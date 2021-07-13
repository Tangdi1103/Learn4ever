V1.0

1. ServerSocket监听端口

2. 使用while(true) accept 阻塞监听端口

3. socket得到输入/输出流

4. 输出流write输出
   1. 响应数据包含响应头+响应体
   2. 每个响应属性都有换行
   3. 响应头和响应体中间有一个空行
   4. content-Length为输出字节流长度

5. 关闭socket



V2.0

1. ServerSocket监听端口
2. 使用while true accept 阻塞监听端口
3. 创建Request/Response对象，分别封装输入流/输出流的。
   1. 封装输入流的url、mothod、输入流
   2. 封装输出流的write，输出静态资源
4. 输入流available获取数据长度，网络io可能存在间断性，需要判断数据长度是否不为零。循环读取不为零
5. 创建byte数组，输入流读取到数组中，数组转为字符串，分割\n和空格得到url和method
6. 封装Response，获得请求路径，读取请求路径得到绝对路径。通过file判断是否存在以及是否为文件类型。
   1. 是，读取文件流，循环判断io数据长度不为零。获取数据长度，  已写长度，创建1024长度byte数组。设置已写长度小于总数据长度循环条件，若已写 + 1024 大于总数据长度则创建数组长度设置为剩余长度数组。（否则尾部输出空不合适）。剩余长度足够则读取文件输入流到数组，输出流输出数组内容，刷新输出流，重新计算已写长度
   2. 否，输出404



V3.0

1. 自定义Servlet接口init、service（req,resp）方法
2. 自定义抽象Servlet类为默认模板实现Servlet接口，定义doGet，doPost方法，实现service方法（get请求调用doget，post请求调用dopost）
3. 自定义Servlet实现类，继承抽象模板类，实现doget和dopost方法，简单输出字符串。并创建web.xml，配置到web.xml中
4. 加载并解析web.xml，通过dom4j和xpath来完成。完成自定义Servlet的实例化并存入Map的V，K为urlpattern
5. 在V2.0基础上，加载得到Map，若Request中URL是与Map的键相同，则调用Servlet的service方法，否则根据URL请求静态资源





V4.0

1. 以上三个版本接收请求模型均为BIO，现在使用多线程进行改造
2. 定义线程执行处理器，将之前的逻辑放入run方法

3. 使用线程池执行线程实现类