
### DecimalFormat
```
//保留一位小数
DecimalFormat DF = new DecimalFormat("0.0");
Double a = 3.21;
System.out.println(DF.format(a));  //3.2
System.out.println(DF.format(9200/1830)); //5.0
```

### BigDecimal
##### BigDecimal(double) 存在精度损失风险，在精确计算或值比较的场景中可能会导致业务逻辑异常。

```
BigDecimal b1 = new BigDecimal(2.3513);
System.out.println(b1);//输出:2.3513000000000000000055511151231257827021181583404541015625



b1.setScale(1);  //2.4 保留1位小数，默认用四舍五入。
b1.setScale(1, BigDecimal.ROUND_DOWN);  //2.3 直接删除多余的小数，2.3513直接被截断位2.3
b1.setScale(1, BigDecimal.ROUND_HALF_UP);  //2.4 四舍五入，向上舍入，2.3513变成2.4   
b1.setScale(1, BigDecimal.ROUND_HALF_DOWN);  //四舍五入，向下舍入，2.3513变成2。3


1. setScale(int x);    BigDecimal值后保留x位小数

2. setScale(x, BigDecimal.ROUND_DOWN);    保留1位小数，默认用四舍五入

3. setScale(x, BigDecimal.ROUND_HALF_UP);    保留一位小数，向上舍入

4. setScale(x, BigDecimal.ROUND_HALF_DOWN);    保留一位小数，向下舍入
```
解决方法很简单，使用BigDecimal的String构造器或者,ValueOf方法
```
double d1 = 0.1;
double d2 = 0.1;

BigDecimal b1 = new BigDecimal(String.valueOf(d1));
BigDecimal b2 = new BigDecimal(String.valueOf(d2));
BigDecimal value = BigDecimal.valueOf(d1);; // 0.1

System.out.println(b1.add(b2));//输出：0.2

```
