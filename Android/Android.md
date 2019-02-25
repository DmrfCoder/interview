# Android

## Android的系统架构是怎么样的？

总的来说，Android的系统体系结构分为**四层**，自顶向下分别是：

- 应用程序(Applications)
- 应用程序框架(Application Frameworks)
- 系统运行库与Android运行环境(Libraris & Android Runtime)
- Linux内核(Linux Kernel)

*安卓系统结构示意图:*
![2](https://ws2.sinaimg.cn/large/006tKfTcly1g0dzkgl481j30i20czta7.jpg)

下面对每层进行详细说明

### 1. 应用程序(Applications)

Android会同一系列核心应用程序包一起发布，该应用程序包包括email客户端，SMS短消息程序，日历，地图，浏览器，联系人管理程序等。所有的应用程序都是使用JAVA语言编写的。通常开发人员就处在这一层。

### 2. 应用程序框架(Application Frameworks)

提供应用程序开发的各种API进行快速开发，也即隐藏在每个应用后面的是一系列的服务和系统，大部分使用Java编写，所谓官方源码很多也就是看这里，其中包括：

- 丰富而又可扩展的视图（Views），可以用来构建应用程序， 它包括列表（lists），网格（grids），文本框（text boxes），按钮（buttons）， 甚至可嵌入的web浏览器。
- 内容提供器（Content Providers）使得应用程序可以访问另一个应用程序的数据（如联系人数据库）， 或者共享它们自己的数据
- 资源管理器（Resource Manager）提供 非代码资源的访问，如本地字符串，图形，和布局文件（ layout files ）。
- 通知管理器 （Notification Manager） 使得应用程序可以在状态栏中显示自定义的提示信息。
- 活动管理器（ Activity Manager） 用来管理应用程序生命周期并提供常用的导航回退功能。

### 3. 系统运行库与Android运行环境(Libraris & Android Runtime)

#### 1) 系统运行库

Android 包含一些C/C++库，这些库能被Android系统中不同的组件使用。它们通过 Android 应用程序框架为开发者提供服务。以下是一些核心库：

- **Bionic系统 C 库** - 一个从 BSD 继承来的标准 C 系统函数库（ libc ）， 它是专门为基于 embedded linux 的设备定制的。
- **媒体库** - 基于 PacketVideo OpenCORE；该库支持多种常用的音频、视频格式回放和录制，同时支持静态图像文件。编码格式包括MPEG4, H.264, MP3, AAC, AMR, JPG, PNG 。
- **Surface Manager** - 对显示子系统的管理，并且为多个应用程序提 供了2D和3D图层的无缝融合。这部分代码
- **Webkit,LibWebCore** - 一个最新的web浏览器引擎用，支持Android浏览器和一个可嵌入的web视图。鼎鼎大名的 Apple Safari背后的引擎就是Webkit
- **SGL** - 底层的2D图形引擎
- **3D libraries** - 基于OpenGL ES 1.0 APIs实现；该库可以使用硬件 3D加速（如果可用）或者使用高度优化的3D软加速。
- **FreeType** -位图（bitmap）和矢量（vector）字体显示。
- **SQLite** - 一个对于所有应用程序可用，功能强劲的轻型关系型数据库引擎。
- 还有部分上面没有显示出来的就是硬件抽象层。其实Android并非讲所有的设备驱动都放在linux内核里面，而是实现在userspace空间，这么做的主要原因是GPL协议，Linux是遵循该 协议来发布的，也就意味着对 linux内核的任何修改，都必须发布其源代码。而现在这么做就可以避开而无需发布其源代码，毕竟它是用来赚钱的。 而 在linux内核中为这些userspace驱动代码开一个后门，就可以让本来userspace驱动不可以直接控制的硬件可以被访问。而只需要公布这个 后门代码即可。一般情况下如果要将Android移植到其他硬件去运行，只需要实现这部分代码即可。包括：显示器驱动，声音，相机，GPS,GSM等等

#### 2) Android运行环境

该核心库提供了JAVA编程语言核心库的大多数功能。
每一个Android应用程序都在它自己的进程中运 行，都拥有一个独立的Dalvik虚拟 机实例。Dalvik被设计成一个设备可以同时高效地运行多个虚拟系统。 Dalvik虚拟机执行（.dex）的Dalvik可执行文件，该格式文件针对小内存使用做了 优化。同时虚拟机是基于寄存器的，所有的类都经由JAVA编译器编译，然后通过SDK中 的 "dx" 工具转化成.dex格式由虚拟机执行。

### 4. Linux内核(Linux Kernel)

Android的核心系统服务依赖于Linux 2.6 内核，如安全性，内存管理，进程管理， 网络协议栈和驱动模型。 Linux 内核也同时作为硬件和软件栈之间的抽象层。其外还对其做了部分修改，主要涉及两部分修改：

1. Binder (IPC)：提供有效的进程间通信，虽然linux内核本身已经提供了这些功能，但Android系统很多服务都需要用到该功能，为了某种原因其实现了自己的一套。
2. 电源管理：主要是为了省电，毕竟是手持设备嘛，低耗电才是我们的追求。



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

提一个问题：假设ListView中有10W个条项，那内存中会缓存10W个吗？答案当然是否定的。那么是如何实现的呢？下面这张图可以清晰地解释其中的原理:z

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

ThreadLocal是一个线程内部的数据存储类，通过它可以在指定线程中存储数据，数据存储以后，只有在指定的线程中获取到存储数据，对于其他线程来说则无法获取到数据，即通过ThreadLocal，每个线程都能获取自己线程内部的私有变量。

示例代码：

![image-20190218141548694](https://ws2.sinaimg.cn/large/006tKfTcly1g0ajvkfefkj31300s2nh1.jpg)

运行结果截图： 

![image-20190218141617749](https://ws3.sinaimg.cn/large/006tKfTcly1g0ajvy3m5xj313003owl4.jpg)

可以看出不同线程访问的是同一个ThreadLocal，但是它们通过ThreadLocal获取的值却不一样。 
主线程设置的是true，所以获取到的是true 
第一个子线程设置的是false，所以获取到的是false 
第二个子线程没有设置，所以获取到的是null

![1](https://ws4.sinaimg.cn/large/006tKfTcly1g0dwfti2lyj31dk0towgy.jpg)

在上图中我们可以发现，整个ThreadLocal的使用都涉及到线程中ThreadLocalMap,虽然我们在外部调用的是ThreadLocal.set(value)方法，但本质是通过线程中的ThreadLocalMap中的set(key,value)方法，其中key为当前ThreadLocal对象，value为当前赋的值，那么通过该情况我们大致也能猜出get方法也是通过ThreadLocalMap。那么接下来我们一起来看看ThreadLocal中set与get方法的具体实现与ThreadLocalMap的具体结构。

- ThreadLocal本质是操作线程中ThreadLocalMap来实现本地线程变量的存储的
- ThreadLocalMap是采用数组的方式来存储数据，其中key(弱引用)指向当前ThreadLocal对象，value为设的值
- ThreadLocal为内存泄漏采取了处理措施，在调用ThreadLocal的get(),set(),remove()方法的时候都会清除线程ThreadLocalMap里所有key为null的Entry
- 在使用ThreadLocal的时候，我们仍然需要注意，避免使用static的ThreadLocal，分配使用了ThreadLocal后，一定要根据当前线程的生命周期来判断是否需要手动的去清理ThreadLocalMap中清key==null的Entry。



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

    public View(Context context, @RecentlyNullable cy attrs) {
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

### binder是什么

Binder承担了绝大部分Android进程通信的职责，可以看做是Android的血管系统，负责不同服务模块进程间的通信。

Binder往小了说可总结成一句话：

**一种IPC进程间通信方式，负责进程A的数据，发送到进程B。**

![1](https://ws2.sinaimg.cn/large/006tKfTcly1g0bm56baz1j30yg0i2n0j.jpg)

### 关于Linux的进程通信

一个进程空间分为 用户空间 & 内核空间（`Kernel`），即把进程内 用户 & 内核 隔离开来

二者区别： 

1. 进程间，用户空间的数据不可共享，所以用户空间 = 不可共享空间
2. 进程间，内核空间的数据可共享，所以内核空间 = 可共享空间 

所有进程共用1个内核空间

进程内 用户空间 & 内核空间 进行交互 需通过 **系统调用**，主要通过函数：

1. copy_from_user（）：将用户空间的数据拷贝到内核空间
2. copy_to_user（）：将内核空间的数据拷贝到用户空间

示意图如下：

![2](https://ws2.sinaimg.cn/large/006tKfTcly1g0bm7dnms3j30iu09ojrl.jpg)

为了保证 安全性 & 独立性，一个进程 不能直接操作或者访问另一个进程，即`Android`的进程是**相互独立、隔离的**

进程间进行数据交互、通信称为跨进程通信（IPC）

传统跨进程通信的原理是：

- 发送进程通过copy_from_user（）将数据拷贝到Linux进程内核空间的缓冲区中（数据拷贝一次）
- 内核服务程序唤醒接收进程的接收线程，通过copy_to_user（）将数据发送到接收进程的用户空间中最终完成数据通信（数据拷贝一次）

所以传统的跨进程通信的原理需要拷贝两次数据，这样效率就很低。

还有一个比较大的缺点是接收数据的缓存要由接收方提供，但是接收方提前不知道所要接收数据的大小，不知道开辟多大的缓存才满足需求，这时主要有两种做法：

- 尽量开辟尽可能大的空间
- 先调用API接收消息头获取消息体大小，再适当开辟空间

第一种方法浪费空间，第二种方法浪费时间，所以传统跨进程通信缺点太多。

 而`Binder`的作用则是：连接 两个进程，实现了mmap()系统调用，主要负责 **创建数据接收的缓存空间** & **管理数据接收缓存** 
注：传统的跨进程通信需拷贝数据2次，但`Binder`机制只需1次，主要是使用到了内存映射，具体下面会详细说明。

### binder跨进程通信机制（模型）

`Binder` 跨进程通信机制 模型 基于 `Client - Server` 模式 ：

![3](https://ws3.sinaimg.cn/large/006tKfTcly1g0bmv3otykj30tq0csjro.jpg)

![4](https://ws2.sinaimg.cn/large/006tKfTcly1g0bmvkfldvj30me0ak3yt.jpg)

#### binder驱动

![5](https://ws3.sinaimg.cn/large/006tKfTcly1g0bmx7rhq1j30yg0ftwh9.jpg)

跨进程通信原理图：

![6](https://ws1.sinaimg.cn/large/006tKfTcly1g0bmxshed4j30qo0lh0vy.jpg)

![7](https://ws3.sinaimg.cn/large/006tKfTcly1g0bmzuzi45j30u00ws10t.jpg)

空间原理图：

![8](https://ws4.sinaimg.cn/large/006tKfTcly1g0bn1am09dj30tq0fagm3.jpg)

`Binder`驱动 & `Service Manager`进程 属于 `Android`基础架构（即系统已经实现好了）；而`Client` 进程 和 `Server` 进程 属于`Android`应用层（需要开发者自己实现），所以，在进行跨进程通信时，开发者只需自定义`Client` & `Server` 进程 并 显式使用上述3个步骤，最终借助 `Android`的基本架构功能就可完成进程间通信：

![9](https://ws2.sinaimg.cn/large/006tKfTcly1g0bn1upmbdj30tq0jht9n.jpg)

## 性能优化

### ANR

ANR全称`Application Not Responding`，意思就是程序未响应。

#### 出现场景

- 主线程被IO操作（从4.0之后网络IO不允许在主线程中）阻塞。
- 主线程中存在耗时的计算
- 主线程中错误的操作，比如Thread.wait或者Thread.sleep等

Android系统会监控程序的响应状况，一旦出现下面两种情况，则弹出ANR对话框

- 应用在5秒内未响应用户的输入事件（如按键或者触摸）
- wBroadcastReceiver未在10秒内完成相关的处理

#### 如何避免

基本的思路就是将IO操作在工作线程来处理，减少其他耗时操作和错误操作

- 使用AsyncTask处理耗时IO操作。
- 使用Thread或者HandlerThread时，调用`Process.setThreadPriority(Process.THREAD_PRIORITY_BACKGROUND)`设置优先级，否则仍然会降低程序响应，因为默认Thread的优先级和主线程相同。
- ji使用Handler处理工作线程结果，而不是使用Thread.wait()或者Thread.sleep()来阻塞主线程。
- `Activity`的`onCreate`和`onResume`回调中尽量避免耗时的代码
- `BroadcastReceiver`中`onReceive`代码也要尽量减少耗时，建议使用`IntentService`处理。

#### 如何改善

通常100到200毫秒就会让人察觉程序反应慢，为了更加提升响应，可以使用下面的几种方法

- 如果程序正在后台处理用户的输入，建议使用让用户得知进度，比如使用ProgressBar控件。
- 程序启动时可以选择加上欢迎界面，避免让用户察觉卡顿。
- 使用`Systrace`和`TraceView`找出影响响应的问题。

如果开发机器上出现问题，我们可以通过查看`/data/anr/traces.txt`即可，最新的ANR信息在最开始部分。

### OOM（Out Of Memory）

在实践操作当中，可以从四个方面着手减小内存使用：

- 减小对象的内存占用
- 内存对象的重复利用
- 避免对象的内存泄露
- 内存使用策略优化。

#### 减小对象的内存占用

- `使用更加轻量级的数据结构`：例如，我们可以考虑使用`ArrayMap`/`SparseArray`而不是`HashMap`等传统数据结构，相比起Android系统专门为移动操作系统编写的`ArrayMap`容器，在大多数情况下，`HashMap`都显示效率低下，更占内存。另外，`SparseArray`更加高效在于，**避免了对key与value的自动装箱，并且避免了装箱后的解箱**。

- `避免使用Enum`：在Android中应该尽量使用`int`来代替`Enum`，因为使用`Enum`会导致编译后的dex文件大小增大，并且使用`Enum`时，其运行时还会产生额外的内存占用。

- `减小`Bitmap`对象的内存占用`：

  - `inBitmap`：如果设置了这个字段，Bitmap在加载数据时可以复用这个字段所指向的bitmap的内存空间。**但是，内存能够复用也是有条件的。比如，在Android 4.4(API level 19)之前，只有新旧两个Bitmap的尺寸一样才能复用内存空间。Android 4.4开始只要旧 Bitmap 的尺寸大于等于新的 Bitmap 就可以复用了**。
  - `inSampleSize`：缩放比例，在把图片载入内存之前，我们需要先计算出一个合适的缩放比例，避免不必要的大图载入。
  - `decode format`：解码格式，选择`ARGB_8888` `RBG_565` `ARGB_4444` `ALPHA_8`，存在很大差异。

  > ARGB_4444：每个像素占四位，即A=4，R=4，G=4，B=4，那么一个像素点占4+4+4+4=16位 ARGB_8888：每个像素占四位，即A=8，R=8，G=8，B=8，那么一个像素点占8+8+8+8=32位 RGB_565：每个像素占四位，即R=5，G=6，B=5，没有透明度，那么一个像素点占5+6+5=16位 ALPHA_8：每个像素占四位，只有透明度，没有颜色。

- `使用更小的图片`：在设计给到资源图片的时候，我们需要特别留意这张图片是否存在可以压缩的空间，是否可以使用一张更小的图片。**尽量使用更小的图片不仅仅可以减少内存的使用，还可以避免出现大量的InflationException**。假设有一张很大的图片被XML文件直接引用，很有可能在初始化视图的时候就会因为内存不足而发生InflationException，这个问题的根本原因其实是发生了OOM。

#### 内存对象的重复使用

大多数对象的复用，最终实施的方案都是利用对象池技术，要么是在编写代码的时候显式的在程序里面去创建对象池，然后处理好复用的实现逻辑，要么就是利用系统框架既有的某些复用特性达到减少对象的重复创建，从而减少内存的分配与回收。

- `复用系统自带资源`：Android系统本身内置了很多的资源，例如字符串/颜色/图片/动画/样式以及简单布局等等，这些资源都可以在应用程序中直接引用。**这样做不仅仅可以减少应用程序的自身负重，减小APK的大小，另外还可以一定程度上减少内存的开销，复用性更好**。但是也有必要留意Android系统的版本差异性，对那些不同系统版本上表现存在很大差异，不符合需求的情况，还是需要应用程序自身内置进去。
- `ListView ViewHodler`
- `Bitmap对象的复用`：在ListView与GridView等显示大量图片的控件里面需要使用LRU的机制来缓存处理好的Bitmap。
- `inBitmap`：**使用inBitmap属性可以告知Bitmap解码器去尝试使用已经存在的内存区域**，新解码的bitmap会尝试去使用之前那张bitmap在heap中所占据的`pixel data`内存区域，而不是去问内存重新申请一块区域来存放bitmap。

> - 使用inBitmap，在4.4之前，只能重用相同大小的bitmap的内存区域，而4.4之后你可以重用任何bitmap的内存区域，只要这块内存比将要分配内存的bitmap大就可以。这里最好的方法就是使用LRUCache来缓存bitmap，后面来了新的bitmap，可以从cache中按照api版本找到最适合重用的bitmap，来重用它的内存区域。
> - 新申请的bitmap与旧的bitmap必须有相同的解码格式

- 避免在onDraw方法里面执行对象的创建：类似onDraw等频繁调用的方法，一定需要注意避免在这里做创建对象的操作，因为他会迅速增加内存的使用，而且很容易引起频繁的gc，甚至是内存抖动。
- `StringBuilder`：在有些时候，代码中会需要使用到大量的字符串拼接的操作，这种时候有必要考虑使用StringBuilder来替代频繁的“+”。

#### 避免内存泄漏

- `内部类引用导致Activity的泄漏`：最典型的场景是Handler导致的Activity泄漏，如果Handler中有延迟的任务或者是等待执行的任务队列过长，都有可能因为Handler继续执行而导致Activity发生泄漏。
- `Activity Context被传递到其他实例中，这可能导致自身被引用而发生泄漏`。
- 考虑使用Application Context而不是Activity Context
- 注意临时Bitmap对象的及时回收
- 注意监听器的注销
- 注意缓存容器中的对象泄漏：不使用的对象要将引用置空。
- 注意Cursor对象是否及时关闭

#### 内存优化策略

- 综合考虑设备内存阈值与其他因素设计合适的缓存大小
- `onLowMemory()`：Android系统提供了一些回调来通知当前应用的内存使用情况，通常来说，当所有的background应用都被kill掉的时候，forground应用会收到onLowMemory()的回调。在这种情况下，需要尽快释放当前应用的非必须的内存资源，从而确保系统能够继续稳定运行。
- `onTrimMemory()`：Android系统从4.0开始还提供了onTrimMemory()的回调，当系统内存达到某些条件的时候，所有正在运行的应用都会收到这个回调，同时在这个回调里面会传递以下的参数，代表不同的内存使用情况，收到onTrimMemory()回调的时候，需要根据传递的参数类型进行判断，合理的选择释放自身的一些内存占用，一方面可以提高系统的整体运行流畅度，另外也可以避免自己被系统判断为优先需要杀掉的应用
- 资源文件需要选择合适的文件夹进行存放：例如我们只在`hdpi`的目录下放置了一张100100的图片，那么根据换算关系，`xxhdpi`的手机去引用那张图片就会被拉伸到200200。需要注意到在这种情况下，内存占用是会显著提高的。**对于不希望被拉伸的图片，需要放到assets或者nodpi的目录下**。
- 谨慎使用static对象
- 优化布局层次，减少内存消耗
- 使用FlatBuffer等工具序列化数据
- 谨慎使用依赖注入框架
- 使用ProGuard来剔除不需要的代码

#### Bitmap与OOM

图片是一个很耗内存的资源，因此经常会遇到OOM。比如从本地文件中读取图片，然后在GridView中显示出来，如果不做处理，OOM就极有可能发生。

##### Bitmap引起OOM的原因

1. 图片使用完成后，没有及时的释放，导致Bitmap占用的内存越来越大，而安卓提供给Bitmap的内存是有一定限制的，当超出该内存时，自然就发生了OOM
2. 图片过大

这里的图片过大是指加载到内存时所占用的内存，并不是图片自身的大小。而图片加载到内存中时所占用的内存是根据图片的分辨率以及它的配置（ARGB值）计算的。举个例子：

假如有一张分辨率为2048x1536的图片，它的配置为ARGB_8888，那么它加载到内存时的大小就是2048x1526x4/1024/1024=12M.，因此当将这张图片设置到ImageView上时，将可能出现OOM。

ARGB表示图片的配置，分表代表：透明度、红色、绿色和蓝色。这几个参数的值越高代表图像的质量越好，那么也就越占内存。就拿ARGB_8888来说，A、R、G、B这几个参数分别占8位，那么总共占32位，代表一个像素点占32位大小即4个字节，那么一个100x100分辨率的图片就占了100x100x4/1024/1024=0.04M的大小的空间。

##### 高效加载Bitmap

当将一个图片加载到内存，在UI上呈现时，需要考虑一下几个因素:

1. 预计加载完整张图片所需要的内存空间
2. 呈现这张图片时控件的大小
3. 屏幕大小与屏幕像素密度

如果我们要加载的图片的分辨率比较大，而呈现它的控件（比如ImageView）比较小，那我们如果直接将这张图片加载到这个控件上显然是不合适的，因此我们需要对图片的分辨率就行压缩。如何去进行图片的压缩呢？

BitmapFactory提供了四种解码（decode）的方法（decodeByteArray(), decodeFile(), decodeResource()，decodeStream()),每一种方法都可以通过BitmapFactory.Options设置一些附加的标记，以此来指定解码选项。

Options有一个inJustDecodeBunds属性，当我们将其设置为true时，表示此时并不加载Bitmap到内存中，而是返回一个null，但是此时我们可以通过options获取到当前bitmap的宽和高，根据这个宽和高，我们再根据目标宽和高计算出一个合适的采样率采样率inSampleSize ，然后将其赋值给Options.inSampleSize属性，这样在加载图片的时候，将会得到一个压缩的图片到内存中。以下是示例代码:

```java
public static Bitmap decodeSampledBitmapFromResource(Resources res, int resId,
   int reqWidth, int reqHeight) {

// 第一次加载时 将inJustDecodeBounds设置为true 表示不真正加载图片到内存 
final BitmapFactory.Options options = new BitmapFactory.Options();
options.inJustDecodeBounds = true;
BitmapFactory.decodeResource(res, resId, options);

// 根据目标宽和高 以及当前图片的大小 计算出压缩比率 
options.inSampleSize = calculateInSampleSize(options, reqWidth, reqHeight);

// 将inJustDecodeBounds设置为false 真正加载图片 然后根据压缩比率压缩图片 再去解码
options.inJustDecodeBounds = false;
return BitmapFactory.decodeResource(res, resId, options);
}

//计算压缩比率 android官方提供的算法
public static int calculateInSampleSize(
       BitmapFactory.Options options, int reqWidth, int reqHeight) {
// Raw height and width of image
final int height = options.outHeight;
final int width = options.outWidth;
int inSampleSize = 1;

if (height > reqHeight || width > reqWidth) {
   //将当前宽和高 分别减小一半
   final int halfHeight = height / 2;
   final int halfWidth = width / 2;

   // Calculate the largest inSampleSize value that is a power of 2 and keeps both
   // height and width larger than the requested height and width.
   while ((halfHeight / inSampleSize) > reqHeight
           && (halfWidth / inSampleSize) > reqWidth) {
       inSampleSize *= 2;
   }
}

return inSampleSize;
}
```

采样率与图片分辨率压缩大小的关系是这样的：

1. 如果inSample=1则表明与原图一样
2. 如果inSample=2则表示宽和高均缩小为1/2
3. nSample的值一般为2的幂次方

假如 一个分辨率为2048x1536的图片，如果设置 inSampleSize 为4，那么会产出一个大约512x384大小的Bitmap。加载这张缩小的图片仅仅使用大概0.75MB的内存，如果是加载完整尺寸的图片，那么大概需要花费12MB（前提都是Bitmap的配置是 ARGB_8888.

##### 缓存Bitmap

当需要加载大量的图片时，图片的缓存机制就特别重要。因为在移动端，用户大多都是使用的移动流量，如果每次都从网络获取图片，一是会耗费大量的流量，二是在网络不佳的时候加载会非常的慢，用户体验均不好。因此需要定义一种缓存策略可以应对上述问题。关于图片的缓存通常有两种：

1. 内存缓存，对应的缓存算法是LruCache<k,v>（近期最少使用算法）,Android提供了该算法。

LruCache是一个泛型类，它的内部采用一个LinkedHashMap以强引用的方式存储外界的缓存对象，其提供了get和put方法来完成缓存的获取和添加操作，当缓存满时，LruCache会移除较早使用的缓存对象，然后再添加新的缓存对象。

补充：之所以使用LinkedHashMap来实现LruCache是因为LinkedHashMap内部采用了双向链表的方式，它可以以访问顺序进行元素的排序。比如通过get方法获取了一个元素，那么就将这个元素放到链表的尾部，通过不断的get操作就得到了一个访问顺序的链表，这样位于链表头部的就是较早的元素。因此非常适合于LruCache算法的思想，在缓存满时，将链表头部的对象移除即可。LruCache经典使用方式:

```java
//app最大可用内存
   int maxMemory = (int) (Runtime.getRuntime().maxMemory()/1024);
   //缓存大小
   int cacheSize = maxMemory/8;
   mMemoryCache = new LruCache<String,Bitmap>(cacheSize) {
       //计算缓存对象的大小
       @Override
       protected int sizeOf(String key, Bitmap value) {
           return value.getRowBytes()*value.getHeight()/1024;
       }
   };
   
   //获取缓存对象
   mMemoryCache.get(key);
   //添加缓存对象
   mMemoryCache.put(key,bitmap);
```

2. 磁盘缓存，对应的缓存算法是DiskLruCache,虽然不是官方提供的，但得到官方的认可。

##### 使用Bitmap时的一些优化方法

1. 对图片采用软引用,调用recycle，及时的回收Bitmap所占用的内存。比如：View如果使用了bitmap,就应该在这个View不再绘制了的时候回收；如果Activity使用了bitmap,就可以在onStop或者onDestroy方法中回收。
2. 对高分辨率图片进行压缩,详情参见高效加载Bitmap部分
3. 关于ListView和GridView加载大量图片时的优化 :

- 不要在getView方法中执行耗时操作，比如加载Bitmap，应将加载动作放到一个异步任务中，比如AsyncTask
- 在快速滑动列表的时候，停止加载Bitmap，当用户停止滑动时再去加载。因为当用户快速上下滑动时，如果去加载Bitmap的话可能会产生大量的异步任务，会造成线程池的拥堵以及大量的更新UI操作，因此会造成卡顿。
- 对当前的Activity开启硬件加速。
- 为防止因异步下载图片而造成错位问题，对ImageView设置Tag，将图片的Url作为tag的标记，当设置图片时，去判断当前ImageView的tag是否等于当前的图片的url，如果相当则显示否则的话不予加载。



在追求效率的情况下大家一般用Glide框架比较多，Glide不仅可以加载显示图片还可以加载显示视频，但是只能够显示手机本地的视频，如果需要显示网络上的视频的话需要另寻他法。



### 卡顿优化

导致Android界面滑动卡顿主要有两个原因：

- UI线程（main）有耗时操作
- 视图渲染时间过长，导致卡顿

众所周知，界面的流畅度主要依赖`FPS`这个值，这个值是通过（1s/渲染1帧所花费的时间）计算所得，FPS值越大视频越流畅，所以就需要渲染1帧的时间能尽量缩短。**正常流畅度的FPS值在60左右，即渲染一帧的时间不应大于16 ms**。

如果想让应用流畅运行 ：

- 不要阻塞UI线程；
- 不要在UI线程之外操作UI；
- 减少UI嵌套层级

**针对界面切换卡顿，一般出现在组件初始化的地方。屏幕滑动卡顿，ui嵌套层级，还有图片加载，图片的话，滑动不加载，监听scrollListener**。

## 推送机制

### 轮询

客户端隔一段时间就去服务器上获取一下信息，看是否有更新的信息出现，这就是轮询。我们可以通过`AlarmManager`来管理时间，当然时间的设置策略也是十分重要的，由于每次轮询都需要建立和释放TCP连接，所以在移动网络情况下耗电量相当大。

针对不同应用的需求，有的可以每5分钟查询一次或者每10分钟查询一次，但是这种策略的电量和流量消耗十分严重。我们可以使用退避法（暂时这么说），比如第一次我们每隔2分钟查询一次数据，如果没有数据，就将查询间隔加倍。

同时进程的保活也十分重要，这部分的知识参照进程保活。

### 长连接

客户端主动和服务器建立TCP长连接之后，客户端定期向服务器发送心跳包，有消息的时候，服务器直接通过这个已经建立好的TCP连接通知客户端。

长连接就是 **建立连接之后，不主动断开。双方互相发送数据，发完了也不主动断开连接，之后有需要发送的数据就继续通过这个连接发送**。

### 影响TCP连接寿命的因素

#### NAT超时

因为 IPv4 的 IP 量有限，运营商分配给手机终端的 IP 是运营商内网的 IP，手机要连接 Internet，就需要通过运营商的网关做一个网络地址转换（Network Address Translation，NAT）。简单的说运营商的网关需要维护一个外网 IP、端口到内网 IP、端口的对应关系，以确保内网的手机可以跟 Internet 的服务器通讯。

大部分移动无线网络运营商都在链路一段时间没有数据通讯时，会淘汰 NAT 表中的对应项，造成链路中断。

#### DHCP租期

目前测试发现安卓系统对DHCP的处理有Bug，DHCP租期到了不会主动续约并且会继续使用过期IP，这个问题会造成TCP长连接偶然的断连。

#### 网络状态变化

手机网络和WIFI网络切换、网络断开和连上等情况有网络状态的变化，也会使长连接变为无效连接，需要监听响应的网络状态变化事件，重新建立Push长连接。

#### 心跳包

TCP长连接本质上不需要心跳包来维持，其主要是为了防止上面提到的NAT超时，既然一些`NAT设备`判断是否淘汰`NAT映射`的依据是一定时间没有数据，那么客户端就主动发一个数据，这样就能维持TCP长连接。

当然，如果仅仅是为了防止NAT超时，可以让服务器来发送心跳包给客户端，不过这样做有个弊病就是，万一连接断了，服务器就再也联系不上客户端了。所以心跳包必须由客户端发送，客户端发现连接断了，还可以尝试重连服务器。

#### 时间间隔

发送心跳包势必要先唤醒设备，然后才能发送，如果唤醒设备过于频繁，或者直接导致设备无法休眠，会大量消耗电量，而且移动网络下进行网络通信，比在wifi下耗电得多。所以这个心跳包的时间间隔应该尽量的长，最理想的情况就是根本没有NAT超时，比如刚才我说的两台在同一个wifi下的电脑，完全不需要心跳包。这也就是网上常说的长连接，慢心跳。

现实是残酷的，根据网上的一些说法，中移动2/3G下，NAT超时时间为5分钟，中国电信3G则大于28分钟，理想的情况下，客户端应当以略小于NAT超时时间的间隔来发送心跳包。

#### 心跳包和轮询的区别

- 轮询是为了获取数据，而心跳是为了保活TCP连接。
- 轮询得越频繁，获取数据就越及时，心跳的频繁与否和数据是否及时没有直接关系。
- 轮询比心跳能耗更高，因为一次轮询需要经过TCP三次握手，四次挥手，单次心跳不需要建立和拆除TCP连接。

## 进程保活

### 进程生命周期

Android 系统将尽量长时间地保持应用进程，但为了新建进程或运行更重要的进程，最终需要清除旧进程来回收内存。 为了确定保留或终止哪些进程，系统会根据进程中正在运行的组件以及这些组件的状态，将每个进程放入“重要性层次结构”中。 必要时，系统会首先消除重要性最低的进程，然后是重要性略逊的进程，依此类推，以回收系统资源。

重要性层次结构一共有 5 级。以下列表按照重要程度列出了各类进程（第一个进程最重要，将是最后一个被终止的进程）：

- 前台进程：用户当前操作所必需的进程。如果一个进程满足以下任一条件，即视为前台进程：

```
- 托管用户正在交互的 Activity（已调用 Activity 的 `onResume()` 方法）

- 托管某个 Service，后者绑定到用户正在交互的 Activity

- 托管正在“前台”运行的 Service（服务已调用 `startForeground()`）

- 托管正执行一个生命周期回调的 Service（`onCreate()`、`onStart()` 或 `onDestroy()`）

- 托管正执行其 `onReceive()` 方法的 BroadcastReceiver
```

通常，在任意给定时间前台进程都为数不多。只有在内在不足以支持它们同时继续运行这一万不得已的情况下，系统才会终止它们。 此时，设备往往已达到内存分页状态，因此需要终止一些前台进程来确保用户界面正常响应。- 

- 可见进程：没有任何前台组件、但仍会影响用户在屏幕上所见内容的进程。 如果一个进程满足以下任一条件，即视为可见进程：

```
- 托管不在前台、但仍对用户可见的 Activity（已调用其 `onPause()` 方法）。例如，如果前台 Activity 启动了一个对话框，允许在其后显示上一 Activity，则有可能会发生这种情况

- 托管绑定到可见（或前台）Activity 的 Service
```

可见进程被视为是极其重要的进程，除非为了维持所有前台进程同时运行而必须终止，否则系统不会终止这些进程。

- 服务进程：正在运行已使用 `startService()` 方法启动的服务且不属于上述两个更高类别进程的进程。尽管服务进程与用户所见内容没有直接关联，但是它们通常在执行一些用户关心的操作（例如，在后台播放音乐或从网络下载数据）。因此，除非内存不足以维持所有前台进程和可见进程同时运行，否则系统会让服务进程保持运行状态。

- 后台进程：包含目前对用户不可见的 Activity 的进程（已调用 Activity 的 `onStop()` 方法）。这些进程对用户体验没有直接影响，系统可能随时终止它们，以回收内存供前台进程、可见进程或服务进程使用。 通常会有很多后台进程在运行，因此它们会保存在 LRU （最近最少使用）列表中，以确保包含用户最近查看的 Activity 的进程最后一个被终止。如果某个 Activity 正确实现了生命周期方法，并保存了其当前状态，则终止其进程不会对用户体验产生明显影响，因为当用户导航回该 Activity 时，Activity 会恢复其所有可见状态。

- 空进程：不含任何活动应用组件的进程。保留这种进程的的唯一目的是用作缓存，以缩短下次在其中运行组件所需的启动时间。 为使总体系统资源在进程缓存和底层内核缓存之间保持平衡，系统往往会终止这些进程。

**根据进程中当前活动组件的重要程度，Android 会将进程评定为它可能达到的最高级别**。例如，如果某进程托管着服务和可见 Activity，则会将此进程评定为可见进程，而不是服务进程。

此外，一个进程的级别可能会因其他进程对它的依赖而有所提高，即 **服务于另一进程的进程其级别永远不会低于其所服务的进程**。 例如，如果进程 A 中的内容提供程序为进程 B 中的客户端提供服务，或者如果进程 A 中的服务绑定到进程 B 中的组件，则进程 A 始终被视为至少与进程 B 同样重要。

由于运行服务的进程其级别高于托管后台 Activity 的进程，因此 **启动长时间运行操作的 Activity 最好为该操作启动服务，而不是简单地创建工作线程，当操作有可能比 Activity 更加持久时尤要如此**。例如，正在将图片上传到网站的 Activity 应该启动服务来执行上传，这样一来，即使用户退出 Activity，仍可在后台继续执行上传操作。使用服务可以保证，无论 Activity 发生什么情况，该操作至少具备“服务进程”优先级。 同理，广播接收器也应使用服务，而不是简单地将耗时冗长的操作放入线程中。

### 保活的基本概念

当前Android进程保活手段主要分为 黑、白、灰 三种，其大致的实现思路如下：

- **黑色保活**：不同的app进程，用广播相互唤醒（包括利用系统提供的广播进行唤醒）
- **白色保活**：启动前台Service
- **灰色保活**：利用系统的漏洞启动前台Service

> 还有一种就是控制Service.onStartCommand的返回值，使用 `START_STICKY`可以在一定程度上保活。

#### 黑色保活

所谓黑色保活，就是利用不同的app进程使用广播来进行相互唤醒。举个3个比较常见的场景：

- **场景1**：开机，网络切换、拍照、拍视频时候，利用系统产生的广播唤醒app。
- **场景2**：接入第三方SDK也会唤醒相应的app进程，如微信sdk会唤醒微信，支付宝sdk会唤醒支付宝。由此发散开去，就会直接触发了下面的场景3。
- **场景3**：假如你手机里装了支付宝、淘宝、天猫、UC等阿里系的app，那么你打开任意一个阿里系的app后，有可能就顺便把其他阿里系的app给唤醒了。

#### 白色保活

白色保活手段非常简单，就是调用系统api启动一个前台的Service进程，这样会在系统的通知栏生成一个Notification，用来让用户知道有这样一个app在运行着，哪怕当前的app退到了后台。如网易云音乐。

#### 灰色保活

它是利用系统的漏洞来启动一个前台的Service进程，与普通的启动方式区别在于，它不会在系统通知栏处出现一个Notification，看起来就如同运行着一个后台Service进程一样。这样做带来的好处就是，用户无法察觉到你运行着一个前台进程（因为看不到Notification）,但你的进程优先级又是高于普通后台进程的。

- `API < 18`，启动前台Service时直接传入new Notification()；
- `API >= 18`，同时启动两个id相同的前台Service，然后再将后启动的Service做stop处理；

```java
public class GrayService extends Service {

    private final static int GRAY_SERVICE_ID = 1001;

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        if (Build.VERSION.SDK_INT < 18) {
            startForeground(GRAY_SERVICE_ID, new Notification());//API < 18 ，此方法能有效隐藏Notification上的图标
        } else {
            Intent innerIntent = new Intent(this, GrayInnerService.class);
            startService(innerIntent);
            startForeground(GRAY_SERVICE_ID, new Notification());
        }

        return super.onStartCommand(intent, flags, startId);
    }

    ...
    ...

    /**
     * 给 API >= 18 的平台上用的灰色保活手段
     */
    public static class GrayInnerService extends Service {

        @Override
        public int onStartCommand(Intent intent, int flags, int startId) {
            startForeground(GRAY_SERVICE_ID, new Notification());
            stopForeground(true);
            stopSelf();
            return super.onStartCommand(intent, flags, startId);
        }

    }
}
```



## Activity、View及Window之间关系

### View

View（包括ViewGroup）使用的是组合模式，将View组成成树形结构，以表示“部分-整体”的层次结构，使得用户对单个对象和组合对象的使用具有一致性。View主要是用于绘制我们想要的结果，是一个最基本的UI组件。

### Window

简单地说，`Window`表示一个窗口，一般来说，`Window`大小取值为屏幕大小。但是这不是绝对的，如对话框、Toast等就不是整个屏幕大小。你可以指定`Window`的大小。`Window`包含一个`View tree`和窗口的`layout`参数。

感觉Window的理解比较抽象，Window相当于一个容器，里面“盛放”着很多View，这些View是以树状结构组织起来的。

> 如果还是无法理解的话，就把Window当成是显示器，显示器有大有小（对应Window有大有小），View是显示器里面具体显示的内容。

#### Window对象存在的必要性

`Window`能做的事情，`View`对象基本都能做：像什么触摸事件啊、显示的坐标及大小啊、管理各个子View啊等等。View已经这么强大了，为什么还多此一举，加个`Window`对象。可能有人会说因为`WindowManager`管理的就是`Window`对象呀，那我想问，既然这样，Android系统直接让`WindowManager`去管理`View`不就好了？让View接替`Window`的工作，把`Window`所做的事情都封装到`View`里面不好嘛？。或许又有人说，`View`负责绘制显示内容，`Window`负责管理`View`，各自的工作职责不同。可是我想说，`Window`所做的大部分工作，`View`里面都有同样（或类似）的处理。

关于`Window`存在的必要，我查了国内外各种资料，最后有了我个人的理解。在后面小节里面，我会结合我个人的理解来解释。在解释之前，我们需要了解Window绘制过程。

#### Window绘制过程

在理解`Window`绘制过程之前，首先，我们需要知道`Surface`，在`Window`中持有一个`Surface`，那么什么是`Surface`呢？

`Surface`其实就是一个持有像素点矩阵的对象，这个像素点矩阵是组成显示在屏幕的图像的一部分。**我们看到显示的每个Window（包括对话框、全屏的Activity、状态栏等）都有他自己绘制的Surface**。而最终的显示可能存在`Window`之间遮挡的问题，此时就是通过`Surface Flinger对`象渲染最终的显示，使他们以正确的`Z-order`显示出来。一般`Surface`拥有一个或多个缓存（一般2个），通过双缓存来刷新，这样就可以一边绘制一边加新缓存。

`WindowManager`为每个`Window`创建`Surface`对象，然后应用就可以通过这个`Surface`来绘制任何它想要绘制的东西。而对于`WindowManager`来说，这只不过是一块矩形区域而已。

前面我们说过，`View`是`Window`里面用于交互的UI元素。`Window`只attach一个`View Tree`，当`Window`需要重绘（如，当View调用`invalidate`）时，最终转为`Window`的`Surface`，`Surface`被锁住（locked）并返回Canvas对象，此时View拿到Canvas对象来绘制自己。当所有View绘制完成后，`Surface`解锁（unlock），并且post到绘制缓存用于绘制，通过`Surface Flinger`来组织各个Window，显示最终的整个屏幕。

#### 总结

现在我们知道了`Window`绘制过程，其实，站在系统的角度来考虑，一个Window对象代表一块显示区域，系统不关心Window里面具体的绘制内容，也不管你`Window`怎么去绘制，反正只给你提供可以在这块区域上绘制图形的`Surface`对象，你`Window`对象怎么画是你的事情！

换句话说，站在系统的角度上看，系统是“不知道”有View对象这个说法的！作为系统，我有自己的骄傲，不去管你Window如何搬砖、如何砌墙，只给你地皮。而这时，Window为了绘制出用户想要的组件（按钮、文字、输入框等等），系统又不给我！没事，那我自己定义，于是就定义了View机制，给每个View提供Canvas，让不同的View自己绘制具有自己特色的组件。同时，为了更好的管理View，通过定义ViewGroup，等等。

### Activity

对于开发人员来说，一个`Activity`就“相当于”一个界面（通过`setContentView`指定具体的View）。我们可以直接在Activity里处理事件，如`onKeyEvent`,`onTouchEvent`等。 并可以通过Activity维护应用程序的生命周期。

### Activity和Window

前面我们知道，`Window`已经是系统管理的窗口界面。那么为什么还需要`Activity`呢？我们把`Activity`所做的事情，全部封装到`Window`不就好了？

其实，本质上讲，我们要显示一个窗口出来，的确可以不需要Activity。悬浮窗口中不就是没有使用Activity来显示一个悬浮窗吗？既然如此，Window（以及View）能处理点击事件以及封装各种逻辑，那为啥还需要Activity呢？

`Android`中的应用中，里面对各个窗口的管理相当复杂（任务栈、状态等等），Android系统当然可以不用Activity，让用户自己直接操作Window来开发自己的应用。但是如果让用户自己去管理这些Window，先不说工作量，光让用户自己去实现任务栈这点，有几个人能写的出来。**为了让大家能简单、快速的开发应用，Android通过定义Activity，让Activity帮我们管理好，我们只需简单的去重写几个回调函数，无需直接与Window对象接触**。各种事件也只需重写Activity里面的回调即可。无需关注其他细节，默认都帮我们写好了，针对需要定制的部分我们重写（设计模式为：模板方法模式）。

## EventBus

EventBus是一个Android事件发布/订阅框架，通过解耦发布者和订阅者简化Android事件传递，这里的事件可以理解为消息。事件传递既可以用于Android四大组件间通讯，也可以用于异步线程和主线程间通讯等。
 传统的事件传递方式包括：Handler、BroadcastReceiver、Interface回调，相比之下EventBus的优点是代码简洁，使用简单，并将事件发布和 订阅充分解耦。

**事件Event： **又可称为消息，其实就是一个对象，可以是网络请求返回的字符串，也可以是某个开关状态等等。事件类型EventType是指事件所属的Class。

事件分为一般事件和Sticky事件，相对于一般事件，Sticky事件不同之处在于，当事件发布后，再有订阅者开始订阅该类型事件，依然能收到该类型事件的最近一个Sticky事件。

**订阅者Subscriber： **订阅某种事件类型的对象，当有发布者发布这类事件后，EventBus会执行订阅者的onEvent函数，这个函数叫事件响应函数。订阅者通过register接口订阅某个事件类型，unregister接口退订。订阅者存在优先级，优先级高的订阅者可以取消事件继续向优先级低的订阅者分发，默认所有订阅者优先级都为0。

**发布者Publisher： **发布某事件的对象，通过post接口发布事件。

## okHttp

## Intent

### Intent的介绍

Intent的中文意思是“意图，意向”，在Android中提供了Intent机制来协助应用间的交互与通讯，Intent负责对应用中一次操作的动作、动作涉及数据、附加数据进行描述，Android则根据此Intent的描述，负责找到对应的组件，将 Intent传递给调用的组件，并完成组件的调用。Intent不仅可用于应用程序之间，也可用于应用程序内部的Activity/Service之间的交互。因此，可以将Intent理解为不同组件之间通信的“媒介”专门提供组件互相调用的相关信息。

### Intent的七大属性

**第一类：启动，有ComponentName（显式）,Action（隐式），Category（隐式）。**
 **第二类：传值，有Data（隐式），Type（隐式），Extra（隐式、显式）。**
 **第三类：启动模式，有Flag。**

#### 1.ComponentName（显式Intent）

下面我们来看一个简单的例子：跳转到另一个Activity

```java
Intent intent = new Intent();
                ComponentName componentName = new ComponentName(MainActivity.this,OtherActivity.class);
                intent.setComponent(componentName);
                startActivity(intent);
```

上面等同于下面两个：

```java
Intent intent = new Intent();
                intent.setClass(MainActivity.this,OtherActivity.class);
                startActivity(intent);
```

一般我们写成：

```java
 Intent intent = new Intent(MainActivity.this, OtherActivity.class);
                startActivity(intent);
```

#### 2.Action跟Category（隐式Intent）

因为在实际开发中，Action大多时候都是和Category一起使用的，所以这里我们将这两个放在一起来讲解。Intent中的Action我们在使用广播的时候用的比较多，在Activity中，我们可以通过设置Action来隐式的启动一个Activity，比如我们有一个ThirdActivity，我们在清单文件中做如下配置：

```java
<activity android:name=".ThirdActivity">
            <intent-filter>
                <category android:name="android.intent.category.DEFAULT"/>
                <action android:name="com.yjn.ThirdActivity"/>
            </intent-filter>
        </activity>
```

然后响应：

```java
Intent intent = new Intent();
                intent.setAction("com.yjn.ThirdActivity");
                startActivity(intent);
```

当然可以写简单一点

```java
 Intent intent = new Intent("com.yjn.ThirdActivity");
                startActivity(intent);
```

通过这中方式我们也可以启动一个Activity，那么大家可能也注意到了，我们的清单文件中有一个category的节点，那么没有这个节点可以吗？不可以！！当我们使用这种隐式启动的方式来启动一个Activity的时候，必须要action和category都匹配上了，该Activity才会成功启动。如果我们没有定义category，那么可以暂时先使用系统默认的category，总之，category不能没有。这个时候我们可能会有疑问了，如果我有多个Activity都配置了相同的action，那么会启动哪个？看下面一张图片:

![image-20190219135823814](https://ws4.sinaimg.cn/large/006tKfTcly1g0bozmdarrj30re16o77x.jpg)



当我们有多个Activity配置了相同的action的时候，那么系统会弹出来一个选择框，让我们自己选择要启动那个Activity。
action我们只能添加一个，但是category却可以添加多个（至少有一个，没有就要设置为DEFAULT），如下：

```java
<activity android:name=".ThirdActivity">
            <intent-filter>
                <category android:name="android.intent.category.DEFAULT"/>
                <category android:name="mycategory"/>
                <action android:name="com.yjn.ThirdActivity"/>
            </intent-filter>
        </activity>
```

相应的代码如下：

```java
Intent intent = new Intent("com.yjn.ThirdActivity");
                intent.addCategory("mycategory");
                startActivity(intent);
```

#### 3.Data

通过设置data，我们可以执行打电话，发短信，开发网页等等操作。究竟做哪种操作，要看我们的数据格式：

```java
// 打开网页  
intent = new Intent(Intent.ACTION_VIEW);  
intent.setData(Uri.parse("http://www.baidu.com"));  
startActivity(intent);  
// 打电话  
intent = new Intent(Intent.ACTION_VIEW);  
intent.setData(Uri.parse("tel:18565554482"));  
startActivity(intent);  
```

当我们的data是一个http协议的时候，系统会自动去查找可以打开http协议的Activity，这个时候如果手机安装了多个浏览器，那么系统会弹出多个浏览器供我们选择。这是我们通过设置Data来启动一个Activity，同时，我们也可以通过设置一个Data属性来将我们的Activity发布出去供别人调用，怎么发布呢？

```java
<activity android:name=".HttpActivity" >
            <intent-filter>
                <category android:name="android.intent.category.DEFAULT"/>

                <action android:name="ANDROID.INTENT.ACTION.VIEW"/>
                <data android:scheme="http"/>
            </intent-filter>
        </activity>
```

在data节点中我们设置我们这个Activity可以打开的协议，我们这里设置为http协议，那么以后要打开一个http请求的时候，系统都会让我们选择是否用这个Activity打开。当然，我们也可以自己定义一个协议（自己定义的协议，由于别人不知道，所以只能由我们自己的程序打开）。比如下面这样：

```java
<activity  
    android:name=".HttpActivity"  
    android:label="@string/title_activity_http" >  
    <intent-filter>  
        <action android:name="android.intent.action.VIEW" />  
  
        <category android:name="android.intent.category.DEFAULT" />  
  
        <data  
            android:scheme="myhttp" />  
    </intent-filter>  
</activity>  
```

那么我们怎么打开自己的Activity呢？

```java
intent = new Intent();  
            intent.setData(Uri.parse("myhttp://www.baidu.com"));  
            startActivity(intent);  
```

这个例子没有什么实际意义，我只是举一个自定义协议的栗子。
 其实，说到这里，大家应该明白了为什么我们说data是隐式传值，比如我们打开一个网页，http协议后面跟的就是网页地址，我们不用再单独指定要打开哪个网页。

#### 4.Type

type的存在，主要是为了对data的类型做进一步的说明，但是一般情况下，只有data属性为null的时候，type属性才有效，如果data属性不为null，系统会自动根据data中的协议来分析data的数据类型，而不会去管type。当我们设置data的时候，系统会默认将type设置为null，当我们设置type的时候，系统会默认将data设置为null.也就是说，一般情况下，data和type我们只需要设置一个就行了，如果我们既想要设置data又想要设置type，那么可以使用

```java
setDataAndType(Uri data, String type)  
```

#### 5.Flag

通过设置Flag，我们可以设定一个Activity的启动模式，这个和launchMode基本上是一样的，所以我也不再细说。

#### 6.Extras

这个参数不参与匹配activity，而仅作为额外数据传送到另一个activity中，接收的activity可以将其取出来。这些信息并不是激活这个activity所必须的。也就是说激活某个activity与否只上action、data、catagory有关，与extras无关。而extras用来传递附加信息，诸如用户名，用户密码什么的。
 可通过putXX()和getXX()方法存取信息；也可以通过创建Bundle对象，再通过putExtras()和getExtras()方法来存取。

通过bundle对象传递

- 发送方

```java
Intent intent = new Intent("com.scott.intent.action.TARGET");    
Bundle bundle = new Bundle();    
bundle.putInt("id", 0);    
bundle.putString("name", "scott");    
intent.putExtras(bundle);    
startActivity(intent);    
```

- 接收方

```java
Bundle bundle = intent.getExtras();  
int id = bundle.getInt("id");  
String name = bundle.getString("name");  
```

### 附Intent调用常见系统组件方法

```java
// 调用浏览器  
Uri webViewUri = Uri.parse("http://blog.csdn.net/zuolongsnail");  
Intent intent = new Intent(Intent.ACTION_VIEW, webViewUri);  
  
// 调用地图  
Uri mapUri = Uri.parse("geo:100,100");  
Intent intent = new Intent(Intent.ACTION_VIEW, mapUri);  
  
// 播放mp3  
Uri playUri = Uri.parse("file:///sdcard/test.mp3");  
Intent intent = new Intent(Intent.ACTION_VIEW, playUri);  
intent.setDataAndType(playUri, "audio/mp3");  
  
// 调用拨打电话  
Uri dialUri = Uri.parse("tel:10086");  
Intent intent = new Intent(Intent.ACTION_DIAL, dialUri);  
// 直接拨打电话，需要加上权限<uses-permission id="android.permission.CALL_PHONE" />  
Uri callUri = Uri.parse("tel:10086");  
Intent intent = new Intent(Intent.ACTION_CALL, callUri);  
  
// 调用发邮件（这里要事先配置好的系统Email，否则是调不出发邮件界面的）  
Uri emailUri = Uri.parse("mailto:zuolongsnail@163.com");  
Intent intent = new Intent(Intent.ACTION_SENDTO, emailUri);  
// 直接发邮件  
Intent intent = new Intent(Intent.ACTION_SEND);  
String[] tos = { "zuolongsnail@gmail.com" };  
String[] ccs = { "zuolongsnail@163.com" };  
intent.putExtra(Intent.EXTRA_EMAIL, tos);  
intent.putExtra(Intent.EXTRA_CC, ccs);  
intent.putExtra(Intent.EXTRA_TEXT, "the email text");  
intent.putExtra(Intent.EXTRA_SUBJECT, "subject");  
intent.setType("text/plain");  
Intent.createChooser(intent, "Choose Email Client");  
  
// 发短信  
Intent intent = new Intent(Intent.ACTION_VIEW);  
intent.putExtra("sms_body", "the sms text");  
intent.setType("vnd.android-dir/mms-sms");  
// 直接发短信  
Uri smsToUri = Uri.parse("smsto:10086");  
Intent intent = new Intent(Intent.ACTION_SENDTO, smsToUri);  
intent.putExtra("sms_body", "the sms text");  
// 发彩信  
Uri mmsUri = Uri.parse("content://media/external/images/media/23");  
Intent intent = new Intent(Intent.ACTION_SEND);  
intent.putExtra("sms_body", "the sms text");  
intent.putExtra(Intent.EXTRA_STREAM, mmsUri);  
intent.setType("image/png");  
  
// 卸载应用  
Uri uninstallUri = Uri.fromParts("package", "com.app.test", null);  
Intent intent = new Intent(Intent.ACTION_DELETE, uninstallUri);  
// 安装应用  
Intent intent = new Intent(Intent.ACTION_VIEW);  
intent.setDataAndType(Uri.fromFile(new File("/sdcard/test.apk"), "application/vnd.android.package-archive");  
  
// 在Android Market中查找应用  
Uri uri = Uri.parse("market://search?q=愤怒的小鸟");           
Intent intent = new Intent(Intent.ACTION_VIEW, uri); 
```



## 版本问题

### CompileSdkVersion

`compileSdkVersion` 告诉 Gradle 用哪个 Android SDK 版本编译你的应用。使用任何新添加的 API 就需要使用对应 Level 的 Android SDK。

需要强调的是修改 `compileSdkVersion` 不会改变运行时的行为。当你修改了 `compileSdkVersion` 的时候，可能会出现新的编译警告、编译错误，但新的 `compileSdkVersion` 不会被包含到 APK 中：它纯粹只是在编译的时候使用。（你真的应该修复这些警告，他们的出现一定是有原因的）

因此我们强烈推荐总是使用最新的 SDK 进行编译。在现有代码上使用新的编译检查可以获得很多好处，避免新弃用的 API ，并且为使用新的 API 做好准备。

注意，如果使用 `Support Library` ，那么使用最新发布的 `Support Library` 就需要使用最新的 SDK 编译。例如，要使用 23.1.1 版本的 `Support Library` ，`compileSdkVersion` 就必需至少是 23 （大版本号要一致！）。通常，新版的 `Support Library` 随着新的系统版本而发布，它为系统新增加的 API 和新特性提供兼容性支持。

### MinSdkVersion

如果 `compileSdkVersion` 设置为可用的最新 API，那么 `minSdkVersion` 则是应用可以运行的最低要求。`minSdkVersion` 是 Google Play 商店用来判断用户设备是否可以安装某个应用的标志之一。

在开发时 `minSdkVersion` 也起到一个重要角色：`lint` 默认会在项目中运行，它在你使用了高于 `minSdkVersion` 的 API 时会警告你，帮你避免调用不存在的 API 的运行时问题。如果只在较高版本的系统上才使用某些 API，通常使用运行时检查系统版本的方式解决。

请记住，你所使用的库，如 `Support Library` 或 `Google Play services`，可能有他们自己的 `minSdkVersio`n 。你的应用设置的 `minSdkVersion` 必需大于等于这些库的 `minSdkVersion` 。

当你决定使用什么 `minSdkVersion` 时候，你应该参考当前的 Android 分布统计，它显示了最近 7 天所有访问 Google Play 的设备信息。他们就是你把应用发布到 Google Play 时的潜在用户。最终这是一个商业决策问题，取决于为了支持额外 3% 的设备，确保最佳体验而付出的开发和测试成本是否值得。

当然，如果某个新的 API 是你整个应用的关键，那么确定 `minSdkVersion` 的值就比较容易了。不过要记得 14 亿设备中的 0.7％ 也是个不小的数字。

### TargetSdkVersion

三个版本号中最有趣的就是 `targetSdkVersion` 了。 `targetSdkVersion` 是 Android 提供向前兼容的主要依据，在应用的 `targetSdkVersion` 没有更新之前系统不会应用最新的行为变化。这允许你在适应新的行为变化之前就可以使用新的 API （因为你已经更新了 `compileSdkVersion` 不是吗？）。

`targetSdkVersion` 所暗示的许多行为变化都记录在 VERSION_CODES 文档中了，但是所有恐怖的细节也都列在每次发布的平台亮点中了，在这个 API Level 表中可以方便地找到相应的链接。

例如，Android 6.0 变化文档中谈了 target 为 API 23 时会如何把你的应用转换到运行时权限模型上，Android 4.4 行为变化阐述了 target 为 API 19 及以上时使用 `set()` 和 `setRepeating()` 设置 alarm 会有怎样的行为变化。

由于某些行为的变化对用户是非常明显的（弃用的 menu 按钮，运行时权限等），所以将 target 更新为最新的 SDK 是所有应用都应该优先处理的事情。但这不意味着你一定要使用所有新引入的功能，也不意味着你可以不做任何测试就盲目地更新 `targetSdkVersion` ，请一定在更新 `targetSdkVersion` 之前做测试！你的用户会感谢你的。

### 综合来看

如果你按照上面示例那样配置，你会发现这三个值的关系是：

```
minSdkVersion <= targetSdkVersion <= compileSdkVersion
```

这种直觉是合理的，如果 `compileSdkVersion` 是你的最大值，`minSdkVersion` 是最小值，那么最大值必需至少和最小值一样大且 target 必需在二者之间。

理想上，在稳定状态下三者的关系应该更像这样：

```
minSdkVersion (lowest possible) <=
    targetSdkVersion == compileSdkVersion (latest SDK)
```

用较低的 `minSdkVersion` 来覆盖最大的人群，用最新的 SDK 设置 target 和 compile 来获得最好的外观和行为。





## Android中的动画

### 综述

Android中的动画分为补间动画(Tweened Animation)和逐帧动画(Frame-by-Frame Animation)。没有意外的，补间动画是在几个关键的节点对对象进行描述又系统进行填充。而逐帧动画是在固定的时间点以一定速率播放一系列的drawable资源。下面对两种动画进行分别简要说明。

### 补间动画

补间动画分为如下种

- Alpha 淡入淡出
- Scale 缩放
- Rotate 旋转
- Translate 平移

这些动画是可以同时进行和顺次进行的。需要用到AnimationSet来实现。调用AnimationSet.addAnimation()即可。 实现方法举例:

```java
(Button)btn = (Button)findViewById(...);
AnimationSet as = new AnimationSet(false);//新建AnimationSet实例
TranslateAnimation ta = new TranslateAnimation(//新建平移动画实例，在构造函数中传入平移的始末位置
        Animation.RELATIVE_TO_SELF, 0f,
        Animation.RELATIVE_TO_SELF, 0.3f,
        Animation.RELATIVE_TO_SELF, 0f,
        Animation.RELATIVE_TO_SELF, 0.3f);
ta.setStartOffset(0);//AnimationSet被触发后立刻执行
ta.setInterpolator(new AccelerateDecelerateInterpolator());//加入一个加速减速插值器
ta.setFillAfter(true);//动画结束后保持该状态
ta.setDuration(700);//设置动画时长

ScaleAnimation sa = new ScaleAnimation(1f, 0.1f, 1f, 0.1f,//构造一个缩放动画实例，构造函数参数传入百分比和缩放中心
        ScaleAnimation.RELATIVE_TO_SELF, 0.5f, 
        ScaleAnimation.RELATIVE_TO_SELF, 0.5f);
sa.setInterpolator(new AccelerateDecelerateInterpolator());//加入一个加速减速插值器
sa.setDuration(700);//设置时长
sa.setFillAfter(true);//动画结束后保持该状态
sa.setStartOffset(650);//AnimationSet触发后650ms启动动画

AlphaAnimation aa = new AlphaAnimation(1f, 0f);//构造一个淡出动画，从100%变为0%
aa.setDuration(700);//设置时长
aa.setStartOffset(650);//AnimationSet触发后650ms启动动画
aa.setFillAfter(true);//动画结束后保持该状态

as.addAnimation(ta);
as.addAnimation(sa);
as.addAnimation(aa);//将动画放入AnimationSet中

btn.setOnClickListener(new OnClickListener(){
  public void onClick(View view){
    btn.startAnimation(as);//触发动画
  }
}
```

该段代码实现了先平移，然后边缩小边淡出。

具体的代码实现需要注意各个参数所代表的含义，比较琐碎，建议阅读文档熟悉。在这里不做过多讲解，文档说的已经很清楚了。
文档链接<http://developer.android.com/reference/android/view/animation/Animation.html>

### 逐帧动画

这一部分只涉及非常基础的知识。逐帧动画适用于更高级的动画效果，原因可想而知。我们可以将每帧图片资源放到drawable下然后代码中canvas.drawBitmap(Bitmap, Matrix, Paint)进行动画播放，但这样就将动画资源与代码耦合，如果哪天美工说我要换一下效果就呵呵了。因此我们要做的是将资源等信息放入配置文件然后教会美工怎么改配置文件，这样才有时间去刷知乎而不被打扰^_^。 大致分为两种方法：

- 每一帧是一张png图片中
- 所有动画帧都存在一张png图片中

当然还有的专门的游戏公司有自己的动画编辑器，这里不加说明。

#### 每一帧是一张png

说的就是这个效果：
![每一帧是一张png例图](https://github.com/HIT-Alibaba/interview/blob/master/img/android-animation-eachpng.jpg?raw=true)

在animation1.xml文件中进行如下配置：

```xml
<?xml version="1.0" encoding="utf-8"?>
<animation-list
  xmlns:android="http://schemas.android.com/apk/res/android"
  android:oneshot="true"<!-- true表示只播放一次，false表示循环播放 -->
  >
    <item android:drawable="@drawable/hero_down_a" android:duration="70"></item>
    <item android:drawable="@drawable/hero_down_b" android:duration="70"></item>
    <item android:drawable="@drawable/hero_down_c" android:duration="70"></item>
    <item android:drawable="@drawable/hero_down_d" android:duration="70"></item>
</animation-list>
```

在JAVA文件中我们进行如下加载：

```java
ImageView animationIV;
AnimationDrawable animationDrawable;

animationIV.setImageResource(R.drawable.animation1);
animationDrawable = (AnimationDrawable) animationIV.getDrawable();
animationDrawable.start();
```

注意动画的播放是按照xml文件中的顺序顺次播放，如果要考虑到循环播放的时候应该写两个xml一个正向一个反向才能很好地循环播放。

#### 所有动画在一张png中

说的就是这个效果：
![所有动画放在一张png中](https://github.com/HIT-Alibaba/interview/blob/master/img/android-animation-onepng.jpg?raw=true) animation.xml的配置：

```xml
<key>010001.png</key>
<dict>
    <key>frame</key>
    <string>{{378, 438}, {374, 144}}</string>
    <key>offset</key>
    <string>{-2, 7}</string>
    <key>sourceColorRect</key>
    <string>{{61, 51}, {374, 144}}</string>
    <key>sourceSize</key>
    <string>{500, 260}</string>
</dict>
<key>010002.png</key>
<dict>
    <key>frame</key>
    <string>{{384, 294}, {380, 142}}</string>
    <key>offset</key>
    <string>{1, 7}</string>
    <key>sourceColorRect</key>
    <key>rotate</key>
    <false/>
    <string>{{61, 52}, {380, 142}}</string>
    <key>sourceSize</key>
    <string>{500, 260}</string>
</dict>
…
```

其中：

- frame 指定在原图中截取的框大小；
- offeset 指定原图中心与截图中心偏移的向量；
- rotate若为true顺时针旋转90°；
- sourceColorRect 截取原图透明部分的大小
- sourceSize 原图大小

JAVA的加载方式与第一种方法相同。

在使用过程中一定要注意内存资源的回收和drawable的压缩，一不小心可能爆掉。

## HandlerThread和Tread的区别

## IntentService是什么

## 线程池和AsyncTask

## MemoryCache

## AIDL

## 对象池

