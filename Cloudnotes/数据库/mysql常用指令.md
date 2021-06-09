#### 查看某个数据库下每张表的数据量大小


```
USE information_schema;
SELECT table_name,table_rows FROM TABLES WHERE TABLE_SCHEMA = 'mmp' ORDER BY table_rows DESC;
```
