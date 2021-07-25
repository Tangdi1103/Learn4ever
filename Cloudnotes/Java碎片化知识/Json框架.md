#### FastJson（安全漏洞以及bug较多，不推荐）

###### 不推荐原因
- 序列化时各种丢失（属性名不规范，如_开头、uId等），FastJson通过getter方法寻找属性
- 很多代码写死，如处理Spring框架时通过反射寻找Spring类、ASM字节码织入、getter方法名
- 解析json主要使用String的subString方法，JDK1.7之前subString不会创建新对象，解析json很大容易导致内存泄漏；JDK1.7以后subString方法会创建行的对象，FastJson快的优势不复存在

1.json转Bean

```
ActivityResult a = JSON.parseArray(jsonData, ActivityResult.class);
```


2.json转List

```
List<ActivityResult> list = JSON.parseArray(jsonData, ActivityResult.class);

或者

JSONArray jsonArray = JSONArray.fromObject(paramStr);
List<SeatInput> inputs = (List<SeatInput>)JSONArray.toCollection(jsonArray, SeatInput.class);
```

3.bean转json，设置序列化属性


```
JSONObject.toJSONString(Object object, SerializerFeature… features)

//Fastjson的SerializerFeature序列化属性
//QuoteFieldNames————输出key时是否使用双引号,默认为true
//WriteMapNullValue————是否输出值为null的字段,默认为false
//WriteNullNumberAsZero————数值字段如果为null,输出为0,而非null
//WriteNullListAsEmpty————List字段如果为null,输出为[],而非null
//WriteNullStringAsEmpty————字符类型字段如果为null,输出为”“,而非null
//WriteNullBooleanAsFalse————Boolean字段如果为null,输出为false,而非nul
```

4.指定属性名

```
@JSONField(name= "uId")
```

#### JackJson

###### 使用JackJson需先初始化，提升性能

```
static {
    // 对于空的对象转json的时候不抛出错误
    mapper.disable(SerializationFeature.FAIL_ON_EMPTY_BEANS);
    // 允许属性名称没有引号
    mapper.configure(JsonParser.Feature.ALLOW_UNQUOTED_FIELD_NAMES, true);
    // 允许单引号
    mapper.configure(JsonParser.Feature.ALLOW_SINGLE_QUOTES, true);
    // 设置输入时忽略在json字符串中存在但在java对象实际没有的属性
    mapper.disable(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES);
    // 设置输出时包含属性的风格
    mapper.setSerializationInclusion(JsonInclude.Include.NON_NULL);
    //空值转换-异常情况处理	
	mapper.configure(DeserializationFeature.ACCEPT_EMPTY_STRING_AS_NULL_OBJECT, true) ; 
	//转义字符-异常情况处理
	mapper.configure(Feature.ALLOW_UNQUOTED_CONTROL_CHARS, true) ; 
}
```

1.json转Bean

```
ObjectMapper objectMapper = new ObjectMapper();
objectMapper.setSerializationInclusion(JsonInclude.Include.NON_NULL);
objectMapper.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);
Study s1 = objectMapper.readValue(json4, new TypeReference<Study>() {});
Study s2 = objectMapper.readValue(json4, Study.class);
```

2.json转List

```
ObjectMapper objectMapper = new ObjectMapper();
objectMapper.setSerializationInclusion(JsonInclude.Include.NON_NULL);
objectMapper.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);
List<Study> list = objectMapper.readValue(json4, new TypeReference<List<Study>>() {});
```

3.bean转json

```
ObjectMapper objectMapper = new ObjectMapper();
objectMapper.setSerializationInclusion(JsonInclude.Include.NON_NULL);
objectMapper.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);
String json2 = objectMapper.writeValueAsString(study);
```

4.注解

```
// 指定属性名
@JsonProperty("Age")

// 序列化时忽略属性
@JsonIgnore

// 该类忽略的属性
@JsonIgnoreProperties({"dete","high"})

// 该类所有属性序列化时首字母大写
@JsonNaming(value = JsonUpFirstCharNamingStrategy.class)

// 日期格式
@JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss:SSS", timezone = "GMT+8")
```
