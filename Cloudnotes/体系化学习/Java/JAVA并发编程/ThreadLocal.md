## ThreadLocal

- 简介

  ThreadLocal 一般定义为成员变量，可以用来存储线程本地内存独有的数据，线程在整个调用链中都可以通过ThreadLocal 访问到这个数据。

- 应用：

  Spring的事务管理，使用ThreadLocal存储Connection，保证各dao操作都能获取同一个Connection，从而进行事务提交、回滚..

- 原理：

  每个**Thread对象**中都**绑定一个ThreadLocalMap对象**，而 **ThreadLocal**对象就是**当前线程的ThreadLocalMap的操作封装**

  Thread在C++的实现为`JavaThread`，又通过`ThreadLocalStorage`对象，将自己保存到了实际操作系统线程的线程变量中。

- 回收策略

  ThreadLocalMap的Entry Key使用当前ThreadLocal实例并为其添加一个弱引用，而Value为需要存储的拥有强引用的对象。为什么要将ThreadLocal添加一个弱引用呢？就是为了当ThreadLocal的强引用消失时，其实例对象可以被gc回收。而value强引用对象则需要手动remove释放，或者set





ThreadLocal-set方法具体实现：

```java
public void set(T value) {
    Thread t = Thread.currentThread();
    ThreadLocalMap map = getMap(t);
    if (map != null)
        map.set(this, value);
    else
        createMap(t, value);
}
// ThreadLocalMap属于ThreadLocal的内部类，是Thread的成员属性，因此每个线程有各自的ThreadLocalMap内存空间
```
ThreadLocal-get方法具体实现：

```java
public T get() {
    Thread t = Thread.currentThread();
    ThreadLocalMap map = getMap(t);
    if (map != null) {
        ThreadLocalMap.Entry e = map.getEntry(this);
        if (e != null) {
            @SuppressWarnings("unchecked")
            T result = (T)e.value;
            return result;
        }
    }
    return setInitialValue();
}
```

**ThreadLocalMap**底层结构使用Entry存储、获取、释放

ThreadLocalMap内部结构实现：

```java
// 初次使用，Entry默认大小为INITIAL_CAPACITY（16）
ThreadLocalMap(ThreadLocal<?> firstKey, Object firstValue) {
    table = new Entry[INITIAL_CAPACITY];
    int i = firstKey.threadLocalHashCode & (INITIAL_CAPACITY - 1);
    table[i] = new Entry(firstKey, firstValue);
    size = 1;
    setThreshold(INITIAL_CAPACITY);
}

// Entry的键ThreadLocal为弱引用，保存对象引用为强引用
static class Entry extends WeakReference<ThreadLocal<?>> {
    /** The value associated with this ThreadLocal. */
    Object value;

    Entry(ThreadLocal<?> k, Object v) {
        super(k);
        value = v;
    }
}
```

ThreadLocalMap-getEntry实现
```java
private Entry getEntry(ThreadLocal<?> key) {
    int i = key.threadLocalHashCode & (table.length - 1);
    Entry e = table[i];
    if (e != null && e.get() == key)
        return e;
    else
        return getEntryAfterMiss(key, i, e);
}
```

ThreadLocalMap-remove实现
```java
/**
 * Remove the entry for key.
 */
private void remove(ThreadLocal<?> key) {
    Entry[] tab = table;
    int len = tab.length;
    int i = key.threadLocalHashCode & (len-1);
    for (Entry e = tab[i];
         e != null;
         e = tab[i = nextIndex(i, len)]) {
        if (e.get() == key) {
            e.clear();
            expungeStaleEntry(i);
            return;
        }
    }
}
```

清理强引用实现

```java
private Entry getEntryAfterMiss(ThreadLocal<?> key, int i, Entry e) {
    Entry[] tab = table;
    int len = tab.length;

    while (e != null) {
        ThreadLocal<?> k = e.get();
        if (k == key)
            return e;
        if (k == null)
            expungeStaleEntry(i);
        else
            i = nextIndex(i, len);
        e = tab[i];
    }
    return null;
}
```

#### 最佳实践：
- remove()、set()方法中，真正用来回收value的是expungeStaleEntry()。
- ThreadLocal使用了弱引用维护key，在getEntry()方法中检查key是否被回收进而回收value。但是如果threadLocal一直被get()访问，清理动作就不会执行，所以还是主动调用remove()最好。
- ThreadLocalMap的每个Entry的key都是弱引用，当这个引用不被其他对象使用时，则ThreadLocal对象会被自动回收。