[toc]

### 需求：

1. 提供服务，接收请求（Socket通信）
2. 请求信息封装成Request对象（Response对象）
3. 客户端请求资源，资源分为静态资源（html）和动态资源（Servlet） 
4. 资源返回给客户端浏览器



### V1.0

1. ServerSocket监听端口

2. 使用while(true) accept 阻塞监听端口

3. socket得到输入/输出流

4. 输出流write输出
   1. 响应数据包含响应头+响应体
   2. 每个响应属性都有换行
   3. 响应头和响应体中间有一个空行
   4. content-Length为输出字节流长度

5. 关闭socket



### V2.0

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



### V3.0

1. 自定义Servlet接口init、service（req,resp）方法
2. 自定义抽象Servlet类为默认模板实现Servlet接口，定义doGet，doPost方法，实现service方法（get请求调用doget，post请求调用dopost）
3. 自定义Servlet实现类，继承抽象模板类，实现doget和dopost方法，简单输出字符串。并创建web.xml，配置到web.xml中
4. 加载并解析web.xml，通过dom4j和xpath来完成。完成自定义Servlet的实例化并存入Map的V，K为urlpattern
5. 在V2.0基础上，加载得到Map，若Request中URL是与Map的键相同，则调用Servlet的service方法，否则根据URL请求静态资源





### V4.0

1. 以上三个版本接收请求模型均为BIO，现在使用多线程进行改造
2. 定义线程执行处理器，将之前的逻辑放入run方法

3. 使用线程池执行线程实现类



### 具体实现

#### 创建启动类

```java
package com.tangdi.server;

import org.dom4j.Document;
import org.dom4j.DocumentException;
import org.dom4j.Element;
import org.dom4j.io.SAXReader;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.List;
import java.util.concurrent.*;

/**
 * Minicat的主类
 */
public class Bootstrap {

    // Servlet映射
     private Mapper mapper = new Mapper();
    
    /**
     * Minicat启动需要初始化展开的一些操作
     */
    public void start() throws Exception {

        // 加载解析相关的配置，web.xml
        loadServlet();


        // 定义一个线程池
        int corePoolSize = 10;
        int maximumPoolSize =50;
        long keepAliveTime = 100L;
        TimeUnit unit = TimeUnit.SECONDS;
        BlockingQueue<Runnable> workQueue = new ArrayBlockingQueue<>(50);
        ThreadFactory threadFactory = Executors.defaultThreadFactory();
        RejectedExecutionHandler handler = new ThreadPoolExecutor.AbortPolicy();


        ThreadPoolExecutor threadPoolExecutor = new ThreadPoolExecutor(
                corePoolSize,
                maximumPoolSize,
                keepAliveTime,
                unit,
                workQueue,
                threadFactory,
                handler
        );

        // 使用线程池处理请求
        while(true) {
            Socket socket = serverSocket.accept();
            RequestProcessor requestProcessor = new RequestProcessor(socket,mapper);
            //requestProcessor.start();
            threadPoolExecutor.execute(requestProcessor);
        }
    }


    /**
     * 加载解析web.xml，初始化Servlet
     */
    private void loadServlet() {
        parseServerXml("server.xml");
    }


    @SuppressWarnings("unchecked")
    private void parseServerXml(String fileName) {
        try {
            InputStream serverXml = this.getClass().getClassLoader().getResourceAsStream(fileName);
            SAXReader saxReader = new SAXReader();

            Document document = saxReader.read(serverXml);
            Element root = document.getRootElement();
            Element connectorElement = (Element) root.selectSingleNode("/Server/Service/Connector");
            List<Element> hostElement = root.selectNodes("//Host");


            for (Element element : hostElement) {
                Host host = new Host();
                String name = element.attributeValue("name");
                String appBase = element.attributeValue("appBase");
                File appBaseFile = new File(appBase);
                File[] files = appBaseFile.listFiles();
                for (File file : files) {
                    if (file.isDirectory()){
                        Context context = new Context();
                        String webXml = file.getAbsolutePath().replace("\\", "/").concat("/web.xml");
                        parseWebapp(webXml,context);
                        context.setName(file.getName());
                        host.getContextList().add(context);
                    }
                }

                host.setName(name);
                mapper.getHosts().add(host);
            }

            port = Integer.parseInt(connectorElement.attributeValue("port"));
        } catch (DocumentException e) {
            e.printStackTrace();
        } catch (NumberFormatException e) {
            e.printStackTrace();
        }

    }

    private void parseWebapp(String path, Context context) {
        try {
            InputStream resourceAsStream = new FileInputStream(path);
            SAXReader saxReader = new SAXReader();

            Document document = saxReader.read(resourceAsStream);
            Element rootElement = document.getRootElement();

            String replace = path.replace("web.xml", "");
            MyClassLoader myClassLoader = new MyClassLoader(Bootstrap.class.getClassLoader(),replace);
            List<Element> selectNodes = rootElement.selectNodes("//servlet");
            for (int i = 0; i < selectNodes.size(); i++) {
                Element element =  selectNodes.get(i);
                // <servlet-name>lagou</servlet-name>
                Element servletnameElement = (Element) element.selectSingleNode("servlet-name");
                String servletName = servletnameElement.getStringValue();
                // <servlet-class>server.LagouServlet</servlet-class>
                Element servletclassElement = (Element) element.selectSingleNode("servlet-class");
                String servletClass = servletclassElement.getStringValue();


                // 根据servlet-name的值找到url-pattern
                Element servletMapping = (Element) rootElement.selectSingleNode("/web-app/servlet-mapping[servlet-name='" + servletName + "']");
                // /lagou
                String urlPattern = servletMapping.selectSingleNode("url-pattern").getStringValue();
//                Class<?> aClass = myClassLoader.findClass(servletClass,replace);
                Class<?> aClass = myClassLoader.loadClass(servletClass);

                Wrapper wrapper = new Wrapper();
                wrapper.setName(urlPattern);
                wrapper.setServlet((HttpServlet) aClass.newInstance());
                context.getWrappers().add(wrapper);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * Minicat 的程序启动入口
     * @param args
     */
    public static void main(String[] args) {
        Bootstrap bootstrap = new Bootstrap();
        try {
            // 启动Minicat
            bootstrap.start();
        } catch (IOException e) {
            e.printStackTrace();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
```



#### 协议处理类

```java
package com.tangdi.server;

/**
 * http协议工具类，主要是提供响应头信息，这里我们只提供200和404的情况
 */
public class HttpProtocolUtil {

    /**
     * 为响应码200提供请求头信息
     * @return
     */
    public static String getHttpHeader200(long contentLength) {
        return "HTTP/1.1 200 OK \n" +
                "Content-Type: text/html \n" +
                "Content-Length: " + contentLength + " \n" +
                "\r\n";
    }

    /**
     * 为响应码404提供请求头信息(此处也包含了数据内容)
     * @return
     */
    public static String getHttpHeader404() {
        String str404 = "<h1>404 not found</h1>";
        return "HTTP/1.1 404 NOT Found \n" +
                "Content-Type: text/html \n" +
                "Content-Length: " + str404.getBytes().length + " \n" +
                "\r\n" + str404;
    }
}
```

#### 模型

**请求模型**

```java
package com.tangdi.server;

import java.io.IOException;
import java.io.InputStream;

/**
 * 把请求信息封装为Request对象（根据InputSteam输入流封装）
 */
public class Request {

    private String host;
    private String method; // 请求方式，比如GET/POST
    private String url;  // 例如 /,/index.html

    private InputStream inputStream;  // 输入流，其他属性从输入流中解析出来


    public String getMethod() {
        return method;
    }

    public void setMethod(String method) {
        this.method = method;
    }

    public String getUrl() {
        return url;
    }

    public void setUrl(String url) {
        this.url = url;
    }

    public InputStream getInputStream() {
        return inputStream;
    }

    public void setInputStream(InputStream inputStream) {
        this.inputStream = inputStream;
    }

    public String getHost() {
        return host;
    }

    public void setHost(String host) {
        this.host = host;
    }

    public Request() {
    }


    // 构造器，输入流传入
    public Request(InputStream inputStream) throws IOException {
        this.inputStream = inputStream;

        // 从输入流中获取请求信息
        int count = 0;
        while (count == 0) {
            count = inputStream.available();
        }

        byte[] bytes = new byte[count];
        inputStream.read(bytes);

        String inputStr = new String(bytes);
        // 获取第一行请求头信息
        String firstLineStr = inputStr.split("\\n")[0];  // GET / HTTP/1.1
        String hostStr = inputStr.split("\\n")[1];

        String[] strings = firstLineStr.split(" ");
        String[] hosts = hostStr.replaceAll("\\n|\\r", "").split(" ")[1].split(":");

        this.host = hosts[0];
        this.method = strings[0];
        this.url = strings[1];

        System.out.println("=====>>host:" + host);
        System.out.println("=====>>method:" + method);
        System.out.println("=====>>url:" + url);
    }

    @Override
    public String toString() {
        return "Request{" +
                "host='" + host + '\'' +
                ", method='" + method + '\'' +
                ", url='" + url + '\'' +
                '}';
    }
}
```

**响应模型**

```java
package com.tangdi.server;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;

/**
 * 封装Response对象，需要依赖于OutputStream
 *
 * 该对象需要提供核心方法，输出html
 */
public class Response {

    private OutputStream outputStream;

    public Response() {
    }

    public Response(OutputStream outputStream) {
        this.outputStream = outputStream;
    }


    // 使用输出流输出指定字符串
    public void output(String content) throws IOException {
        outputStream.write(content.getBytes());
    }


    /**
     *
     * @param path  url，随后要根据url来获取到静态资源的绝对路径，进一步根据绝对路径读取该静态资源文件，最终通过
     *                  输出流输出
     *              /-----> classes
     */
    public void outputHtml(String path) throws IOException {
        // 获取静态资源文件的绝对路径
        String absoluteResourcePath = StaticResourceUtil.getAbsolutePath(path);

        // 输入静态资源文件
        File file = new File(absoluteResourcePath);
        if(file.exists() && file.isFile()) {
            // 读取静态资源文件，输出静态资源
            StaticResourceUtil.outputStaticResource(new FileInputStream(file),outputStream);
        }else{
            // 输出404
            output(HttpProtocolUtil.getHttpHeader404());
        }

    }

}
```

**Servlet模型**

```java
package com.tangdi.server;

public interface Servlet {

    void init() throws Exception;

    void destory() throws Exception;

    void service(Request request,Response response) throws Exception;
}

--------------------------------------------------------------------------------

package com.tangdi.server;

public abstract class HttpServlet implements Servlet{


    public abstract void doGet(Request request,Response response);

    public abstract void doPost(Request request,Response response);


    @Override
    public void service(Request request, Response response) throws Exception {
        if("GET".equalsIgnoreCase(request.getMethod())) {
            doGet(request,response);
        }else{
            doPost(request,response);
        }
    }
}

```

**Container模型**

```java
package com.tangdi.server;

import java.util.ArrayList;
import java.util.List;


public class Mapper {

    private List<Host> hosts = new ArrayList<>();

    public List<Host> getHosts() {
        return hosts;
    }

    public void setHosts(List<Host> hosts) {
        this.hosts = hosts;
    }
}
-------------------------------------------------------------------------------------

    
package com.tangdi.server;

import java.util.ArrayList;
import java.util.List;

public class Host {

    private String name;
    private List<Context> contextList = new ArrayList<>();

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public List<Context> getContextList() {
        return contextList;
    }

    public void setContextList(List<Context> contextList) {
        this.contextList = contextList;
    }
}

-------------------------------------------------------------------------------------
    
    
package com.tangdi.server;


import java.util.ArrayList;
import java.util.List;

public class Context {

    private String name;
    private List<Wrapper> Wrappers = new ArrayList<>();

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public List<Wrapper> getWrappers() {
        return Wrappers;
    }

    public void setWrappers(List<Wrapper> wrappers) {
        Wrappers = wrappers;
    }
}

-------------------------------------------------------------------------------------
    
    
package com.tangdi.server;


public class Wrapper {

    private String name;
    private Servlet servlet;

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Servlet getServlet() {
        return servlet;
    }

    public void setServlet(Servlet servlet) {
        this.servlet = servlet;
    }
}
-------------------------------------------------------------------------------------
```

####  自定义类加载器

```java
package com.tangdi.server;


import java.io.IOException;
import java.io.InputStream;
import java.net.MalformedURLException;
import java.net.URL;

/**
 * @program: Minicat
 * @description:
 * @author: Wangwt
 * @create: 22:36 2021/7/20
 */
public class MyClassLoader extends ClassLoader {

    private final String baseApp;

    public MyClassLoader(ClassLoader parent,String baseApp) {
        super(parent);
        this.baseApp = baseApp;
    }


    @Override
    public Class<?> findClass(String name) throws ClassNotFoundException {
        InputStream inputStream = null;
        try {
            String path = baseApp.concat(name.replace('.', '/').concat(".class"));
            URL url = new URL("file", "", path);
            inputStream = url.openConnection().getInputStream();
            int available = inputStream.available();
            byte[] bytes = new byte[available];
            inputStream.read(bytes);
            return defineClass(name, bytes, 0, bytes.length,null);
        } catch (Exception e) {
            throw new ClassNotFoundException(name);
        } finally {
            if (inputStream != null){
                try {
                    inputStream.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }
    }
}
```



#### 接收请求处理类

```java
package com.tangdi.server;

import java.io.InputStream;
import java.net.Socket;
import java.util.List;

public class RequestProcessor extends Thread {

    private Socket socket;
    private Mapper mapper;

    public RequestProcessor(Socket socket, Mapper mapper) {
        this.socket = socket;
        this.mapper = mapper;
    }

    @Override
    public void run() {
        try{
            InputStream inputStream = socket.getInputStream();

            // 封装Request对象和Response对象
            Request request = new Request(inputStream);
            Response response = new Response(socket.getOutputStream());

            String url = request.getUrl().substring(1);
            int index = url.indexOf("/");
            if (index <= 0 ){
                // 静态资源处理
                response.outputHtml(url);
            } else {
                // 匹配servlet
                Servlet servlet = getServlet(request, url, index);
                if (servlet != null){
                    servlet.service(request,response);
                } else {
                    // 静态资源处理
                    response.outputHtml(url);
                }
            }

            socket.close();

        }catch (Exception e) {
            e.printStackTrace();
        }

    }

    private Servlet getServlet(Request request, String url, int index) {
        Servlet servlet = null;
        String contextPath = url.substring(0, index);
        String urlPattern = url.substring(index);
        for (Host host : mapper.getHosts()) {
            if (request.getHost().equalsIgnoreCase(host.getName())){
                List<Context> contextList = host.getContextList();
                for (Context context : contextList) {
                    if (context.getName().equalsIgnoreCase(contextPath)){
                        List<Wrapper> wrappers = context.getWrappers();
                        for (Wrapper wrapper : wrappers) {
                            if (wrapper.getName().equalsIgnoreCase(urlPattern)){
                                servlet = wrapper.getServlet();
                            }
                        }
                    }
                }
            }
        }
        return servlet;
    }
}
```

#### 资源处理类

```java
package com.tangdi.server;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;

public class StaticResourceUtil {

    /**
     * 获取静态资源文件的绝对路径
     * @param path
     * @return
     */
    public static String getAbsolutePath(String path) throws UnsupportedEncodingException {
        String absolutePath = StaticResourceUtil.class.getResource("/").getPath();
        absolutePath = URLDecoder.decode(absolutePath, "utf-8");
        return absolutePath.replaceAll("\\\\","/") + path;
    }


    /**
     * 读取静态资源文件输入流，通过输出流输出
     */
    public static void outputStaticResource(InputStream inputStream, OutputStream outputStream) throws IOException {

        int count = 0;
        while(count == 0) {
            count = inputStream.available();
        }

        int resourceSize = count;
        // 输出http请求头,然后再输出具体内容
        outputStream.write(HttpProtocolUtil.getHttpHeader200(resourceSize).getBytes());

        // 读取内容输出
        long written = 0 ;// 已经读取的内容长度
        int byteSize = 1024; // 计划每次缓冲的长度
        byte[] bytes = new byte[byteSize];

        while(written < resourceSize) {
            if(written  + byteSize > resourceSize) {  // 说明剩余未读取大小不足一个1024长度，那就按真实长度处理
                byteSize = (int) (resourceSize - written);  // 剩余的文件内容长度
                bytes = new byte[byteSize];
            }

            inputStream.read(bytes);
            outputStream.write(bytes);

            outputStream.flush();
            written+=byteSize;
        }
    }
}
```

#### server.xml配置

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<Server>
    <Service>
        <Engine>
            <Host name = "localhost" appBase = "D:/wanfeng/codespace/webapps"></Host>
        </Engine>
        <Connector port = "8080"></Connector>
    </Service>
</Server>
```

#### pom.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>com.tangdi</groupId>
    <artifactId>Minicat</artifactId>
    <version>1.0-SNAPSHOT</version>


    <dependencies>
        <dependency>
            <groupId>dom4j</groupId>
            <artifactId>dom4j</artifactId>
            <version>1.6.1</version>
        </dependency>
        <dependency>
            <groupId>jaxen</groupId>
            <artifactId>jaxen</artifactId>
            <version>1.1.6</version>
        </dependency>
    </dependencies>


    <build>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>3.1</version>
                <configuration>
                    <source>1.8</source>
                    <target>1.8</target>
                    <encoding>utf-8</encoding>
                </configuration>
            </plugin>
        </plugins>
    </build>
</project>
```



#### 客户端配置

**Servlet类**

```java
package server;

import com.tangdi.server.HttpProtocolUtil;
import com.tangdi.server.HttpServlet;
import com.tangdi.server.Request;
import com.tangdi.server.Response;

import java.io.IOException;

public class Demo2Servlet extends HttpServlet {
    @Override
    public void doGet(Request request, Response response) {
        String content = "<h1>Demo2Servlet get</h1>";
        try {
            response.output((HttpProtocolUtil.getHttpHeader200(content.getBytes().length) + content));
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void doPost(Request request, Response response) {
        String content = "<h1>Demo2Servlet post</h1>";
        try {
            response.output((HttpProtocolUtil.getHttpHeader200(content.getBytes().length) + content));
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void init() throws Exception {

    }

    @Override
    public void destory() throws Exception {

    }
}
```

**web.xml**

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<web-app>
    <servlet>
        <servlet-name>servlet</servlet-name>
        <servlet-class>server.Demo2Servlet</servlet-class>
    </servlet>


    <servlet-mapping>
        <servlet-name>servlet</servlet-name>
        <url-pattern>/tangdi</url-pattern>
    </servlet-mapping>
</web-app>
```

**pom.xml**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>com.tangdi</groupId>
    <artifactId>demo2</artifactId>
    <version>1.0-SNAPSHOT</version>

    <dependencies>
        <dependency>
            <groupId>com.tangdi</groupId>
            <artifactId>Minicat</artifactId>
            <version>1.0-SNAPSHOT</version>
        </dependency>
    </dependencies>

    <build>
        <finalName>demo2</finalName>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>3.1</version>
                <configuration>
                    <source>1.8</source>
                    <target>1.8</target>
                    <encoding>utf-8</encoding>
                </configuration>
            </plugin>
        </plugins>
    </build>
</project>
```

