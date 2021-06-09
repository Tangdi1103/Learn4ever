### Solr分词

分词技术就是搜索引擎针对用户提交查询的关键词串进行的查询查理后根据用户的关键词串用各种匹配方法进行分词的一种技术。---将一句话分成几个关键词

### IKAnalyzer简介

IKAnalyzer是一个开源的，基于Java语言开发的轻量级的中文分词工具包。

### 部署Solr并安装IKAnalyzer

创建/usr/local/docker/solr/ikanalyzer目录：

- /usr/local/docker/solr:用于存放docker-compose.yml配置文件
- /usr/local/docker/solr/ikanalyzer:用于存放Dockerfile镜像配置文件

##### Dockerfile配置---放于ikanalyzer目录下


```
FROM solr

# 创建Core
WORKDIR /opt/solr/server/solr

RUN mkdir ik_core

WORKDIR /opt/solr/server/solr/ik_core

RUN echo 'name=ik_core' > core.properties

RUN mkdir data

RUN cp -r ../configsets/sample_techproducts_configs/conf/ .


# 安装中文分词
WORKDIR /opt/solr/server/solr-webapp/webapp/WEB-INF/lib

ADD ik-analyzer-solr5-5.x.jar .

ADD solr-analyzer-ik-5.1.0.jar .

WORKDIR /opt/solr/server/solr-webapp/webapp/WEB-INF

ADD ext.dic .

ADD stopword.dic .

ADD IKAnalyzer.cfg.xml .

#增加分词配置

COPY managed-schema /opt/solr/server/solr/ik_core/conf

WORKDIR /opt/solr
```

##### 将ikanalyzer-solr5.zip传输到ikanalyzer下，并解压


##### docker-compose配置---放于solr目录下
```
version: '3.1'
services:
  solr:
    image: ikanalyzer
    restart: always
    container_name: solr
    ports:
      - 8983:8983
    volumes:
      - /usr/local/docker/solr/solrdata:/opt/solrdata
```

##### 进入分词容器，修改managed-schema配置，配置字段域

```
<!-- 自定义字段域 -->
<field name="article_title" type="text_ik" indexed="true" stored="true" /> 
<field name="article_source" type="text_ik" indexed="true" stored="true" /> 
<field name="article_introduction" type="text_ik" indexed="true" stored="true" /> 
<field name="article_url" type="string" indexed="false" stored="true" /> 
<field name="article_cover" type="string" indexed="false" stored="true" /> 

<!-- 复制字段域 -->
<field name="article_keywords" type="text_ik" indexed="true" stored="false" multiValued="true" /> 
<copyfield source="article_title" dest="article_keywords" /> 
<copyfield source="article_source" dest="article_keywords" /> 
<copyfield source="article_introduction" dest="article_keywords" /> 
```
修改完后，拷贝到容器内

```
docker cp managed-schema solr:/opt/solr/server/solr/ik_core/conf
```

##### 安装完之后，访问solr的地址和端口，在ik_core中可以对solr进行修改、查询和删除

##### 查询说明：

- q: 查询跳进，*:*为查询所有域，单独查询某个域如：article_title:h1z1
- fq: 过滤条件
- sort: 排序条件
- start,rows: 分页条件
- fl：字段列表返回域，如只希望返回id
- df：默认搜索域，如之前配置的复制域article_keywords

##### 高亮显示

hl.fl: article_title---搜索字段高亮

hl.simple.pre: 
```
<span style='color:red;'>
```

hl.simple.post: 
```
</span>
```



