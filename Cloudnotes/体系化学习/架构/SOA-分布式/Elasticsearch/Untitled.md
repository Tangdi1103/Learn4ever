分库分表后的多维度复杂查询，可以使用ES搜索引擎来完成，如按uid分库的订单表需要用商户id查询、分页查询等多维度的复杂查询查询



数据同步措施：

采用 Canal 中间件同步binlog，然后通过异步方式将数据同步至 ES

![image-20220224210600904](images/image-20220224210600904.png)

![image-20220224210640047](images/image-20220224210640047.png)

- 数据库表结构

  ![image-20220224210707100](images/image-20220224210707100.png)

- ES文档结构

  ![image-20220224211003643](images/image-20220224211003643.png)

- ES深翻页查询

  ```sql
  select col.. from table where id >= lastMaxId order by id limit pageSize
  ```

  