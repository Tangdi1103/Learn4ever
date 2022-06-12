[toc]

### 一、原生mp使用

#### 1. 依赖

```xml
<dependencies> 
    <!-- mybatis-plus插件依赖 --> 
    <dependency> 
        <groupId>com.baomidou</groupId> 
        <artifactId>mybatis-plus</artifactId> 
        <version>3.1.1</version> 
    </dependency> 
    
    <!--Mysql--> 
    <dependency> 
        <groupId>mysql</groupId> 
        <artifactId>mysql-connector-java</artifactId> 
        <version>5.1.47</version> 
    </dependency> 
    
    <!--连接池--> 
    <dependency> 
        <groupId>com.alibaba</groupId>
        <artifactId>druid</artifactId> 
        <version>1.0.11</version> 
    </dependency> 
    
    <!--简化bean代码的工具包，注意：mp需要依赖lombok使用--> 
    <dependency> 
        <groupId>org.projectlombok</groupId> 
        <artifactId>lombok</artifactId> 
        <version>1.18.4</version> 
    </dependency> 
    
    <dependency> 
        <groupId>junit</groupId> 
        <artifactId>junit</artifactId> 
        <version>4.12</version> 
    </dependency> 
    
    <dependency> 
        <groupId>org.slf4j</groupId> 
        <artifactId>slf4j-log4j12</artifactId> 
        <version>1.6.4</version> 
    </dependency> 
</dependencies> 

<build> 
    <plugins> 
        <plugin> 
            <groupId>org.apache.maven.plugins</groupId> 
            <artifactId>maven-compiler-plugin</artifactId> 
            <configuration> 
                <source>1.8</source> 
                <target>1.8</target> 
            </configuration> 
        </plugin> 
    </plugins> 
</build>
```



#### 2. 增
