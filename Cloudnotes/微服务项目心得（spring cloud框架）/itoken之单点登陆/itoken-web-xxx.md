# Application


```
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;
import org.springframework.cloud.netflix.hystrix.dashboard.EnableHystrixDashboard;
import org.springframework.cloud.openfeign.EnableFeignClients;

@SpringBootApplication(exclude = DataSourceAutoConfiguration.class,scanBasePackages = "com.tangdi.itoken")
@EnableDiscoveryClient
@EnableFeignClients
@EnableHystrixDashboard
public class WebAdminApplication {
    public static void main(String[] args) {
        SpringApplication.run(WebAdminApplication.class,args);
    }
}

```

---

# 消费redis

### 创建接口


```
import com.tangdi.itoken.web.admin.service.fallback.RedisServiceFallback;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;

@FeignClient(value = "itoken-service-redis",fallback = RedisServiceFallback.class)
public interface RedisService {

    @RequestMapping(value = "put", method = RequestMethod.POST)
    public String put(
            @RequestParam(value = "key") String key,
            @RequestParam(value = "value") String value,
            @RequestParam(value = "seconds") long seconds);

    @RequestMapping(value = "get", method = RequestMethod.GET)
    public String get(@RequestParam(value = "key") String key);
}

```

### 创建熔断器


```
import com.tangdi.itoken.web.admin.service.RedisService;
import org.springframework.stereotype.Component;

@Component
public class RedisServiceFallback implements RedisService {

    @Override
    public String put(String key, String value, long seconds) {
        return null;
    }

    @Override
    public String get(String key) {
        return null;
    }

}

```

---

# 拦截器

### Interceptor


```
import com.tangdi.itoken.common.domain.TbSysUser;
import com.tangdi.itoken.common.utils.CookieUtils;
import com.tangdi.itoken.common.utils.MapperJacksonUtils;
import com.tangdi.itoken.web.admin.service.RedisService;
import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.servlet.HandlerInterceptor;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

public class WebAdminInterceptor implements HandlerInterceptor{

    @Autowired
    private RedisService redisService;

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) {
        String token = CookieUtils.getCookieValue(request, "token");

        // token 为空表示一定没有登录
        if (StringUtils.isBlank(token)) {
            try {
                response.sendRedirect("http://localhost:8503/login?url=http://localhost:8601");
            } catch (IOException e) {
                e.printStackTrace();
            }
            return false;
        }

        return true;
    }

    @Override
    public void postHandle(HttpServletRequest request, HttpServletResponse response, Object handler, ModelAndView modelAndView) {
        HttpSession session = request.getSession();
        TbSysUser tbSysUser = (TbSysUser) session.getAttribute("tbSysUser");

        // 已登录状态
        if (tbSysUser != null) {
            if (modelAndView != null) {
                modelAndView.addObject("tbSysUser", tbSysUser);
            }
        }

        // 未登录状态
        else {
            String token = CookieUtils.getCookieValue(request, "token");
            if (StringUtils.isNotBlank(token)) {
                String loginCode = redisService.get(token);
                if (StringUtils.isNotBlank(loginCode)) {
                    String json = redisService.get(loginCode);
                    if (StringUtils.isNotBlank(json)) {
                        try {
                            // 已登录状态，创建局部会话
                            tbSysUser = MapperJacksonUtils.json2pojo(json, TbSysUser.class);
                            if (modelAndView != null) {
                                modelAndView.addObject("tbSysUser", tbSysUser);
                            }
                            request.getSession().setAttribute("tbSysUser", tbSysUser);
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    }
                }
            }
        }

        // 二次确认是否有用户信息
        if (tbSysUser == null) {
            try {
                response.sendRedirect("http://localhost:8503/login?url=http://localhost:8601");
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    @Override
    public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) {

    }

}

```

### config


```
import com.tangdi.itoken.web.admin.interceptor.WebAdminInterceptor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebAdminInterceptorConfig implements WebMvcConfigurer {

    @Bean
    WebAdminInterceptor webAdminInterceptor() {
        return new WebAdminInterceptor();
    }

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(webAdminInterceptor())
                .addPathPatterns("/**")
                .excludePathPatterns("/static");
    }
}

```





