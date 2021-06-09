### 创建pom.xml

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

    <artifactId>itoken-common-domain</artifactId>
    <packaging>jar</packaging>

    <dependencies>
        <dependency>
            <groupId>com.tangdi</groupId>
            <artifactId>itoken-common</artifactId>
            <version>${project.parent.version}</version>
        </dependency>
        <dependency>
            <groupId>javax.persistence</groupId>
            <artifactId>persistence-api</artifactId>
            <version>1.0</version>
        </dependency>
    </dependencies>
</project>
```
---

### 创建实体类和基类

##### 将==iotken-common-service==中生成的实体类剪切到==com.tangdi.itoken.common.domain==目录下

如有共同属性，创建基类，如：

###### 将实体类中的共同属性及get/set方法删除并继承基类


```
import lombok.Getter;
import lombok.Setter;

import javax.persistence.Column;
import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;

@Getter
@Setter
public class BaseDomain implements Serializable{
    /**
     * 创建者
     */
    @Column(name = "create_by")
    private String createBy;

    /**
     * 创建时间
     */
    @Column(name = "create_date")
    private Date createDate;

    /**
     * 更新者
     */
    @Column(name = "update_by")
    private String updateBy;

    /**
     * 更新时间
     */
    @Column(name = "update_date")
    private Date updateDate;

    /**
     * 备注信息
     */
    private String remarks;

    /**
     * 扩展 String 1
     */
    @Column(name = "extend_s1")
    private String extendS1;

    /**
     * 扩展 String 2
     */
    @Column(name = "extend_s2")
    private String extendS2;

    /**
     * 扩展 String 3
     */
    @Column(name = "extend_s3")
    private String extendS3;

    /**
     * 扩展 String 4
     */
    @Column(name = "extend_s4")
    private String extendS4;

    /**
     * 扩展 String 5
     */
    @Column(name = "extend_s5")
    private String extendS5;

    /**
     * 扩展 String 6
     */
    @Column(name = "extend_s6")
    private String extendS6;

    /**
     * 扩展 String 7
     */
    @Column(name = "extend_s7")
    private String extendS7;

    /**
     * 扩展 String 8
     */
    @Column(name = "extend_s8")
    private String extendS8;

    /**
     * 扩展 Integer 1
     */
    @Column(name = "extend_i1")
    private BigDecimal extendI1;

    /**
     * 扩展 Integer 2
     */
    @Column(name = "extend_i2")
    private BigDecimal extendI2;

    /**
     * 扩展 Integer 3
     */
    @Column(name = "extend_i3")
    private BigDecimal extendI3;

    /**
     * 扩展 Integer 4
     */
    @Column(name = "extend_i4")
    private BigDecimal extendI4;

    /**
     * 扩展 Float 1
     */
    @Column(name = "extend_f1")
    private BigDecimal extendF1;

    /**
     * 扩展 Float 2
     */
    @Column(name = "extend_f2")
    private BigDecimal extendF2;

    /**
     * 扩展 Float 3
     */
    @Column(name = "extend_f3")
    private BigDecimal extendF3;

    /**
     * 扩展 Float 4
     */
    @Column(name = "extend_f4")
    private BigDecimal extendF4;

    /**
     * 扩展 Date 1
     */
    @Column(name = "extend_d1")
    private Date extendD1;

    /**
     * 扩展 Date 2
     */
    @Column(name = "extend_d2")
    private Date extendD2;

    /**
     * 扩展 Date 3
     */
    @Column(name = "extend_d3")
    private Date extendD3;

    /**
     * 扩展 Date 4
     */
    @Column(name = "extend_d4")
    private Date extendD4;
}

```





































