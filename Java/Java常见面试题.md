# Java常见面试题

[TOC]

## 如何用数组实现队列？

用数组实现队列时要注意 **溢出** 现象，这时我们可以采用循环数组的方式来解决，即将数组收尾相接。使用front指针指向队列首位，tail指针指向队列末位。

---

## 内部类访问局部变量的时候，为什么变量必须加上final修饰？ 

因为生命周期不同。局部变量在方法结束后就会被销毁，但内部类对象并不一定，这样就会导致内部类引用了一个不存在的变量。

所以编译器会在内部类中生成一个局部变量的拷贝，这个拷贝的生命周期和内部类对象相同，就不会出现上述问题。

但这样就导致了其中一个变量被修改，两个变量值可能不同的问题。为了解决这个问题，编译器就要求局部变量需要被final修饰，以保证两个变量值相同。

在JDK8之后，编译器不要求内部类访问的局部变量必须被final修饰，但局部变量值不能被修改（无论是方法中还是内部类中），否则会报编译错误。利用javap查看编译后的字节码可以发现，编译器已经加上了final。

---

## long s = 499999999 \* 499999999 在上面的代码中，s的值是多少？

根据代码的计算结果，`s`的值应该是`-1371654655`，**这是由于Java中右侧值的计算默认是**`int`类型。

---

## NIO相关，Channels、Buffers、Selectors

`NIO(Non-blocking IO)`为所有的原始类型提供\(Buffer\)缓存支持，字符集编码解码解决方案。 `Channel` ：一个新的原始I\/O 抽象。 支持锁和内存映射文件的文件访问接口。提供多路\(non-bloking\) 非阻塞式的高伸缩性网络I\/O 。

| IO     | NIO      |
| ------ | -------- |
| 面向流 | 面向缓冲 |
| 阻塞IO | 非阻塞IO |
| 无     | 选择器   |

## 流与缓冲

Java NIO和IO之间第一个最大的区别是，**IO是面向流的，NIO是面向缓冲区的**。 Java IO面向流意味着每次从流中读一个或多个字节，直至读取所有字节，它们没有被缓存在任何地方。此外，它不能前后移动流中的数据。如果需要前后移动从流中读取的数据，需要先将它缓存到一个缓冲区。

Java NIO的缓冲导向方法略有不同。**数据读取到一个它稍后处理的缓冲区，需要时可在缓冲区中前后移动。这就增加了处理过程中的灵活性**。但是，还需要检查是否该缓冲区中包含所有您需要处理的数据。而且，需确保当更多的数据读入缓冲区时，不要覆盖缓冲区里尚未处理的数据。

## 阻塞与非阻塞IO

Java IO的各种流是阻塞的。这意味着，当一个线程调用`read()` 或 `write()`时，该线程被阻塞，直到有一些数据被读取，或数据完全写入。该线程在此期间不能再干任何事情了。 **Java NIO的非阻塞模式，是线程向某通道发送请求读取数据，仅能得到目前可用的数据，如果目前没有数据可用时，就什么都不会获取，当然它不会保持线程阻塞。所以直至数据变的可以读取之前，该线程可以继续做其他的事情**。 非阻塞写也是如此。所以一个单独的线程现在可以管理多个输入和输出通道。

## 选择器（Selectors）

Java NIO 的 **选择器允许一个单独的线程来监视多个输入通道**，你可以注册多个通道使用一个选择器，然后使用一个单独的线程来“选择”通道：这些通道里已经有可以处理的输入，或者选择已准备写入的通道。这种选择机制，使得一个单独的线程很容易来管理多个通道。

---

## 反射的用途

Java反射机制可以让我们在编译期\(Compile Time\)之外的运行期\(Runtime\)检查类，接口，变量以及方法的信息。反射还可以让我们在运行期实例化对象，调用方法，通过调用`get/set`方法获取变量的值。同时我们也可以通过反射来获取泛型信息，以及注解。还有更高级的应用--动态代理和动态类加载（`ClassLoader.loadclass()`）。

下面列举一些比较重要的方法：

* getFields：获取所有 `public` 的变量。
* getDeclaredFields：获取所有包括 `private` , `protected` 权限的变量。
* setAccessible：设置为 true 可以跳过Java权限检查，从而访问`private`权限的变量。
* getAnnotations：获取注解，可以用在类和方法上。

获取方法的泛型参数：

```Java
method = Myclass.class.getMethod("setStringList", List.class);

Type[] genericParameterTypes = method.getGenericParameterTypes();

for(Type genericParameterType : genericParameterTypes){
    if(genericParameterType instanceof ParameterizedType){
        ParameterizedType aType = (ParameterizedType) genericParameterType;
        Type[] parameterArgTypes = aType.getActualTypeArguments();
        for(Type parameterArgType : parameterArgTypes){
            Class parameterArgClass = (Class) parameterArgType;
            System.out.println("parameterArgClass = " + parameterArgClass);
        }
    }
}
```

动态代理：

```Java
//Main.java
public static void main(String[] args) {
    HelloWorld helloWorld=new HelloWorldImpl();
    InvocationHandler handler=new HelloWorldHandler(helloWorld);

    //创建动态代理对象
    HelloWorld proxy=(HelloWorld)Proxy.newProxyInstance(
            helloWorld.getClass().getClassLoader(),
            helloWorld.getClass().getInterfaces(),
            handler);
    proxy.sayHelloWorld();
}

//HelloWorldHandler.java
public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
    Object result = null;
    //调用之前
    doBefore();
    //调用原始对象的方法
    result=method.invoke(obj, args);
    //调用之后
    doAfter();
    return result;
}
```

通过反射获取方法注解的参数：

```Java
Class aClass = TheClass.class;
Annotation[] annotations = aClass.getAnnotations();

for(Annotation annotation : annotations){
   if(annotation instanceof MyAnnotation){
       MyAnnotation myAnnotation = (MyAnnotation) annotation;
       System.out.println("name: " + myAnnotation.name());
       System.out.println("value: " + myAnnotation.value());
   }
}
```

---

## Java注解的继承

|                                        | 有@Inherited | 没有@Inherited |
| -------------------------------------- | ------------ | -------------- |
| 子类的类上能否继承到父类的类上的注解？ | 否           | 能             |
| 子类实现了父类上的抽象方法             | 否           | 否             |
| 子类继承了父类上的方法                 | 能           | 能             |
| 子类覆盖了父类上的方法                 | 否           | 否             |

通过测试结果来看，`@Inherited` 只是可控制对类名上注解是否可以被继承。不能控制方法上的注解是否可以被继承。

***

## 非静态内部类能定义静态方法吗？

```Java
public class OuterClass{
    private static float f = 1.0f;

    class InnerClass{
        public static float func(){return f;}
    }
}
```

以上代码会出现编译错误，因为只有静态内部类才能定义静态方法。

***

## Lock 和 Synchronized 有什么区别？

    1. 使用方法的区别
    
    - **Synchronized**：在需要同步的对象中加入此控制，`synchronized`可以加在方法上，也可以加在特定代码块中，括号中表示需要锁的对象。
    
    - **Lock**：需要显示指定起始位置和终止位置。一般使用`ReentrantLock`类做为锁，多个线程中必须要使用一个`ReentrantLock`类做为对象才能保证锁的生效。且在加锁和解锁处需要通过`lock()`和`unlock()`显示指出。所以一般会在`finally`块中写`unlock()`以防死锁。
    
    2. 性能的区别
    
    `synchronized`是托管给JVM执行的，而`lock`是java写的控制锁的代码。在Java1.5中，`synchronize`是性能低效的。因为这是一个重量级操作，需要调用操作接口，导致有可能加锁消耗的系统时间比加锁以外的操作还多。相比之下使用Java提供的Lock对象，性能更高一些。但是到了Java1.6，发生了变化。`synchronize`在语义上很清晰，可以进行很多优化，有适应自旋，锁消除，锁粗化，轻量级锁，偏向锁等等。导致在Java1.6上`synchronize`的性能并不比Lock差。
    
      - **Synchronized**：采用的是CPU悲观锁机制，即线程获得的是独占锁。独占锁意味着 **其他线程只能依靠阻塞来等待线程释放锁**。而在CPU转换线程阻塞时会引起线程上下文切换，当有很多线程竞争锁的时候，会引起CPU频繁的上下文切换导致效率很低。
    
      - **Lock**：用的是乐观锁方式。所谓乐观锁就是，**每次不加锁而是假设没有冲突而去完成某项操作，如果因为冲突失败就重试，直到成功为止**。乐观锁实现的机制就是`CAS`操作。我们可以进一步研究`ReentrantLock`的源代码，会发现其中比较重要的获得锁的一个方法是`compareAndSetState`。这里其实就是调用的CPU提供的特殊指令。
    
    3. `ReentrantLock`：具有更好的可伸缩性：比如时间锁等候、可中断锁等候、无块结构锁、多个条件变量或者锁投票。

***

## float 变量如何与 0 比较？

folat类型的还有double类型的，**这些小数类型在趋近于0的时候直接等于0的可能性很小，一般都是无限趋近于0，因此不能用==来判断**。应该用`|x-0|<err`来判断，这里`|x-0|`表示绝对值，`err`表示限定误差。

```Java
//用程序表示就是

fabs(x) < 0.00001f
```

***

## 如何新建非静态内部类？

内部类在声明的时候必须是 `Outer.Inner a`，就像`int a` 一样，至于静态内部类和非静态内部类new的时候有点区别：

  - `Outer.Inner a = new Outer().new Inner()`（非静态，先有Outer对象才能 new 内部类）
  - `Outer.Inner a = new Outer.Inner()`（静态内部类）

***

## Java标识符命名规则

可以包含：字母、数字、$、`_`(下划线)，不可用数字开头，不能是 Java 的关键字和保留字。

***

## 你知道哪些JDK中用到的设计模式？

  * 装饰模式：java.io

  * 单例模式：Runtime类

  * 简单工厂模式：Integer.valueOf方法

  * 享元模式：String常量池、Integer.valueOf\(int i\)、Character.valueOf\(char c\)

  * 迭代器模式：Iterator

  * 职责链模式：ClassLoader的双亲委派模型

  * 解释器模式：正则表达式java.util.regex.Pattern

---

## ConcurrentHashMap如何保证线程安全

JDK 1.7及以前：

ConcurrentHashMap允许多个修改操作并发进行，其关键在于使用了锁分离技术。它使用了多个锁来控制对hash表的不同部分进行的修改。ConcurrentHashMap内部使用段\(Segment\)来表示这些不同的部分，每个段其实就是一个小的hash table，它们有自己的锁。只要多个修改操作发生在不同的段上，它们就可以并发进行。

详细参考：

[http:\/\/www.cnblogs.com\/ITtangtang\/p\/3948786.html](http://www.cnblogs.com/ITtangtang/p/3948786.html)

JDK 1.8：

Segment虽保留，但已经简化属性，仅仅是为了兼容旧版本。

插入时使用CAS算法：unsafe.compareAndSwapInt\(this, valueOffset, expect, update\)。 CAS\(Compare And Swap\)意思是如果valueOffset位置包含的值与expect值相同，则更新valueOffset位置的值为update，并返回true，否则不更新，返回false。插入时不允许key或value为null

与Java8的HashMap有相通之处，底层依然由“数组”+链表+红黑树；

底层结构存放的是TreeBin对象，而不是TreeNode对象；

CAS作为知名无锁算法，那ConcurrentHashMap就没用锁了么？当然不是，当hash值与链表的头结点相同还是会synchronized上锁，锁链表。

---

## i++在多线程环境下是否存在问题，怎么解决？

虽然递增操作++i是一种紧凑的语法，使其看上去只是一个操作，但这个操作并非原子的，因而它并不会作为一个不可分割的操作来执行。实际上，它包含了三个独立的操作：读取count的值，将值加1，然后将计算结果写入count。这是一个“读取 - 修改 - 写入”的操作序列，并且其结果状态依赖于之前的状态。所以在多线程环境下存在问题。

要解决自增操作在多线程环境下线程不安全的问题，可以选择使用Java提供的原子类，如AtomicInteger或者使用synchronized同步方法。

---

## new与newInstance()的区别

  * new是一个关键字，它是调用new指令创建一个对象，然后调用构造方法来初始化这个对象，可以使用带参数的构造器

  * newInstance()是Class的一个方法，在这个过程中，是先取了这个类的不带参数的构造器Constructor，然后调用构造器的newInstance方法来创建对象。

  > Class.newInstance不能带参数，如果要带参数需要取得对应的构造器，然后调用该构造器的Constructor.newInstance(Object ... initargs)方法

---

## 你了解哪些JDK1.8的新特性？

  * 接口的默认方法和静态方法，JDK8允许我们给接口添加一个非抽象的方法实现，只需要使用default关键字即可。也可以定义被static修饰的静态方法。

  * 对HashMap进行了改进，当单个桶的元素个数大于6时就会将实现改为红黑树实现，以避免构造重复的hashCode的攻击

  * 多并发进行了优化。如ConcurrentHashMap实现由分段加锁、锁分离改为CAS实现。

  * JDK8拓宽了注解的应用场景，注解几乎可以使用在任何元素上，并且允许在同一个地方多次使用同一个注解

  * Lambda表达式

---

## 你用过哪些JVM参数？

  - Xms 堆最小值

  - Xmx 堆最大值

  - Xmn: 新生代容量

  - XX:SurvivorRatio 新生代中Eden与Surivor空间比例

  - Xss 栈容量

  - XX:PermSize 方法区初始容量

  - XX:MaxPermSize 方法区最大容量

  - XX:+PrintGCDetails 收集器日志参数

***

## 如何打破 ClassLoader 双亲委托？

重写`loadClass()`方法。

***

## hashCode() && equals()

`hashcode()` 返回该对象的哈希码值，支持该方法是为哈希表提供一些优点，例如，`java.util.Hashtable` 提供的哈希表。   

在 Java 应用程序执行期间，在同一对象上多次调用 `hashCode` 方法时，必须一致地返回相同的整数，前提是对象上 `equals` 比较中所用的信息没有被修改（`equals`默认返回对象地址是否相等）。如果根据 `equals(Object) `方法，两个对象是相等的，那么在两个对象中的每个对象上调用 `hashCode` 方法都必须生成相同的整数结果。

以下情况不是必需的：如果根据 `equals(java.lang.Object)` 方法，两个对象不相等，那么在两个对象中的任一对象上调用 `hashCode` 方法必定会生成不同的整数结果。但是，**程序员应该知道，为不相等的对象生成不同整数结果可以提高哈希表的性能**。   

实际上，由 `Object` 类定义的 `hashCode` 方法确实会针对不同的对象返回不同的整数。（**这一般是通过将该对象的内部地址转换成一个整数来实现的，但是 JavaTM 编程语言不需要这种实现技巧I**。）   

  - **hashCode的存在主要是用于查找的快捷性**，如 Hashtable，HashMap等，hashCode 是用来在散列存储结构中确定对象的存储地址的；

  - 如果两个对象相同，就是适用于 `equals(java.lang.Object)` 方法，那么这两个对象的 `hashCode` 一定要相同；

  - 如果对象的 `equals` 方法被重写，那么对象的 `hashCode` 也尽量重写，并且产生 `hashCode` 使用的对象，一定要和 `equals` 方法中使用的一致，否则就会违反上面提到的第2点；

  - **两个对象的hashCode相同，并不一定表示两个对象就相同，也就是不一定适用于equals(java.lang.Object) 方法，只能够说明这两个对象在散列存储结构中，如Hashtable，他们“存放在同一个篮子里”**。

***

## Thread.sleep() & Thread.yield()&Thread.wait()的区别

sleep()和yield()都会释放CPU。

sleep()可使优先级低的线程得到执行的机会，当然也可以让同优先级和高优先级的线程有执行的机会；yield()只能使**同优先级**的线程有执行的机会。

Thread.sleep和Thread.yield()不会导致锁行为的改变，如果当前线程是拥有锁的，那么Thread.sleep不会让线程释放锁。如果能够帮助你记忆的话，可以简单认为和锁相关的方法都定义在Object类中，因此调用Thread.sleep是不会影响锁的相关行为。

Thread.sleep和Object.wait都会暂停当前的线程，对于CPU资源来说，不管是哪种方式暂停的线程，都表示它暂时不再需要CPU的执行时间。OS会将执行时间分配给其它线程。区别是，调用wait后，需要别的线程执行notify/notifyAll才能够重新获得CPU执行时间。

##  arraylist 和 linkedlist 的区别？

ArrayList和LinkedList两者都实现了List接口，但是它们之间有些不同。 

（1）ArrayList是由Array所支持的基于一个索引的数据结构，所以它提供对元素的随机访问 

（2）与ArrayList相比，在LinkedList中插入、添加和删除一个元素会更快 

（3）LinkedList比ArrayList消耗更多的内存，因为LinkedList中的每个节点存储了前后节点的引用

## 你用过哪些集合类？

> ArrayList、HashMap、TreeMap和HashTable类提供对元素的随机访问。

**线程安全**

> Vector HashTable(不允许插空值)

**非线程安全**

> ArrayList LinkedList HashMap(允许插入空值) HashSet TreeSet TreeMap(基于红黑树的Map实现)

### 

## concurrentMap 和 HashMap 区别

1.**hashMap可以有null的键**，concurrentMap不可以有

 2.hashMap是线程不安全的，在多线程的时候需要Collections.synchronizedMap(hashMap),ConcurrentMap使用了重入锁保证线程安全。

 3.在删除元素时候，两者的算法不一样。 `ConcurrentHashMap`和`Hashtable`主要区别就是围绕着锁的粒度以及如何锁,可以简单理解成把一个大的HashTable分解成多个，形成了锁分离。

## Java中HashMap的key值要是为类对象则该类需要满足什么条件？

需要同时重写该类的hashCode()方法和它的equals()方法。

> 当程序试图将一个 key-value 对放入 HashMap 中时，程序首先根据该 key 的 hashCode() 返回值决定该 Entry 的存储位置：如果两个 Entry 的 key 的 hashCode() 返回值相同，那它们的存储位置相同。如果这两个 Entry 的 key 通过 equals 比较返回 true，新添加 Entry 的 value 将覆盖集合中原有 Entry 的 value，但 key 不会覆盖。如果这两个 Entry 的 key 通过 equals 比较返回 false，新添加的 Entry 将与集合中原有 Entry 形成 Entry 链，而且新添加的 Entry 位于 Entry 链的头部——具体说明继续看 addEntry() 方法的说明。

## 关于抽象类和接口的关系

简言之抽象类是一种功能不全的类，接口只是一个抽象方法声明和静态不能被修改的数据的集合，两者都不能被实例化。 从某种意义上说，接口是一种特殊形式的抽象类，在java语言中抽象类表示的是一种继承关系，一个类只能继承继承一个抽象类，而一个类却可以实现多个接口。在许多情况下，接口确实可以代替抽象类，如果你不需要刻意表达属性上的继承的话。

## 堆内存和栈内存的区别

**寄存器**：JVM内部虚拟寄存器，存取速度非常快，程序不可控制。

 **栈**：保存局部变量的值包括：1.保存基本数据类型的值；2.保存引用变量，即堆区对象的引用(指针)。也可以用来保存加载方法时的帧。

 **堆**：用来存放动态产生的数据，比如new出来的对象。注意创建出来的对象只包含属于各自的成员变量，并不包括成员方法。因为同一个类的对象拥有各自的成员变量，存储在各自的堆中，但是他们共享该类的方法，并不是每创建一个对象就把成员方法复制一次。

 **常量池**：JVM为每个已加载的类型维护一个常量池，常量池就是这个类型用到的常量的一个有序集合。包括直接常量(基本类型，String)和对其他类型、方法、字段的符号引用(1)。池中的数据和数组一样通过索引访问。由于常量池包含了一个类型所有的对其他类型、方法、字段的符号引用，所以常量池在Java的动态链接中起了核心作用。常量池存在于堆中。

 **代码段**：用来存放从硬盘上读取的源程序代码。 

**数据段**：用来存放static修饰的静态成员（在java中static的作用就是说明该变量，方法，代码块是属于类的还是属于实例的）。

![image-20190226202415923](https://ws1.sinaimg.cn/large/006tKfTcgy1g0k3h9cahzj30zg0j644a.jpg)

## 关于重载和重写的区别

重载是overload，是一个类中同方法名的不同具体实现。然后重写是override，是子类重写父类中的方法。

## String、StringBuffer与StringBuilder之间区别

三者在执行速度方面的比较：StringBuilder >  StringBuffer  >  String

String：字符串常量

StringBuffer：字符串变量 

StringBuilder：字符串变量

StringBuilder：线程非安全的

StringBuffer：线程安全的

 **对于三者使用的总结： ** 

1.如果要操作少量的数据用 = String

2.单线程操作字符串缓冲区 下操作大量数据 = StringBuilder 

3.多线程操作字符串缓冲区 下操作大量数据 = StringBuffer

## java运行时异常与一般异常有何异同？

运行时异常：由java虚拟机抛出的异常。用户不必处理。

一般异常:用户可以抛出的异常，如果抛出调用必须进行处理。

运行时异常表示虚拟机的通常操作中可能遇到的异常，是一种常见运行错误。java编译器要求方法必须声明抛出可能发生的非运行时异常，但是并不要求必须声明抛出未被捕获的运行时异常。

从机制角度来讲:

**Runtime exceptions:**

　　在定义方法时不需要声明会抛出runtime exception;在调用这个方法时不需要捕获这个runtime exception;runtime exception是从java.lang.RuntimeException或java.lang.Error类衍生出来的。

**Checked exceptions:**

　定义方法时必须声明所有可能会抛出的checked exception; 
在调用这个方法时，必须捕获它的checked exception，不然就得把它的exception传递下去;checked exception是java.lang.Exception类衍生出来的。

从逻辑的角度来说， checked exceptions和runtime exception是有不同的使用目的的。checked exception用来指示一种调用方能够直接处理的异常情况。而runtime exception则用来指示一种调用方本身无法处理或恢复的程序错误。

## error和exception有什么区别? 

error 表示恢复不是不可能但很困难的情况下的一种严重问题。比如说内存溢出。不可能指望程序能处理这样的情况。 exception表示一种设计或实现问题。也就是说，它表示如果程序运行正常，从不会发生的情况。

## java中有几种方法可以实现一个线程?

- class ThreadA extends Thread{},然后重写run方法 
- class ThreadB implements Runnable{},然后重写run方法 
- class ThreadC implements Callable{},然后new FutureTask(threadC),再用new Thread(future)封装。

## java在处理线程同步时，常用方法有?

1、synchronized关键字。

2、Lock显示加锁。 

3、信号量Semaphore。 

4、CAS算法 

5、concurrent包

## 进程与线程的区别，及其通信方式

区别 

1.一个程序至少有一个进程,一个进程至少有一个线程. 

2.进程在执行过程中拥有独立的内存单元，而多个线程共享内存 

3.线程是进程的一个实体,是CPU调度和分派的基本单位

进程间通信

```
1.管道（Pipe）及有名管道（named pipe）
2.信号（Signal）
3.消息队列（Message）
4.共享内存
5.信号量（semaphore）
6.套接口（Socket）
```

## 线程池用过吗？

线程池（Thread Pool）对于限制应用程序中同一时刻运行的线程数很有用。因为每启动一个新线程都会有相应的性能开销，每个线程都需要给栈分配一些内存等等。

我们可以把并发执行的任务传递给一个线程池，来替代为每个并发执行的任务都启动一个新的线程。只要池里有空闲的线程，任务就会分配给一个线程执行。在线程池的内部，任务被插入一个阻塞队列（Blocking Queue ），线程池里的线程会去取这个队列里的任务。当一个新任务插入队列时，一个空闲线程就会成功的从队列中取出任务并且执行它。

## int与Integer的区别，分别什么场合使用

```
1、Integer是int提供的封装类，而int是Java的基本数据类型
2、Integer默认值是null，而int默认值是0；
3、声明为Integer的变量需要实例化，而声明为int的变量不需要实例化；
4、Integer是对象，用一个引用指向这个对象，而int是基本类型，直接存储数值。

复制代码
```

`int`是基本数据类型，`Integer`是包装类，类似HashMap这样的结构必须使用包装类，因为包装类继承自Object,都需要实现HashCode，所以可以使用在HashMap这类数据结构中。

## 为什么在for…each中删除或者add元素会抛出异常（ConcurrentModificationException）？

使用for..each进行遍历的时候实际上使用的是迭代器（Iterator），在使用Iterator的时候需要考虑fail-fast机制，即当多个线程对非fast fail的集合类进行结构上的改变时，也就是说当方法检测到有多个线程并发对该对象修改时就会抛出异常来禁止多线程同时对该对象的修改。在foreach中虽然只有一个线程，但是我们在遍历的时候使用的是Iterator，但是在add/remove的时候却使用的是对象本身的add/remove方法，这样当Iterator下一次遍历的时候发现对象的结构被改变了，而且不是自己改变的，就会认为可能是其他线程并发对其进行了修改，这时候就会抛出异常。

## 垃圾回收机制。。。(主要从下面几方面解答 GC原理、最好画图解释一下年轻代（Eden区和Survival区）、年老代、比例分配及为啥要这样分代回收)

## 对象分配问题，堆栈里的问题，详细的会问道方法区、堆、程序计数器、本地方法栈、虚拟机栈，问题入口从String a,new String("")开始

## 关键字，private protected public static final 组合着问

## Object类里面有哪几种方法，作用

## equals 和 hashCode方法，重写equals的原则()

## 向上转型

## Java引用类型(强引用，软引用，弱引用，虚引用)

## 线程相关的，主要是volitate，synchorized，wait()，notify()，notifyAll()，join()

## Exception和Error

## 反射的用途

## HashMap实现原理(数组+链表)，查找数据的时间复杂度

## List有哪些子类，各有什么区别

## NIO相关，缓冲区、通道、selector。。。(不熟，面了这么多，挂在这里。其实主要是表现在同步阻塞和异步，传输方式不同。标准IO无法实现非阻塞模式、文件锁、读选择、分散聚集等)

## 内存泄露，举个例子

## OOM是怎么出现的，有哪几块JVM区域会产生OOM，如何解决(对于该问题，建议去《Java特种兵》的3.6章)

## Java里面的观察者模式实现

## 单例实现(我一般用enum写，不容易被挑毛病)

## 用Java模拟一个栈，并能够做到扩容，并且能有同步锁。（用数组实现）

## Java泛型机制，泛型机制的优点，以及类型变量