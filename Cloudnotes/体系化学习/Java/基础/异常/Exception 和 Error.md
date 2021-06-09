### 介绍

- Exception和Error都继承自Throwable，都剋有被抛出(Throw)和捕获(catch)

    ---

### 对比

- Exception：程序中可被预料的异常，异常可以被捕获并处理，来恢复程序的正常运行
- Error：不可预料的错误，Error会导致程序处于非正常，无法恢复的状态。因此即便捕获Error，程序也无法正常运行。如，OutOfMemoryError就是Error的子类

    ---

### Error（错误）
Error可分为一下两类
- 非VMError：LinkageError（类加载冲突），NoClassDefFoundError（找不到类加载）
- VMError：OutOfMemoryError（内存溢出），StackOverflowError(栈内存溢出)

---
### Exception（异常）
- unchecked：编译期不可检查型异常，就是运行时异常,可通过编码避免的异常。如NullPointException，ArrayIndexOutOfBoundsException 
- checked：编译期可检查型异常，强制显示的捕获处理。除了RunTimeException以外所有的Exception异常，如IOException

    ---

### 总结
1. 当我们想捕获某种特定的异常，不应该捕获Exception这种通用异常。应该让不希望捕获的异常向外扩散开来。
1. 不要生吞异常（swallow），必须抛出或者捕获并将异常堆栈信息输出到日志系统。
1. 捕获异常的处理不应该只是打印堆栈信息，e.printStackTrace();分布式系统中发生异常，很难找到堆栈轨迹，应该输出到日志系统
1. 处理异常时，底层可输出异常堆栈再向上抛出异常，在高层的业务层根据业务需求来处理异常
1. 不应try-catch大段代码和使用try-catch控制流程，因为try-catch代码段会有额外的性能开销，影响JVM对代码进行优化
1. Java每实例化一个Exception，都会对当时的堆栈进行快照，这是相对比较重的操作。若是异常发生频繁，开销会非常大。

    ---
