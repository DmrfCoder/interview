# 关系操作及alpha语言学习
本文将介绍关系数据库的相关理论。

[TOC]

### 前备知识

**关系：**在关系模型中，实体及实体间的各种联系称为关系

**域：**具有相同数据类型的值的集合

关系有**三种类型**：基本关系(**基本表**、基表)、**查询表**、**视图表**

### 关系代数

下文将会以如下两个关系R和S具为例进行说明，R和S有相同的目即二者具有相同的属性，且相应属性取自同一个域：

R：

![image-20190627133518245](https://imgconvert.csdnimg.cn/aHR0cDovL3BpY3R1cmUtcG9vbC5vc3MtY24tYmVpamluZy5hbGl5dW5jcy5jb20vMjAxOS0wNi0yNy0wNTM1MTgucG5n)

S:

![image-20190627133704970](https://imgconvert.csdnimg.cn/aHR0cDovL3BpY3R1cmUtcG9vbC5vc3MtY24tYmVpamluZy5hbGl5dW5jcy5jb20vMjAxOS0wNi0yNy0wNTM3MDUucG5n)



#### 传统的集合运算

##### 并

$R \cup S$：由属于R**或**属于S的元组组成。

![image-20190627133724793](https://imgconvert.csdnimg.cn/aHR0cDovL3BpY3R1cmUtcG9vbC5vc3MtY24tYmVpamluZy5hbGl5dW5jcy5jb20vMjAxOS0wNi0yNy0wNTM3MjUucG5n)

##### 交

$R \cap S$：由属于R且属于S的元组组成。

![image-20190627133818849](https://imgconvert.csdnimg.cn/aHR0cDovL3BpY3R1cmUtcG9vbC5vc3MtY24tYmVpamluZy5hbGl5dW5jcy5jb20vMjAxOS0wNi0yNy0wNTM4MTkucG5n)

##### 差

$R-S$：由属于R但不属于S的元组组成。

![image-20190627133858613](https://imgconvert.csdnimg.cn/aHR0cDovL3BpY3R1cmUtcG9vbC5vc3MtY24tYmVpamluZy5hbGl5dW5jcy5jb20vMjAxOS0wNi0yNy0wNTM4NTkucG5n)

##### 笛卡尔积

$R\times S$：

1. R中的每一行和S中的每一行进行组合，组成新的行；
2. 假设R有n个属性，S有m个属性，则$R\times S$的结果应该有m+n个属性，即m+n列；
3. 假设R有x行，S有y行，则$R\times S$由xy行；

![image-20190627143949731](https://imgconvert.csdnimg.cn/aHR0cDovL3BpY3R1cmUtcG9vbC5vc3MtY24tYmVpamluZy5hbGl5dW5jcy5jb20vMjAxOS0wNi0yNy0wNjM5NTAucG5n)

#### 专门的关系运算

##### 选择

$$
\sigma_F(R)={t|r\in R \and F(t)=真}
$$



F(t)表示选择条件，是一个逻辑表达式，取逻辑值"真"或"假"，逻辑表达式中可用的运算符如下表所示：

![image-20190627134903993](https://imgconvert.csdnimg.cn/aHR0cDovL3BpY3R1cmUtcG9vbC5vc3MtY24tYmVpamluZy5hbGl5dW5jcy5jb20vMjAxOS0wNi0yNy0wNTQ5MDQucG5n)

比如：

$\sigma_{Sdept='IS'}(Student)$

上式中F为$Sdept='IS'$, R=Student，表示从Student表中**选择**出满足条件$Sdept='IS'$的数据项。

##### 投影

关系R上的投影是指从R中选择若干列组成新的关系，记做：
$$
\prod\ _A(R)=\{t[A]|t \in R\}
$$


比如：

关系R中有如下列：{Sname,Sdept,Sage}，则：
$$
\prod\ _{Sname,Sdept}(R)=\{Sname,Sdept\}
$$

##### 连接

![image-20190627150152659](https://imgconvert.csdnimg.cn/aHR0cDovL3BpY3R1cmUtcG9vbC5vc3MtY24tYmVpamluZy5hbGl5dW5jcy5jb20vMjAxOS0wNi0yNy0wNzAxNTMucG5n)

其中$A \theta B$中的$\theta$表示比较运算符，连接运算的计算流程是这样的：

1. 计算R和S的笛卡尔积$U=R \times S$
2. 从U中选取R.A属性和S.B属性满足比较运算符$\theta$的元组

连接运算中有两种最常用的连接类型：

1. **等值连接（内连接）：**当$\theta$为等号即$=$的时候，对应连接为等值连接，记做$R\bowtie_{A = B}^{} S$
2. **自然连接：**在等值连接的基础上，如果R.A和S.B是**同名的属性组**，并且在结果中把**重复的属性去掉**，对应的连接就称自然连接，即自然连接表示的是两个关系R和S选取在公共属性上值相等的元组进而构成新的关系，记做$R\bowtie S$

我们以一个例子作为说明，比如有以下两个关系R和S：

R:

![image-20190627144301838](https://imgconvert.csdnimg.cn/aHR0cDovL3BpY3R1cmUtcG9vbC5vc3MtY24tYmVpamluZy5hbGl5dW5jcy5jb20vMjAxOS0wNi0yNy0wNjQzMDIucG5n)

S:

![image-20190627144319102](https://imgconvert.csdnimg.cn/aHR0cDovL3BpY3R1cmUtcG9vbC5vc3MtY24tYmVpamluZy5hbGl5dW5jcy5jb20vMjAxOS0wNi0yNy0wNjQzMTkucG5n)

其做自然连接后的结果应该为$R\bowtie S$：

![image-20190627144415074](https://imgconvert.csdnimg.cn/aHR0cDovL3BpY3R1cmUtcG9vbC5vc3MtY24tYmVpamluZy5hbGl5dW5jcy5jb20vMjAxOS0wNi0yNy0wNjQ0MTUucG5n)

我们可以发现，在R和S做了等值连接之后，R和S中都有个别行消失了，比如R中的第3行（a1,b3,8），S中的第3行(b5,2)，这是因为这两个行中不存在公共属性(B)上值相等的元组，所以被舍弃了，如果不舍弃，则应该是：

![image-20190627144820653](https://imgconvert.csdnimg.cn/aHR0cDovL3BpY3R1cmUtcG9vbC5vc3MtY24tYmVpamluZy5hbGl5dW5jcy5jb20vMjAxOS0wNi0yNy0wNjQ4MjAucG5n)

我们将像上图中最后2行的这种元组称为悬浮元组，将像上图这样将不存在值的地方填上NULL而不舍弃的连接称为**外连接**，记做![image-20190627145246287](https://imgconvert.csdnimg.cn/aHR0cDovL3BpY3R1cmUtcG9vbC5vc3MtY24tYmVpamluZy5hbGl5dW5jcy5jb20vMjAxOS0wNi0yNy0wNjUyNDcucG5n)，如果只保留左边关系R中的悬浮元组，称为**左外连接**，记作![image-20190627145612289](https://imgconvert.csdnimg.cn/aHR0cDovL3BpY3R1cmUtcG9vbC5vc3MtY24tYmVpamluZy5hbGl5dW5jcy5jb20vMjAxOS0wNi0yNy0wNjU2MTIucG5n)：

![image-20190627145946091](https://imgconvert.csdnimg.cn/aHR0cDovL3BpY3R1cmUtcG9vbC5vc3MtY24tYmVpamluZy5hbGl5dW5jcy5jb20vMjAxOS0wNi0yNy0wNjU5NDYucG5n)

如果只保留右边关系S中的悬浮元组，称为**右外连接**，记做![image-20190627150041516](https://imgconvert.csdnimg.cn/aHR0cDovL3BpY3R1cmUtcG9vbC5vc3MtY24tYmVpamluZy5hbGl5dW5jcy5jb20vMjAxOS0wNi0yNy0wNzAwNDEucG5n)：

![image-20190627150118486](https://imgconvert.csdnimg.cn/aHR0cDovL3BpY3R1cmUtcG9vbC5vc3MtY24tYmVpamluZy5hbGl5dW5jcy5jb20vMjAxOS0wNi0yNy0wNzAxMTgucG5n)

在实际的生产中我们一般是使用join关键字进行连接查询，举几个例子：

内连接(等值连接)：

```mysql
select * from A inner join B on A.name = B.name;
```

左外连接：

```mysql
select * from A left join B on A.name = B.name;
```

或：

```mysql
select * from A left outer join B on A.name = B.name;
```

我们之前还提到了笛卡尔积，其实，在数据库的实际编程中，笛卡尔积又叫交叉连接，关键字为cross join，在 MySQL（**仅限于 MySQL**） 中 `CROSS JOIN` 与 `INNER JOIN` 的表现是一样的，在不指定 ON 条件得到的结果都是笛卡尔积。

`INNER JOIN` 与 `CROSS JOIN` 可以省略 `INNER` 或 `CROSS` 关键字，因此下面的 SQL 效果是一样的：

```mysql
... FROM table1 INNER JOIN table2
... FROM table1 CROSS JOIN table2
... FROM table1 JOIN table2
```

##### 除运算

$$
R \div S
$$

表示所有包含在R但不包含在S中的**属性**及其**值**，也就是说，除运算是在行和列两个维度都有要求，具体地，计算$T=R \div S$运算结果的步骤为：

1. **列级别**：使用R中的属性减去S中的属性，即使用R原有的属性集减去与S中相同的属性集，比如R中的属性集为{A,B,C}，S中的属性集为{B,C,D}，那么结果T的属性集为${A,B,C}-{B,C,D}={A}$
2. **行级别**：假设R的属性集为{A,B,C}，R和S共同的属性集为{B,C}，从1中我们知道最终T只有一列即A，T.A的值应该是$T.A=\{R.A|R.B=S.B \and R.C=S.C\}$

以一个实例进行说明，有关系R和S：

R:

![image-20190627151832764](https://imgconvert.csdnimg.cn/aHR0cDovL3BpY3R1cmUtcG9vbC5vc3MtY24tYmVpamluZy5hbGl5dW5jcy5jb20vMjAxOS0wNi0yNy0wNzE4MzMucG5n)

S:

![image-20190627151951409](https://imgconvert.csdnimg.cn/aHR0cDovL3BpY3R1cmUtcG9vbC5vc3MtY24tYmVpamluZy5hbGl5dW5jcy5jb20vMjAxOS0wNi0yNy0wNzE5NTIucG5n)

则其除运算的结果是：

![image-20190627152221204](https://imgconvert.csdnimg.cn/aHR0cDovL3BpY3R1cmUtcG9vbC5vc3MtY24tYmVpamluZy5hbGl5dW5jcy5jb20vMjAxOS0wNi0yNy0wNzIyMjEucG5n)

### alpha语言

alpha语言主要有get、put、hold、update、delete、drop六条语句，语句的基本格式为：
$$
操作语句 工作空间名(表达式):操作条件
$$

#### 检索

检索操作主要使用get语句实现。

##### 简单检索(不带条件的检索)

查询所有学生的数据：
$$
get \space W(Student)
$$


W表示工作空间名，这里的条件为空。

##### 限定的检索(带条件的检索)

查询信息系（IS）中年龄小于20岁的学生的学号和年龄：
$$
get\space W(Student.Sno,Student.Sage):Student.Sdept='IS' \and Student.Sage=20
$$


##### 带排序的查询

查询信息系（IS）中年龄小于20岁的学生的学号和年龄，结果按年龄降序排序：
$$
get\space W(Student.Sno,Student.Sage):Student.Sdept='IS' \and Student.Sage=20 \space down \space Student.age
$$


其中down表示降序排序，up表示升序排序。

##### 指定返回的结果的条数

取出一个信息系学生的学号：
$$
get \space W(1)(Student.Sno):Student.Sdept='IS'
$$

##### 用元组变量的检索

两种情况下需要使用元组变量：

1. 关系名太复杂时可用元组变量达到简化关系名的目的
2. 操作条件中使用量词时必须使用元组变量，这里的量词指的是存在量词、全称量词等。

比如：
$$
range\space  Student \space X\space  get \space W(X.Sname) :X.Sdept='IS'
$$
其中X表示Student的别名，这样可以简化变量名。

##### 用存在量词的检索

查询选修2号课程的学生名字：
$$
range\space Sc\space X\space get\space W(Student.Sname) :\exists\space X(X.Sno=Student.Sno \space\and \space X.cno='2')
$$
注意这里使用了存在量词，所以存在符号后面一定要使用元组变量即$\exists X$。

##### 带有多个关系的表达式的检索

上面的例子中表达式中即查询结果只涉及一个关系，事实上查询结果中可以有多个关系。

查询成绩为90分以上的学生名字和课程名字：
$$
range \space SC\space scX\space get\space W(Student.Sname,Course.Cname):\exists\space scX (scX.Grade>90 \space\and \\\space scX.Sno=Student.Sno \space\and\space scX.Cno=Course.Cno)
$$

##### 使用全称量词的检索

查询不选1号课程的学生姓名：
$$
range\space  Sc\space scX\space get\space W(Student.Sname) :\space\forall\space scX(scX.Sno\space \not=\space Student.Sno\space \or\space scX.Cno\not='1')
$$
本例也可以使用存在量词解决：
$$
range\space Sc\space scX\space get\space W(Student.Sname) :\neg \exists scX(scX.Sno=Student.Sno\space \and\space scX.Cno='1')
$$

##### 用两种量词的检索

查询选修了全部课程的学生姓名：
$$
range\space Course\space cX\space  SC\space scX\space get\space W(Student.Sname) :\forall cX\space\exists\space scX(scX.Sno=Student.Sno\space \\\and\space scX.Cno=cX.Cno)
$$

##### 用蕴含的检索

查询最少选修了122号学生所选课程的学生学号。
$$
range \space Course\space cX\space Sc\space scX\space SC\space scY\space get\space W(Student.Sno):\forall (\exists scX(scX.Sno='122' \\ \and scX.Cno=sX.Cno) \Rightarrow \exists scY(scY.Sno=Student.Sno \and scY.Cno=cX.Cno))
$$

##### 聚集函数

聚集函数有以下几个：

![image-20190627162209014](https://imgconvert.csdnimg.cn/aHR0cDovL3BpY3R1cmUtcG9vbC5vc3MtY24tYmVpamluZy5hbGl5dW5jcy5jb20vMjAxOS0wNi0yNy0wODIyMDkucG5n)

查询信息系学生的平均年龄：
$$
get\space W(count(Student.Sage):Student.Sdept='IS')
$$

#### 更新

##### 修改操作

修改操作用update语句实现，步骤为：

1. 用hold语句将要修改的元组从数据库中读到工作空间中
2. 用宿主语言修改工作空间中元组的属性值
3. 用update语句将修改后的元组送回数据库中

注意，单纯检索的话使用get关键字即可，但为修改而数据而读元组的话必须使用hold语句，hold语句是加上并发控制的get语句。

把127号学生的专业改为信息系：
$$
hold\space W(Student.Sno,Student.Sdept) :Student.Snp='127'(从Student中选出需要修改的内容)\\
move\space 'IS'\space to\space W.Sdept（修改元组的属性值）\\
update\space W(将修改后的元组送回数据库)
$$
注意：

1. 如果修改涉及两个关系的话，就应该执行两次hold-move-update的过程
2. alpha语言不允许修改主码，要修改主码，应该先删除原来的元组，然后增加新的元组

##### 插入操作

插入操作使用put关键字，步骤如下：

1. 用宿主语言建立新元组
2. 用put与局部将建立的元组存入指定的关系中

比如：

```
move '8' to W.Cno
move '计算机基础' to W.Cname
move '2' to W.Ccredit
put W(Course)
```

注意，put语句只能对单个关系操作

##### 删除操作

删除操作使用delete关键字，步骤如下：

1. 用hold语句将要删除的元组读到工作空间中
2. 用delete语句删除该元组

删除第230号学生：

```
hold W(Student):Student.Sno='230'
delete W
```