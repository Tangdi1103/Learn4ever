```java
// 创建线程池
ExecutorService executor = Executors.newFixedThreadPool(3);
// 异步向电商 S1 询价
Future<Integer> f1 =  executor.submit( ()->getPriceByS1());
// 异步向电商 S2 询价
Future<Integer> f2 =  executor.submit( ()->getPriceByS2());
// 异步向电商 S3 询价
Future<Integer> f3 =  executor.submit( ()->getPriceByS3());
    
// 获取电商 S1 报价并保存
r=f1.get();
executor.execute(()->save(r));
  
// 获取电商 S2 报价并保存
r=f2.get();
executor.execute(()->save(r));
  
// 获取电商 S3 报价并保存  
r=f3.get();
executor.execute(()->save(r));


/*********************减少运行耗时***********************/
// 创建阻塞队列
BlockingQueue<Integer> bq = new LinkedBlockingQueue<>();
// 电商 S1 报价异步进入阻塞队列  
executor.execute(()-> bq.put(f1.get()));
// 电商 S2 报价异步进入阻塞队列  
executor.execute(()-> bq.put(f2.get()));
// 电商 S3 报价异步进入阻塞队列  
executor.execute(()-> bq.put(f3.get()));
// 异步保存所有报价  
for (int i=0; i<3; i++) {
  Integer r = bq.take();
  executor.execute(()->save(r));
} 
/*********************减少运行耗时***********************/
```





当需要批量提交异步任务的时候建议你使用 CompletionService。CompletionService 将线程池 Executor 和阻塞队列 BlockingQueue 的功能融合在了一起，能够让批量异步任务的管理更简单。除此之外，CompletionService 能够让异步任务的执行结果有序化，先执行完的先进入阻塞队列，利用这个特性，你可以轻松实现后续处理的有序性，避免无谓的等待，同时还可以快速实现诸如 Forking Cluster 这样的需求。

CompletionService 的实现类 ExecutorCompletionService，需要你自己创建线程池，虽看上去有些啰嗦，但好处是你可以让多个 ExecutorCompletionService 的线程池隔离，**线程隔离可以避免几个特别耗时的任务拖垮整个应用的风险**。

```java
public static void main(String[] args) throws Exception {
        // 创建线程池
        ExecutorService executor = Executors.newFixedThreadPool(3);
        // 创建 CompletionService
        CompletionService<Integer> cs = new ExecutorCompletionService<>(executor);
        // 异步向电商 S1 询价
        cs.submit(()->{
            try {
                System.out.println(Thread.currentThread() + " s1 do something....");
                Thread.sleep(12000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            System.out.println("s1 任务完成");
            return 1;
        });
        // 异步向电商 S2 询价
        cs.submit(()->{
            try {
                System.out.println(Thread.currentThread() + " s2 do something....");
                Thread.sleep(3000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            System.out.println("s2 任务完成");
            return 2;
        });
        // 异步向电商 S3 询价
        cs.submit(()->{
            try {
                System.out.println(Thread.currentThread() + " s3 do something....");
                Thread.sleep(10000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            System.out.println("s3 任务完成");
            return 3;
        });
        // 将询价结果异步保存到数据库
        for (int i=0; i<3; i++) {
            Integer r = cs.take().get();
            executor.execute(()->saveToDB(r));
        }
    }
```





**利用 CompletionService 实现 Dubbo 中的 Forking Cluster**

Dubbo 中有一种叫做**Forking 的集群模式**，这种集群模式下，支持**并行地调用多个查询服务，只要有一个成功返回结果，整个服务就可以返回了**。例如你需要提供一个地址转坐标的服务，为了保证该服务的高可用和性能，你可以并行地调用 3 个地图服务商的 API，然后只要有 1 个正确返回了结果 r，那么地址转坐标这个服务就可以直接返回 r 了。这种集群模式可以容忍 2 个地图服务商服务异常，但缺点是消耗的资源偏多。

利用 CompletionService 可以快速实现 Forking 这种集群模式，比如下面的示例代码就展示了具体是如何实现的。首先我们创建了一个线程池 executor 、一个 CompletionService 对象 cs 和一个`Future<Integer>`类型的列表 futures，每次通过调用 CompletionService 的 submit() 方法提交一个异步任务，会返回一个 Future 对象，我们把这些 Future 对象保存在列表 futures 中。通过调用 `cs.take().get()`，我们能够拿到最快返回的任务执行结果，只要我们拿到一个正确返回的结果，就可以取消所有任务并且返回最终结果了。

```java
// 创建线程池
ExecutorService executor = Executors.newFixedThreadPool(3);
// 创建 CompletionService
CompletionService<Integer> cs = new ExecutorCompletionService<>(executor);
// 用于保存 Future 对象
List<Future<Integer>> futures = new ArrayList<>(3);
// 提交异步任务，并保存 future 到 futures 
futures.add( cs.submit(()->geocoderByS1()));
futures.add( cs.submit(()->geocoderByS2()));
futures.add( cs.submit(()->geocoderByS3()));

// 获取最快返回的任务执行结果
Integer r = 0;
try {
  // 只要有一个成功返回，则 break
  for (int i = 0; i < 3; ++i) {
    r = cs.take().get();
    // 简单地通过判空来检查是否成功返回
    if (r != null) {
      break;
    }
  }
} finally {
  // 取消所有任务
  for(Future<Integer> f : futures)
    f.cancel(true);
}
// 返回结果
return r;
```



### 总结

当需要批量提交异步任务的时候建议你使用 CompletionService。CompletionService 将线程池 Executor 和阻塞队列 BlockingQueue 的功能融合在了一起，能够让批量异步任务的管理更简单。除此之外，CompletionService 能够让异步任务的执行结果有序化，先执行完的先进入阻塞队列，利用这个特性，你可以轻松实现后续处理的有序性，避免无谓的等待，同时还可以快速实现诸如 Forking Cluster 这样的需求。
