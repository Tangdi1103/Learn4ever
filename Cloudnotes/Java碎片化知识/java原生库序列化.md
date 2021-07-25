序列化

```
ByteArrayOutputStream bos = new ByteArrayOutputStream();  
ObjectOutputStream os = new ObjectOutputStream(bos);  
os.writeObject(src);  
os.flush();  
os.close();  
byte[] b = bos.toByteArray();  
bos.close();  

// FileOutputStream fos = new FileOutputStream(dataFile);  
// fos.write(b);  
// fos.close();  
```

反序列化

```
FileInputStream fis = new FileInputStream(dataFile);  
ObjectInputStream ois = new ObjectInputStream(fis);  
vo = (UserVo) ois.readObject();  
ois.close();  
fis.close();  
```
