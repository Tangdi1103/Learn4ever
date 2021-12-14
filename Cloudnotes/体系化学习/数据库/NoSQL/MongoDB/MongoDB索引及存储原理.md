[toc]

### 一、MongoDB的索引

#### 1. 索引类型

##### 1.1 单键索引 Single Field

- 普通单键索引

  ```js
  db.集合名.createIndex({"字段名" : 排序方式}) 
  ```

  **注意：**单键索引的排序顺序无关紧要，因为MongoDB可以在任⼀方向读取索引

- TTL（ **Time To Live**）单键索引

  规定时间之后⾃动删除，只能在单字段上建立，并且字段类型必须是**日期类型**

  ```js
  db.集合名.createIndex({"日期字段":排序方式}, {expireAfterSeconds: 秒数})
  ```

- 唯一索引

  ```js
  db.集合.createIndex({name:1},{unique:true})
  ```

  

##### 1.2 复合索引 Compound Index

在多个字段上建立索引，适合多字段条件查询

**注意：**制作复合索引时要注意的重要事项包括：字段顺序与索引方向。

```js
db.集合名.createIndex( { "字段名1" : 排序方式, "字段名2" : 排序方式 } )
```



##### 1.3 多健索引

针对属性包含数组数据的情况，对数组中每⼀个element创建索引，Multikey indexes支持Strings，Numbers和Nested Documents



##### 1.4 地理空间索引 Geospatial Index

针对地理空间坐标数据创建索引

创建地理空间索引：`db.company.ensureIndex({loc : "2dsphere"})`

- 2dsphere索引，用于存储和查找球面上的点

- 2d索引，用于存储和查找平面上的点

**2dsphere测试**

```js
db.company.insert(
   {
     loc : { type: "Point", coordinates: [ 116.482451, 39.914176 ] },
     name: "大望路地铁",
     category : "Parks"
   }
)

db.company.insert(
   {
     loc : { type: "Point", coordinates: [ 116.492451, 39.934176 ] },
     name: "test1",
     category : "Parks"
   }
)

db.company.insert(
   {
     loc : { type: "Point", coordinates: [ 116.462451, 39.954176 ] },
     name: "test2",
     category : "Parks"
   }
)


db.company.insert(
   {
     loc : { type: "Point", coordinates: [ 116.562451, 38.954176 ] },
     name: "test3",
     category : "Parks"
   }
)

db.company.insert(
   {
     loc : { type: "Point", coordinates: [ 117.562451, 37.954176 ] },
     name: "test4",
     category : "Parks"
   }
)

db.company.ensureIndex( { loc : "2dsphere" } )
db.company.find({
    "loc" : { 
        "$geoWithin" : {
          "$center":[[116.482451,39.914176],0.05] 
        }
    }
})

/** 计算中心点最近的三个点 */
db.company.aggregate([
   {
     $geoNear: {
        near: { type: "Point", coordinates: [116.482451,39.914176 ] },
        key: "loc",
        distanceField: "dist.calculated"
     }
   },
   { $limit: 3 }
])
```

**2d测试**

```js
/** 2d 测试  */
db.places.drop()
db.places.insert({"name": "Temple1","tile": [32, 22]})
db.places.insert({"name": "Temple2","tile": [30, 22]})
db.places.insert({"name": "Temple3","tile": [28, 21]})
db.places.insert({"name": "Temple4","tile": [34, 27]})
db.places.insert({"name": "Temple5","tile": [34, 26]})
db.places.insert({"name": "Temple6","tile": [39, 28]})

db.places.find({})
 
db.places.ensureIndex({"tile" : "2d"}, {"min" : -90, "max" : 90, "bits" : 20}) 
 
db.places.find({"tile": {"$within": {"$box": [[0, 0], [30, 30]]}}})
```



##### 1.5 全文索引/倒排索引

针对 String 内容的文本查询，Text Index支持任意属性值为 String 或String 数组元素的索引查询

**注意：**一个集合仅支持最多⼀个Text Index，中文分词不理想，推荐ES

```js
db.textTextIndex.createIndex({description:"text"});

db.textTextIndex.find({"$text": {"$search": "two"}});
```



##### 1.6 哈希索引

针对属性的哈希值进⾏索引查询，当要使⽤Hashed index时，MongoDB能够⾃动的计算hash值，⽆需程序计算hash值。注：hash index仅⽀持等于查询，不⽀持范围查询。

```js
db.集合.createIndex({"字段": "hashed"})
```



#### 2. 索引管理与执行计划

##### 2.1 索引管理

- 创建索引并在后台运行

  ```js
  db.COLLECTION_NAME.createIndex({"字段":排序方式}, {background: true});
  ```

- 获取针对某个集合的索引

  ```js
  db.COLLECTION_NAME.getIndexes()
  ```

- 索引的大小

  ```js
  db.COLLECTION_NAME.totalIndexSize()
  ```

- 索引的重建

  ```js
  db.COLLECTION_NAME.reIndex()
  ```

- 索引的删除

  ```js
  db.COLLECTION_NAME.dropIndex("INDEX-NAME")
  db.COLLECTION_NAME.dropIndexes()
  注意: _id 对应的索引是删除不了的
  ```



##### 2.2 执行计划

explain()也接收不同的参数，通过设置不同参数我们可以查看更详细的查询计划

- **queryPlanner：**queryPlanner是默认参数，具体执行计划信息参考下⾯的表格
  - namespace：要查询的集合（该值返回的是该query所查询的表）数据库.集合
  - winningPlan.stage被选中执⾏计划的stage(查询方式)
    - COLLSCAN/全表扫描
    - IXSCAN/索引扫描：（是IndexScan，这就说明我们已经命中索引了）
    - FETCH/根据索引去检索文档
    - SHARD_MERGE/合并分片结果
    - IDHACK/针对_id进行查询等
- executionStats：executionStats会返回执行计划的⼀些统计信息(有些版本中和allPlansExecution等同)
- **allPlansExecution：**allPlansExecution用来获取所有执行计划，结果参数基本与上⽂相同。





### 二、 MongoDB存储引擎及原理





1、 索引原理（为什么这么快）





2、 存储引擎原理（为什么这么快）





3、 怎么保证数据不丢失





4、 高可用集群





5、 实战





6、安装认证，监控，备份恢复