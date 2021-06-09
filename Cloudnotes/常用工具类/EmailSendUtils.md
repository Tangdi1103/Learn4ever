
```
import org.apache.commons.mail.Email;
import org.apache.commons.mail.EmailException;
import org.springframework.beans.factory.annotation.Autowired;


/**
 * 邮件发送工具类
 * <p>Title: EmailSendUtils</p>
 * <p>Description: </p>
 *
 * @author Tangdi
 * @version 1.0.0
 * @date 2018/7/8 15:35
 */

public class EmailSendUtils {
    @Autowired
    private Email email;

    public void send(String subject, String msg, String... to) throws EmailException {
        email.setSubject(subject);
        email.setMsg(msg);
        email.addTo(to);
        email.send();
    }

}

```
