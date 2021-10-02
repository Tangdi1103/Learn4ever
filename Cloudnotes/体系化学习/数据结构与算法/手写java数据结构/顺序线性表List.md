```java
package com.tangdi.datastructure.list;

import java.util.Arrays;

/**
 * @program: algorithm
 * @description:
 * @author: Wangwt
 * @create: 15:25 2021/10/2
 */
public class ArrayList<E> {

    private int size;
    private Object[] arr;

    public ArrayList() {
        arr = new Object[10];
    }
    public ArrayList(Object[] elements) {
        arr = elements;
        size = arr.length;
    }

    public void add(E e){
        if (size >= arr.length){
            int growLength = arr.length + (arr.length >> 1);
            arr = Arrays.copyOf(arr,growLength);
        }
        arr[size++] = e;
    }

    public void add(E e,int index){
        if (index > size || index < 0)
            throw new IndexOutOfBoundsException("位置有误");

        // 扩容
        if (size >= arr.length){
            int growLength = arr.length + (arr.length >> 1);
            arr = Arrays.copyOf(arr,growLength);
        }

        // 位移
        for (int j = size-1; j >= index; j--) {
            arr[j+1] =arr[j];
        }
        arr[index] = e;
//        System.arraycopy(arr, index, arr, index + 1,size - index);
        size++;
    }

    public Object[] toArray(){
        return Arrays.copyOf(arr,size);
    }
}
```

