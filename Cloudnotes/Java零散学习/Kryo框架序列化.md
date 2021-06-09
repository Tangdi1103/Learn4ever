
```
compile("com.esotericsoftware:kryo:4.0.0")
     /**
     * 将对象序列化
     */
    public static byte[] serializableObject(String objStr, Object object) {

        try {
            Kryo kryo = new Kryo();
            Output output = new Output(1048, -1);
            kryo.writeObject(output, object);
            output.flush();
            output.close();
            return output.toBytes();
        } catch (Exception e) {
            logger.error("对象【" + objStr + "】序列化失败。" + e.getMessage());
            return null;
        }
    }


    /**
     * 将对象反序列化
     */
    public static <T> T unSerializableObject(String objStr, byte[] object, Class<T> serializableClass) {
        try {
            Kryo kryo = new Kryo();
            Input input = new Input(object);
            input.close();
            return kryo.readObject(input, serializableClass);
        } catch (Exception e) {
            logger.error("对象【" + objStr + "】反序列化失败。" + e.getMessage());
            return null;
        }
    }
     /**
     * 反序列化方法可以使用以下模式，此模式对实体类名及实体类所在位置没有要求
     */
    public static <T> T unSerializableClassAndObject(String objStr, byte[] object) {
        String start = "【";
        if (!objStr.startsWith(start)) {
            objStr = start + objStr + "】";
        }
        try {
            Kryo kryo = new Kryo();
            Input input = new Input(object);
            input.close();
            return (T) kryo.readClassAndObject(input);
        } catch (Exception e) {
            logger.error("对象【" + objStr + "】反序列化失败。" + e.getMessage());
            return null;
        }
    }
```
