
### 尚有目录结构

![image](https://note.youdao.com/yws/public/resource/c5be5802daf0385d18fbdfde57d959e9/xmlnote/3BFBE265A37449D983F13718A7E3FA9D/3250)


---


### 创建pom.xml

##### 服务提供者和消费者通用的项目

```
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>com.tangdi</groupId>
        <artifactId>itoken-dependencies</artifactId>
        <version>1.0.0-SNAPSHOT</version>
        <relativePath>../itoken-dependencies/pom.xml</relativePath>
    </parent>

    <artifactId>itoken-common</artifactId>
    <packaging>jar</packaging>

    <dependencies>

        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-context</artifactId>
        </dependency>

        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
        </dependency>
        <dependency>
            <groupId>com.fasterxml.jackson.core</groupId>
            <artifactId>jackson-databind</artifactId>
        </dependency>
        <dependency>
            <groupId>org.apache.commons</groupId>
            <artifactId>commons-pool2</artifactId>
        </dependency>
        <dependency>
            <groupId>org.apache.commons</groupId>
            <artifactId>commons-lang3</artifactId>
        </dependency>
        <dependency>
            <groupId>javax.servlet</groupId>
            <artifactId>javax.servlet-api</artifactId>
            <scope>provided</scope>
        </dependency>

        <dependency>
            <groupId>org.apache.httpcomponents</groupId>
            <artifactId>httpclient</artifactId>
        </dependency>
        <dependency>
            <groupId>org.apache.httpcomponents</groupId>
            <artifactId>httpmime</artifactId>
        </dependency>
        <dependency>
            <groupId>org.apache.httpcomponents</groupId>
            <artifactId>httpasyncclient</artifactId>
        </dependency>

        <dependency>
            <groupId>org.slf4j</groupId>
            <artifactId>jcl-over-slf4j</artifactId>
        </dependency>
        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
        </dependency>
    </dependencies>
</project>
```
---

### 枚举常量


```
package com.tangdi.itoken.common.constants;

public enum HttpStatusConstants {

    BAD_GATEWAY(502,"无法获得响应");

    private Integer status;
    private String message;

    HttpStatusConstants(Integer status, String message) {
        this.status = status;
        this.message = message;
    }

    public Integer getStatus() {
        return status;
    }

    public String getMessage() {
        return message;
    }
}

```

---

### BaseResult---API返回的结构体


```
package com.tangdi.itoken.common.dto;

import lombok.Data;

import java.util.List;

@Data
public class BaseResult {

    private static final String OK_RESULT="ok";
    private static final String OK_SUCCESS="操作成功";
    private static final String NOT_OK_RESULT="not_ok";
    private static final String NOT_OK_SUCCESS="";


    private String result;
    private Object data;
    private String success;
    private Cursor cursor;
    private List<Errors> errors;

    public static BaseResult ok(Object data,Cursor cursor){
        return createResult(OK_RESULT,data,OK_SUCCESS,cursor,null);
    }
    
    public static BaseResult ok(Object data){
        return createResult(OK_RESULT,data,OK_SUCCESS,null,null);
    }

    public static BaseResult ok(Cursor cursor){
        return createResult(OK_RESULT,null,OK_SUCCESS,cursor,null);
    }

    public static BaseResult ok(){
        return createResult(OK_RESULT,null,OK_SUCCESS,null,null);
    }

    public static BaseResult ok(String message){return createResult(OK_RESULT,null,message,null,null);}

    public static BaseResult notOk(List<Errors> errors){
        return createResult(NOT_OK_RESULT,null,NOT_OK_SUCCESS,null,errors);
    }

    public static BaseResult notOk(String message){
        return createResult(NOT_OK_RESULT,null,message,null,null);
    }

    public static BaseResult notOk(){
        return createResult(NOT_OK_RESULT,null,NOT_OK_SUCCESS,null,null);
    }

    private static BaseResult createResult(String result, Object data, String success, Cursor cursor, List<Errors> errors){
        BaseResult baseResult = new BaseResult();
        baseResult.setResult(result);
        baseResult.setData(data);
        baseResult.setSuccess(success);
        baseResult.setCursor(cursor);
        baseResult.setErrors(errors);
        return baseResult;
    }
    @Data
    public static class Cursor{
        private int total;
        private int offset;
        private int limit;

        public Cursor(int total, int offset, int limit) {
            this.total = total;
            this.offset = offset;
            this.limit = limit;
        }
    }

    @Data
    public static class Errors{
        private String field;
        private String message;

        public Errors(String field, String message) {
            this.field = field;
            this.message = message;
        }
    }
}

```

### 通用熔断器


```
package com.tangdi.itoken.common.hystrix;

import com.tangdi.itoken.common.constants.HttpStatusConstants;
import com.tangdi.itoken.common.dto.BaseResult;
import com.tangdi.itoken.common.utils.MapperJacksonUtils;

import java.util.ArrayList;

public class Fallback {

    public static String CommonFallback(){
        ArrayList<BaseResult.Errors> errors = new ArrayList<>();
        errors.add(new BaseResult.Errors(String.valueOf(HttpStatusConstants.BAD_GATEWAY.getStatus()),HttpStatusConstants.BAD_GATEWAY.getMessage()));
        BaseResult baseResult = BaseResult.notOk(errors);
        try {
            return MapperJacksonUtils.obj2json(baseResult);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}

```

---


### 工具类自行添加







