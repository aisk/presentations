# Gevent 简介

asaka@LeanCloud

---

## code

*以下均为伪代码*

```python
def get_data():
    time.sleep(10)
    # or query mysql / send http request
    return {}

@app.get('/')
def index(request):
    return render('index.html', data=get_data())
```

---

## run it

```python
server = socket.listen('http://localhost:8080')

while True:
    client = socket.accept()
    request = client.parse_http()
    if request.url.match('/'):
        result = index(request)
        client.write(result)
```

---

- 用户 A 请求
  - -> `index(request)`
  - -> `get_data()`
  - -> `time.sleep(10)`
- 用户 B 请求
  - -> **BLOCKED!**

---

## multi process

```python
server = socket.listen('http://localhost:8080')

for i in xrange(4):
  fork()

# now we have 4 process to run the code below:

while True:
    client = socket.accept()
    request = client.parse_http()
    if request.url.match('/'):
        result = index(request)
        client.write(result)
```

---

- 用户 A 请求
  - -> `time.sleep(10)`
- 用户 B 请求
  - -> `time.sleep(10)`
- 用户 C 请求
  - -> `time.sleep(10)`
- 用户 D 请求
  - -> `time.sleep(10)`

- 用户 E 请求
  - -> **BLOCKED!**

---

### muilti process problem

- 不能无限多开进程
  - 进程上下文切换成本较高（内核调度）
  - 每个进程单独占用内存
    - 进程本身占用
    - Python本身占用
    - 代码本身占用
  - 其他资源限制

---

## multi thread

```python
server = socket.listen('http://localhost:8080')

while True:
    client = socket.accept()
    def handler(client):
      request = client.parse_http()
      if request.url.match('/'):
          result = index(request)
          client.write(result)
    threading.run(handler, client)
```

---

### multi thread problem

- 不能无限多开进程
  - 进程创建成本较高
  - 进程上下文切换成本较高
  - 每个进程单独占用内存
- Python GIL 限制
  - （不过会在 sleep / IO 的时候切换到其他线程执行）

---

## 异步 IO

```python
loop = eventloop('http://localhost:8080')

while True:
    event = loop.get_event()
    if event.type == 'get_new_connection':
        data = event.read()
        request = parse_http(data)
        request.url == '/':
            response = index(request)
            loop.register_write_event(response, event)
    if event.type == 'ready_for_write':
        event.write(event.data)
```

---

### I can't sleep!

```python
def get_data():
    time.sleep(10)  # BLOCKED THE EVENT LOOP!
    return {}
```

---

### async callback

```python
def settimeout(duration, callback):
    # register an event to the event loop
    # and when the event is fired, let the
    # event loop call the `callback`
```

```python
def request_socket(url, data, callback):
    sock = socket.connect(url)
    socket.setnonblock(sock)
    write(sock, data)
    # register an event to the event loop
    # while the sock is readable, and call
    # the callback with response data
```

---

### sync

```python
@app.get('/')
def index():
    data1 = get_data1()
    data2 = get_data2(data1)
    data3 = get_data3(data2)
    return data3
```

---

### async

```python
@app.get('/')
def index(response):
    get_data1(response, callback=after_get_data1)

def after_get_data1(response, data1):
    get_data2(response, data1, callback=after_get_data2)

def after_get_data2(response, data2):
    get_data3(response, data2, callback=after_get_data3)

def after_get_data3(response, data3):
    response.send(data3)
```
👆 Like node.js / tornado

---

### async callback problem

- 代码难读／难写
- 丢失错误调用栈

---

## 协程(greenlet)

```python
from greenlet import greenlet
 
def test1():
    print 12
    gr2.switch()
    print 34
 
def test2():
    print 56
    gr1.switch()
    print 78
 
gr1 = greenlet(test1)
gr2 = greenlet(test2)
gr1.switch()
```

---

### 协程优点

- 主动让出
  - 不需要锁
  - 调度开销低（用户态切换）
- 资源占用少
  - 内存
  - 调度开销

---

### 协程 + 异步IO

- 在调用需要 callback 的异步方法时，切换到另外一个协程
- 在异步方法调用完毕，恢复此协程运行状态

---

### code

```python
def get_data():
    time.sleep(10)
    # or query mysql / send http request
    return {}

@app.get('/')
def index(request):
    return render('index.html', data=get_data())
```

---

- 用户 A 请求
  - time.sleep(10)
  - 协程切换
- 用户 B 请求
  - time.sleep(10)
  - 协程切换
- 处理用户 A 的 sleep 完毕
  - 响应用户
- 处理用户 B 的 sleep 完毕
  - 响应应用

---

## gevent

gevent = eventloop + 协程 + monkey patch

---

### monkey patch

- 在标准库中所有会阻塞调用函数
  - 设置成非阻塞
  - 切换协程
- socket
- threading
- time.sleep
