[toc]

#### 1. 添加依赖

```xml
<!--添加mp 依赖 -->
<dependency>
    <groupId>com.baomidou</groupId>
    <artifactId>mybatis-plus-boot-starter</artifactId>
    <version>3.3.2</version>
</dependency>
```



#### 2. Service 代码

接口继承 `com.baomidou.mybatisplus.extension.service.IService`

```java
package com.tangdi.storage.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.tangdi.storage.entity.Storage;
import io.seata.rm.tcc.api.BusinessActionContext;
import io.seata.rm.tcc.api.BusinessActionContextParameter;
import io.seata.rm.tcc.api.LocalTCC;
import io.seata.rm.tcc.api.TwoPhaseBusinessAction;

/**
 * 仓库服务
 */
@LocalTCC
public interface StorageService extends IService<Storage> {


    @TwoPhaseBusinessAction(name = "decreaseTCC",
            commitMethod = "decreaseCommit", rollbackMethod = "decreaseRollBack")
    public void decrease(@BusinessActionContextParameter(paramName = "goodsId")
                                 Integer goodsId, @BusinessActionContextParameter(paramName = "quantity") Integer quantity);


    public boolean decreaseCommit(BusinessActionContext context);

    public boolean decreaseRollBack(BusinessActionContext context);
}

```

```java
package com.tangdi.points.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.tangdi.points.entity.Points;
import io.seata.rm.tcc.api.BusinessActionContext;
import io.seata.rm.tcc.api.BusinessActionContextParameter;
import io.seata.rm.tcc.api.LocalTCC;
import io.seata.rm.tcc.api.TwoPhaseBusinessAction;

@LocalTCC
public interface PointsService extends IService<Points> {

    @TwoPhaseBusinessAction(name = "increaseTCC",
            commitMethod = "increaseCommit",rollbackMethod = "increaseRollBack")
    public void increase(@BusinessActionContextParameter(paramName = "username") String username,
                         @BusinessActionContextParameter(paramName = "points")  Integer points);


    public boolean increaseCommit(BusinessActionContext context);

    public boolean increaseRollBack(BusinessActionContext context);

}
```

```java
package com.tangdi.order.service;


import com.baomidou.mybatisplus.extension.service.IService;
import com.tangdi.order.entity.Order;
import io.seata.rm.tcc.api.BusinessActionContext;
import io.seata.rm.tcc.api.BusinessActionContextParameter;
import io.seata.rm.tcc.api.LocalTCC;
import io.seata.rm.tcc.api.TwoPhaseBusinessAction;

/**
 * 接口被seata管理. 根据事务的状态完成提交或回滚操作
 */
@LocalTCC
public interface OrderService extends IService<Order> {

    @TwoPhaseBusinessAction(name = "addTCC",
            commitMethod = "addCommit",rollbackMethod = "addRollBack")
    void add(@BusinessActionContextParameter(paramName = "order") Order order);

    public boolean addCommit(BusinessActionContext context);


    public boolean addRollBack(BusinessActionContext context);

}
```



实现类继承 `com.baomidou.mybatisplus.extension.service.impl.ServiceImpl`

```java
package com.tangdi.storage.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.tangdi.storage.entity.Storage;
import com.tangdi.storage.mapper.StorageMapper;
import com.tangdi.storage.service.StorageService;
import io.seata.rm.tcc.api.BusinessActionContext;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

/**
 * 仓库服务
 */
@Slf4j
@Service
public class StorageServiceImpl extends ServiceImpl<StorageMapper, Storage> implements StorageService {

    /**
     * 减少库存
     *
     * @param goodsId  商品ID
     * @param quantity 减少数量
     * @return 库存对象
     */
    public void decrease(Integer goodsId, Integer quantity) {
        QueryWrapper<Storage> wrapper = new QueryWrapper<Storage>();
        wrapper.lambda().eq(Storage::getGoodsId, goodsId);
        Storage goodsStorage = this.getOne(wrapper);
        if (goodsStorage.getStorage() >= quantity) {
            //goodsStorage.setStorage(goodsStorage.getStorage() - quantity);
            //设置冻结库存
            goodsStorage.setFrozenStorage(quantity);
        } else {
            throw new RuntimeException(goodsId + "库存不足,目前剩余库存:" + goodsStorage.getStorage());
        }
        this.saveOrUpdate(goodsStorage);
    }

    @Override
    public boolean decreaseCommit(BusinessActionContext context) {
        QueryWrapper<Storage> wrapper = new QueryWrapper<Storage>();
        wrapper.lambda().eq(Storage::getGoodsId, context.getActionContext("goodsId"));
        Storage goodsStorage = this.getOne(wrapper);
        if (goodsStorage != null) {
            //扣减库存
            goodsStorage.setStorage(goodsStorage.getStorage() - goodsStorage.getFrozenStorage());
            goodsStorage.setFrozenStorage(0);//冻结库存清零
            this.saveOrUpdate(goodsStorage);
        }
        log.info("-------->xid" + context.getXid() + " 提交成功!");
        return true;
    }

    @Override
    public boolean decreaseRollBack(BusinessActionContext context) {
        QueryWrapper<Storage> wrapper = new QueryWrapper<Storage>();
        wrapper.lambda().eq(Storage::getGoodsId, context.getActionContext("goodsId"));
        Storage goodsStorage = this.getOne(wrapper);
        if (goodsStorage != null) {
            goodsStorage.setFrozenStorage(0);//冻结库存清零
            this.saveOrUpdate(goodsStorage);
        }
        log.info("-------->xid" + context.getXid() + " 回滚成功!");
        return true;
    }
}
```

```java
package com.tangdi.points.service.impl;


import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.tangdi.points.mapper.PointsMapper;
import com.tangdi.points.entity.Points;
import com.tangdi.points.service.PointsService;
import io.seata.rm.tcc.api.BusinessActionContext;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

/**
 * 会员积分服务
 */
@Slf4j
@Service
public class PointsServiceImpl extends ServiceImpl<PointsMapper, Points> implements PointsService {
    @Autowired
    PointsMapper pointsMapper;

    /**
     * 会员增加积分
     *
     * @param username 用户名
     * @param points   增加的积分
     * @return 积分对象
     */
    public void increase(String username, Integer points) {
        QueryWrapper<Points> wrapper = new QueryWrapper<Points>();
        wrapper.lambda().eq(Points::getUsername, username);
        Points userPoints = this.getOne(wrapper);
        if (userPoints == null) {
            userPoints = new Points();
            userPoints.setUsername(username);
            //userPoints.setPoints(points);
            userPoints.setFrozenPoints(points);//try-设置冻结积分
        } else {
            //userPoints.setPoints(userPoints.getPoints() + points);
            userPoints.setFrozenPoints(points);//try-设置冻结积分
        }
        this.saveOrUpdate(userPoints);
    }

    @Override
    public boolean increaseCommit(BusinessActionContext context) {
        QueryWrapper<Points> wrapper = new QueryWrapper<Points>();
        wrapper.lambda().eq(Points::getUsername,
                context.getActionContext("username"));
        Points userPoints = this.getOne(wrapper);
        if(userPoints!=null){
            //增加用户积分
            userPoints.setPoints(userPoints.getPoints()+ userPoints.getFrozenPoints());
            userPoints.setFrozenPoints(0);//冻结积分清零
            this.saveOrUpdate(userPoints);
        }
        log.info("-------->xid" + context.getXid() + " 提交成功!");
        return true;
    }

    @Override
    public boolean increaseRollBack(BusinessActionContext context) {
        QueryWrapper<Points> wrapper = new QueryWrapper<Points>();
        wrapper.lambda().eq(Points::getUsername,
                context.getActionContext("username"));
        Points userPoints = this.getOne(wrapper);
        if(userPoints!=null){
            userPoints.setFrozenPoints(0);//冻结积分清零
            this.saveOrUpdate(userPoints);
        }
        log.info("-------->xid" + context.getXid() + " 回滚成功!");
        return true;
    }
}
```

```java
package com.tangdi.order.service.impl;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONPath;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.tangdi.order.entity.Order;
import com.tangdi.order.mapper.OrderMapper;
import com.tangdi.order.service.OrderService;
import io.seata.rm.tcc.api.BusinessActionContext;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.Date;

@Slf4j
@Service
public class OrderServiceImpl extends ServiceImpl<OrderMapper, Order> implements OrderService {

    @Override
    public void add(Order order) {
        order.setCreateTime(new Date());//设置订单创建时间
        order.setStatus(0);//try阶段-预检查
        this.save(order);//保存订单
    }

    @Override
    public boolean addCommit(BusinessActionContext context) {
        Object jsonOrder = context.getActionContext("order");
        Order order = JSON.parseObject(jsonOrder.toString(), Order.class);
        order = this.getById(order.getId());
        if (order != null) {
            order.setStatus(1);//commit提交操作.1订单可用
            this.saveOrUpdate(order);
        }
        log.info("-------->xid" + context.getXid() + " 提交成功!");
        return true;//注意: 方法必须返回为true
    }

    @Override
    public boolean addRollBack(BusinessActionContext context) {
        Object jsonOrder = context.getActionContext("order");
        Order order = JSON.parseObject(jsonOrder.toString(), Order.class);
        order = this.getById(order.getId());
        if (order != null) {
            this.removeById(order.getId());//回滚操作-删除订单
        }
        log.info("-------->xid" + context.getXid() + " 回滚成功!");
        return true;
    }
}
```

