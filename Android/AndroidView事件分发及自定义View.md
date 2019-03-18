## 事件分发

> 在android开发中会经常遇到滑动冲突（比如ScrollView或是SliddingMenu与ListView的嵌套）的问题，需要我们深入的了解android事件响应机制才能解决，事件响应机制已经是android开发者必不可少的知识。

### 涉及到事件响应的常用方法

用户在手指与屏幕接触过程中通过MotionEvent对象产生一系列事件，它有四种状态：

 - MotionEvent.ACTION_DOWN　：手指按下屏幕的瞬间（一切事件的开始）

 - MotionEvent.ACTION_MOVE　：手指在屏幕上移动

 - MotionEvent.ACTION_UP　：手指离开屏幕瞬间

 - MotionEvent.ACTION_CANCEL 　：取消手势，一般由程序产生，不会由用户产生

　　Android中的事件onClick, onLongClick，onScroll, onFling等等，都是由许多个Touch事件构成的（一个ACTION_DOWN， n个ACTION_MOVE，1个ACTION_UP）。

　　android 事件响应机制是先 **分发**（先由外部的View接收，然后依次传递给其内层的最小View）再 **处理** （从最小View单元（事件源）开始依次向外层传递。）的形式实现的。

　　复杂性表现在：可以控制每层事件是否继续传递（分发和拦截协同实现），以及事件的具体消费（事件分发也具有事件消费能力）。

### android事件处理涉及到的三个重要函数

#### 事件分发：public boolean dispatchTouchEvent(MotionEvent ev)

　　　当有监听到事件时，首先由Activity进行捕获，进入事件分发处理流程。（因为activity没有事件拦截，View和ViewGroup有）会将事件传递给最外层View的dispatchTouchEvent(MotionEvent ev)方法，该方法对事件进行分发。

 - return true  ：表示该View内部消化掉了所有事件。
 - return false  ：事件在本层不再继续进行分发，并交由**上层**控件的onTouchEvent方法进行消费（如果本层控件已经是Activity，那么事件将被系统消费或处理）。　
 - 如果事件分发返回系统默认的 super.dispatchTouchEvent(ev)，事件将分发给本层的事件拦截onInterceptTouchEvent 方法进行处理

#### 事件拦截：public boolean onInterceptTouchEvent(MotionEvent ev)

 - return true  ：表示将事件进行拦截，并将拦截到的事件交由本层控件 的 onTouchEvent 进行处理；

 -  return false  ：则表示不对事件进行拦截，事件得以成功分发到子View。并由子View的dispatchTouchEvent进行处理。　

 - 如果返回super.onInterceptTouchEvent(ev)，默认表示拦截该事件，并将事件传递给当前View的onTouchEvent方法，和return true一样。

#### 事件响应：public boolean onTouchEvent(MotionEvent ev)

　　在dispatchTouchEvent（事件分发）返回super.dispatchTouchEvent(ev)并且onInterceptTouchEvent（事件拦截返回true或super.onInterceptTouchEvent(ev)的情况下，那么事件会传递到onTouchEvent方法，该方法对事件进行响应。

 - 如果return true，表示onTouchEvent处理完事件后消费了此次事件。此时事件终结；

 -  如果return fasle，则表示不响应事件，那么该事件将会不断向上层View的onTouchEvent方法传递，直到某个View的onTouchEvent方法返回true，如果到了最顶层View还是返回false，那么认为该事件不消耗，则在同一个事件系列中，当前View无法再次接收到事件，该事件会交由Activity的onTouchEvent进行处理；　　
 - 如果return super.dispatchTouchEvent(ev)，则表示不响应事件，结果与return false一样。

从以上过程中可以看出，dispatchTouchEvent无论返回true还是false，事件都不再进行分发，只有当其返回super.dispatchTouchEvent(ev)，才表明其具有向下层分发的愿望，但是是否能够分发成功，则需要经过事件拦截onInterceptTouchEvent的审核。事件是否向上传递处理是由onTouchEvent的返回值决定的。


![image-20190318095650631](https://ws1.sinaimg.cn/large/006tKfTcgy1g16pqlscqhj31500u0dn5.jpg)

### View源码分析

　　Android中ImageView、textView、Button等继承于View但没有重写的dispatchTouchEvent方法，所以都用的View的该方法进行事件分发。
　　看View重要函数部分源码：

```java
public boolean dispatchTouchEvent(MotionEvent event) {
//返回true,表示该View内部消化掉了所有事件。返回false，表示View内部只处理了ACTION_DOWN事件，事件继续传递，向上级View(ViewGroup)传递。

    if (mOnTouchListener != null && (mViewFlags & ENABLED_MASK) == ENABLED &&
            mOnTouchListener.onTouch(this, event)) {
  //此处的onTouch方式就是回调的我们注册OnTouchListener时重写的onTouch()方法
        return true;
    }
    return onTouchEvent(event);
}
```

　首先进行三个条件的判断：

（1）查看是否给button设置了OnTouchListener()事件；

（2）控件是否Enable；（控件默认都是enable的）

（3）button里面实现的OnTouchListener监听里的onTouch()方法是否返回true；

　如果条件都满足，则该事件被消耗掉，不再进入onTouchEvent中处理。否则将事件将交给onTouchEvent方法处理：


```java
 public boolean onTouchEvent(MotionEvent event) {
    ...
 
   /＊ 当前onTouch的组件必须是可点击的比如Button，ImageButton等等，此处CLICKABLE为true，才会进入if方法，最后返回true。
 如果是ImageView、TexitView这些默认为不可点击的View,此处CLICKABLE为false，最后返回false。当然会有特殊情况，如果给这些View设置了onClick监听器，此处CLICKABLE也将为true　　＊／
 
    if (((viewFlags & CLICKABLE) == CLICKABLE ||  
            (viewFlags & LONG_CLICKABLE) == LONG_CLICKABLE)) {
        switch (event.getAction()) {
            case MotionEvent.ACTION_UP:
                ...
                            if (!post(mPerformClick)) {
                                performClick();// 实际就是回调了我们注册的OnClickListener中的onClick()方法
                            }
                 ...
                break;
 
            case MotionEvent.ACTION_DOWN:
               ...
                break;
 
            case MotionEvent.ACTION_CANCEL:
                ...
                break;
 
            case MotionEvent.ACTION_MOVE:
               ...
                break;
        }
        return true;
    }
 
    return false;
}
```
```java
public boolean performClick() {
    ...
 ／／
    if (li != null && li.mOnClickListener != null) {
        ...
        li.mOnClickListener.onClick(this);
        return true;
    }
 
    return false;
}
```
```java
 public void setOnClickListener(OnClickListener l) {
    if (!isClickable()) {
        setClickable(true);
    }
    getListenerInfo().mOnClickListener = l;
}
```

我们注册OnTouchListener时重写onTouch()方法：

- 返回false  —> 执行onTouchEvent方法 —>  导致onClick()回调方法执行　

- 返回true —> onTouchEvent方法不执行 —>  导致onClick()回调方法不会执行


### ViewGroup源码分析

　　Android中诸如LinearLayout等的五大布局控件，都是继承自ViewGroup，而ViewGroup本身是继承自View，所以ViewGroup的事件处理机制对这些控件都有效。


部分源码：
```java
public boolean dispatchTouchEvent(MotionEvent ev) {  
       final int action = ev.getAction();  
       final float xf = ev.getX();  
       final float yf = ev.getY();  
       final float scrolledXFloat = xf + mScrollX;  
       final float scrolledYFloat = yf + mScrollY;  
       final Rect frame = mTempRect;  
  
       //这个值默认是false, 然后我们可以通过requestDisallowInterceptTouchEvent(boolean disallowIntercept)方法来改变disallowIntercept的值  
       boolean disallowIntercept = (mGroupFlags & FLAG_DISALLOW_INTERCEPT) != 0;  
  
       //这里是ACTION_DOWN的处理逻辑  
       if (action == MotionEvent.ACTION_DOWN) {  
        //清除mMotionTarget, 每次ACTION_DOWN都很设置mMotionTarget为null  
           if (mMotionTarget != null) {  
               mMotionTarget = null;  
           }  
  
           //disallowIntercept默认是false, 就看ViewGroup的onInterceptTouchEvent()方法  
           if (disallowIntercept || !onInterceptTouchEvent(ev)) {  //第一点
               ev.setAction(MotionEvent.ACTION_DOWN);  
               final int scrolledXInt = (int) scrolledXFloat;  
               final int scrolledYInt = (int) scrolledYFloat;  
               final View[] children = mChildren;  
               final int count = mChildrenCount;  
               //遍历其子View  
               for (int i = count - 1; i >= 0; i--) {  //第二点
                   final View child = children[i];  
                     
                   //如果该子View是VISIBLE或者该子View正在执行动画, 表示该View才可以接受到Touch事件  
                   if ((child.mViewFlags & VISIBILITY_MASK) == VISIBLE  
                           || child.getAnimation() != null) {  
                    //获取子View的位置范围  
                       child.getHitRect(frame);  
                         
                       //如Touch到屏幕上的点在该子View上面  
                       if (frame.contains(scrolledXInt, scrolledYInt)) {  
                           // offset the event to the view's coordinate system  
                           final float xc = scrolledXFloat - child.mLeft;  
                           final float yc = scrolledYFloat - child.mTop;  
                           ev.setLocation(xc, yc);  
                           child.mPrivateFlags &= ~CANCEL_NEXT_UP_EVENT;  
                             
                           //调用该子View的dispatchTouchEvent()方法  
                           if (child.dispatchTouchEvent(ev))  {  
                               // 如果child.dispatchTouchEvent(ev)返回true表示  
                            //该事件被消费了，设置mMotionTarget为该子View  
                               mMotionTarget = child;  
                               //直接返回true  
                               return true;  
                           }  
                           // The event didn't get handled, try the next view.  
                           // Don't reset the event's location, it's not  
                           // necessary here.  
                       }  
                   }  
               }  
           }  
       }  
  
       //判断是否为ACTION_UP或者ACTION_CANCEL  
       boolean isUpOrCancel = (action == MotionEvent.ACTION_UP) ||  
               (action == MotionEvent.ACTION_CANCEL);  
  
       if (isUpOrCancel) {  
           //如果是ACTION_UP或者ACTION_CANCEL, 将disallowIntercept设置为默认的false  
        //假如我们调用了requestDisallowInterceptTouchEvent()方法来设置disallowIntercept为true  
        //当我们抬起手指或者取消Touch事件的时候要将disallowIntercept重置为false  
        //所以说上面的disallowIntercept默认在我们每次ACTION_DOWN的时候都是false  
           mGroupFlags &= ~FLAG_DISALLOW_INTERCEPT;  
       }  
  
       // The event wasn't an ACTION_DOWN, dispatch it to our target if  
       // we have one.  
       final View target = mMotionTarget;  
       //mMotionTarget为null意味着没有找到消费Touch事件的View, 所以我们需要调用ViewGroup父类的  
       //dispatchTouchEvent()方法，也就是View的dispatchTouchEvent()方法  
       if (target == null) {  
           // We don't have a target, this means we're handling the  
           // event as a regular view.  
           ev.setLocation(xf, yf);  
           if ((mPrivateFlags & CANCEL_NEXT_UP_EVENT) != 0) {  
               ev.setAction(MotionEvent.ACTION_CANCEL);  
               mPrivateFlags &= ~CANCEL_NEXT_UP_EVENT;  
           }  
           return super.dispatchTouchEvent(ev);  
       }  
  
       //这个if里面的代码ACTION_DOWN不会执行，只有ACTION_MOVE  
       //ACTION_UP才会走到这里, 假如在ACTION_MOVE或者ACTION_UP拦截的  
       //Touch事件, 将ACTION_CANCEL派发给target，然后直接返回true  
       //表示消费了此Touch事件  
       if (!disallowIntercept && onInterceptTouchEvent(ev)) {  
           final float xc = scrolledXFloat - (float) target.mLeft;  
           final float yc = scrolledYFloat - (float) target.mTop;  
           mPrivateFlags &= ~CANCEL_NEXT_UP_EVENT;  
           ev.setAction(MotionEvent.ACTION_CANCEL);  
           ev.setLocation(xc, yc);  
             
           if (!target.dispatchTouchEvent(ev)) {  
           }  
           // clear the target  
           mMotionTarget = null;  
           // Don't dispatch this event to our own view, because we already  
           // saw it when intercepting; we just want to give the following  
           // event to the normal onTouchEvent().  
           return true;  
       }  
  
       if (isUpOrCancel) {  
           mMotionTarget = null;  
       }  
  
       // finally offset the event to the target's coordinate system and  
       // dispatch the event.  
       final float xc = scrolledXFloat - (float) target.mLeft;  
       final float yc = scrolledYFloat - (float) target.mTop;  
       ev.setLocation(xc, yc);  
  
       if ((target.mPrivateFlags & CANCEL_NEXT_UP_EVENT) != 0) {  
           ev.setAction(MotionEvent.ACTION_CANCEL);  
           target.mPrivateFlags &= ~CANCEL_NEXT_UP_EVENT;  
           mMotionTarget = null;  
       }  
  
       //如果没有拦截ACTION_MOVE, ACTION_DOWN的话，直接将Touch事件派发给target  
       return target.dispatchTouchEvent(ev);  
   }
```

1、dispatchTouchEvent作用：决定事件是否由onInterceptTouchEvent来拦截处理。
返回super.dispatchTouchEvent时，由onInterceptTouchEvent来决定事件的流向
返回false时，会继续分发事件，自己内部只处理了ACTION_DOWN
返回true时，不会继续分发事件，自己内部处理了所有事件（ACTION_DOWN,ACTION_MOVE,ACTION_UP）

2、onInterceptTouchEvent作用：拦截事件，用来决定事件是否传向子View
返回true时，拦截后交给自己的onTouchEvent处理
返回false时，拦截后交给子View来处理

3、onTouchEvent作用：事件最终到达这个方法
返回true时，内部处理所有的事件，换句话说，后续事件将继续传递给该view的onTouchEvent()处理
返回false时，事件会向上传递，由onToucEvent来接受，如果最上面View中的onTouchEvent也返回false的话，那么事件就会消失


### 总结

 - 如果ViewGroup找到了能够处理该事件的View，则直接交给子View处理，自己的onTouchEvent不会被触发；　

 - 可以通过复写onInterceptTouchEvent(ev)方法，拦截子View的事件（即return true），把事件交给自己处理，则会执行自己对应的onTouchEvent方法。
 - 子View可以通过调用getParent().requestDisallowInterceptTouchEvent(true);  阻止ViewGroup对其MOVE或者UP事件进行拦截；　　

 - 一个点击事件产生后，它的传递过程如下：
 Activity->Window->View。顶级View接收到事件之后，就会按相应规则去分发事件。如果一个View的onTouchEvent方法返回false，那么将会交给父容器的onTouchEvent方法进行处理，逐级往上，如果所有的View都不处理该事件，则交由Activity的onTouchEvent进行处理。　

 - 如果某一个View开始处理事件，如果他不消耗ACTION_DOWN事件（也就是onTouchEvent返回false），则同一事件序列比如接下来进行ACTION_MOVE，则不会再交给该View处理。

 - ViewGroup默认不拦截任何事件。　

 - 诸如TextView、ImageView这些不作为容器的View，一旦接受到事件，就调用onTouchEvent方法，它们本身没有onInterceptTouchEvent方法。正常情况下，它们都会消耗事件（返回true），除非它们是不可点击的（clickable和longClickable都为false），那么就会交由父容器的onTouchEvent处理。　

 - 点击事件分发过程如下 `dispatchTouchEvent—->OnTouchListener的onTouch方法—->onTouchEvent-->OnClickListener的onClick方法`。也就是说，我们平时调用的setOnClickListener，优先级是最低的，所以，onTouchEvent或OnTouchListener的onTouch方法如果返回true，则不响应onClick方法

 

## 自定义View

> 在android应用开发过程中，固定的一些控件和属性可能满足不了开发的需求，所以在一些特殊情况下，我们需要自定义控件与属性。

### 实现步骤

1. 继承View类或其子类　
2. 复写view中的一些函数

 ３.为自定义View类增加属性（两种方式）

４.绘制控件（导入布局）

５.响应用户事件

６.定义回调函数（根据自己需求来选择）

### 哪些方法需要被重写　　

- onDraw()

　　view中onDraw()是个空函数，也就是说具体的视图都要覆写该函数来实现自己的绘制。对于ViewGroup则不需要实现该函数，因为作为容器是“没有内容“的（但必须实现dispatchDraw()函数，告诉子view绘制自己）。

- onLayout()

　　主要是为viewGroup类型布局子视图用的，在View中这个函数为空函数。

- onMeasure()

　　用于计算视图大小（即长和宽）的方式，并通过setMeasuredDimension(width, height)保存计算结果。

- onTouchEvent

　　定义触屏事件来响应用户操作。
　　

还有一些不常用的方法：

```java
	onKeyDown 当按下某个键盘时 　

	onKeyUp 当松开某个键盘时 　

　　onTrackballEvent 当发生轨迹球事件时 　
　　
　　onSizeChange() 当该组件的大小被改变时 　
　　
　　onFinishInflate() 回调方法，当应用从XML加载该组件并用它构建界面之后调用的方法 　
　　
　　onWindowFocusChanged(boolean) 当该组件得到、失去焦点时 　
　　onAttachedToWindow() 当把该组件放入到某个窗口时 　
　　
　　onDetachedFromWindow() 当把该组件从某个窗口上分离时触发的方法 　
　　
　　onWindowVisibilityChanged(int): 当包含该组件的窗口的可见性发生改变时触发的方法 　

```

#### **View的绘制流程**

绘制流程函数调用关系如下图：

![image-20190318114109020](https://ws4.sinaimg.cn/large/006tKfTcgy1g16sr4kmdqj30vk0sojvj.jpg)

我们调用requestLayout()的时候，会触发measure 和 layout 过程，调用invalidate,会执行 draw 过程。

### 自定义控件的三种方式　

 １. 继承已有的控件

　　当要实现的控件和已有的控件在很多方面比较类似, 通过对已有控件的扩展来满足要求。

 ２. 继承一个布局文件

　　一般用于自定义组合控件，在构造函数中通过inflater和addView()方法加载自定义控件的布局文件形成图形界面（不需要onDraw方法）。

３.继承view

　　通过onDraw方法来绘制出组件界面。

### 自定义属性的两种方法

　　１．在布局文件中直接加入属性，在构造函数中去获得。

布局文件：

```xml
<RelativeLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    >
     <com.example.demo.myView
         android:layout_width="wrap_content"
         android:layout_height="wrap_content" 
         Text="@string/hello_world"
         />
</RelativeLayout>

```

获取属性值：

```java
public myView(Context context, AttributeSet attrs) {
		super(context, attrs);
		// TODO Auto-generated constructor stub
int textId = attrs.getAttributeResourceValue(null, "Text", 0);
String text = context.getResources().getText(textId).toString();
	}
```

２．在res/values/ 下建立一个attrs.xml 来声明自定义view的属性。

可以定义的属性有：

```xml
<declare-styleable name = "名称"> 
//参考某一资源ID (name可以随便命名)
<attr name = "background" format = "reference" /> 
//颜色值 
<attr name = "textColor" format = "color" /> 
//布尔值
<attr name = "focusable" format = "boolean" /> 
//尺寸值 
<attr name = "layout_width" format = "dimension" /> 
//浮点值 
<attr name = "fromAlpha" format = "float" /> 
//整型值 
<attr name = "frameDuration" format="integer" /> 
//字符串 
<attr name = "text" format = "string" /> 
//百分数 
<attr name = "pivotX" format = "fraction" /> 

//枚举值 
<attr name="orientation"> 
<enum name="horizontal" value="0" /> 
<enum name="vertical" value="1" /> 
</attr> 

//位或运算 
<attr name="windowSoftInputMode"> 
<flag name = "stateUnspecified" value = "0" /> 
<flag name = "stateUnchanged" value = "1" /> 
</attr> 

//多类型
<attr name = "background" format = "reference|color" /> 
</declare-styleable> 
```

- attrs.xml进行属性声明

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <declare-styleable name="myView">
        <attr name="text" format="string"/>
        <attr name="textColor" format="color"/>
    </declare-styleable>
</resources>

```

- 添加到布局文件　　

```xml
<RelativeLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    xmlns:myview="http://schemas.android.com/apk/com.example.demo"
    >
     <com.example.demo.myView
         android:layout_width="wrap_content"
         android:layout_height="wrap_content" 
         myview:text = "test"
         myview:textColor ="#ff0000"
         />
</RelativeLayout>

```

这里注意命名空间：
`xmlns:前缀=”http://schemas.android.com/apk/res/包名（或res-auto）`，

前缀:TextColor　使用属性。

- 在构造函数中获取属性值

```xml
public myView(Context context, AttributeSet attrs) {
		super(context, attrs);
		// TODO Auto-generated constructor stub
		TypedArray a = context.obtainStyledAttributes(attrs, R.styleable.myView); 
		String text = a.getString(R.styleable.myView_text); 
		int textColor = a.getColor(R.styleable.myView_textColor, Color.WHITE); 
		a.recycle();
	}
```

　或者：

```java
	public myView(Context context, AttributeSet attrs) {
		super(context, attrs);
		// TODO Auto-generated constructor stub
		TypedArray a = context.obtainStyledAttributes(attrs, R.styleable.myView); 
		int n = a.getIndexCount();
		for(int i=0;i<n;i++){
			int attr = a.getIndex(i);
			switch (attr) {
			case R.styleable.myView_text:
				
				break;

			case R.styleable.myView_textColor:
				
				break;
				
			}
		}
	   a.recycle();
	}
```

### 自定义随手指移动的小球(小例子)

![1](https://ws1.sinaimg.cn/large/006tKfTcgy1g16svnfkvhg30bn0ikt9h.gif)

实现上面的效果我们大致需要分成这几步

- 在res/values/ 下建立一个attrs.xml 来声明自定义view的属性
- 一个继承View并复写部分函数的自定义view的类
- 一个展示自定义view 的容器界面 

1.自定义view命名为myView，它有一个属性值，格式为color、

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <declare-styleable name="myView">
        <attr name="TextColor" format="color"/>
    </declare-styleable>        
</resources>
```

2.在构造函数获取获得view的属性配置和复写onDraw和onTouchEvent函数实现绘制界面和用户事件响应。

```java
public class myView extends View{
    //定义画笔和初始位置
    Paint p = new Paint();
    public float currentX = 50;
    public float currentY = 50;
    public int textColor;

    public myView(Context context, AttributeSet attrs) {
        super(context, attrs);
        //获取资源文件里面的属性，由于这里只有一个属性值，不用遍历数组，直接通过R文件拿出color值
        //把属性放在资源文件里，方便设置和复用
        TypedArray array = context.obtainStyledAttributes(attrs,R.styleable.myView);
        textColor = array.getColor(R.styleable.myView_TextColor,Color.BLACK);
        array.recycle();
    }

    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);
        //画一个蓝色的圆形
        p.setColor(Color.BLUE);
        canvas.drawCircle(currentX,currentY,30,p);
        //设置文字和颜色，这里的颜色是资源文件values里面的值
        p.setColor(textColor);
        canvas.drawText("BY finch",currentX-30,currentY+50,p);
    }

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        currentX = event.getX();
        currentY = event.getY();
        invalidate();//重新绘制图形
        return true;
    }
}

```

　　这里通过不断的更新当前位置坐标和重新绘制图形实现效果，要注意的是使用TypedArray后一定要记得recycle(). 否则会对下次调用产生影响。
　　![image-20190318114700292](https://ws3.sinaimg.cn/large/006tKfTcgy1g16sx7pjzij30nq08sn23.jpg)

３．把myView加入到activity_main.xml布局里面

```xml
<?xml version="1.0" encoding="utf-8"?>
<RelativeLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    xmlns:myview="http://schemas.android.com/apk/res-auto"
    android:paddingBottom="@dimen/activity_vertical_margin"
    android:paddingLeft="@dimen/activity_horizontal_margin"
    android:paddingRight="@dimen/activity_horizontal_margin"
    android:paddingTop="@dimen/activity_vertical_margin"
    tools:context="finch.scu.cn.myview.MainActivity">


    <finch.scu.cn.myview.myView
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        myview:TextColor="#ff0000"
        />
</RelativeLayout>

```

４．最后是MainActivity

```java
public class MainActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
    }
}

```

具体的view要根据具体的需求来，比如我们要侧滑删除的listview我们可以继承listview，监听侧滑事件，显示删除按钮实现功能。

## 自定义ViewGroup

### ViewGroup 绘制流程

　　ViewGroup也是继承于View，下面看看绘制过程中依次会调用哪些函数。

![image-20190318114753102](https://ws3.sinaimg.cn/large/006tKfTcgy1g16sy4wy1yj30gs0muq4t.jpg)

说明：

- measure()和onMeasure()

　　在View.Java源码中：
　　

```java
public final void measure(int widthMeasureSpec,int heightMeasureSpec){
... 
onMeasure
...
}

protected void onMeasure(int widthMeasureSpec,int heightMeasureSpec) {
        setMeasuredDimension(getDefaultSize(getSuggestedMinimumWidth(), widthMeasureSpec),
        getDefaultSize(getSuggestedMinimumHeight(), heightMeasureSpec));
}
```

　　可以看出measure()是被final修饰的，这是不可被重写。onMeasure在measure方法中调用的，当我们继承View的时候通过重写onMeasure方法来测量控件大小。

 　　layout()和onLayout(),draw()和onDraw()类似。

- dispatchDraw()

　　View 中这个函数是一个空函数，ViewGroup 复写了dispatchDraw()来对其子视图进行绘制。自定义的 ViewGroup 一般不对dispatchDraw()进行复写。

- requestLayout()

　　当布局变化的时候，比如方向变化，尺寸的变化，会调用该方法，在自定义的视图中，如果某些情况下希望重新测量尺寸大小，应该手动去调用该方法，它会触发measure()和layout()过程，但不会进行 draw。

自定义ViewGroup的时候一般复写

> onMeasure()方法,计算childView的测量值以及模式，以及设置自己的宽和高　

> onLayout()方法，对其所有childView的位置进行定位

View树：

![image-20190318114856310](https://ws1.sinaimg.cn/large/006tKfTcgy1g16sz87c40j30m00k60wc.jpg)

　树的遍历是有序的，由父视图到子视图，每一个 ViewGroup 负责测绘它所有的子视图，而最底层的 View 会负责测绘自身。

- **measure：**

　　自上而下进行遍历，根据父视图对子视图的MeasureSpec以及ChildView自身的参数，通过　　

```java
getChildMeasureSpec(parentHeightMeasure,mPaddingTop+mPaddingBottom，lp.height)
```

　　获取ChildView的MeasureSpec，回调ChildView.measure最终调用setMeasuredDimension得到ChildView的尺寸：

```java
mMeasuredWidth 和 mMeasuredHeight
```

- **Layout ：** 

　　　也是自上而下进行遍历的，该方法计算每个ChildView的ChildLeft,ChildTop；与measure中得到的每个ChildView的mMeasuredWidth 和 mMeasuredHeight，来对ChildView进行布局。

```java
child.layout(left,top,left+width,top+height)
```

### onMeasure过程

measure过程会为一个View及所有子节点的mMeasuredWidth和mMeasuredHeight变量赋值，该值可以通过getMeasuredWidth()和getMeasuredHeight()方法获得。

**onMeasure过程传递尺寸的两个类：**

- **ViewGroup.LayoutParams** （ViewGroup 自身的布局参数）

　　用来指定视图的高度和宽度等参数，使用 view.getLayoutParams() 方法获取一个视图LayoutParams，该方法得到的就是其所在父视图类型的LayoutParams，比如View的父控件为RelativeLayout，那么得到的 LayoutParams 类型就为RelativeLayoutParams。

> ①具体值 　
>
> ②MATCH_PARENT 表示子视图希望和父视图一样大(不包含 padding 值) 　
>
> ③WRAP_CONTENT 表示视图为正好能包裹其内容大小(包含 padding 值) 

- **MeasureSpecs**

　　测量规格，包含测量要求和尺寸的信息，有三种模式:

> ①UNSPECIFIED
>
> 　　父视图不对子视图有任何约束，它可以达到所期望的任意尺寸。比如 ListView、ScrollView，一般自定义 View 中用不到 

> ②EXACTLY　
>
> 　　父视图为子视图指定一个确切的尺寸，而且无论子视图期望多大，它都必须在该指定大小的边界内，对应的属性为 match_parent 或具体值，比如 100dp，父控件可以通过MeasureSpec.getSize(measureSpec)直接得到子控件的尺寸。

> ③AT_MOST　
>
> 　　 父视图为子视图指定一个最大尺寸。子视图必须确保它自己所有子视图可以适应在该尺寸范围内，对应的属性为 wrap_content，这种模式下，父控件无法确定子 View 的尺寸，只能由子控件自己根据需求去计算自己的尺寸，这种模式就是我们自定义视图需要实现测量逻辑的情况。　

### onLayout 过程

 　　子视图的具体位置都是相对于父视图而言的。View 的 onLayout 方法为空实现，而 ViewGroup 的 onLayout 为 abstract 的，因此，如果自定义的自定义ViewGroup 时，必须实现 onLayout 函数。 
 　　在 layout 过程中，子视图会调用getMeasuredWidth()和getMeasuredHeight()方法获取到 measure 过程得到的 mMeasuredWidth 和 mMeasuredHeight，作为自己的 width 和 height。然后调用每一个子视图的layout(l, t, r, b)函数，来确定每个子视图在父视图中的位置。

### 示例程序

先上效果图：

![2](https://ws1.sinaimg.cn/large/006tKfTcgy1g16t1fv2q9g30c00lcdl9.gif)

代码中有详细的注释，结合上文中的说明，理解应该没有问题。这里主要贴出核心代码。

FlowLayout.java中(参照阳神的慕课课程)

> onMeasure方法

```java
 @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec)
    {
        // 获得它的父容器为它设置的测量模式和大小
        int sizeWidth = MeasureSpec.getSize(widthMeasureSpec);
        int modeWidth = MeasureSpec.getMode(widthMeasureSpec);
        int sizeHeight = MeasureSpec.getSize(heightMeasureSpec);
        int modeHeight = MeasureSpec.getMode(heightMeasureSpec);

        // 用于warp_content情况下，来记录父view宽和高
        int width = 0;
        int height = 0;

        // 取每一行宽度的最大值
        int lineWidth = 0;
        // 每一行的高度累加
        int lineHeight = 0;

        // 获得子view的个数
        int cCount = getChildCount();

        for (int i = 0; i < cCount; i++)
        {
            View child = getChildAt(i);
            // 测量子View的宽和高（子view在布局文件中是wrap_content）
            measureChild(child, widthMeasureSpec, heightMeasureSpec);
            // 得到LayoutParams
            MarginLayoutParams lp = (MarginLayoutParams) child.getLayoutParams();

            // 根据测量宽度加上Margin值算出子view的实际宽度（上文中有说明）
            int childWidth = child.getMeasuredWidth() + lp.leftMargin + lp.rightMargin;
            // 根据测量高度加上Margin值算出子view的实际高度
            int childHeight = child.getMeasuredHeight() + lp.topMargin+ lp.bottomMargin;

            // 这里的父view是有padding值的，如果再添加一个元素就超出最大宽度就换行
            if (lineWidth + childWidth > sizeWidth - getPaddingLeft() - getPaddingRight())
            {
                // 父view宽度=以前父view宽度、当前行宽的最大值
                width = Math.max(width, lineWidth);
                // 换行了，当前行宽=第一个view的宽度
                lineWidth = childWidth;
                // 父view的高度=各行高度之和
                height += lineHeight;
                //换行了，当前行高=第一个view的高度
                lineHeight = childHeight;
            } else{
                // 叠加行宽
                lineWidth += childWidth;
                // 得到当前行最大的高度
                lineHeight = Math.max(lineHeight, childHeight);
            }
            // 最后一个控件
            if (i == cCount - 1)
            {
                width = Math.max(lineWidth, width);
                height += lineHeight;
            }
        }
        /**
         * EXACTLY对应match_parent 或具体值
         * AT_MOST对应wrap_content
         * 在FlowLayout布局文件中
         * android:layout_width="fill_parent"
         * android:layout_height="wrap_content"
         *
         * 如果是MeasureSpec.EXACTLY则直接使用父ViewGroup传入的宽和高，否则设置为自己计算的宽和高。
         */
        setMeasuredDimension(
                modeWidth == MeasureSpec.EXACTLY ? sizeWidth : width + getPaddingLeft() + getPaddingRight(),
                modeHeight == MeasureSpec.EXACTLY ? sizeHeight : height + getPaddingTop()+ getPaddingBottom()
        );

    }
```

> onLayout方法

```java
 //存储所有的View
    private List<List<View>> mAllViews = new ArrayList<List<View>>();
    //存储每一行的高度
    private List<Integer> mLineHeight = new ArrayList<Integer>();

    @Override
    protected void onLayout(boolean changed, int l, int t, int r, int b)
    {
        mAllViews.clear();
        mLineHeight.clear();

        // 当前ViewGroup的宽度
        int width = getWidth();

        int lineWidth = 0;
        int lineHeight = 0;
        // 存储每一行所有的childView
        List<View> lineViews = new ArrayList<View>();

        int cCount = getChildCount();

        for (int i = 0; i < cCount; i++)
        {
            View child = getChildAt(i);
            MarginLayoutParams lp = (MarginLayoutParams) child.getLayoutParams();

            int childWidth = child.getMeasuredWidth();
            int childHeight = child.getMeasuredHeight();

            lineWidth += childWidth + lp.leftMargin + lp.rightMargin;
            lineHeight = Math.max(lineHeight, childHeight + lp.topMargin+ lp.bottomMargin);
            lineViews.add(child);

            // 换行，在onMeasure中childWidth是加上Margin值的
            if (childWidth + lineWidth + lp.leftMargin + lp.rightMargin > width - getPaddingLeft() - getPaddingRight())
            {
                // 记录行高
                mLineHeight.add(lineHeight);
                // 记录当前行的Views
                mAllViews.add(lineViews);

                // 新行的行宽和行高
                lineWidth = 0;
                lineHeight = childHeight + lp.topMargin + lp.bottomMargin;
                // 新行的View集合
                lineViews = new ArrayList<View>();
            }

        }
        // 处理最后一行
        mLineHeight.add(lineHeight);
        mAllViews.add(lineViews);

        // 设置子View的位置

        int left = getPaddingLeft();
        int top = getPaddingTop();

        // 行数
        int lineNum = mAllViews.size();

        for (int i = 0; i < lineNum; i++)
        {
            // 当前行的所有的View
            lineViews = mAllViews.get(i);
            lineHeight = mLineHeight.get(i);

            for (int j = 0; j < lineViews.size(); j++)
            {
                View child = lineViews.get(j);
                // 判断child的状态
                if (child.getVisibility() == View.GONE)
                {
                    continue;
                }

                MarginLayoutParams lp = (MarginLayoutParams) child.getLayoutParams();

                int lc = left + lp.leftMargin;
                int tc = top + lp.topMargin;
                int rc = lc + child.getMeasuredWidth();
                int bc = tc + child.getMeasuredHeight();

                // 为子View进行布局
                child.layout(lc, tc, rc, bc);

                left += child.getMeasuredWidth() + lp.leftMargin+ lp.rightMargin;
            }
            left = getPaddingLeft() ;
            top += lineHeight ;
        }

    }

    /**
     * 因为我们只需要支持margin，所以直接使用系统的MarginLayoutParams
     */
    @Override
    public LayoutParams generateLayoutParams(AttributeSet attrs)
    {
        return new MarginLayoutParams(getContext(), attrs);
    }
```

> 以及MainActivity.java

```java
public class MainActivity extends Activity {

    LayoutInflater mInflater;
    @InjectView(R.id.id_flowlayout1)
    FlowLayout idFlowlayout1;
    @InjectView(R.id.id_flowlayout2)
    FlowLayout idFlowlayout2;
    private String[] mVals = new String[]
            {"Do", "one thing", "at a time", "and do well.", "Never", "forget",
                    "to say", "thanks.", "Keep on", "going ", "never give up."};

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        ButterKnife.inject(this);
        mInflater = LayoutInflater.from(this);
        initFlowlayout2();
    }

    public void initFlowlayout2() {
        for (int i = 0; i < mVals.length; i++) {
            final RelativeLayout rl2 = (RelativeLayout) mInflater.inflate(R.layout.flow_layout, idFlowlayout2, false);
            TextView tv2 = (TextView) rl2.findViewById(R.id.tv);
            tv2.setText(mVals[i]);
            rl2.setTag(i);
            idFlowlayout2.addView(rl2);
            rl2.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    int i = (int) v.getTag();
                    addViewToFlowlayout1(i);
                    rl2.setBackgroundResource(R.drawable.flow_layout_disable_bg);
                    rl2.setClickable(false);
                }
            });

        }
    }
    public void addViewToFlowlayout1(int i){
        RelativeLayout rl1 = (RelativeLayout) mInflater.inflate(R.layout.flow_layout, idFlowlayout1, false);
        ImageView iv = (ImageView) rl1.findViewById(R.id.iv);
        iv.setVisibility(View.VISIBLE);
        TextView tv1 = (TextView) rl1.findViewById(R.id.tv);
        tv1.setText(mVals[i]);
        rl1.setTag(i);
        idFlowlayout1.addView(rl1);
        rl1.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                int i = (int) v.getTag();
                idFlowlayout1.removeView(v);
                View view = idFlowlayout2.getChildAt(i);
                view.setClickable(true);
                view.setBackgroundResource(R.drawable.flow_layout_bg);
            }
        });
    }
```

> 源码：点击 [FlowLayout](https://github.com/fanrunqi/FlowLayout) 