```java
package com.tangdi.mvcframework.component;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.net.URL;
import java.net.URLDecoder;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Pattern;

/**
 * @program: lagou-transfer
 * @description: 扫描Class包
 * @author: Wangwentao
 * @create: 2021-06-17 11:09
 **/
public class ResourcesScanner {

    public static final String CLASS_SUFFIX = ".class";
    private static final Pattern INNER_PATTERN = Pattern.compile("\\$(\\d+).", Pattern.CASE_INSENSITIVE);

    private static void scan(String name,List<String> list) {
        try {
            String path = name.replace('.', '/');
            if (path.startsWith("/")){
                path = path.substring(path.indexOf("/"));
            }
            ArrayList<URL> urls = Collections.list(Thread.currentThread().getContextClassLoader().getResources(path));
            for (URL url : urls){
                if ("file".equalsIgnoreCase(url.getProtocol())) {
                    File file = new File(URLDecoder.decode(url.getPath(),"UTF-8"));
                    // File file2 = new File(url.toURI());
                    File[] files = file.listFiles();
                    for (File f : files){
                        if (f.isDirectory()){
                            scan(name + "." + f.getName(),list);
                        } else if (f.getName().endsWith(".class")){
                            if (f.getName().contains("$")){
                                continue;
                            }
                            list.add(name + "." + f.getName().replace(".class",""));
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void doScanforClass(List<String> result, String pathName) throws IOException {
        Map<String, String> classMap = new HashMap<>(32);

        String path = pathName.replace('.', '/');
        List<URL> urls = getResources(path);
        for (URL url : urls) {
            InputStream is = null;
            try {
                if ("file".equals(url.getProtocol())){
                    File file = new File(URLDecoder.decode(url.getFile(),"UTF-8"));
                    parseClassFile(file,path,classMap);
                }
            } finally {
                if (is != null) {
                    try {
                        is.close();
                    } catch (Exception e) {
                        // Ignore
                    }
                }
            }
        }
        result.addAll(classMap.values());
    }

    private static List<URL> getResources(String path) throws IOException {
        return Collections.list(Thread.currentThread().getContextClassLoader().getResources(path));
    }

    private static void parseClassFile(File dir, String packageName, Map<String, String> classMap){
        if(dir.isDirectory()){
            File[] files = dir.listFiles();
            for (File file : files) {
                parseClassFile(file, packageName, classMap);
            }
        } else if(dir.getName().endsWith(CLASS_SUFFIX)) {
            String name = dir.getPath();
            name = name.substring(name.indexOf("classes")+8).replace("\\", ".");
            System.out.println("file:"+dir+"\t class:"+name);
            addToClassMap(name, classMap);
        }
    }

    private static boolean addToClassMap(String name, Map<String, String> classMap){

        //过滤掉匿名内部类
        if(INNER_PATTERN.matcher(name).find()){
            System.out.println("anonymous inner class:"+name);
            return false;
        }
        System.out.println("class:"+name);
        //内部类
        if(name.indexOf("$")>0){
            System.out.println("inner class:"+name);
        }
        if(!classMap.containsKey(name)){
            //去掉.class
            classMap.put(name, name.substring(0, name.length()-6));
        }
        return true;
    }


}

```

