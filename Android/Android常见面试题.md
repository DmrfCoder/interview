# Android常见面试题

[TOC]



## 什么是ANR，如何避免

ANR的全称是`Application Not Responsing`，即我们俗称的应用无响应。

要想知道如何避免ANR，就有必要了解哪些情况下会导致ANR，常见的以下几种情况都会导致ANR：

- 主线程中被IO操作（从Android4.0以后不允许网络IO操作在主线程中）
- 主线程中存在耗时操作
- 主线程中存在错误操作，比如Thread.wait或者Thread.sleep

Android系统会监控程序的响应情况，一旦出现以下两种情况就会弹出ANR对话框：

- 应用程序超过5s没有响应用户输入事件（比如按键或者触摸）
- BroadCastReceiver未在10s内完成相关操作

那么对应的避免ANR的基本思路就是避免IO操作在主线程中，避免在主线程中进行耗时操作，避免主线程中的错误操作等，具体的方法有如下几种：

- 使用AsyncTask处理耗时IO操作
- 使用Handler处理线程处理结果，而不是使用Thread.sleep或者Thread.wait来堵塞线程
- Activity的onCreat和onResume方法中尽量避免进行耗时操作
- BroadcastReceiver中的onReceive中也应该避免耗时操作，建议使用intentService处理

## ListView原理与优化

ListView最大的优点就是在于即使在ListView中加载非常非常多的数据，比如达到成百上千条甚至更多，ListView都不会发生OOM或者崩溃，而且随着我们手指滑动来浏览更多数据时，程序所占用的内存竟然都不会跟着增长。

而实现这种效果的原理也十分简单，就是基于Recycle机制，比如现在listview有10w个条项，那么它不会同时把这10w个条项同时加载进来，而是只讲用户可见的若干个条项加载进来，而且会进行循环利用，比如用户当前划出了一个view1，与此同时进来了一个view2，那么当view1划出可见区的同时它会被标记为recycle，这样做的好处是当新进入的view2与view1类型相同的时候getView方法传入的contentView就不是null而是view1，否则会传入null，此时需要new一个View，当内存紧张的时候View1就会被GC。这就是Listview的大概原理。

补充的一点是Adapter在listview中的作用，view负责的是将数据展示出来，而adapter负责的就是把数据加载进来，其指挥了ListView的数据加载行为，二者的关系类似于mvc中的v和c。

而listview的优化主要是在缓存上采取处理，listview的优化分为三级缓存：

- 内存缓存
- 文件缓存
- 网络加载

以listview加载Bitmap为例：

比如一个10w个条目的listview，每个item中都有一张照片，不同item的照片可能相同，那么优化的策略是在getview中，如果需要加载一张照片，先从MemoryCache中去找，如果找不到就去文件系统中找，如果文件系统中还找不到再从网络加载，同时从网络上加载完之后应把当前图片进行缓存，机制是首先考虑放入map类型的MemoryCache中，如果内存不够了不能放入内存中了，则给该图片打上TAG存入文件系统中，这样下次需要加载该图片的时候就可以从之前的缓存中加载出来。

同时有几个细节需要注意：

- 从文件中加载虽然比从网络加载快，但是比从内存中加载慢，所以应该设立busy位，当listview处于滚动状态时停止加载，这样可以环节listview的滚动卡顿问题（如何判断listview当前是否是滚动状态：通过setOnScrollListener？）
- 应该在子线程中加载图片，防止listview变卡
- 开启网络等耗时操作应该开启新的线程，应使用线程池避免资源浪费，最起码也应该使用AsyncTask
- 从网络加载的Bitmap最好先缓存入文件系统，这样做既可以方便下次加载时直接通过Url加载到，也可以方便在加载时使用Option.inSampleSize配合Bitmap.decodeFile进行内存压缩



## ContentProvider实现原理

`ContentProvider`的底层是采用 `Android`中的`Binder`机制，既然已经有了binder实现了进程间通信了为什么还会需要contentProvider？

contentprovider是一种进程间数据交互&共享的方式，当然它也可以进行进程内通信，但是一般不会“杀鸡用牛刀”用contentProvider作为进程内通信的方式。Android系统中，每一个应用程序只可以访问自己创建的数据。然而，有时候我们需要在不同的应用程序之间进行数据共享，例如很多程序都需要访问通讯录中的联系人信息来实现自己的业务功能。由于通讯录本身是一个独立的应用程序，因此，其他应用程序是不能直接访问它的联系人信息的，这时候就需要使用Content Provider组件来共享通讯录中的联系人信息了。从垂直的方向来看，一个软件平台至少由数据层、数据访问层、业务层构成。在Android系统中，数据层可以使用数据库、文件或者网络来实现，业务层可以使用一系列应用来实现，而数据访问层可以使用Content Provider组件来实现。在这个软件平台架构中，为了降低业务层中各个应用之间的耦合度，每一个应用都使用一个Android应用程序来实现，并且它们都是运行在独立的进层中。同样，为了降低业务层和数据层的耦合度，我们也将数据访问层即Content Provider组件运行在一个独立的应用程序进程中。通过这样的划分，Content Provider组件就可以按照自己的方式来管理平台数据，而上层的Android应用程序不需要关心它的具体实现，只要和它约定好数据访问接口就行了。

不同的应用程序进程可以通过Binder进程间通信的机制来通信，但如果在传输的数据量很大的时候，直接使用Binder进程间通信机制传递数据，那么数据传输效率就会成为问题。不同的应用程序进程可以通过匿名共享内存来传输大数据，因为无论多大的数据，对匿名共享内存来说，需要在进程间传递的仅仅是一个文件描述符而已。这样，结合Binder进程间通信机制以及匿名共享内存机制，Content Provider组件就可以高效地将它里面的数据传递给业务层中的Android应用程序访问了。

比如应用A想要暴露一部分数据给其他的应用操作，那么我们可以在应用A中自定义一个继承了contentProvider**抽象类** 的类，选择性重写其insert（增）、delete（删）、update（改）、Cursor query（查）以暴露出数据访问的接口给其他应用，然后在manifest文件中注册该contentProvider，注册的时候指定**authorities**，该**authorities**应该是全局唯一的，同时在manifest中声明一下权限，这样就完成了应用A中提供数据访问接口的工作，那么对于另外一个应用B如果想要操作A应用暴露出的数据，首先需要在manifest中声明一下权限，然后需要在其Activity中使用getContentResolver()方法获取一个contentResolver对象，该对象可以调用insert（增）、delete（删）、update（改）、Cursor query（查）四个方法，每个方法需要传入一个Uri参数，因为只有指定了Uri，该contentRecover才知道应该去访问哪一个contentProvider提供的数据访问接口，Uri的格式是固定的，一般格式是Uri uri_user = Uri.parse("content://authorities/表名/记录")，这样就实现了B访问A中的数据即跨进程通信。

## 为什么要使用通过`ContentResolver`类从而与`ContentProvider`类进行交互，而不直接访问`ContentProvider`类？

一般来说，一款应用要使用多个`ContentProvider`，若需要了解每个`ContentProvider`的不同实现从而再完成数据交互，**操作成本高 & 难度大**。所以再`ContentProvider`类上加多了一个 `ContentResolver`类对所有的`ContentProvider`进行统一管理。



## 介绍Binder机制

Binder是Android中的一种跨进程通信机制，Android是基于Linux的，所有的用户线程工作在不同的用户空间下，互相不能访问，但是他们都共享内核空间，所以传统的跨进程通信可以先从A进程的用户空间拷贝数据到内核空间，再将数据从内核空间拷贝到B进程的用户空间，这样做需要拷贝两次数据，效率太低，而Binder机制应用了内存映射的原理，其通过Binder驱动（位于内核空间）将A进程、B进程以及serviceManager连接起来，通过serviceManager来管理Service的注册与查询，在Android中Binder驱动和serviceManager都属于Android基础架构即Android系统已经帮我们实现好了，我们只需要自定义A进程和B进程，使其调用注册服务、获取服务&使用服务三个步骤即可，具体的实现方法如下：





## 如何自定义View，如果要实现一个转盘圆形的View，需要重写View中的哪些方法？

自定义View一般是继承View或者ViewGroup，然后重点是以下几个方法：

- 构造函数，这个方法的主要功能是获取view的基本参数，有四个不同参数列表的构造方法，我们一般只会用到前两种，第一种构造方法只有一个context参数，一般是使用java代码new出该view时会调用，第二种构造方法有一个context参数和一个AttributeSet参数，主要是在xml文件中使用到该view时会调用，通过AttributeSet参数获取到xml文件中定义的各种参数
- onMeasure，这个方法的主要作用是测量view的大小，而measure的执行过程也要分情况，如果是一个原始的View，只需要通过measure方法就可以完成，如果是一个ViewGroup，则除了完成自己的measure之外还需要遍历调用所有子view的measure方法
- onSizeChanged(int w, int h, int oldw, int oldh)方法，这个方法的作用是确定view的大小，虽然我们已经在onMeasure中测量到了view的大小，可是实际中view的大小不仅与自己有关，还与父View的大小有关，所以我们在确定View大小的时候最好使用系统提供的onSizeChanged回调函数。
- onLayout(boolean changed, int left, int top, int right, int bottom)，一般如果是继承ViewGroup的话需要重写这个方法，做法是首先获取到各个子view，然后计算出各个子view的位置，再调用子view的layout（left, top, right, bottom）方法设置子view的位置
- onDraw(Canvas canvas) 方法，主要是根据自己的需求通过canvas进行绘制

## Android事件分发机制

Android事件分发机制的对象是点击事件，本质是将点击事件（MotionEvent）传递到某个具体的View & 处理的整个过程，当用户触摸屏幕时将产生点击事件，而点击事件的相关细节被封装成MotionEvent对象，其对应的事件类型有4种：ACTION_DOWN、ACTION_UP、ACTION_MOVE、ACTION_CANCEL（非人为因素导致的结束事件），事件分发的顺序是Activity—>viewGroup—>View,其中涉及到三个主要的方法：dispatchTouchEvent、onInterceptTouchEvent、onTouchEvent，分别对应事件分发、事件拦截、事件响应，如果事件被分发给了当前view，则一定会调用该view的dispatchTouchEvent方法，在该方法中首先调用onInterceptTouchEvent方法判断当前view是否应该拦截该事件，如果确定当前View需要拦截该事件，则调用当前View的onTouchEvent进行事件响应，如果判断当前view不应该拦截该事件，则调用其子view的dispatchTouchEvent方法将该事件分发给其子View，以此类推。

`ViewGroup`默认不拦截任何事件。Android源码中`ViewGroup`的`onInterceptTouchEvent`方法默认返回false。

**View没有onIntercepteTouchEvent方法，一旦有点击事件传递给它，那么它的onTouchEvent方法就会被调用**。



## Socket和LocalSocket



## 如何加载大图片

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

## HttpClient和URLConnection的区别，怎么使用https



## 布局文件中，layout_gravity 和 gravity 以及 weight的作用。

android:gravity　是设置该view里面的**内容**相对于该view的位置，例如设置button里面的text相对于view的靠左，居中等位置。(也可以在Layout布局属性中添加，设置Layout中组件的位置)

android:layout_gravity 是用来设置该view相对与父view的位置，例如设置button在layout里面的相对位置：屏幕居中，水平居中等。

即android:gravity用于设置View中内容相对于View组件的对齐方式，而android:layout_gravity用于设置View组件相对于Container的对齐方式。

说的再直白点，就是android:gravity只对该组件内的东西有效，android:layout_gravity只对组件自身有效。

android:layout_gravity 只在 LinearLayout 和 FrameLayout 中有效

layout_weight：按屏幕剩余空间，按权重分配空间(权重、百分比布局)

## ListView里的ViewType机制

当我们在Adapter中调用方法getView的时候，如果整个列表中的Item View如果有多种类型布局，如：

![1](https://ws2.sinaimg.cn/large/006tKfTcgy1g0inuqh05zj30880a9q31.jpg)

我们继续使用convertView来将数据从新填充貌似不可行了，因为每次返回的convertView类型都不一样，无法重用。

Android在设计上的时候，也想到了这点。所以，在adapter中预留的两个方法。

- public int getItemViewType(int position) ; 
- public int getViewTypeCount();

只需要重写这两个方法，设置一下ItemViewType的个数和判断方法，然后在getView中获取到当前ViewType，然后通过不同的viewType解析不同的布局即可，而且Recycler还能有选择性的给出不同的convertView了。 

## TextView怎么改变局部颜色

Android提供了SpannableStringBuilder用来实现富文本的定制，或者也可以考虑使用HTML即写好HTML后使用tv.setText(Html.fromHtml(html))达到在TextView上显示Html的目的。

## Activity A 跳转到 Activity B，生命周期的执行过程是啥？

(此处有坑 ActivityA的OnPause和ActivityB的onResume谁先执行)

打开Activity A：

- A.onCreate
- A.onStart
- A.onResume

Activity A跳转到Activity B：

- A.onPause
- B.onCreate
- B.onStart
- B.onResume
- A.onStop

在Activity B中按返回键返回Activity A：

- B.onPause
- A.onRestart
- A.onStart
- A.onResume
- B.onStop
- B.onDestroy

再按返回键退出A：

- A.onPause
- A.onStop
- A.onDestroy

## Android中Handler声明非静态对象会发出警告，为什么非得是静态的？

(Memory Leak)

比如：

```java
public class MainActivity extends Activity {    
   private  Handler mHandler = new Handler() {   
         @Override       
        public void handleMessage(Message msg) {       
              //TODO handle message...        
        }   
   };   
     @Override   
     public void onCreate(Bundle savedInstanceState) {   
           super.onCreate(savedInstanceState);  
           setContentView(R.layout.activity_main);  
           mHandler.sendMessageDelayed(Message.obtain(), 60000);                 
                 finish();  
   }
 }
```

当Android应用启动的时候，会先创建一个应用主线程的Looper对象，Looper实现了一个简单的消息队列，一个一个的处理里面的Message对象。主线程Looper对象在整个应用生命周期中存在。当在主线程中初始化Handler时，该Handler和Looper的消息队列关联，发送到消息队列的Message会引用发送该消息的Handler对象，这样系统就可以调用 Handler#handleMessage(Message) 来分发处理该消息。然而，我们都知道**在Java中，非静态(匿名)内部类会引用外部类对象。而静态内部类不会引用外部类对象**。如果外部类是Activity，则会引起Activity泄露 。因为当Activity finish后，延时消息会继续存在主线程消息队列中，然后处理消息。而该消息引用了Activity的Handler对象，然后这个Handler又引用了这个Activity。这些引用对象会保持到该消息被处理完，这样就导致该Activity对象无法被回收，从而导致了上面说的 Activity泄露。也就是如果你执行了Handler的postDelayed()方法，该方法会将你的Handler装入一个Message，并把这条Message推到 MessageQueue中，那么在你设定的delay到达之前，会有一条MessageQueue -> Message -> Handler -> Activity的链，导致你的Activity被持有引用而无法被回收。 

再比如：

```java
Handler mHandler = new Handler() {
    @Override
    public void handleMessage(Message msg) {
        mImageView.setImageBitmap(mBitmap);
    }
}
```

当使用内部类（包括匿名类）来创建Handler的时候，Handler对象会隐式地持有一个外部类对象（通常是一个Activity）的引用（不然你怎 么可能通过Handler来操作Activity中的View？）。而Handler通常会伴随着一个耗时的后台线程（例如从网络拉取图片）一起出现，这 个后台线程在任务执行完毕（例如图片下载完毕）之后，通过消息机制通知Handler，然后Handler把图片更新到界面。然而，如果用户在网络请求过程中关闭了Activity，正常情况下，Activity不再被使用，它就有可能在GC检查时被回收掉，但由于这时线程尚未执行完，而该线程持有 Handler的引用（不然它怎么发消息给Handler？），这个Handler又持有Activity的引用，就导致该Activity无法被回收 （即内存泄露），直到网络请求结束（例如图片下载完毕）。 

改进方法：

方法一：通过完善自己的代码逻辑来进行保护。 
1.在关闭Activity的时候停掉你的后台线程。线程停掉了，就相当于切断了Handler和外部连接的线，Activity自然会在合适的时候被回收。 
2.如果你的Handler是被delay的Message持有了引用，那么使用相应的Handler的removeCallbacks()方法，把消息对象从消息队列移除就行了。 
方法二：将Handler声明为静态类,然后通过WeakReference 来保持外部的Activity对象。 由于静态类不持有外部类的对象，所以你的Activity可以随意被回收。由于Handler不再持有外部类对象的引用，导致程序不允许你在Handler中操作Activity中的对象了。所以你需要在Handler中增加一个对Activity的弱引用（WeakReference）

```java
static class MyHandler extends Handler {
    WeakReference<Activity > mActivityReference;

    MyHandler(Activity activity) {
        mActivityReference= new WeakReference<Activity>(activity);
    }

    @Override
    public void handleMessage(Message msg) {
        final Activity activity = mActivityReference.get();
        if (activity != null) {
            mImageView.setImageBitmap(mBitmap);
        }
    }
}
```

当我们在Activity中使用内部类的时候，需要时刻考虑是否可以控制该内部类的生命周期，如果不可以，则最好定义为静态内部类，以免造成内存泄漏。这是Android开发过程中经常被忽略掉的，特别是在开发自定义View组件的过程中经常忘记而导致内存泄漏。

## ListView使用过程中是否可以调用addView

不能，因为ListView有一个祖先类AdapterView，这个AdapterView重写了addView方法，在里面抛出了异常：

```java
@Override
        public void addView(View child) {
            throw new UnsupportedOperationException("addView(View) is not supported in AdapterView");
        }
```



## Android中的Thread, Looper和Handler机制(附带HandlerThread与AsyncTask)



## View的绘制过程

## 

## 属性动画(Property Animation)和补间动画(Tween Animation)的区别，为什么在3.0之后引入属性动画

[官方解释：调用简单](http://android-developers.blogspot.com/2011/05/introducing-viewpropertyanimator.html)

## 有没有使用过EventBus或者Otto框架，主要用来解决什么问题，内部原理

是一个Android事件发布/订阅框架，通过解耦发布者和订阅者简化Android事件传递，这里的事件可以理解为消息。事件传递既可以用于Android四大组件间通讯，也可以用于异步线程和主线程间通讯等。
 传统的事件传递方式包括：Handler、BroadcastReceiver、Interface回调，相比之下EventBus的优点是代码简洁，使用简单，并将事件发布和 订阅充分解耦。



## 设计一个网络请求框架(可以参考Volley框架)



## 网络图片加载框架(可以参考BitmapFun)

## Android里的LRU（Least Recently Used 最近最少使用）算法原理

LRU是近期最少使用的算法，它的核心思想是当缓存满时，会优先淘汰那些近期最少使用的缓存对象。采用LRU算法的缓存有两种：LrhCache和DisLruCache，分别用于实现内存缓存和硬盘缓存，其核心思想都是LRU缓存算法。

LruCache的核心思想很好理解，就是要维护一个缓存对象列表，其中对象列表的排列方式是按照访问顺序实现的，即一直没访问的对象，将放在队尾，即将被淘汰。而最近访问的对象将放在队头，最后被淘汰。

## Service onBindService 和startService 启动的区别

## APK安装过程

应用安装涉及到如下几个目录：
  - **system/app**：系统自带的应用程序，无法删除
  - **data/app**：用户程序安装的目录，有删除权限。安装时把apk文件复制到此目录
  - **data/data**：存放应用程序的数据
  - **data/dalvik-cache**：将apk中的dex文件安装到dalvik-cache目录下

复制APK安装包到data/app目录下，解压并扫描安装包，把dex文件(Dalvik字节码)保存到dalvik-cache目录，并在data/data目录下创建对应的应用数据目录。

***

## invalidate()和postInvalidate() 的区别

- `invalidate()`是用来刷新View的，必须是在UI线程中进行工作。比如在修改某个view的显示时，调用invalidate()才能看到重新绘制的界面。
- `postInvalidate()`在工作者线程中被调用。

***

## 导入外部数据库

Android系统下数据库应该存放在 `/data/data/com.*.*(package name)/` 目录下，所以我们需要做的是把已有的数据库传入那个目录下。操作方法是用`FileInputStream`读取原数据库，再用`FileOutputStream`把读取到的东西写入到那个目录。

***

## Parcelable和Serializable区别

在我们平时开发中.我们用到序列化最多的地方就是通过intent传递对象,如果你要在intent中传递基本数据类型以外的对象,那么该对象必须实现Serializable或者Parcelable,否则会报错;

同时进程间通信传递的对象是有严格要求的,除了基本数据类型,其他对象要想可以传递,必须可序列化,Android实现可序列化一般是通过实现 Serializable 或者是 Parcelable。

**注意:**

- 1:通过intent传递过去的对象是经过了序列化与反序列化的,虽然传送的对象和接收的对象内容相同,但是是不同的对象,他们的引用是不同的
- 2:静态变量是不会经过序列化的,所以跨进程通信的时候静态变量是传送不过去的
- 序列化过程中不会保存transient 修饰的属性，它是 Java 的关键字，专门用来标识不序列化的属性。

Serializable`序列化不保存静态变量，可以使用`Transient`关键字对部分字段不进行序列化，也可以覆盖`writeObject`、`readObject`方法以实现序列化过程自定义。



Serializable是java提供的序列化接口，使用方法是让待序列化的类实现Parcelable接口即可，不需要额外实现任何方法，但是最好手动加上一个private static final long serialVersionUID变量，其作用是一个类序列化时，运行时会保存它的版本号，然后在反序列化时检查你要反序列化成的对象版本号是否一致，不一致的话就会报错：·`InvalidClassException`，如果我们不自己创建这个版本号，序列化过程中运行时会根据类的许多特点计算出一个默认版本号。然而只要你对这个类修改了一点点，这个版本号就会改变。这种情况如果发生在序列化之后，反序列化时就会导致上面说的错误，Serializable 的序列化与反序列化分别通过 ObjectOutputStream 和 ObjectInputStream 进行。

Parcelable 是 Android 特有的序列化接口，方法是实现Parcelable接口并重写相应方法，as中建议使用插件**Android Parcelable Code Generator**自动化完成Parcelable接口对应方法的重写。

区别：

Serializable:

1.Serializable是java提供的可序列化接口
2.Serializable的序列化与反序列化需要大量的IO操作,效率比较低
3.Serializable实现起来很简单

Parcelable:

1.Parcelable是Android特有的可序列化接口
2.Parcelable的效率比较高
3.Parcleable实现起来比较复杂
4.使用场景
1.Parcleable: 内存中的序列化时使用,效率更高，如activity间传输数据

2.Serializable: 对象序列化到存储设备中、在网络中传输等，在需要保存或网络传输数据时选择

因为android不同版本`Parcelable`可能不同，所以不推荐使用`Parcelable`进行数据持久化。



***

## Android里跨进程传递数据的几种方案

  - Binder
  - Socket/LocalSocket
  - 共享内存

***

## 匿名共享内存，使用场景

在Android系统中，提供了独特的匿名共享内存子系统`Ashmem(Anonymous Shared Memory)`，它以驱动程序的形式实现在内核空间中。它有两个特点，一是能够辅助内存管理系统来有效地管理不再使用的内存块，二是它通过Binder进程间通信机制来实现进程间的内存共享。

`ashmem`并像`Binder`是Android重新自己搞的一套东西，而是利用了Linux的 **tmpfs文件系统**。tmpfs是一种可以基于RAM或是SWAP的高速文件系统，然后可以拿它来实现不同进程间的内存共享。

大致思路和流程是：

  - Proc A 通过 tmpfs 创建一块共享区域，得到这块区域的 fd（文件描述符）
  - Proc A 在 fd 上 mmap 一片内存区域到本进程用于共享数据
  - Proc A 通过某种方法把 fd 倒腾给 Proc B
  - Proc B 在接到的 fd 上同样 mmap 相同的区域到本进程
  - 然后 A、B 在 mmap 到本进程中的内存中读、写，对方都能看到了

其实核心点就是 **创建一块共享区域，然后2个进程同时把这片区域 mmap 到本进程，然后读写就像本进程的内存一样**。这里要解释下第3步，为什么要倒腾 fd，因为在 linux 中 fd 只是对本进程是唯一的，在 Proc A 中打开一个文件得到一个 fd，但是把这个打开的 fd 直接放到 Proc B 中，Proc B 是无法直接使用的。但是文件是唯一的，就是说一个文件（file）可以被打开多次，每打开一次就有一个 fd（文件描述符），所以对于同一个文件来说，需要某种转化，把 Proc A 中的 fd 转化成 Proc B 中的 fd。这样 Proc B 才能通过 fd mmap 同样的共享内存文件。

使用场景：进程间大量数据传输。

***

## ContentProvider实现原理

ContentProvider 有以下两个特点：

  - **封装**：对数据进行封装，提供统一的接口，使用者完全不必关心这些数据是在DB，XML、Preferences或者网络请求来的。当项目需求要改变数据来源时，使用我们的地方完全不需要修改。
  - **提供一种跨进程数据共享的方式**。

`Content Provider`组件在不同应用程序之间传输数据是基于匿名共享内存机制来实现的。其主要的调用过程：

1. 通过ContentResolver先查找对应给定Uri的ContentProvider，返回对应的`BinderProxy`

  - 如果该Provider尚未被调用进程使用过:
    - 通过`ServiceManager`查找activity service得到`ActivityManagerService`对应`BinderProxy`
    - 调用`BinderProxy`的transcat方法发送`GET_CONTENT_PROVIDER_TRANSACTION`命令，得到对应`ContentProvider`的`BinderProxy`。

  - 如果该Provider已被调用进程使用过，则调用进程会保留使用过provider的HashMap。此时直接从此表查询即得。

2. 调用`BinderProxy`的`query()`

***

## 如何使用ContentProvider进行批量操作？

通常进行数据的批量操作我们都会使用“事务”，但是`ContentProvider`如何进行批量操作呢？创建 `ContentProviderOperation` 对象数组，然后使用 `ContentResolver.applyBatch()` 将其分派给内容提供程序。您需将内容提供程序的授权传递给此方法，而不是特定内容 `URI`。这样可使数组中的每个 `ContentProviderOperation` 对象都能适用于其他表。调用 `ContentResolver.applyBatch()` 会返回结果数组。

同时我们还可以通过`ContentObserver`对数据进行观察：

    1. 创建我们特定的`ContentObserver`派生类，必须重载`onChange()`方法去处理回调后的功能实现
    2. 利用`context.getContentResolover()`获得`ContentResolove`对象，接着调用`registerContentObserver()`方法去注册内容观察者，为指定的Uri注册一个`ContentObserver`派生类实例，当给定的Uri发生改变时，回调该实例对象去处理。
    3. 由于`ContentObserver`的生命周期不同步于Activity和Service等，因此，在不需要时，需要手动的调用`unregisterContentObserver()`去取消注册。

***

## Application类的作用

 Android系统会为每个程序运行时创建一个`Application`类的对象且仅创建一个，所以Application可以说是单例 (singleton)模式的一个类。`Application`对象的生命周期是整个程序中最长的，它的生命周期就等于这个程序的生命周期。因为它是全局的单例的，所以在不同的`Activity`,`Service`中获得的对象都是同一个对象。所以通过`Application`来进行一些，数据传递，数据共享，数据缓存等操作。

***

## 广播注册后不解除注册会有什么问题？(内存泄露)

我们可以通过两种方式注册`BroadcastReceiver`，一是在Activity启动过程中通过代码动态注册，二是在AndroidManifest.xml文件中利用`<receiver>`标签进行静态注册。

  - 对于第一种方法，我们需要养成一个良好的习惯：在Activity进入停止或者销毁状态的时候使用`unregisterReceiver`方法将注册的`BroadcastReceiver`注销掉。
  - 对于`<receiver>`标签进行注册的，那么该对象的实例在`onReceive`被调用之后就会在任意时间内被销毁。

***

## 属性动画(Property Animation)和补间动画(Tween Animation)的区别

  - 补间动画只是针对于View，超脱了View就无法操作了。
  - 补间动画有四种动画操作（移动，缩放，旋转，淡入淡出）。
  - 补间动画只是改变View的显示效果而已，但是不会真正的去改变View的属性。
  - 属性动画改变View的实际属性值，当然它也可以不作用于View。

***

## BrocastReceive里面可不可以执行耗时操作?

不能，当 `onReceive()` 方法在 10 秒内没有执行完毕，Android 会认为该程序无响应，所以在`BroadcastReceiver`里不能做一些比较耗时的操作，否侧会弹出 ANR 的对话框。

***

## Android优化工具

### TraceView

traceview 是Android SDK中自带的一个工具，可以 **对应用中方法调用耗时进行统计分析，是Android性能优化和分析时一个很重要的工具**。使用方法：第一种是在相应进行traceview分析的开始位置和结束位置分别调用`startMethodTracing`和`stopMethodTracing`方法。第二种是在ddms中直接使用，即在ddms中在选中某个要进行监控的进程后，点击如图所示的小图标开始监控，在监控结束时再次点击小图标，ddms会自动打开traceview视图。

### Systrace

Systrace是Android4.1中新增的性能数据采样和分析工具。它可帮助开发者收集Android关键子系统（如`surfaceflinger`、`WindowManagerService`等Framework部分关键模块、服务）的运行信息，从而帮助开发者更直观的分析系统瓶颈，改进性能。

Systrace的功能包括跟踪系统的I/O操作、内核工作队列、CPU负载以及Android各个子系统的运行状况等。

***

## Dalvik与ART的区别？

Dalvik是Google公司自己设计用于Android平台的Java虚拟机。Dalvik虚拟机是Google等厂商合作开发的Android移动设备平台的核心组成部分之一，它可以支持已转换为.dex(即Dalvik Executable)格式的Java应用程序的运行，.dex格式是专为Dalvik应用设计的一种压缩格式，适合内存和处理器速度有限的系统。Dalvik经过优化，允许在有限的内存中同时运行多个虚拟机的实例，并且每一个Dalvik应用作为独立的Linux进程执行。独立的进程可以防止在虚拟机崩溃的时候所有程序都被关闭。

ART代表`Android Runtime`,其处理应用程序执行的方式完全不同于Dalvik，**Dalvik是依靠一个Just-In-Time(JIT)编译器去解释字节码。开发者编译后的应用代码需要通过一个解释器在用户的设备上运行，这一机制并不高效，但让应用能更容易在不同硬件和架构上运行。ART则完全改变了这套做法，在应用安装的时候就预编译字节码到机器语言，这一机制叫 Ahead-Of-Time(AOT) 编译** 。在移除解释代码这一过程后，应用程序执行将更有效率，启动更快。

ART优点：

    1. 系统性能的显著提升
    2. 应用启动更快、运行更快、体验更流畅、触感反馈更及时
    3. 更长的电池续航能力
    4. 支持更低的硬件

ART缺点：

    1. 更大的存储空间占用，可能会增加10%-20%
    2. 更长的应用安装时间

***

## Android动态权限？

Android 6.0 动态权限，这里以拨打电话的权限为例，首先需要在Manifest里添加`android.permission.CALL_PHONE`权限。

```Java
int checkCallPhonePermission = ContextCompat.checkSelfPermission(this, Manifest.permission.CALL_PHONE);
    if (checkCallPhonePermission != PackageManager.PERMISSION_GRANTED) {
        ActivityCompat.requestPermissions(
                this, new String[]{Manifest.permission.CALL_PHONE}, REQUEST_CODE_ASK_CALL_PHONE);
        return;
    }
```

在获取权限后，可以重写Activity.onRequestPermissionsResult方法来进行回调。

```Java
@Override
public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions,
                                       @NonNull int[] grantResults) {
    switch (requestCode) {
        case REQUEST_CODE_ASK_CALL_PHONE:
            if (grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                // Permission Granted
                Toast.makeText(MainActivity.this, "CALL_PHONE Granted", Toast.LENGTH_SHORT)
                        .show();
            } else {
                // Permission Denied
                Toast.makeText(MainActivity.this, "CALL_PHONE Denied", Toast.LENGTH_SHORT)
                        .show();
            }
            break;
        default:
            super.onRequestPermissionsResult(requestCode, permissions, grantResults);
    }
}
```

***

## ViewPager如何判断左右滑动？

实现`OnPageChangeListener`并重写`onPageScrolled`方法，通过参数进行判断。

***

## ListView与RecyclerView

    1. **ViewHolder**：在ListView中，ViewHolder需要自己来定义，且这只是一种推荐的使用方式，不使用当然也可以，这不是必须的。而在RecyclerView中使用 `RecyclerView.ViewHolder` 则变成了必须，尽管实现起来稍显复杂，但它却解决了ListView面临的上述不使用自定义ViewHolder时所面临的问题。
    
    2. **LayoutManager**：RecyclerView提供了更加丰富的布局管理。`LinearLayoutManager`，可以支持水平和竖直方向上滚动的列表。`StaggeredGridLayoutManager`，可以支持交叉网格风格的列表，类似于瀑布流或者Pinterest。`GridLayoutManager`，支持网格展示，可以水平或者竖直滚动，如展示图片的画廊。
    
    3. **ItemAnimator**：相比较于ListView，`RecyclerView.ItemAnimator` 则被提供用于在`RecyclerView`添加、删除或移动item时处理动画效果。
    
    4. **ItemDecoration**：RecyclerView在默认情况下并不在item之间展示间隔符。如果你想要添加间隔符，你必须使用`RecyclerView.ItemDecoration`类来实现。

ListView可以设置选择模式，并添加`MultiChoiceModeListener`，`RecyclerView`中并没有提供这样功能。

***

## SpannableString

TextView通常用来显示普通文本，但是有时候需要对其中某些文本进行样式、事件方面的设置。Android系统通过`SpannableString`类来对指定文本进行相关处理。可以通过`SpannableString`来对TextView进行富文本设置，包括但不限于文本颜色，删除线，图片，超链接，字体样式。

***

## 描述一下Android手机启动过程和App启动过程？

### Android手机启动过程

当我们开机时，首先是启动Linux内核，在Linux内核中首先启动的是init进程，这个进程会去读取配置文件`system\core\rootdir\init.rc`配置文件，这个文件中配置了Android系统中第一个进程Zygote进程。

启动Zygote进程 --> 创建AppRuntime（Android运行环境） --> 启动虚拟机 --> 在虚拟机中注册JNI方法 --> 初始化进程通信使用的Socket（用于接收AMS的请求） --> 启动系统服务进程 --> 初始化时区、键盘布局等通用信息 --> 启动Binder线程池 --> 初始化系统服务（包括PMS，AMS等等） --> 启动Launcher

### App启动过程

![3](https://ws1.sinaimg.cn/large/006tKfTcgy1g0ipin8446j30jk0ge0te.jpg)

    1. 应用的启动是从其他应用调用`startActivity`开始的。通过代理请求AMS启动Activity。
    
    2. AMS创建进程，并进入`ActivityThread`的main入口。在main入口，主线程初始化，并loop起来。主线程初始化，主要是实例化`ActivityThread`和`ApplicationThread`，以及`MainLooper`的创建。`ActivityThread`和`ApplicationThread`实例用于与AMS进程通信。
    
    3. 应用进程将实例化的`ApplicationThread`，`Binder`传递给AMS，这样AMS就可以通过代理对应用进程进行访问。
    
    4. AMS通过代理，请求启动Activity。`ApplicationThread`通知主线程执行该请求。然后，`ActivityThread`执行Activity的启动。
    
    5. Activity的启动包括，Activity的实例化，Application的实例化，以及Activity的启动流程：create、start、resume。


可以看到 **入口Activity其实是先于Application实例化，只是onCreate之类的流程，先于Activity的流程**。另外需要`scheduleLaunchActivity`，在`ApplicationThreaad`中，对应AMS管理Activity生命周期的方法都以`scheduleXXXActivity`，ApplicationThread在Binder线程中，它会向主线程发送消息，ActivityThread的Handler会调用相应的handleXXXActivity方法，然后会执行performXXXActivity方法，最终调用Activity的onXXX方法

***

## Include、Merge、ViewStub的作用

**Include**：布局重用

  - `<include />`标签可以使用单独的layout属性，这个也是必须使用的。

  - 可以使用其他属性。`<include />`标签若指定了ID属性，而你的layout也定义了ID，则你的layout的ID会被覆盖，解决方案。

  - 在`<include />`标签中所有的`android:layout_*`都是有效的，**前提是必须要写layout_width和layout_height两个属性**。

  - 布局中可以包含两个相同的include标签

**Merge**：减少视图层级，多用于替换FrameLayout或者当一个布局包含另一个时，`<merge/>`标签消除视图层次结构中多余的视图组。

>例如：你的主布局文件是垂直布局，引入了一个垂直布局的include，这是如果include布局使用的LinearLayout就没意义了，使用的话反而减慢你的UI表现。这时可以使用<merge/>标签优化。

**ViewStub**：需要时使用。优点是当你需要时才会加载，使用他并不会影响UI初始化时的性能。需要使用时调用`inflate()`。

***

## Asset目录与res目录的区别

  - **assets 目录**：不会在`R.java`文件下生成相应的标记，assets文件夹可以自己创建文件夹，必须使用`AssetsManager`类进行访问，存放到这里的资源在运行打包的时候都会打入程序安装包中，

  - **res 目录**：会在R.java文件下生成标记，这里的资源会在运行打包操作的时候判断哪些被使用到了，没有被使用到的文件资源是不会打包到安装包中的。

> res/raw 和 assets文件夹来存放不需要系统编译成二进制的文件，例如字体文件等

> res/raw不可以有目录结构，而assets则可以有目录结构，也就是assets目录下可以再建立文件夹

***

## System.gc && Runtime.gc

`System.gc`和`Runtime.gc`是等效的，在`System.gc`内部也是调用的`Runtime.gc`。**调用两者都是通知虚拟机要进行gc，但是否立即回收还是延迟回收由JVM决定**。两者唯一的区别就是一个是类方法，一个是实例方法。

***

## Application 在多进程下会多次调用 onCreate() 么？

当采用多进程的时候，比如下面的Service 配置：

```XML
<service
    android:name=".MyService"
    android:enabled="true"
    android:exported="false"
    android:process=":remote" />
```

> android:process 属性中 `:`的作用就是把这个名字附加到你的包所运行的标准进程名字的后面作为新的进程名称。

这样配置会调用 onCreate() 两次。

***

## Theme && Style

  - **Style** 是一组外观、样式的属性集合，适用于 View 和 Window 。

  - **Theme** 是一种应用于整个 Activity 或者 Application ，而不是独立的 View。

***

## SQLiteOpenHelper.onCreate() 调用时机？

在调`getReadableDatabase`或`getWritableDatabase`时，会判断指定的数据库是否存在，不存在则调`SQLiteDatabase.onCreate`创建， `onCreate`只在数据库第一次创建时才执行。

***

## Removecallback 失效？

Removecallback 必须是同一个Handler才能移除。

***

## Toast 如果会短时间内频繁显示怎么优化？

```Java
public void update(String msg){
  toast.setText(msg);
  toast.show();
}
```

***

## Notification 如何优化？

可以通过 相同 ID 来更新 Notification 。

***

## 应用怎么判断自己是处于前台还是后台？

主要是通过 `getRunningAppProcesses()` 方法来实现。

```Java
ActivityManager activityManager = (ActivityManager) getSystemService(Context.ACTIVITY_SERVICE);
List<ActivityManager.RunningAppProcessInfo> appProcesses = activityManager.getRunningAppProcesses();
for (ActivityManager.RunningAppProcessInfo appProcess : appProcesses) {
    if (appProcess.processName.equals(getPackageName())) {
        if (appProcess.importance == ActivityManager.RunningAppProcessInfo.IMPORTANCE_FOREGROUND) {
            Log.d(TAG, String.format("Foreground App:%s", appProcess.processName));
        } else {
            Log.d(TAG, "Background App:" + appProcess.processName);
        }
    }
}
```

***

## FragmentPagerAdapter 和 FragmentStateAdapter 的区别？

`FragmentStatePagerAdapter` 是 `PagerAdapter` 的子类，这个适配器对实现多个 `Fragment` 界面的滑动是非常有用的，它的工作方式和listview是非常相似的。当Fragment对用户不可见的时候，整个Fragment会被销毁，只会保存Fragment的保存状态。基于这样的特性，`FragmentStatePagerAdapter` 比 `FragmentPagerAdapter` 更适合用于很多界面之间的转换，而且消耗更少的内存资源。

***

## Bitmap的本质？

本质是 SkBitmap 详见 Pocket

***

## SurfaceView && View && GLSurfaceView

  - `View`：显示视图，内置画布，提供图形绘制函数、触屏事件、按键事件函数等；**必须在UI主线程内更新画面，速度较慢**。
  - `SurfaceView`：基于view视图进行拓展的视图类，更适合2D游戏的开发；**View的子类，类似使用双缓机制，在新的线程（也可以在UI线程）中更新画面所以刷新界面速度比 View 快**，但是会涉及到线程同步问题。
 - `GLSurfaceView`：openGL专用。基于SurfaceView视图再次进行拓展的视图类，**专用于3D游戏开发的视图**。



## 请简述一下你对fragment的理解？

fragment被称为碎片，可以作为界面来使用，在一个Activity中可以嵌入多个Fragment，而且Fragment不能单独存在，必须依附于Activity才行，但是Fragment又有自己的生命周期，也能直接处理用户的一些事件，Fragment的生命周期也受依附的Activity的生命周期影响；一般来说Fragment在平板开发中用的比较多，还有就是Tab切换

## 请简述一下Fragment的生命周期？

fragment的生命周期：onAttach——>onCreate——>onCreateView——>onViewCreated——>onActivityCreated——>onStart——>onResume——>onPause——>onStop——>onDestroyView——>onDestroy——>onDetach；
 fragment的生命周期大致就这么多，但是还有一个比较常见的就是onHiddenChanged，这个是在切换fragment的时候会执行，至于什么场景下会执行什么，我还是建议你自己动手实验一把；这里还需要注意的是，如果是通过add方法显示fragment，那么切换fragment不会执行其生命周期，只会执行onHiddenChanged方法；如果是通过replace方法显示fragment，切换fragment的时候会重新走生命周期的流程。

## Android的多渠道打包你了解吗

**多渠道打包：就是指分不同的市场打包，如安卓市场、百度市场、谷歌市场等等，Android的这个市场有点多，就不一一列举了，多渠道打包是为了针对不同市场做出不同的一些统计，数据分析，收集用户信息。**

**AndroidStudio用的多的友盟多渠道打包**

## 如何对APK瘦身?

1)使用混淆

 2)开启shrinkResourse(shrink-收缩),会将没有用到的图片变成一个像素点

 3)删除无用的语言资源(删除国际化文件) 

4)对于非透明的大图,使用JPG(没有透明度信息),代替PNG格式 

5)使用tinypng进行图片压缩 

6)使用webp图片格式,进一步压缩图片资源

 7)使用第三方包时把用到的代码加到项目中来,避免引用整一个第三方库

# 字节跳动Android岗面试题

## java的classloader工作原理

ClassLoader使用的是**双亲委托模型**来搜索类的，每个ClassLoader实例都有一个父类加载器的引用（不是继承的关系，是一个包含的关系），虚拟机内置的类加载器（Bootstrap ClassLoader）本身没有父类加载器，但可以用作其它ClassLoader实例的的父类加载器。当一个ClassLoader实例需要加载某个类时，它会试图亲自搜索某个类之前，先把这个任务委托给它的父类加载器，这个过程是由上至下依次检查的，首先由最顶层的类加载器Bootstrap ClassLoader试图加载，如果没加载到，则把任务转交给Extension ClassLoader试图加载，如果也没加载到，则转交给App ClassLoader 进行加载，如果它也没有加载得到的话，则返回给委托的发起者，由它到指定的文件系统或网络等URL中加载该类。如果它们都没有加载到这个类时，则抛出ClassNotFoundException异常。否则将这个找到的类生成一个类的定义，并将它加载到内存当中，最后返回这个类在内存中的Class实例对象。

## 开发过程中常见的内存泄漏都有哪些

静态的对象中（包括单例）持有一个生命周期较短的引用时，或内部类的子代码块对象的生命周期超过了外面代码的生命周期（如非静态内部类，线程），会导致这个短生命周期的对象内存泄漏。总之就是一个对象的生命周期结束（不再使用该对象）后，依然被某些对象所持有该对象强引用的场景就是内存泄漏。

当一个对象在程序中已经不再使用，但是（强）引用还是会被其他对象持有，则称为内存泄漏。内存泄漏并不会使程序马上异常，但是多处的未处理的内存泄漏则可能导致内存溢出，造成不可预估的后果。

常见情景：

1、静态成员变量持有外部（短周期临时）对象引用。 如单例类（类内部静态属性）持有一个activity（或其他短周期对象）引用时，导致被持有的对象内存无法释放。

2、内部类。当内部类与外部类生命周期不一致时，就会造成内存泄漏。如非静态内部类创建静态实例、Activity中的Handler或Thread等。

3、资源没有及时关闭。如数据库、IO流、Bitmap、注册的相关服务、webview、动画等。

4、集合内部Item没有置空。

5、方法块内不使用的对象，没有及时置空。

## 关于JVM内存管理的一些建议

1、尽可能的手动将无用对象置为null，加快内存回收。 

2、可考虑对象池技术生成可重用的对象，较少对象的生成。

 3、合理利用四种引用。



## LeakCanary的工作原理，java gc是如何回收对象的，可以作为gc根节点的对象有哪些？

Android Studio供了许多对App性能分析的工具，可以方便分析App性能。我们可以使用Memory Monitor和Heap Dump来观察内存的使用情况、使用Allocation Tracker来跟踪内存分配的情况，也可以通过这些工具来找到疑似发生内存泄漏的位置。

堆存储文件（hpof）可以使用DDMS或者Memory Monitor来生成，输出的文件格式为hpof，而MAT（Memory Analysis Tool）就是来分析堆存储文件的。

然而MAT工具分析内存问题并不是一件容易的事情，需要一定的经验区做引用链的分析，需要一定的门槛。 随着安卓技术生态的发展，**LeakCanary** 开源项目诞生了，只要几行代码引入目标项目，就可以自动分析hpof文件，把内存泄漏的地方展示出来。

说白了就是用来检测内存泄漏的。

### LeakCanary原理

主要是在Activity的&**onDestroy**方法中，手动调用 GC，然后利用ReferenceQueue+WeakReference，来判断是否有释放不掉的引用，然后结合dump memory的hpof文件, 用[HaHa（Headless Android Heap Analyzer）](https://link.juejin.im/?target=https%3A%2F%2Fgithub.com%2Fsquare%2Fhaha)分析出泄漏地方。

流程：

1：用ActivityLifecycleCallbacks接口来检测Activity生命周期

2：WeakReference + ReferenceQueue 来监听对象回收情况 

3：Apolication中可通过processName判断是否是任务执行进程 

4：MessageQueue中加入一个IdleHandler来得到主线程空闲回调 

5：LeakCanary检测只针对Activiy里的相关对象。其他类无法使用，还得用MAT原始方法

### java gc是如何回收对象的

那些不可能再被任何途径使用的对象，需要被回收，否则内存迟早都会被消耗空。

GC机制主要是通过可达性分析法，通过一系列称为“GC Roots”的对象作为起始点，从这些节点向下搜索，搜索所走过的路径称为引用链，当一个对象到GC Roots没有任何引用链时，即GC Roots到对象不可达，则证明此对象是不可达的。

### 可以作为gc根节点的对象有哪些

- 虚拟机栈（栈帧中的局部变量区，也叫做局部变量表）中引用的对象。
- 方法区中的类静态属性引用的对象。
- 方法区中常量引用的对象。
- 本地方法栈中JNI(Native方法)引用的对象。

## 既然有GC机制，为什么还会有内存泄露的情     

​            理论上Java因为有垃圾回收机制不会存在内存泄露问题（这也是Java被广泛使用于服务器端编程的一个重要原因）。

​            然而在实际开发中，可能会存在无用但可达的对象，这些对对象不能被GC回收，因此会导致内存溢出发生。

## jvm的内存模型是什么样的？如何理解java的虚函数表？

## 如何从一百万个数里面找到最小的一百个数，考虑算法的时间复杂度和空间复杂度。

**解法一**：采用局部淘汰法。选取前100个元素，并排序，记为序列L。然后一次扫描剩余的元素x，与排好序的100个元素中最小的元素比，如果比这个最小的要大，那么把这个最小的元素删除，并把x利用插入排序的思想，插入到序列L中。依次循环，知道扫描了所有的元素。复杂度为O(100万*100)。

**解法二**：采用快速排序的思想，每次分割之后只考虑比主元大的一部分，直到比主元大的一部分比100多的时候，采用传统排序算法排序，取前100个。复杂度为O(100万*100)。

**解法三**：在前面的题中，我们已经提到了，用一个含100个元素的最小堆完成。复杂度为O(100万*lg100)。

## 安卓的app加固如何做。

加固:防止代码反编译,提高代码安全性 加固三方平台,梆梆安全,360加固,爱加密等区别:梆梆安全,360加固看不到项目中的类,爱加密看的到Java类,单看不到里面的方法实现体,效果比前面差一点点 加固的底层原理:第三方加固的应用会生成一个Apk,然后把你的APK读取出来,在封装到这个第三方应用的APK里面.

## mvp和mvc的主要区别是什么？为什么mvp要比mvc好。

mvc是指用户触发事件的时候，view层会发送指令到controller层，然后controller去通知model层更新数据，model层更新完数据后会直接在view层显示结果。 
对android来说 activity几乎承担了view层和controller层两种角色，并且和model层耦合严重，在逻辑复杂的界面维护起来很麻烦。

mvp模式下的activity只承担了view层的角色，controller的角色完全由presenter负责，view层和presenter层的通信通过接口实现，所以VP之间不存在耦合问题，view层与model也是完全解耦了。

presenter复用度高，可以随意搬到任何界面。

mvp模式下还方便测试维护： 
可以在为完成界面的情况下实现接口调试，只需写一个Java类，实现对应的接口，presenter网络获取数据后能调用相应的方法。 
相反的，在接口未完成联调的情况下正常显示界面，由presenter提供测试数据。

mvp的问题在于view层和presenter层是通过接口连接，在复杂的界面中，维护过多接口的成本很大。 

解决办法是定义一些基类接口，把网络请求结果,toast等通用逻辑放在里面，然后供定义具体业务的接口集成。



## 安卓的混淆原理是什么？

Java 是一种跨平台、解释型语言，Java 源代码编译成的class文件中有大量包含语义的变量名、方法名的信息，很容易被反编译为Java 源代码。为了防止这种现象，我们可以对Java字节码进行混淆。混淆不仅能将代码中的类名、字段、方法名变为无意义的名称，保护代码，也由于移除无用的类、方法，并使用简短名称对类、字段、方法进行重命名缩小了程序的size。

ProGuard由shrink、optimize、obfuscate和preverify四个步骤组成，每个步骤都是可选的，需要哪些步骤都可以在脚本中配置。 

- **压缩(Shrink)**: 侦测并移除代码中无用的类、字段、方法、和特性(Attribute)。
- **优化(Optimize)**: 分析和优化字节码。
- **混淆(Obfuscate)**: 使用a、b、c、d这样简短而无意义的名称，对类、字段和方法进行重命名。

上面三个步骤使代码size更小，更高效，也更难被逆向工程。

- **预检(Preveirfy)**: 在java平台上对处理后的代码进行预检。



## 如何设计一个安卓的画图库，做到对扩展开放，对修改封闭，同时又保持独立性。

**OCP原则（开闭原则）**：一个软件实体如类、模块和函数应该对扩展开放，对修改关闭。

能用抽象类的别用具体类，能用接口的别用抽象类。总之一句：尽量面向接口编程。



## 怎样做系统调度。

## 设计一个下载器。

## 数组实现队列。

## 网络优化的方案

我们对移动设备网络的需求无非快速，节省流量，节省电量。
一般而言：
快速可以通过缓存方式来实现；
节省流量可以通过缓存，压缩数据源等方式；
节省耗电量 可以通过批量操作，减少唤醒电源和电源持续时间来达到

## APP的性能优化经验

### 布局优化

- 减少嵌套的层级（可使用RelativeLayout）,减少嵌套层级可加快加载效率，
- 使用include标签
- 使用style提取相同view的公共属性，减少重复代码
- 合理使用ViewStub

### 图片的优化

android中图片的使用是非常占用内存资源的。

- 在图片未使用时，及时recycle()回收

- 使用三级缓存，内存-sd卡-网络
   内存中再次获取最快，由于内存有限可能被gc回收，sd卡中的图片不会回收，当前面两种都不存在所需图片时，才去网洛下载

- 将大图片进行压缩处理再放到内存中，用到`BitmapFactory`类

- 图片解码率也会影响图片所占内存

  常见的png，JPG，webp等格式的图片在设置到UI上之前需要经过解码过程，而图片采用不同的码率，也会造成对内存的占用不同。

  ARGB_8888 格式的解码率，一个像素占用4个字节，alpha(A)值，Red（R）值，Green(G)值，Blue（B）值各占8个bytes ， 共32bytes , 即4个字节。这是一种高质量的图片格式，电脑上普通采用的格式。它也是Android手机上一个BitMap的默认格式。

  RGB_565格式的解码率，一个像素占用2个字节，没有alpha(A)值，即不支持透明和半透明， Red（R）值占5个bytes ，Green(G)值占6个bytes ，Blue（B）值占5个bytes,共16bytes,即2个字节。 对于半透明颜色的图片来说，该格式的图片能够达到比较好的呈现效果，相对于ARGB_8888来说也能减少一半的内存开销，因此它是一个不错的选择。推荐使用

### 其他优化

- 网络优化
  - 同一个页面数据尽量放到一个接口中去处理
- 使用Application Context代替Activity Context
- 谨慎使用static 关键字
  - static使用不当容易造成内存泄漏

## 死锁的概念，怎么避免死锁

当线程A持有独占锁a，并尝试去获取独占锁b的同时，线程B持有独占锁b，并尝试获取独占锁a的情况下，就会发生AB两个线程由于互相持有对方需要的锁，而发生的阻塞现象，我们称为死锁。



## 数据结构中堆的概念，堆排序







## ReentrantLock 、synchronized和volatile（n面）

## HashMap

## singleTask启动模式

## 用到的一些开源框架，介绍一个看过源码的，内部实现过程。

## 消息机制实现

## ReentrantLock的内部实现

## App启动崩溃异常捕捉

## 事件传递机制的介绍

## ListView的优化

## 二叉树，给出根节点和目标节点，找出从根节点到目标节点的路径

## 模式MVP，MVC介绍

## 断点续传的实现

## 集合的接口和具体实现类，介绍

## TreeMap具体实现

## synchronized与ReentrantLock

## 手写生产者/消费者模式

## 逻辑地址与物理地址，为什么使用逻辑地址

## 一个无序，不重复数组，输出N个元素，使得N个元素的和相加为M，给出时间复杂度、空间复杂度。手写算法

## .Android进程分类

## 前台切换到后台，然后再回到前台，Activity生命周期回调方法。弹出Dialog，生命值周期回调方法。

## Activity的启动模式

