# Java

## java中的数据类型

变量就是申请内存来存储值。也就是说，当创建变量的时候，需要在内存中申请空间。

内存管理系统根据变量的类型为变量分配存储空间，分配的空间只能用来储存该类型数据。
因此，通过定义不同类型的变量，可以在内存中储存整数、小数或者字符。

Java的两大数据类型:

### 内置数据类型(基本数据类型)

　　1 六种数字类型 ( byte, short, int, long, float, double)      +   void

　　　　　　　　　     8      16     32   64     32     64    位

　　2 一种字符类型  char

　　　　　　　　　　16位Unicode字符

　　3 一种布尔型    boolean

　　　　　　　　　　1位

### 关于Integer

对于两个非new生成的Integer对象，进行比较时，如果两个变量的值在区间-128到127之间，则比较结果为true，如果两个变量的值不在此区间，则比较结果为false

```java
Integer i = 100;
Integer j = 100;
System.out.print(i == j); //true

Integer i = 128;
Integer j = 128;

System.out.print(i == j); //false
```

 java在编译Integer i = 100 ;时，会翻译成为Integer i = Integer.valueOf(100)。而java API中对Integer类型的valueOf的定义如下，对于-128到127之间的数，会进行缓存，Integer i = 127时，会将127进行缓存，下次再写Integer j = 127时，就会直接从缓存中取，就不会new了。

```java
public static Integer valueOf(int i){
    assert IntegerCache.high >= 127;
    if (i >= IntegerCache.low && i <= IntegerCache.high){
        return IntegerCache.cache[i + (-IntegerCache.low)];
    }
    return new Integer(i);

}
```



### 引用数据类型

　　引用类型变量由类的构造函数创建，可以使用它们访问所引用的对象。这些变量在声明时被指定为一个特定的类型。变量一旦声明后，类型就不能被改变了。

对象、数组都是引用数据类型，所有引用类型的默认值都是null。

 基本数据类型只能按值传递，而封装类按引用传递。

 Void无返回值类型，作为伪类型对应类的对象，也被认为是 基本数据类型

## java中的修饰符

![image-20190317190424510](https://ws4.sinaimg.cn/large/006tKfTcgy1g15zy29r4oj30hu0b4jsn.jpg)

## 关于static

static修饰符表示静态的，在类加载时Jvm会把它放到**方法区**，被本类以及本类的所有实例所共用。在编译后所分配的内存会**一直存在**，直到程序退出内存才会释放这个空间。如果一个被所有实例共用的方法被申明为static，那么就可以节省空间，不用每个实例初始化的时候都被分配到内存。

java类被加载过程：

类装载器把一个类装入Java虚拟机中，要经过三个步骤来完成：

 ①加载（以二进制形式来生成Class对象） 

 ②链接（又分为验证、准备和解析） 　　　　

 	校验：检查导入类或接口的二进制数据的正确性； 　　　　

​	 准备：**给类的静态变量分配并初始化存储空间**； 　　　　

​	 解析：将符号引用转成直接引用； 

③初始化（**激活类的静态变量和静态代码块**、初始化Java代码）

- 静态变量

- 静态方法

- 静态代码块

  静态代码块就是在类加载器加载对象时，要执行的一组语句。静态块只会在类加载到内存中的时候执行一次，位置可以随便放，如果static代码块有多个，JVM将按照它们在类中出现的先后顺序依次执行它们，每个代码块只会被执行一次。

  ```
  static{
      //在类被加载的时候用于初始化资源，仅能访问静态变量和静态方法
      System.out.println("StaticExample static block");
  }
  ```

- 静态类

  **只能在内部类中定义静态类**，静态内部类与外层类绑定，即使没有创建外层类的对象，它一样存在。静态类的方法可以是静态的方法也可以是非静态的方法，静态的方法可以在外层通过静态类调用，而非静态的方法必须要创建类的对象之后才能调用。只能引用外部类的static成员变量（也就是类变量），当然前提是满足修饰关键字（public等）的可见性要求。

  　　如果一个内部类不是被定义成静态内部类，那么**在定义成员变量或者成员方法的时候，是不能够被定义成静态的。** 　　

  ```java
  public class OuterClass {  
      public static class InnerClass{  
          InnerClass(){  
              System.out.println("静态内部类");  
          }  
      }  
  }  
  ```

## 面向对象基础

面向对象三要素：封装、继承、多态

- `封装`：封装的意义，在于明确标识出允许外部使用的所有成员函数和数据项，或者叫接口。
- 继承：
  - 继承基类的方法，并做出自己的扩展；
  - 声明某个子类兼容于某基类（或者说，接口上完全兼容于基类），外部调用者可无需关注其差别（内部机制会自动把请求派发`dispatch`到合适的逻辑）。
- `多态`：基于对象所属类的不同，外部对同一个方法的调用，实际执行的逻辑不同。**很显然，多态实际上是依附于继承的第二种含义的**。

### 多态

方法签名：`方法名 + 参数列表(参数类型、个数、顺序)`

#### 重写

子类重写父类方法，**只有实例方法可以被重写**，重写后的方法必须仍为实例方法。**成员变量和静态方法都不能被重写，只能被隐藏**。

重写实例方法：超类Parent中有实例方法A，子类child定义了与A **相同签名和子集返回类型** 的实例方法B，子类对象ChildObj只能调用自己的实例方法B。

方法的重写（override）两同两小一大原则：

1. 方法名相同，参数类型相同
2. 子类返回类型小于等于父类方法返回类型
3. 子类抛出异常小于等于父类方法抛出异常
4. 子类访问权限大于等于父类方法访问权限

注意：

- 不能重写static静态方法。(形式上可以写，但本质上不是重写，属于下面要讲的隐藏)
- 重写方法可以改变它的方法修饰符，如`final`,`synchronized`,`native`。不管被重写方法中有无final修饰的参数，重写方法都可以增加、保留、去掉这个参数的 final 修饰符(**参数修饰符不属于方法签名**)。

#### 重载

在同一个类中，有多个方法名相同，参数列表不同（参数个数不同，参数类型不同），与方法的返回值无关，与权限修饰符无关。**编译器通过对方法签名的识别即可静态编译出不同的方法。这也是java中重载与重写的区别之一**。

重载只是一种语言特性，与多态无关，与面向对象也无关。**多态是为了实现接口重用**。

Java中方法是可以和类名同名的，和构造方法唯一的区别就是，**构造方法没有返回值**。

#### 隐藏

隐藏与覆盖在形式上极其类似(语法规则)，但有着本质的区别：只有成员变量(不管是不是静态)和静态方法可以被隐藏。

##### 成员变量

超类 Parent 中有成员变量 A ，子类 Child 定义了与 A 同名的成员变量 B ，子类对象 ChildObj 调用的是自己的成员变量 B。如果把子类对象 ChildObj 转换为超类对象 ParentObj ，ParentObj 调用的是超类的成员变量 A ！

1. 隐藏成员变量时，只要同名即可，可以更改变量类型(无论基本类型还是隐藏类型)
2. 不能隐藏超类中的 private 成员变量，换句话说，只能隐藏可以访问的成员变量。
3. 隐藏超类成员变量 A 时，可以降低或提高子类成员变量B的访问权限，只要A不是 private。
4. 隐藏成员变量与是否静态无关！静态变量可以隐藏实例变量，实例变量也可以隐藏静态变量。
5. 可以隐藏超类中的final成员变量。

##### 静态方法

超类 Parent 有静态方法 A ，子类 Child 定义了与 A *相同签名和子集返回类型* 的静态方法 B ，子类对象 ChildObj 调用的是自己的静态方法 B 。如果把子类对象 ChildObj 转换为超类对象 ParentObj ，ParentObj 调用的是超类的静态方法 A ！

> 隐藏后的方法必须仍为静态方法



## Java虚函数、抽象函数、抽象类、接口

### Java虚函数

虚函数的存在是为了多态。

它虚就虚在所谓“推迟联编”或者“动态联编”上，一个类函数的调用并不是在编译时刻被确定的，而是在运行时刻被确定的。由于编写代码的时候并不能确定被调用的是基类的函数还是哪个派生类的函数，所以被成为“虚”函数。

C++中普通成员函数加上virtual关键字就成为虚函数

Java中其实没有虚函数的概念，它的普通函数就相当于C++的虚函数，动态绑定是Java的默认行为。如果Java中不希望某个函数具有虚函数特性，可以加上final关键字变成非虚函数

PS: 其实C++和Java在虚函数的观点大同小异，异曲同工罢了。

### Java抽象函数(纯虚函数)

抽象函数或者说是纯虚函数的存在是为了定义接口。

C++中纯虚函数形式为：virtual void print() = 0;

Java中纯虚函数形式为：abstract void print();

PS: 在抽象函数方面C++和Java还是换汤不换药。

###  Java抽象类

抽象类的存在是因为父类中既包括子类共性函数的具体定义，也包括需要子类各自实现的函数接口。抽象类中可以有数据成员和非抽象方法。

C++中抽象类只需要包括纯虚函数，既是一个抽象类。如果仅仅包括虚函数，不能定义为抽象类，因为类中其实没有抽象的概念。

Java抽象类是用abstract修饰声明的类。

PS: 抽象类其实是一个半虚半实的东西，可以全部为虚，这时候变成接口。

### Java接口

接口的存在是为了形成一种规约。接口中不能有普通成员变量，也不能具有非纯虚函数。

C++中接口其实就是**全虚基类**。

Java中接口是用interface修饰的类。

PS: 接口就是虚到极点的抽象类。

### 抽象类和接口的区别

接口不是类，抽象类是一个功能不齐全的类，都不能实例化对象。

一个类可以实现（implements）多个接口。一个类只能继承（extends）一个抽象类。

接口没有构造函数，所有方法都是 public abstract的，一般不定义成员变量。（所有的成员变量都是 static final ，而且必须显示初始化）。 　　抽象类除了不能实例化对象之外，类的其它功能依然存在，成员变量、成员方法和构造方法的访问方式和普通类一样。

一个实现接口的类，必须实现接口内所描述的所有方法（**所有方法都是抽象的方法**），否则就必须声明为抽象类。　 　　

如果一个类包含抽象方法，那么该类必须是抽象类。任何子类必须重写父类的抽象方法，或者声明自身为抽象类。

###  小结

C++虚函数    ==  Java普通函数

C++纯虚函数  ==  Java抽象函数

C++抽象类    ==  Java抽象类

C++虚基类    ==  Java接口



## 运算符优先级

优先级从上到下依次递减，最上面具有最高的优先级，逗号操作符具有最低的优先级。

相同优先级中，按结合顺序计算。**大多数运算是从左至右计算，只有三个优先级是从右至左结合的，它们是单目运算符、条件运算符、赋值运算符**。

基本的优先级需要记住：

- 指针最优，单目运算优于双目运算。如正负号。
- 先乘除（模），后加减。
- 先算术运算，后移位运算，最后位运算。请特别注意：`1 << 3 + 2 & 7`等价于 `(1 << (3 + 2)) & 7`.
- 逻辑运算最后计算。

#### 优先级表

| 运算符                                 | 结合性   |
| -------------------------------------- | -------- |
| [ ] . ( ) (方法调用)                   | 从左向右 |
| ! ~ ++ -- +(一元运算) -(一元运算)      | 从右向左 |
| * / %                                  | 从左向右 |
| + -                                    | 从左向右 |
| << >> >>>                              | 从左向右 |
| < <= > >= instanceof                   | 从左向右 |
| == !=                                  | 从左向右 |
| &                                      | 从左向右 |
| ^                                      | 从左向右 |
| \|                                     | 从左向右 |
| &&                                     | 从左向右 |
| \|\|                                   | 从左向右 |
| ?:                                     | 从右向左 |
| = += -= *= /= %= &= \|= ^= <<= >>= >>= | 从右向左 |
| ，                                     | 从左到右 |

## Object有哪些公用方法？**

`protected Object clone() `创建并返回此对象的一个副本。

`boolean equals(Object obj) `指示其他某个对象是否与此对象“相等”。

`protected void finalize() `当垃圾回收器确定不存在对该对象的更多引用时，由对象的垃圾回收器调用此方法。

`Class getClass()` 返回此 Object 的运行时类。

`int	hashCode() `返回该对象的哈希码值。

`void	notify() `唤醒在此对象监视器上等待的单个线程。

`void	notifyAll() `唤醒在此对象监视器上等待的所有线程。

`String	toString() `返回该对象的字符串表示。

`void	wait() `在其他线程调用此对象的 notify() 方法或 notifyAll() 方法前，导致当前线程等待。

`void	wait(long timeout) `在其他线程调用此对象的 notify() 方法或 notifyAll() 方法，或者超过指定的时间量前，导致当前线程等待。

`void	wait(long timeout, int nanos)` 在其他线程调用此对象的 notify() 方法或 notifyAll() 方法，或者其他某个线程中断当前线程，或者已超过某个实际时间量前，导致当前线程等待。

## Java和C++的对比**

- 多继承
- 内存管理
- Java 没有函数，作为一个比 C++更纯的面向对象的语言。Java 强迫开发人员把所有例行程序包括在类中。事实上，用方法实现例行程序可激励开发人员更好地组织编码
- goto语句
- 数据类型转换，在 C 和 C++中，有时出现数据类型的隐含转换，这就涉及了自动强制类型转换问题。例如，在 C++中可将一个浮点值赋予整型变量，并去掉其尾数。Java 不支持 C++中的自动强制类型转换，如果需要，必须由程序显式进行强制类型转换。 

## 集合框架

java集合框架的组成部分：

![2](https://ws3.sinaimg.cn/large/006tKfTcgy1g15n7q3wgzj30s10g4dhp.jpg)

### Collection和Collections的区别

Collection：

![1](https://ws2.sinaimg.cn/large/006tKfTcgy1g15n3fl6rfj30h2067q31.jpg)

Collection是集合继承结构中的顶层接口（interface），其是Iterable的子类。

Collections 是提供了对集合进行操作的强大方法的工具类 ，它包含有各种有关集合操作的静态多态方法。此类不能实例化（其构造函数是private的，该类中的方法都是static的可以直接调用）

### Collection

- `ArrayList`：线程不同步。默认初始容量为10，当数组大小不足时增长率为当前长度的`50%`。
- `Vector`：**线程同步**。默认初始容量为10，当数组大小不足时增长率为当前长度的`100%`。它的同步是通过`Iterator`方法加`synchronized`实现的。
- `LinkedList`：线程不同步。**双端队列形式**。
- `Stack`：**线程同步**。继承自`Vector`，添加了几个方法来完成栈的功能。
- `Set`：Set是一种不包含重复元素的Collection，Set最多只有一个null元素。
- `HashSet`：线程不同步，内部使用`HashMap`进行数据存储，提供的方法基本都是调用`HashMap`的方法，所以两者本质是一样的。**集合元素可以为**`NULL`。
- `NavigableSet`：添加了搜索功能，可以对给定元素进行搜索：小于、小于等于、大于、大于等于，放回一个符合条件的最接近给定元素的 key。
- `TreeSet`：线程不同步，内部使用`NavigableMap`操作。默认元素“自然顺序”排列，可以通过`Comparator`改变排序。
- `EnumSet`：线程不同步。内部使用Enum数组实现，速度比`HashSet`快。**只能存储在构造函数传入的枚举类的枚举值**。

### Map

- `HashMap`：线程不同步。根据`key`的`hashcode`进行存储，内部使用静态内部类`Node`的数组进行存储，默认初始大小为16，每次扩大一倍。当发生Hash冲突时，采用拉链法（链表）。**可以接受为null的键值(key)和值(value)**。JDK 1.8中：当单个桶中元素个数大于等于8时，链表实现改为红黑树实现；当元素个数小于6时，变回链表实现。由此来防止hashCode攻击。
- `LinkedHashMap`：**保存了记录的插入顺序**，在用Iterator遍历LinkedHashMap时，先得到的记录肯定是先插入的. 也可以在构造时用带参数，按照应用次数排序。在遍历的时候会比HashMap慢，不过有种情况例外，当HashMap容量很大，实际数据较少时，遍历起来可能会比LinkedHashMap慢，因为LinkedHashMap的遍历速度只和实际数据有关，和容量无关，而HashMap的遍历速度和他的容量有关。
- `TreeMap`：线程不同步，基于 **红黑树** （Red-Black tree）的NavigableMap 实现，**能够把它保存的记录根据键排序,默认是按键值的升序排序，也可以指定排序的比较器，当用Iterator 遍历TreeMap时，得到的记录是排过序的。**
- `HashTable`：线程安全，HashMap的迭代器(Iterator)是`fail-fast`迭代器。**HashTable不能存储NULL的key和value。**

### 工具类

- `Collections`、`Arrays`：集合类的一个工具类/帮助类，其中提供了一系列静态方法，用于对集合中元素进行排序、搜索以及线程安全等各种操作。

- Comparable，Comparator：一般是用于对象的比较来实现排序，两者略有区别。

  > - 类设计者没有考虑到比较问题而没有实现Comparable接口。这是我们就可以通过使用Comparator，这种情况下，我们是不需要改变对象的。
  > - 一个集合中，我们可能需要有多重的排序标准，这时候如果使用Comparable就有些捉襟见肘了，可以自己继承Comparator提供多种标准的比较器进行排序。

## Java分派机制

在Java中，符合“编译时可知，运行时不可变”这个要求的方法主要是静态方法和私有方法。这两种方法都不能通过继承或别的方法重写，因此它们适合在类加载时进行解析。

Java虚拟机中有四种方法调用指令：

- `invokestatic`：调用静态方法。
- `invokespecial`：调用实例构造器方法，私有方法和super。
- `invokeinterface`：调用接口方法。
- `invokevirtual`：调用以上指令不能调用的方法（虚方法）。

只要能被`invokestatic`和`invokespecial`指令调用的方法，都可以在解析阶段确定唯一的调用版本，符合这个条件的有：静态方法、私有方法、实例构造器、父类方法，他们在类加载的时候就会把符号引用解析为该方法的直接引用。这些方法被称为非虚方法，反之其他方法称为虚方法（final方法除外）。

> 虽然final方法是使用`invokevirtual `指令来调用的，但是由于它无法被覆盖，多态的选择是唯一的，所以是一种非虚方法。

### 静态分派

> 对于类字段的访问也是采用静态分派

```
People man = new Man()
```

**静态分派主要针对重载**，方法调用时如何选择。在上面的代码中，`People`被称为变量的引用类型，`Man`被称为变量的实际类型。**静态类型是在编译时可知的，而动态类型是在运行时可知的**，编译器不能知道一个变量的实际类型是什么。

**编译器在重载时候通过参数的静态类型而不是实际类型作为判断依据**。并且静态类型在编译时是可知的，所以编译器根据重载的参数的静态类型进行方法选择。

> 在某些情况下有多个重载，那编译器如何选择呢？ 编译器会选择"最合适"的函数版本，那么怎么判断"最合适“呢？越接近传入参数的类型，越容易被调用。

### 动态分派

动态分派主要针对重写，使用`invokevirtual`指令调用。`invokevirtual`指令多态查找过程：

- 找到操作数栈顶的第一个元素所指向的对象的实际类型，记为C。
- 如果在类型C中找到与常量中的描述符合简单名称都相符的方法，则进行访问权限校验，如果通过则返回这个方法的直接引用，查找过程结束；如果权限校验不通过，返回java.lang.IllegalAccessError异常。
- 否则，按照继承关系从下往上一次对C的各个父类进行第2步的搜索和验证过程。
- 如果始终没有找到合适的方法，则抛出 java.lang.AbstractMethodError异常。

### 虚拟机动态分派的实现

由于动态分派是非常繁琐的动作，而且动态分派的方法版本选择需要考虑运行时在类的方法元数据中搜索合适的目标方法，**因此在虚拟机的实现中基于性能的考虑，在方法区中建立一个虚方法表**（`invokeinterface `有接口方法表），来提高性能。

虚方法表中存放**各个方法的实际入口地址**。如果某个方法在子类没有重写，那么子类的虚方法表里的入口和父类入口一致，如果子类重写了这个方法，那么**子类方法表中的地址会被替换为子类实现版本的入口地址**。

## Java异常

Java中有Error和Exception，它们都是继承自Throwable类。

### 二者的不同之处

Exception：

- 可以是可被控制(checked) 或不可控制的(unchecked)。
- 表示一个由程序员导致的错误。
- 应该在应用程序级被处理。

Error：

- 总是不可控制的(unchecked)。
- 经常用于表示系统错误或低层资源的错误。
- 如何可能的话，应该在系统级被捕捉。

### 异常的分类

- **Checked exception**: 这类异常都是Exception的子类。异常的向上抛出机制进行处理，假如子类可能产生A异常，那么在父类中也必须throws A异常。可能导致的问题：代码效率低，耦合度过高。
- **Unchecked exception**: **这类异常都是RuntimeException的子类，虽然RuntimeException同样也是Exception的子类，但是它们是非凡的，它们不能通过client code来试图解决**，所以称为Unchecked exception 。

## 常见设计模式

- 观察者模式

  观察者模式用一句话描述就是当一个类的对象（被观察者）的状态发生改变时同时其他依赖于它的对象（观察者）的状态也做相应的改变（做相应的动作）。

  具体实现流程：

  - 定义观察者抽象类，该抽象类中有一个被观察者的成员变量，还有一个update方法用于在被观察者发生改变时通知观察者类，实例化观察者类时将被观察者实例传递进来，这样当被观察者调用观察者的update方法后观察者就可以通过自己的被观察者成员变量访问到被观察者改变之后的状态
  - 定义被观察者，其含有一个list，用来存储若干个观察者的实例，暴露出增加、删除编辑观察者的方法，当其状态发生改变时遍历调用list中观察者对象的update方法通知观察者们

  

  java在java.util库里面，提供了一个Observable类和一个Observer接口，在Observer接口中只提供了一个update方法，被观察者通过调用该方法通知观察者自己的状态发生了改变。Observable类我们提供了对于观察者添加，删除，通知观察者改变等方法。当我们的需要通知观察者并且需要调用观察者update方法，我们需要调用setChanged方法。

  在Android中对于观察者模式使用的场景有很多。例如BroadcastReceiver，Eventbus，RxJava等等都采用了观察者模式。

- 适配器模式

  作为两个不兼容的接口之间的桥梁，它结合了两个独立接口的功能。
  这种模式涉及到一个单一的类，该类负责加入独立的或不兼容的接口功能。
  注意，要点是要在原来类的基础上使原本不兼容的功能变得兼容。
  Adapter类一般是用来实现与原有类不兼容的功能，比如demo中的MediaAdapter实现了MediaPlayer没有的特殊功能，用户只要调用AudioPlayer中的play方法，AudioPlayer会自动根据音频的类型选择不同的play方式，当音频类型不符合传统player的能力时AudioPlayer会使用adapter去调用之前不兼容的方法（功能），这样就实现了所谓的适配。

- 代理模式

  具先实现其实也很简单，就是一个代理类将别代理类包裹起来，只对外界暴露调用被代理类方法的方法，从而实现代理模式，需要特别注意的是代理模式和适配器模式的区别：
  **适配器模式主要改变所考虑对象的接口，而代理模式不能改变所代理类的接口** ，和装饰器模式的区别：
  **装饰器模式为了增强功能，而代理模式是为了加以控制** 。

- 工厂方法模式

  工厂方法模式其实就是当一个类的实例化依赖于不同场景时需要使用的，比如上面demo，根据不同的形状，实例化的Shape对象内部的实现逻辑不一样，这时候就可以使用工厂方法模式，将类内部的实现细节隐藏起来，用户只需要告诉工厂类自己需要什么情况下的产品，工厂就可以自动调用自己内部对应场景的代码从而返回一个用户需要的“产品”。

- 抽象工厂模式

  对比工厂方法模式，因为一个工厂只能生产一个产品，比如一个ShapeFactory只能根据不同情况实例化不同的Shape，那么当我们需要一整套的产品（比如形状和颜色形成了一套产品）时使用工厂方法显然就不能解决了，所以就需要抽象工厂模式，抽象工厂模式实际上是工厂的工厂，即其作用的目的是为了实例化不同的工厂，用户再通过不同的工厂实例化不同场景下成套的产品。

- 单例模式

  单例模式通俗来讲就是让一个类在整个程序中只有一个对象。

- 命令模式

  命令模式实质上就是将命令抽象到一个具体的类中，即这个类是专门去执行某个命令的，比如demo中，SellStock就是专门执行sell这个命令的，当用户需要sell的时候只要实例化SellStock然后excute就可以完成sell，还有一个比较常用的例子是GUI开发中按钮（button）的作用，每一个按钮都是一个对象，当用户点击某个按钮后就会触发一个相应的命令，用户看到的是点击按钮产生效果，而代码层面上是实例化的按钮对象执行类似于demo中的excute方法完成自己的“命令”。

## Java泛型

开发人员在使用泛型的时候，很容易根据自己的直觉而犯一些错误。比如一个方法如果接收`List<Object>`作为形式参数，那么如果尝试将一个`List<String>`的对象作为实际参数传进去，却发现无法通过编译。虽然从直觉上来说，`Object`是`String`的父类，这种类型转换应该是合理的。**但是实际上这会产生隐含的类型转换问题，因此编译器直接就禁止这样的行为**。

### 类型擦除

Java中的泛型基本上都是在编译器这个层次来实现的，**在生成的Java字节代码中是不包含泛型中的类型信息的。使用泛型的时候加上的类型参数，会被编译器在编译的时候去掉，这个过程就称为类型擦除**。如在代码中定义的`List<Object>`和`List<String>`等类型，在编译之后都会变成`List`。**JVM看到的只是List，而由泛型附加的类型信息对JVM来说是不可见的**。Java编译器会在编译时尽可能的发现可能出错的地方，但是仍然无法避免在运行时刻出现类型转换异常的情况。

很多泛型的奇怪特性都与这个类型擦除的存在有关，包括：

- **泛型类并没有自己独有的Class类对象**。比如并不存在`List<String>.class`或是`List<Integer>.class`，而只有`List.class`。
- **静态变量是被泛型类的所有实例所共享的**。对于声明为`MyClass<T>`的类，访问其中的静态变量的方法仍然是 `MyClass.myStaticVar`。不管是通过`new MyClass<String>`还是`new MyClass<Integer>`创建的对象，都是共享一个静态变量。
- **泛型的类型参数不能用在Java异常处理的catch语句中**。因为异常处理是由`JVM`在运行时刻来进行的。由于类型信息被擦除，`JVM`是无法区分两个异常类型`MyException<String>`和`MyException<Integer>`的。对于`JVM`来说，它们都是 `MyException`类型的。也就无法执行与异常对应的catch语句。

类型擦除的基本过程也比较简单，首先是找到用来替换类型参数的具体类。这个具体类一般是Object。如果指定了类型参数的上界的话，则使用这个上界。把代码中的类型参数都替换成具体的类。同时去掉出现的类型声明，即去掉<>的内容。比如`T get()`方法声明就变成了`Object get()`；`List<String>`就变成了`List`。接下来就可能需要生成一些桥接方法（bridge method）。这是由于擦除了类型之后的类可能缺少某些必须的方法。比如考虑下面的代码：

```java
class MyString implements Comparable<String> {
    public int compareTo(String str) {        
        return 0;    
    }
}
```

当类型信息被擦除之后，上述类的声明变成了`class MyString implements Comparable`。但是这样的话，类`MyString`就会有编译错误，因为没有实现接口`Comparable`声明的`int compareTo(Object)`方法。这个时候就由编译器来动态生成这个方法。

### 通配符

在使用泛型类的时候，既可以指定一个具体的类型，如`List<String>`就声明了具体的类型是`String`；也可以用通配符`?`来表示未知类型，如`List<?>`就声明了`List`中包含的元素类型是未知的。 通配符所代表的其实是一组类型，但具体的类型是未知的。`List<?>`所声明的就是所有类型都是可以的。但是List\<?\>并不等同于List\<Object\>。List\<Object\>实际上确定了List中包含的是Object及其子类，在使用的时候都可以通过Object来进行引用。而List<?>其中所包含的元素类型是不确定**。其中可能包含的是`String`，也可能是 `Integer`。如果它包含了`String`的话，往里面添加`Integer`类型的元素就是错误的。**正因为类型未知，就不能通过new ArrayList()的方法来创建一个新的ArrayList对象。因为编译器无法知道具体的类型是什么。但是对于 List中的元素确总是可以用Object来引用的，因为虽然类型未知，但肯定是Object及其子类。考虑下面的代码：

```
public void wildcard(List<?> list) {
    list.add(1);//编译错误
}  
```

> 如上所示，试图对一个带通配符的泛型类进行操作的时候，总是会出现编译错误。其原因在于通配符所表示的类型是未知的。

因为对于`List<?>`中的元素只能用`Object`来引用，在有些情况下不是很方便。在这些情况下，可以使用上下界来限制未知类型的范围。 如 **List<? extends Number>说明List中可能包含的元素类型是Number及其子类。而List<? super Number>则说明List中包含的是Number及其父类**。当引入了上界之后，在使用类型的时候就可以使用上界类中定义的方法。

### 类型系统

在Java中，大家比较熟悉的是通过继承机制而产生的类型体系结构。比如`String`继承自`Object`。根据`Liskov替换原则`，子类是可以替换父类的。当需要`Object`类的引用的时候，如果传入一个`String`对象是没有任何问题的。但是反过来的话，即用父类的引用替换子类引用的时候，就需要进行强制类型转换。编译器并不能保证运行时刻这种转换一定是合法的。**这种自动的子类替换父类的类型转换机制，对于数组也是适用的。 String[]可以替换Object[]**。但是泛型的引入，对于这个类型系统产生了一定的影响。**正如前面提到的List是不能替换掉List的。**

引入泛型之后的类型系统增加了两个维度：**一个是类型参数自身的继承体系结构，另外一个是泛型类或接口自身的继承体系结构**。第一个指的是对于 `List<String>`和`List<Object>`这样的情况，类型参数`String`是继承自`Object`的。而第二种指的是 `List`接口继承自`Collection`接口。对于这个类型系统，有如下的一些规则：

- **相同类型参数的泛型类的关系取决于泛型类自身的继承体系结构**。即`List<String>`是`Collection<String>` 的子类型，`List<String>`可以替换`Collection<String>`。这种情况也适用于带有上下界的类型声明。
- **当泛型类的类型声明中使用了通配符的时候，其子类型可以在两个维度上分别展开**。如对`Collection<? extends Number>`来说，其子类型可以在`Collection`这个维度上展开，即`List<? extends Number>`和`Set<? extends Number>`等；也可以在`Number`这个层次上展开，即`Collection<Double>`和`Collection<Integer>`等。如此循环下去，`ArrayList<Long>`和 `HashSet<Double>`等也都算是`Collection<? extends Number>`的子类型。
- 如果泛型类中包含多个类型参数，则对于每个类型参数分别应用上面的规则。

## ==和equals的区别

== 是一个运算符。 equals则是string对象的方法。

java中 **值类型**的变量（即基本的诸如int、float等） 是存储在内存中的**栈**中。 而**引用类型**（对象）在栈中仅仅是存储引用类型变量的地址，而其本身则存储在**堆**中。所以字符串的内容相同，引用地址不一定相同，有可能创建了多个对象。

String类是不可变类
String s = "Hello";   //--1
String s1=new String("World");//---2
方式1是申请的变量存放在常量池中的，这是java的性能优化所做的。也就是说每创建一个字符串，虚拟机就要创建一个新的对象，因为String是不可变类，因此，虚拟机做出优化，将字符串放入常量池，实现对不同字符串的引用。
第二种方法是使用new创建的对象，那么会在堆区申请内存，对于大量的这样的操作，这个开销是很大的，所以不建议使用第二种方式。

所以对于：

```
String a = "123";
String b = "123";
System.out.println(a == b);
System.out.println(a.equals(b));
```

会输出两个true

但是对于：

```
String a = new String("123");
String b = new String("123");
System.out.println(a == b);
System.out.println(a.equals(b));
```

会输出false和true。

## try..catch..finally中如果try或者catch中进行了return，finally是否还会执行？

- 如果try中**没有异常**且try中**有return** （执行顺序）

```
try ---- finally --- return
```

- 如果try中**有异常**并且try中**有return**

```
try----catch---finally--- return
```

总之 finally 永远执行！

- try中有异常，try-catch-finally里都没有return ，finally 之后有个return

```
try----catch---finally
```

try中有异常以后，根据java的异常机制先执行catch后执行finally，此时错误异常已经抛出，程序因异常而终止，所以**你的return是不会执行的**

- 当 try和finally中都有return时，finally中的return会覆盖掉其它位置的return（多个return会报unreachable code，编译不会通过）。

- 当finally中不存在return，而catch中存在return，但finally中要修改catch中return 的变量值时

```
int ret = 0;
try{ 
	throw new Exception();
}
catch(Exception e)
{
	ret = 1;  return ret;
}
finally{
	ret = 2;
} 
```

最后返回值是1，因为return的值在执行finally之前已经确定下来了

## Java线程

Java 给多线程编程提供了内置的支持。 一条线程指的是进程中一个单一顺序的控制流，一个进程中可以并发多个线程，每条线程并行执行不同的任务。

多线程是多任务的一种特别的形式，但多线程使用了更小的资源开销。

这里定义和线程相关的另一个术语 - 进程：一个进程包括由操作系统分配的内存空间，包含一个或多个线程。一个线程不能独立的存在，它必须是进程的一部分。一个进程一直运行，直到所有的非守护线程都结束运行后才能结束。

多线程能满足程序员编写高效率的程序来达到充分利用 CPU 的目的。

### 一个线程的生命周期

线程是一个动态执行的过程，它也有一个从产生到死亡的过程。

下图显示了一个线程完整的生命周期。

![3](https://ws2.sinaimg.cn/large/006tKfTcgy1g0l0sb64doj30y80nyt9i.jpg)

- 新建状态:

  使用 **new** 关键字和 **Thread** 类或其子类建立一个线程对象后，该线程对象就处于新建状态。它保持这个状态直到程序 **start()** 这个线程。

- 就绪状态:

  当线程对象调用了start()方法之后，该线程就进入就绪状态。就绪状态的线程处于就绪队列中，要等待JVM里线程调度器的调度。

- 运行状态:

  如果就绪状态的线程获取 CPU 资源，就可以执行 **run()**，此时线程便处于运行状态。处于运行状态的线程最为复杂，它可以变为阻塞状态、就绪状态和死亡状态。

- 阻塞状态:

  如果一个线程执行了sleep（睡眠）、suspend（挂起）等方法，失去所占用资源之后，该线程就从运行状态进入阻塞状态。在睡眠时间已到或获得设备资源后可以重新进入就绪状态。可以分为三种：

  - 等待阻塞：运行状态中的线程执行 wait() 方法，使线程进入到等待阻塞状态。
  - 同步阻塞：线程在获取 synchronized 同步锁失败(因为同步锁被其他线程占用)。
  - 其他阻塞：通过调用线程的 sleep() 或 join() 发出了 I/O 请求时，线程就会进入到阻塞状态。当sleep() 状态超时，join() 等待线程终止或超时，或者 I/O 处理完毕，线程重新转入就绪状态。

- 死亡状态:

  一个运行状态的线程完成任务或者其他终止条件发生时，该线程就切换到终止状态。

Thread.run()和Thread.start()的区别：

- start（）方法来启动线程，真正实现了多线程运行。这时无需等待run方法体代码执行完毕，可以直接继续执行下面的代码；通过调用Thread类的start()方法来启动一个线程， 这时此线程是处于就绪状态， 并没有运行。 然后通过此Thread类调用方法run()来完成其运行操作的， 这里方法run()称为线程体，它包含了要执行的这个线程的内容， Run方法运行结束， 此线程终止。然后CPU再调度其它线程。
- run（）方法当作普通方法的方式调用。程序还是要顺序执行，要等待run方法体执行完毕后，才可继续执行下面的代码； 程序中只有主线程这一个线程， 其程序执行路径还是只有一条， 这样就没有达到写线程的目的。

### wait和sleep的区别

这两个方法来自不同的类：sleep来自Thread类，而wait来自Object类。 sleep是Thread的**静态方法**，谁调用的谁去睡觉，即使在a线程里调用b的sleep方法，实际上还是a去睡觉，要让b线程睡觉要在b的代码中调用sleep。

对锁: 最主要是sleep方法没有释放锁，而wait方法释放了锁，使得其他线程可以使用同步控制块或者方法。　　 sleep不出让系统资源；wait是进入线程等待池等待，让出系统资源，其他线程可以占用CPU。一般wait不会加时间限制，因为如果wait线程的运行资源不够，再出来也没用，要等待其他线程调用notify/notifyAll唤醒等待池中的所有线程，才会进入就绪队列等待OS分配系统资源。sleep(milliseconds)可以用时间指定使它自动唤醒过来，如果时间不到只能调用interrupt()强行打断。 Thread.sleep(0)的作用是“触发操作系统立刻重新进行一次CPU竞争”。

使用范围：wait，notify和notifyAll只能在同步控制方法或者同步控制块（synchronized）里面使用，而sleep可以在任何地方使用：

```
   synchronized(x){ 
      x.notify() 
     //或者wait() 
   }
```

### 线程的优先级

每一个 Java 线程都有一个优先级，这样有助于操作系统确定线程的调度顺序。

Java 线程的优先级是一个整数，其取值范围是 1 （Thread.MIN_PRIORITY ） - 10 （Thread.MAX_PRIORITY ）。

默认情况下，每一个线程都会分配一个优先级 NORM_PRIORITY（5）。

具有较高优先级的线程对程序更重要，并且应该在低优先级的线程之前分配处理器资源。但是，线程优先级不能保证线程执行的顺序，而且非常依赖于平台。

### 创建一个线程

Java 提供了三种创建线程的方法：

- 通过实现 Runnable 接口；
- 通过继承 Thread 类本身；
- 通过 Callable 和 Future 创建线程。

#### 通过实现 Runnable 接口

```java
class RunnableDemo implements Runnable {
   private Thread t;
   private String threadName;
   
   RunnableDemo( String name) {
      threadName = name;
      System.out.println("Creating " +  threadName );
   }
   
   public void run() {
      System.out.println("Running " +  threadName );
      try {
         for(int i = 4; i > 0; i--) {
            System.out.println("Thread: " + threadName + ", " + i);
            // 让线程睡眠一会
            Thread.sleep(50);
         }
      }catch (InterruptedException e) {
         System.out.println("Thread " +  threadName + " interrupted.");
      }
      System.out.println("Thread " +  threadName + " exiting.");
   }
   
   public void start () {
      System.out.println("Starting " +  threadName );
      if (t == null) {
         t = new Thread (this, threadName);
         t.start ();
      }
   }
}
 
public class TestThread {
 
   public static void main(String args[]) {
      RunnableDemo R1 = new RunnableDemo( "Thread-1");
      R1.start();
      
      RunnableDemo R2 = new RunnableDemo( "Thread-2");
      R2.start();
   }   
}
```

#### 通过继承 Thread 类本身

```java
class ThreadDemo extends Thread {
   private Thread t;
   private String threadName;
   
   ThreadDemo( String name) {
      threadName = name;
      System.out.println("Creating " +  threadName );
   }
   
   public void run() {
      System.out.println("Running " +  threadName );
      try {
         for(int i = 4; i > 0; i--) {
            System.out.println("Thread: " + threadName + ", " + i);
            // 让线程睡眠一会
            Thread.sleep(50);
         }
      }catch (InterruptedException e) {
         System.out.println("Thread " +  threadName + " interrupted.");
      }
      System.out.println("Thread " +  threadName + " exiting.");
   }
   
   public void start () {
      System.out.println("Starting " +  threadName );
      if (t == null) {
         t = new Thread (this, threadName);
         t.start ();
      }
   }
}
 
public class TestThread {
 
   public static void main(String args[]) {
      ThreadDemo T1 = new ThreadDemo( "Thread-1");
      T1.start();
      
      ThreadDemo T2 = new ThreadDemo( "Thread-2");
      T2.start();
   }   
}
```

#### 通过 Callable 和 Future 创建线程

- 创建 Callable 接口的实现类，并实现 call() 方法，该 call() 方法将作为线程执行体，并且有返回值。
- 创建 Callable 实现类的实例，使用 FutureTask 类来包装 Callable 对象，该 FutureTask 对象封装了该 Callable 对象的 call() 方法的返回值。
- 使用 FutureTask 对象作为 Thread 对象的 target 创建并启动新线程。
- 调用 FutureTask 对象的 get() 方法来获得子线程执行结束后的返回值。

```java
public class CallableThreadTest implements Callable<Integer> {
    public static void main(String[] args)  
    {  
        CallableThreadTest ctt = new CallableThreadTest();  
        FutureTask<Integer> ft = new FutureTask<>(ctt);  
        for(int i = 0;i < 100;i++)  
        {  
            System.out.println(Thread.currentThread().getName()+" 的循环变量i的值"+i);  
            if(i==20)  
            {  
                new Thread(ft,"有返回值的线程").start();  
            }  
        }  
        try  
        {  
            System.out.println("子线程的返回值："+ft.get());  
        } catch (InterruptedException e)  
        {  
            e.printStackTrace();  
        } catch (ExecutionException e)  
        {  
            e.printStackTrace();  
        }  
  
    }
    @Override  
    public Integer call() throws Exception  
    {  
        int i = 0;  
        for(;i<100;i++)  
        {  
            System.out.println(Thread.currentThread().getName()+" "+i);  
        }  
        return i;  
    }  
}
```

#### 创建线程的三种方式的对比

- 采用实现 Runnable、Callable 接口的方式创建多线程时，线程类只是实现了 Runnable 接口或 Callable 接口，还可以继承其他类。
- 使用继承 Thread 类的方式创建多线程时，编写简单，如果需要访问当前线程，则无需使用 Thread.currentThread() 方法，直接使用 this 即可获得当前线程。

------

### 线程的几个主要概念

在多线程编程时，你需要了解以下几个概念：

- 线程同步
- 线程间通信
- 线程死锁
- 线程控制：挂起、停止和恢复

------

### 多线程的使用

有效利用多线程的关键是理解程序是并发执行而不是串行执行的。例如：程序中有两个子系统需要并发执行，这时候就需要利用多线程编程。

通过对多线程的使用，可以编写出非常高效的程序。不过请注意，如果你创建太多的线程，程序执行的效率实际上是降低了，而不是提升了。

请记住，上下文的切换开销也很重要，如果你创建了太多的线程，CPU 花费在上下文的切换的时间将多于执行程序的时间！

## Java线程池

线程池的基本思想是一种对象池，在程序启动时就开辟一块内存空间，里面存放了众多(未死亡)的线程，池中线程执行调度由池管理器来处理。当有线程任务时，从池中取一个，执行完成后线程对象归池，这样可以避免**反复创建线程对象所带来的性能开销**，节省了系统的资源。

### 使用线程池的好处

（1）降低资源消耗。通过重复利用已创建的线程降低线程创建和销毁造成的消耗(**每个线程需要大约1MB内存**，线程开的越多，消耗的内存也就越大，最后死机)。； 

（2）提高响应速度。当任务到达时，任务可以不需要等到线程创建就能立即执行； 

（3）提高线程的可管理性。线程是稀缺资源，如果无限制的创建，不仅会消耗系统资源，还会降低系统的稳定性，使用线程池可以进行统一的分配，调优和监控。

（4）对线程进行一些简单的管理，比如：延时执行、定时循环执行的策略等，运用线程池都能进行很好的实现

一个线程池包括以下四个基本组成部分：

1. 线程池管理器（ThreadPool）：用于创建并管理线程池，包括 创建线程池，销毁线程池，添加新任务；
2. 工作线程（WorkThread）：线程池中线程，在没有任务时处于等待状态，可以循环的执行任务；
3. 任务接口（Task）：每个任务必须实现的接口，以供工作线程调度任务的执行，它主要规定了任务的入口，任务执行完后的收尾工作，任务的执行状态等；
4. 任务队列（taskQueue）：用于存放没有处理的任务。提供一种缓冲机制。

### ThreadPoolExecutor类

讲到线程池，要重点介绍java.uitl.concurrent.ThreadPoolExecutor类，ThreadPoolExecutor是线程池中最核心的一个类。

我们可以通过ThreadPoolExecutor来创建一个线程池

```
new ThreadPoolExecutor(corePoolSize, maximumPoolSize,keepAliveTime, 
milliseconds,runnableTaskQueue, threadFactory,handler);
```

- **corePoolSize（线程池的基本大小）**：当提交一个任务到线程池时，线程池会创建一个线程来执行任务，即使其他空闲的基本线程能够执行新任务也会创建线程，等到需要执行的任务数大于线程池基本大小时就不再创建。如果调用了线程池的prestartAllCoreThreads方法，线程池会提前创建并启动所有基本线程。

- **maximumPoolSize（线程池最大大小）**：线程池允许创建的最大线程数。如果队列满了，并且已创建的线程数小于最大线程数，则线程池会再创建新的线程执行任务。值得注意的是如果使用了无界的任务队列这个参数就没什么效果。

- **runnableTaskQueue（任务队列）**：用于保存等待执行的任务的阻塞队列。

- **ThreadFactory**：用于设置创建线程的工厂，可以通过线程工厂给每个创建出来的线程设置更有意义的名字，Debug和定位问题时非常又帮助。

- **RejectedExecutionHandler（拒绝策略）**：当队列和线程池都满了，说明线程池处于饱和状态，那么必须采取一种策略处理提交的新任务。这个策略默认情况下是AbortPolicy，表示无法处理新任务时抛出异常。以下是JDK1.5提供的四种策略。n  AbortPolicy：直接抛出异常。

- **keepAliveTime（线程活动保持时间）**：线程池的工作线程空闲后，保持存活的时间。所以如果任务很多，并且每个任务执行的时间比较短，可以调大这个时间，提高线程的利用率。

- **TimeUnit（线程活动保持时间的单位）**：可选的单位有天（DAYS），小时（HOURS），分钟（MINUTES），毫秒(MILLISECONDS)，微秒(MICROSECONDS, 千分之一毫秒)和毫微秒(NANOSECONDS, 千分之一微秒)。

#### 向线程池提交任务

我们可以通过execute()或submit()两个方法向线程池提交任务，不过它们有所不同

- execute()方法没有返回值，所以无法判断任务知否被线程池执行成功

```
threadsPool.execute(new Runnable() {
    @Override
    public void run() {
    // TODO Auto-generated method stub
   }
});
```

- submit()方法返回一个future,那么我们可以通过这个future来判断任务是否执行成功，通过future的get方法来获取返回值

```
try {
     Object s = future.get();
   } catch (InterruptedException e) {
   // 处理中断异常
   } catch (ExecutionException e) {
   // 处理无法执行任务异常
   } finally {
   // 关闭线程池
   executor.shutdown();
}
```

#### 线程池的关闭

我们可以通过shutdown()或shutdownNow()方法来关闭线程池，不过它们也有所不同

- shutdown的原理是只是将线程池的状态设置成SHUTDOWN状态，然后中断所有没有正在执行任务的线程。
- shutdownNow的原理是遍历线程池中的工作线程，然后逐个调用线程的interrupt方法来中断线程，所以无法响应中断的任务可能永远无法终止。shutdownNow会首先将线程池的状态设置成STOP，然后尝试停止所有的正在执行或暂停任务的线程，并返回等待执行任务的列表。

#### ThreadPoolExecutor执行的策略

![1](https://ws4.sinaimg.cn/large/006tKfTcgy1g0l2awri9rj30dw0850tb.jpg)

线程数量未达到corePoolSize，则新建一个线程(核心线程)执行任务

线程数量达到了corePools，则将任务移入队列等待

队列已满，新建线程(非核心线程)执行任务

队列已满，总线程数又达到了maximumPoolSize，就会由(RejectedExecutionHandler)抛出异常

#### 四种拒绝策略

ThreadPoolExecutor.AbortPolicy()  抛出java.util.concurrent.RejectedExecutionException异常 

ThreadPoolExecutor.DiscardPolicy() 抛弃当前的任务 

ThreadPoolExecutor.DiscardOldestPolicy() 抛弃旧的任务 （队列中的第一个任务替换为当前新进来的任务执行）

ThreadPoolExecutor.CallerRunsPolicy() 重试添加当前的任务，他会自动重复调用execute()方法 

### Java通过Executors提供四种线程池

- CachedThreadPool()：可缓存线程池。
  - 线程数无限制
  - 有空闲线程则复用空闲线程，若无空闲线程则新建线程 一定程序减少频繁创建/销毁线程，减少系统开销

  CachedThreadPool创建一个可缓存线程池，如果线程池长度超过处理需要，可灵活回收空闲线程，若无可回收，则新建线程

- FixedThreadPool()：定长线程池。
  - 可控制线程最大并发数（同时执行的线程数）
  - 超出的线程会在队列中等待
  - 如果某个线程因为执行异常而结束，那么线程池会补充一个新线程。

- ScheduledThreadPool()：
  - 定时线程池。
  - 支持定时及周期性任务执行。

  newscheduledThreadPool创建一个定长线程池，支持定时及周期性任务执行。延迟执行示例代码如下.表示延迟1秒后每3秒执行一次

  ```java
  public class ThreadPoolExecutorTest3 {
  	public static void main(String[] args) {
  		ScheduledExecutorService scheduledThreadPool = Executors.newScheduledThreadPool(5);
  		scheduledThreadPool.scheduleAtFixedRate(new Runnable() {
  			public void run() {
  				System.out.println(Thread.currentThread().getName() + ": delay 1 seconds, and excute every 3 seconds");
  			}
  		}, 1, 3, TimeUnit.SECONDS);// 表示延迟1秒后每3秒执行一次
  	}
  }
  
  ```

- SingleThreadExecutor()：单线程化的线程池。
  - 有且仅有一个工作线程执行任务
  - 所有任务按照指定顺序执行，即遵循队列的入队出队规则

  newSingleThreadExecutor创建一个单线程化的线程池，它只会用唯一的工作线程来执行任务，**保证所有任务按照指定顺序(FIFO, LIFO, 优先级)执行**，如果这个唯一的线程因为异常结束，那么会有一个新的线程来替代它。此线程池保证所有任务的执行顺序按照任务的提交顺序执行

### 线程池的监控

通过继承线程池并重写线程池的beforeExecute，afterExecute和terminated方法，我们可以在任务执行前，执行后和线程池关闭前干一些事情。如监控任务的平均执行时间，最大执行时间和最小执行时间等。这几个方法在线程池里是空方法。

## Jvm架构

### 什么是JVM

JVM是Java Virtual Machine（Java虚拟机）的缩写，JVM是一种用于计算设备的规范，它是一个虚构出来的计算机，是通过在实际的计算机上仿真模拟各种计算机功能来实现的。Java虚拟机包括**一套字节码指令集**、**一组寄存器**、**一个栈**、**一个垃圾回收堆**和一**个存储方法域**。 JVM**屏蔽了与具体操作系统平台相关的信息**，使Java程序只需生成在Java虚拟机上运行的目标代码（字节码）,就可以在多种平台上不加修改地运行。JVM在执行字节码时，实际上最终还是把字节码解释成具体平台上的机器指令执行。

### JRE/JDK/JVM是什么关系

JRE(Java Runtime Environment，Java运行环境)，也就是Java平台。所有的Java 程序都要在JRE下才能运行。普通用户只需要运行已开发好的java程序，安装JRE即可。

JDK(Java Development Kit)是程序开发者用来来编译、调试java程序用的开发工具包。JDK的工具也是Java程序，也需要JRE才能运行。为了保持JDK的独立性和完整性，在JDK的安装过程中，JRE也是 安装的一部分。所以，在JDK的安装目录下有一个名为jre的目录，用于存放JRE文件。

JVM(Java Virtual Machine，Java虚拟机)是JRE的一部分。它是一个虚构出来的计算机，是通过在实际的计算机上仿真模拟各种计算机功能来实现的。JVM有自己完善的硬件架构，如处理器、堆栈、寄存器等，还具有相应的指令系统。Java语言最重要的特点就是跨平台运行。使用JVM就是为了支持与操作系统无关，实现跨平台。

### JVM原理

JVM是java的核心和基础，在java编译器和os平台之间的虚拟处理器。它是一种利用软件方法实现的抽象的计算机基于下层的操作系统和硬件平台，可以在上面执行java的字节码程序。

![image-20190227170231506](https://ws1.sinaimg.cn/large/006tKfTcgy1g0l39o1ujzj31940ryafz.jpg)

java编译器只要面向JVM，生成JVM能理解的代码或字节码文件。Java源文件经编译成字节码程序，通过JVM将每一条指令翻译成不同平台机器码，通过特定平台运行。

### JVM体系结构

![5](https://ws2.sinaimg.cn/large/006tKfTcgy1g0l3g10y3tj30uf0u0443.jpg)

**JVM被分为三个主要的子系统：**

**（1）类加载器子系统（2）**运行时数据区**（3）**执行引擎

#### 类加载器子系统

Java的动态类加载功能是由类加载器子系统处理。当它在运行时（不是编译时）首次引用一个类时，它加载、链接并初始化该类文件。

##### 加载

类由此组件加载。启动类加载器 (BootStrap class Loader)、扩展类加载器(Extension class Loader)和应用程序类加载器(Application class Loader) 这三种类加载器帮助完成类的加载。

1.  启动类加载器 – 负责从启动类路径中加载类，无非就是rt.jar。这个加载器会被赋予最高优先级。

2.  扩展类加载器 – 负责加载ext 目录(jre\lib)内的类.

3.  应用程序类加载器 – 负责加载应用程序级别类路径，涉及到路径的环境变量等etc.

上述的类加载器会遵循委托层次算法（Delegation Hierarchy Algorithm）加载类文件。

##### 链接

1.  校验 – 字节码校验器会校验生成的字节码是否正确，如果校验失败，我们会得到校验错误。

2.  准备 – 分配内存并初始化默认值给所有的静态变量。

3.  解析 – 所有符号内存引用被方法区(Method Area)的原始引用所替代。

##### 初始化

这是类加载的最后阶段，这里所有的静态变量会被赋初始值, 并且静态块将被执行。

#### 运行时数据区（Runtime Data Area）

运行时数据区域被划分为5个主要组件：

##### 方法区（Method Area）

所有**类级别数据**将被存储在这里，包括**静态变量**。每个JVM只有一个方法区，它是一个共享的资源。

##### 堆区（Heap Area）

所有的**对象**和它们**相应的实例变量**以及**数组**将被存储在这里。每个JVM同样只有一个堆区。由于方法区和堆区的内存由多个线程共享，所以存储的数据不是线程安全的。

##### 栈区（Stack Area）

对每个线程会单独创建一个运行时栈。对每个函数呼叫会在栈内存生成一个栈帧(Stack Frame)。所有的**局部变量**将在栈内存中创建。栈区是线程安全的，因为它不是一个共享资源。栈帧被分为三个子实体：

a 局部变量数组 – 包含多个与方法相关的局部变量并且相应的值将被存储在这里。

b 操作数栈 – 如果需要执行任何中间操作，操作数栈作为运行时工作区去执行指令。

c 帧数据 – 方法的所有符号都保存在这里。在任意异常的情况下，catch块的信息将会被保存在帧数据里面。

![20180617161343935](https://ws2.sinaimg.cn/large/006tKfTcgy1g0l3tcquztj31v60ow1kx.jpg)

##### PC寄存器

每个线程都有一个单独的PC寄存器来保存**当前执行指令的地址**，一旦该指令被执行，pc寄存器会被更新至下条指令的地址。

##### 本地方法栈

本地方法栈保存**本地方法信息**。对**每一个线程，将创建一个单独的本地方法栈**。

#### 执行引擎

分配给运行时数据区的字节码将由执行引擎执行。执行引擎读取字节码并逐段执行。

##### 解释器

 解释器能快速的**解释字节码**，但执行却很慢。 解释器的缺点就是,当一个方法被调用多次，每次都需要重新解释。

##### JIT编译器

JIT编译器消除了解释器的缺点。执行引擎利用解释器转换字节码，但如果是重复的代码则使用JIT编译器**将全部字节码编译成本机代码**。本机代码将直接用于重复的方法调用，这提高了系统的性能。

a. 中间代码生成器 – 生成中间代码

b. 代码优化器 – 负责优化上面生成的中间代码

c. 目标代码生成器 – 负责**生成机器代码或本机代码**

d.  探测器(Profiler) – 一个特殊的组件，负责**寻找被多次调用的方法**。

##### 垃圾回收器:

收集并删除未引用的对象。可以通过调用"System.gc()"来触发垃圾回收，但并不保证会确实进行垃圾回收。JVM的垃圾回收只收集哪些由new关键字创建的对象。所以，如果不是用new创建的对象，你可以使用finalize函数来执行清理。

Java本地接口 (JNI): JNI 会与本地方法库进行交互并提供执行引擎所需的本地库。

本地方法库:它是一个执行引擎所需的本地库的集合。

## java中的类加载模型（class loader）

### 什么是classLoader

当我们写好一个[Java](http://lib.csdn.net/base/17)程序之后，都是由若干个.class文件组织而成的一个完整的Java应用程序，当程序在运行时，即会调用该程序的一个入口函数来调用系统的相关功能，而这些功能都被封装在不同的class文件当中，所以经常要从这个class文件中要调用另外一个class文件中的方法，如果另外一个文件不存在的，则会引发系统异常。而程序在启动的时候，并不会一次性加载程序所要用的所有class文件，而是根据程序的需要，通过Java的类加载机制（ClassLoader）来动态加载某个class文件到内存当中的，从而只有class文件被载入到了内存之后，才能被其它class所引用。所以ClassLoader就是用来动态加载class文件到内存当中用的。

### Java中默认提供的三个ClassLoader

- **BootStrap ClassLoader**：称为启动类加载器，是Java类加载层次中最顶层的类加载器，**负责加载JDK中的核心类库，如：rt.jar、resources.jar、charsets.jar等**
- **Extension ClassLoader**：称为扩展类加载器，负责加载Java的扩展类库，默认加载JAVA_HOME/jre/lib/ext/目下的所有jar。
- **App ClassLoader**：称为系统类加载器，负责加载应用程序classpath目录下的所有jar和class文件。

除了Java默认提供的三个ClassLoader之外，用户还可以根据需要定义自已的ClassLoader，而这些自定义的ClassLoader都必须继承自java.lang.ClassLoader类，也包括Java提供的另外二个ClassLoader（Extension ClassLoader和App ClassLoader）在内，但是Bootstrap ClassLoader不继承自ClassLoader，因为它不是一个普通的Java类，底层由C++编写，已嵌入到了JVM内核当中，当JVM启动后，Bootstrap ClassLoader也随着启动，负责加载完核心类库后，并构造Extension ClassLoader和App ClassLoader类加载器。

### classLoader原理

ClassLoader使用的是**双亲委托模型**来搜索类的，每个ClassLoader实例都有一个父类加载器的引用（不是继承的关系，是一个包含的关系），虚拟机内置的类加载器（Bootstrap ClassLoader）本身没有父类加载器，但可以用作其它ClassLoader实例的的父类加载器。当一个ClassLoader实例需要加载某个类时，它会试图亲自搜索某个类之前，先把这个任务委托给它的父类加载器，这个过程是由上至下依次检查的，首先由最顶层的类加载器Bootstrap ClassLoader试图加载，如果没加载到，则把任务转交给Extension ClassLoader试图加载，如果也没加载到，则转交给App ClassLoader 进行加载，如果它也没有加载得到的话，则返回给委托的发起者，由它到指定的文件系统或网络等URL中加载该类。如果它们都没有加载到这个类时，则抛出ClassNotFoundException异常。否则将这个找到的类生成一个类的定义，并将它加载到内存当中，最后返回这个类在内存中的Class实例对象。

#### 为什么要使用双亲委托模型？

因为这样可以避免重复加载，当父亲已经加载了该类的时候，就没有必要子ClassLoader再加载一次。考虑到安全因素，我们试想一下，如果不使用这种委托模式，那我们就可以随时使用自定义的String来动态替代java核心api中定义的类型，这样会存在非常大的安全隐患，而双亲委托的方式，就可以避免这种情况，因为String已经在启动时就被引导类加载器（Bootstrcp ClassLoader）加载，所以用户自定义的ClassLoader永远也无法加载一个自己写的String，除非你改变JDK中ClassLoader搜索类的默认算法。

#### JVM在搜索类的时候，又是如何判定两个class是相同的呢？

JVM在判定两个class是否相同时，不仅要判断两个**类名**是否相同，而且要判断**是否由同一个类加载器实例加载**的。只有两者同时满足的情况下，JVM才认为这两个class是相同的。就算两个class是同一份class字节码，如果被两个不同的ClassLoader实例所加载，JVM也会认为它们是两个不同class。比如网络上的一个Java类org.classloader.simple.NetClassLoaderSimple，javac编译之后生成字节码文件NetClassLoaderSimple.class，ClassLoaderA和ClassLoaderB这两个类加载器并读取了NetClassLoaderSimple.class文件，并分别定义出了java.lang.Class实例来表示这个类，对于JVM来说，它们是两个不同的实例对象，但它们确实是同一份字节码文件，如果试图将这个Class实例生成具体的对象进行转换时，就会抛运行时异常java.lang.ClassCaseException，提示这是两个不同的类型。

### classLoader的体系结构

![image-20190225155430824](https://ws3.sinaimg.cn/large/006tKfTcgy1g0iq2ab0l8j316v0u01kx.jpg)

### 定义自己的classLoader

***既然JVM已经提供了默认的类加载器，为什么还要定义自已的类加载器呢？***

​      因为Java中提供的默认ClassLoader，只加载指定目录下的jar和class，如果我们想加载其它位置的类或jar时，比如：我要加载网络上的一个class文件，通过动态加载到内存之后，要调用这个类中的方法实现我的业务逻辑。在这样的情况下，默认的ClassLoader就不能满足我们的需求了，所以需要定义自己的ClassLoader。

***定义自已的类加载器分为两步：***

1、继承java.lang.ClassLoader

2、重写父类的**findClass**方法

读者可能在这里有疑问，父类有那么多方法，为什么偏偏只重写findClass方法？

​      因为JDK已经在loadClass方法中帮我们实现了ClassLoader搜索类的算法，当在loadClass方法中搜索不到类时，loadClass方法就会调用findClass方法来搜索类，所以我们只需重写该方法即可。如没有特殊的要求，一般不建议重写loadClass搜索类的算法。

### Java类加载的步骤

Java虚拟机通过装载、连接和初始化一个类型，使该类型可以被正在运行的Java程序使用。

1. 装载：把二进制形式的Java类型读入Java虚拟机中。
2. 连接：把装载的二进制形式的类型数据合并到虚拟机的运行时状态中去。
           	 1. 验证：确保Java类型数据格式正确并且适合于Java虚拟机使用。
                       	 2. 准备：负责为该类型**分配它所需内存**。
                       	 3. 解析：把常量池中的**符号引用**转换为**直接引用**。(可推迟到运行中的程序真正使用某个符号引用时再解析)
3. 初始化：为类变量赋适当的初始值

所有Java虚拟机实现必须在每个类或接口**首次主动使用**时初始化。以下六种情况符合主动使用的要求：

- 当创建某个类的新实例时(new、反射、克隆、序列化)
- 调用某个类的静态方法
- 使用某个类或接口的静态字段，或对该字段赋值(用final修饰的静态字段除外，它被初始化为一个编译时常量表达式)
- 当调用Java API的某些反射方法时。
- 初始化某个类的子类时。
- 当虚拟机启动时被标明为启动类的类。

除以上六种情况，所有其他使用Java类型的方式都是被动的，它们不会导致Java类型的初始化。

> 对于接口来说，只有在某个接口声明的非常量字段被使用时，该接口才会初始化，而不会因为事先这个接口的子接口或类要初始化而被初始化。

**父类需要在子类初始化之前被初始化，所以这些类应该被装载了。当实现了接口的类被初始化的时候，不需要初始化父接口。然而，当实现了父接口的子类(或者是扩展了父接口的子接口)被装载时，父接口也要被装载。(只是被装载，没有初始化)**

## Java垃圾回收机制（garbage collection-GC）

Java堆中存放着大量的Java对象实例，在垃圾收集器回收内存前，第一件事情就是确定哪些对象是“活着的”，哪些是可以回收的。

[**Java**](http://lib.csdn.net/base/javase)中Stop-The-World机制简称STW，是在执行垃圾收集[**算法**](http://lib.csdn.net/base/datastructure)时，Java应用程序的其他所有线程都被挂起（除了垃圾收集帮助器之外）。Java中一种全局暂停现象，全局停顿，所有Java代码停止，native代码可以执行，但不能与JVM交互；这些现象多半是由于gc引起。

### 判断对象是否存活的算法

#### 引用计数算法（基本弃用）

引用计数算法是判断对象是否存活的基本算法：给每个对象添加一个引用计数器，没当一个地方引用它的时候，计数器值加1；当引用失效后，计数器值减1。但是这种方法有一个致命的缺陷，**当两个对象相互引用时会导致这两个都无法被回收**。

#### 根搜索算法（目前使用中）

在主流的商用语言中（Java、C#...）都是使用根搜索算法来判断对象是否存活。对于程序来说，根对象总是可以访问的。*从这些根对象开始，任何可以被触及的对象都被认为是"活着的"的对象。无法触及的对象被认为是垃圾，需要被回收*。

Java虚拟机的根对象集合根据实现不同而不同，但是总会包含以下几个方面：

- 栈（栈帧中的本地变量表）中引用的对象。
- 方法区中的类静态属性引用的变量。
- 方法区中的常量引用的变量。
- 本地方法JNI的引用对象。

**区分活动对象和垃圾的两个基本方法是引用计数和根搜索。** 引用计数是通过为堆中每个对象保存一个计数来区分活动对象和垃圾。根搜索算法实际上是追踪从根结点开始的引用图。

**在主流的商用程序语言（如我们的Java）的主流实现中，都是通过可达性分析算法来判定对象是否存活的。**

### 垃圾收集算法

#### 标记-清除算法

分标记和清除两个阶段：首先标记处所需要回收的对象，在标记完成后统一回收所有被标记的对象。

![6](https://ws4.sinaimg.cn/large/006tKfTcgy1g0l7i4uiewj30ag08zdg9.jpg)

它有两点不足：一个效率问题，标记和清除过程都效率不高；一个是空间问题，标记清除之后会产生大量不连续的内存碎片（类似于我们电脑的磁盘碎片），空间碎片太多导致需要分配大对象时无法找到足够的连续内存而不得不提前触发另一次垃圾回收动作。

#### 复制算法

为了解决效率问题，出现了“复制”算法，他将可用内存按容量划分为大小相等的两块，每次只需要使用其中一块。当一块内存用完了，将还存活的对象复制到另一块上面，然后再把刚刚用完的内存空间一次清理掉。这样就解决了内存碎片问题，但是代价就是可以用内容就缩小为原来的一半。

![7](https://ws3.sinaimg.cn/large/006tKfTcgy1g0l7ixtv9rj30cd0a30t5.jpg)

#### 标记-整理算法

复制算法在对象存活率较高时就会进行频繁的复制操作，效率将降低。因此又有了标记-整理算法，标记过程同标记-清除算法，但是在后续步骤不是直接对对象进行清理，而是让所有存活的对象都向一侧移动，然后直接清理掉端边界以外的内存。

![8](https://ws4.sinaimg.cn/large/006tKfTcgy1g0l7jwzdegj30bm097dg9.jpg)

#### 分代收集法

当前商业虚拟机的GC都是采用分代收集算法

为了增大垃圾收集的效率，所以JVM将堆进行分代，分为不同的部分，一般有三部分，新生代，老年代和永久代（在新的版本中已经将永久代废弃，引入了元空间的概念，永久代使用的是JVM内存而元空间直接使用物理内存）：

![8](https://ws3.sinaimg.cn/large/006tKfTcgy1g0irckny0aj30qo0k0t8m.jpg)

- 新生代（对应minor GC）

  所有新new出来的对象都会最先出现在新生代中，当新生代这部分内存满了之后，就会发起一次垃圾收集事件，这种发生在新生代的垃圾收集称为Minor collections。这种收集通常比较快，因为新生代的大部分对象都是需要回收的，那些暂时无法回收的就会被移动到老年代。

- 老年代（对应Full GC）

  老年代用来存储那些存活时间较长的对象。一般来说，我们会给新生代的对象限定一个存活的时间，当达到这个时间还没有被收集的时候就会被移动到老年代中。

- 永久代

  用于存放静态文件，如Java类、方法等。持久代对垃圾回收没有显著影响，但是有些应用可能动态生成或者调用一些class，例如Hibernate 等，在这种时候需要设置一个比较大的持久代空间来存放这些运行过程中新增的类。

**程序中主动调用System.gc()强制执行的GC为Full GC。**

大概流程：

内存分区：

年轻代(Young Generation)（Eden,Survivor-s0,Survivor-s1，大小比例默认为8:1:1） 

年老代(Old Generation) 

永久代代(Permanent Generation)。（包含应用的类/方法信息, 以及JRE库的类和方法信息.和垃圾回收基本无关）   



新生代中的对象“朝生夕死”，每次GC时都会有大量对象死去，少量存活，使用复制算法。新生代又分为Eden区和Survivor区（Survivor from、Survivor to），大小比例默认为8:1:1。

老年代中的对象因为对象存活率高、没有额外空间进行分配担保，就使用标记-清除或标记-整理算法。

新产生的对象优先进去Eden区，当Eden区满了之后再使用Survivor from，当Survivor from 也满了之后就进行Minor GC（新生代GC），将Eden和Survivor from中存活的对象copy进入Survivor to，然后清空Eden和Survivor from，这个时候原来的Survivor from成了新的Survivor to，原来的Survivor to成了新的Survivor from。复制的时候，如果Survivor to 无法容纳全部存活的对象，则根据老年代的分配担保（类似于银行的贷款担保）将对象copy进去老年代，如果老年代也无法容纳，则进行Full GC（老年代GC）。

**大对象直接进入老年代**：JVM中有个参数配置-XX:PretenureSizeThreshold，令大于这个设置值的对象直接进入老年代，目的是为了避免在Eden和Survivor区之间发生大量的内存复制。

**长期存活的对象进入老年代**：JVM给每个对象定义一个对象年龄计数器，如果对象在Eden出生并经过第一次Minor GC后仍然存活，并且能被Survivor容纳，将被移入Survivor并且年龄设定为1。没熬过一次Minor GC，年龄就加1，当他的年龄到一定程度（默认为15岁，可以通过XX:MaxTenuringThreshold来设定），就会移入老年代。但是JVM并不是永远要求年龄必须达到最大年龄才会晋升老年代，**如果Survivor 空间中相同年龄（如年龄为x）所有对象大小的总和大于Survivor的一半，年龄大于等于x的所有对象直接进入老年代，无需等到最大年龄要求**。

### 垃圾收集器

垃圾回收算法是方法论，垃圾回收器是实现。

![image-20190227195802636](https://ws2.sinaimg.cn/large/006tKfTcgy1g0l8ci31b5j314o0howhg.jpg)

- Serial收集器，串行收集器是最古老，最稳定以及效率高的收集器，可能会产生较长的停顿，只使用一个线程去回收。（STW）它是虚拟机运行在client模式下的默认新生代收集器：简单而高效（与其他收集器的单个线程相比，因为没有线程切换的开销等）。

- ParNew收集器，ParNew收集器其实就是Serial收集器的多线程版本。（STW）是许多运行在Server模式下的JVM中首选的新生代收集器，其中一个很重还要的原因就是除了Serial之外，只有他能和老年代的CMS收集器配合工作。

- Parallel Scavenge收集器，Parallel Scavenge收集器类似ParNew收集器，Parallel收集器更关注系统的吞吐量（就是CPU运行用户代码的时间与CPU总消耗时间的比值，即 吞吐量=运行用户代码的时间/[运行用户代码的时间+垃圾收集时间]）。

- CMS收集器，CMS（Concurrent Mark Sweep）收集器是一种以获取最短回收停顿时间为目标的收集器。，停顿时间短，用户体验就好。

  基于“标记清除”算法，并发收集、低停顿，运作过程复杂，分4步：

  1)初始标记：仅仅标记GC Roots能直接关联到的对象，速度快，但是需要“Stop The World”

  2)并发标记：就是进行追踪引用链的过程，可以和用户线程并发执行。

  3)重新标记：修正并发标记阶段因用户线程继续运行而导致标记发生变化的那部分对象的标记记录，比初始标记时间长但远比并发标记时间短，需要“Stop The World”

  4)并发清除：清除标记为可以回收对象，可以和用户线程并发执行

  由于整个过程耗时最长的并发标记和并发清除都可以和用户线程一起工作，所以总体上来看，CMS收集器的内存回收过程和用户线程是并发执行的。

  CSM收集器有3个缺点：

  1)对CPU资源非常敏感

  并发收集虽然不会暂停用户线程，但因为占用一部分CPU资源，还是会导致应用程序变慢，总吞吐量降低。

  CMS的默认收集线程数量是=(CPU数量+3)/4；当CPU数量多于4个，收集线程占用的CPU资源多于25%，对用户程序影响可能较大；不足4个时，影响更大，可能无法接受。

  2)无法处理浮动垃圾（在并发清除时，用户线程新产生的垃圾叫浮动垃圾）,可能出现"Concurrent Mode Failure"失败。

  并发清除时需要预留一定的内存空间，不能像其他收集器在老年代几乎填满再进行收集；如果CMS预留内存空间无法满足程序需要，就会出现一次"Concurrent Mode Failure"失败；这时JVM启用后备预案：临时启用Serail Old收集器，而导致另一次Full GC的产生；

  3)产生大量内存碎片：CMS基于"标记-清除"算法，清除后不进行压缩操作产生大量不连续的内存碎片，这样会导致分配大内存对象时，无法找到足够的连续内存，从而需要提前触发另一次Full GC动作。

- Serial Old收集器，Serial 收集器的老年代版本，单线程，“标记整理”算法，主要是给Client模式下的虚拟机使用。可以作为CMS的后背方案，在CMS发生Concurrent Mode Failure是使用

- Parallel Old 收集器，Parallel Scavenge的老年代版本，多线程，“标记整理”算法，JDK 1.6才出现。在此之前Parallel Scavenge只能同Serial Old搭配使用，由于Serial Old的性能较差导致Parallel Scavenge的优势发挥不出来，Parallel Old收集器的出现，使“吞吐量优先”收集器终于有了名副其实的组合。在吞吐量和CPU敏感的场合，都可以使用Parallel Scavenge/Parallel Old组合。

- G1收集器，G1 (Garbage-First)是一款面向服务器的垃圾收集器,主要针对配备多颗处理器及大容量内存的机器. 以极高概率满足GC停顿时间要求的同时,还具备高吞吐量性能特征。G1是面向服务端应用的垃圾收集器。它的使命是未来可以替换掉CMS收集器。

### 垃圾回收过程

-  Marking 标记

  垃圾收集器会找出那些需要回收的对象所在的内存和不需要回收的对象所在的内存，并把它们标记出来，简单的说，也就是先找出垃圾在哪。

  所有堆中的对象都会被扫描一遍，以此来确定回收的对象，所以这通常会是一个相对比较耗时的过程

  ![7](https://ws4.sinaimg.cn/large/006tKfTcgy1g0ir1du1lij30qo0k0q2t.jpg)

- Normal Deletion 清除

  垃圾收集器会清除掉上一步标记出来的那些需要回收的对象区域。

  存在的问题就是碎片问题：
  标记清除之后会产生大量不连续的内存碎片，空间碎片太多可能会导致以后在程序运行过程中需要分配较大对象时，无法找到足够的连续内存而不得不提前触发另一次垃圾收集动作。

  ![6](https://ws3.sinaimg.cn/large/006tKfTcgy1g0ir1mb8rsj30qo0k0jrb.jpg)

  

- Deletion with Compacting 压缩

  由于简单的清除可能会存在碎片的问题，所以又出现了压缩清除的方法，也就是先清除需要回收的对象，然后再对内存进行压缩操作，将内存分成可用和不可用两大部分：

  ![5](https://ws3.sinaimg.cn/large/006tKfTcgy1g0ir10bu2xj30qo0k0t8n.jpg)

## jvm内存结构、java内存模型、java对象模型的区别

### java内存结构

我们都知道，Java代码是要运行在虚拟机上的，而虚拟机在执行Java程序的过程中会把所管理的内存划分为若干个不同的数据区域，这些区域都有各自的用途。其中有些区域随着虚拟机进程的启动而存在，而有些区域则依赖用户线程的启动和结束而建立和销毁。在《[Java虚拟机规范（Java SE 8）](https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-2.html#jvms-2.5.4)》中描述了JVM运行时内存区域结构如下：

![9](https://ws1.sinaimg.cn/large/006tKfTcgy1g0l93hspouj30ir09qdid.jpg)

各个区域的功能不是本文重点，就不在这里详细介绍了。这里简单提几个需要特别注意的点：

1、以上是Java虚拟机规范，不同的虚拟机实现会各有不同，但是一般会遵守规范。

2、规范中定义的方法区，只是一种概念上的区域，并说明了其应该具有什么功能。但是并没有规定这个区域到底应该处于何处。所以，对于不同的虚拟机实现来说，是由一定的自由度的。

3、不同版本的方法区所处位置不同，上图中划分的是逻辑区域，并不是绝对意义上的物理区域。因为某些版本的JDK中方法区其实是在堆中实现的。

4、运行时常量池用于存放编译期生成的各种字面量和符号应用。但是，Java语言并不要求常量只有在编译期才能产生。比如在运行期，String.intern也会把新的常量放入池中。

5、除了以上介绍的JVM运行时内存外，还有一块内存区域可供使用，那就是直接内存。Java虚拟机规范并没有定义这块内存区域，所以他并不由JVM管理，是利用本地方法库直接在堆外申请的内存区域。

6、堆和栈的数据划分也不是绝对的，如HotSpot的JIT会针对对象分配做相应的优化。

如上，做个总结，JVM内存结构，由Java虚拟机规范定义。描述的是Java程序执行过程中，由JVM管理的不同数据区域。各个区域有其特定的功能。

### java内存模型

**更恰当说JMM描述的是一组规则，通过这组规则控制程序中各个变量在共享数据区域和私有数据区域的访问方式，JMM是围绕原子性，有序性、可见性展开的。**

Java内存模型看上去和Java内存结构（JVM内存结构）差不多，很多人会误以为两者是一回事儿，这也就导致面试过程中经常答非所为。

在前面的关于JVM的内存结构的图中，我们可以看到，其中Java堆和方法区的区域是多个线程共享的数据区域。也就是说，多个线程可能可以操作保存在堆或者方法区中的同一个数据。这也就是我们常说的“Java的线程间通过共享内存进行通信”。

Java内存模型是根据英文Java Memory Model（JMM）翻译过来的。其实JMM并不像JVM内存结构一样是真实存在的。他只是一个抽象的概念。[JSR-133: Java Memory Model and Thread Specification](http://www.cs.umd.edu/~pugh/java/memoryModel/jsr133.pdf)中描述了，JMM是和多线程相关的，他描述了一组规则或规范，这个规范定义了一个线程对共享变量的写入时对另一个线程是可见的。

那么，简单总结下，Java的多线程之间是通过共享内存进行通信的，而由于采用共享内存进行通信，在通信过程中会存在一系列如可见性、原子性、顺序性等问题，而**JMM就是围绕着多线程通信以及与其相关的一系列特性而建立的模型。JMM定义了一些语法集，这些语法集映射到Java语言中就是volatile、synchronized等关键字。**

![10](https://ws4.sinaimg.cn/large/006tKfTcgy1g0l949rhmxj30br0ah0st.jpg)

在Java中，JMM是一个非常重要的概念，正是由于有了JMM，Java的并发编程才能避免很多问题。

### java对象模型

Java是一种面向对象的语言，而**Java对象在JVM中的存储也是有一定的结构的**。而这个关于Java对象自身的存储模型称之为Java对象模型。

HotSpot虚拟机中，设计了一个OOP-Klass Model。OOP（Ordinary Object Pointer）指的是普通对象指针，而Klass用来描述对象实例的具体类型。

每一个Java类，在被JVM加载的时候，JVM会给这个类创建一个`instanceKlass`，保存在方法区，用来在JVM层表示该Java类。当我们在Java代码中，使用new创建一个对象的时候，JVM会创建一个`instanceOopDesc`对象，这个对象中包含了对象头以及实例数据。

![11](https://ws2.sinaimg.cn/large/006tKfTcgy1g0l94t3ke6j31840js429.jpg)

这就是一个简单的Java对象的OOP-Klass模型，即Java对象模型。

### 总结

我们再来区分下JVM内存结构、 Java内存模型 以及 Java对象模型 三个概念。

JVM内存结构，和**Java虚拟机的运行时区域**有关。

 Java内存模型，和**Java的并发编程有关**。

 Java对象模型，和**Java对象在虚拟机中的表现形式有关**。

## Java中的强引用、弱引用、软引用、虚引用

（1）强引用：默认情况下，对象采用的均为强引用（这个对象的实例没有其他对象引用，GC时才会被回收）

（2）软引用：软引用是Java中提供的一种比较适合于缓存场景的应用（只有在内存不够用的情况下才会被GC）

（3）弱引用：在GC时一定会被GC回收

（4）虚引用：由于虚引用只是用来得知对象是否被GC

### 强引用(StrongReference)

**强引用**是使用最普遍的引用。如果一个对象具有强引用，那**垃圾回收器**绝不会回收它。如下：

```java
Object strongReference = new Object();
```

当**内存空间不足**时，`Java`虚拟机宁愿抛出`OutOfMemoryError`错误，使程序**异常终止**，也不会靠随意**回收**具有**强引用**的**对象**来解决内存不足的问题。 如果强引用对象**不使用时**，需要弱化从而使`GC`能够回收，如下：

```java
strongReference = null;
```

显式地设置`strongReference`对象为`null`，或让其**超出**对象的**生命周期**范围，则`gc`认为该对象**不存在引用**，这时就可以回收这个对象。具体什么时候收集这要取决于`GC`算法。

### 软引用(SoftReference)

如果一个对象只具有**软引用**，则**内存空间充足**时，**垃圾回收器**就**不会**回收它；如果**内存空间不足**了，就会**回收**这些对象的内存。只要垃圾回收器没有回收它，该对象就可以被程序使用。

软引用可用来实现内存敏感的高速缓存。

```java
// 软引用
    String str = new String("abc");
    SoftReference<String> softReference = new SoftReference<String>(str);
```

当内存不足时，`JVM`首先将**软引用**中的**对象**引用置为`null`，然后通知**垃圾回收器**进行回收：

```
if(JVM内存不足) {
        // 将软引用中的对象引用置为null
        str = null;
        // 通知垃圾回收器进行回收
        System.gc();
    }
```

也就是说，**垃圾收集线程**会在虚拟机抛出`OutOfMemoryError`之前回**收软引用对象**，而且**虚拟机**会尽可能优先回收**长时间闲置不用**的**软引用对象**。对那些**刚构建**的或刚使用过的**"较新的"**软对象会被虚拟机尽可能**保留**，这就是引入**引用队列**`ReferenceQueue`的原因。

**应用场景：**

浏览器的后退按钮。按后退时，这个后退时显示的网页内容是重新进行请求还是从缓存中取出呢？这就要看具体的实现策略了。

1. 如果一个网页在浏览结束时就进行内容的回收，则按后退查看前面浏览过的页面时，需要重新构建；
2. 如果将浏览过的网页存储到内存中会造成内存的大量浪费，甚至会造成内存溢出。

这时候就可以使用软引用，很好的解决了实际的问题：

```java
// 获取浏览器对象进行浏览
    Browser browser = new Browser();
    // 从后台程序加载浏览页面
    BrowserPage page = browser.getPage();
    // 将浏览完毕的页面置为软引用
    SoftReference softReference = new SoftReference(page);

    // 回退或者再次浏览此页面时
    if(softReference.get() != null) {
        // 内存充足，还没有被回收器回收，直接获取缓存
        page = softReference.get();
    } else {
        // 内存不足，软引用的对象已经回收
        page = browser.getPage();
        // 重新构建软引用
        softReference = new SoftReference(page);
    }


```

### 弱引用(WeakReference)

**弱引用**与**软引用**的区别在于：只具有**弱引用**的对象拥有**更短暂**的**生命周期**。在垃圾回收器线程扫描它所管辖的内存区域的过程中，一旦发现了只具有**弱引用**的对象，不管当前**内存空间足够与否**，都会**回收**它的内存。不过，由于垃圾回收器是一个**优先级很低的线程**，因此**不一定**会**很快**发现那些只具有**弱引用**的对象。

```java
 String str = new String("abc");
    WeakReference<String> weakReference = new WeakReference<>(str);
    str = null;
```

如果一个对象是偶尔(很少)的使用，并且希望在使用时随时就能获取到，但又不想影响此对象的垃圾收集，那么你应该用Weak Reference来记住此对象。一个使用弱引用的例子是WeakHashMap，它是除HashMap和TreeMap之外，Map接口的另一种实现。WeakHashMap有一个特点：map中的键值(keys)都被封装成弱引用，也就是说一旦强引用被删除，WeakHashMap内部的弱引用就无法阻止该对象被垃圾回收器回收。

下面的代码会让一个**弱引用**再次变为一个**强引用**：

```
    String str = new String("abc");
    WeakReference<String> weakReference = new WeakReference<>(str);
    // 弱引用转强引用
    String strongReference = weakReference.get();
```

Threadlocal中的`ThreadLocalMap`的成员变量，`ThreadLocalMap `内部采用`WeakReference`数组保存，数组的key即为`ThreadLocal `内部的Hash值。

### 虚引用(PhantomReference)

**虚引用**顾名思义，就是**形同虚设**。与其他几种引用都不同，**虚引用**并**不会**决定对象的**生命周期**。如果一个对象**仅持有虚引用**，那么它就和**没有任何引用**一样，在任何时候都可能被垃圾回收器回收。

**应用场景：**

**虚引用**主要用来**跟踪对象**被垃圾回收器**回收**的活动。 **虚引用**与**软引用**和**弱引用**的一个区别在于：

> 虚引用必须和引用队列(ReferenceQueue)联合使用。当垃圾回收器准备回收一个对象时，如果发现它还有虚引用，就会在回收对象的内存之前，把这个虚引用加入到与之关联的引用队列中。

```java
    String str = new String("abc");
    ReferenceQueue queue = new ReferenceQueue();
    // 创建虚引用，要求必须与一个引用队列关联
    PhantomReference pr = new PhantomReference(str, queue);
```

程序可以通过判断引用**队列**中是否已经加入了**虚引用**，来了解被引用的对象是否将要进行**垃圾回收**。如果程序发现某个虚引用已经被加入到引用队列，那么就可以在所引用的对象的**内存被回收之前**采取必要的行动。

### Android中软引用/弱引用的使用场景

在Android应用的开发中，为了防止内存溢出，在处理一些占用内存大而且声明周期较长的对象时候，可以尽量应用软引用和弱引用技术。 下面以使用软引用为例来详细说明。弱引用的使用方式与软引用是类似的。

假设我们的应用会用到大量的默认图片，比如应用中有默认的头像，默认游戏图标等等，这些图片很多地方会用到。如果每次都去读取图片，由于读取文件需要硬件操作，速度较慢，会导致性能较低。所以我们考虑将图片缓存起来，需要的时候直接从内存中读取。但是，由于图片占用内存空间比较大，缓存很多图片需要很多的内存，就可能比较容易发生OutOfMemory异常。这时，我们可以考虑使用软引用技术来避免这个问题发生。

使用软引用以后，在OutOfMemory异常发生之前，这些缓存的图片资源的内存空间可以被释放掉的，从而避免内存达到上限，避免Crash发生。 需要注意的是，在垃圾回收器对这个Java对象回收前，SoftReference类所提供的get方法会返回Java对象的强引用，一旦垃圾线程回收该Java对象之后，get方法将返回null。所以在获取软引用对象的代码中，一定要判断是否为null，以免出现NullPointerException异常导致应用崩溃，同理也是用这个方法去判断是否需要重新加载资源。

## 锁

### 锁的概念

#### **可重入锁**

如果锁具备可重入性，则称作为可重入锁。像synchronized和ReentrantLock都是可重入锁，可重入性在我看来实际上表明了锁的分配机制：基于线程的分配，而不是基于方法调用的分配。举个简单的例子，当一个线程执行到某个synchronized方法时，比如说method1，而在method1中会调用另外一个synchronized方法method2，此时线程不必重新去申请锁，而是可以直接执行方法method2。

#### **可中断锁**

可中断锁：顾名思义，就是可以相应中断的锁。

在Java中，**synchronized就不是可中断锁，而Lock是可中断锁（lock.lockInterruptibly()）**。

如果某一线程A正在执行锁中的代码，另一线程B正在等待获取该锁，可能由于等待时间过长，线程B不想等待了，想先处理其他事情，我们可以让它中断自己或者在别的线程中中断它，这种就是可中断锁。

在前面演示`lockInterruptibly()`的用法时已经体现了Lock的可中断性。

#### **公平锁**

公平锁即**尽量以请求锁的顺序来获取锁**。比如同是有多个线程在等待一个锁，当这个锁被释放时，等待时间最久的线程（最先请求的线程）会获得该所，这种就是公平锁。

非公平锁即无法保证锁的获取是按照请求锁的顺序进行的。这样就可能导致某个或者一些线程永远获取不到锁。

在Java中，synchronized就是非公平锁，它无法保证等待的线程获取锁的顺序。

而对于ReentrantLock和ReentrantReadWriteLock，它默认情况下是非公平锁，但是可以设置为公平锁。

### [Volatile原理](http://www.cnblogs.com/dolphin0520/p/3920373.html)

### 计算机内存模型

计算机在执行程序时，每条指令都是在CPU中执行的，而执行指令过程中，势必涉及到数据的读取和写入。由于程序运行过程中的临时数据是存放在主存（物理内存）当中的，这时就存在一个问题，由于CPU执行速度很快，而从内存读取数据和向内存写入数据的过程跟CPU执行指令的速度比起来要慢的多，因此如果任何时候对数据的操作都要通过和内存的交互来进行，会大大降低指令执行的速度。因此在CPU里面就有了高速缓存。**当程序在运行过程中，会将运算需要的数据从主存复制一份到CPU的高速缓存当中，那么CPU进行计算时就可以直接从它的高速缓存读取数据和向其中写入数据，当运算结束之后，再将高速缓存中的数据刷新到主存当中**。举个简单的例子，比如下面的这段代码：

```Java
i = i + 1;
```

> 当线程执行这个语句时，会先从主存当中读取`i`的值，然后复制一份到高速缓存当中，然后 CPU 执行指令对`i`进行加1操作，然后将数据写入高速缓存，最后将高速缓存中`i`最新的值刷新到主存当中。

这个代码在单线程中运行是没有任何问题的，但是在多线程中运行就会有问题了。在多核 CPU 中，每条线程可能运行于不同的 CPU 中，因此 **每个线程运行时有自己的高速缓存**（对单核CPU来说，其实也会出现这种问题，只不过是以线程调度的形式来分别执行的）。比如同时有两个线程执行这段代码，假如初始时`i`的值为`0`，那么我们希望两个线程执行完之后i的值变为2。但是事实会是这样吗？

可能出现这种情况：初始时，**两个线程分别读取`i`的值存入各自所在的 CPU 的高速缓存当中，然后 线程1 进行加1操作，然后把`i`的最新值1写入到内存。此时线程2的高速缓存当中`i`的值还是0，进行加1操作之后，`i`的值为1，然后线程2把i的值写入内存。最终结果`i`的值是1，而不是2。这就是著名的缓存一致性问题**。通常称这种被多个线程访问的变量为共享变量。

为了解决缓存不一致性问题，通常来说有以下两种解决方法：

  - 通过在总线加`LOCK#`锁的方式
  - 通过 **缓存一致性协议**

> 这两种方式都是硬件层面上提供的方式。

在早期的 CPU 当中，是通过在总线上加`LOCK#`锁的形式来解决缓存不一致的问题。因为 CPU 和其他部件进行通信都是通过总线来进行的，如果对总线加LOCK#锁的话，也就是说阻塞了其他 CPU 对其他部件访问（如内存），从而使得只能有一个 CPU 能使用这个变量的内存。比如上面例子中 如果一个线程在执行 `i = i +1`，如果在执行这段代码的过程中，在总线上发出了`LCOK#`锁的信号，那么只有等待这段代码完全执行完毕之后，其他CPU才能从变量i所在的内存读取变量，然后进行相应的操作。这样就解决了缓存不一致的问题。但是上面的方式会有一个问题，**由于在锁住总线期间，其他CPU无法访问内存，导致效率低下**。

所以就出现了缓存一致性协议。最出名的就是 Intel 的`MESI协议`，`MESI协议`保证了每个缓存中使用的共享变量的副本是一致的。它核心的思想是：**当CPU写数据时，如果发现操作的变量是共享变量，即在其他CPU中也存在该变量的副本，会发出信号通知其他CPU将该变量的缓存行置为无效状态，因此当其他CPU需要读取这个变量时，发现自己缓存中缓存该变量的缓存行是无效的，那么它就会从内存重新读取**。

![9](https://ws2.sinaimg.cn/large/006tKfTcgy1g0issk795tj30l909rgme.jpg)

###　Java内存模型

在Java虚拟机规范中试图定义一种Java内存模型（`Java Memory Model，JMM`）来屏蔽各个硬件平台和操作系统的内存访问差异，以实现让Java程序在各种平台下都能达到一致的内存访问效果。那么Java内存模型规定了程序中变量的访问规则，往大一点说是定义了程序执行的次序。**注意，为了获得较好的执行性能，Java内存模型并没有限制执行引擎使用处理器的寄存器或者高速缓存来提升指令执行速度，也没有限制编译器对指令进行重排序。也就是说，在java内存模型中，也会存在缓存一致性问题和指令重排序的问题**。

**Java内存模型规定所有的变量都是存在主存当中（类似于前面说的物理内存），每个线程都有自己的工作内存（类似于前面的高速缓存）。线程对变量的所有操作都必须在工作内存中进行，而不能直接对主存进行操作。并且每个线程不能访问其他线程的工作内存**。

在Java中，执行下面这个语句：

```Java
i  = 10;
```

执行线程必须先在自己的工作线程中对变量`i`所在的缓存行进行赋值操作，然后再写入主存当中。而不是直接将数值`10`写入主存当中。那么Java语言本身对 原子性、可见性以及有序性提供了哪些保证呢？

#### 原子性

> 即一个操作或者多个操作 要么全部执行并且执行的过程不会被任何因素打断，要么就都不执行。

**在Java中，对基本数据类型的变量的读取和赋值操作是原子性操作，即这些操作是不可被中断的，要么执行，要么不执行**。上面一句话虽然看起来简单，但是理解起来并不是那么容易。看下面一个例子`i`：请分析以下哪些操作是原子性操作：

```Java
x = 10;        //语句1
y = x;         //语句2
x++;           //语句3
x = x + 1;     //语句4
```

咋一看，有些朋友可能会说上面的4个语句中的操作都是原子性操作。**其实只有`语句1`是原子性操作，其他三个语句都不是原子性操作**。

  - `语句1`是直接将数值`10`赋值给`x`，也就是说线程执行这个语句的会直接将数值`10`写入到工作内存中。
  - `语句2`实际上包含2个操作，它先要去读取`x`的值，再将`x`的值写入工作内存，虽然读取x的值以及 将x的值写入工作内存 这2个操作都是原子性操作，但是合起来就不是原子性操作了。
  - 同样的，`x++`和 `x = x+1`包括3个操作：读取`x`的值，进行加`1`操作，写入新的值。

也就是说，**只有简单的读取、赋值（而且必须是将数字赋值给某个变量，变量之间的相互赋值不是原子操作）才是原子操作**。不过这里有一点需要注意：**在32位平台下，对64位数据的读取和赋值是需要通过两个操作来完成的，不能保证其原子性。但是好像在最新的JDK中，JVM已经保证对64位数据的读取和赋值也是原子性操作了**。

从上面可以看出，Java内存模型只保证了基本读取和赋值是原子性操作，如果要实现更大范围操作的原子性，可以通过`synchronize`d和`Lock`来实现。由于`synchronized`和`Lock`能够保证任一时刻只有一个线程执行该代码块，那么自然就不存在原子性问题了，从而保证了原子性。

#### 可见性

> 可见性是指当多个线程访问同一个变量时，一个线程修改了这个变量的值，其他线程能够立即看得到修改的值。

对于可见性，Java提供了`volatile`关键字来保证可见性。**当一个共享变量被`volatile`修饰时，它会保证修改的值会立即被更新到主存，当有其他线程需要读取时，它会去内存中读取新值**。而普通的共享变量不能保证可见性，因为普通共享变量被修改之后，什么时候被写入主存是不确定的，当其他线程去读取时，此时内存中可能还是原来的旧值，因此无法保证可见性。

另外，通过`synchronized`和`Lock`也能够保证可见性，`synchronized`和`Lock`能保证同一时刻只有一个线程获取锁然后执行同步代码，并且在释放锁之前会将对变量的修改刷新到主存当中。因此可以保证可见性。

#### 有序性

> 即程序执行的顺序按照代码的先后顺序执行。

> 指令重排序，一般来说，处理器为了提高程序运行效率，可能会对输入代码进行优化，它不保证程序中各个语句的执行先后顺序同代码中的顺序一致，但是它会保证程序最终执行结果和代码顺序执行的结果是一致的。

**处理器在进行重排序时是会考虑指令之间的数据依赖性，如果一个指令Instruction 2必须用到Instruction 1的结果，那么处理器会保证Instruction 1会在Instruction 2之前执行**。

在Java内存模型中，允许编译器和处理器对指令进行重排序，但是重排序过程不会影响到单线程程序的执行，却会影响到多线程并发执行的正确性。

在Java里面，可以通过`volatile`关键字来保证一定的“有序性”（具体原理在下一节讲述）。另外可以通过`synchronized`和`Lock`来保证有序性，很显然，`synchronized`和`Lock`保证每个时刻是有一个线程执行同步代码，相当于是让线程顺序执行同步代码，自然就保证了有序性。

另外，Java内存模型具备一些先天的“有序性”，即不需要通过任何手段就能够得到保证的有序性，这个通常也称为 `happens-before` 原则。如果两个操作的执行次序无法从`happens-before`原则推导出来，那么它们就不能保证它们的有序性，虚拟机可以随意地对它们进行重排序。

下面就来具体介绍下`happens-before`原则（先行发生原则）：

  - **程序次序规则**：一个线程内，按照代码顺序，书写在前面的操作先行发生于书写在后面的操作
  - **锁定规则**：一个unLock操作先行发生于后面对同一个锁额lock操作
  - **volatile变量规则**：对一个变量的写操作先行发生于后面对这个变量的读操作
  - **传递规则**：如果操作A先行发生于操作B，而操作B又先行发生于操作C，则可以得出操作A先行发生于操作C
  - **线程启动规则**：Thread对象的start()方法先行发生于此线程的每个一个动作
  - **线程中断规则**：对线程interrupt()方法的调用先行发生于被中断线程的代码检测到中断事件的发生
  - **线程终结规则**：线程中所有的操作都先行发生于线程的终止检测，我们可以通过Thread.join()方法结束、Thread.isAlive()的返回值手段检测到线程已经终止执行
  - **对象终结规则**：一个对象的初始化完成先行发生于他的finalize()方法的开始


对于程序次序规则来说，我的理解就是一段程序代码的执行在单个线程中看起来是有序的。注意，虽然这条规则中提到“书写在前面的操作先行发生于书写在后面的操作”，这个应该是程序看起来执行的顺序是按照代码顺序执行的，因为虚拟机可能会对程序代码进行指令重排序。虽然进行重排序，但是最终执行的结果是与程序顺序执行的结果一致的，它只会对不存在数据依赖性的指令进行重排序。因此，在单个线程中，程序执行看起来是有序执行的，这一点要注意理解。事实上，这个规则是用来保证程序在单线程中执行结果的正确性，但无法保证程序在多线程中执行的正确性。

第二条规则也比较容易理解，也就是说无论在单线程中还是多线程中，同一个锁如果出于被锁定的状态，那么必须先对锁进行了释放操作，后面才能继续进行lock操作。

第三条规则是一条比较重要的规则，也是后文将要重点讲述的内容。**直观地解释就是，如果一个线程先去写一个变量，然后一个线程去进行读取，那么写入操作肯定会先行发生于读操作**。

第四条规则实际上就是体现`happens-before`原则具备传递性。

### 深入剖析Volatile关键字

**volatile可以保证可见性和有序性,不能保证原子性**

#### Volatile的语义

一旦一个共享变量（类的成员变量、类的静态成员变量）被`volatile`修饰之后，那么就具备了两层语义：

  - 保证了不同线程对这个变量进行操作时的可见性，即一个线程修改了某个变量的值，这新值对其他线程来说是立即可见的。
 - 禁止进行指令重排序。

先看一段代码，假如线程1先执行，线程2后执行：

```Java
//线程1
boolean stop = false;
while(!stop){
    doSomething();
}

//线程2
stop = true;
```

这段代码是很典型的一段代码，很多人在中断线程时可能都会采用这种标记办法。但是事实上，这段代码会完全运行正确么？即一定会将线程中断么？不一定，也许在大多数时候，这个代码能够把线程中断，但是也有可能会导致无法中断线程（虽然这个可能性很小，但是只要一旦发生这种情况就会造成死循环了）。

下面解释一下这段代码为何有可能导致无法中断线程。在前面已经解释过，每个线程在运行过程中都有自己的工作内存，那么`线程1`在运行的时候，会将`stop`变量的值拷贝一份放在自己的工作内存当中。

那么当`线程2`更改了`stop`变量的值之后，但是还没来得及写入主存当中，`线程2`转去做其他事情了，那么`线程1`由于不知道`线程2`对`stop`变量的更改，因此还会一直循环下去。但是用`volatile`修饰之后就变得不一样了：

 - 使用`volatile`关键字会强制将修改的值立即写入主存；
  - 使用`volatile`关键字的话，当`线程2`进行修改时，会导致`线程1`的工作内存中缓存变量`stop`的缓存行无效（*反映到硬件层的话，就是CPU的L1或者L2缓存中对应的缓存行无效*）；
  - 由于`线程1`的工作内存中缓存变量`stop`的缓存行无效，所以`线程1`再次读取变量`stop`的值时会去主存读取。
  - 那么在`线程2`修改`stop`值时（当然这里包括2个操作，修改线程2工作内存中的值，然后将修改后的值写入内存），会使得`线程1`的工作内存中缓存变量`stop`的缓存行无效，然后`线程1`读取时，发现自己的缓存行无效，它会等待缓存行对应的主存地址被更新之后，然后去对应的主存读取最新的值。

那么线程1读取到的就是最新的正确的值。

#### Volatile与原子性

从上面知道`volatile`关键字保证了操作的可见性，但是`volatile`能保证对变量的操作是原子性吗？

下面看一个例子：

```Java
public class Test {
    public volatile int inc = 0;

    public void increase() {
        inc++;
    }

    public static void main(String[] args) {
        final Test test = new Test();
        for(int i=0;i<10;i++){
            new Thread(){
                public void run() {
                    for(int j=0;j<1000;j++)
                        test.increase();
                };
            }.start();
        }

        while(Thread.activeCount()>1)  //保证前面的线程都执行完
            Thread.yield();
        System.out.println(test.inc);
    }
}
```

大家想一下这段程序的输出结果是多少？**也许有些朋友认为是10000。但是事实上运行它会发现每次运行结果都不一致，都是一个小于10000的数字**。可能有的朋友就会有疑问，不对啊，上面是对变量`inc`进行自增操作，由于`volatile`保证了可见性，那么在每个线程中对`inc`自增完之后，在其他线程中都能看到修改后的值啊，所以有10个线程分别进行了1000次操作，那么最终`inc`的值应该是`1000*10=10000`。

**这里面就有一个误区了，volatile关键字能保证可见性没有错，但是上面的程序错在没能保证原子性。可见性只能保证每次读取的是最新的值，但是volatile没办法保证对变量的操作的原子性**。

在前面已经提到过，自增操作是不具备原子性的，它包括读取变量的原始值、进行加1操作、写入工作内存。那么就是说自增操作的三个子操作可能会分割开执行，就有可能导致下面这种情况出现：

```
假如某个时刻变量inc的值为10，

线程1对变量进行自增操作，线程1先读取了变量inc的原始值，然后线程1被阻塞了；

然后线程2对变量进行自增操作，线程2也去读取变量inc的原始值，由于线程1只是对变量inc进行读取操作，而没有对变量进行修改操作，所以不会导致线程2的工作内存中缓存变量inc的缓存行无效，所以线程2会直接去主存读取inc的值，发现inc的值时10，然后进行加1操作，并把11写入工作内存，最后写入主存。

然后线程1接着进行加1操作，由于已经读取了inc的值，注意此时在线程1的工作内存中inc的值仍然为10，所以线程1对inc进行加1操作后inc的值为11，然后将11写入工作内存，最后写入主存。

那么两个线程分别进行了一次自增操作后，inc只增加了1。
```

解释到这里，可能有朋友会有疑问，不对啊，前面不是保证一个变量在修改volatile变量时，会让缓存行无效吗？然后其他线程去读就会读到新的值，对，这个没错。这个就是上面的`happens-before`规则中的`volatile`变量规则，但是要注意，**线程1对变量进行读取操作之后，被阻塞了的话，并没有对inc值进行修改。然后虽然volatile能保证线程2对变量inc的值读取是从内存中读取的，但是线程1没有进行修改，所以线程2根本就不会看到修改的值**。

**根源就在这里，自增操作不是原子性操作，而且volatile也无法保证对变量的任何操作都是原子性的**。解决的方法也就是对提供原子性的自增操作即可。

在`Java 1.5`的`java.util.concurrent.atomic`包下提供了一些原子操作类，即对基本数据类型的 自增（加1操作），自减（减1操作）、以及加法操作（加一个数），减法操作（减一个数）进行了封装，保证这些操作是原子性操作。`atomic`是利用CAS来实现原子性操作的（`Compare And Swap`），CAS实际上是利用处理器提供的CMPXCHG指令实现的，而处理器执行CMPXCHG指令是一个原子性操作。

#### Volatile与有序性

在前面提到`volatile`关键字能禁止指令重排序，所以`volatile`能在一定程度上保证有序性。`volatile`关键字禁止指令重排序有两层意思：

  - 当程序执行到`volatile`变量的读操作或者写操作时，在其前面的操作的更改肯定全部已经进行，且结果已经对后面的操作可见，在其后面的操作肯定还没有进行；
  - **在进行指令优化时，不能将在对`volatile`变量访问的语句放在其后面执行，也不能把`volatile`变量后面的语句放到其前面执行**。

可能上面说的比较绕，举个简单的例子：

```Java
//x、y为非volatile变量
//flag为volatile变量

x = 2;        //语句1
y = 0;        //语句2
flag = true;  //语句3
x = 4;         //语句4
y = -1;       //语句5
```

由于flag变量为`volatile`变量，那么在进行指令重排序的过程的时候，不会将`语句3`放到`语句1`、`语句2`前面，也不会讲`语句3`放到`语句4`、`语句5`后面。但是要注意`语句1`和`语句2`的顺序、`语句4`和`语句5`的顺序是不作任何保证的。

并且`volatile`关键字能保证，执行到`语句3`时`，语句1`和`语句2`必定是执行完毕了的，且`语句1`和`语句2`的执行结果对`语句3`、`语句4`、`语句5`是可见的。

#### Volatile的原理和实现机制

前面讲述了源于volatile关键字的一些使用，下面我们来探讨一下volatile到底如何保证可见性和禁止指令重排序的。下面这段话摘自《深入理解Java虚拟机》：

> 观察加入volatile关键字和没有加入volatile关键字时所生成的汇编代码发现，加入volatile关键字时，会多出一个lock前缀指令

lock前缀指令实际上相当于一个 **内存屏障**（也成内存栅栏），内存屏障会提供3个功能：

  - 它 **确保指令重排序时不会把其后面的指令排到内存屏障之前的位置，也不会把前面的指令排到内存屏障的后面**；即在执行到内存屏障这句指令时，在它前面的操作已经全部完成；
  - 它会 **强制将对缓存的修改操作立即写入主存**；
  - **如果是写操作，它会导致其他CPU中对应的缓存行无效**。

### ReentrantLock 、synchronized

**可保证原子性,可见性**

ReentrantLock 、synchronized都可以实现多线程编程的安全性.
 **相同点:**
 这两种同步方式有很多相似之处，它们都是加锁方式同步，而且都是阻塞式的同步，也就是说当如果一个线程获得了对象锁，进入了同步块，其他访问该同步块的线程都必须阻塞在同步块外面等待，而进行线程阻塞和唤醒的代价是比较高的
 **不同点:**
 这两种方式最大区别就是对于Synchronized来说，它是java语言的关键字，是原生语法层面的互斥，需要jvm实现。而ReentrantLock它是JDK 1.5之后提供的API层面的互斥锁，需要lock()和unlock()方法配合try/finally语句块来完成。

ReentrantLock相比synchronized的高级功能:

- 等待**可中断**，持有锁的线程长期不释放的时候，正在等待的线程可以**选择放弃等待**，这相当于Synchronized来说可以避免出现死锁的情况。
- **公平锁**，多个线程等待同一个锁时，必须按照申请锁的时间顺序获得锁，Synchronized锁非公平锁，ReentrantLock默认的构造函数是创建的非公平锁，可以通过参数true设为公平锁，但公平锁表现的性能不是很好。
- **锁绑定多个条件**，一个ReentrantLock对象可以同时绑定多个对象。
- **在资源竞争不是很激烈的情况下，Synchronized的性能要优于ReetrantLock，但是在资源竞争很激烈的情况下，Synchronized的性能会下降几十倍，但是ReetrantLock的性能能维持常态**；

为什么默认创建的是非公平锁呢？因为非公平锁的效率高呀，当一个线程请求非公平锁时，如果在**发出请求的同时**该锁变成可用状态，那么这个线程会跳过队列中所有的等待线程而获得锁。有的同学会说了，这不就是插队吗？
没错，这就是插队！这也就是为什么它被称作非公平锁。
之所以使用这种方式是因为：

> 在恢复一个被挂起的线程与该线程真正运行之间存在着严重的延迟。

在公平锁模式下，大家讲究先来后到，如果当前线程A在请求锁，即使现在锁处于可用状态，它也得在队列的末尾排着，这时我们需要唤醒排在等待队列队首的线程H(在AQS中其实是次头节点)，由于恢复一个被挂起的线程并且让它真正运行起来需要较长时间，那么这段时间锁就处于空闲状态，时间和资源就白白浪费了，非公平锁的设计思想就是将这段白白浪费的时间利用起来——由于线程A在请求锁的时候本身就处于运行状态，因此如果我们此时把锁给它，它就会立即执行自己的任务，因此线程A有机会在线程H完全唤醒之前获得、使用以及释放锁。这样我们就可以把线程H恢复运行的这段时间给利用起来了，结果就是线程A更早的获取了锁，线程H获取锁的时刻也没有推迟。因此提高了吞吐量。

当然，非公平锁仅仅是在**当前线程请求锁，并且锁处于可用状态时**有效，当请求锁时，锁已经被其他线程占有时，就只能还是老老实实的去排队了。

#### **synchronized**

静态：锁定的是类

非静态：锁定的是对象

有一点要注意：对于synchronized方法或者synchronized代码块，当出现异常时，**JVM会自动释放当前线程占用的锁，因此不会由于异常导致出现死锁现象。**

synchronized 的缺陷：若将一个大的方法声明为synchronized 将会大大影响效率，典型地，若将线程类的方法 run() 声明为　synchronized ，由于在线程的整个生命期内它一直在运行，因此将导致它对本类任何 synchronized 方法的调用都永远不会成功。解决的方法是使用synchronized 块来替代synchronized方法

#### Lock

1）Lock是一个接口，而synchronized是Java中的关键字，synchronized是内置的语言实现；

2）synchronized在发生异常时，**会自动释放线程占有的锁，因此不会导致死锁现象发生；**而Lock在发生异常时，如果没有主动通过unLock()去释放锁，则很可能造成死锁现象，因此使用Lock时需要在finally块中释放锁；

3）**Lock**可以让等待锁的线程**响应中断**，而synchronized却不行，使用**synchronized**时，等待的线程会一直等待下去，**不能够响应中断**；

4）通过**Lock**可以知道**有没有成功获取锁**，而synchronized却无法办到。

5）**Lock**可以提高多个线程进行**读操作的效率**。

Lock 接口实现提供了比使用 synchronized 方法和语句可获得的更广泛的锁定操作。此实现允许更灵活的结构，可以具有差别很大的属性，可以支持多个相关的 Condition 对象。在硬件层面依赖特殊的CPU指令实现同步更加灵活。

> 什么是Condition ？ Condition 接口将 Object 监视器方法（wait、notify 和 notifyAll）分解成截然不同的对象，以便通过将这些对象与任意 Lock 实现组合使用，为每个对象提供多个等待 set（wait-set）。其中，Lock 替代了 synchronized 方法和语句的使用，Condition 替代了 Object 监视器方法的使用。

虽然 synchronized 方法和语句的范围机制使得使用监视器锁编程方便了很多，而且还帮助避免了很多涉及到锁的常见编程错误，但有时也需要以更为灵活的方式使用锁。例如，某些遍历并发访问的数据结果的算法要求使用 "hand-over-hand" 或 "chain locking"：获取节点 A 的锁，然后再获取节点 B 的锁，然后释放 A 并获取 C，然后释放 B 并获取 D，依此类推。Lock 接口的实现允许锁在不同的作用范围内获取和释放，并允许以任何顺序获取和释放多个锁，从而支持使用这种技术，当然，有利就有弊，Lock必须手动在finally块中释放锁。

在java.util.concurrent.locks包中有很多Lock的实现类，常用的有ReentrantLock、ReadWriteLock（实现类ReentrantReadWriteLock）.它们是具体实现类，不是java语言关键字。

#### ReentrantLock

一个可重入的互斥锁 Lock，它具有与使用 synchronized 方法和语句所访问的**隐式监视器锁**相同的一些基本行为和语义，但功能更强大。

重入性：指的是同一个线程多次试图获取它所占有的锁，请求会成功。当释放锁的时候，直到重入次数清零，锁才释放完毕。

ReentrantLock 的lock机制有2种，**忽略中断锁（即忽略掉中断，lock）**和**响应中断锁（即响应中断，lockInterruptibly）**

ReentrantLock相对于synchronized多了三个高级功能： 　　

- 等待可中断
- 可实现公平锁
- 绑定多个Condition ：通过多次newCondition可以获得多个Condition对象,可以简单的实现比较复杂的线程同步的功能.通过await(),signal()

synchronized是托管给JVM执行的，而lock是java写的控制锁的代码。 　 　synchronized原始采用的是CPU**悲观锁**机制，即线程获得的是**独占锁**。独占锁意味着其他线程只能依靠阻塞来等待线程释放锁。而在CPU转换线程阻塞时会引起线程上下文切换，当有很多线程竞争锁的时候，会引起CPU频繁的上下文切换导致效率很低。　 　 　Lock用的是**乐观锁**方式。每次不加锁而是假设没有冲突而去完成某项操作，如果因为冲突失败就重试，直到成功为止。

ReentrantLock必须在finally中释放锁，否则后果很严重，编码角度来说使用synchronized更加简单，不容易遗漏或者出错。

　ReentrantLock提供了可轮询的锁请求，他可以尝试的去取得锁，如果取得成功则继续处理，取得不成功，可以等下次运行的时候处理，所以不容易产生死锁，而synchronized则一旦进入锁请求要么成功，要么一直阻塞，所以更容易产生死锁。

　synchronized的话，锁的范围是整个方法或synchronized块部分；而Lock因为是方法调用，可以跨方法，灵活性更大

　一般情况下都是用synchronized原语实现同步，除非下列情况使用ReentrantLock：

 　①某个线程在等待一个锁的控制权的这段时间需要中断 　　　

​     ②需要分开处理一些wait-notify，ReentrantLock里面的Condition应用，能够控制notify哪个线程 　　　 

​     ③具有公平锁功能，每个到来的线程都将排队等候

### 方法锁（synchronized修饰方法时）

每个类对应的对象对应一把锁，每个 synchronized 方法都必须获得调用该方法的类实例的锁方能执行，否则所属线程阻塞，**方法一旦执行，就独占该锁**，直到从该方法返回时才将锁释放，此后被阻塞的线程方能获得该锁，重新进入可执行状态。这种机制确保了同一时刻对于每一个对象，其所有声明为 synchronized 的成员函数中**至多只有一个**处于可执行状态，从而有效避免了类成员变量的访问冲突。

（方法锁也是对象锁）

### 对象锁（synchronized修饰方法或代码块）

java的所有对象都含有1个互斥锁，这个锁由JVM自动获取和释放。线程进入synchronized方法的时候获取该对象的锁，当然如果已经有线程获取了这个对象的锁，那么当前线程会等待；synchronized方法正常返回或者抛异常而终止，JVM会自动释放对象锁。这里也体现了用synchronized来加锁的1个好处，**方法抛异常的时候，锁仍然可以由JVM来自动释放。**　

### 类锁(synchronized 修饰静态的方法或代码块)

由于一个class不论被实例化多少次，其中的静态方法和静态变量在内存中都**只有一份**。所以，一旦一个静态的方法被申明为synchronized。此类所有的实例化对象在调用此方法，共用同一把锁，我们称之为类锁。 　 　　 　　**对象锁是用来控制实例方法之间的同步，类锁是用来控制静态方法（或静态变量互斥体）之间的同步。**　 　　 　　类锁只是一个概念上的东西，并不是真实存在的，它只是用来帮助我们理解锁定实例方法和静态方法的区别的。java类可能会有很多个对象，但是只有1个Class对象，也就是说类的不同实例之间共享该类的Class对象。Class对象其实也仅仅是1个java对象，只不过有点特殊而已。由于每个java对象都有1个互斥锁，而类的静态方法是需要Class对象。所以所谓的类锁，不过是Class对象的锁而已。获取类的Class对象有好几种，最简单的就是［类名.class］的方式。

```java
public static synchronized void Method1()
synchronized (Test.class){}
```

## HashMap&HashTable

### HashMap原理

#### HashMap特性？

HashMap的特性：HashMap存储键值对，实现快速存取数据；允许null键/值；**非同步**；不保证有序(比如插入的顺序)。实现map接口。

#### HashMap的原理，内部数据结构？

HashMap 是一个散列表，它存储的内容是键值对(key-value)映射。 HashMap 继承于AbstractMap，实现了Map、Cloneable、java.io.Serializable接口。 HashMap 的实现不是同步的，这意味着它不是线程安全的,但可以用 Collections的synchronizedMap方法使HashMap具有线程安全的能力。**它的key、value都可以为null**。此外，HashMap中的映射不是有序的。 HashMap 的实例有两个参数影响其性能：“初始容量” 和 “加载因子”。**初始容量默认是16。默认加载因子是 0.75,** 这是在时间和空间成本上寻求一种折衷。加载因子过高虽然减少了空间开销，但同时也增加了查询成本. HashMap是数组+链表+红黑树（JDK1.8增加了红黑树部分）实现的,当链表长度太长（默认超过8）时，链表就转换为红黑树.

　　HashMap是基于hashing的原理，底层使用哈希表（数组 + 链表）实现。里边最重要的两个方法put、get，使用put(key, value)存储对象到HashMap中，使用get(key)从HashMap中获取对象。 
　　存储对象时，我们将K/V传给put方法时，它调用hashCode计算hash，然后根据hash调用indexfor（hash，length）方法从而得到bucket位置，进一步存储，HashMap会根据当前bucket的占用情况自动调整容量(超过Load Facotr则resize为原来的2倍)。获取对象时，我们将K传给get，它调用hashCode计算hash从而得到bucket位置，并进一步调用equals()方法确定键值对。如果发生碰撞的时候，Hashmap通过链表将产生碰撞冲突的元素组织起来，在Java 8中，如果一个bucket中碰撞冲突的元素超过某个限制(默认是8)，则使用**红黑树**来替换链表，从而提高速度。

#### 1.3 HashMap 中 put 方法过程？

如果key不为null，则先求出key的hash值，根据hash值得出在table中的索引，而后遍历对应的单链表，如果单链表中存在与目标key相等的键值对，则**将新的value覆盖旧的value**，并**将旧的value返回**，如果找不到与目标key相等的键值对，或者该单链表为空，则将该键值对**插入到改单链表的头结点位置**（每次新插入的节点都是放在头结点的位置），该操作是有addEntry方法实现的。

#### get()方法的工作原理

　　如果key不为null，则先求的key的hash值，根据hash值找到在table中的索引，在该索引对应的单链表中查找是否有键值对的key与目标key相等，有就返回对应的value，没有则返回null。 　　如果key为null，则直接从哈希表的第一个位置table[0]对应的链表上查找。记住，key为null的键值对永远都放在以table[0]为头结点的链表中，当然不一定是存放在头结点table[0]中。 

#### resize的过程

如果bucket的数量超过了阈值（阈值=loadfactor*current capacity，load factor默认0.75），就需要resize。

新建了一个HashMap的底层数组（Entry[]），而后调用transfer方法，将就HashMap的全部元素添加到新的HashMap中（要**重新计算元素在新的数组中的索引位置**）。 扩容是需要进行数组复制的，非常消耗性能的操作，所以如果我们已经预知HashMap中元素的个数，那么预设元素的个数能够有效的提高HashMap的性能。

#### HashMap中hash函数怎么是是实现的？还有哪些 hash 的实现方式？

1. 对key的hashCode做hash操作（高16bit不变，低16bit和高16bit做了一个异或）； 

2. h & (length-1); //通过位操作得到下标index。

　　还有数字分析法、平方取中法、分段叠加法、 除留余数法、 伪随机数法。

####  HashMap 怎样解决冲突？

　　HashMap中处理冲突的方法实际就是链地址法，内部数据结构是数组+单链表。

 扩展问题1：当两个对象的hashcode相同会发生什么？
　　因为两个对象的Hashcode相同，所以它们的bucket位置相同，会发生“碰撞”。HashMap使用链表存储对象，这个Entry(包含有键值对的Map.Entry对象)会存储在链表中。

扩展问题2：抛开 HashMap，hash 冲突有那些解决办法？
　　开放定址法、链地址法、再哈希法。

#### 如果两个键的hashcode相同，你如何获取值对象？

　　重点在于理解hashCode()与equals()。 
　　通过对key的hashCode()进行hashing，并计算下标( n-1 & hash)，从而获得buckets的位置。两个键的hashcode相同会产生碰撞，则利用key.equals()方法去链表或树（java1.8）中去查找对应的节点。

#### 针对 HashMap 中某个 Entry 链太长，查找的时间复杂度可能达到 O(n)，怎么优化？

　　将链表转为**红黑树**，实现 O(logn) 时间复杂度内查找。JDK1.8 已经实现了。

#### 如果HashMap的大小超过了负载因子(load factor)定义的容量，怎么办？

扩容。这个过程也叫作rehashing，因为它重建内部数据结构，并调用hash方法找到新的bucket位置。 

　　大致分两步： 
　　1.扩容：容量扩充为原来的两倍（2 * table.length）； 
　　2.移动：对每个节点重新计算哈希值，重新计算每个元素在数组中的位置，将原来的元素移动到新的哈希表中。 　 
补充： 
loadFactor：加载因子。默认值DEFAULT_LOAD_FACTOR = 0.75f； 
capacity：容量； 
threshold：阈值=capacity*loadFactor。当HashMap中存储数据的数量达到threshold时，就需要将HashMap的容量加倍（capacity*2）； 
size：HashMap的大小，它是HashMap保存的键值对的数量。

#### 为什么String, Interger这样的类适合作为键？

　　String, Interger这样的类作为HashMap的键是再适合不过了，而且String最为常用。 
　　因为String对象是不可变的，而且已经重写了equals()和hashCode()方法了。 
　　1.不可变性是必要的，因为为了要计算hashCode()，就要防止键值改变，如果键值在放入时和获取时返回不同的hashcode的话，那么就不能从HashMap中找到你想要的对象。不可变性还有其他的优点如线程安全。 
　　注：String的不可变性可以看这篇文章《【java基础】浅析String》。 
　　2.因为获取对象的时候要用到equals()和hashCode()方法，那么键对象正确的重写这两个方法是非常重要的。如果两个不相等的对象返回不同的hashcode的话，那么碰撞的几率就会小些，这样就能提高HashMap的性能。

### HashMap与HashTable区别

　　Hashtable可以看做是线程安全版的HashMap，两者几乎“等价”（当然还是有很多不同）。Hashtable几乎在每个方法上都加上synchronized（同步锁），实现线程安全。

#### 2.1 区别

　　1.HashMap继承于AbstractMap，而Hashtable继承于Dictionary； 
　　2.线程安全不同。Hashtable的几乎所有函方法都通过（synchronized）进行了同步的，即它是线程安全的，支持多线程。而HashMap的函数则是非同步的，它不是线程安全的。若要在多线程中使用HashMap，需要我们额外的进行同步处理； 
　　3.null值。HashMap的key、value都可以为null。**Hashtable的key、value都不可以为null**； 
　　4.迭代器(Iterator)。**HashMap的迭代器(Iterator)是fail-fast迭代器，而Hashtable的enumerator迭代器不是fail-fast的。**所以当有其它线程改变了HashMap的结构（增加或者移除元素），将会抛出ConcurrentModificationException。 
　　5.容量的初始值和增加方式都不一样：**HashMap默认的容量大小是16；增加容量时，每次将容量变为“原始容量x2”。Hashtable默认的容量大小是11；增加容量时，每次将容量变为“原始容量x2 + 1”；** 
　　6.添加key-value时的hash值算法不同：HashMap添加元素时，是使用自定义的哈希算法。Hashtable没有自定义哈希算法，而直接采用的key的hashCode()。，所以在检测是否含有key时，HashMap内部需要将key的hash码重新计算一边再检测，而hashtable直接用key内部的hashCode（）值即可，不用重复计算。
　　7.速度。由于Hashtable是线程安全的也是synchronized，所以在单线程环境下它比HashMap要慢。如果你不需要同步，只需要单一线程，那么使用HashMap性能要好过Hashtable。

####  能否让HashMap同步？

HashMap可以通过下面的语句进行同步：Map m = Collections.synchronizeMap(hashMap);

HashMap和ConcurrentHashMap的区别

　　ConcurrentHashMap是在hashMap的基础上，将数据分为多个segment(类似hashtable)，默认16个（concurrency level），然后在每一个分段上都用锁进行保护，从而让锁的粒度更精细一些，并发性能更好。？？

## ArrayList、LinkedList、Vector的区别？各自的使用场景？

![1](https://ws3.sinaimg.cn/large/006tKfTcgy1g15mq3j98bj30h2067q31.jpg)

首先看三者的类声明：

```java
//ArrayList
public class ArrayList<E> extends AbstractList<E>
        implements List<E>, RandomAccess, Cloneable, java.io.Serializable
//Vector
public class Vector<E> extends AbstractList<E> implements List<E>, RandomAccess, Cloneable, java.io.Serializable
//LinkedList
public class LinkedList<E> extends AbstractSequentialList<E> implements List<E>, Deque<E>, Cloneable, java.io.Serializable
```

可见，ArrayList和Vector的父类以及实现的接口都是一模一样的，但是对于他们各自实现的方法，Vector对主要的方法加了Synchronized锁来保证其是线程安全的，而ArrayList没有做任何线程安全的处理，这也就决定了Vector开销比ArrayList要大。如果我们的程序本身是线程安全的，那么使用ArrayList是更好的选择。 Vector和ArrayList在更多元素添加进来时会请求更大的空间。Vector每次请求其大小的双倍空间，而ArrayList每次对size增长50%.

ArrayList适用于无频繁增删的情况 ,比数组效率低，如果不是需要可变数组，可考虑使用数组 ,**非线程安全**.

对于LinkedList，其可视为一个双向链表，在LinkedList的内部实现中，并不是用普通的数组来存放数据的，而是使用结点\<Node\>来存放数据的，有一个指向链表头的结点first和一个指向链表尾的结点last。LinkedList的**插入**方法的效率要高于ArrayList，但是**查询**的效率要低一点，而且没做任何线程安全的处理，所以适用于 ：没有大规模的随机读取，大量的增加/删除操作.**随机访问很慢，增删操作很快**，不耗费多余资源 ,允许null元素,**非线程安全.**。

## String、StringBuilder、StringBuffer的异同点

**1.基本区别**

String的对象不可变，StringBuffer和StringBuilder的对象是可变的，三者底层都是用char[]实现了字符串功能，但是String中的char[]用final修饰，故不可变。

**2.性能区别**

三者中StringBuilder执行速度最佳，StringBuffer次之，String的执行速度最慢（String为字符串常量，而StringBuilder和StringBuffer均为字符串变量，String对象一旦创建后该对象是不可更改的，如果需要append则需要重新copy一份新的再将原来的值拷贝过去，后两者的对象是变量是可以更改的）

**3.安全区别**

String、StringBuffer是线程安全的，StringBuilder是线程不安全的（所以如果程序是单线程的使用StringBuilder效率高，如果是多线程使用StringBuffer或者String）

***其次总结下这三者的相同：***

1.三者在java中都是用来处理字符串的

2.三个类都被final修饰，因此都是不可继承的

3.StringBuilder与StringBuffer有公共父类AbstractStringBuilder(抽象类)



  Integer A=1 

​       Integer B=1 

​       Integer C=new Integer(1); 

​       Integer D=129 

​       Integer E=129 

D==E的返回结果