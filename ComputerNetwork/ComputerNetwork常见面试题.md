# Computer Network常见面试题

##  http的请求过程

域名解析 --> 发起TCP的3次握手 --> 建立TCP连接后发起http请求 --> 服务器响应http请求，浏览器得到html代码 --> 浏览器解析html代码，并请求html代码中的资源（如js、css、图片等） --> 浏览器对页面进行渲染呈现给用户

## tcp的三次握手

## 用户是如何通过url地址访问到服务器的，它怎么知道要访问哪个ip

## http的请求头都有什么内容

## http与https的区别

## 网络的七层协议

## get和post的区别

## tcp和udp的区别，使用场景

### 什么时候应该使用TCP：

当对网络通讯质量有要求的时候，比如：整个数据要准确无误的传递给对方，这往往用于一些要求可靠的应用，比如HTTP、HTTPS、FTP等传输文件的协议，POP、SMTP等邮件传输的协议。 
在日常生活中，常见使用TCP协议的应用如下：

```
浏览器，用的HTTP
FlashFXP，用的FTP
Outlook，用的POP、SMTP
Putty，用的Telnet、SSH
QQ文件传输
```

### 什么时候应该使用UDP：

当对网络通讯质量要求不高的时候，要求网络通讯速度能尽量的快，这时就可以使用UDP。 
比如，日常生活中，常见使用UDP协议的应用如下：

```
QQ语音
QQ视频
TFTP
```

## TCP滑动窗口、慢启动，HTTP 2.0，断点续传，Quick协议，