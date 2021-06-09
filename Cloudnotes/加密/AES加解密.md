#### AES加密算法
- 是一种对称的加密算法
- 使用步骤：1.加密报文；2签名处理；
- 签名处理时，使用的是密钥明文


##### 加密
```
 /**
     * 加密参数
     * 注意:UPP以往的支付接口，是用编码后的报文做签名，收银台这个由于是不同人开发的，要改成用加密后的报文去签名
     * @param xml UTF-8 编码后的XML
     * @return 加密参数
     */
    protected String encryptString(String xml){
        String encodedStr = URLEncoder.encode(xml, "UTF-8");//编码处理
        getSecurityAES().encryptMsg(encodedStr);//加密处理
        return getSecurityAES().getResultMsg();
    }

    /**
     * 签名处理
     * @param xml 加密后的报文
     * @return 签名
     */
    protected String signString(String xml){
        getSecurityAES().signMsg(xml, getPassWord());//签名处理
        return getSecurityAES().getResultMsg();
    }
    
    private SecurityAES getSecurityAES() {
        if (securityAES == null) {
            if (decryptPwd == null) {
                decryptPwd = getPassWord();
            }
            securityAES = new SecurityAES(decryptPwd);
        }
        return securityAES;
    }


    private String getPassWord() {
        if (StringUtils.isBlank(decryptPwd)) {
            SecurityAES aes = new SecurityAES();
            aes.decryptMsg(encryptPwd);// AES解密加密的密钥
            decryptPwd = aes.getResultMsg();// 密钥明文
        }
        return decryptPwd;
    }
```

##### 解密验签

```
private String decryptAndVerifyAES(String returnEncodeMsg, String returnSignMsg) {
        String sourceText;
        SecurityAES sAES = new SecurityAES();
        if (sAES.decryptMsg(encryptPwd)) {
            String merPwd = sAES.getResultMsg();
            sAES = new SecurityAES(merPwd);
            if (sAES.decryptMsg(returnEncodeMsg)) {
                sourceText = sAES.getResultMsg();
                if (sAES.verifyMsg(sourceText, returnSignMsg, merPwd)) {
                    return sourceText;
                }
            }
        }
        throw new RuntimeException("UPP里程支付回调验签失败！");
    }
```
