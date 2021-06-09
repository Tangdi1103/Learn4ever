### 配置拦截器

#### com.tangdi.itoken.commin.web.interceptor目录中创建
```
package com.tangdi.itoken.commin.web.interceptor;

import org.omg.PortableInterceptor.Interceptor;
import org.springframework.lang.Nullable;
import org.springframework.web.servlet.HandlerInterceptor;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class ConstantsInterceptor implements HandlerInterceptor {

    private static final String HOST_CDN = "http://www.tangdi.com:81";

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        return true;
    }

    @Override
    public void postHandle(HttpServletRequest request, HttpServletResponse response, Object handler, @Nullable ModelAndView modelAndView) throws Exception {
        if (modelAndView != null) {
            modelAndView.addObject("adminlte", HOST_CDN );
        }
    }

    @Override
    public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, @Nullable Exception ex) throws Exception {

    }
}

```

### 添加拦截器

#### 目录com.tangdi.itoken.commin.web.config添加拦截器
```
package com.tangdi.itoken.commin.web.config;

import com.tangdi.itoken.commin.web.interceptor.ConstantsInterceptor;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class InterceptorConfig implements WebMvcConfigurer {
    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(new ConstantsInterceptor()).addPathPatterns("/**");
    }
}

```

















