select * from a,b where a.id=b.id ;

select * from a left join b on a.id=b.id ;

以上两句有什么区别么？好像没任何区别，不知道left join 和from两个表到底有什么区别？



一个是普通的联接，根据条件分别在两个表中取出数据拼在一起

一个是左外联接，结果中的记录在A表中存在，B表中不一定有。相当于a表为主体表，根据条件将B表连接到A表右侧


##### 在查询的时候指定查询使用哪个索引。

```
EXPLAIN SELECT COUNT(id)   FROM temp_orders force index (PRIMARY)；
```

##### 查询区分大小写


```
"select * from csmbp_insurance_group where BINARY insurance_type1 = ? AND BINARY insurance_type2 = ?"

```

##### 使用存储过程插入数据

```sql
DELIMITER ;;
CREATE PROCEDURE insert_student()
    BEGIN
	    DECLARE id INTEGER DEFAULT 112;
	    WHILE id<=10000000 DO
	    INSERT INTO student VALUES(id, CONCAT('name',id), RAND(100), RAND(1),date_sub(NOW(), interval id second));
	    SET id=id+1;
	    END WHILE;
    END ;;
DELIMITER ;

//执行存储过程
CALL insert_student();
```


##### 基操
```
insert into tableName value(1,2,3);

update tableName set aaa = "1" where bbb = "2";

delete from tableName where aaa="111";
```

##### MySQL中通过表注释来查找表名
```sql
SELECT
	table_name 表名,
	TABLE_COMMENT 表注释
FROM
	INFORMATION_SCHEMA. TABLES
WHERE
	table_schema = '数据库名'
AND TABLE_COMMENT LIKE '%注解%';
```


##### MySQL中通过字段注释来查找表名
```sql
SELECT
	table_name 表名,
	COLUMN_NAME 字段名,
	COLUMN_COMMENT 字段注释
FROM
	INFORMATION_SCHEMA. COLUMNS
WHERE
	table_schema = '数据库名'
AND COLUMN_COMMENT LIKE '%注解%';
```

##### MySQL中通过字段来查找表名
```sql
SELECT table_name 表名,TABLE_COMMENT '表注解' FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = '要查找的字段名称';
```

##### 导出数据库文档

```sql
SELECT
TABLE_NAME 表名,
COLUMN_NAME 列名,
COLUMN_COMMENT 注释,
COLUMN_TYPE 数据类型,
IF(IS_NULLABLE='NO','是','否') AS '是否必填'
FROM
information_schema.`COLUMNS`
WHERE
TABLE_SCHEMA='database_name'//数据库名称
AND 
table_name like 't_fms%'//表名称
```

##### 授权

```
1)授权命令 grant,语法格式(SQL语句不区分大小写):
Grant  <权限>  on  表名[(列名)]  to  用户 With  grant  option

或 GRANT <权限> ON <数据对象> FROM <数据库用户>  

//数据对象可以是表名或列名

//权限表示对表的操作，如select,update,insert,delete

表:
grant select on sync_mode.FSS_EBANK_INSTRUCT to vdmuser

模式
grant all on schema sync_mode to vdmuser
```
##### 回收

```
2)回收权限 revoke
REVOKE <权限> ON <数据对象>  FROM <数据库用户名>
```
