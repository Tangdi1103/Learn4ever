[toc]
<font size=4>
# 一、一级缓存
1. 作用于SqlSession，SqlSession -> BaseExecutor -> Perpetualcache -> HashMap 
2. 执行查询时，根据statementId和入参组成cacheKey，查询是否有缓存
3. 无缓存则查库，然后写入缓存
4. 一级缓存默认开启，若开启二级缓存，二级缓然优先于一级缓存
5. 一级缓存作用域SqlSession，执行数据库操作时将结果存于HashMap中
6. 增删改时，会清空SqlSession中的缓存
7. 缓存只在autoCommit关闭时生效，在调用commit方法时，先清空缓存，再commit事务


```
Override
public <E> List<E> query(MappedStatement ms, Object parameter, RowBounds
        rowBounds, ResultHandler resultHandler) throws SQLException {
    BoundSql boundSql = ms.getBoundSql(parameter);
    //创建缓存
    CacheKey key = createCacheKey(ms, parameter, rowBounds, boundSql);
    return query(ms, parameter, rowBounds, resultHandler, key, boundSql);
}

@SuppressWarnings("unchecked")
Override
public <E> List<E> query(MappedStatement ms, Object parameter, RowBounds
        rowBounds, ResultHandler resultHandler, CacheKey key, BoundSql boundSql) throws
        SQLException {
            ...
    list = resultHandler == null ? (List<E>) localCache.getObject(key) : null;
    if (list != null) {
        //这个主要是处理存储过程用的。
        handleLocallyCachedOutputParameters(ms, key, parameter, boundSql);
    } else {
        list = queryFromDatabase(ms, parameter, rowBounds, resultHandler, key,
                boundSql);
    }
    ...
}

// queryFromDatabase 方法
private <E> List<E> queryFromDatabase(MappedStatement ms, Object parameter,
                                      RowBounds rowBounds, ResultHandler resultHandler, CacheKey key, BoundSql
                                              boundSql) throws SQLException {
    List<E> list;
    localCache.putObject(key, EXECUTION_PLACEHOLDER);
    try {
        list = doQuery(ms, parameter, rowBounds, resultHandler, boundSql);
    } finally {
        localCache.removeObject(key);
    }
    localCache.putObject(key, list);
    if (ms.getStatementType() == StatementType.CALLABLE) {
        localOutputParameterCache.putObject(key, parameter);
    }
    return list;
}
```


![image](images/10895)




# 二、二级缓存
1. 二级缓存作用域namespace，在解析mapper.xml时生成cacheExecutor封装在各个MeppedStatement对象中，所以同个namespace的所有SqlSession共享同一个缓存对象
2. 解析SqlSessionFactoryBuilder执行解析xml时，若配置了二级缓存则生成建Cache类，封装到对应的MappedStatement
3. 因为MappedStatement的全局性，所有线程共用MappedStatement，可导致脏读，TransactionalCacheManager为二级缓存提供了事务管理
4. Mybatis自带的二级缓存不支持分布式架构，需整合缓存服务来做二级缓存如redis
5. 缓存只在autoCommit关闭时生效，在调用commit方法时，先清空缓存，再commit事务
6. 实现原理：在SqlMapConfiguration和各Mapper.xml中开启二级缓存，在Executor执行查时先查缓存，执行删改操作时清空缓存
    <settings>
       <setting name="cacheEnabled" value="true"/>
    </settings>

![image](https://note.youdao.com/yws/public/resource/c5be5802daf0385d18fbdfde57d959e9/xmlnote/8C405F15866349F5B225D32DE6B7ADB0/10897)
</font>
