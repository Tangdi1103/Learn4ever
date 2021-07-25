### 创建线程池类

```
/**
 * @author: Tangdi
 * @date: 17:08 2018/10/30
 * @description:
 * @modify:
 */
@Configuration
@EnableAsync
public class ThreadPoolconfig {

    @Value("${async.thread.corePoolSize}")
    private int corePoolSize;
    @Value("${async.thread.maxPoolSize}")
    private int maxPoolSize;
    @Value("${async.thread.queueCapacity}")
    private int queueCapacity;
    @Value("${async.thread.threadNamePrefix}")
    private String threadNamePrefix;


    private static final Logger logger = LogManager.getLogger(ThreadPoolconfig.class);

    @Bean(name = "oneExecutor")
    public Executor oneExecutor(){
        logger.info("enter Thread");
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.setCorePoolSize(corePoolSize);
        executor.setMaxPoolSize(maxPoolSize);
        executor.setQueueCapacity(queueCapacity);
        executor.setThreadNamePrefix(threadNamePrefix);

        executor.setRejectedExecutionHandler(new ThreadPoolExecutor.CallerRunsPolicy());
        executor.initialize();
        return executor;
    }

}
```

### 创建需异步类

```
/**
 * @author: Tangdi
 * @date: 10:57 2019/8/5
 * @description:
 * @modify:
 */
@Component
public class OneTask {

    private static final Logger logger = LogManager.getLogger(OneTask.class);

    @Async("oneExecutor")  //可指定使用名为oneExecutor的线程池
    public Future<String> one() throws InterruptedException {
        Thread.sleep(6000);//人工超时
        logger.info("我是"+Thread.currentThread().getName());
        return new AsyncResult<>("2333");
    }
}
```

### 创建service

```
/**
 * @author: Tangdi
 * @date: 17:55 2018/10/30
 * @description:
 * @modify:
 */
@Service
public class SoutServiceImpl implements SoutService {

    private static final Logger logger = LogManager.getLogger(SoutServiceImpl.class);
    @Autowired
    OneTask oneTask;

    @Override
    public String sout() throws InterruptedException, ExecutionException, TimeoutException {
        logger.info("进入service");
        //异步业务，会使用oneExecutor线程池执行
        Future<String> one = oneTask.one();
        logger.info("结束service");
        String s = one.get(7, TimeUnit.SECONDS);
        logger.info("回调结果" + s);
        return s;
    }
}

```

### 创建controller

```
/**
 * @author: Tangdi
 * @date: 17:01 2018/10/31
 * @description:
 * @modify:
 */
@RestController
public class TestController {

    private static final Logger logger = LogManager.getLogger(TestController.class);

    @Autowired
    private SoutService soutService;

    @RequestMapping(value = "/index",method = RequestMethod.GET)
    public String sout(){
        logger.info("请求开始");
        String sout = null;
        try {
            sout = soutService.sout();
        } catch (InterruptedException e) {
            logger.error("线程中断",e);
        } catch (ExecutionException e) {
            logger.error("线程异常",e);
        } catch (TimeoutException e) {
            logger.error("超时",e);
        }
        logger.info("请求结束");
        return sout;
    }
}

```

### 执行结果


```
2019-08-05 15:01:38.959  INFO 10504 --- [nio-9001-exec-1] c.e.h.controller.TestController          : 请求开始
2019-08-05 15:01:38.959  INFO 10504 --- [nio-9001-exec-1] c.e.h.service.SoutServiceImpl            : 进入service
2019-08-05 15:01:38.965  INFO 10504 --- [nio-9001-exec-1] c.e.h.service.SoutServiceImpl            : 结束service
2019-08-05 15:01:44.968  INFO 10504 --- [it's-DarkKing-1] c.e.h.service.async.OneTask              : 我是Your-Name-it's-DarkKing-1
2019-08-05 15:01:44.971  INFO 10504 --- [nio-9001-exec-1] c.e.h.service.SoutServiceImpl            : 回调结果2333
2019-08-05 15:01:44.971  INFO 10504 --- [nio-9001-exec-1] c.e.h.controller.TestController          : 请求结束
```
