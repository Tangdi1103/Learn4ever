### MessageFormat.format（）
format string接受参数位置（例如{0}，{1}）。例：


```
passenger.over100=\u4E58\u673A\u4EBA\u6700\u5927\u9650\u5236100\u4E2A\uFF0C\u60A8\u76EE\u524D\u7684\u4E58\u673A\u4EBA\u4E3A{0}\u4E2A\uFF0C\u8BF7\u5220\u9664\u540E\u518D\u8FDB\u884C\u64CD\u4F5C

```


```
String message = MessageFormat.format(I18NUtil.getString("passenger.over100", lang), "啊");

```

### String.format（）

format string接受参数类型说明符（例如，$d表示数字，$s表示字符串，%代表第几位）。例：



```
create.order.checkBirthdate=%1$s\u8bc1\u4ef6\u53f7\u4e0e\u51fa\u751f\u65e5\u671f\u6709\u51b2\u7a81\uff0c\u8bf7\u91cd\u65b0\u68c0\u67e5\u3002

```


```
String msg = String.format(I18NUtil.getString("create.order.checkBirthdate", lang), s);
```
