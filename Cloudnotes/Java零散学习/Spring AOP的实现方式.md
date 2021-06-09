AOP的底层原理是基于jdk的动态代理实现，通过反射

### 基于注解实现

#### 1.被代理类

```
package com.example.demo5.controller;

import com.example.demo5.common.BaseResult;
import com.example.demo5.service.WeatherService;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;


@RestController
@RequestMapping(value = "/weather/api")
public class WeatherController {

    private static Logger logger = LogManager.getLogger(WeatherController.class);

    @Autowired
    private WeatherService weatherService;

    @RequestMapping(value = "/city/{cityName}")
    public BaseResult searchWeather(@PathVariable(required = true)String cityName){

        BaseResult baseResult = weatherService.getWeatherByCity(cityName);

        if(baseResult != null){
            logger.info("成功获取天气数据"+baseResult.getData());
            return baseResult;
        }
        else {
            logger.error("获取天气数据失败");
            return baseResult;
        }
    }
}

```

#### 2.切面类
切面可通过包路经、注解、继承接口的方式代理
- @Pointcut("execution(* com.example.demo5.controller..*(..))")
- @Pointcut("this(com.csair.common.BaseWebApi)")继承BaseWebApi接口的
- @Around(value = "@annotation(eLog)")

```
package com.example.demo5.aop;

import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.*;
import org.springframework.stereotype.Component;

@Aspect
@Component
public class MyOneAspect {

    //@Pointcut("this(com.csair.common.BaseWebApi)")继承BaseWebApi接口的切
    //@Pointcut("@annotation(org.springframework.web.bind.annotation.PostMapping)")对该注解切
    @Pointcut("execution(* com.example.demo5.controller..*(..))")//正则表达式
    public void getWeather(){}

    @After("getWeather()")
    public void two(){
        System.out.println("第一次哦，请加油wwt");
    }

    @Before("getWeather()")
    public void one(){
        System.out.println("即将开始！");
    }

    //@Around(value = "@annotation(eLog)")对使用eLog注解的方法或类
    @Around("getWeather()")
    public void three(ProceedingJoinPoint j) throws Throwable {
        System.out.println("环绕1");
        j.proceed();
        System.out.println("环绕2");
    }
}
```

#### 3.控制台输出

```
环绕1
即将开始！
2019-07-29 16:45:39.212  INFO 14180 --- [nio-8086-exec-7] c.e.demo5.controller.WeatherController   : 成功获取天气数据Weather(city=成都, aqi=null, ganmao=天气转凉，空气湿度较大，较易发生感冒，体质较弱的朋友请注意适当防护。, wendu=23, yesterday=Yesterday(date=28日星期日, high=高温 33℃, fx=无持续风向, low=低温 23℃, fl=<![CDATA[<3级]]>, type=阵雨), forecast=[Forecast(date=29日星期一, high=高温 26℃, fengxiang=无持续风向, low=低温 22℃, fengli=<![CDATA[<3级]]>, type=中雨), Forecast(date=30日星期二, high=高温 28℃, fengxiang=无持续风向, low=低温 22℃, fengli=<![CDATA[<3级]]>, type=小雨), Forecast(date=31日星期三, high=高温 30℃, fengxiang=无持续风向, low=低温 22℃, fengli=<![CDATA[<3级]]>, type=阵雨), Forecast(date=1日星期四, high=高温 29℃, fengxiang=无持续风向, low=低温 22℃, fengli=<![CDATA[<3级]]>, type=阵雨), Forecast(date=2日星期五, high=高温 28℃, fengxiang=无持续风向, low=低温 22℃, fengli=<![CDATA[<3级]]>, type=小雨)])
环绕2
第一次哦，请加油wwt
```

#### 4.对象讲解
###### 1. JoinPoint 对象
> JoinPoint对象封装了SpringAop中切面方法的信息,在切面方法中添加JoinPoint参数,就可以获取到封装了该方法信息的JoinPoint对象


方法名	 | 功能
---|---
Signature getSignature(); | 获取封装了署名信息的对象,在该对象中可以获取到目标方法名,所属类的Class等信息
Object[] getArgs(); | 获取传入目标方法的参数对象
Object getTarget(); | 获取被代理的对象
Object getThis(); | 获取代理对象

###### 2. ProceedingJoinPoint对象
> ProceedingJoinPoint对象是JoinPoint的子接口,该对象只用在@Around的切面方法中

添加的方法如下：
方法名	 | 功能
---|---
Object proceed() throws Throwable | //执行目标方法 
Object proceed(Object[] var1) throws Throwable | //传入的新的参数去执行目标方法 
---

### 实际应用
结合kibana日志系统，对日志进行脱敏
用法：脱敏注解使用在Controller方法上，Contrller类不用获取日志类，直接在切面获取响应controller类日志并记录

#### 在切面类，操作


```
package com.csair.order.aop.logging;

import com.csair.common.*;
import com.csair.csmbp.logback.LogSender;
import com.csair.logger.CsmbpLoggerFactory;
import com.csair.logger.Logger;
import com.csair.order.config.Constants;
import com.csair.util.JsonParser;

import com.csair.util.StringUtils;
import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.Signature;
import org.aspectj.lang.annotation.AfterThrowing;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Pointcut;
import org.aspectj.lang.reflect.MethodSignature;
import org.springframework.core.env.Environment;

import javax.inject.Inject;
import java.lang.reflect.Method;
import java.util.Arrays;

/**
 * Aspect for logging execution of service and repository Spring components.
 *
 * By default, it only runs with the "dev" profile.
 */
@Aspect
public class LoggingAspect {

    private final Logger log = CsmbpLoggerFactory.getLogger(this.getClass());

    @Inject
    private Environment env;

    /**
     * Pointcut that matches all repositories, services and Web REST endpoints.
     */
    //@Pointcut("within(com.csair.order.web.rest..*)")
    //@Pointcut("@annotation(org.springframework.web.bind.annotation.PostMapping)||@annotation(org.springframework.web.bind.annotation.RequestMapping)||@annotation(org.springframework.web.bind.annotation.GetMapping)")    	
    @Pointcut("@annotation(org.springframework.web.bind.annotation.PostMapping)")    		
    public void loggingPointcut() {
        // Method is empty as this is just a Poincut, the implementations are in the advices.
    }

    /**
     * Advice that logs methods throwing exceptions.
     */
    @AfterThrowing(pointcut = "loggingPointcut()", throwing = "e")
    public void logAfterThrowing(JoinPoint joinPoint, Throwable e) {
        if (env.acceptsProfiles(Constants.SPRING_PROFILE_DEVELOPMENT)) {
            log.error("Exception in {}.{}() with cause = \'{}\' and exception = \'{}\'", joinPoint.getSignature().getDeclaringTypeName(),
                joinPoint.getSignature().getName(), e.getCause() != null? e.getCause() : "NULL", e.getMessage(), e);

        } else {
            log.error("Exception in {}.{}() with cause = {}", joinPoint.getSignature().getDeclaringTypeName(),
                joinPoint.getSignature().getName(), e.getCause() != null? e.getCause() : "NULL");
        }
    }

    /**
     * Advice that logs when a method is entered and exited.
     */
    @Around("loggingPointcut()")
    public Object logAround(ProceedingJoinPoint joinPoint) throws Throwable {
    	long start=System.currentTimeMillis();
    	com.csair.logger.Logger log = getLogger(joinPoint);
        String methodName = null;
        String inputMessage = null;
        Signature signature = joinPoint.getSignature();
        methodName = signature.getDeclaringTypeName() + "." + signature.getName();
        doInputLogMask(signature, methodName, log);
        log.info("前端入参: {}.{}() with argument[s] = {}", joinPoint.getSignature().getDeclaringTypeName(),
            joinPoint.getSignature().getName(),"业务内容忽略");
        try {
            Object result = joinPoint.proceed();
            long end=System.currentTimeMillis();
            if(!isOutPutUnlog(joinPoint.getSignature().getDeclaringTypeName()))	{
                doOutputLogMask(signature, methodName, log);
            	log.info("返回结果: {}.{}() with result = {},耗时：{}", joinPoint.getSignature().getDeclaringTypeName(),
            			joinPoint.getSignature().getName(), "业务内容忽略",end-start);
            }else{
                doOutputLogMask(signature, methodName, log);
            	log.info("返回结果: {}.{}() with result = {},耗时：{}", joinPoint.getSignature().getDeclaringTypeName(),
            			joinPoint.getSignature().getName(), "业务内容忽略",end-start);
            }
            return result;
        } catch (IllegalArgumentException e) {
            log.error("Illegal argument: {} in {}.{}()", Arrays.toString(joinPoint.getArgs()),
                    joinPoint.getSignature().getDeclaringTypeName(), joinPoint.getSignature().getName());

            throw e;
        }
    }

    /**
     * 入参日志脱敏
     *
     * @param
     * @return
     */
    private void doInputLogMask(Signature signature, String methodName, com.csair.logger.Logger log) {
        //存储日志脱敏相关信息
        LogFieldsData logFieldsData;
        //从缓存中获取当前方法的入参脱敏字段列表，进行日志脱敏处理
        if(null != (logFieldsData = CsmbpDataContext.inputFieldsMaskingCache.get(methodName))) {
            if(null != logFieldsData.getFields() && logFieldsData.getFields().length > 0) {
                if(logFieldsData.getMessageType() == MessageType.XML) {
                    log.xml();
                }
                log.masking(logFieldsData.getFields());
            }
        }
        //通过反射获取注解上的日志脱敏相关信息，进行日志脱敏处理，并缓存脱敏信息
        else {
            Method targetMethod = ((MethodSignature)signature).getMethod();
            if(targetMethod.isAnnotationPresent(InputLogMasker.class)) {
                InputLogMasker maskInputLog = targetMethod.getAnnotation(InputLogMasker.class);
                if(StringUtils.isNotBlank(maskInputLog.fields())) {
                    logFieldsData = new LogFieldsData();
                    if(maskInputLog.type() == MessageType.XML) {
                        logFieldsData.setMessageType(MessageType.XML);
                        log.xml();
                    }
                    logFieldsData.setFields(maskInputLog.fields().split(","));
                    log.masking(logFieldsData.getFields());
                    CsmbpDataContext.inputFieldsMaskingCache.put(methodName, logFieldsData);
                }
            }
        }
    }

    /**
     * 出参日志脱敏
     *
     * @param
     * @return
     */
    private void doOutputLogMask(Signature signature, String methodName, com.csair.logger.Logger log) {
        //存储日志脱敏相关信息
        LogFieldsData logFieldsData;
        //从缓存中获取当前方法的出参脱敏字段列表，进行日志脱敏处理
        if(null != (logFieldsData = CsmbpDataContext.outputFieldsMaskingCache.get(methodName))) {
            if(null != logFieldsData.getFields() && logFieldsData.getFields().length > 0) {
                if(logFieldsData.getMessageType() == MessageType.XML) {
                    log.xml();
                }
                log.masking(logFieldsData.getFields());
            }
        }
        //通过反射获取注解上的日志脱敏相关信息，进行日志脱敏处理，并缓存脱敏信息
        else {
            Method targetMethod = ((MethodSignature)signature).getMethod();
            if(targetMethod.isAnnotationPresent(OutputLogMasker.class)) {
                OutputLogMasker maskOutputLog = targetMethod.getAnnotation(OutputLogMasker.class);
                if(StringUtils.isNotBlank(maskOutputLog.fields())) {
                    logFieldsData = new LogFieldsData();
                    if(maskOutputLog.type() == MessageType.XML) {
                        logFieldsData.setMessageType(MessageType.XML);
                        log.xml();
                    }
                    logFieldsData.setFields(maskOutputLog.fields().split(","));
                    log.masking(logFieldsData.getFields());
                    CsmbpDataContext.outputFieldsMaskingCache.put(methodName, logFieldsData);
                }
            }
        }
    }


    /**
     * 对含有Elog标签的方法推送日志到E眼系统
     * @param joinPoint
     * @param eLog
     * @return Object
     */
    @Around(value = "@annotation(eLog)")
    public Object eLogAround(ProceedingJoinPoint joinPoint, ELog eLog) throws Throwable {
        String moduleName = eLog.moduleName();
        String operationName = eLog.operationName();
        LogSender sender = LogSender.build().module(moduleName).operation(operationName);
        sender.req(Arrays.toString(joinPoint.getArgs())).info();
        try {
            Object result = joinPoint.proceed();
            sender.resp(getResultStr(result)).info();
            return result;
        } catch (IllegalArgumentException e) {
            sender.desc(joinPoint.getSignature().getName() + "发生错误:Illegal argument: " + Arrays.toString(joinPoint.getArgs())).error();
            throw e;
        }
    }

    /**
     * 对含有Elog标签的方法异常推送日志到E眼系统
     * @param joinPoint
     * @param eLog
     * @param e
     */
    @AfterThrowing(value = "@annotation(eLog)", throwing = "e")
    public void eLogAfterThrowing(JoinPoint joinPoint, ELog eLog, Throwable e) {
        String moduleName = eLog.moduleName();
        String operationName = eLog.operationName();
        LogSender sender = LogSender.build().module(moduleName).operation(operationName);
        sender.desc(joinPoint.getSignature().getName() + "方法发生异常: " + e.getMessage()).error();
    }

    /**
     * 判断是否需要打印出参
     * @param path
     * @return
     */
    private boolean isOutPutUnlog(String path){
    	for(String str:LocalConstants.UNLOGAPIS){
    		if(path.contains(str)){    			
    			return true;
    		}
    	}
    	return false;
    }


    private com.csair.logger.Logger getLogger(JoinPoint joinPoint) {
        try {
            return CsmbpLoggerFactory.getLogger(Class.forName(joinPoint.getSignature().getDeclaringTypeName()));
        } catch (ClassNotFoundException e) {
            return this.log;
        }
    }
    
    private String getResultStr(Object result){
    	if(result instanceof String){
    		return result.toString();
    	}else{
    		return JsonParser.toJsonQuietly(result);
    	}
    }
}

```
#### 自定义入参脱敏注解

```
package com.csair.common;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * 入参报文日志字段脱敏
 * @ClassName InputMsgMasker
 * @author sgz
 * @date 2019年3月12日 上午11:03:19
 */
@Target({ElementType.METHOD})
@Retention(RetentionPolicy.RUNTIME)
public @interface InputLogMasker{

    /**
     * 字段名字符串集合，逗号分隔
     *
     * @param
     * @return
     */
    String fields() default "";
    /**
     * 报文类型
     *
     * @param
     * @return
     */
    MessageType type() default MessageType.JSON;
}

```

#### 自定义出参脱敏注解

```
package com.csair.common;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * 出参报文日志字段脱敏
 * @ClassName MaskLog
 * @author sgz
 * @date 2019年3月12日 上午11:03:19
 */
@Target({ElementType.METHOD})
@Retention(RetentionPolicy.RUNTIME)
public @interface OutputLogMasker {

    /**
     * 字段名字符串集合，逗号分隔
     *
     * @param
     * @return
     */
    String fields() default "";
    /**
     * 报文类型
     *
     * @param
     * @return
     */
    MessageType type() default MessageType.JSON;
}

```

#### 封装SLF4J日志类

```
package com.csair.logger.impl;

import com.csair.common.ModuleName;
import com.csair.common.elog.ElogModule;
import com.csair.csmbp.logback.LogSender;
import com.csair.logger.CsmbpLogUtils;
import com.csair.logger.Logger;
import org.slf4j.LoggerFactory;
import org.slf4j.helpers.MessageFormatter;

/**
 * CSMBP后台日志输出类，封装slf4j日志记录以及E眼日志推送
 * @ClassName CsmbpLogger
 * @author sgz
 * @date 2019年3月12日 上午11:03:19
 */
public class CsmbpLogger implements Logger {

	private org.slf4j.Logger logger;
	private String moduleName;
	
	//E眼日志推送工具类，线程安全
    private static final ThreadLocal<LogSender> LOCAL_LOG_SENDER = new ThreadLocal<LogSender>(){
        @Override
        protected LogSender initialValue() {
            return null;
        }
    };
    
	//日志信息操作描述，线程安全
    private static final ThreadLocal<String> LOCAL_OPERATION = new ThreadLocal<String>(){
        @Override
        protected String initialValue() {
            return null;
        }
    };
	
	//待脱敏字段列表，线程安全
    private static final ThreadLocal<String[]> LOCAL_FIELDS_MASKING = new ThreadLocal<String[]>(){
        @Override
        protected String[] initialValue() {
            return null;
        }
    };
    
    //XML报文标识，线程安全
    private static final ThreadLocal<Boolean> LOCAL_IS_XML = new ThreadLocal<Boolean>(){
        @Override
        protected Boolean initialValue() {
            return false;
        }
    };
	
	public CsmbpLogger(Class<?> clazz) {
		this.logger = LoggerFactory.getLogger(clazz);
		moduleName = ModuleName.OTHER_MODULE.getName();
		if(clazz.isAnnotationPresent(ElogModule.class)) {
			ElogModule module = clazz.getDeclaredAnnotation(ElogModule.class);
			moduleName = module.name().getName();
		}
	}
	
	public CsmbpLogger(String loggerName) {
		this.logger = LoggerFactory.getLogger(loggerName); 
		moduleName = ModuleName.OTHER_MODULE.getName();
	}
	
	public CsmbpLogger(Class<?> clazz, String loggerName) {
		this.logger = LoggerFactory.getLogger(loggerName); 
		moduleName = ModuleName.OTHER_MODULE.getName();
		if(clazz.isAnnotationPresent(ElogModule.class)) {
			ElogModule module = clazz.getDeclaredAnnotation(ElogModule.class);
			moduleName = module.name().getName();
		}
	}

	@Override
	public void trace(String msg) {
		logger.trace(msg);
	}
	
	@Override
	public void trace(String msg, Object... arguments) {
		logger.trace(msg, arguments);
	}
	
	@Override
	public void debug(String msg) {
		logger.debug(msg);
	}
	
	@Override
	public void debug(String msg, Object... arguments) {
		logger.debug(msg, arguments);
	}
	
	@Override
	public Logger operation(String operation, Object... arguments) {
		operation = MessageFormatter.arrayFormat(operation, arguments).getMessage();
		LOCAL_OPERATION.set(operation);
		return this;
	}
	
	@Override
	public void req(String req) {
		req = mask(req);
		String operation = LOCAL_OPERATION.get();
		logger.info("{}. req: {}", operation, req);
		getLogSender().operation(operation).req(req).info();
		LOCAL_OPERATION.set(null);
	}
	
	@Override
	public void resp(String resp) {
		resp = mask(resp);
		String operation = LOCAL_OPERATION.get();
		logger.info("{}. resp: {}", operation, resp);
		getLogSender().operation(operation).resp(resp).info();
		LOCAL_OPERATION.set(null);
	}
	
	@Override
	public void info(String operation) {
		operation = mask(operation);
		logger.info(operation);
		getLogSender().operation(operation).info();
	}
	
	@Override
	public void info(String operation, Object... arguments) {
		info(mask(operation, arguments));
	}
	
	@Override
	public void error(String desc) {
		logger.error(desc);
		getLogSender().operation("handle error.").desc(desc).error();
	}
	
	@Override
	public void error(String desc, Throwable e) {
		logger.error(desc, e);
		getLogSender().operation("handle error.").desc(desc).error(new Exception(e));
	}
	
	@Override
	public void error(String desc, Object... arguments) {
		logger.error(desc, arguments);
		getLogSender().operation("handle error.")
			.desc(MessageFormatter.arrayFormat(desc, arguments).getMessage()).error();
	}
	
	private LogSender getLogSender() {
		if(null == LOCAL_LOG_SENDER.get()) {
			LogSender logSender = LogSender.build().module(moduleName);
			LOCAL_LOG_SENDER.set(logSender);
			return logSender;
		}else {
			LogSender logSender = LOCAL_LOG_SENDER.get();
			logSender.module(moduleName);
			return logSender;
		}
	}

	@Override
    public Logger masking(String... fields) {
		LOCAL_FIELDS_MASKING.set(fields);
        return this;
    }
    
    @Override
    public Logger xml() {
    	LOCAL_IS_XML.set(true);
        return this;
    }
    
    private void clear() {
    	LOCAL_FIELDS_MASKING.set(null);
    	LOCAL_IS_XML.set(false);
    }
    
    private String[] getFields() {
        return LOCAL_FIELDS_MASKING.get();
    }
    
    private boolean isXml() {
        Boolean isXml =  LOCAL_IS_XML.get();
        if(null != isXml) {
            return isXml;
        }else {
            return false;
        }
    }
    
    private String mask(String msg) {
        try {
            if(isXml()) {
                msg = CsmbpLogUtils.maskXmlMessage(msg, getFields());
            }else {
                msg = CsmbpLogUtils.maskJsonMessage(msg, getFields());
            }
            clear();
        } catch (Exception e) {
            logger.error("mask(msg) error! {}, {}", e.getMessage(), e);
        }
        return msg;
    }
    
    private String mask(String msg, Object... arguments) {
        try {
            if(isXml()) {
                msg = CsmbpLogUtils.maskXmlMessage(MessageFormatter.arrayFormat(msg, arguments).getMessage(),
                        getFields());
            } else {
                msg = CsmbpLogUtils.maskJsonMessage(MessageFormatter.arrayFormat(msg, arguments).getMessage(),
                        getFields());
            }
            clear();
        } catch (Exception e) {
            logger.error("mask(msg,arguments) error! {}, {}", e.getMessage(), e);
        }
        return msg;
    }
	
}

```

