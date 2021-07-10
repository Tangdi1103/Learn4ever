```java
package com.tangdi.mvcframework.component;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.File;
import java.io.IOException;
import java.net.JarURLConnection;
import java.net.URL;
import java.net.URLDecoder;
import java.util.*;
import java.util.jar.JarEntry;
import java.util.jar.JarFile;
import java.util.regex.Pattern;

/**
 * @program: imvc
 * @description: 扫描Class包
 * @author: Wangwentao
 * @create: 2021-06-17 11:09
 **/
public class ResourcesScanner {

    private static final Logger logger = LoggerFactory.getLogger(ResourcesScanner.class);

    public static final String CLASS_SUFFIX = ".class";
    private static final Pattern INNER_PATTERN = Pattern.compile("\\$(\\d+)", Pattern.CASE_INSENSITIVE);


    public static List<String> doScanClass(List<String> classNames,String path) throws IOException {

        String newpath = path.replace('.', '/');
        if (newpath.startsWith("/")){
            newpath = newpath.substring(1);
        }

        List<URL> urls = getResources(newpath);
        for (URL u : urls) {
            if (u == null){
                continue;
            }
            logger.info("[ResourcesScanner] doScan url:" + u.getFile());

            // IDEA中直接编译运行，则该资源目录为文件
            if ("file".equals(u.getProtocol())){
                File file = new File(URLDecoder.decode(u.getFile(), "utf-8"));
                File[] files = file.listFiles();
                if (files == null){
                    continue;
                }

                for (File f : files) {
                    String fileName = f.getName();
                    // 若为目录则继续解析
                    if (f.isDirectory()){
                        doScanClass(classNames,path+ "." + fileName);
                    }
                    else {
                        logger.info("[ResourcesScanner] doScan file:" + f.getPath());
                        if (fileName.endsWith(CLASS_SUFFIX) && !INNER_PATTERN.matcher(fileName).find()){
                            classNames.add(path+ "." + fileName.replace(".class",""));
                        }
                    }
                }
            }
            // 若将该项目打成jar包，则该资源目录为jar
            else if ("jar".equals(u.getProtocol())){
                // 获取Jar文件下所有条目
                JarFile jarFile = ((JarURLConnection) u.openConnection()).getJarFile();
                List<JarEntry> entries = Collections.list(jarFile.entries());
                for (JarEntry entry : entries) {
                    // 过滤内部类
                    if (entry.getName().replace('/','.').startsWith(path)
                            && !INNER_PATTERN.matcher(entry.getName()).find()
                            && entry.getName().endsWith(CLASS_SUFFIX)){
                        logger.info("[ResourcesScanner] doScan file:" + entry.getName());
                        classNames.add(entry.getName().replace(".class","").replace('/','.'));
                    }
                }
            }
        }
        return classNames;
    }

    private static List<URL> getResources(String path) throws IOException {
        return Collections.list(Thread.currentThread().getContextClassLoader().getResources(path));
    }
}
```

