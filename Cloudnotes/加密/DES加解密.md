
```

解密验签
/**
     * DES解密签名
     *
     * @param returnEncodeMsg 加密的报文信息
     * @param returnSignMsg   加密的签名信息
     * @return UPP报文明文
     * @throws Exception
     */
    private String decryptAndVerify(String returnEncodeMsg, String returnSignMsg) {
        Security s = new Security();
        String sourceText;
        if (s.decryptMsg(callBackPassword)) {
            String merPwd = s.getResultMsg();
            if (s.decryptMsg(returnEncodeMsg)) {
                sourceText = s.getResultMsg();
                if (s.verifyMsg(sourceText, returnSignMsg, merPwd)) {
                    return sourceText;
                }
            }
        }
        throw new RuntimeException("UPP验签失败！");
    }
```
