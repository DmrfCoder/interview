# Android

## Android的系统架构是怎么样的？

总的来说，Android的系统体系结构分为**四层**，自顶向下分别是：

- 应用程序(Applications)
- 应用程序框架(Application Frameworks)
- 系统运行库与Android运行环境(Libraris & Android Runtime)
- Linux内核(Linux Kernel)

*安卓系统结构示意图:*
![2](https://ws2.sinaimg.cn/large/006tKfTcly1g0dzkgl481j30i20czta7.jpg)

## Android四大组件

Android四大组件分别是`Activity`，`Service`服务,`Content Provider`内容提供者，`BroadcastReceiver`广播接收器。

### Activity

#### Activity生命周期

![1](https://ws4.sinaimg.cn/large/006tKfTcly1g0ahnvdf3oj30ie087q4j.jpg)

在上面的图中存在不同状态之间的过渡，但是，这些状态中只有三种可以是静态，也就是说 Activity 只能在三种状态之一下存在很长时间：

- **Resumed**：Activity处于前台，且用户可以与其交互（又称为运行态，在调用 `onResume()` 方法调用后）。
- **Paused**：Activity被在前台中处于半透明状态或者未覆盖整个屏幕的另一个Activity（DialogActivity）—部分阻挡或者锁屏。 暂停的Activity不会接收用户输入并且无法执行任何代码。
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

#### 关于Android屏幕旋转时Activity的声明周期

如果配置了`android:configChanges="keyboardHidden|orientation|screenSize"`，  这句话意思就是配置双引号里面参数意义，软键盘隐藏，方向，屏幕大小，则屏幕旋转时只会调用Activity的configChanges方法，我们可以重写该方法，达到不调用其他的生命周期的方法的目的。

如果没有配置`configChanges`，则生命周期如下：

- onCreate
- onStart
- onResume
- onSaveInstanceState
- onPause
- onStop
- onDestroy
- OnCreate
- onStart
- OnRestoreInstanceState
- onResume

#### onSaveInstanceState 什么时候调用

> 1. 非用户主动明确结束（按back键，自定义click方法调用finish）时都会调用onSaveInstanceState： 
>    1. 屏幕旋转
>    2. 按HOME键
>    3. 内存不足
>    4. 从一个activity启动另一个activity
> 2. 这个方法的调用时机是在onStop前，但是它和onPause没有既定的时序关系

#### [Activity之间的通信方式](https://juejin.im/post/5a9509ef6fb9a06337575d4b)

> 1. Intent
> 2. BroadCast或者LocalBroadCast
> 3. 数据存储的方式
> 4. 静态变量

#### activity启动的四种模式

standard，singleTop，singleTask，singleInstance，如果要使用这四种启动模式，必须在manifest文件中<activity>标签中的launchMode属性中配置，如：

```java
<activity android:name=".app.InterstitialMessageActivity"
                  android:label="@string/interstitial_label"
                  android:theme="@style/Theme.Dialog"
                  android:launchMode="singleTask"
</activity>
```

##### standard

标准启动模式，也是activity的默认启动模式。在这种模式下启动的activity可以被多次实例化，即在同一个任务中可以存在多个activity的实例，每个实例都会处理一个Intent对象。如果Activity A的启动模式为standard，并且A已经启动，在A中再次启动Activity A，即调用startActivity（new Intent（this，A.class）），会在A的上面再次启动一个A的实例，即当前的桟中的状态为A-->A。

##### singleTop

如果一个以singleTop模式启动的activity的实例已经存在于任务桟的桟顶，那么再启动这个Activity时，不会创建新的实例，而是重用位于栈顶的那个实例，并且会调用该实例的onNewIntent()方法将Intent对象传递到这个实例中。举例来说，如果A的启动模式为singleTop，并且A的一个实例已经存在于栈顶中，那么再调用startActivity（new Intent（this，A.class））启动A时，不会再次创建A的实例，而是重用原来的实例，并且调用原来实例的onNewIntent()方法。这时任务桟中还是这有一个A的实例。

如果以singleTop模式启动的activity的一个实例已经存在与任务桟中，但是不在桟顶，那么它的行为和standard模式相同，也会创建多个实例。

##### singleTask

栈内复用模式。这种模式下，只要Activity只要在一个栈内存在，那么就不会创建新的实例，会调用`onNewIntent()`方法。

- 如果要调用的Activity在同一应用中：调用singleTask模式的Activity会清空在它之上的所有Activity。
- 若其他应用启动该Activity：如果不存在，则建立新的Task。如果已经存在后台，那么启动后，后台的Task会一起被切换到前台。

适合作为程序入口点，例如浏览器的主界面。不管从多少个应用启动浏览器，只会启动主界面一次，其余情况都会走onNewIntent，并且会清空主界面上面的其他页面。

##### singleInstance

总是在新的任务中开启，并且这个新的任务中有且只有这一个实例，也就是说被该实例启动的其他activity会自动运行于另一个任务中。当再次启动该activity的实例时，会重用已存在的任务和实例。并且会调用这个实例的onNewIntent()方法，将Intent实例传递到该实例中。和singleTask相同，同一时刻在系统中只会存在一个这样的Activity实例。

![image-20190218133254451](https://ws1.sinaimg.cn/large/006tKfTcly1g0ain5wyjmj30u012cb2a.jpg)

适合需要与程序分离开的页面。例如闹铃提醒，将闹铃提醒与闹铃设置分离。

#### Fragment

##### Fragment生命周期

> onAttach -> onCreate  -> onCreateView -> onActivityCreate -> onStart -> onResume -> onPause -> onStop -> onDestoryView -> onDestory -> onDetach

##### 遇到过哪些关于Fragment的问题，如何处理的

> 举例：getActivity()空指针：这种情况一般发生在在异步任务里调用getActivity()，而Fragment已经onDetach()。

##### Fragment 有什么优点， Fragment和View可以相互替换嘛

> 1. Fragment为了解决Andriod碎片化而产生的
> 2. Fragment和View都有助于界面复用
> 3. Fragment的复用粒度更大，包含生命周期和业务逻辑，通常包含好几个View
> 4. View通常更关注视图的实现

##### Fragment add replace 区别

1. replace 先删除容器中的内容，再添加
2. add直接添加，可以配合hide适用

### Service

#### Service 和Activity 的通信方式

> 1. 如上Activity和Activity的通信方式
> 2. [bind方式启动时可以通过ServiceConnection通信](https://link.juejin.im?target=https%3A%2F%2Fwww.cnblogs.com%2FJMatrix%2Fp%2F8296364.html)：在SerVice的onBind方法中返回一个binder，该binder可以是AIDL方法产生的，也可以是Messenger方法产生的

#### service生命周期

![2](https://ws2.sinaimg.cn/large/006tKfTcly1g0ahvy80hwj30ir0fcdh6.jpg)

- Start Service：通过`context.startService()`启动，这种service可以无限制的运行，除非调用`stopSelf()`或者其他组件调用`context.stopService()`。
- Bind Service：通过`context.bindService()`启动，客户可以通过IBinder接口和service通信，客户可以通过`context.unBindService()`取消绑定。一个service可以和多个客户绑定，当所有客户都解除绑定后，service将终止运行。

一个通过`context.startService()`方法启动的service，其他组件也可以通过`context.bindService()`与它绑定，在这种情况下，不能使用`stopSelf()`或者`context.stopService()`停止service，只能当所有客户解除绑定在调用`context.stopService()`才会终止。

#### [IntentService](https://link.juejin.im?target=https%3A%2F%2Fwww.jianshu.com%2Fp%2F332b6daf91f0)

> 1. IntentService 是继承自 Service,内部通过HandlerThread启动一个新线程处理耗时操作，可以看做是Service和HandlerThread的结合体，在完成了使命之后会自动停止，适合需要在工作线程处理UI无关任务的场景
> 2. 如果启动 IntentService 多次，那么每一个耗时操作会以工作队列的方式在 IntentService 的 onHandleIntent 回调方法中执行，依次去执行，使用串行的方式，执行完自动结束

#### IntentService生命周期是怎样的

> 1. 在所有任务执行完毕后，自动结束生命

### Content Provider

主要的作用就是将程序的内部的数据和外部进行共享，为数据提供外部访问接口，被访问的数据主要以数据库的形式存在，而且还可以选择共享哪一部分的数据。这样一来，对于程序当中的隐私数据可以不共享，从而更加安全。content provider是android中一种跨程序共享数据的重要组件。

#### [请介绍下ContentProvider是如何实现数据共享的](https://link.juejin.im?target=https%3A%2F%2Fblog.csdn.net%2Fu011240877%2Farticle%2Fdetails%2F72848608)

> 1. 准确的说，ContentProvider是一个APP间共享数据的接口。一个程序可以通过实现一个Content provider的抽象接口将自己的数据完全暴露出去，数据可以是SqLite中的，也可以是文件或者其他类型。
> 2. 使用方式： 
>    1. 在A APP中实现建ContentProvider，并在Manifest中生命它的Uri和权限
>    2. 在B APP中注册权限，并通过ContentResolver和Uri进行增删改查
> 3. [扩展](https://link.juejin.im?target=https%3A%2F%2Fwww.2cto.com%2Fkf%2F201407%2F317150.html)：ContentProvider底层是通过Binder机制来实现跨进程间通信，通过匿名共享内存方式进行数据的传输 一个应用进程有16个Binder线程去和远程服务进行交互，而每个线程可占用的缓存空间是128KB，超过会报异常。

#### ContentProvider、ContentResolver与ContentObserver之间的关系是什么？

> 1. ContentProvider：管理数据，提供数据的增删改查操作，数据源可以是数据库、文件、XML、网络等，ContentProvider为这些数据的访问提供了统一的接口，可以用来做进程间数据共享。
> 2. ContentResolver：ContentResolver可以不同URI操作不同的ContentProvider中的数据，外部进程可以通过ContentResolver与ContentProvider进行交互。
> 3. ContentObserver：观察ContentProvider中的数据变化，并将变化通知给外界。

每个ContentProvider的操作是在哪个线程中运行的呢（其实我们关心的是UI线程和工作线程）？比如我们在UI线程调用getContentResolver().query查询数据，而当数据量很大时（或者需要进行较长时间的计算）会不会阻塞UI线程呢？

要分两种情况回答这个问题：

1：ContentProvider和调用者在同一个进程，ContentProvider的方法（query/insert/update/delete等）和调用者在同一线程中；

2：ContentProvider和调用者在不同的进程，ContentProvider的方法会运行在它自身所在进程的一个Binder线程中。

但是，注意这两种方式在ContentProvider的方法没有执行完成前都会阻塞调用者。

### BroadcastReceiver（广播机制）

广播(Broadcast)机制用于进程/线程间通信，广播分为广播发送和广播接收两个过程，其中广播接收者BroadcastReceiver便是Android四大组件之一。

BroadcastReceiver分为两类：

- `静态广播接收者`：通过`AndroidManifest.xml`的标签来申明的BroadcastReceiver。
- `动态广播接收者`：通过`AMS.registerReceiver()`方式注册的BroadcastReceiver，动态注册更为灵活，可在不需要时通过`unregisterReceiver()`取消注册。

从广播发送方式可分为三类：

- `普通广播`：通过Context.sendBroadcast()发送，可并行处理，完全异步的，可以在同一时刻（逻辑上）被所有接收者接收到，消息传递的效率比较高，但缺点是：接收者不能将处理结果传递给下一个接收者，并且无法终止广播Intent的传播；

- `有序广播`：通过Context.sendOrderedBroadcast()发送，串行处理，按照接收者声明的优先级别（声明在intent-filter元素的android:priority属性中，数越大优先级别越高,取值范围:-1000到1000。也可以调用IntentFilter对象的setPriority()进行设置），被接收者依次接收广播。前面的接收者可以将处理结果通过setResultExtras(Bundle)方法存放进结果对象，然后传给下一个接收者，通过代码：Bundle bundle =getResultExtras(true))可以获取上一个接收者存入在结果对象中的数据。

  比如想阻止用户收到短信，可以通过设置优先级，让你们自定义的接收者先获取到广播，然后终止广播，这样用户就接收不到短信了。

- `Sticky广播`：通过Context.sendStickyBroadcast()发送，发出的广播会一直滞留（等待），以便有人注册这则广播消息后能尽快的收到这条广播。

Android 中的 Broadcast 实际底层使用Binder机制。

#### BroadCast的注册方式与区别

> 1. 在manifest中静态注册:广播是常驻的，android3.1版本之前App关闭后仍能接收广播，唤醒App
> 2. 动态的注册和注销:动态注册的广播生命周期和他的宿主相同，或者调用注销方法注销广播

Android 3.1开始系统在Intent与广播相关的flag增加了参数：
 A. `FLAG_INCLUDE_STOPPED_PACKAGES`：包含已经停止的包（停止：即包所在的进程已经退出）
 B. `FLAG_EXCLUDE_STOPPED_PACKAGES`：不包含已经停止的包
 自Android3.1开始，系统本身增加了对所有App当前是否处于运行状态的跟踪。在发送广播时，不管是什么广播类型，**系统默认直接增加了值为`FLAG_EXCLUDE_STOPPED_PACKAGES`的flag**，导致即使是静态注册的广播接收器，对于其所在进程已经退出的App，同样无法接收到广播。

#### [Android中发送BroadCast的方式](https://link.juejin.im?target=https%3A%2F%2Fwww.jianshu.com%2Fp%2Fea5e233d9f43)

> 1. 无序广播：通过mContext.sendBroadcast(Intent)或mContext.sendBroadcast(Intent, String)发送的是无序广播(后者加了权限)；
> 2. 通过mContext.sendOrderedBroadcast(Intent, String, BroadCastReceiver, Handler, int, String, Bundle)发送的是有序广播（不再推荐使用）。
> 3. 在无序广播中，所有的Receiver会接收到相同广播；而在有序广播中，我们可以为Receiver设置优先级，优先级高的先接收广播，并有权对广播进行处理和决定要不要继续向下传送

#### BroadCastReceiver处理耗时操作

> 1. BroadcastReceiver的生命周期只有一个回调方法onReceive(Context context, Intent intent)；无法进行耗时操作，即使启动线程处理，也是出于非活动状态，有可能被系统杀掉。
> 2. 如果需要进行耗时操作，可以启动一个service处理。

#### 广播发送和接收的原理了解吗

> 1. 继承BroadcastReceiver，重写onReceive()方法。
> 2. 通过Binder机制向ActivityManagerService注册广播。
> 3. 通过Binder机制向ActivityMangerService发送广播。
> 4. ActivityManagerService查找符合相应条件的广播（主要是通过在Intent中设置IntentFilter/Permission中的属性来定位广播）的BroadcastReceiver，将广播发送到BroadcastReceiver所在的消息队列中。
> 5. BroadcastReceiver所在消息队列拿到此广播后，回调它的onReceive()方法。

#### 广播传输的数据是否有限制，是多少，为什么要限制？

> 1. 广播是通过Intent携带需要传递的数据的
> 2. Intent是通过Binder机制实现的
> 3. Binder对数据大小有限制，不同room不一样，一般为1M

#### [Localbroadcast](https://link.juejin.im?target=https%3A%2F%2Fblog.csdn.net%2Fu013614207%2Farticle%2Fdetails%2F46536047)

本地广播，只有本进程中的receivers能接收到此广播

> 实现原理（监听者模式）：
>
> 1. LocalBroadcastManager是一个单例
> 2. 在LocalBroadcastManager实例中维护一个Action和ReceiverRecord的Map.(ReceiverRecord是reveiver和intentfilter的组合)
> 3. 当调用LocalBroadcastManager的sendBroadcast方法时，会从2中的map找到合适的receiver，让后加到待执行的队列mPendingBroadcasts，并通过Handler发送一个空消息（此Handler运行在主线程中，是创建manager时创建的）
> 4. handler 的handle方法收到消息，从mPendingBroadcasts取出receiver并调用onreceive方法
>     其他：删除方法是通过一个辅助的hashmap实现的，hashmap存储了receiver和receiverRecord



## 如何理解android中的context

![image-20190301132911899](https://ws2.sinaimg.cn/large/006tKfTcgy1g0n8cbdgktj31480u0gow.jpg)

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

进程和线程的主要差别在于它们是不同的操作系统资源管理方式。进程有独立的地址空间，一个进程崩溃后，在保护模式下不会对其它进程产生影响，而线程只是一个进程中的不同执行路径。线程有自己的堆栈和局部变量，但线程之间没有单独的地址空间，一个线程死掉（将地址空间写坏）就等于整个进程死掉，所以多进程的程序要比多线程的程序健壮，但在[进程切换](https://www.baidu.com/s?wd=%E8%BF%9B%E7%A8%8B%E5%88%87%E6%8D%A2&tn=24004469_oem_dg&rsv_dl=gh_pl_sl_csd)时，耗费资源较大，效率要差一些。**但对于一些要求同时进行并且又要共享某些变量的并发操作，只能用线程，不能用进程。**

**1) 简而言之,一个程序至少有一个进程,一个进程至少有一个线程.**

2) 线程的划分尺度小于进程，使得多线程程序的并发性高。

3) 另外，进程在执行过程中拥有独立的内存单元，而多个线程共享内存，从而极大地提高了程序的运行效率。

4) 线程在执行过程中与进程还是有区别的。每个独立的线程有一个程序运行的入口、顺序执行序列和程序的出口。**但是线程不能够独立执行，**必须依存在应用程序中，由应用程序提供多个线程执行控制。

5) 从逻辑角度来看，多线程的意义在于一个应用程序中，有多个执行部分可以同时执行。但操作系统并没有将多个线程看做多个独立的应用，来实现进程的调度和管理以及资源分配。**这就是进程和线程的重要区别。**

线程和进程在使用上各有优缺点：线程执行开销小，但不利于资源的管理和保护；而进程正相反。同时，线程适合于在SMP机器上运行，而进程则可以跨机器迁移。



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

对android来说 activity几乎承担了view层和controller层两种角色，并且和model层耦合严重，在逻辑复杂的界面维护起来很麻烦。

mvp模式下的activity只承担了view层的角色，controller的角色完全由presenter负责，view层和presenter层的通信通过接口实现，所以VP之间不存在耦合问题，view层与model也是完全解耦了。

presenter复用度高，可以随意搬到任何界面。

mvp模式下还方便测试维护： 
可以在未完成界面的情况下实现接口调试，只需写一个Java类，实现对应的接口，presenter网络获取数据后能调用相应的方法。 
相反的，在接口未完成联调的情况下正常显示界面，由presenter提供测试数据。

mvp的问题在于view层和presenter层是通过接口连接，在复杂的界面中，维护过多接口的成本很大。 

解决办法是定义一些基类接口，把网络请求结果,toast等通用逻辑放在里面，然后供定义具体业务的接口继承。

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

- 从文件系统中加载图片没有内存中加载那么快，甚至可能内存中加载也不够快。因此在ListView中应设立busy标志位，**当ListView滚动时busy设为true，停止各个view的图片加载**。否则可能会让UI不够流畅用户体验度降低。
- 文件**加载图片放在子线程实现**，否则快速滑动屏幕会卡
- 开启**网络访问等耗时操作需要开启新线程**，应使用线程池避免资源浪费，最起码也要用**AsyncTask**。
- Bitmap从网络下载下来最好先放到**文件系统中缓存**。这样一是方便下一次加载根据本地uri直接找到，二是如果Bitmap过大，从本地缓存可以方便的使用Option.inSampleSize配合Bitmap.decodeFile(ui, options)或Bitmap.createScaledBitmap来进行内存压缩

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
next：是一个无限循环的方法，如果没有消息，next方法就一直阻塞在这了 
如果有消息，next方法就返回这条消息并将消息从单列表中移除。

#### Looper的工作原理

Looper扮演着消息循环的角色，不停的从消息队列MessageQueue中查看是否具有消息，如果有消息就会立刻处理，否则就一直阻塞在那里

Handler中需要Looper，没有Looper线程就会报错，通过Looper.prepare()就可以为当前线程创建一个Looper，通过Looper.loop()来开启消息循环。

### Handler的使用套路

主线程中声明一个Handler，重写其handleMessage(Message msg)方法，通过msg.what属性的值对应到其他线程发送的Message并利用该Message拿到其他线程传过来的数据。

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



## RecyclerView

一个类似于listview的控件，规范化了viewholder的使用，封装了itemview的复用工作，不用像之前那样settag（）了，引入了layoutManager，方便动画编写，提供了局部item更新的接口。

## Zygote

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

关于ACTION_CANCEL何时被触发，系统文档有这么一种使用场景：在设计设置页面的滑动开关时，如果不监听ACTION_CANCEL，在滑动到中间时，如果你手指上下移动，就是移动到开关控件之外，则此时会触发ACTION_CANCEL，而不是ACTION_UP，造成开关的按钮停顿在中间位置。 
意思是当滑动的时候就会触发，不知道大家搞没搞过微信的长按录音，有一种状态是“松开手指，取消发送”，这时候就会触发ACTION_CANCEL。



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

完整的事件通常包括Down、Move、Up，当down事件被拦截下来以后，move和up就不再走intercept方法，而是直接被传递给当前view处理

ViewGroup`默认不拦截任何事件。Android源码中`ViewGroup`的`onInterceptTouchEvent`方法默认返回false。

**View没有onIntercepteTouchEvent方法，一旦有点击事件传递给它，那么它的onTouchEvent方法就会被调用**。



多点触控的要点：

在onTouch（Event event）中通过event.getPointerCount,可以获得触摸点的个数，通过event.getX(index)，添加索引可以获得不同控制点的坐标，然后做自己需要的事情。

#### [什么时候执行ACTION_CANCEL](https://link.juejin.im?target=https%3A%2F%2Fwww.jianshu.com%2Fp%2F8360d7150786)

> 1. 一个点击或者活动事件包含ACTION_DOWN，ACTION_MOVE,ACTION_UP等
> 2. 当子View处理了ACTION_DOWN事件之后，后续的ACTION_MOVE,ACTION_UP都会直接交由这个子View处理
> 3. 如果此时父View拦截了ACTION_MOVE,ACTION_UP，那么子View会收到一个ACTION_CANCEL
> 4. 场景举例：点击一个控件，并滑动到控件外，此时次控件会收到一个ACTION_CALNCEL

## Binder

### binder是什么

Binder承担了绝大部分Android进程通信的职责，可以看做是Android的血管系统，负责不同服务模块进程间的通信。

Binder往小了说可总结成一句话：

**一种跨进程通信（IPC）的方式，负责进程A的数据，发送到进程B。**

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

### 为什么要使用Binder？

主要有两个方面的原因：

性能方面 
在移动设备上（性能受限制的设备，比如要省电），广泛地使用跨进程通信对通信机制的性能有严格的要求，Binder相对出传统的Socket方式，更加高效。Binder数据拷贝只需要一次，而管道、消息队列、Socket都需要2次，共享内存方式一次内存拷贝都不需要，但实现方式又比较复杂。

安全方面 

Binder会验证权限，鉴定UID/PID来验证身份，保证了进程通信的安全性

还有一些好处，如实现面象对象的调用方式，在使用Binder时就和调用一个本地实例一样。



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
- BroadcastReceiver未在10秒内完成相关的处理

#### 如何避免

基本的思路就是将IO操作在工作线程来处理，减少其他耗时操作和错误操作

- 使用AsyncTask处理耗时IO操作。
- 使用Thread或者HandlerThread时，调用`Process.setThreadPriority(Process.THREAD_PRIORITY_BACKGROUND)`设置优先级，否则仍然会降低程序响应，因为默认Thread的优先级和主线程相同。
- 使用Handler处理工作线程结果，而不是使用Thread.wait()或者Thread.sleep()来阻塞主线程。
- `Activity`的`onCreate`和`onResume`回调中尽量避免耗时的代码
- `BroadcastReceiver`中`onReceive`代码也要尽量减少耗时，建议使用`IntentService`处理。

#### 如何改善

通常100到200毫秒就会让人察觉程序反应慢，为了更加提升响应，可以使用下面的几种方法

- 如果程序正在后台处理用户的输入，建议使用让用户得知进度，比如使用ProgressBar控件。
- 程序启动时可以选择加上欢迎界面，避免让用户察觉卡顿。
- 使用`Systrace`和`TraceView`找出影响响应的问题。

如果开发机器上出现问题，我们可以通过查看`/data/anr/traces.txt`即可，最新的ANR信息在最开始部分。

### OOM（Out Of Memory）

#### 常见的内存泄漏（举例）

> 1. 不恰当的使用static变量（或者向static集合中添加数据却忘了必要时移除数据）
> 2. 忘记关闭各种连接，如IO流等
> 3. [不恰当的内部类](https://link.juejin.im?target=https%3A%2F%2Fgithub.com%2Ffrancistao%2FLearningNotes%2Fblob%2Fmaster%2FPart1%2FAndroid%2FHandler%25E5%2586%2585%25E5%25AD%2598%25E6%25B3%2584%25E6%25BC%258F%25E5%2588%2586%25E6%259E%2590%25E5%258F%258A%25E8%25A7%25A3%25E5%2586%25B3.md)：因为内部类持有外部类的引用，当内部类存活时间较长时，导致外部类也不能正确的回收（常发生在使用Handler的时候）
> 4. 不恰当的单例模式：例如错误的将某个Activity给单例持有，或者在不该使用单例的地方使用了单例
> 5. 使用错误的Context：Application 和 Activity的context生命周期不一样
> 6. webview造成的内存泄漏

#### OOM异常是否可以被try...catch捕获

> 1. 在发生地点可以捕获
> 2. 但是OOM往往是由于内存泄漏造成的，泄漏的部分多数情况下不在try语句块里，所以catch后不久就会再次发生OOM
> 3. 对待OOM的方案应该是找到内存泄漏的地方以及优化内存的占用

#### 如何避免内存泄漏

- `内部类引用导致Activity的泄漏`：最典型的场景是Handler导致的Activity泄漏，如果Handler中有延迟的任务或者是等待执行的任务队列过长，都有可能因为Handler继续执行而导致Activity发生泄漏。
- `Activity Context被传递到其他实例中，这可能导致自身被引用而发生泄漏`。
- 考虑使用Application Context而不是Activity Context
- 注意临时Bitmap对象的及时回收
- 注意监听器的注销
- 注意缓存容器中的对象泄漏：不使用的对象要将引用置空。
- 注意Cursor对象是否及时关闭

### 如何减小内存的使用

在实践操作当中，可以从四个方面着手减小内存使用：

- 减小对象的内存占用（使用轻量级对象）
- 内存对象的重复利用（复用对象）
- 内存使用策略优化

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

#### 内存优化策略

- 综合考虑设备内存阈值与其他因素设计合适的缓存大小
- `onLowMemory()`：Android系统提供了一些回调来通知当前应用的内存使用情况，通常来说，当所有的background应用都被kill掉的时候，forground应用会收到onLowMemory()的回调。在这种情况下，需要尽快释放当前应用的非必须的内存资源，从而确保系统能够继续稳定运行。
- `onTrimMemory()`：Android系统从4.0开始还提供了onTrimMemory()的回调，当系统内存达到某些条件的时候，所有正在运行的应用都会收到这个回调，同时在这个回调里面会传递以下的参数，代表不同的内存使用情况，收到onTrimMemory()回调的时候，需要根据传递的参数类型进行判断，合理的选择释放自身的一些内存占用，一方面可以提高系统的整体运行流畅度，另外也可以避免自己被系统判断为优先需要杀掉的应用
- 资源文件需要选择合适的文件夹进行存放：例如我们只在`hdpi`的目录下放置了一张$100\times100$的图片，那么根据换算关系，`xxhdpi`的手机去引用那张图片就会被拉伸到$200\times200​$。需要注意到在这种情况下，内存占用是会显著提高的。**对于不希望被拉伸的图片，需要放到assets或者nodpi的目录下**。
- 谨慎使用static对象
- 优化布局层次，减少内存消耗
- 使用FlatBuffer等工具序列化数据
- 谨慎使用依赖注入框架
- 使用ProGuard来剔除不需要的代码

### Bitmap与OOM

图片是一个很耗内存的资源，因此经常会遇到OOM。比如从本地文件中读取图片，然后在GridView中显示出来，如果不做处理，OOM就极有可能发生。

#### Bitmap引起OOM的原因

1. 图片使用完成后，没有及时的释放，导致Bitmap占用的内存越来越大，而安卓提供给Bitmap的内存是有一定限制的，当超出该内存时，自然就发生了OOM
2. 图片过大

这里的图片过大是指**加载到内存时所占用的内存**，并不是图片自身的大小。而图片加载到内存中时所占用的内存是根据图片的分辨率以及它的配置（ARGB值）计算的。举个例子：

假如有一张分辨率为2048x1536的图片，它的配置为ARGB_8888，那么它加载到内存时的大小就是2048x1526x4/1024/1024=12M.，因此当将这张图片设置到ImageView上时，将可能出现OOM。

ARGB表示图片的配置，分表代表：透明度、红色、绿色和蓝色。这几个参数的值越高代表图像的质量越好，那么也就越占内存。就拿ARGB_8888来说，A、R、G、B这几个参数分别占8位，那么总共占32位，代表一个像素点占32位大小即4个字节，那么一个100x100分辨率的图片就占了100x100x4/1024/1024=0.04M的大小的空间。

#### 高效加载Bitmap

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

#### 缓存Bitmap

当需要加载大量的图片时，图片的缓存机制就特别重要。因为在移动端，用户大多都是使用的移动流量，如果每次都从网络获取图片，一是会耗费大量的流量，二是在网络不佳的时候加载会非常的慢，用户体验均不好。因此需要定义一种缓存策略可以应对上述问题。关于图片的缓存通常有两种：

1. 内存缓存，对应的缓存算法是LruCache<k,v>（近期最少使用算法）,Android提供了该算法。

LruCache是一个泛型类，它的内部采用一个LinkedHashMap以**强引用**的方式存储外界的缓存对象，其提供了get和put方法来完成缓存的获取和添加操作，当缓存满时，LruCache会移除较早使用的缓存对象，然后再添加新的缓存对象。

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

#### 使用Bitmap时的一些优化方法

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

### 进程分类

Android 系统将尽量长时间地保持应用进程，但为了新建进程或运行更重要的进程，最终需要清除旧进程来回收内存。 为了确定保留或终止哪些进程，系统会根据进程中正在运行的组件以及这些组件的状态，将每个进程放入“重要性层次结构”中。 必要时，系统会首先消除重要性最低的进程，然后是重要性略逊的进程，依此类推，以回收系统资源。

重要性层次结构一共有 5 级。以下列表按照重要程度列出了各类进程（第一个进程最重要，将是最后一个被终止的进程）：

#### 前台进程

目前正在屏幕上显示的进程和一些系统进程。举例来说，Dialer Storage，Google Search等系统进程就是前台进程；再举例来说，当你运行一个程序，如浏览器，当浏览器界面在前台显示时，浏览器属于前台进程 （foreground），但一旦你按home回到主界面，浏览器就变成了后台程序（background）。我们最不希望终止的进程就是前台进程。

通常，在任意给定时间前台进程都为数不多。只有在内存不足以支持它们同时继续运行这一万不得已的情况下，系统才会终止它们。 此时，设备往往已达到内存分页状态，因此需要终止一些前台进程来确保用户界面正常响应。- 

#### 可见进程

没有任何前台组件，但仍会影响用户在屏幕上所见内容的进程。 可见进程是一些不再前台，但用户依然可见的进程，举个例来说：widget、输入法等，都属于visible。这 部分进程虽然不在前台，但与我们的使用也密切相关，我们也不希望它们被终止（你肯定不希望时钟、天气，新闻等widget被终止，那它们将无法同步，你也 不希望输入法被终止，否则你每次输入时都需要重新启动输入法）

可见进程被视为是极其重要的进程，除非为了维持所有前台进程同时运行而必须终止，否则系统不会终止这些进程。

#### 服务进程

正在运行已使用 `startService()` 方法启动的服务且不属于上述两个更高类别进程的进程。尽管服务进程与用户所见内容没有直接关联，但是它们通常在执行一些用户关心的操作（例如，在后台播放音乐或从网络下载数据）。因此，除非内存不足以维持所有前台进程和可见进程同时运行，否则系统会让服务进程保持运行状态。

#### 后台进程

就是我们通常意义上理解的启动后被切换到后台的进程，如浏览器，阅读器等。当程序显示在屏幕上时，他所运行的进程即为前台进程 （foreground），一旦我们按home返回主界面（注意是按home，不是按back），程序就驻留在后台，成为后台进程 （background）。后台进程的管理策略有多种：有较为积极的方式，一旦程序到达后台立即终止，这种方式会提高程序的运行速度，但无法加速程序的再 次启动；也有较消极的方式，尽可能多的保留后台程序，虽然可能会影响到单个程序的运行速度，但在再次启动已启动的程序时，速度会有所提升。这里就需要用户 根据自己的使用习惯找到一个平衡点

#### 空进程

没有任何东西在内运行的进程，有些程序，比如BTE，在程序退出后，依然会在进程中驻留一个空进程，这个进程里没有任何数据在运行，作用往往是提高该程序下次的启动速度或者记录程序的一些历史信息。这部分进程无疑是应该最先终止的。

不含任何活动应用组件的进程。保留这种进程的的唯一目的是用作缓存，以缩短下次在其中运行组件所需的启动时间。 为使总体系统资源在进程缓存和底层内核缓存之间保持平衡，系统往往会终止这些进程。

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

而当我们运行程序的时候，有一个setContentView()方法，Activity其实不是显示视图（直观上感觉是它），实际上Activity调用了PhoneWindow的setContentView()方法，然后加载视图，将视图放到这个Window上，而Activity其实构造的时候初始化的是Window（PhoneWindow），Activity其实是个控制单元，即可视的人机交互界面。

打个比喻：

Activity是一个工人，它来控制Window；Window是一面显示屏，用来显示信息；View就是要显示在显示屏上的信息，这些View都是层层重叠在一起（通过infalte()和addView()）放到Window显示屏上的。而LayoutInfalter就是用来生成View的一个工具，XML布局文件就是用来生成View的原料

再来说说代码中具体的执行流程

setContentView(R.layout.main)其实就是下面内容。（注释掉本行执行下面的代码可以更直观）

getWindow().setContentView(LayoutInflater.from(this).inflate(R.layout.main, null))

即运行程序后，Activity会调用PhoneWindow的setContentView()来生成一个Window，而此时的setContentView就是那个最底层的View。然后通过LayoutInflater.infalte()方法加载布局生成View对象并通过addView()方法添加到Window上，（一层一层的叠加到Window上）

所以，Activity其实不是显示视图，View才是真正的显示视图

注：一个Activity构造的时候只能初始化一个Window(PhoneWindow)，另外这个PhoneWindow有一个”ViewRoot”，这个”ViewRoot”是一个View或ViewGroup，是最初始的根视图，然后通过addView方法将View一个个层叠到ViewRoot上，这些层叠的View最终放在Window这个载体上面

## Intent

### Intent的介绍

Intent的中文意思是“意图，意向”，在Android中提供了Intent机制来协助应用间的交互与通讯，Intent负责对应用中一次操作的动作、动作涉及数据、附加数据进行描述，Android则根据此Intent的描述，负责找到对应的组件，将 Intent传递给调用的组件，并完成组件的调用。Intent不仅可用于应用程序之间，也可用于应用程序内部的Activity/Service之间的交互。因此，可以将Intent理解为**不同组件之间通信的“媒介”**专门提供组件互相调用的相关信息。

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

通过这种方式我们也可以启动一个Activity，那么大家可能也注意到了，我们的清单文件中有一个category的节点，那么没有这个节点可以吗？不可以！！当我们使用这种隐式启动的方式来启动一个Activity的时候，必须要action和category都匹配上了，该Activity才会成功启动。如果我们没有定义category，那么可以暂时先使用系统默认的category，总之，category不能没有。这个时候我们可能会有疑问了，如果我有多个Activity都配置了相同的action，那么会启动哪个？看下面一张图片:

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

##### 既然单独使用Intent就可以完成数据传送了，为什么还要使用Bundle？

其实使用Intent传值实际上底层也是会产生bundle的：

```java
public Intent putExtra(String name, String value) {
        if (mExtras == null) {
            mExtras = new Bundle();
        }
        mExtras.putString(name, value);
        return this;
    }
```

如果您在ABC三个页面中传值且顺序必须是ABC，直接传递Bundle的数据就好了。而不用在 B 将数据从Intent拿出来,然后封装到新的Intent，传递到C，多此一举。

##### bundle和HashMap的区别？

bundle是根据键值对来存储数据的，既然这样，它和HashMap有什么区别呢？

- Bundle内部是由ArrayMap实现的，ArrayMap的内部实现是两个数组，一个int数组是存储对象数据对应下标，一个对象数组保存key和value，内部使用二分法对key进行排序，所以在添加、删除、查找数据的时候，都会使用二分法查找，只适合于小数据量操作，如果在数据量比较大的情况下，那么它的性能将退化。而HashMap内部则是数组+链表结构，所以在数据量较少的时候，HashMap的Entry Array比ArrayMap占用更多的内存。因为使用Bundle的场景大多数为小数据量，我没见过在两个Activity之间传递10个以上数据的场景，所以相比之下，在这种情况下使用ArrayMap保存数据，在操作速度和内存占用上都具有优势，因此使用Bundle来传递数据，可以保证更快的速度和更少的内存占用。
- 另外一个原因，则是在Android中如果使用Intent来携带数据的话，需要数据是基本类型或者是可序列化类型，HashMap使用Serializable进行序列化，而Bundle则是使用Parcelable进行序列化。而在Android平台中，更推荐使用Parcelable实现序列化，虽然写法复杂，但是开销更小，所以为了更加快速的进行数据的序列化和反序列化，系统封装了Bundle类，方便我们进行数据的传输。

## 版本问题

- compileSdkVersion ：编译所依赖的版本，它可以让我们在写代码时调用最新的api，告知我们过时的api

- minSdkVersion：最小的可安装此App的版本，意味着我们不用做低于此版本的兼容

- targetSdkVersion: 目标版本，可以让我们虽然运行在最新的手机上，但是行为和target版本一致，比如：如果targetSdkVersion小于Android 6.0，那么即使我们的app运行在6.0系统上，也不需要运行时权限

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

Android中的动画分为补间动画(Tweened Animation)和逐帧动画(Frame-by-Frame Animation)。没有意外的，补间动画是在几个关键的节点对对象进行描述由系统进行填充。而逐帧动画是在固定的时间点以一定速率播放一系列的drawable资源。下面对两种动画进行分别简要说明。

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

我们知道Handler是用来异步更新UI的，更详细的说是用来做线程间的通信的，更新UI时是子线程与UI主线程之间的通信。那么现在我们要是想子线程与子线程之间的通信要怎么做呢？当然说到底也是用Handler+Thread来完成（不推荐，需要自己操作Looper），Google官方很贴心的帮我们封装好了一个类，那就是刚才说到的：HandlerThread。（类似的封装对于多线程的场景还有AsyncTask）

HandlerThread的使用方法还是比较简单的，但是我们要明白一点的是：如果一个线程要处理消息，那么它必须拥有自己的Looper，并不是Handler在哪里创建，就可以在哪里处理消息的。

如果不用HandlerThread的话，需要手动去调用Looper.prepare()和Looper.loop()这些方法。

来看看HandlerThread的使用方法： 
首先新建HandlerThread并且执行start()

```
private HandlerThread mHandlerThread;
......
mHandlerThread = new HandlerThread("HandlerThread");
handlerThread.start();
创建Handler，使用mHandlerThread.getLooper()生成Looper：
```

```
    final Handler handler = new Handler(mHandlerThread.getLooper()){
        @Override
        public void handleMessage(Message msg) {
            System.out.println("收到消息");
        }
    };
```

然后再新建一个子线程来发送消息：

```
    new Thread(new Runnable() {
        @Override
        public void run() {
            try {
                Thread.sleep(1000);//模拟耗时操作
                handler.sendEmptyMessage(0);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
    }).start();
```

最后一定不要忘了在onDestroy释放,避免内存泄漏：

```
@Override
protected void onDestroy() {
    super.onDestroy();
    mHandlerThread.quit();
}
```

执行结果很简单，就是在控制台打印字符串：收到消息

## IntentService是什么

IntentService是Service的子类,由于Service里面不能做耗时的操作,所以Google提供了IntentService,在IntentService内维护了一个工作线程来处理耗时操作，当任务执行完后，IntentService会自动停止。另外，可以启动IntentService多次，而每一个耗时操作会以工作队列的方式在IntentService的onHandleIntent回调方法中执行，并且，每次只会执行一个工作线程，执行完第一个再执行第二个，以此类推。

使用示例：

```java
public class MyService extends IntentService {
    //这里必须有一个空参数的构造实现父类的构造,否则会报异常
    //java.lang.InstantiationException: java.lang.Class<***.MyService> has no zero argument constructor
    public MyService() {
        super("");
    }
    
    @Override
    public void onCreate() {
        System.out.println("onCreate");
        super.onCreate();
    }

    @Override
    public int onStartCommand(@Nullable Intent intent, int flags, int startId) {
        System.out.println("onStartCommand");
        return super.onStartCommand(intent, flags, startId);

    }

    @Override
    public void onStart(@Nullable Intent intent, int startId) {
        System.out.println("onStart");
        super.onStart(intent, startId);
    }

    @Override
    public void onDestroy() {
        System.out.println("onDestroy");
        super.onDestroy();
    }

    //这个是IntentService的核心方法,它是通过串行来处理任务的,也就是一个一个来处理
    @Override
    protected void onHandleIntent(@Nullable Intent intent) {
        System.out.println("工作线程是: "+Thread.currentThread().getName());
        String task = intent.getStringExtra("task");
        System.out.println("任务是 :"+task);
        try {
            Thread.sleep(2000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }
}
```

然后看看Activity里面怎么使用这个Service

```java
public class MainActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        
        Intent intent = new Intent(this,MyService.class);
        intent.putExtra("task","播放音乐");
        startService(intent);
        intent.putExtra("task","播放视频");
        startService(intent);
        intent.putExtra("task","播放图片");
        startService(intent);
    }
}
```

运行结果：

```java
14:49:31.465 18974-18974/com.dgtech.sss.intentservicedemo I/System.out: onCreate
14:49:31.467 18974-18974/com.dgtech.sss.intentservicedemo I/System.out: onStartCommand
14:49:31.467 18974-18974/com.dgtech.sss.intentservicedemo I/System.out: onStart
14:49:31.467 18974-18974/com.dgtech.sss.intentservicedemo I/System.out: onStartCommand
14:49:31.467 18974-18974/com.dgtech.sss.intentservicedemo I/System.out: onStart
14:49:31.467 18974-18974/com.dgtech.sss.intentservicedemo I/System.out: onStartCommand
14:49:31.467 18974-18974/com.dgtech.sss.intentservicedemo I/System.out: onStart
14:49:31.467 18974-19008/com.dgtech.sss.intentservicedemo I/System.out: 工作线程是:IntentService[]
14:49:31.467 18974-19008/com.dgtech.sss.intentservicedemo I/System.out: 任务是 :播放音乐
14:49:33.468 18974-19008/com.dgtech.sss.intentservicedemo I/System.out: 工作线程是: IntentService[]
14:49:33.468 18974-19008/com.dgtech.sss.intentservicedemo I/System.out: 任务是 :播放视频
14:49:35.472 18974-19008/com.dgtech.sss.intentservicedemo I/System.out: 工作线程是: IntentService[]
14:49:35.472 18974-19008/com.dgtech.sss.intentservicedemo I/System.out: 任务是 :播放图片
14:49:37.477 18974-18974/com.dgtech.sss.intentservicedemo I/System.out: onDestroy

```

从结果中可以看出我们startService()执行了三次, onCreate()方法只执行了一次,说明只有一个Service实例, onStartCommand()和onStart()也执行了三次,关键是onHandleIntent()也执行了三次,而且这三次是串行的,也就是执行完一个再执行下一个,当最后一个任务执行完, onDestroy()便自动执行了

不管使用多少个service，oncreat（）方法只会执行一次。

## AsyncTask

在android中实现异步任务有两种方法：一种为通过多线程Thread配合Handler实现，另一种就是通过android为我们提供的AsyncTask来实现。AsyncTask使得编写异步任务更加简单。

AsyncTask这个类，就是为了方便我们在后台线程中执行操作，然后将结果发送给主线程，从而在主线程中进行UI更新等操作。在使用AsyncTask时，我们无需关注ThreadHandler。AsyncTask内部会对其进行管理，这样我们就只需要关注于我们的业务逻辑即可。

**默认是一个串行的线程池SerialExecutor**

使用方法：

AsyncTask有四个重要的回调方法，分别是：onPreExecute、doInBackground, onProgressUpdate 和 onPostExecute。这四个方法会在AsyncTask的不同时期进行自动调用，我们只需要实现这几个方法的内部逻辑即可。这四个方法的一些参数和返回值都是基于泛型的，而且泛型的类型还不一样，所以在AsyncTask的使用中会遇到三种泛型参数：Params, Progress 和 Result

1.Params表示用于AsyncTask执行任务的参数的类型 
2.Progress表示在后台线程处理的过程中，可以阶段性地发布结果的数据类型 
3.Result表示任务全部完成后所返回的数据类型

onPreExecute ：运行在主线程中的。在AsyncTask执行了execute()方法后就会在UI线程上执行onPreExecute()方法，该方法在task真正执行前运行，我们通常可以在该方法中显示一个进度条，从而告知用户后台任务即将开始。

doInBackground ：该方法有WorkerThread注解，表示该方法是运行在单独的工作线程中的，而不是运行在主线程中。doInBackground会在onPreExecute()方法执行完成后立即执行，该方法用于在工作线程中执行耗时任务，我们可以在该方法中编写我们需要在后台线程中运行的逻辑代码，由于是运行在工作线程中，所以该方法不会阻塞UI线程。该方法接收Params泛型参数，参数params是Params类型的不定长数组，该方法的返回值是Result泛型，由于doInBackgroud是抽象方法，我们在使用AsyncTask时必须重写该方法。在doInBackground中执行的任务可能要分解为好多步骤，每完成一步我们就可以通过调用AsyncTask的publishProgress(Progress…)将阶段性的处理结果发布出去，阶段性处理结果是Progress泛型类型。当调用了publishProgress方法后，处理结果会被传递到UI线程中，并在UI线程中回调onProgressUpdate方法。根据我们的具体需要，我们可以在doInBackground中不调用publishProgress方法，当然也可以在该方法中多次调用publishProgress方法。doInBackgroud方法的返回值表示后台线程完成任务之后的结果。

onProgressUpdate ：当我们在doInBackground中调用publishProgress(Progress…)方法后，就会在UI线程上回调onProgressUpdate方法，该方法是在主线程上被调用的，且传入的参数是Progress泛型定义的不定长数组。如果在doInBackground中多次调用了publishProgress方法，那么主线程就会多次回调onProgressUpdate方法。

onPostExecute ：该方法也具有MainThread注解，表示该方法是在主线程中被调用的。当doInBackgroud方法执行完毕后，就表示任务完成了，doInBackgroud方法的返回值就会作为参数在主线程中传入到onPostExecute方法中，这样就可以在主线程中根据任务的执行结果更新UI。

Asynctask有什么优缺点？ 
使用的优点: 简单快捷，过程可控 
使用的缺点: 在使用多个异步操作和并需要进行Ui变更时,就变得复杂起来.

AsyncTask对象必须在主线程中创建 
AsyncTask对象的execute方法必须在主线程中调用 
一个AsyncTask对象只能调用一次execute方法

可定制化程度不高，例如我们不能很方便地cancel线程

内存泄漏，同Handler一样，非静态内部类持有外部类的引用导致内存泄漏
AsyncTask的生命周期和Activity是不一致的，需要在Activity的onDestory方法中调用AsyncTask的cancle方法，取消任务执行。否则可能会导致崩溃。
结果丢失：同上一条，在屏幕旋转或者activity在内存不够时，被系统杀掉，此时AsyncTask持有的Activity已经失效，调用更新UI的方法则会失效。

并行或串行（可以调用executeOnExecutor来执行并行任务）：建议只用串行，避免多线程运行影响线程池的稳定性 。

### 原理解读

比较适用于一些耗时比较短的任务，内部封装了线程池，实现原理是FutureTask+Callable +SerialExecutor （线程池）。
 整个流程，在AsyncTask的构造方法中 ，会创建Future对象跟Callable对象，然后在execute方法中会执行onPreExecute()方法跟doInBackground方法，而doInbackground 的结果，会被封装成一个Message，再通过handler来进行线程间通信，通过message.what来识别是否需要调用onProgressUpdate，或是finish方法 。finish方法里面会调用onPostExecute方法 。
 另外我们可以通过publishProgress()方法来主动调用onProgressUpdate()方法，内部也是通过这个方法，来发出一个这样的message去调用onProgressUpdate的。

## 常用开源框架

### LeakCanry

LeakCanary是一个检测内存泄露的开源类库，以可视化的方式 轻松检测内存泄露，并且在出现内存泄漏时及时通知开发者，省去手工分析hprof的过程。

这里可能会穿插问到android中内存泄漏的常见原因以及避免方法。

#### 原理

- 在Application中注册一个`ActivityLifecycleCallbacks`来监听Activity的销毁

- 通过`IdleHandler`在主线程空闲时进行检测（`IdleHandler `可以用来提升性能，主要用在我们希望能够在当前线程消息队列空闲时做些事情，譬如 UI 线程在显示完成后，如果线程空闲我们就可以提前准备其他内容的情况下，不过最好不要做耗时操作。）

- 检测是通过WeakReference实现的，如果没有被回收会再次调用gc再确认一遍

- 确认有泄漏后，dump hprof文件，并开启一个进程IntentService通过HAHA进行分析

IntentService是Service的子类,由于Service里面不能做耗时的操作,所以Google提供了IntentService,在IntentService内维护了一个工作线程来处理耗时操作，当任务执行完后，IntentService会自动停止。另外，可以启动IntentService多次，而每一个耗时操作会以工作队列的方式在IntentService的onHandleIntent回调方法中执行，并且，每次只会执行一个工作线程，执行完第一个再执行第二个，以此类推。

### OkHttp（基于3.9版本）

------

#### [使用](https://link.juejin.im?target=http%3A%2F%2Fliuwangshu.cn%2Fapplication%2Fnetwork%2F5-okhttp2x.html)

##### 1. 在gradle中添加依赖

```
compile 'com.squareup.okhttp3:okhttp:3.9.0'
compile 'com.squareup.okio:okio:1.13.0'
复制代码
```

##### 2. 创建OkHttpClient，并对timeout等进行设置

```
File sdcache = getExternalCacheDir();
int cacheSize = 10 * 1024 * 1024;
OkHttpClient.Builder builder = new OkHttpClient.Builder()
        .connectTimeout(15, TimeUnit.SECONDS)
        .writeTimeout(20, TimeUnit.SECONDS)
        .readTimeout(20, TimeUnit.SECONDS)
        .cache(new Cache(sdcache.getAbsoluteFile(), cacheSize));
OkHttpClient mOkHttpClient=builder.build();
复制代码
```

##### 3. 创建Request

- get请求

```
Request request = new Request.Builder()
            .url("http://www.baidu.com")
            .build();
复制代码
```

- post请求（post需要传入requsetBody）

```
RequestBody formBody = new FormEncodingBuilder()
            .add("size", "10")
            .build();
    Request request = new Request.Builder()
            .url("http://api.1-blog.com/biz/bizserver/article/list.do")
            .post(formBody)
            .build();
复制代码
```

##### 4. 创建Call并执行（okHttp的返回结果并没有在ui线程）

```
Call call = mOkHttpClient.newCall(request);
复制代码
```

- 同步执行

```
Response mResponse=call.execute();
        if (mResponse.isSuccessful()) {     
           return mResponse.body().string();
       } else {
           throw new IOException("Unexpected code " + mResponse);
       }
复制代码
```

- 异步执行

```
call.enqueue(new Callback() {
        @Override
        public void onFailure(Request request, IOException e) {
        }
        @Override
        public void onResponse(Response response) throws IOException {
            String str = response.body().string();
            Log.i("wangshu", str);
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    Toast.makeText(getApplicationContext(), "请求成功", Toast.LENGTH_SHORT).show();
                }
            });
        }
    });
复制代码
```

##### 5. 封装

因为以下原因，所以我们需要封装：

- 避免重复代码编写
- 请求的回调改为UI线程
- 其他需要的逻辑：例如加解密等

#### OkHttp中的设计模式

1. Builder模式：OkHttpClient 和Request等都是通过Builder模式创建的
2. 责任链模式：拦截器通过责任链模式进行工作
3. 门面模式：整体采用门面模式，OkHttpClient为门面，向子系统委派任务
4. 享元模式：连接池等采用了享元模式
5. 其他：工厂模式、代理模式等

#### [源码分析](https://link.juejin.im?target=http%3A%2F%2Fliuwangshu.cn%2Fapplication%2Fnetwork%2F7-okhttp3-sourcecode.html)

##### 1. Call

- Call的实现类为RealCall
- 在执行execute或者enqueue时，会取出okHttpClient中的Dispatcher执行对应的方法

```
client.dispatcher().enqueue(new AsyncCall(responseCallback, forWebSocket));
复制代码
```

##### 2. Diapatcher

- Diapatcher在OkHttpClient build时进行初始化
- Dispatcher负责进行任务调度，内部维护一个线程池，处理并发请求
- Dispatcher内部有三个队列

```
/** 将要运行的异步请求队列 */
private final Deque<AsyncCall> readyAsyncCalls = new ArrayDeque<>();
/**正在运行的异步请求队列 */
private final Deque<AsyncCall> runningAsyncCalls = new ArrayDeque<>();
/** 正在运行的同步请求队列 */
private final Deque<RealCall> runningSyncCalls = new ArrayDeque<>();
复制代码
```

- 执行时，线程会调用AsyncCall的excute方法

##### 3. AsyncCall

- AsyncCall是RealCall的一个内部类，实现了Runnalbe接口
- AsyncCall 通过 getResponseWithInterceptorChain方法取得Response
- 执行完毕后通过client.dispatcher().finished(this)；将自身从dispatcher队列中取出，并取出下一个加入相应队列

```
//AsyncCall 的excute方法
@Override protected void execute() {
  boolean signalledCallback = false;
  try {
    Response response = getResponseWithInterceptorChain(forWebSocket);
    if (canceled) {
      signalledCallback = true;
      responseCallback.onFailure(RealCall.this, new IOException("Canceled"));
    } else {
      signalledCallback = true;
      responseCallback.onResponse(RealCall.this, response);
    }
  } catch (IOException e) {
    if (signalledCallback) {
      // Do not signal the callback twice!
      logger.log(Level.INFO, "Callback failure for " + toLoggableString(), e);
    } else {
      responseCallback.onFailure(RealCall.this, e);
    }
  } finally {
    client.dispatcher().finished(this);
  }
}

复制代码
```

##### 4. getResponseWithInterceptorChain

getResponseWithInterceptorChain是用责任链的方式，执行拦截器，对请求和请求结果进行处理

- getResponseWithInterceptorChain 中创建拦截器，并创建第一个RealInterceptorChain，执行其proceed方法

```
Response getResponseWithInterceptorChain() throws IOException {
    // Build a full stack of interceptors.
    List<Interceptor> interceptors = new ArrayList<>();
    interceptors.addAll(client.interceptors());
    interceptors.add(retryAndFollowUpInterceptor);
    interceptors.add(new BridgeInterceptor(client.cookieJar()));
    interceptors.add(new CacheInterceptor(client.internalCache()));
    interceptors.add(new ConnectInterceptor(client));
    if (!forWebSocket) {
      interceptors.addAll(client.networkInterceptors());
    }
    interceptors.add(new CallServerInterceptor(forWebSocket));

    Interceptor.Chain chain = new RealInterceptorChain(interceptors, null, null, null, 0,
        originalRequest, this, eventListener, client.connectTimeoutMillis(),
        client.readTimeoutMillis(), client.writeTimeoutMillis());

    return chain.proceed(originalRequest);
  }
复制代码
```

- RealInterceptorChain的proceed方法中，会取出拦截器，并创建下一个Chain，将其作为参数传给拦截器的intercept方法

```
  // If there's another interceptor in the chain, call that.
  if (index < client.interceptors().size()) {
    Interceptor.Chain chain = new ApplicationInterceptorChain(index + 1, request, forWebSocket);
    //从拦截器列表取出拦截器
    Interceptor interceptor = client.interceptors().get(index);
    Response interceptedResponse = interceptor.intercept(chain);

    if (interceptedResponse == null) {
      throw new NullPointerException("application interceptor " + interceptor
          + " returned null");
    }

    return interceptedResponse;
  }

  // No more interceptors. Do HTTP.
  return getResponse(request, forWebSocket);
}

复制代码
```

#### 拦截器

##### 1. [自定义拦截器](https://link.juejin.im?target=https%3A%2F%2Fwww.jianshu.com%2Fp%2Fd04b463806c8)

- 自定义拦截器分为两类，interceptor和networkInterceptor（区别：networkInterceptor处理网络相关任务，如果response直接从缓存返回了，那么有可能不会执行networkInterceptor）
- 自定义方式：实现Interceptor，重写intercept方法，并注册拦截器

##### 2. [系统拦截器](https://link.juejin.im?target=https%3A%2F%2Fblog.csdn.net%2Flepaitianshi%2Farticle%2Fdetails%2F72457928)

- RetryAndFollowUpInterceptor：进行失败重试和重定向
- BridgeInterceptor：添加头部信息
- CacheInterceptor：处理缓存
- ConnectInterceptor：获取可用的connection实例
- CallServerInterceptor：发起请求

#### [连接池复用](https://link.juejin.im?target=http%3A%2F%2Fliuwangshu.cn%2Fapplication%2Fnetwork%2F8-okhttp3-sourcecode2.html)

在ConnectInterceptor中，我们获取到了connection的实例，该实例是从ConnectionPool中取得

##### 1. Connection

- Connection 是客户端和服务器建立的数据通路，一个Connection上可能存在几个链接
- Connection的实现类是RealConnection，是socket物理连接的包装
- Connection内部维持着一个List<Reference>引用

##### 2. StreamAllocation

StreamAllocation是Connection维护的连接，以下是类内注解

```
 <ul>
 *     <li><strong>Connections:</strong> physical socket connections to remote servers. These are
 *         potentially slow to establish so it is necessary to be able to cancel a connection
 *         currently being connected.
 *     <li><strong>Streams:</strong> logical HTTP request/response pairs that are layered on
 *         connections. Each connection has its own allocation limit, which defines how many
 *         concurrent streams that connection can carry. HTTP/1.x connections can carry 1 stream
 *         at a time, HTTP/2 typically carry multiple.
 *     <li><strong>Calls:</strong> a logical sequence of streams, typically an initial request and
 *         its follow up requests. We prefer to keep all streams of a single call on the same
 *         connection for better behavior and locality.
 * </ul>
复制代码
```

##### 3. ConnectionPool

ConnectionPool通过Address等来查找有没有可以复用的Connection，同时维护一个线程池，对Connection做回收工作

### Retrofit

------

Retrofit帮助我们对OkHttp进行了封装，使网络请求更加方便

#### [使用](https://link.juejin.im?target=https%3A%2F%2Fwww.jianshu.com%2Fp%2Fa3e162261ab6)

##### 1. 添加依赖

```
dependencies {
    compile 'com.squareup.retrofit2:retrofit:2.0.2'
  }
复制代码
```

##### 2. 创建Retrofit实例

```
Retrofit retrofit = new Retrofit.Builder() 
 .baseUrl("http://fanyi.youdao.com/") // 设置网络请求的Url地址
 .addConverterFactory(GsonConverterFactory.create()) // 设置数据解析器 
 .addCallAdapterFactory(RxJavaCallAdapterFactory.create()) // 支持RxJava平台 .build();
复制代码
```

##### 3. 创建网络接口

```
@GET("user")
Call<User> getUser(@Header("Authorization") String authorization)
复制代码
```

##### 4. 创建Call

```
 GetRequest_Interface request = retrofit.create(GetRequest_Interface.class);
//对 发送请求 进行封装
Call<Reception> call = request.getCall();
复制代码
```

##### 5. 执行Call的请求方法

```
//发送网络请求(异步) call.enqueue(new Callback<Translation>() { 
//请求成功时回调
 @Override 
public void onResponse(Call<Translation> call, Response<Translation> response) { 
   //请求处理,输出结果
    response.body().show(); 
 } 
 //请求失败时候的回调 
 @Override 
 public void onFailure(Call<Translation> call, Throwable throwable) { 
     System.out.println("连接失败"); 
 } 
 });
 
 // 发送网络请求（同步） Response<Reception> response = call.execute();

复制代码
```

#### [源码解析](https://link.juejin.im?target=https%3A%2F%2Fwww.jianshu.com%2Fp%2F0c055ad46b6c)

##### 1. Retrofit

Retrofit 通过builder模式创建，我们可以对其进行各种设置：

- baseUrl：请求地址的头部，必填
- callFactory：网络请求工厂（不进行设置的话默认会生成一个OkHttpClient）
- adapterFactories：网络请求适配器工厂的集合，这里有适配器因为Retrofit不仅支持Android，还支持Ios等其他平台（不进行设置的话会根据平台自动生成）
- converterFactories：数据转换器工厂的集合（将网络返回的数据转换成我们需要的类）
- callbackExecutor：回调方法执行器（Android平台默认通过Handler发送到主线程执行）

##### 2. Call

我们的每个method对应一个Call， Call的创建分为两步：

- retorfit.create(myInfterfaceClass.class)创建我们网络请求接口类的实例
- 调用对应方法拿到对应网络请求的Call

关键在第一步，第一步是通过动态代理实现的

```
public <T> T create(final Class<T> service) {
  Utils.validateServiceInterface(service);
  if (validateEagerly) {
    eagerlyValidateMethods(service);
  }
  return (T) Proxy.newProxyInstance(service.getClassLoader(), new Class<?>[] { service },
      new InvocationHandler() {
        private final Platform platform = Platform.get();

        @Override public Object invoke(Object proxy, Method method, Object... args)
            throws Throwable {
          // If the method is a method from Object then defer to normal invocation.
          if (method.getDeclaringClass() == Object.class) {
            return method.invoke(this, args);
          }
          if (platform.isDefaultMethod(method)) {
            return platform.invokeDefaultMethod(method, service, proxy, args);
          }
          ServiceMethod serviceMethod = loadServiceMethod(method);//1
          OkHttpCall okHttpCall = new OkHttpCall<>(serviceMethod, args);
          return serviceMethod.callAdapter.adapt(okHttpCall);
        }
      });
}
复制代码
```

- 通过loadServiceMethod方法生成mehtod对应的ServiceMethod
- 将ServiceMethod和方法参数传进OkHttpCall生成OkHttpCall
- 调用callAdapter方法对OkHttpCall进行处理并返回

##### 1. ServiceMethod

loadServiceMethod方法会首先在缓存里查找是否有该method对应的ServiceMethod，没有的话调用build方法创建一个

```
ServiceMethod loadServiceMethod(Method method) {
 ServiceMethod result; 
 // 设置线程同步锁 
 synchronized (serviceMethodCache) { 
 result = serviceMethodCache.get(method);
  // ServiceMethod类对象采用了单例模式进行创建 
  // 即创建ServiceMethod对象前，先看serviceMethodCache有没有缓存之前创建过的网络请求实例 
  // 若没缓存，则通过建造者模式创建 
  serviceMethod 对象 if (result == null) { 
  // 下面会详细介绍ServiceMethod生成实例的过程 
  result = new ServiceMethod.Builder(this, method).build(); 
  serviceMethodCache.put(method, result); 
   } 
  }
   
  return result;
}

复制代码
```

ServiceMethod的创建过程即是对method的解析过程，解析过程包括：对注解的解析，寻找合适的CallAdapter和Convert等

##### 2. OkHttpCall

OkHttpCall实现了Call接口，当执行excute或enqueue请求命令时，内部通过传入的CallFactory（OkHttpClient）执行网络请求

##### 3. callAdapter

如果我们没有对CallAdapter进行设置，它的值将是Android平台的默认设置，其adapt方法如下

```
public <R> Call<R> adapt(Call<R> call) { 
    return new ExecutorCallbackCall<>(callbackExecutor, call); 
} 


ExecutorCallbackCall(Executor callbackExecutor, Call<T> delegate) {

 this.delegate = delegate; 
 // 把上面创建并配置好参数的OkhttpCall对象交给静态代理delegate 
 // 静态代理和动态代理都属于代理模式 
 // 静态代理作用：代理执行被代理者的方法，且可在要执行的方法前后加入自己的动作，进行对系统功能的拓展 
 
 this.callbackExecutor = callbackExecutor; 
 // 传入上面定义的回调方法执行器 
 // 用于进行线程切换 }

复制代码
```

ExecutorCallbackCall对OkHttpCall进行了装饰，会调用CallBackExcutor对OkHttpCall执行的返回结果进行处理，使其位于主线程

#### [自定义Convert和CallAdapter](https://link.juejin.im?target=https%3A%2F%2Fwww.jianshu.com%2Fp%2F308f3c54abdd)

### [Fresco](https://link.juejin.im?target=https%3A%2F%2Fwww.fresco-cn.org%2F)

------

Fresco是一个图片加载库，可以帮助我们加载图片显示，控制多线程，以及管理缓存和内存等

#### [Fresco使用](https://link.juejin.im?target=https%3A%2F%2Fwww.fresco-cn.org%2Fdocs%2Findex.html)

引入依赖

```
dependencies {
  // 其他依赖
  compile 'com.facebook.fresco:fresco:0.12.0'
   // 在 API < 14 上的机器支持 WebP 时，需要添加
  compile 'com.facebook.fresco:animated-base-support:0.12.0'

  // 支持 GIF 动图，需要添加
  compile 'com.facebook.fresco:animated-gif:0.12.0'

  // 支持 WebP （静态图+动图），需要添加
  compile 'com.facebook.fresco:animated-webp:0.12.0'
  compile 'com.facebook.fresco:webpsupport:0.12.0'

  // 仅支持 WebP 静态图，需要添加
  compile 'com.facebook.fresco:webpsupport:0.12.0'
}

复制代码
```

初始化

```
Fresco.initialize(Context context);
复制代码
```

使用SimpleView

```
<com.facebook.drawee.view.SimpleDraweeView
    android:id="@+id/my_image_view"
    android:layout_width="130dp"
    android:layout_height="130dp"
    fresco:placeholderImage="@drawable/my_drawable"
  />
复制代码
```

加载图片

```
Uri uri = Uri.parse("https://raw.githubusercontent.com/facebook/fresco/gh-pages/static/logo.png");
SimpleDraweeView draweeView = (SimpleDraweeView) findViewById(R.id.my_image_view);
draweeView.setImageURI(uri);

复制代码
```



以上是Fresco的基本加载流程，此外，我们可以定制加载和显示的各个环节

Fresco由两部分组成，Drawees负责图片的呈现，ImagePipeline负责图片的下载解码和内存管理

#### [Drawees](https://link.juejin.im?target=https%3A%2F%2Fwww.fresco-cn.org%2Fdocs%2Fconcepts.html)

Drawees 负责图片的呈现。它由三个元素组成，有点像MVC模式。

##### DraweeView

- 继承于 View, 负责图片的显示。
- 一般情况下，使用 SimpleDraweeView 即可。 你可以在 XML 或者在 Java 代码中使用它，通过 setImageUri 给它设置一个 URI 来使用，这里有简单的入门教学：开始使用
- 你可以使用 XML属性来达到各式各样的效果。

##### DraweeHierarchy

- DraweeHierarchy 用于组织和维护最终绘制和呈现的 Drawable 对象，相当于MVC中的M。
- 你可以通过它来在Java代码中自定义图片的展示

##### DraweeController

- DraweeController 负责和 image loader 交互（ Fresco 中默认为 image pipeline, 当然你也可以指定别的），可以创建一个这个类的实例，来实现对所要显示的图片做更多的控制。
- 如果你还需要对Uri加载到的图片做一些额外的处理，那么你会需要这个类的。

##### DraweeControllerBuilder

- DraweeControllers 由 DraweeControllerBuilder 采用 Builder 模式创建，创建之后，不可修改。具体参见: 使用ControllerBuilder。

##### Listeners

- 使用 ControllerListener 的一个场景就是设置一个 Listener监听图片的下载。

#### ImagePipeline

- Fresco 的 Image Pipeline 负责图片的获取和管理。图片可以来自远程服务器，本地文件，或者Content Provider，本地资源。压缩后的文件缓存在本地存储中，Bitmap数据缓存在内存中。
- 在5.0系统以下，Image Pipeline 使用 pinned purgeables 将Bitmap数据避开Java堆内存，存在ashmem中。这要求图片不使用时，要显式地释放内存
- SimpleDraweeView自动处理了这个释放过程，所以没有特殊情况，尽量使用SimpleDraweeView，在特殊的场合，如果有需要，也可以直接控制Image Pipeline。
- ImagePipeline加载图片流程

> 1. 检查内存缓存，如有，返回

1. 后台线程开始后续工作
2. 检查是否在未解码内存缓存中。如有，解码，变换，返回，然后缓存到内存缓存中。
3. 检查是否在磁盘缓存中，如果有，变换，返回。缓存到未解码缓存和内存缓存中。
4. 从网络或者本地加载。加载完成后，解码，变换，返回。存到各个缓存中。

#### ImagePipeline的线程池

Image pipeline 默认有3个线程池:

> 1. 3个线程用于网络下载

1. 2个线程用于磁盘操作: 本地文件的读取，磁盘缓存操作。
2. 2个线程用于CPU相关的操作: 解码，转换，以及后处理等后台操作。

#### ImagePipeline的 缓存

ImagePipeLine有三级缓存

> 1. 解码后的Bitmap缓存
> 2. 未解码图片的内存缓存
> 3. 磁盘缓存

#### [对比](https://link.juejin.im?target=https%3A%2F%2Fwww.jianshu.com%2Fp%2F6729dc17586b)

##### 功能

Fresco 相对于Glide/Picaso等拥有更多的功能，如图片的渐进式加载/动图/圆角等，

##### 性能

Fresco采用三级缓存：

> 1. 解码后的Bitmap缓存
> 2. 未解码图片的内存缓存
> 3. 磁盘缓存

Glide两级缓存：

> 1. 根据ImageView控件尺寸获得对应的大小的bitmap来展示，可以缓存原始数据或者resize后数据
> 2. 磁盘缓存

##### 使用

Fresco通过CloseableReference管理图片，通过图片控件DraweeView来显示图片和控制图片释放，虽然扩展性高，但是扩展起来麻烦；对项目有一定侵入性

### EventBus

------

EventBus使用了观察者模式，方便我们项目中进行数据传递和通信

#### [使用](https://link.juejin.im?target=https%3A%2F%2Fwww.jianshu.com%2Fp%2Facfe78296bb5)

添加依赖

```
compile 'org.greenrobot:eventbus:3.0.0'
复制代码
```

注册和解绑

```
EventBus.getDefault().register(this);

EventBus.getDefault().unregister(this);
复制代码
```

添加订阅消息方法

```
@Subscribe(threadMode = ThreadMode.MAIN) 
public void onEvent(MessageEvent event) {
    /* Do something */
}
复制代码
```

发送消息

```
EventBus.getDefault().post(new MessageEvent("Hello !....."));
    
复制代码
```

##### @Subscribe注解

该注解内部有三个成员，分别是threadMode、sticky、priority。

> 1. threadMode代表订阅方法所运行的线程
> 2. sticky代表是否是粘性事件
> 3. priority代表优先级

##### threadMode

> 1. POSTING:表示订阅方法运行在发送事件的线程。
> 2. MAIN：表示订阅方法运行在UI线程，由于UI线程不能阻塞，因此当使用MAIN的时候，订阅方法不应该耗时过长。
> 3. BACKGROUND：表示订阅方法运行在后台线程，如果发送的事件线程不是UI线程，那么就使用该线程；如果发送事件的线程是UI线程，那么新建一个后台线程来调用订阅方法。
> 4. ASYNC：订阅方法与发送事件始终不在同一个线程，即订阅方法始终会使用新的线程来运行。

##### sticky 粘性事件

在注册之前便把事件发生出去，等到注册之后便会收到最近发送的粘性事件（必须匹配）。注意：只会接收到最近发送的一次粘性事件，之前的会接受不到,demo

#### [源码解析](https://link.juejin.im?target=https%3A%2F%2Fwww.jianshu.com%2Fp%2Fbda4ed3017ba)

参见链接

##### [性能](https://link.juejin.im?target=https%3A%2F%2Fsegmentfault.com%2Fa%2F1190000005089229)

1. EventBus通过反射的方式对@Subscribe方法进行解析。
2. 默认情况下，解析是运行时进行的，但是我们也可以通过设置和加载依赖库，使其编译时形成索引，其性能会大大提升





