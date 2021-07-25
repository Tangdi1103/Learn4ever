```java
public static void main(String[] args)  {
    try {
        StdSchedulerFactory stdSchedulerFactory = new StdSchedulerFactory();
        Scheduler scheduler = stdSchedulerFactory.getScheduler();

        JobDetail detail = JobBuilder
                .newJob(DemoJob.class)
                .withIdentity("demoDetail","myJobGroup")
                .build();

        CronTrigger trigger = TriggerBuilder
                .newTrigger()
                .withIdentity("demoTrigger","myTriggerGroup")
                .startNow()
                .withSchedule(CronScheduleBuilder.cronSchedule("0/2 * * * * ?"))
                .build();

        scheduler.scheduleJob(detail, trigger);
        scheduler.start();
    } catch (SchedulerException e) {
        e.printStackTrace();
    }
}
```

```java
package com.example.demo5.study;

import org.quartz.Job;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;

/**
 * @program: demo5
 * @description:
 * @author: Wangwt
 * @create: 15:04 2021/7/25
 */
public class DemoJob implements Job {
    @Override
    public void execute(JobExecutionContext context) throws JobExecutionException {
        System.out.println("我是定时任务demo");
    }
}
```

