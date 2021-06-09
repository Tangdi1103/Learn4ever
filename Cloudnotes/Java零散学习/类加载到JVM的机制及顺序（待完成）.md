### 加载顺序：
分析思路(静态代码块是随着类的加载而加载,而且只执行一次,非静态
代码块优先于构造代码块,执行是随着对象的创建而执行的)

##### 案例:
```
public class Test {
    public static Test t1 = new Test();
    public  Test() {
        System.out.println("Test父类构造方法");
    }
    {
        System.out.println("Test父类非静态块");
    }
    static
    {
        System.out.println("Test父类静态块");
    }
}


public class TestSon extends Test{
    public static TestSon t2 = new TestSon();
    public TestSon() {
        System.out.println("Test子类构造方法");
    }
    {
        System.out.println("Test子类非静态块");
    }
    static
    {
        System.out.println("Test子类静态块");
    }
    
    public static void main(String[] args) {
        TestSon son=new TestSon();
    }
}

输出：
Test父类非静态块
Test父类构造方法
Test父类静态块
Test父类非静态块
Test父类构造方法
Test子类非静态块
Test子类构造方法
Test子类静态块
Test父类非静态块
Test父类构造方法
Test子类非静态块
Test子类构造方法
```
##### 解析：

    子类继承了父类,在加载子类的时候会先加载父类,执行的顺序是从上到下,先执行父类静态属性
    创建对象,创建对象会先执行父类非静态代码块,然后在执行父类构造方法,之后执行父类类静态
    代码块(随着类的加载而加载,而且只加载一次),
    然后加载子类,先执行子类静态属性创建对象，因为继承了父类，所以先执行父类非静态代码块
    ，然后执行父类构造方法，然后执行子类的非静态代码块，然后执行子类的构造方法，然后执行
    子类的静态代码,
    
    至此，所有类加载完成
    
    之后new一个子类对象,
    因为有继承关系,所以先执行父类非静态方法,在执行父类构造方法,然后执行子类非静态方法,在执行子类构造方法