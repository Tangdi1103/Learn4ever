### BlockingQueue

```java
package com.tangdi.datastructure.blocking;

/**
 * @program: algorithm
 * @description: FIFO阻塞队列的实现，队列满时阻塞put，队列空时阻塞get
 * @author: Wangwentao
 * @create: 2021-08-23 11:22
 **/
public class BlockingQueue {

    private String[] queue;
    private int putIndex = 0;
    private int getIndex = 0;
    public int size = 0;

    public BlockingQueue(int queueLength) {
        this.queue = new String[queueLength];
    }

    synchronized public void put(String element) {
        try {
            if (size == queue.length){
                wait();
            }

            queue[putIndex++] = element;
            if (putIndex >= queue.length){
                putIndex = 0;
            }

            size++;
            notify();
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }

    synchronized public String get() {
        try {
            if (size == 0) {
                wait();
            }

            String element = queue[getIndex++];
            if (getIndex >= queue.length){
                getIndex = 0;
            }

            size--;
            notify();
            return element;
        } catch (InterruptedException e) {
            e.printStackTrace();
            throw new RuntimeException();
        }
    }
}
```



### 消费者

```java
package com.tangdi.datastructure.blocking;


/**
 * @program: algorithm
 * @description:
 * @author: Wangwentao
 * @create: 2021-08-23 15:51
 **/
public class Consumer implements Runnable{

    private final BlockingQueue blockingQueue;

    public Consumer(BlockingQueue blockingQueue) {
        this.blockingQueue = blockingQueue;
    }

    public void run() {
        while (true) {
            System.out.println(Thread.currentThread().getName()+"消费消息："+blockingQueue.get()+"，剩余消息数量："+blockingQueue.size);
        }
    }
}
```



### 生产者

```java
package com.tangdi.datastructure.blocking;

import java.text.MessageFormat;
import java.util.Random;

/**
 * @program: algorithm
 * @description:
 * @author: Wangwentao
 * @create: 2021-08-23 15:51
 **/
public class Provider implements Runnable{

    private final BlockingQueue blockingQueue;
    private volatile int element = 0;


    public Provider(BlockingQueue blockingQueue) {
        this.blockingQueue = blockingQueue;
    }

    public void run() {
        Random random = new Random();
        while (true) {
            blockingQueue.put(String.valueOf(element));
            System.out.println(MessageFormat.format("{0}生产消息：{1}，剩余消息数量：{2}"
                    ,Thread.currentThread().getName()
                    ,element
                    ,blockingQueue.size));
            element++;
            try {
                Thread.sleep(random.nextInt(500));
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
    }
}
```



### 测试

```java
package com.tangdi.datastructure.blocking;

/**
 * @program: algorithm
 * @description:
 * @author: Wangwentao
 * @create: 2021-08-23 15:46
 **/
public class TestMain {

    public static void main(String[] args) throws InterruptedException {
        BlockingQueue blockingQueue = new BlockingQueue(10);
        new Thread(new Provider(blockingQueue)).start();
        Thread.sleep(3000);
        System.out.println(Thread.currentThread().getName()+"=====>"+"等待消费者消费队列信息");
        Thread.sleep(5000);
        new Thread(new Consumer(blockingQueue)).start();
        Thread.sleep(5000);
        System.exit(1);
    }
}
```

