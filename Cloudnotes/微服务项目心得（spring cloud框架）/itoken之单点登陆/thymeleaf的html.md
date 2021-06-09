
```
<!DOCTYPE html SYSTEM "http://www.thymeleaf.org/dtd/xhtml1-strict-thymeleaf-spring4-4.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:th="http://www.thymeleaf.org">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <title>我的商城 | 登录</title>
    <!-- Tell the browser to be responsive to screen width -->
    <meta content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" name="viewport">
    <!-- Bootstrap 3.3.7 -->
    <link rel="stylesheet" th:href="@{{adminlte}/bower_components/bootstrap/dist/css/bootstrap.min.css(adminlte=${adminlte})}">
    <!-- Font Awesome -->
    <link rel="stylesheet" th:href="@{{adminlte}/bower_components/font-awesome/css/font-awesome.min.css(adminlte=${adminlte})}">
    <!-- Ionicons -->
    <link rel="stylesheet" th:href="@{{adminlte}/bower_components/Ionicons/css/ionicons.min.css(adminlte=${adminlte})}">
    <!-- Theme style -->
    <link rel="stylesheet" th:href="@{{adminlte}/dist/css/AdminLTE.min.css(adminlte=${adminlte})}">
    <!-- iCheck -->
    <link rel="stylesheet" th:href="@{{adminlte}/plugins/iCheck/square/blue.css(adminlte=${adminlte})}">
</head>

<body class="hold-transition login-page">
<div class="login-box">
    <div class="login-logo">
        <a href="#">iToken</a>
    </div>
    <!-- /.login-logo -->

    <div class="login-box-body">
        <th:block th:if="${tbSysUser != null}">
            <p class="login-box-msg">欢迎 <span th:text="${tbSysUser.userName}"></span> 回来</p>
        </th:block>

        <th:block th:if="${tbSysUser == null}">
            <p class="login-box-msg">欢迎管理员登录</p>

            <form action="/login" method="post">
                <input type="hidden" name="url" th:value="${url}" />

                <div class="alert alert-danger alert-dismissible" th:if="${message != null}">
                    <button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button>
                    <span th:text="${message}"></span>
                </div>

                <div class="form-group has-feedback">
                    <input name="loginCode" type="email" class="form-control" placeholder="邮箱">
                    <span class="glyphicon glyphicon-envelope form-control-feedback"></span>
                </div>
                <div class="form-group has-feedback">
                    <input name="passWord" type="password" class="form-control" placeholder="密码">
                    <span class="glyphicon glyphicon-lock form-control-feedback"></span>
                </div>
                <div class="row">
                    <div class="col-xs-8">
                        <div class="checkbox icheck">
                            <label>
                                <input name="isRemember" type="checkbox"> 记住我
                            </label>
                        </div>
                    </div>
                    <!-- /.col -->
                    <div class="col-xs-4">
                        <button type="submit" class="btn btn-primary btn-block btn-flat">登录</button>
                    </div>
                    <!-- /.col -->
                </div>
            </form>

            <a href="#">忘记密码？</a><br>
        </th:block>
    </div>
</div>

<!-- HTML5 Shim and Respond.js IE8 support of HTML5 elements and media queries -->
<!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
<!--[if lt IE 9]>
<script src="https://oss.maxcdn.com/html5shiv/3.7.3/html5shiv.min.js"></script>
<script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
<![endif]-->

<!-- jQuery 3 -->
<script th:src="@{{adminlte}/bower_components/jquery/dist/jquery.min.js(adminlte=${adminlte})}"></script>
<!-- Bootstrap 3.3.7 -->
<script th:src="@{{adminlte}/bower_components/bootstrap/dist/js/bootstrap.min.js(adminlte=${adminlte})}"></script>
<!-- iCheck -->
<script th:src="@{{adminlte}/plugins/iCheck/icheck.min.js(adminlte=${adminlte})}"></script>
<script>
    $(function () {
        $('input').iCheck({
            checkboxClass: 'icheckbox_square-blue',
            radioClass: 'iradio_square-blue',
            increaseArea: '20%' /* optional */
        });
    });
</script>
</body>

</html>
```
