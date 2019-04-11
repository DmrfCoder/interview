# 概述

　　Fragment是Activity中用户界面的一个行为或者是一部分。主要是支持在大屏幕上动态和更为灵活的去组合或是交换UI组件，通过将Activity的布局分割成若干个Fragment，可以在运行时编辑Activity的呈现，并且那些变化会被保存在由Activity管理的后台栈里面。

　　**Fragment必须总是被嵌入到一个Activity之中**，并且Fragment的生命周期直接受其宿主Activity的生命周期的影响。可以认为Fragment是Activity的一个模块零件，它有自己的生命周期，接收它自己的输入事件，并且可以在Activity运行时添加或者删除。

　　应该将每一个Fragment设计为模块化的和可复用化的Activity组件。也就是说，你可以在多个Activity中引用同一个Fragment，因为Fragment定义了它自己的布局，并且使用它本身生命周期回调的行为。

# Fragment的生命周期

先看Fragment生命周期图：

![image-20190318130446348](https://ws1.sinaimg.cn/large/006tKfTcgy1g16v654abfj30q619ctlr.jpg)

　　Fragment所生存的Activity生命周期直接影响着Fragment的生命周期，由此针对Activity的每一个生命周期回调都会引发一个Fragment类似的回调。例如，当Activity接收到onPause()时，这个Activity之中的每个Fragment都会接收到onPause()。

　　Fragment有一些额外的生命周期回调方法（创建和销毁Fragment界面）．

 - onAttach()

　　当Fragment被绑定到Activity时调用（Activity会被传入）。

 - onCreateView()

　　将本身的布局构建到Activity中去（Fragment作为Activity界面的一部分）

 -  onActivityCreated()

　　当Activity的onCreate()函数返回时被调用。

 - onDestroyView()

　　当与Fragment关联的视图体系正被移除时被调用。

 - onDetach()

　　当Fragment正与Activity解除关联时被调用。

当Activity接收到它的onCreate()回调时，Activity之中的Fragment接收到onActivityCreated()回调。

　　一旦Activity处于resumed状态，则可以在Activity中自由的添加或者移除Fragment。因此，只**有当Activity处于resumed状态时**，Fragment的生命周期才可以独立变化。
　　
Fragment会在　Activity离开恢复状态时　再一次被Activity推入它的生命周期中。

**管理Fragment生命周期**与管理Activity生命周期很相像。像Activity一样，Fragment也有三种状态：

 - Resumed

　　Fragment在运行中的Activity可见。

 - Paused

　　另一个Activity处于前台且得到焦点，但是这个Fragment所在的Activity仍然可见（前台Activity部分透明，或者没有覆盖全屏）。

 - Stopped

　　Fragment不可见。要么宿主Activity已经停止，要么Fragment已经从Activity上移除，但已被添加到后台栈中。一个停止的Fragment仍然活着（所有状态和成员信息仍然由系统保留着）。但是，它对用户来讲已经不再可见，并且如果Activity被杀掉，它也将被杀掉。

　　如果Activity的进程被杀掉了，在Activity被重新创建时，你需要恢复Fragment状态。可以执行Fragment的onSaveInstanceState()来保存状态（注意在Fragment是在onCreate()，onCreateView()，或onActvityCreate()中进行恢复而不是像Activity在onRestoreInstanceState中恢复）。

　　在生命周期方面,Activity与Fragment之间一个**很重要的不同**，就是在各自的后台栈中是如何存储的。
　　当Activity停止时，**默认**情况下Activity被安置在由系统管理的Activity后台栈中；　
　　Fragment仅当在一个事务被移除时，通过显式调用addToBackStack()请求保存的实例，该Fragment才被置于由宿主Activity管理的后台栈。　

**要创建一个Fragment**，必须创建一个Fragment的子类。一般情况下，我们至少需要实现以下几个Fragment生命周期方法：

> onCreate()

　　在创建Fragment时系统会调用此方法。在实现代码中，你可以初始化想要在Fragment中保持的那些必要组件，当Fragment处于暂停或者停止状态之后可重新启用它们。

>onCreateView()

　　在第一次为Fragment绘制用户界面时系统会调用此方法。为Fragment绘制用户界面，这个函数必须要返回所绘出的Fragment的根View。如果Fragment没有用户界面可以返回空。


```java
@Override
		public View onCreateView(LayoutInflater inflater, ViewGroup container,Bundle savedInstanceState) {　
		
			// Inflate the layout for this Fragment
return inflater.inflate(R.layout.example_Fragment, container, false);
		}
```
inflate()函数需要以下三个参数：

①要inflate的布局的资源ID。　

②被inflate的布局的父ViewGroup。

③一个布尔值，表明在inflate期间被infalte的布局是否应该附上ViewGroup（第二个参数container）。（在这个例子中传入的是false，因为系统已经将被inflate的布局插入到容器中（container）——传入true会在最终的布局里创建一个多余的ViewGroup。）　

> onPause()

　　系统回调用该函数作为用户离开Fragment的第一个预兆（尽管这并不总意味着Fragment被销毁）。在当前用户会话结束之前，通常要在这里提交任何应该持久化的变化（因为用户可能不再返回）。

# 将Fragment添加到Activity之中

　　可以通过在Activity布局文件中声明Fragment，用Fragment标签把Fragment插入到Activity的布局中，或者是用应用程序源码将它添加到一个存在的ViewGroup中。　
但Fragment并不是一个定要作为Activity布局的一部分，Fragment也可以为Activity隐身工作。

## 在Activity的布局文件里声明Fragment

　　可以像为view一样为Fragment指定布局属性。例如：

```xml
<?xml version="1.0" encoding="utf-8"?>
	<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
		android:orientation="horizontal"
		android:layout_width="match_parent"
		android:layout_height="match_parent">　
		
		<Fragment android:name="com.example.test.FragmentOne"
				android:id="@+id/fo"
				android:layout_width="match_parent"
				android:layout_height="match_parent" />
	</LinearLayout>

```
　　Fragment标签中的android:name 属性指定了布局中实例化的Fragment类。

　　当系统创建Activity布局时，它实例化了布局文件中指定的每一个Fragment，并为它们调用onCreateView()函数，以获取每一个Fragment的布局。系统直接在\<Fragment\>元素的位置插入Fragment返回的View。

　　注意：每个Fragment都需要一个**唯一的标识**，如果重启Activity，系统可用来恢复Fragment（并且可用来捕捉Fragment的事务处理，例如移除）。为Fragment提供ID有三种方法：

 - 用android:id属性提供一个唯一的标识。　

 - 用android:tag属性提供一个唯一的字符串。　

 - 如果上述两个属性都没有，系统会使用其容器视图（view）的ID。　

## 通过编码将Fragment添加到已存在的ViewGroup中

　　在Activity运行的任何时候，你都可以将Fragment添加到Activity布局中。
　　要管理Activity中的Fragment，可以使用FragmentManager。可以通过在Activity中调用getFragmentManager()获得。使用FragmentManager 可以做如下事情，包括：

 - 使用findFragmentById()（用于在Activity布局中提供有界面的Fragment）或者findFragmentByTag()获取Activity中存在的Fragment（用于有界面或者没有界面的Fragment）。　　

 - 使用popBackStack()（模仿用户的BACK命令）从后台栈弹出Fragment。　　


 - 使用addOnBackStackChangedListener()注册一个监听后台栈变化的监听器。

在Android中，对Fragment的事务操作都是通过FragmentTransaction来执行。操作大致可以分为两类：

 - 显示：add() replace() show() attach()　　

 - 隐藏：remove() hide() detach()　

> 说明：
　　调用show() & hide()方法时，Fragment的**生命周期方法并不会被执行**，仅仅是Fragment的View被显示或者​隐藏。

>　　执行replace()时（至少两个Fragment），会执行第二个Fragment的onAttach()方法、执行第一个Fragment的onPause()-onDetach()方法，同时containerView会detach第一个Fragment的View。

>　　add()方法执行onAttach()-onResume()的生命周期，相对的remove()就是执行完成剩下的onPause()-onDetach()周期。


可以像下面这样从Activity中取得FragmentTransaction的实例：

```java
FragmentManager FragmentManager = getFragmentManager()　
FragmentTransaction FragmentTransaction = FragmentManager.beginTransaction();
```

可以用add()函数添加Fragment，并指定要添加的Fragment以及要将其插入到哪个视图（view）之中（注意commit事务）：

```java
ExampleFragment Fragment = new ExampleFragment();
FragmentTransaction.add(R.id.Fragment_container, Fragment);
FragmentTransaction.commit();
```

## 添加没有界面的Fragment 

　　也可以使用Fragment为Activity提供后台动作，却不呈现多余的用户界面。

　　想要添加没有界面的Fragment ，可以使用add(Fragment, String)（为Fragment提供一个唯一的字符串“tag”，而不是视图（view）ID）。这样添加了Fragment，但是，因为还没有关联到Activity布局中的视图（view） ，收不到onCreateView()的调用。所以不需要实现这个方法。　
　　
　　对于无界面Fragment，字符串标签是**唯一识别**它的方法。如果之后想从Activity中取到Fragment，需要使用findFragmentByTag()。　

# Fragment事务后台栈

　　在调用commit()之前，可以将事务添加到Fragment事务后台栈中（通过调用addToBackStatck()）。这个后台栈由Activity管理，并且允许用户通过按BACK键回退到前一个Fragment状态。

　　下面的代码中一个Fragment代替另一个Fragment，并且将之前的Fragment状态保留在后台栈中：

```java
 Fragment newFragment = new ExampleFragment();
 FragmentTransaction transaction = getFragmentManager().beginTransaction();
 
 transaction.replace(R.id.Fragment_container, newFragment);
 transaction.addToBackStack(null);

 transaction.commit();
```

> 注意：
> 
>　　 如果添加多个变更事务（例如另一个add()或者remove()）并调用addToBackStack()，那么在调用commit()之前的所有应用的变更被作为一个单独的事务添加到后台栈中，并且BACK键可以将它们一起回退。
> 
> 　　当移除一个Fragment时，如果调用了addToBackStack()，那么之后Fragment会被停止，如果用户回退，它将被恢复过来。
> 
>　　调用commit()并不立刻执行事务，相反，而是采取预约方式，一旦Activity的界面线程（主线程）准备好便可运行起来。然而，如果有必要的话，你可以从界面线程调用executePendingTransations()立即执行由commit()提交的事务。
> 
> 　　只能在Activity保存状态（当用户离开Activity时）之前用commit()提交事务。如果你尝试在那时之后提交，会抛出一个异常。这是因为如果Activity需要被恢复，提交后的状态会被丢失。对于这类丢失提交的情况，可使用commitAllowingStateLoss()

# 与Activity交互

 - Activity中已经有了该Fragment的引用，直接通过该引用进行交互。

- 如果没引用可以通过调用Fragment的函数findFragmentById()或者findFragmentByTag()，从FragmentManager中获取Fragment的索引，例如： 

```java
ExampleFragment Fragment = (ExampleFragment) getFragmentManager().findFragmentById(R.id.example_Fragment);
```

 - 在Fragment中可以通过getActivity得到当前绑定的Activity的实例。

 - 创建Activity事件回调函数，在Fragment内部定义一个回调接口，宿主Activity来实现它。

 - Activity向Fragment传参：

   > 很多人提到向Fragment传递参数会下意识想到重写Fragment的构造方法并传入自己的参数。事实上，这种方式时极不科学和极不安全的，因为Android在很多场景下都会出现Fragment的重建情况（比如横竖屏的切换），但是重建的时候系统并不会使用你编写的Fragment的构造方法而是调用Fragment默认的构造方法，这个时候你传的参数将会消失导致各种异常。那么如何更安全地向Fragment传递参数呢，这里建议大家使用Google官方推荐的setArguments方法：
   >
   > - 初始化Fragment实例并setArguments
   >
   >   ```java
   >   DiscoverFragment discoverFragment = new DiscoverFragment();
   >   Bundle bundle = new Bundle();
   >   bundle.putString("email", email);
   >   discoverFragment.setArguments(bundle);
   >   ```
   >
   > - 在Fragment中拿到Arguments：
   >
   > ```java
   > @Nullable
   >   @Override
   >   public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
   >       View view = inflater.inflate(R.layout.Fragment_discover, null);
   >       Bundle bundle = getArguments();
   >       //这里就拿到了之前传递的参数
   >       email = bundle.getString("email");
   >       return view;
   >   }
   > ```

# Fragment && Fragment 数据交互

Fragment和Fragment间数据交互，应该也是会经常用到的。我们可以使用宿主Activity做传递媒介。原理其实也是通过使用onActivityResult回调，完成Fragment && Fragment 的数据交互，这其中有两个比较重要的方法：Fragment.setTargetFragment、getTargetFragment()。

在 FirstFragment 中，通过setTargetFragment来连接需要交互的Fragment：

```java
secondFragment.setTargetFragment(FirstFragment.this, REQUEST_CODE);
```

接着实现onActivityResult,处理传递过来的数据：

```java
@Override  
   public void onActivityResult(int requestCode, int resultCode, Intent data) {  
       super.onActivityResult(requestCode, resultCode, data);  
       if(resultCode != Activity.RESULT_OK){  
           return;  
       }else{  
           Integer str = data.getIntExtra("key",-1);  
           //处理数据...
       }  
   }
```

在 SecondFragment 中调用sendResult（）方法，回传数据给 FirstFragment:

```java
private void sendResult(int resultOk) {  
        if(getTargetFragment() == null){  
            return;  
        }else{  
            Intent intent = new Intent();  
            intent.putExtra("key", 520);       			   			   getTargetFragment().onActivityResult(FirstFragment.REQUEST_CODE,resultOk,intent);  
        }  
    }
```



​	