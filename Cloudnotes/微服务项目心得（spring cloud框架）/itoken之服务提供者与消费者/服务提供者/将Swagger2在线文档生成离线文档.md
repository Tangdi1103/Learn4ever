1.根据文章[Spring Boot 配置 Swagger2 接口文档引擎](http://note.youdao.com/noteshare?id=5f76186f644bf33a5d523647a7fee0ad&sub=9D55F15859214AE38F8BB96618094996)已经生成在线Swagger文档


2.添加==io.github.swagger2markup==依赖，及==org.asciidoctor.convert==插件

```
buildscript{
    ext{
        springBootVersion = '2.0.3.RELEASE'
    }
    repositories{
        mavenCentral()
        jcenter()
    }
    dependencies{
        classpath("org.springframework.boot:spring-boot-gradle-plugin:${springBootVersion}")
        classpath 'org.asciidoctor:asciidoctor-gradle-plugin:1.5.8'
    }
}

apply plugin: 'org.asciidoctor.convert'


asciidoctor {
    sourceDir = file('/src/docs/asciidoc')
    sources {
        include 'generated.adoc'
    }
    outputDir = file('/src/docs/asciidoc/html')
    attributes = [
            'source-highlighter': 'coderay',
            toc                 : 'left',
            icons             : 'font',
            sectanchors       : '',
            idprefix            : '',
            idseparator         : '-'
    ]

}
```



3.编写测试类代码，代码如下

```
package com.tinckay;

import io.github.swagger2markup.Swagger2MarkupConfig;
import io.github.swagger2markup.Swagger2MarkupConverter;
import io.github.swagger2markup.builder.Swagger2MarkupConfigBuilder;
import io.github.swagger2markup.markup.builder.MarkupLanguage;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit4.SpringRunner;

import java.net.MalformedURLException;
import java.net.URL;
import java.nio.file.Paths;

@RunWith(SpringRunner.class)
@SpringBootTest(classes = App.class)
public class AppTest {
    @Test
    public void contextLoads() throws MalformedURLException {
        //    输出Ascii格式
        Swagger2MarkupConfig config = new Swagger2MarkupConfigBuilder()
                .withMarkupLanguage(MarkupLanguage.ASCIIDOC)
                .build();

        Swagger2MarkupConverter.from(new URL("http://localhost:23003/v2/api-docs"))
                .withConfig(config)
                .build()
//                .toFolder(Paths.get("src/docs/asciidoc/generated"));
                .toFile(Paths.get("src/docs/asciidoc/generated"));
    }

}

```

- ==MarkupLanguage.ASCIIDOC==：意为指定生成Asciidoc格式的文档
- ==new URL("http://localhost:23003/v2/api-docs"==：指定Swagger.json的URL，URL指向的服务器必须在运行状态，才能获得json
- ==.toFolder(Paths.get("src/docs/asciidoc/generated"))==：指定生成后的文件夹地址（多个文档）
- ==.toFile(Paths.get("src/docs/asciidoc/generated"))==：指定生成后的文件地址（合多为一）


3.运行测试类，在src/docs/asciidoc/generated目录下生成==generated.adoc==

4.在terminal下执行gradle asciidoc命令，在src/docs/asciidoc/html/html5下生成离线html文件














