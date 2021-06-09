### Rdis的Hash类型

RedisTemplate.opsForHash.entries(H Key);---获得全部KEY的value

RedisTemplate.opsForHash.putAll(H key , Map m)---存入map集合到Key

RedisTemplate.expire(H key, 10, TimeUnit.SECONDS);---刷新Kry过期时间

incr---Incr 命令将 key 中储存的数字值增一。如果 key 不存在，那么 key 的值会先被初始化为 0 ，然后再执行 INCR 操作。











