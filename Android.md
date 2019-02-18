# Android

## Android的系统架构是怎么样的？

Android从底层到顶层依次是：Linux内核（Linux kernel）、HAL（硬件抽象层）、系统运行库与Android运行环境、应用程序框架(Application Frameworks)、应用程序(Applications)



## Android四大组件

Android四大组件分别是`Activity`，`Service`服务,`Content Provider`内容提供者，`BroadcastReceiver`广播接收器。

### Activity

### Service

### Content Provider

主要的作用就是将程序的内部的数据和外部进行共享，为数据提供外部访问接口，被访问的数据主要以数据库的形式存在，而且还可以选择共享哪一部分的数据。这样一来，对于程序当中的隐私数据可以不共享，从而更加安全。content provider是android中一种跨程序共享数据的重要组件。

### BroadcastReceiver

广播被分为两种不同的类型：“**普通广播**（Normal broadcasts）”和“**有序广播**（Ordered broadcasts）”。

普通广播是完全异步的，通过`Context.sendBroadcast()`方法发送，可以在同一时刻（逻辑上）被所有接收者接收到，消息传递的效率比较高，但缺点是：接收者不能将处理结果传递给下一个接收者，并且无法终止广播Intent的传播；

有序广播通过`Context.sendOrderedBroadcast()`方法发送，是按照接收者声明的优先级别（声明在intent-filter元素的android:priority属性中，数越大优先级别越高,取值范围:-1000到1000。也可以调用IntentFilter对象的setPriority()进行设置），被接收者依次接收广播。前面的接收者可以将处理结果通过setResultExtras(Bundle)方法存放进结果对象，然后传给下一个接收者，通过代码：Bundle bundle =getResultExtras(true))可以获取上一个接收者存入在结果对象中的数据。

比如想阻止用户收到短信，可以通过设置优先级，让你们自定义的接收者先获取到广播，然后终止广播，这样用户就接收不到短信了。

## Application，Task和Process的区别与联系

### Application

application翻译成中文时一般称为“应用”或“应用程序”，在android中，总体来说一个应用就是一组组件的集合。众所周知，android是在应用层组件化程度非常高的系统，android开发的第一课就是学习android的四大组件。当我们写完了多个组件，并且在manifest文件中注册了这些组件之后，把这些组件和组件使用到的资源打包成apk，我们就可以说完成了一个application。application和组件的关系可以在manifest文件中清晰地体现出来。如下所示：

```java

<?xml version="1.0" encoding="utf-8"?>
<manifest android:versionCode="1"
        android:versionName="1"
        xmlns:android="http://schemas.android.com/apk/res/android"
        package="com.example.android.myapp">
 
    <application android:label="@string/app_name">
        <activity android:name=".MyActivity" android:label="@string/app_nam">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
	<receiver android:name=".MyReceiver"/>
	<provider android:name=".MyProvider"/>
	<service android:name=".MyService"/>
    </application>
</manifest>

```

由此可见，application是由四大组件组成的。在app安装时，系统会读取manifest的信息，将所有的组件解析出来，以便在运行时对组件进行实例化和调度。

### Task

task是在程序运行时，只针对activity的概念。说白了，task是一组相互关联的activity的集合，它是存在于framework层的一个概念，控制界面的跳转和返回。这个task存在于一个称为back stack的数据结构中，也就是说，framework是以栈的形式管理用户开启的activity。这个栈的基本行为是，当用户在多个activity之间跳转时，执行压栈操作，当用户按返回键时，执行出栈操作。

 task是可以跨应用的，这正是task存在的一个重要原因。有的Activity，虽然不在同一个app中，但为了保持用户操作的连贯性，把他们放在同一个任务中。例如，在我们的应用中的一个Activity A中点击发送邮件，会启动邮件程序的一个Activity B来发送邮件，这两个activity是存在于不同app中的，但是被系统放在一个任务中，这样当发送完邮件后，用户按back键返回，可以返回到原来的Activity A中，这样就确保了用户体验。

### process

process一般翻译成进程，进程是操作系统内核中的一个概念，表示直接受内核调度的执行单位。在应用程序的角度看，我们用java编写的应用程序，运行在dalvik虚拟机中，可以认为一个运行中的dalvik虚拟机实例占有一个进程，所以，在默认情况下，一个应用程序的所有组件运行在同一个进程中。但是这种情况也有例外，即，应用程序中的不同组件可以运行在不同的进程中。只需要在manifest中用process属性指定组件所运行的进程的名字。如下所示：

```java
<activity android:name=".MyActivity" android:label="@string/app_nam"
		android:process=":remote">
 </activity>
```

这样的话这个activity会运行在一个独立的进程中。

## 线程（Thread）和进程（process）的区别

进程和线程的主要差别在于它们是不同的操作系统资源管理方式。进程有独立的地址空间，一个进程崩溃后，在保护模式下不会对其它进程产生影响，而线程只是一个进程中的不同执行路径。线程有自己的堆栈和局部变量，但线程之间没有单独的地址空间，一个线程死掉就等于整个进程死掉，所以多进程的程序要比多线程的程序健壮，但在[进程切换](https://www.baidu.com/s?wd=%E8%BF%9B%E7%A8%8B%E5%88%87%E6%8D%A2&tn=24004469_oem_dg&rsv_dl=gh_pl_sl_csd)时，耗费资源较大，效率要差一些。**但对于一些要求同时进行并且又要共享某些变量的并发操作，只能用线程，不能用进程。**

**1) 简而言之,一个程序至少有一个进程,一个进程至少有一个线程.**

2) 线程的划分尺度小于进程，使得多线程程序的并发性高。

3) 另外，进程在执行过程中拥有独立的内存单元，而多个线程共享内存，从而极大地提高了程序的运行效率。

4) 线程在执行过程中与进程还是有区别的。每个独立的线程有一个程序运行的入口、顺序执行序列和程序的出口。**但是线程不能够独立执行，**必须依存在应用程序中，由应用程序提供多个线程执行控制。

5) 从逻辑角度来看，多线程的意义在于一个应用程序中，有多个执行部分可以同时执行。但操作系统并没有将多个线程看做多个独立的应用，来实现进程的调度和管理以及资源分配。**这就是进程和线程的重要区别。**



线程和进程在使用上各有优缺点：线程执行开销小，但不利于资源的管理和保护；而进程正相反。同时，线程适合于在SMP机器上运行，而进程则可以跨机器迁移。



## Activity生命周期

![1](https://ws4.sinaimg.cn/large/006tKfTcly1g0ahnvdf3oj30ie087q4j.jpg)

在上面的图中存在不同状态之间的过渡，但是，这些状态中只有三种可以是静态，也就是说 Activity 只能在三种状态之一下存在很长时间：

- **Resumed**：Activity处于前台，且用户可以与其交互（又称为运行态，在调用 `onResume()` 方法调用后）。
- **Paused**：Activity被在前台中处于半透明状态或者未覆盖整个屏幕的另一个Activity—部分阻挡。 暂停的Activity不会接收用户输入并且无法执行任何代码。
- **Stopped**：Activity被完全隐藏并且对用户不可见；它被视为处于后台。 停止时，Activity实例及其诸如成员变量等所有状态信息将保留，但它无法执行任何代码。

其他状态（“Created”和“Started”）是瞬态，系统会通过调用下一个生命周期回调方法从这些状态快速移到下一个状态。 也就是说，在系统调用 `onCreate()` 之后，它会快速调用 `onStart()`，紧接着快速调用 `onResume()`。

- 启动`activity`：系统先调用`onCreate()`，然后调用`onStart()`，最后调用`onResume()`方法，`activity`进入运行状态。

- `activity`被**其他activity覆盖其上（DialogActivity）**或者**锁屏**：系统会调用`onPause()`方法，暂停当前`activity`的执行。

- 当前`activity`由被`覆盖`状态回到前台或者`解锁屏`：系统会调用`onResume()`方法，再次进入运行状态。

- 当前`Activity`转到新的`Activity`界面或按`Home`键回到主屏，自身退居后台：系统会先调用`onPause`方法，然后调用`onStop`方法，进入停滞状态。

- 用户后退回到此`Activity`：系统会先调用`onRestart`方法，然后调用`onStart`方法，最后调用`onResume`方法，再次进入运行状态。

- 当前`Activity`处于被覆盖状态或者后台不可见状态，即第2步和第4步，系统内存不足，杀死当前`Activity`，而后用户退回当前`Activity`：再次调用`onCreate`方法、`onStart`方法、`onResume`方法，进入运行状态。

- 用户退出当前`Activity`：系统先调用`onPause`方法，然后调用`onStop`方法，最后调用`onDestory`方法，结束当前`Activity`。

- `onRestart()`：表示`activity`正在重新启动 ，一般情况下，当前`activity`从`不可见`重新`变成可见`状态时，`onRestart()`就会被调用，这种情形一般是用户行为所导致的，比如用户按`HOME`键切换到桌面然后重新打开`APP`或者按`back`键。

- `onStart()`：`activity`可见了，但是还没有出现在前台，还**无法和用户交互**。

- `onPause()`：表示`activity`正在停止，此时可以做一些存储数据，停止动画等工作，注意不能太耗时，因为这会影响到新`activity`的显示，`onPause`必须先执行完，新的`activity`的`onResume`才会执行。

- 从`activity`是否可见来说，`onstart()`和`onStop()`是配对的，从`activity`是否在前台来说，`onResume()`和`onPause()`是配对的。

- **旧activity先onPause，然后新activity在启动**

当`activity`中弹出`dialog`对话框的时候，`activity不会回调onPause`。
然而当`activity`启动`dialog风格的activity`的时候，此`activity会回调onPause函数`。

## service生命周期

![2](https://ws2.sinaimg.cn/large/006tKfTcly1g0ahvy80hwj30ir0fcdh6.jpg)

- Start Service：通过`context.startService()`启动，这种service可以无限制的运行，除非调用`stopSelf()`或者其他组件调用`context.stopService()`。
- Bind Service：通过`context.bindService()`启动，客户可以通过IBinder接口和service通信，客户可以通过`context.unBindService()`取消绑定。一个service可以和多个客户绑定，当所有客户都解除绑定后，service将终止运行。

一个通过`context.startService()`方法启动的service，其他组件也可以通过`context.bindService()`与它绑定，在这种情况下，不能使用`stopSelf()`或者`context.stopService()`停止service，只能当所有客户解除绑定在调用`context.stopService()`才会终止。

## activity启动的四种模式

standard，singleTop，singleTask，singleInstance，如果要使用这四种启动模式，必须在manifest文件中<activity>标签中的launchMode属性中配置，如：

```java
<activity android:name=".app.InterstitialMessageActivity"
                  android:label="@string/interstitial_label"
                  android:theme="@style/Theme.Dialog"
                  android:launchMode="singleTask"
</activity>
```

### standard

标准启动模式，也是activity的默认启动模式。在这种模式下启动的activity可以被多次实例化，即在同一个任务中可以存在多个activity的实例，每个实例都会处理一个Intent对象。如果Activity A的启动模式为standard，并且A已经启动，在A中再次启动Activity A，即调用startActivity（new Intent（this，A.class）），会在A的上面再次启动一个A的实例，即当前的桟中的状态为A-->A。

### singleTop

如果一个以singleTop模式启动的activity的实例已经存在于任务桟的桟顶，那么再启动这个Activity时，不会创建新的实例，而是重用位于栈顶的那个实例，并且会调用该实例的onNewIntent()方法将Intent对象传递到这个实例中。举例来说，如果A的启动模式为singleTop，并且A的一个实例已经存在于栈顶中，那么再调用startActivity（new Intent（this，A.class））启动A时，不会再次创建A的实例，而是重用原来的实例，并且调用原来实例的onNewIntent()方法。这时任务桟中还是这有一个A的实例。

如果以singleTop模式启动的activity的一个实例已经存在与任务桟中，但是不在桟顶，那么它的行为和standard模式相同，也会创建多个实例。

### singleTask

栈内复用模式。这种模式下，只要Activity只要在一个栈内存在，那么就不会创建新的实例，会调用`onNewIntent()`方法。

- 如果要调用的Activity在同一应用中：调用singleTask模式的Activity会清空在它之上的所有Activity。
- 若其他应用启动该Activity：如果不存在，则建立新的Task。如果已经存在后台，那么启动后，后台的Task会一起被切换到前台。

适合作为程序入口点，例如浏览器的主界面。不管从多少个应用启动浏览器，只会启动主界面一次，其余情况都会走onNewIntent，并且会清空主界面上面的其他页面。

### singleInstance

单实例模式。这时一种加强的singleTask，它除了具有singleTask的所有特性外，还加强了一点--该模式的Activity只能单独的位于一个Task中。

不同Task之间，默认不能传递数据(`startActivityForResult()`)，如果一定要传递，只能使用Intent绑定。

![image-20190218133254451](https://ws1.sinaimg.cn/large/006tKfTcly1g0ain5wyjmj30u012cb2a.jpg)

适合需要与程序分离开的页面。例如闹铃提醒，将闹铃提醒与闹铃设置分离。

## mvp与mvc以及mvvm三中常见架构的区别

### mvc

View传送指令到Controller,Controller完成业务逻辑后，改变Model的状态，Model将新的数据发送到View：

![image-20190218133710850](https://ws1.sinaimg.cn/large/006tKfTcly1g0air9v4u7j31300l212r.jpg)

1. View 传送指令到 Controller
2. Controller 完成业务逻辑后，要求 Model 改变状态
3. Model 将新的数据发送到 View，用户得到反馈

所有通信都是单向的

### mvp

View不直接与Model交互，而是通过与Presenter交互来与Model间接交互。
Presenter与View的交互是通过接口来进行的。
通常View与Presenter是一对一的，但复杂的View可能绑定多个Presenter来处理逻辑。

1. 各部分之间的通信，都是双向的。

2. View 与 Model 不发生联系，都通过 Presenter 传递。

3. View 非常薄，不部署任何业务逻辑，称为"被动视图"（Passive View），即没有任何主动性，而 Presenter非常厚，所有逻辑都部署在那里。

![image-20190218133747942](https://ws1.sinaimg.cn/large/006tKfTcly1g0airwblpgj31dw09ogud.jpg)

### mvvm

MVVM 模式将 Presenter 改名为 ViewModel，基本上与 MVP 模式完全一致。

![4](https://ws3.sinaimg.cn/large/006tKfTcly1g0aiyvcr2xj30fg0brwei.jpg)

唯一的区别是，它采用双向绑定（data-binding）：View的变动，自动反映在 ViewModel，反之亦然。

## listview原理及优化

ListView的实现离不开Adapter。可以这么理解：ListView中给出了数据来的时候，如何实现View的具体方式，相当于MVC中的V；而Adapter相当于MVC中的C，指挥了ListView的数据加载等行为。

提一个问题：假设ListView中有10W个条项，那内存中会缓存10W个吗？答案当然是否定的。那么是如何实现的呢？下面这张图可以清晰地解释其中的原理:

![5](https://ws2.sinaimg.cn/large/006tKfTcly1g0aj18qi2dj30xz0n879d.jpg)

可以看到当一个View移出可视区域的时候，设为View1，它会被标记Recycle，然后可能：

- 新进入的View2与View1类型相同，那么在getView方法传入的convertView就不是null而就是View1。换句话说，View1被重用了
- 新进入的View2与View1类型不同，那么getView传入的convertView就是null，这是需要new一个View。当内存紧张时，View1就会被GC

### listview的优化

以异步加载Bitmap优化为例

首先概括的说ListView优化分为三级缓存:

- 内存缓存
- 文件缓存
- 网络读取

简要概括就是在getView中，如果加载过一个图片，放入Map类型的一个MemoryCache中，如果这里获取不到，根据View被Recycle之前放入的TAG中记录的uri从文件系统中读取文件缓存。如果本地都找不到，再去网络中异步加载。

这里有几个注意的优化点：

- 从文件系统中加载图片没有内存中加载那么快，甚至可能内存中加载也不够快。因此在ListView中应设立busy标志位，当ListView滚动时busy设为true，停止各个view的图片加载。否则可能会让UI不够流畅用户体验度降低。
- 文件加载图片放在子线程实现，否则快速滑动屏幕会卡
- 开启网络访问等耗时操作需要开启新线程，应使用线程池避免资源浪费，最起码也要用AsyncTask。
- Bitmap从网络下载下来最好先放到文件系统中缓存。这样一是方便下一次加载根据本地uri直接找到，二是如果Bitmap过大，从本地缓存可以方便的使用Option.inSampleSize配合Bitmap.decodeFile(ui, options)或Bitmap.createScaledBitmap来进行内存压缩

## Android为什么不允许在非UI线程更新UI

Android的UI控件不是线程安全的，在多线程中并发访问可能出现问题，比如A线程在t时刻想让textview1显示`demoa`，B线程并发地同时在t时刻想让textview1显示`demob`，这个时候就不知道该听谁的，所以索性都不给他们更新UI的权利，想要更新UI必须向UI线程发起请求，这样就不会出现并发访问的矛盾问题了。



## Android中的Handler机制（Android消息机制）

Android消息机制主要是指Handler的运行机制及Handler所附带的MessageQueue和Looper的工作过程

### 什么是Handler机制

一套 `Android` 消息传递机制：

![image-20190218141119588](https://ws1.sinaimg.cn/large/006tKfTcly1g0ajr0frz5j31qy0lqtnc.jpg)

子线程中默认是没有Looper的，如果要使用Handler就必须为子线程创建Looper。如果当前线程没有Looper就会报错：`Can’t create handler inside thread that has not called Looper.prepare() `
主线程(UI线程)即是ActivityThread，ActivityThread被创建时会初始化Looper，所以在主线程中直接可以使用Handler。

### Handler机制的作用

Handler 可以将一个任务切换到Handler所在线程中去执行，Handler的主要作用是更新UI,有时候需要在子线程进行耗时的I/O操作(读取文件或者访问网络)，当耗时任务完成后，需要在UI线程中做一些改变，由于我们不能在子线程中访问UI控件，否则会发生异常，通过Handler就可以将跟新UI操作切换到主线程中执行，即Handler解决了在子线程中无法访问UI的矛盾。 

### Handler的工作过程

![image-20190218141417443](https://ws2.sinaimg.cn/large/006tKfTcly1g0ajtuk4euj31300ki43r.jpg)

Handler的send方法被调用时，它会调用MessageQueue的enqueueMessage方法，将消息放入消息队列中，当Looper发现有新消息来时，就会处理这个消息，最终Handler的handleMessage方法就会被调用。

#### ThreadLocal的工作原理

ThreadLocal是Java提供的用于保存同一进程中不同线程数据的一种机制。

ThreadLocal是一个线程内部的数据存储类，通过它可以在指定线程中存储数据，数据存储以后，只有在指定的线程中获取到存储数据，对于其他线程来说则无法获取到数据。

示例代码：

![image-20190218141548694](https://ws2.sinaimg.cn/large/006tKfTcly1g0ajvkfefkj31300s2nh1.jpg)

运行结果截图： 

![image-20190218141617749](https://ws3.sinaimg.cn/large/006tKfTcly1g0ajvy3m5xj313003owl4.jpg)

可以看出不同线程访问的是同一个ThreadLocal，但是它们通过ThreadLocal获取的值却不一样。 
主线程设置的是true，所以获取到的是true 
第一个子线程设置的是false，所以获取到的是false 
第二个子线程没有设置，所以获取到的是null

#### 消息队列MessageQueue的工作原理

![image-20190218141738158](https://ws2.sinaimg.cn/large/006tKfTcly1g0ajxckrscj312c06y42s.jpg)

MessageQueue：消息队列，内部实现是通过一个单链表的数据结构来维护消息列表

eqeueMessage：就是向单链表中插入数据。 
next：是一个无线循环的方法，如果没有消息，next方法就一直阻塞在这了 
如果有消息，next方法就返回这条消息并将消息从单列表中移除。

#### Looper的工作原理

Looper扮演者消息循环的角色，不停的从消息队列MessageQueue中查看是否具有消息，如果有消息就会立刻处理，否则就一直阻塞在那里

Handler中需要Looper，没有Looper线程就会报错，通过Looper.prepare()就可以为当前线程创建一个Looper，通过Looper.loop()来开启消息循环。

### Handler的使用套路

主线程中声明一个Handler，重写其handleMessage(Message msg)方法，通过msg.what属性的值对应到其他线程发送的Message并利用该Message拿到其他线程传过来的数据。

## Android中的广播机制

广播(Broadcast)机制用于进程/线程间通信，广播分为广播发送和广播接收两个过程，其中广播接收者BroadcastReceiver便是Android四大组件之一。

BroadcastReceiver分为两类：

- `静态广播接收者`：通过`AndroidManifest.xml`的标签来申明的BroadcastReceiver。
- `动态广播接收者`：通过`AMS.registerReceiver()`方式注册的BroadcastReceiver，动态注册更为灵活，可在不需要时通过`unregisterReceiver()`取消注册。

从广播发送方式可分为三类：

- `普通广播`：通过Context.sendBroadcast()发送，可并行处理
- `有序广播`：通过Context.sendOrderedBroadcast()发送，串行处理
- `Sticky广播`：通过Context.sendStickyBroadcast()发送，发出的广播会一直滞留（等待），以便有人注册这则广播消息后能尽快的收到这条广播。

Android 中的 Broadcast 实际底层使用Binder机制。

## View和ViewGroup的区别

View是Android中所有控件的基类。

ViewGroup继承自View，控件组，可以包含若干个View。

View本身既可以是单个控件，也可以是由多个控件组成的一组控件。

View只能操作自己。

viewGroup能操作自己也可以操作孩子（通过`viewGroup.getChildAt(i).getId()`）。

- View派生出的直接子类

​    ImageView , ViewGroup

●  View派生出的间接子类有： 
   Button

●  ViewGroup派生出的直接子类有： 
    LinearLayout,RelativeLayout

●  ViewGroup派生出的间接子类有： 
    ListView

## Android自定义view的步骤

继承View或者ViewGroup（从View继承一般需要忙活的方法是onDraw这里，从ViewGroup继承一般需要忙活的方法是onLayout这里）

### 构造函数（获取自定义的参数）

主要获取该view在xml文件中声明时的自定义参数，通过AttributeSet对象attrs获取他们的值，一共有四个构造函数：

```java
	public View(Context context) {
        throw new RuntimeException("Stub!");
    }

    public View(Context context, @RecentlyNullable AttributeSet attrs) {
        throw new RuntimeException("Stub!");
    }

    public View(Context context, @RecentlyNullable AttributeSet attrs, int defStyleAttr) {
        throw new RuntimeException("Stub!");
    }

    public View(Context context, @RecentlyNullable AttributeSet attrs, int defStyleAttr, int defStyleRes) {
        throw new RuntimeException("Stub!");
    }
```

一般我们只会用到前两个，第一个是在使用java代码new该view时调用的，第二个是在xml文件中声明后调用的。

### onMeasure（测量View大小）

measure过程要分情况来看，如果只是一个原始的View，那么通过measure方法就完成其测量过程，如果是一个ViewGroup，除了完成自己的测量过程外，还会遍历去调用所有子元素的measure方法。

### onSizeChanged （确定View的大小）

一般情况下onMeasure中就可以把View的大小确定下来了，但是因为View的大小不仅由View本身控制，而且受父控件的影响，所以我们在确定View大小的时候最好使用系统提供的onSizeChanged回调函数。

### onLayout （确定子View的位置）

主要是用于确定子View的具体布局位置，一般是在继承了ViewGroup的时候需要重写这个方法，一般都是在onLayout中获取所有的子类，然后根据需求计算出子View的位置参数，再通过调用子View的layout(l,t, r, b)方法设置子View的位置。

### onDraw （绘制内容）

重写onDraw方法基本可以说是自定义View的一个标配。这部分也决定了自定义View的具体效果。是猫是狗，主要取决于你在一个方法的canvas上画了什么。

## Canvas使用

- **save**：用来保存 Canvas 的状态。save 之后，可以调用 Canvas 的平移、放缩、旋转、错切、裁剪等操作。
- **restore**：用来恢复Canvas之前保存的状态。防止 save 后对 Canvas 执行的操作对后续的绘制有影响。

save 和 restore 要配对使用( restore 可以比 save 少，但不能多)，如果 restore 调用次数比 save 多，会引发 Error 。save 和 restore 之间，往往夹杂的是对 Canvas 的特殊操作。

## Android中的事件分发

事件分发的对象是点击事件，当用户触摸屏幕时（`View` 或 `ViewGroup`派生的控件），将产生点击事件（`Touch`事件），而`Touch`事件的相关细节（发生触摸的位置、时间等）被封装成`MotionEvent`对象，对应的事件类型有4种：

| 事件类型                  | 具体动作                   |
| ------------------------- | -------------------------- |
| MotionEvent.ACTION_DOWN   | 按下View（所有事件的开始） |
| MotionEvent.ACTION_UP     | 抬起View（与DOWN对应）     |
| MotionEvent.ACTION_MOVE   | 滑动View                   |
| MotionEvent.ACTION_CANCEL | 结束事件（非人为原因）     |

`事件列`：从手指接触屏幕 至 手指离开屏幕，这个过程产生的一系列事件，一般情况下，事件列都是以`DOWN`事件开始、`UP`事件结束，中间有0个或多个的MOVE事件。

事件分发的本质：将点击事件（MotionEvent）传递到某个具体的View & 处理的整个过程

事件分发的对象与顺序：

![7](https://ws4.sinaimg.cn/large/006tKfTcly1g0alnqw859j30e10kfabn.jpg)

​	

​	

事件分发中的三个重要方法：dispatchTouchEvent、onInterceptTouchEvent和onTouchEvent

| 方法                                     | 方法中文名 | 解释                                                         |
| ---------------------------------------- | ---------- | ------------------------------------------------------------ |
| dispatchTouchEvent(MotionEvent ev)       | 事件分发   | 用来进行事件的分发。如果事件能够传递给当前View，那么此方法一定会被调用，返回结果受当前View的onTouchEvent和下级View的DispatchTouchEvent方法的影响，表示是否消耗当前事件。 |
| onInterceptTouchEvent(MotionEvent event) | 事件拦截   | 在上述方法内部调用，用来判断是否拦截某个事件，如果当前View拦截了某个事件，那么在同一个事件序列当中，此方法不会被再次调用，返回结果表示是否拦截当前事件。 |
| onTouchEvent(MotionEvent event)          | 事件响应   | 在dispatchTouchEvent方法中调用，用来处理点击事件，返回结果表示是否消耗当前事件，如果不消耗，则在同一个事件序列中，当前View无法再次接收到事件 |

三者的关系可以总结为如下伪代码：

```java
public boolean dispatchTouchEvent(MotionEvent ev) {
    boolean consume = false;
    if (onInterceptTouchEvent(ev)) {
        consume = onTouchEvent(ev);
    } else {
        consume = child.dispatchTouchEvent(ev);
    }

    return consume;
}
```

一个事件序列只能被一个View拦截且消耗，不过通过事件代理`TouchDelegate`，可以将`onTouchEvent`强行传递给其他View处理。

**某个View一旦决定拦截，那么这一事件序列就都只能由它来处理**。

**某个View一旦开始处理事件，如果不消耗ACTION_DOWN事件（onTouchEvent返回了false），那么事件会重新交给它的父元素处理，即父元素的onTouchEvent会被调用**。

如果View不消耗除`ACTION_DOWN`以外的事件，那么这个点击事件会消失，此时父元素的`onTouchEvent`并不会调用，并且当前View可以持续收到后续的事件（Android系统通过一个标记来解决），最终这些消失的事件会传递到Activity。

`ViewGroup`默认不拦截任何事件。Android源码中`ViewGroup`的`onInterceptTouchEvent`方法默认返回false。

**View没有onIntercepteTouchEvent方法，一旦有点击事件传递给它，那么它的onTouchEvent方法就会被调用**。

View的`onTouchEvent`默认都不会消耗事件（返回false），除非它是可点击的（`clickable`和`longClickable`有一个为true）。View的`longClickable`默认都为false，clickable要分情况看，比如Button默认为true，TextView默认为false。

View的`enable`属性不影响`onTouchEvent`的默认返回值。哪怕一个View是`disable`状态，只要它的`clickable`或者`longClickable`有一个为true，那么它的`onTouchEvent`就返回true。

`onClick`会发生的前提是当前View是可点击的，并且它受到down和up的事件。

事件传递是由外向内的，即事件总是先传递给父元素，然后再由父元素分发给子View，**通过requestDisallowInterceptTouchEvent方法就可以在子元素中干扰父元素的事件分发过程**，但ACTION_DOWN事件除外。

## Binder

