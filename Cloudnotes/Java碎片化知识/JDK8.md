
#### 函数式接口Function、Consumer、Predicate、Supplier

```
Function<T,R>   接收一个输入参数，返回一个结果
Consumer<T>     接受一个输入参数，无返回结果
Predicate<T>    接受一个输入参数，返回一个布尔值
Supplier<T>     无参数，返回一个结果
```

#### lambda表达式语法

简单例子

```
// 1. 不需要参数,返回值为 5  
() -> 5  
  
// 2. 接收一个参数(数字类型),返回其2倍的值  
x -> 2 * x  
  
// 3. 接受2个参数(数字),并返回他们的差值  
(x, y) -> x – y  
  
// 4. 接收2个int型整数,返回他们的和  
(int x, int y) -> x + y  
  
// 5. 接受一个 string 对象,并在控制台打印,不返回任何值(看起来像是返回void)  
(String s) -> System.out.print(s)  
```


```
        String[] name = {"zs","ls","ww"};
		List<String> names = Arrays.asList(name);
		
		//控制台输出zs,ls,ww
		
		names.forEach((mon) -> System.out.print(mon+","));
		names.forEach(System.out::println);

		Optional<Student> zs = Optional.ofNullable(new Student("zs", 21, 1));
		
		//控制台输出对象是否存在:true---获取对象:Student(name=zs, age=21, sex=1)---对象:Student(name=zs, age=21, sex=1)
		System.out.printf("对象是否存在:%s\n获取对象:%s\n对象:%s\n",zs.isPresent(),zs.get(),zs.orElseGet(() -> new Student("ls",21,1)));
		
		//控制台输出重置对象:Student(name=ww, age=21, sex=1)
		System.out.printf("重置对象:%s\n",zs.map(p -> new Student("ww", 21, 1)).get());
```

#### Sream流

```
    @Before
	public void before() {
		list = Arrays.asList("a","b","c","d","e","c");
		nums = new int[]{17,4,1,20,10,7,1, 26,2,11, 26,8};
	}

	@Test
	public void hi(){
		List<String> list1 = list.stream()
				.map(String::toUpperCase)
				.collect(Collectors.toList());
		System.out.println(list1);
	}

	@Test
	public void so(){
		list = Arrays.asList("3","1","11","17","9","5","13");
		List<String> collect = list.stream()
				.filter(x -> {
					int i = Integer.parseInt(x);
					return i > 5;
				})
				.collect(Collectors.toList());
		System.out.println(collect);
	}
```



