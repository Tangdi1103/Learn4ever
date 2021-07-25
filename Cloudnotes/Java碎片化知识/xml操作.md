<font size=4>

#### 首先项目必须依赖org.dom4j

```java
Document document = DocumentHelper.parseText(payResult);
 root = document.getRootElement();
uppBillNo = root.element("payno").getText();
Element subOrderDetail = (Element) root.elements("subOrderDetail").get(0);
orderNo = subOrderDetail.element("subOrderNo").getText();
currency = root.element("currency").getText();
payment = root.element("mileage").getText();
```


```java
Document payInfoDoc= DocumentHelper.parseText(msg);
String status = payInfoDoc.selectSingleNode("/returnPaymentInfo/orderInfo/status").getText().trim();
orderNo = payInfoDoc.selectSingleNode("/returnPaymentInfo/orderInfo/orderNo").getText().trim();
String uppPayNo = payInfoDoc.selectSingleNode("/returnPaymentInfo/orderInfo/uppPayNo").getText().trim();
String merPayNo=payInfoDoc.selectSingleNode("/returnPaymentInfo/orderInfo/merPayNo").getText().trim();
```

```java
Document document = new SAXReader().read(inputStream); //<configuation>
Element rootElement = document.getRootElement();
List<Element> propertyElements = rootElement.selectNodes("//property");
Properties properties = new Properties();
for (Element e : propertyElements) {
    String name = e.attributeValue("name");
    String value = e.attributeValue("value");
    properties.setProperty(name,value);
}
```

