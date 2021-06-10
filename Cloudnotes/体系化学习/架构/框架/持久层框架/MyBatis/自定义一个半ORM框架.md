[toc]
<font size=4>

# 一、原始JDBC操作的问题
1.  数据库配置存在硬编码问题，不易统一维护
1.  频繁的创建/释放数据库链接，浪费系统资源，影响性能
1.  sql语句、预编译、获取结果集存在硬编码问题
1.  需要手动封装结果集至对象中，若查询字段或POJO变化，需重新解析封装
![image](images/10327)



# 二、解决思路及设计方案：
## 2.1思路
1. 使用数据库连接池初始化连接资源
1. 将sql语句抽取到xml配置文件中
1. 使用反射、内省等底层技术，自动将实体与表进行属性与字段的自动映射

## 2.2设计
### 2.2.1使用端（引入自定义持久层框架依赖）
#### 2.2.1.1. sqlMapConfig.xml
> 1. 存放数据源信息
> 2. 存放所有Mapper.xml的全路径

```
<mappers>
   <mapper resource="UserMapper.xml"></mapper>
   <mapper resource="OrderMapper.xml"></mapper>
</mappers>

```
> 3. 使用package标签配置Mapper接口所在包的全路径

    1. xml文件名需与Mapper接口名相同
    2. 利用反射获取包下或有的接口类型
    3. 根据类文件名找到classpath下同名的xml文件

```
<mappers>
   <!--扫描使用注解的类所在的包-->
   <package name="com.tangdi.mapper"></package>
</mappers>
```

#### 2.2.1.2. Mapper.xml
    1. sql语句的配置文件信息
    2. namespace+id组成一条sql的唯一标识

### 2.2.2框架端（封装JDBC操作）
#### 1. 加载配置文件信息为字节输入流
#### 2. 创建一个SqlSessionFactoryBuilder类
    1. 使用dom4j解析xml文件，组装到实体对象中
    2. 将解析后的对象传入SqlSessionFactory构造函数，创建SqlSessionFactory并返回
#### 3. 通过dom4j解析配置文件及sql文件，存入实体类
    1. Configuration(配置源信息)：DataSource(classDriver、jdbcUrl、name、password)、Map<statementId,MappedStatement>
    2. MappedStatement(mapper信息)：id、parameterType、resultType、sql、mapperType
#### 4. 创建SqlSessionFactory工厂接口及默认实现类,getSqlSession()
#### 5. 创建SqlSession接口及默认实现，实现通用CRUD方法
    1.默认conn.setAutoCommit(false)
    2.select
    3.update
    4.insert
    5.delete
    6.commit
    7.close
    8.rollback
    9.getMapper
#### 6. 创建Executor接口及默认实现，执行JDBC操作
    1. 接收Configuration、MappedStatement和查询对象
    2. boundSql，解析sql替换#{colunm}为?，并抽取查询字段
    3. 通过连接池获取connection，创建prepareStatement
    4. 通过查询字段和MappedStatement中的请求class对象，绑定sql参数
    5. 通过ResultSet.metaData()获取元数据，并使用内省类PropertyDescriptor完成ORM，封装对象
#### 7.使用动态代理，解决客户端入参statementId硬编码
    1.Mapper.xml的statementId = namespace(DAO接口全路径) + "." + id(方法名)

![image](images/10450)


# 三、自定义持久层框架代码实现
## 3.1 创建SqlSessionFactoryBuilder
解析字节输入流，将生成的Configuration类传入SqlSessionFactory构造函数，创建SqlSessionFactory
```
import com.mchange.v2.c3p0.ComboPooledDataSource;
import com.tangdi.pojo.Configuration;
import org.dom4j.Document;
import org.dom4j.DocumentException;
import org.dom4j.Element;
import org.dom4j.io.SAXReader;

import java.beans.PropertyVetoException;
import java.io.*;
import java.net.URL;
import java.util.*;

/**
 * @program: IPersistence
 * @description: 配置解析工具类
 * @author: Wangwentao
 * @create: 2021-06-07 16:27
 **/
public class XMLConfigerBuilder {

    public Configuration parse(InputStream in) throws DocumentException, PropertyVetoException, IOException, ClassNotFoundException {
        Document document = new SAXReader().read(in);
        Element root = document.getRootElement();
        Configuration configuration = parseConfig(root);
        return configuration;
    }

    private Configuration parseConfig(Element root) throws PropertyVetoException, IOException, ClassNotFoundException, DocumentException {
        List<Element> propertyElements = root.selectNodes("//property");
        Configuration configuration = new Configuration();
        Properties properties = new Properties();

        for (Element e : propertyElements) {
            String name = e.attributeValue("name");
            String value = e.attributeValue("value");
            properties.setProperty(name,value);
        }

        ComboPooledDataSource comboPooledDataSource = new ComboPooledDataSource();
        comboPooledDataSource.setDriverClass(properties.getProperty("classDriver"));
        comboPooledDataSource.setJdbcUrl(properties.getProperty("jdbcUrl"));
        comboPooledDataSource.setUser(properties.getProperty("username"));
        comboPooledDataSource.setPassword(properties.getProperty("password"));
        configuration.setDataSource(comboPooledDataSource);

        List<Element> packages = root.selectNodes("//package");
        List<String> result = new ArrayList<>();
        for (Element node : packages) {
            String pathName = node.attributeValue("name");
            getClassName(result, pathName);

            for (String r : result) {
                String externalName = r.substring(0, r.indexOf('.')).replace('/', '.');
//                Class<?> aClass = getClassLoader().loadClass(externalName);
                XMLMapperBuilder xmlMapperBuilder = new XMLMapperBuilder(configuration);
                xmlMapperBuilder.parse(pathName + "/" + externalName);
            }
        }



        return configuration;
    }

    private void getClassName(List<String> result, String pathName) throws IOException {
        String path = pathName.replace('.', '/');
        List<URL> urls = getResources(path);
        for (URL url : urls) {
            InputStream is = null;
            try {
                if ("file".equals(url.getProtocol())){
                    is = url.openStream();
                    BufferedReader reader = new BufferedReader(new InputStreamReader(is));
                    List<String> lines = new ArrayList<String>();
                    for (String line; (line = reader.readLine()) != null;) {

                        lines.add(line);
                        if (getResources(path + "/" + line).isEmpty()) {
                            lines.clear();
                            break;
                        }
                    }

                    if (!lines.isEmpty()) {
                        result.addAll(lines);
                    }
                }
            } finally {
                if (is != null) {
                    try {
                        is.close();
                    } catch (Exception e) {
                        // Ignore
                    }
                }
            }
        }
    }

    protected static List<URL> getResources(String path) throws IOException {
        return Collections.list(Thread.currentThread().getContextClassLoader().getResources(path));
    }

    public ClassLoader getClassLoader() {
        return Thread.currentThread().getContextClassLoader();
    }
}

```

## 3.2 SqlMapConfig.xml和Mapper.xml的解析类
dataSource使用连接池，使用classloader.getResource()扫描packge路径下所有mapper文件,解析并封装所有属性，所有属性封装进configuration类中
```
package com.tangdi.parse;

import com.mchange.v2.c3p0.ComboPooledDataSource;
import com.tangdi.pojo.Configuration;
import org.dom4j.Document;
import org.dom4j.DocumentException;
import org.dom4j.Element;
import org.dom4j.io.SAXReader;

import java.beans.PropertyVetoException;
import java.io.*;
import java.net.URL;
import java.util.*;

/**
 * @program: IPersistence
 * @description: 配置解析工具类
 * @author: Wangwentao
 * @create: 2021-06-07 16:27
 **/
public class XMLConfigerBuilder {

    public Configuration parse(InputStream in) throws DocumentException, PropertyVetoException, IOException, ClassNotFoundException {
        Document document = new SAXReader().read(in);
        Element root = document.getRootElement();
        Configuration configuration = parseConfig(root);
        return configuration;
    }

    private Configuration parseConfig(Element root) throws PropertyVetoException, IOException, ClassNotFoundException, DocumentException {
        List<Element> propertyElements = root.selectNodes("//property");
        Configuration configuration = new Configuration();
        Properties properties = new Properties();

        for (Element e : propertyElements) {
            String name = e.attributeValue("name");
            String value = e.attributeValue("value");
            properties.setProperty(name,value);
        }

        ComboPooledDataSource comboPooledDataSource = new ComboPooledDataSource();
        comboPooledDataSource.setDriverClass(properties.getProperty("classDriver"));
        comboPooledDataSource.setJdbcUrl(properties.getProperty("jdbcUrl"));
        comboPooledDataSource.setUser(properties.getProperty("username"));
        comboPooledDataSource.setPassword(properties.getProperty("password"));
        configuration.setDataSource(comboPooledDataSource);

        List<Element> packages = root.selectNodes("//package");
        List<String> result = new ArrayList<>();
        for (Element node : packages) {
            String pathName = node.attributeValue("name");
            getClassName(result, pathName);

            for (String r : result) {
                String externalName = r.substring(0, r.indexOf('.')).replace('/', '.');
//                Class<?> aClass = getClassLoader().loadClass(externalName);
                XMLMapperBuilder xmlMapperBuilder = new XMLMapperBuilder(configuration);
                xmlMapperBuilder.parse(pathName + "/" + externalName);
            }
        }



        return configuration;
    }

    private void getClassName(List<String> result, String pathName) throws IOException {
        String path = pathName.replace('.', '/');
        List<URL> urls = getResources(path);
        for (URL url : urls) {
            InputStream is = null;
            try {
                if ("file".equals(url.getProtocol())){
                    is = url.openStream();
                    BufferedReader reader = new BufferedReader(new InputStreamReader(is));
                    List<String> lines = new ArrayList<String>();
                    for (String line; (line = reader.readLine()) != null;) {

                        lines.add(line);
                        if (getResources(path + "/" + line).isEmpty()) {
                            lines.clear();
                            break;
                        }
                    }

                    if (!lines.isEmpty()) {
                        result.addAll(lines);
                    }
                }
            } finally {
                if (is != null) {
                    try {
                        is.close();
                    } catch (Exception e) {
                        // Ignore
                    }
                }
            }
        }
    }

    protected static List<URL> getResources(String path) throws IOException {
        return Collections.list(Thread.currentThread().getContextClassLoader().getResources(path));
    }

    public ClassLoader getClassLoader() {
        return Thread.currentThread().getContextClassLoader();
    }
}


package com.tangdi.parse;

import com.tangdi.io.Resource;
import com.tangdi.pojo.Configuration;
import com.tangdi.pojo.MappedStatement;
import org.dom4j.Document;
import org.dom4j.DocumentException;
import org.dom4j.Element;
import org.dom4j.io.SAXReader;

import java.io.InputStream;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * @program: IPersistence
 * @description: mapper解析器
 * @author: Wangwentao
 * @create: 2021-06-07 16:53
 **/
public class XMLMapperBuilder {

    private Configuration configuration;
    private final List<String> type = new ArrayList<>(Arrays.asList("select","insert","update","delete"));

    public XMLMapperBuilder(Configuration configuration) {
        this.configuration = configuration;
    }

    public void parse(String r) throws DocumentException, ClassNotFoundException {
        InputStream in = null;
        try {
//            String xmlResource = r.replace('.', '/') + ".xml";
            String xmlResource = r + ".xml";
            in = Resource.getResourceAsStream(xmlResource);
            Document document = new SAXReader().read(in);
            Element root = document.getRootElement();
            String namespace = root.attributeValue("namespace");

            for (String t : type) {
                List<Element> list2 = root.elements(t);
                setMeppedStatement(namespace, list2,t);
            }

        } finally {
            try {
                in.close();
            } catch (Exception e) {
            }
        }
    }

    private void setMeppedStatement(String namespace, List<Element> select, String type) throws ClassNotFoundException {
        for (Element element : select) {
            String id = element.attributeValue("id");
            String resultType = element.attributeValue("resultType");
            String parameterType = element.attributeValue("parameterType");
            String sqlText = element.getTextTrim();
            MappedStatement mappedStatement = new MappedStatement();
            mappedStatement.setId(id);
            mappedStatement.setResultType(getClassType(resultType));
            mappedStatement.setParameterType(getClassType(parameterType));
            mappedStatement.setSqlText(sqlText);
            mappedStatement.setSqlType(type);
            String key = namespace+"."+id;
            configuration.getMappedStatements().put(key,mappedStatement);

        }
    }

    private Class<?> getClassType(String name) throws ClassNotFoundException {
        return Class.forName(name);
    }
}

```

## 3.3 SqlSessionFactory及默认实现类
提供两种创建SqlSession方法，一个是可设置自动提交Executor，另一个是默认自动提交Executor
```
public class DefaultSqlSessionFactory implements SqlSessionFactory{

    private Configuration configuration;

    public DefaultSqlSessionFactory(Configuration configuration) {
        this.configuration = configuration;
    }

    @Override
    public SqlSession openSqlSession() {
        Executor simplerExecutor = new SimplerExecutor(configuration);
        return new DfaultSqlSession(configuration,simplerExecutor);
    }

    @Override
    public SqlSession openSqlSession(boolean autoCommit) {
        Executor simplerExecutor = new SimplerExecutor(configuration,autoCommit);
        return new DfaultSqlSession(configuration,simplerExecutor);
    }
}


```


## 3.4 SqlSession及默认实现类

构造函数包含核心配置类、执行器，每个sqlsession对应一个Executor，通过Executor获取jdbc连接提供带statementId的CRUD、commit、close、rollback和代理功能
```
public class DfaultSqlSession implements SqlSession{

    private Configuration configuration;
    private Executor executor;

    public DfaultSqlSession(Configuration configuration, Executor executor) {
        this.configuration = configuration;
        this.executor = executor;
    }

    @Override
    public Object selectList(String statementid, Object... params) throws Exception {
        MappedStatement mappedStatement = configuration.getMappedStatements().get(statementid);
        return executor.query(mappedStatement, "list", params);
    }

    @Override
    public Object selectByName(String statementid, Object... params) throws Exception {
        MappedStatement mappedStatement = configuration.getMappedStatements().get(statementid);
        return executor.query(mappedStatement, "one", params);
    }

    @Override
    public int insert(String statementid, Object... params) throws Exception {
        MappedStatement mappedStatement = configuration.getMappedStatements().get(statementid);
        return executor.update(mappedStatement, params);
    }

    @Override
    public int update(String statementid, Object... params) throws Exception {
        MappedStatement mappedStatement = configuration.getMappedStatements().get(statementid);
        return executor.update(mappedStatement, params);
    }

    @Override
    public int delete(String statementid, Object... params) throws Exception {
        MappedStatement mappedStatement = configuration.getMappedStatements().get(statementid);
        return executor.update(mappedStatement, params);
    }

    @Override
    public void close()  {
        try {
            if (executor.getConnection() != null) {
                executor.getConnection().close();
            }
        } catch (Exception e) {
            throw new RuntimeException("关闭连接异常",e);
        }
    }

    @Override
    public void commit()  {
        try {
            if (executor.getConnection() != null && !executor.getConnection().getAutoCommit()) {
                executor.getConnection().commit();
            }
        } catch (Exception e) {
            throw new RuntimeException("事务提交异常",e);
        }
    }

    @Override
    public void rollback() throws SQLException {
        try {
            if (executor.getConnection() != null && !executor.getConnection().getAutoCommit()) {
                executor.getConnection().rollback();
            }
        } catch (Exception e) {
            throw new RuntimeException("事务回滚异常",e);
        }
    }

    @Override
    public Object getMapper(Class<?> mapperClass) {
        MapperProxyHandler mapperProxyHandler = new MapperProxyHandler(configuration,executor);
        return Proxy.newProxyInstance(DfaultSqlSession.class.getClassLoader(),new Class[]{mapperClass},mapperProxyHandler);
    }
}
```

## 3.5 Executor及默认实现类

Executor才是最终的做JDBC操作的类，使用连接池的dataSource获取jdbc连接；

解析获得?替换#{}后得sql，以及#{}中得查询字段名，预编译sql，并使用反射得到查询字段值并设置参数；

执行sql得到结果集resultSet，通过ResultSetMetaData元数据封装属性名及值到返回对象中，此处得DB与POJO字段名完全相同。

可通过注解为POJO提供别名，然后用别名映射DB字段
```
public class SimplerExecutor implements Executor{

    private Connection connection;
    private Configuration configuration;
    private boolean autoCommit = true;


    public SimplerExecutor(Configuration configuration) {
        this.configuration = configuration;
    }

    public SimplerExecutor(Configuration configuration, boolean autoCommit) {
        this.configuration = configuration;
        this.autoCommit = autoCommit;
    }

    @Override
    public Object query(MappedStatement mappedStatement,String type, Object... params) throws Exception {
        // 获取数据库连接
        Connection connection = getConnection();

        // 解析sql
        BoundSql boundSql = getBoundSql(mappedStatement.getSqlText());
        // 获取预编译类
        PreparedStatement preparedStatement = connection.prepareStatement(boundSql.getSql());

        // 设置参数
        Class<?> parameterType = mappedStatement.getParameterType();
        List<ParameterMapping> parameterMappingList = boundSql.getParameterMappingList();
        for (int i = 0; i < parameterMappingList.size(); i++) {
            Field field = parameterType.getDeclaredField(parameterMappingList.get(i).getContent());
            field.setAccessible(true);
            Object value = field.get(params[0]);
            preparedStatement.setObject(i+1,value);
        }

        // 执行sql
        ResultSet resultSet = preparedStatement.executeQuery();

        // 封住结果集
        List<Object> objects = new ArrayList<>();
        Class<?> resultType = mappedStatement.getResultType();
        while (resultSet.next()){
            Object result = resultType.newInstance();

            // 获取元数据
            ResultSetMetaData metaData = resultSet.getMetaData();
            for (int i = 1; i <= metaData.getColumnCount(); i++) {
                // 字段名
                String columnName = metaData.getColumnName(i);
                // 字段值
                Object columnValue = resultSet.getObject(columnName);

                Class<?> aClass = result.getClass();
                Field declaredField = aClass.getDeclaredField(columnName);
                declaredField.setAccessible(true);
                declaredField.set(result,columnValue);
//                PropertyDescriptor propertyDescriptor = new PropertyDescriptor(columnName,resultType);
//                Method writeMethod = propertyDescriptor.getWriteMethod();
//                writeMethod.invoke(result,columnValue);
            }
            objects.add(result);
        }

        if ("list".equals(type)){
            return objects;
        }
        if (!objects.isEmpty()){
            return objects.get(0);
        }
        return null;
    }

    @Override
    public int update(MappedStatement mappedStatement, Object... params) throws Exception {
        // 获取数据库连接
        Connection connection = getConnection();

        // 解析sql
        BoundSql boundSql = getBoundSql(mappedStatement.getSqlText());
        // 获取预编译类
        PreparedStatement preparedStatement = connection.prepareStatement(boundSql.getSql());

        // 设置参数
        Class<?> parameterType = mappedStatement.getParameterType();
        List<ParameterMapping> parameterMappingList = boundSql.getParameterMappingList();
        for (int i = 0; i < parameterMappingList.size(); i++) {
            Field field = parameterType.getDeclaredField(parameterMappingList.get(i).getContent());
            field.setAccessible(true);
            Object value = field.get(params[0]);
            preparedStatement.setObject(i+1,value);
        }

        return preparedStatement.executeUpdate();
    }

    public Connection getConnection() throws SQLException {
        if (connection == null){
            connection = configuration.getDataSource().getConnection();
            connection.setAutoCommit(autoCommit);
        }
        return connection;
    }

    private BoundSql getBoundSql(String sql) {
        //标记处理类：配置标记解析器来完成对占位符的解析处理工作
        ParameterMappingTokenHandler parameterMappingTokenHandler = new ParameterMappingTokenHandler();
        GenericTokenParser genericTokenParser = new GenericTokenParser("#{", "}", parameterMappingTokenHandler);
        //解析出来的sql
        String parseSql = genericTokenParser.parse(sql);
        //#{}里面解析出来的参数名称
        List<ParameterMapping> parameterMappings = parameterMappingTokenHandler.getParameterMappings();

        return new BoundSql(parseSql,parameterMappings);
    }
}
```

## 3.6 代理实现类

通过被代理类的Method对象，可获得类名+"."+方法名的statementId，xml中的namespace和id需与该statementId一致。根据statementId获得对应的mappedStatement对象，调用Executor
```
public class MapperProxyHandler implements InvocationHandler {

    private Configuration configuration;
    private Executor executor;

    public MapperProxyHandler(Configuration configuration, Executor executor) {
        this.configuration = configuration;
        this.executor = executor;
    }

    @Override
    public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
        Class<?> aClass = method.getDeclaringClass();
        String spacename = aClass.getName();
        String id = method.getName();
        String key = spacename + "." + id;
        MappedStatement mappedStatement = configuration.getMappedStatements().get(key);
        String sqlType = mappedStatement.getSqlType();
        if ("select".equalsIgnoreCase(sqlType)){
            Type genericReturnType = method.getGenericReturnType();
            if (genericReturnType instanceof ParameterizedType){
                return executor.query(mappedStatement, "list",args);
            }
            return executor.query(mappedStatement, "one",args);
        } else {
            return executor.update(mappedStatement, args);
        }
    }
}
```

## 3.7 测试类

```
public class Test {
    SqlSession sqlSession;
    UserDao mapper;

    @Before
    public void before(){
        InputStream inputStream = Resource.getResourceAsStream("SqlMapConfiguration.xml");
        SqlSessionFactoryBuilder sqlSessionFactoryBuilder = new SqlSessionFactoryBuilder();
        SqlSessionFactory sqlSessionFactory = sqlSessionFactoryBuilder.build(inputStream);
        sqlSession = sqlSessionFactory.openSqlSession(true);
        mapper = (UserDao) sqlSession.getMapper(UserDao.class);

    }

    @org.junit.Test
    public void selectTest(){
        try {
            User user = new User();
            List<User> all = mapper.findAll(user);
            for (User a : all) {
                System.out.println(a);
            }
        } finally {
            try {
                sqlSession.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    @org.junit.Test
    public void selectTest2(){
        try {
            User user = new User();
            user.setUsername("lucy");
            User u = mapper.findByName(user);
            System.out.println(u);
        } finally {
            try {
                sqlSession.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    @org.junit.Test
    public void insertTest(){
        try {
            User user = new User();
            user.setId(3);
            user.setUsername("张三");
            int i = mapper.insert(user);
            System.out.println(i);

            List<User> all = mapper.findAll(user);
            for (User a : all) {
                System.out.println(a);
            }
        } finally {
            try {
                sqlSession.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }


    @org.junit.Test
    public void updateTest(){
        try {
            User user = new User();
            user.setId(1);
            user.setUsername("王五");
            int i = mapper.update(user);

            System.out.println(i);

            List<User> all = mapper.findAll(user);
            for (User a : all) {
                System.out.println(a);
            }
        } finally {
            try {
                sqlSession.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }


    @org.junit.Test
    public void deleteTest(){
        try {
            User user = new User();
            user.setId(3);
            int i = mapper.delete(user);
            System.out.println(i);

            List<User> all = mapper.findAll(user);
            for (User a : all) {
                System.out.println(a);
            }
        } finally {
            try {
                sqlSession.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }
}
```

## 3.8 xml文件

### 3.8.1 SqlMapConfig.xml
```
<configuration>

    <!--数据库配置信息-->
    <dataSource>
        <property name = "classDriver" value = "com.mysql.jdbc.Driver"></property>
        <property name = "jdbcUrl" value = "jdbc:mysql://localhost:3306/demo_jpa"></property>
        <property name = "username" value = "root"></property>
        <property name = "password" value = "123456"></property>
    </dataSource>


    <mappers>
        <mapper>
            <package name = "com.tangdi.dao"></package>
        </mapper>
    </mappers>
</configuration>
```

### 3.8.1 SqlMapConfig.xml
```
<mapper namespace="com.tangdi.dao.UserDao">
    <select id="findAll" parameterType="com.tangdi.domain.User" resultType="com.tangdi.domain.User" >
        select * from user_demo
    </select>

    <select id="findByName" parameterType="com.tangdi.domain.User" resultType="com.tangdi.domain.User" >
        select * from user_demo where username = #{username}
    </select>

    <insert id="insert" parameterType="com.tangdi.domain.User" resultType="com.tangdi.domain.User" >
        insert into user_demo values(#{id},#{username})
    </insert>

    <update id="update" parameterType="com.tangdi.domain.User" resultType="com.tangdi.domain.User" >
        update user_demo set username=#{username} where id = #{id}
    </update>

    <delete id="delete" parameterType="com.tangdi.domain.User" resultType="com.tangdi.domain.User" >
        delete from user_demo where id = #{id}
    </delete>
</mapper>
```



# 四、仿造MyBatis中的功能优化
## 4.1. 动态标签

## 4.2. sql抽取标签

## 4.3. resultMap标签-实体属性与表字段的映射关系，格式如下

```
<resultMap id="orderMap" type="com.lagou.domain.Order">
   <result property="id" column="id"></result>
   <result property="ordertime" column="ordertime"></result>
   <result property="total" column="total"></result>
   
   <!- 一对一 -->
   <association property="user" javaType="com.lagou.domain.User">
       <result column="uid" property="id"></result>
       <result column="username" property="username"></result>
       <result column="password" property="password"></result>
       <result column="birthday" property="birthday"></result>
   </association>
   
   <!- 一对多 -->
   <collection property="orderList" ofType="com.lagou.domain.Order">
       <result column="oid" property="id"></result>
       <result column="ordertime" property="ordertime"></result>
       <result column="total" property="total"></result>
   </collection>
</resultMap>
```
##  4.4.增加缓存

    1. builder解析SqlMapConfig.xml和各Mapper.xml得到Configuration核心配置类
    	1.Configuration若含二级缓存标识，则创建CachingExecutor传入SqlSessionFactory
    	2.Configuration若不含二级缓存标识，则船舰SimpleExecutor传入SqlSessionFactory
    2. 一级缓存作用域SqlSession，执行数据库操作时将结果存于HashMap中
    3. 增删改时，会清空SqlSession中的缓存
    4. 二级缓存作用域namespace，在解析mapper.xml时生成Cache封装在各个MeppedStatement对象中，所以同个namespace的两个SqlSession共享同一个缓存对象
    5. Mybatis自带的二级缓存不支持分布式架构，需整合缓存服务来做二级缓存如redis
    6. 缓存只在autoCommit关闭时生效，在调用commit方法时，先清空缓存，再commit事务
    7. 实现原理：在SqlMapConfiguration和各Mapper.xml中开启二级缓存
        <settings>
           <setting name="cacheEnabled" value="true"/>
        </settings>


##  4.5.延迟加载(懒加载)

    1. 通过嵌套查询来实现懒加载
    2. resultMap标签-局部延迟加载
        <resultMap id="userMap" type="user">
            <result column="id" property="id"></result>
            <result column="username" property="username"></result>
            <collection property="orderList" ofType="order" column="id"   
               select="com.lagou.dao.OrderMapper.findByUid" fetchType="lazy">
            </collection>
        </resultMap>
        
    3. 在SqlMapConfiguration开启懒加载-全局懒加载
        <settings>
           <!--开启全局延迟加载功能-->
           <setting name="lazyLoadingEnabled" value="true"/>
        </settings>
    4.实现原理：在DefaultResultSetHandler.createResultObject()方法处理返回结果时，判断ResultMap标签中是否含懒加载，是则创建代理实现类。代理实现类中判断当前方法是否懒加载，是则执行查询
    5.实现方式：有Javassist和Cglib两种代理方式，默认使用javassist实现


# 五、使用的技术 
## 5.1设计模式
### 5.1.1 构建者模式
#### SqlSessionFactoryBuilder

### 5.1.2. 工厂模式
#### proxyFactory
#### SqlSessionFactory
#### TransactionFactory
### 5.1.3. 代理模式
将客户端加载配置文件，创建sqlSessionFactory和生产sqlSession的重复代码放入DAO接口的代理实现内中，实现只用调用DAO接口就完成数据库操作

使用jdk自带的动态代理：
Proxy.newProxyInstance(ClassLoader，Class[]，InvocationHandler)
1. ClassLoader:当前类的类加载器
1. Class[]:需被代理类的Class数组
1. InvocationHandler:代理实现类
2. 
![image](images/10517)

## 5.2反射
## 5.3泛型



</font>