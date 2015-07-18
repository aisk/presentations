title: Python 异步编程与 async / await
author:
  name: 艾斯昆
  twitter: 艾斯昆
  url: http://aisk.me
theme: jdan/cleaver-retro
output: target/python-async-await.html

--

# Who am I?

- Pythonista
- Works @ [LeanCloud](http://leancloud.cn/)

--

# Python 异步编程与 async / await

--

# 历史

- Twisted
- tornado
- gevent
- asyncio

--

### Twisted

- 优点：
  - 历史久远（2000 ~ ）
  - 严谨
  - 协议支持广泛（HTTP, FTP, SMTP, POP3, IMAP4, DNS, IRC, MSN, OSCAR, XMPP/Jabber, telnet, SSH, SSL, NNTP）

--

### Twisted

- 缺点：
  - **Not Pythonic** (Javanic?)
  - Callback hell
  - 第三方 io 库需要重写

--

### tornado

- 优点：
  - 轻量级
  - 内置比较好用的 web framework

--

### tornado

- 缺点：
  - Callback hell
  - 第三方 io 库需要重写

--

### gevent

- 优点
  - monkey patch （复用现有第三方 io 库）
  - 协程支持（no more callback hell）

--

## gevent

- 缺点
  - too hacky（导致侵入性强）
  - 协程实现依赖 greenlet（非标准）

--

## 理想中的 Python 异步编程？

- 丰富的第三方 io 库
  - 可直接兼容现有 io 库？
  - 成为一个标准的 event loop？

- 协程支持

--

# Python 给出的解决方案：

--

# asyncio + async / await

--

### asyncio

- PEP-3156
- Python 3.4 +

虽然不能复用现有 io 库，但作为一个 Python 内置标准库，生态圈应该会比 Tornado 等异步网络编程框架好。

--

# 协程？

--

### 曾经的 yield (generator)

可以挂起当前函数执行，等待异步 io 结束之后再次唤醒。

```python
def say_hello():
    name = yield
    print('Hello, {}!'.format(name))
    yield

g = say_hello()
next(g)
g.send('Asaka')
```

--

### yield 缺点

yield 只能将控制权转交给外部调用者。

比如前面的 `say_hello` 函数，我们需要将其封装一下，打印完 hello 之后打印 goodbye：

```python
def say_hello_and_goodbye():
    name = yield
    g = say_hello()
    next(g)
    g.send(name)
    print('Goodbye.')
    yield
```

只是简单的封装，比 `say_hello` 本身还要长。

--

# WTF

--

### yield from

- PEP-380
- Python 3.3

可将控制权任意传递。

--

### 依然是上面的例子

```python
def say_hello_and_goodbye():
  yield from say_hello()
  print('Goodbye.')
  yield
```

就是这么简单。

--

# yield from 也有缺点？

--

### 某天需求变更

`say_hello` 不需要传入 `name` 变量

- 殴打产品经理
- 修改代码：
  ```python
  def say_hello():
      print('Hello, world!')
  ```
- 发布
- 吃着火车唱着锅

--

```
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "<stdin>", line 2, in say_hello_and_goodbye
TypeError: 'NoneType' object is not iterable
```

……然后服务器就挂了，WTF

--

### 问题所在

调用一个函数前，不知道是正常函数返回，还是 generator 返回，不知道正确的调用姿势。
重构时容易遗漏。

--

### async / await

- PEP-0492
- Python 3.5（Beta2 发布）
- 最先在 C# 上实现
- JavaScript ES7 中也有实现
- 与 yield from 原理相同
- 明确区分 generator 与 coroutine 两个概念（对于新人来讲很难理解 generator 与 coroutine 的联系）
- 更好的与现有语法适配

--

### 还是之前的例子

```python
async def say_hello():
    name = await
    print('Hello, {}!'.format(name))

async def say_hello_and_goodbye():
    await say_hello()
    print('Goodbye.')
```

await 只能在声明为 async 的函数中使用，否则会抛出 SyntaxError。

--

# Fail Fast, Fail Often.

--

# LeanCloud 现在的解决方案

--

### LeanCloud

- Mobile Backend as a Service
- 直接提供 HTTP API 给客户端调用
- 复杂的逻辑和必须在服务端执行的逻辑，用户可直接上传自己的代码来执行
- 支持 Node.js & Python

--

### LeanCloud

- 高并发
- 大部分用户习惯使用 Python2，并且 Python 3.5 还未正式发布
- 暂时使用 gevent 的方案，正在计划支持 Python3, asyncio + async/await

--

# 完

## 人生苦短，我用 Python

--

# ![](http://ww1.sinaimg.cn/large/46b69fecjw1eu7ips7v3lj20g00nwdh9.jpg)
