### MVC简介
MVC是一种三层架构，全称model view controller

---

![image](https://note.youdao.com/yws/public/resource/c5be5802daf0385d18fbdfde57d959e9/xmlnote/C82907D0515B4C31810C1BA425772232/5385)


##### SpringMVC框架为什么可以通过在Controller中写各种方法来处理个各种请求？
因为SpringMVC内部实现了Servlet，一个名叫DispatcherServlet类，所有的请求要经过这个Servlet，具体流程见下文。


##### 流程说明（重要）：

1. 客户端（浏览器）发送请求，直接请求到 DispatcherServlet。
1. DispatcherServlet 根据请求信息调用 HandlerMapping，解析请求对应的 Handler。
1. 解析到对应的 Handler（也就是我们平常说的 Controller 控制器）后，开始由 HandlerAdapter 适配器处理。
1. HandlerAdapter 会根据 Handler 来调用真正的处理器开处理请求，并处理相应的业务逻辑。
1. 处理器处理完业务后，会返回一个 ModelAndView 对象，Model 是返回的数据对象，View 是个逻辑上的 View。
1. ViewResolver 会根据逻辑 View 查找实际的 View。
1. DispaterServlet 把返回的 Model 传给 View（视图渲染）。
1. 把 View 返回给请求者（浏览器）

##### SpringMvc流程：
浏览器请求—>DispatcherSelvlet—>调用HandlerMapping找到对应的handler—>将handler信息返回到DispatcherSelvlet—>请求适配器HandlerAdapter调用对应的controller处理业务—>返回一个ModelAndView给DispatcherSelvlet—>请求视图解析器ViewResolver根据View信息找到View层—>返回给DispatcherSelvlet一个View层页面—>将Model传给View页面进行渲染—>将渲染后的View响应给浏览器