1、Calendar有个子类GregorianCalendar,它的功能非常强大。首先我们创建一个日历对 象。如:Calendar date = new GregorianCalendar();使用 date.getTime();方法可以获 得当前系统时间,返回表示时间值的Date。new GregorianCalendar()构造方法里面也可 以加入参数,如:new  GregorianCalendar(2000,month,day),获得给定时间的对象。

##### 2、Calendar类有些字段比较有用。
DATE 指示一个月中的某天。
DAY_OF_MONTH  指示一个月中的某天。
DAY_OF_WEEK 指示一个星期中的某天。
DAY_OF_WEEK_IN_MONTH 指示当前月中的第几个星期。
DAY_OF_YEAR 指示当前年中的天数。

3、getActualMaximum();setActualMinimum();getMaximum();setMinimum();
getActualMaximum()表示取得指定实际的日历字段的最大值,而getMaximum()表示取得指 定日历字段的最大值,如:日历字段是4月,那前者返回30,后者则返回31

##### 4、日期比较
如:Calendar xmas = new GregorianCalendar(1998, Calendar.DECEMBER, 25);
Calendar newyears = new GregorianCalendar(1999, Calendar.JANUARY, 1);
如果xmas表示的日期在newyears之后,则b为true,反之false
boolean b = xmas.after(newyears);
如果xmas表示的日期在newyears之前,则b为true,反之false
b = xmas.before(newyears);

##### 5、年龄判断
Calendar dateOfBirth = new GregorianCalendar(1972, Calendar.JANUARY, 27);
建立当前日期的日历对象
Calendar today = Calendar.getInstance();
当前日期年份减去出生日期的年份
int age = today.get(Calendar.YEAR) – dateOfBirth.get(Calendar.YEAR);
出生日期的年份加上与当前日期年份的差数
dateOfBirth.add(Calendar.YEAR, age);
判断上面得出结果如果在当前日期之前,则age减1得到实际年龄,否则age就为实际年龄
if (today.before(dateOfBirth))
age–;

##### 6、判断是否为闰年
因为isleapYear()方法并不是继承Calendar类的方法,所以不能使用Calendar类作为声明
GregorianCalendar cal = new GregorianCalendar();
boolean b = cal.isLeapYear(1998); // false
b = cal.isLeapYear(2000);         // true

##### 7、Calendar类里月份是从0开始的,即0表示1月,1表示2月,以次类推。一周中第一天是 星期天,即1表示星期天,2表示星期一,以次类推。

##### 8、add()方法
add(int field,int amount);在指定的日历字段的基础上加上amount;如果现在是1月31 号,在month字段上+1,将得到2月28号,如果是闰年则为