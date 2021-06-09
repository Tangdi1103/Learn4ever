### 简介：

在社区强烈反应下，java8推出了线程安全、简易、高可靠的时间包。并且数据库中也支持LocalDateTime类型，所以在数据存储时候使时间变得简单。


##### 拥有以下三个类，对应数据库类型
- LocalDateTime年月日十分秒 -> timestamp 
- LocalDate日期 -> date 
- LocalTime时间 -> time 



### 基本操作：


```
// 取当前日期：
LocalDate localDate1 = LocalDate.now();
//取当前时间：
LocalDateTime localDateTime1 = LocalDateTime.now();
// 设置日期：
LocalDate localDate2 = LocalDate.of(2019, 04, 24); // -> 2019-04-24
//设置时间
LocalDateTime localDateTime2 = LocalDateTime.of(2019,04,24,22,50) // ->2019-04-25 22:50
//获取年、月、日、时、分、秒
int year = now.getYear();
Month month = now.getMonth();
int dayOfMonth = now.getDayOfMonth();
int dayOfYear = now.getDayOfYear();


//格式化模板
DateTimeFormatter df = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss:SSS");
//LocalDateTime转String（两种方法）
String s1 = df.format(localDateTime1);
String s2 = localDateTime1.format(df);
//String转LocalDateTime：
LocalDateTime parse = LocalDateTime.parse(s1, df);


//比较时间先后
boolean after = localDateTime1.isAfter(localDateTime2);
boolean before = localDateTime1.isBefore(localDateTime2);
boolean equal = localDateTime1.isEqual(localDateTime2);

//小时间间隔
Duration duration = Duration.between(localDateTime1,localDateTime2);
duration.toDays();
duration.toHours();
duration.toMinutes();
duration.toMillis();

//大时间间隔
Period period2 = Period.between(localDateTime.toLocalDate(),localDateTime4.toLocalDate());
period2.getYears();
period2.getMonths();
period2.toTotalMonths();

//获取long型毫秒时间
Long l = localDateTime1.toInstant(ZoneOffset.of("+8")).toEpochMilli();


//判断是否闰年
boolean leapYear = localDate1.isLeapYear();

// 取本月第1天：
LocalDate firstDayOfThisMonth = localDate1.with(TemporalAdjusters.firstDayOfMonth());

// 取本月第2天：
LocalDate secondDayOfThisMonth = localDate1.withDayOfMonth(2);

// 取本月最后一天，再也不用计算是28，29，30还是31：
LocalDate lastDayOfThisMonth = localDate1.with(TemporalAdjusters.lastDayOfMonth()); // 2017-12-31

// 取下一天：
LocalDate xiayitian = lastDayOfThisMonth.plusDays(1); // 变成了2018-01-01

//取前一天：
LocalDate qianyitian = lastDayOfThisMonth.minusDays(1);

// 取2017年1月第一个周一，用Calendar要死掉很多脑细胞：
LocalDate firstMondayOf2015 = LocalDate.parse("2017-01-01").with(TemporalAdjusters.firstInMonth(DayOfWeek.MONDAY)); // 2017-01-02
```
