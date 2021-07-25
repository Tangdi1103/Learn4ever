这个类主要用来解决国际化和本地化问题。国际化和本地化可不是两个概念，两者都是一起出现的。可以说，国际化的目的就是为了实现本地化。比如对于“取消”，中文中我们使用“取消”来表示，而英文中我们使用“cancel”。若我们的程序是面向国际的（这也是软件发展的一个趋势），那么使用的人群必然是多语言环境的，实现国际化就非常有必要。而ResourceBundle可以帮助我们轻松完成这个任务：当程序需要一个特定于语言环境的资源时（如 String），程序可以从适合当前用户语言环境的资源包（大多数情况下也就是.properties文件）中加载它。这样可以编写很大程度上独立于用户语言环境的程序代码，它将资源包中大部分（即便不是全部）特定于语言环境的信息隔离开来。


在resource包下创建i18n包，再i18n下创建Resource Bundle文件,名称为message。
- messages.properties
- messages_en_US.properties
- messages_zh_US.properties

```
ResourceBundle.getBundle("i18n_message",new Locale("zh","CN")).getString("upp_success");
```
