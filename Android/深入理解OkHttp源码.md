# 深入理解OkHttp源码

首先理一下okHttp使用的一般流程：

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

一步一步来看，1、2、3中是初始化的一些对象，设计到的点主要是Builder的设计模式，在Builder的构造方法中做了一些相关参数的默认初始化；

4中是通过client.newCall(request)得到了一个Call，其实client.newCall中调用的是RealCall.newRealCall(request),newRealCall是RealCall的一个静态方法，RealCall.newRealCall中new了一个RealCall对象并返回，同时newRealCall还有一个OKHttpClient类型的形参，这里调用的时候传入的是this，即client本身，所以此时new出的这个RealCall对象中是由client的引用的，所以我们看到的4中的Call call实际上是一个RealCall对象。

再往下，对同步请求来说，调用的是call.excute()，我们刚才说了这个call实际上是一个RealCall对象，所以call.excute()实际上调用的是RealCall.excute()方法，RealCall.excute()方法中首先有一个用synchronized加锁的代码块，该代码块通过一个标志位判断当前RealCall是否已经被执行过，如果已经被执行过就抛出异常并将标志位赋值，这也就是为什么我们调用两次call.excute()会抛异常的原因，如果当前RealCall没有被执行过，则执行Response result = getResponseWithInterceptorChain();方法得到Response，而在getResponseWithInterceptorChain（）方法中才是okHttp的精髓所在，getResponseWithInterceptorChain中首先会new出一个Interceptor的集合（List），然后将各类Interceptor加入到这个list中，包括我们自定义的Interceptor（在OkHttpclient.builder()中添加）和okHttp本身的Interceptor，顺序是我们自定义的interceptor、retryAndFollowUpInterceptor、…、ConnectInterceptor，然后new了一个RealInterceptorChain，记做chain1，传入了一个index=0和我们刚才new的Interceptors集合，并执行了它的proceed（Request）方法，而Response也是由这个方法返回的，即chain1.proceed()在chain1.proceed()方法中，首先判断当前index是否超过了Interceptor list的大小，如果超过了就抛出异常，否则再new一个RealInterceptorChain记做chain2，但是这次传入的参数是index+1，当然还有刚才的Interceptor list，然后根据Interceptor list和当前index获取到当前的Interceptor，然后调用interceptor的intercept方法，传入chain2,在当前chain1的intercept方法中又会调用chain2的proceed方法，这样一级一级将事件传递下去，最后到ConnectInterceptor最终建立连接，所以这也就决定了我们自定义interceptor时最后必须返回chain.proceed（request），否则会报错，这实际是一种责任链模式。

因为CallServerInterceptor是最后一个拦截器，如果前面的拦截器都没有返回response的话CallServerInterceptor.interceptor()方法中是一定要返回response的，所以在该方法中没有chain.proceed()的调用，在该Interceptor方法中我们可以看到，核心工作都由 HttpCodec 对象完成，而 HttpCodec 实际上利用的是 Okio，而 Okio 实际上还是用的 Socket，所以没什么神秘的，只不过一层套一层，层数有点多。



![image-20190302152951243](https://ws1.sinaimg.cn/large/006tKfTcgy1g0ohg7tx61j313z0u0tpt.jpg)

RealInterceptorChain的proceed方法是一个被重载的方法，proceed（request）会调用`proceed(Request request, StreamAllocation streamAllocation, HttpCodec httpCodec,RealConnection connection)`，但是ConnectInterceptor的intercept方法会直接调用`proceed(Request request, StreamAllocation streamAllocation, HttpCodec httpCodec,RealConnection connection)`而不是proceed（request）。



上面是同步的网络请求的流程，关于异步的：

异步我们一般调用的是client.enqueue(Callback),在enqueue(Callback)中也会首先用一个sychronized代码块判断当前client是否已经被enqueue过，如果已经被执行过，则抛出异常，如果一切正常继续向下执行，其会调用client.dispatcher().enqueue(new AsyncCall(CallBack))，这里使用CallBack实例化了一个AsyncCall并传入了enqueue中，在enqueue中首先会判断当前是否还能再增加一个并发请求（通过runningAsyncCalls的数量是否小于允许的最大Request数量），如果不可以，就将当AsyncCall加入readyAsyncCalls中让其等待，否则将其加入到runningAsyncCalls中，然后执行executorService().execute(call)，executorService（）其实返回的是一个线程池对象，所以这里的AsyncCall对象一定是实现了Runnable接口的并重写了run方法，看了一下源码确实是这样，其在run方法中调用了一个excute（）方法，跟进去后发现了刚才分析过的getResponseWithInterceptorChain（），而且在这里调用了我们刚才传入的callback对象的不同方法，在该方法的try…finally块的finally中调用了dispatcher.finushed(this)方法，跟进去发现finished也是一个被重载的方法，真正的核心块中执行的逻辑是先将当前执行的call从runningAsyncCalls中删除，然后将readyAsyncCalls 队列中的call对象取出来, 加入到runningAsyncCalls 队列中, 然后立即执行.这就是异步的大概流程。

同时上面还提到了一个dispatcher类，该类中维护了三个双端队列（Deque）：

- readyAsyncCalls：准备运行的异步请求
- runningAsyncCalls：正在运行的异步请求
- runningSyncCalls：正在运行的同步请求

maxRequests是最大同时请求数量, 大小是64.

至于那个excutorService（）涉及到的就是线程池的技术了。

addNetworkInterceptor和addInterceptor的区别：

关于这一点，主要的区别是调用次数的不一样，官方文档说如果url是重定向的，networkInrerceptor会运行两次，第一次是request to"http://www.aaa.com"，第二次是redirect to"http://aaa.com"，如果有的api没有重定向这一说的话就只会调用一次networkInterceptor，否则就是两次。

连接池：

客户端和服务器建立socket连接需要经历TCP的三次握手和四次挥手，是一种比较消耗资源的动作。Http中有一种keepAlive connections的机制，在和客户端通信结束以后可以保持连接指定的时间。OkHttp3支持5个并发socket连接，默认的keepAlive时间为5分钟。

okHttp中的连接池逻辑主要是通过ConnectionPool实现的，它是在Okhttpclient的builder中被创建的，的里的几个重要变量：

（1）executor线程池，类似于CachedThreadPool，用于执行清理空闲连接的任务。

（2）Deque双向队列，同时具有队列和栈的性质，经常在缓存中被使用，里面维护的RealConnection是socket物理连接的包装

（3）RouteDatabase，用来记录连接失败的路线名单

get，获取连接：

遍历连接池里的连接connections，通过address等条件找到到符合条件的连接，如果有符合条件的连接则复用。需要注意的是，这里还调用了streamAllocation的acquire方法。acquire方法的作用是对RealConnection引用的streamAllocation进行计数，OkHttp3是通过RealConnection的StreamAllocation的引用计数是否为0来实现自动回收连接的。

acquire计数加1

release计数减1

put添加连接：

添加连接之前会先调用线程池执行清理空闲连接的任务，也就是回收空闲的连接。

空闲连接的回收：

cleanupRunnable中执行清理任务是通过cleanup方法来完成，cleanup方法会返回下次需要清理的间隔时间，然后会调用wait方法释放锁和时间片。等时间到了就再次进行清理。

通过每个连接的引用计数对象StreamAllocation的计数来回收空闲的连接，向连接池添加新的连接时会触发执行清理空闲连接的任务。清理空闲连接的任务通过线程池来执行。

