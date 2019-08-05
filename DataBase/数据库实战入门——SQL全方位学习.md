# 数据库实战入门——SQL全方位学习

## 说明

本文档会在介绍知识点的同时进行举例，例子中主要涉及三个表：

- 学生表(Student)，代表学生，主要属性有Sname（姓名）、Sage（年龄）、Ssex（性别）、Sdept(所在系)
- 课程表(Course)，代表课程，主要属性有Cno(课程编号)、Cname(课程名)、Cpno(本课程的先修课程)、Ccredit(学分)
- 学生选课表(SC)，代表选课表，主要属性有Sno(学生学号)、Cno(课程编号)、Grade(该门课程的成绩)

## 基本表的操作

### 建表

建表语句的格式：

```mysql
create table 表名(
								列名1 数据类型 列级完整性约束条件，
								列名2 数据类型 列级完整性约束条件，
								...											 ，
								表级完整性约束条件
								
);
```

数据类型：

| 数据类型                                  | 含义                                                         |
| ----------------------------------------- | ------------------------------------------------------------ |
| `char(n)` ，`character(n)`                | 长度为n的字符串                                              |
| `varchar(n)`，`charactervarying(n)`       | 最大长度为n的字符串                                          |
| `clob`                                    | 字符串大对象                                                 |
| `blob`                                    | 二进制大对象                                                 |
| `int`，`integer`                          | 长整数(4字节)                                                |
| `smallint`                                | 短整数(2字节)                                                |
| `bigint`                                  | 大整数(8字节)                                                |
| `numeric(p,d)`,`decimal(p,d)`，`dec(p,d)` | 定点数，由p位数字(不包括符号、小数点)组成，小数点后有d位数字 |
| `real`                                    | 同上                                                         |
| `double precision`                        | 取决于机器精度的双精度浮点数                                 |
| `float(n)`                                | 可选精度的浮点数，精度至少为n位数字                          |
| `booean`                                  | 逻辑布尔值                                                   |
| `date`                                    | 日期，包含年、月、日，格式为`YYYY-MM-DD`                     |
| `time`                                    | 时间，包含一日的时、分、秒，格式为`HH:MM:SS`                 |
| `timestamp`                               | 时间戳类型                                                   |
| `interval`                                | 时间间隔类型                                                 |



### 修改表

```mysql
alter table 表名
add [column] 新列名 数据类型 [完整性约束]
drop [column] 列名 [cascade|restrict]//如果指定了cascade，则同时删除引用了该列的其他对象，比如视图，如果指定了restrict，则当该列被其他对象引用时会拒绝删除该列

add [表级完整性约束]
drop constraint 完整性约束名 [cascade|restrict]//删除指定的完整性约束条件
alter column 列名 数据类型//修改原有的列定义，包括修改列名和数据类型
```

### 删除表

```mysql
drop table 表名 [cascade|restrict];
```

`restrict`表示该表的删除是有约束条件的，欲删除的表不能被其他约束所引用，比如`check`、`foreign key`等约束，不能有视图、不能有触发器(`trigger`)、不能有存储过程或函数等，如果存在这些引用，则删除表会失败。

`cascade`表示删除该表没有限制条件，删除后相关的依赖对象(比如视图)也会被删除。

默认是`restrict`。

### 索引的建立与删除

#### 建立索引

```mysql
create [unique] [cluster] index 索引名 on 表名 (列名 [次序] [,列名 [次序]]...);
```

索引可以建立在表的一列或者多列上，各列之间用逗号分隔，每个**列名**后面还可以用**次序**指定索引值的排序次序，可选**asc(升序)**或者**desc(降序)**，默认是**asc**。

`unique`表明此索引的每一个索引值只对应唯一的数据记录。

`cluster`表示要建立的是**聚簇索引**。

#### 修改索引

可以对索引进行重命名：

```mysql
alter index 旧索引名 rename to 新索引名;
```

#### 删除索引

```mysql
drop index 索引名;
```

## 数据查询

```mysql
select [all|distinct] 目标列表达式 [,目标列表达式]...
from 表名或视图名 [,表名或视图名...]|（select语句） as 别名
where 条件表达式
group by 列名1 having 表达式
order by 列名2 asc|desc;
```

根据`where`子句的表达式从`from`子句指定的基本表、视图或派生表中找出满足条件的元组，再按`select`语句中的目标列表达式选出元组中的属性值形成结果表。

如果有`group by`子句，则将结果按**列名1**的值进行分组，该属性值相等的元组为一组，如果`group by`子句中带`having`短语，则只有满足条件的组才予以输出。

如果有`order  by`子句，则结果还要按**列名2**的值升序或降序排序。

### 单表查询

#### 查询表中若干列

##### 查询指定列

```mysql
select 列名1，列名2，... from 表名;
```

##### 查询所有列

```mysql
select * from Student;
```

或者：

```mysql
select 列名1，列名2，...，列名n from Student;
```

##### 查询经过计算的值

```mysql
select 含有列名的表达式 from 表名；
```

比如对如下`Sc`表：

![image-20190602141510868](https://imgconvert.csdnimg.cn/aHR0cDovL3BpY3R1cmUtcG9vbC5vc3MtY24tYmVpamluZy5hbGl5dW5jcy5jb20vMjAxOS0wNi0wMi0wNjE1MTEucG5n)

```mysql
select Sno-161600000 from Sc;
```

执行结果为：

![image-20190602141546313](https://imgconvert.csdnimg.cn/aHR0cDovL3BpY3R1cmUtcG9vbC5vc3MtY24tYmVpamluZy5hbGl5dW5jcy5jb20vMjAxOS0wNi0wMi0wNjE1NDYucG5n)



#### 选择表中的若干元组

##### 消除重复的行

两个本来并不完全相同的元组在投影到相同的某些列上后，可能变成相同的行，可以用`distinct`消除他们。

如果不指定`distinct`，则默认为`all`，即：

```mysql
select all 列名 from 表名;
```

比如上面的sc表执行以下选择语句：

```mysql
select grade from sc;
```

执行结果如下：

![image-20190602141801166](https://imgconvert.csdnimg.cn/aHR0cDovL3BpY3R1cmUtcG9vbC5vc3MtY24tYmVpamluZy5hbGl5dW5jcy5jb20vMjAxOS0wNi0wMi0wNjE4MDEucG5n)

发现有重复值，我们可以用`distinct`来消除重复：

```mysql
select distinct grade from sc;
```

执行结果：

![image-20190602141859998](https://imgconvert.csdnimg.cn/aHR0cDovL3BpY3R1cmUtcG9vbC5vc3MtY24tYmVpamluZy5hbGl5dW5jcy5jb20vMjAxOS0wNi0wMi0wNjE5MDAucG5n)

##### 查询满足条件的元组

查询满足指定条件的元组可以通过where子句实现，where子句常用的查询条件如下表所示：

| 查询条件           | 谓词                                                         |
| ------------------ | ------------------------------------------------------------ |
| 比较               | `=`,`>`,`<`,`>=`,`<=`,`!=`,`<>`,`!>`,`!<`,`not +上述比较运算符` |
| 确定范围           | `between and`,`not between and`                              |
| 确定集合           | `in`,`not in`                                                |
| 字符匹配           | `like` ,`not like`                                           |
| 空值               | `is null`,`is not null`                                      |
| 多重条件(逻辑运算) | `and`,`or`,`not`                                             |

**确定范围**

```mysql
between...and...
```

其中`between`后面是**下限**，`and`后面是**上限**，区间是闭区间。

**确定集合**

`in`谓词用于查询属性值属于指定集合的元组。

比如查询年龄为12、13、19这三个数字的学生姓名：

```mysql
select Sname from Student where Sage in(12,13,190);
```

**字符匹配**

谓词like用来进行字符串的匹配，其一般语法如下：

```mysql
[not] like '匹配串' [escape '换码字符'];
```

其含义是查找属性值列与**匹配串**相匹配的字符串，**匹配串**可以是一个**完整的字符串**，也可以含有**通配符**`%`和`_`：

- `%`：代表任意长度(长度可为0)字符串，比如`'a%b'`代表所有以`a`开头以`b`结尾的字符串；
- `_`：代表任意单个字符；

如果用户要查询的字符串本身就含有`%`或`_`，就需要使用`escape`换码字符对通配符进行转义，转义字符为`\`.

#### `order by`子句

用户可以用order by子句对查询结果按照一个或多个属性列的**升序(asc)**或**降序(desc)**排序，默认为升序。

对于空值的排序标准各个系统不一样。

比如查询全体学生，查询结果按照缩在系的系号升序排列，同一个系中的学生按照年龄降序排列：

```mysql
select * from student order by Sdept ,Sage desc;
```

#### 聚集函数

为了增强检索功能，`SQL`提供了很多聚集函数：

| 聚集函数                     | 解释                                 |
| ---------------------------- | ------------------------------------ |
| `count(*)`                   | 统计元组个数                         |
| `count([distinct|all] 列名)` | 统计一列个数                         |
| `sum([distinct|all] 列名)`   | 统计一列值的总和(此列必须是数值型)   |
| `avg([distinct|all] 列名)`   | 统计一列值的平均值(此列必须是数值型) |
| `max([distinct|all] 列名)`   | 求一列值中的最大值                   |
| `min([distinct|all] 列名)`   | 求一列值中的最小值                   |

`distinct`短语表示在计算时要取消指定列中的重复值，如果不指定或使用`all`(默认为`all`)，则表示不取消重复值。

比如查询学生'1616303000'选修课程的总学分数：

```mysql
select sum(Ccredit) from sc,course where Sno='1616303000' and sc.Cno=Course.Cno
```

当聚集函数遇到空值时迈出了count(*)外，都跳过空值只处理非空值，而由于count(*)计算的是元组的数量，元组中的一个或部分列取空值并不影响count的计算。

`where`子句中是不能使用聚集函数作为条件表达式的，**聚集函数只能用在`select`子句和`group by`中的`having`子句。**

#### `group by`子句

`group by`子句将查询结果按某一列或多列的值分组，值相等的为一组。

对查询结果分组的目的是为了**细化聚集函数的作用对象**，如果未对查询结果分组，聚集函数将应用于整个查询结果，分组后聚集函数将作用于每一个分组，即每一个分组都有一个函数值。

求各个课程号级相应的选课人数：

```mysql
select Cno,count(Sno) from sc group by Cno;
```

该语句对查询结果按`Cno`的值分组，所有具有相应`Cno`值的元组为一组，然后使用聚集函数`count`进行计算，以求得该组的学生人数。

如果分组之后还要求按照一定的条件对这些组进行筛选，则可以使用`having`短语指定筛选条件：

查询平均成绩大于等于90的学生学号和平均成绩：

```mysql
select Sno,avg(grade) from sc group by Sno having avg(grade)>=90;
```

注意这里用的是`having`而不是`where`，这也是二者的区别，`where`子句中**不能使用聚集函数作为条件表达式**。

### 连接查询

若一个查询涉及两个及以上的表，称之为连接查询，连接查询分为**等值连接查询**、**自然连接查询**、**非等值连接查询**、**自身连接查询**、**外连接查询**、**符合条件连接查询**等。

#### 等值与非等值连接查询

连接查询的`where`子句中用来连接两个表的条件称为**连接条件**或者**连接谓词**，其一般格式为：

```mysql
表名1.列名1 比较运算符 表名2.列名2
```

其中比较运算符主要有：

```
=,>,<,>=,<=,!=,<>等
```

此外连接谓词还可以使用下面的形式：

```mysql
表名1.列名1 between 表名2.列名2 and 表名2.列名3
```

当连接运算符为`=`时，称为**等值连接**，否则称为**非等值连接**。

**连接谓词**中的**列名称**称为**连接字段**，连接条件中的各连接字段类型必须是**可比的**，但名字不必相同。

比如：

```mysql
select Student.*,Sc.* from Student,Sc where Student.Sno=Sc.Sno;
```

若在等值连接中把目标列中重复的属性列去掉则为**自然连接**。

#### 自身连接

连接操作不仅可以在两个表之间进行，也可以是一个表与其自己进行连接，称为表的**自身连接**。

```mysql
select first.Cno,second.Cpno from Course first,Course second where first.Cpno=second.Cno;
```

这里`Course`代表课程表，`Cpno`列表示该门课程的先修课程，`Cno`代表课程号，这里涉及到的一个知识点是数据库中表的别名，比如这里`first`、`second`都是`Course`的别名，`first`表中的先修课程是`second`表中的课程，然后查询的是`second`表的先修课程，那么这句的意思就是查询`course`表中所有课程的先修课程的先修课程。

#### 外连接

比如两个表：学生表Student、学生选课表SC，现在想了解每一个学生选课的情况，如果直接用链接查询，比如：

```mysql
select Student.Sno,Sname,Ssex,Sage,Sdpet,Cno,Grade from Student,Course where Course.Sno=Student.Sno;
```

这样查询的结果是将所有选了课的(即Course表中有记录)学生的选课情况，并没有那些没有选课的学生的信息，如果我们想同时将没有选课的学生的选课情况也列出来(查询结果中没有选课的同学对应课程信息的列为NULL)，则应该使用外连接：

```mysql
select Student.Sno,Sname,Ssex,Sage,Sdpet,Cno,Grade from Student,Course from Student left outer join sc on (Student.Sno=Sc.Sno); 
```

左外连接列出左边关系(`Student`)中所有的元组，右外连接列出右边关系中的所有元组。

#### 多表连接

连接操作除了可以是两个表连接、一个表与自身连接之外，还可以是两个以上的表进行连接，称之为多表连接。

```mysql
select Student.Sno,Sname,Cname,Grade from Student,Sc,Course where Student.Sno=Sc.Sno and Sc.Cno=Course.Cno;
```

### 嵌套查询

`SQL`语言中，一个`select…from…where`语句称为一个**查询块**，将一个查询块嵌套在另一个查询块的`where`子句或者`having`短语的条件中的查询称为**嵌套查询**。

比如：

```mysql
select Sname from Student where Sno in (select Sno from sc where Cno='2')
```

可以看到，嵌套查询可以让我们**通过多个简单的查询组合成复杂的查询**，从而增强`SQL`的查询能力。

我们来具体学习一下**嵌套查询**的用法：

#### 带有`in`谓词的子查询

比如，查询与"小明"在同一个系学习的学生：

```mysql
select Sno,Sname,Sdept from student where Sdept in (select Sdept from Student where Sname='小明');
```

像这样子查询的查询条件不依赖于父查询的查询称为**不相关子查询**，如果子查询的查询条件依赖于父查询，则这类查询称为**相关子查询**。

#### 带有比较运算符的子查询

带有比较运算符的子查询是指父查询与子查询之间用比较运算符进行连接。当用户能**确切知道内层查询返回的是单个值**时，可以用`>`,`<`,`=`,`>=`,`<=`,`!=`或`<>`等比较运算符。

比如找出每一个学生超过他自己选修课程平均成绩的课程号：

```mysql
select Sno,Cno from Sc x where Grade>=(select avg(Grade) from Sc y where y.Sno=x.Sno);
```

这里x、y都是Sc表的别名。

这个例子就是一个**相关子查询**。

#### 带有`any(some)` 或`all`谓词的子查询

子查询返回单值时可以用比较运算符，但返回多值时要用any(有的系统用some)或all谓词修饰符，而使用any或all谓词时必须同时使用比较运算符，其语义如下：

| 比较运算符 | 语义                                       |
| ---------- | ------------------------------------------ |
| `> any`    | 大于子查询结果中的某个值                   |
| `> all`    | 大于子查询结果中的所有值                   |
| `< any`    | 小于子查询结果中的某个值                   |
| `< all`    | 小于子查询结果中的所有值                   |
| `>= any`   | 大于等于子查询结果中的某个值               |
| `>= all`   | 大于等于子查询结果中的所有值               |
| `<= any`   | 小于等于子查询结果中的某个值               |
| `<=all`    | 小于等于子查询结果中的所有值               |
| `=any`     | 等于子查询结果中的某个值                   |
| `=all`     | 等于子查询结果中的所有值(通常没有实际意义) |
| `!= any`   | 不等于子查询结果中的某个值                 |
| `!=all`    | 不等于子查询结果中的所有值                 |

例如，查询非计算机系中比计算机系任意一个学生年龄小的学生姓名和年龄：

```mysql
select Sname,Sage from student where Sage<any (select Sage from Student where Sdept='CS') and Sdept<>'CS';
```



#### 带有`exists`谓词的子查询

`exists`代表存在量词$\exists$，带有`exists`谓词的子查询不返回任何数据，只产生逻辑真值`"true"`或逻辑假值`"false"`。

比如：

```mysql
select Sname from Student where exists(select * from sc where Sno=Student.Sno and Cno='1');
```

这个语句的执行过程是，首先取外层查询中`Student`表中的第一个元组，根据它与内层查询相关的属性值(`Sno`值)处理内层查询，若内层查询为真，则取外层查询中该院组的`Sname`放入结果表，然后外层取第二个元组进行相同处理，以此类推直到最后。

### 集合查询

`select`查询的结果是元组的集合，所以多个`select`语句的结果可进行集合操作，主要包括**并（union）**、**交（intersect）**、**差（except）**。

### 基于派生表的查询

子查询不仅可以出现在`where`字句中，还可以出现在`from`字句中，这时子查询生成的**临时派生表**成为主查询的查询对象。

比如：

```mysql
select Sno,Cno from Sc,(select Sno avg(grade) from sc group by Sno) as avg_sc(avg_sno,avg_grade)
```

## 数据更新

#### 插入数据

`SQL`的数据插入语句`insert`通常有两种形式，一种是插入**一个元组**，另一种是插入**子查询结果**，后者可以一次插入多个元组。

##### 插入元组

基本格式为：

```mysql
insert into 表名 [(属性列1)...(属性列n)] values (常量1，[常量2，...,常量n);
```

其功能是将新元组插入指定表中，其中新元组的`属性列i`的值为`常量i`，`into`字句中没有出现的属性列，新元组将在这些列上取`NULL`(在表定义时说明了 `not null`的属性列不能取空值，否则会报错)，如果`into`字句中没有显式指定属性列名，则新插入的元组必须在每个属性列上都有对应值。

**注意：**`values`字句中出现的值如果是字符串，则应该用**单引号**括起来。

##### 插入子查询结果

基本格式为：

```mysql
insert into 表名 [(属性列1),...,(属性列n)] 子查询;
```

比如：

```mysql
insert into TableName(attribute1,attrbute2) select a1,a2 from TableName2 ;
```

#### 修改数据

修改操作又称更新操作，其语句的一般格式为：

```mysql
update 表名 set 列名1=表达式1，[列名2=表达式2,...,列名n=表达式n] [where 条件];
```

其功能是修改指定表中满足`where`字句条件的元组，其中`set`字句中给出的`表达式i`的值用于替代`列名i`对应的属性值，如果省略`where`字句，则代表要修改表中的所有元组。

#### 删除数据

删除语句的一般格式为：

```mysql
delete from 表名 [where 条件]
```

## 空值的处理

数据库中的`空值(NULL)`是一个特殊的概念，所谓空值就是"不知道"或"不存在"或"无意义"的值。

我们可以使用`is null` 和`is not null`来判断空值。

在属性定义(或者域定义)中有`not null` 约束条件的不能取空值，加了`unique`限制的属性值不能取空值，`码属性`不能取空值。

空值与另一个值(包括另一个空值)的**算术运算**的结果为空值，空值与另一个值(包括另一个值)的**比较运算**的结果为`unknown`，有了`unknown`之后，传统的逻辑运算中`二值(true，false)逻辑`就拓展成了`三值逻辑`。

## 视图

**视图**是从一个或几个基本表(或视图)导出的表，它与基本表不同，是一个**虚表**，数据库中只存放视图的**定义**，视图对应的数据还是存放在原来的基本表中，一旦基本表的数据发生了变化，从视图中查询出来的数据也会随之发生变化。

### 定义视图

#### 建立视图

一般格式：

```mysql
create view 视图名 [列名1，列名2，...，列名n] as 子查询 [with check option]；
```

子查询可以是任意的`select`语句，是否可以含有`order by`子句和`distinct`短语取决于具体的系统实现。

`with check option`表示对视图进行`update`、`insert`、`delete`操作时要保证更新、插入或删除的行满足视图定义中的**谓词条件(即子查询中的条件表达式)**，比如：

```mysql
create view ViewName as select Sno,Sname,Sage from Student where Sno='123' with check option;
```

使用上面的语句定义了视图`ViewName`，当对视图`ViewName`进行插入、修改、删除时，关系数据库管理系统会自动加上`where`后面的条件表达式(即`Sno='123'`).

关系数据库执行`create view`语句的结果是将视图的定义存入数据字典，并不执行其中的`select`字句，在对视图进行查询时才会按视图的定义从基本表中将数据查出。

#### 删除视图

删除视图的基本语法为：

```mysql
drop view 视图名 [cascade];
```

视图删除后视图的定义将从数据字典中删除，存在其他视图是从该视图导出的，那么使用`cascade`级联删除语句会把该视图和又它导出的视图一并删除。

### 对视图内容的增删改查

建立好视图之后，所有的对视图内容的增删改查操作都和对基本表的操作一样。

#### 视图的作用

1. 视图能够简化用户操作
2. 视图使用户能以多种角度看待同一数据
3. 视图对重构数据库提供了一定程度的逻辑独立性
4. 视图能够对机密数据提供安全保护
5. 适当利用视图可以更清晰地表达查询



## 数据库的安全性

### 数据库中的授权

SQL中可以使用grant语句向用户授予对数据的操作权限，基本格式如下：

```mysql
grant 权限1，[权限2,...,权限n] on 对象类型1 对象名1 [,对象类型2 对象名2,....,对象类型n 对象名n] to 用户1 [用户2，...，用户n] [with check option];
```

其语义为：将对指定操作对象的指定操作权限授予指定的用户，发出该`grant`语句的可以是**数据库管理员**、该**数据库的创建者**、**已经拥有将要授予的权限的用户**，接受权限的用户可以是一个或多个**具体的用户**，也可以是`public`，即**全体用户**。

如果指定了`with grant option` 字句，则获得该权限的用户还可以把这种权限再授予其他用户，如果没有指定`with grant option`字句，则获得该权利的用户只能使用该权限，不能传播该权限。

注意，`SQL`标准不允许**循环授权**，即`A`向`B`授予了`权限1`，这时`B`是不可以再将`权限1`授权给`A`的（因为`A`已经具有这个权限了）。

### 数据库中权限的收回

权限即能授予，也能收回，收回使用的是`revoke`语句，基本格式如下：

```mysql
revoke 权限1，[权限2，...，权限n] on 对象类型1 对象名1  [,对象类型2 对象名2,....,对象类型n 对象名n] from 用户1 [用户2，...，用户n]；
```

### 创建数据库模式的权限

grant和revoke语句向用户授予或收回对数据的操作权限，对创建把数据库模式一类的数据库对象的授权则由数据库管理员在创建用户时实现，基本格式如下：

```mysql
create user username [with] [dba|resource|connect];
```

对上述的授权语句解释如下：

1. 只有系统的超级用户才有权限创建一个新的数据库用户
2. 新创建的数据库用户又三种权限：`connect`、`resource`、`dba`
3. `create user`命令中如果没有指定创建的新用户的权限，则默认该用户有`connect`权限。

对`dba`、`resource`、`connect`三种权限的说明如下：

1. `dba`：拥有该权限的是系统中的超级用户，可以创建新的用户、创建模式、创建基本表和视图等，dba拥有对所有数据库对象的存取权限，还可以把这些权限赋予一般用户。
2. `resource`：有用`resource`权限的用户能创建基本表和视图，成为所创建对象的属主，但不能创建模式，不能创建新的用户。数据库对象的属主可以使用grant语句把该对象上的存取权限授予给其他用户。
3. `connect`：拥有`connect`权限的用户不能创建新用户、不能创建模式、不能创建基本表，只能登录数据库，由数据库管理员或其他用户授予他应有的权限，根据获得的授权情况他可以对数据库对象进行权限范围内的操作。

下表对这几个权限进行了总结：

| 权限     | create user | create schema | create table | 登录数据库，执行数据查找和操纵 |
| -------- | ----------- | ------------- | ------------ | ------------------------------ |
| dba      | 可以        | 可以          | 可以         | 可以                           |
| resource | 不可以      | 不可以        | 可以         | 可以                           |
| connect  | 不可以      | 不可以        | 不可以       | 可以，但必须拥有相关权限       |

## 数据库角色

数据角色是被命名的一组与数据库操作相关的权限，角色是**权限的集合**。因此，可以为一组具有相同权限的用户创建一个角色，使用角色来管理数据库权限可以简化授权的过程。

### 角色的创建

基本格式：

```mysql
create role 角色名
```

刚刚创建的角色是空的，没有任何内容，可以用grant为角色授权。

### 给角色授权

基本格式：

```mysql
grant 权限1，[权限2，...，权限n] on 对象类型 对象名 to 角色1,[角色2,...,角色n]；
```

数据库**管理员**和**用户**可以利用`grant`语句将权限授予某一个或几个角色。

### 将一个角色授予其他的角色或用户

基本格式：

```mysql
grant 角色1，[角色2，...，角色n] to 角色a/用户1, [角色b/用户2,...,角色x/用户n] [with admin option];
```

该语句把角色授予某用户或其他的某角色，授予者是角色的创建者或者拥有在这个角色上的`admin option`。

如果指定了`with admin option`，则获得某种权限的角色或用户还可以把这一种权限再授予其他角色。

### 角色权限的收回

基本格式：

```mysql
revoke  权限1，[权限2，...，权限n] on 对象类型 对象名 from 角色1,[角色2,...,角色n]；
```

用户可以收回角色的权限，从而修改角色有用的权限。

`revoke`动作的执行者是角色的创建者或者拥有这个(些)角色上的`admin option`。