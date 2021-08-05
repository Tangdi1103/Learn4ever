####  求值策略
说这个问题前，首先要引用一个概念，求值策略：函数间参数传递的策略。

求值策略规定了函数调用中，传递给被调函数的实参求值的方式（何时求值，何时代入），分为严格求值和非严格求值。

目前多数高级语言采用的都是严格求值策略。

严格求值主要的策略有：
- 传值调用：调用函数时，将实参==复制==一份==传递==给被调函数形参
- 传引用调用：调用函数时，将实参的==引用==直接==传递==给被调函数的形参
- 传共享对象调用：调用函数时，将实参的地址==复制==一份==传递==给被调函数的形参

其中传值调用和传共享调用都会实际参数进行拷贝，可将传共享对象调用理解为传值调用的特例。

#### 引用
引用即是对象的别名，存放的是对象的地址

#### java中的求值策略

官方的说法：1.基本类型按值传递给方法。2.引用数据类型也按值传递给方法。

java中的求值策略就是值传递，传递对象时，是通过复制的方式把引用关系传递了

#### 实践
```
public static void main(String[] args) {
  User hollis = new User();
  hollis.setName("Hollis");
  hollis.setGender("Male");
  pt.pass(hollis);
  System.out.println("print in main , user is " + hollis);
}

public static void pass(User user) {
  user = new User();
  user.setName("hollischuang");
  System.out.println("print in pass , user is " + user);
}

// print in pass , user is User{name='hollischuang', gender='Male'}
// print in main , user is User{name='Hollis', gender='Male'}
```
==修改对象属性发生过程：==
![image](http://www.hollischuang.com/wp-content/uploads/2018/04/pass21.png)

==修改引用值发生过程：==
![image](http://www.hollischuang.com/wp-content/uploads/2018/04/pass1.png)
#### 总结
JAVA的求值策略是值传递，被调函数对副本参数的改变，并不会影响到原来的参数。例如对象传递，如果是修改引用，不会影响原来的对象，但是如果直接修改共享对象的属性的值，是会对原来的对象有影响的。