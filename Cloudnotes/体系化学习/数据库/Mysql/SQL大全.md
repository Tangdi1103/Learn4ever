select * from a,b where a.id=b.id ;

select * from a left join b on a.id=b.id ;

以上两句有什么区别么？好像没任何区别，不知道left join 和from两个表到底有什么区别？



一个是普通的联接，根据条件分别在两个表中取出数据拼在一起

一个是左外联接，结果中的记录在A表中存在，B表中不一定有。相当于a表为主体表，根据条件将B表连接到A表右侧


#### 1. 强制使用索引

```
EXPLAIN SELECT COUNT(id)   FROM temp_orders force index (PRIMARY)；
```

#### 2. 使用大小写敏感


```
"select * from csmbp_insurance_group where BINARY insurance_type1 = ? AND BINARY insurance_type2 = ?"
```

#### 3. 函数

- **随机生成三位数姓名**

  ```sql
  drop function if exists genLName;
  delimiter $ 
  create function genLName() returns varchar(300)
  begin
      declare dateStr varchar(300) character set utf8 ;   
      select concat(substring('赵钱孙李周吴郑王冯陈诸卫蒋沈韩杨朱秦尤许何吕施张孔曹严华金魏陶姜戚谢邹喻柏水窦章云苏潘葛奚范彭郎鲁韦昌马苗凤花方俞任袁柳酆鲍史唐费廉岑薛雷贺倪汤滕殷罗毕郝邬安常乐于时傅皮齐康伍余元卜顾孟平黄和穆萧尹姚邵堪汪祁毛禹狄米贝明臧计伏成戴谈宋茅庞熊纪舒屈项祝董粱杜阮蓝闵席季麻强贾路娄危江童颜郭梅盛林刁钟徐邱骆高夏蔡田樊胡凌霍虞万支柯咎管卢莫经房裘干解应宗丁宣贲邓郁单杭洪包诸左石崔吉钮龚',floor(1+190*rand()),1),substring('明国华建文平志伟东海强晓生光林小民永杰军金健一忠洪江福祥中正振勇耀春大宁亮宇兴宝少剑云学仁涛瑞飞鹏安亚泽世汉达卫利胜敏群波成荣新峰刚家龙德庆斌辉良玉俊立浩天宏子松克清长嘉红山贤阳乐锋智青跃元武广思雄锦威启昌铭维义宗英凯鸿森超坚旭政传康继翔栋仲权奇礼楠炜友年震鑫雷兵万星骏伦绍麟雨行才希彦兆贵源有景升惠臣慧开章润高佳虎根远力进泉茂毅富博霖顺信凡豪树和恩向道川彬柏磊敬书鸣芳培全炳基冠晖京欣廷哲保秋君劲轩帆若连勋祖锡吉崇钧田石奕发洲彪钢运伯满庭申湘皓承梓雪孟其潮冰怀鲁裕翰征谦航士尧标洁城寿枫革纯风化逸腾岳银鹤琳显焕来心凤睿勤延凌昊西羽百捷定琦圣佩麒虹如靖日咏会久昕黎桂玮燕可越彤雁孝宪萌颖艺夏桐月瑜沛诚夫声冬奎扬双坤镇楚水铁喜之迪泰方同滨邦先聪朝善非恒晋汝丹为晨乃秀岩辰洋然厚灿卓杨钰兰怡灵淇美琪亦晶舒菁真涵爽雅爱依静棋宜男蔚芝菲露娜珊雯淑曼萍珠诗璇琴素梅玲蕾艳紫珍丽仪梦倩伊茜妍碧芬儿岚婷菊妮媛莲娟一',floor(1+400*rand()),1),substring('明国华建文平志伟东海强晓生光林小民永杰军金健一忠洪江福祥中正振勇耀春大宁亮宇兴宝少剑云学仁涛瑞飞鹏安亚泽世汉达卫利胜敏群波成荣新峰刚家龙德庆斌辉良玉俊立浩天宏子松克清长嘉红山贤阳乐锋智青跃元武广思雄锦威启昌铭维义宗英凯鸿森超坚旭政传康继翔栋仲权奇礼楠炜友年震鑫雷兵万星骏伦绍麟雨行才希彦兆贵源有景升惠臣慧开章润高佳虎根远力进泉茂毅富博霖顺信凡豪树和恩向道川彬柏磊敬书鸣芳培全炳基冠晖京欣廷哲保秋君劲轩帆若连勋祖锡吉崇钧田石奕发洲彪钢运伯满庭申湘皓承梓雪孟其潮冰怀鲁裕翰征谦航士尧标洁城寿枫革纯风化逸腾岳银鹤琳显焕来心凤睿勤延凌昊西羽百捷定琦圣佩麒虹如靖日咏会久昕黎桂玮燕可越彤雁孝宪萌颖艺夏桐月瑜沛诚夫声冬奎扬双坤镇楚水铁喜之迪泰方同滨邦先聪朝善非恒晋汝丹为晨乃秀岩辰洋然厚灿卓杨钰兰怡灵淇美琪亦晶舒菁真涵爽雅爱依静棋宜男蔚芝菲露娜珊雯淑曼萍珠诗璇琴素梅玲蕾艳紫珍丽仪梦倩伊茜妍碧芬儿岚婷菊妮媛莲娟一',floor(1+400*rand()),1))  into dateStr;
      return dateStr;
  end $
  delimiter;
  ```

- **随机生成2或3位数姓名**

  ```sql
  drop function if exists genName;
  delimiter $ 
  create function genName() returns varchar(300)
  begin
      declare dateStr varchar(300) character set utf8 ;   
      select concat(substring('赵钱孙李周吴郑王冯陈诸卫蒋沈韩杨朱秦尤许何吕施张孔曹严华金魏陶姜戚谢邹喻柏水窦章云苏潘葛奚范彭郎鲁韦昌马苗凤花方俞任袁柳酆鲍史唐费廉岑薛雷贺倪汤滕殷罗毕郝邬安常乐于时傅皮齐康伍余元卜顾孟平黄和穆萧尹姚邵堪汪祁毛禹狄米贝明臧计伏成戴谈宋茅庞熊纪舒屈项祝董粱杜阮蓝闵席季麻强贾路娄危江童颜郭梅盛林刁钟徐邱骆高夏蔡田樊胡凌霍虞万支柯咎管卢莫经房裘干解应宗丁宣贲邓郁单杭洪包诸左石崔吉钮龚',floor(1+190*rand()),1),substring('明国华建文平志伟东海强晓生光林小民永杰军金健一忠洪江福祥中正振勇耀春大宁亮宇兴宝少剑云学仁涛瑞飞鹏安亚泽世汉达卫利胜敏群波成荣新峰刚家龙德庆斌辉良玉俊立浩天宏子松克清长嘉红山贤阳乐锋智青跃元武广思雄锦威启昌铭维义宗英凯鸿森超坚旭政传康继翔栋仲权奇礼楠炜友年震鑫雷兵万星骏伦绍麟雨行才希彦兆贵源有景升惠臣慧开章润高佳虎根远力进泉茂毅富博霖顺信凡豪树和恩向道川彬柏磊敬书鸣芳培全炳基冠晖京欣廷哲保秋君劲轩帆若连勋祖锡吉崇钧田石奕发洲彪钢运伯满庭申湘皓承梓雪孟其潮冰怀鲁裕翰征谦航士尧标洁城寿枫革纯风化逸腾岳银鹤琳显焕来心凤睿勤延凌昊西羽百捷定琦圣佩麒虹如靖日咏会久昕黎桂玮燕可越彤雁孝宪萌颖艺夏桐月瑜沛诚夫声冬奎扬双坤镇楚水铁喜之迪泰方同滨邦先聪朝善非恒晋汝丹为晨乃秀岩辰洋然厚灿卓杨钰兰怡灵淇美琪亦晶舒菁真涵爽雅爱依静棋宜男蔚芝菲露娜珊雯淑曼萍珠诗璇琴素梅玲蕾艳紫珍丽仪梦倩伊茜妍碧芬儿岚婷菊妮媛莲娟一',floor(1+400*rand()),rand()*10>5),substring('明国华建文平志伟东海强晓生光林小民永杰军金健一忠洪江福祥中正振勇耀春大宁亮宇兴宝少剑云学仁涛瑞飞鹏安亚泽世汉达卫利胜敏群波成荣新峰刚家龙德庆斌辉良玉俊立浩天宏子松克清长嘉红山贤阳乐锋智青跃元武广思雄锦威启昌铭维义宗英凯鸿森超坚旭政传康继翔栋仲权奇礼楠炜友年震鑫雷兵万星骏伦绍麟雨行才希彦兆贵源有景升惠臣慧开章润高佳虎根远力进泉茂毅富博霖顺信凡豪树和恩向道川彬柏磊敬书鸣芳培全炳基冠晖京欣廷哲保秋君劲轩帆若连勋祖锡吉崇钧田石奕发洲彪钢运伯满庭申湘皓承梓雪孟其潮冰怀鲁裕翰征谦航士尧标洁城寿枫革纯风化逸腾岳银鹤琳显焕来心凤睿勤延凌昊西羽百捷定琦圣佩麒虹如靖日咏会久昕黎桂玮燕可越彤雁孝宪萌颖艺夏桐月瑜沛诚夫声冬奎扬双坤镇楚水铁喜之迪泰方同滨邦先聪朝善非恒晋汝丹为晨乃秀岩辰洋然厚灿卓杨钰兰怡灵淇美琪亦晶舒菁真涵爽雅爱依静棋宜男蔚芝菲露娜珊雯淑曼萍珠诗璇琴素梅玲蕾艳紫珍丽仪梦倩伊茜妍碧芬儿岚婷菊妮媛莲娟一',floor(1+400*rand()),1)) as name    into dateStr;
      return dateStr;
  end $
  delimiter;
  ```

- **随机生成手机号**

  ```sql
  drop function if exists genMobile;
  delimiter $ 
  create function genMobile() returns varchar(11)
  begin
  	declare dateStr varchar(11);	
  	select  concat('1',ceiling(rand()*9000000000+1000000000)) into dateStr;		
  	return dateStr;
  end $
  delimiter ;
  
  ```

- **随机生成时间**

  ```sql
  drop function if exists getDateTime;
  delimiter $ 
  create function getDateTime(startDate varchar(10),endDate varchar(10)) returns varchar(20)
  begin
  	declare dateStr varchar(20);	
  	select from_unixtime(
          unix_timestamp(startDate) + floor(
              rand() * (
                  unix_timestamp(endDate) - unix_timestamp(startDate) + 1
              )
          )
      ) into dateStr;    
      return dateStr;
  end $
  delimiter ;
  ```

- **随机生成日期**

  ```sql
  drop function if exists getDateStr;
  delimiter $ 
  create function getDateStr(startDate varchar(10),endDate varchar(10)) returns varchar(10)
  begin 
  	declare dateStr varchar(10);	
  	select date(from_unixtime(
  		 unix_timestamp(startDate) 
  		 + floor(
  		   rand() * ( unix_timestamp(endDate) - unix_timestamp(startDate) + 1 )
  		 )
  		)) into dateStr;		
  	 return dateStr;
  end $
  delimiter ;
  ```

#### 4. 存储过程

```sql
CREATE DEFINER=`root`@`%` PROCEDURE `update_demo`(IN count INTEGER)
BEGIN
    declare var int;
    set var=0;  
    while var<count do  
        UPDATE demo set value=value+1 where id=1;
        set var=var+1;  
    end while;  
END



CREATE DEFINER=`root`@`%` PROCEDURE `insert_student`(in count INTEGER)
BEGIN
	DECLARE id INTEGER DEFAULT 1;
	WHILE id<=count DO
		INSERT INTO student VALUES(id, genName(), FLOOR(RAND()*100)+1, FLOOR(RAND()*2));
		SET id=id+1;
	END WHILE;
END


//执行存储过程
CALL insert_student();
CALL update_demo(200);
```

#### 5. 基操

```
insert into tableName value(1,2,3);

update tableName set aaa = "1" where bbb = "2";

delete from tableName where aaa="111";
```

#### 6. 修改表结构

```sql
-- 新增字段
ALTER TABLE table_name ADD COLUMN test VARCHAR(32) NOT NULL DEFAULT '123' COMMENT '测试';

-- 修改test字段属性
ALTER TABLE table_name MODIFY COLUMN test VARCHAR(32) NOT NULL DEFAULT '123' COMMENT '测试2';

-- 修改test字段名称为test1及属性
ALTER TABLE table_name CHANGE COLUMN test test1 VARCHAR(32) NOT NULL DEFAULT '123' COMMENT '测试';

-- 新增普通索引
ALTER TABLE table_name ADD INDEX index_name (COLUMN);

-- 新增唯一索引
ALTER TABLE tablename ADD UNIQUE INDEX index_name (COLUMN);

-- 删除索引
ALTER TABLE table_name DROP INDEX index_name;

-- 删除字段
ALTER TABLE table_name DROP COLUMN index_name;

-- id自增重新从276开始
ALTER TABLE kd_device auto_increment = 276;
```

#### 7. 通过表注释来查找表名

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


#### 8. 通过字段注释来查找表名

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

#### 9. 通过字段来查找表名

```sql
SELECT table_name 表名,TABLE_COMMENT '表注解' FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = '要查找的字段名称';
```

#### 10. 导出数据库文档

```sql
SELECTTABLE_NAME 表名,COLUMN_NAME 列名,COLUMN_COMMENT 注释,COLUMN_TYPE 数据类型,IF(IS_NULLABLE='NO','是','否') AS '是否必填'FROMinformation_schema.`COLUMNS`WHERETABLE_SCHEMA='database_name'//数据库名称AND table_name like 't_fms%'//表名称
```

#### 11. 授权

```
1)授权命令 grant,语法格式(SQL语句不区分大小写):Grant  <权限>  on  表名[(列名)]  to  用户 With  grant  option或 GRANT <权限> ON <数据对象> FROM <数据库用户>  //数据对象可以是表名或列名//权限表示对表的操作，如select,update,insert,delete表:grant select on sync_mode.FSS_EBANK_INSTRUCT to vdmuser模式grant all on schema sync_mode to vdmuser
```

#### 12. 回收

```
2)回收权限 revokeREVOKE <权限> ON <数据对象>  FROM <数据库用户名>
```

#### 13. 查询/删除重复数据

```sql
-- 查询重复数据
SELECT
	T1.COUNT,
	T2.* 
FROM
	( SELECT COUNT( device_id ) AS COUNT, device_id FROM kd_device_test GROUP BY device_id HAVING COUNT > 1 ) AS T1,
	kd_device_test AS T2 
WHERE
	T1.device_id = T2.device_id;


-- 使用DELETE JOIN删除重复行
DELETE 
	t1 
FROM
	kd_device_test t1
INNER JOIN 
	kd_device_test t2 
WHERE
	t1.id < t2.id 
	AND t1.device_id = t2.device_id;


-- 使用ROW_NUMBER()删除重复行
WITH dups AS (SELECT 
    id,
    device_id,
    ROW_NUMBER() OVER (PARTITION BY device_id ORDER BY id) AS row_num
FROM kd_device_test)
DELETE kd_device_test FROM kd_device_test INNER JOIN dups ON kd_device_test.id = dups.id
WHERE dups.row_num <> 1; 
```

