# 深入理解OkHttp源码

首先理一下`okHttp`使用的一般流程：

```java
1：OkHttpClient.Builder okHttpClientBuilder=new OkHttpClient.Builder();//创建Builder，可以在这里设置OkHttpClient的相关参数，比如：new OkHttpClient.Builder().readTimeout(20, TimeUnit.SECONDS)
2：OkHttpClient client=okHttpClientBuilder.build();//Builder设计模式
3：Request request=new Request.Builder().url().build();//又是Builder设计模式,如果是post请求就是new Request.Builder().url().post(formBody).build()
4：Call call=client.newCall(request)//创建Call
//同步请求
5：Response response=call.excute();
//异步请求
6：call.enqueue(new CallBack(){
    onFailure(Request request, IOException e) {
        ...
    }
    
    onResponse(Response response){
        ...
    }
})

```

一步一步来看，1、2、3中是初始化的一些对象，设计到的点主要是`Builder`的设计模式，在`Builder`的构造方法中做了一些相关参数的默认初始化；

4中是通过`client.newCall(request)`得到了一个`Call`，其实`client.newCall`中调用的是`RealCall.newRealCall(request)`，`newRealCall`是`RealCall`的一个静态方法，`RealCall.newRealCall`中`new`了一个`RealCall`对象并返回，同时`newRealCall`还有一个`OKHttpClient`类型的形参，这里调用的时候传入的是`this`，即`client`本身，所以此时`new`出的这个`RealCall`对象中是含有`client`的引用的，所以我们看到的4中的`Call call`实际上是一个`RealCall`对象。

## 同步请求

对同步请求来说，下一步调用的是`call.excute()`，我们刚才说了这个`call`实际上是一个`RealCall`对象，所以`call.excute()`实际上调用的是`RealCall.excute()`方法:

```java
@Override public Response execute() throws IOException {
    synchronized (this) {
      if (executed) throw new IllegalStateException("Already Executed");
      executed = true;
    }
    captureCallStackTrace();
    timeout.enter();
    eventListener.callStart(this);
    try {
      client.dispatcher().executed(this);
      Response result = getResponseWithInterceptorChain();
      if (result == null) throw new IOException("Canceled");
      return result;
    } catch (IOException e) {
      e = timeoutExit(e);
      eventListener.callFailed(this, e);
      throw e;
    } finally {
      client.dispatcher().finished(this);
    }
  }
```

`RealCall.excute()`方法中首先有一个用`synchronized`加锁的代码块，该代码块通过一个布尔类型的`excuted`标志位判断当前`RealCall`的`excute`是否已经被执行过，如果已经被执行过就抛出异常并将标志位赋值，这也就是为什么我们调用两次`call.excute()`会抛异常的原因，如果当前`RealCall`的`excute`方法没有被执行过，则执行`client.dispatcher().executed(this)`，而在`dispatcher`的`excute`中将当前`RealCall`对象加入到了一个`runningSyncCalls`的`list`集合里面，然后调用`Response result = getResponseWithInterceptorChain();`方法得到`Response`，而在`getResponseWithInterceptorChain（）`方法中才是okHttp的精髓所在，`getResponseWithInterceptorChain()`中首先会`new`出一个`Interceptor的集合（List）`，然后将我们调用`addInterceptor()`添加的拦截器（在`OkHttpclient.builder()`中添加）、`retryAndFollowUpInterceptor`（负责失败重试以及重定向）、`BridgeInterceptor`（请求时，对必要的`Header`进行一些添加，接受响应时，移除必要的`Header`）、`CacheInterceptor`（负责读取缓存直接返回、更新缓存）、`ConnectInterceptor`（负责和服务器建立连接）、我们通过`addNetworkInterceptor()`添加的拦截器、`CallServerInterceptor`（ 负责向服务器发送请求数据、从服务器读取响应数据）拦截器依次加入该`list`中，然后使用`Interceptor.Chain chain = new RealInterceptorChain `，`new`了一个`RealInterceptorChain`，`Interceptor.Chain`是一个接口，记做`chain1`，传入了一个`index=0`和我们刚才`new`的`Interceptors`集合，并执行了它的`proceed（Request）`方法，`RealInterceptorChain`是其实现类，而`Response`也是由这个方法返回的，在`RealInterceptorChain.proceed()`方法中，首先判断当前`index`是否超过了`Interceptor list`的大小，如果超过了就抛出异常，否则再`new`一个`RealInterceptorChain``记做chain2`，但是这次传入的参数是`index+1`，当然还有刚才的`Interceptor list`，然后根据`Interceptor list`和当前`index`获取到当前的`Interceptor`，然后调用`interceptor`的`intercept()`方法，传入`chain2``,在intercept`方法中又会调用`chain2`的`proceed`方法，这样一级一级将事件传递下去，最后到`CallServerInterceptor`最终建立连接，最后，由于在`RealCall.excute`方法中调用了`client.dispatcher().executed(this)`将当前`call`加入了`dispater`的`runningSynCalls list`中，所以在最后的`try finally`块中会调用`client.dispatcher().finished(this);`将之前加入的`call`从`runningSynCalls`中移除，`interceptor`时最后必须返回`chain.proceed（request`），否则会报错，这实际是一种责任链模式。

因为`CallServerInterceptor`是最后一个拦截器，如果前面的拦截器都没有返回`response`的话`CallServerInterceptor.interceptor()`方法中是一定要返回`response`的，所以在该方法中没有`chain.proceed()`的调用，在该`Interceptor`方法中我们可以看到，核心工作都由` HttpCodec `对象完成，而 `HttpCodec` 实际上利用的是` Okio`，而` Okio `实际上还是用的 `Socket`，所以没什么神秘的，只不过一层套一层，层数有点多。

![屏幕快照 2019-04-11 16.57.31](https://ws1.sinaimg.cn/large/006tNc79gy1g1ysshm70pj314b0u07m2.jpg)

`RealInterceptorChain`的`proceed`方法是一个被重载的方法，`proceed（request）`会调用`proceed(Request request, StreamAllocation streamAllocation, HttpCodec httpCodec,RealConnection connection)`，但是`ConnectInterceptor`的`intercept`方法会直接调用`proceed(Request request, StreamAllocation streamAllocation, HttpCodec httpCodec,RealConnection connection)`而不是`proceed（request`）。

## 异步请求

异步我们一般调用的是`client.enqueue(Callback)`,在`RealCall.enqueue(Callback)`中也会首先用一个`sychronized`代码块判断当前`client`是否已经被`enqueue`过，如果已经被执行过，则抛出异常，如果一切正常继续向下执行，其会调用`client.dispatcher().enqueue(new AsyncCall(CallBack))`，这里使用`CallBack`实例化了一个`AsyncCall`并传入了`enqueue`中，这个`AsyncCall`一会再详细讲，在`enqueue`中首先会将当前`call add`到一个`readyAsyncCalls list`中，然后调用`promoteAndExecute（）`方法，该方法中首先`new``了一个AsyncCall`类型的`list`，叫做`executableCalls`，然后使用一个`synchronized`块，在该`synchronized`代码块中首先使用了一个循环对`readyAsyncCalls`进行了遍历，对每一个`readyAsyncCalls`中的`RealCall`，首先判断当前`runningAsyncCalls.size()` 是否大于等于`maxRequests`即最大的请求数量，如果大于，跳出循环，否则将当前`RealCall`加入到`runningAsyncCalls`和`executableCalls`中，最后，对加入到`executableCalls`中的每一个`RealCall`对象，调用`asyncCall.executeOn(executorService())`方法进行执行，`executorService（）`方法返回的是一个`ExecutorService`类型的对象，在`executorService（）`里面`new`了一个`ThreadPoolExecutor`，`corePoolSize`是0，`maximumPoolSize`是`Integer.MAX_VALUE`，并将其返回，所以说`asyncCall.executeOn`中传入的是一个线程池，在`executeOn`中使用传入的线程池执行了当前`asyncCall``的run`方法，然后调用`client.dispatcher().finished(this)`将当前`RealCall`从`runningAsyncCalls`中移除，而`AsyncCall`是一个继承了`NamedRunnable`抽象类的类，而`NamedRunnable`实现了`Runnable``接口，在NamedRunnable`中声明了一个抽象方法`excute（）`并在`NamedRunnable`的`run（）``方法中调用了该excute（）`，在`AsyncCall`中实现了该`excute`方法，在里面调用了`getResponseWithInterceptorChain（）`方法，之后根据不同的请求结果回调了我们传入的`CallBack`对象的回调方法（`onFailure`、`onResponse`），之后就和同步请求是类似的逻辑了。

## dispatcher

上面还提到了一个`dispatcher`类，该类中维护了三个双端队列（`Deque`）：

- `readyAsyncCalls`：准备运行的异步请求
- `runningAsyncCalls`：正在运行的异步请求
- `runningSyncCalls`：正在运行的同步请求

`maxRequests`是最大同时请求数量, 大小是**64**.

至于那个`excutorService（）`涉及到的就是线程池的技术了。

`addNetworkInterceptor`和`addInterceptor`的区别：

关于这一点，主要的区别是调用次数的不一样，官方文档说**如果url是重定向的**，`networkInrerceptor`会运行两次，第一次是request to"http://www.aaa.com"，第二次是redirect to"http://aaa.com"，如果有的api没有重定向这一说的话就只会调用一次`networkInterceptor`，否则就是两次。

## 连接池

客户端和服务器建立`socket`连接需要经历`TCP`的三次握手和四次挥手，是一种比较消耗资源的动作。`Http`中有一种`keepAlive connections`的机制，在和客户端通信结束以后可以保持连接指定的时间。连接池的默认配置是5个空闲连接，每个空闲连接保持5分钟。当连接被占用时会和一个`StreamAllocation``建立引用关系，所以可以从connections`这个队列里看出哪些连接是空闲的，那些连接是被占用的。

一个清理线程在后台工作，通过`cleanup`方法实现清理，如果有一个连接满足被清理的条件（存活时间超时或空闲连接过多），就将其清理掉

`okHttp`中的连接池逻辑主要是通过`ConnectionPool`实现的，在`ConnectionPool`的内部有一个`private static final Executor executor =new ThreadPoolExecutor（）`，其线程池基本大小是0，线程池最大大小是`Integer.MAX_VALUE`，它是在`Okhttpclient`的`builder`中被创建的，的里的几个重要变量：

（1）`executor`线程池，类似于`CachedThreadPool`，用于执行清理空闲连接的任务。

（2）`Deque`双向队列，同时具有队列和栈的性质，经常在缓存中被使用，里面维护的`RealConnection`是`socket`物理连接的包装

（3）`RouteDatabase`，用来记录连接失败的路线名单

### get获取连接

遍历连接池里的连接`connections`，通过`address`等条件找到到符合条件的连接，如果有符合条件的连接则复用。需要注意的是，这里还调用了`streamAllocation`的`acquire`方法。`acquire`方法的作用是对`RealConnection`引用的`streamAllocation`进行计数，`OkHttp3`是通过`RealConnection`的`StreamAllocation`的引用计数是否为0来实现自动回收连接的。

acquire计数加1

release计数减1

### put添加连接

添加连接之前会先调用线程池执行清理空闲连接的任务，也就是回收空闲的连接。

### 空闲连接的回收

`cleanupRunnable`中执行清理任务是通过`cleanup`方法来完成，`cleanup`方法会返回下次需要清理的间隔时间，然后会调用`wait`方法释放锁和时间片。等时间到了就再次进行清理。

通过每个连接的引用计数对象`StreamAllocation`的计数来回收空闲的连接，向连接池添加新的连接时会触发执行清理空闲连接的任务。清理空闲连接的任务通过线程池来执行。

