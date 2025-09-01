Go 程序中 connect 系统调用总结
===============================

1. Go DNS 查询阶段（pure Go resolver）
---------------------------------------
- 使用 UDP socket 发送 DNS 查询
  socket(AF_INET, SOCK_DGRAM|SOCK_NONBLOCK, IPPROTO_IP)
  connect(fd, DNS_SERVER, 53)

- connect 在内核中执行，但由于非阻塞:
    - 返回 0 或 EINPROGRESS
    - 不阻塞 OS 线程
    - strace 可看到 connect 调用，但不会体现阻塞

- cgo resolver (调用 libc getaddrinfo) 可能会阻塞 OS 线程
    - connect / getaddrinfo 调用受系统超时控制

2. HTTP Client TCP 连接阶段
---------------------------
- 默认 TCP socket 使用非阻塞 + netpoller
    - connect 返回 EINPROGRESS
    - Go runtime 轮询等待连接完成
    - strace 能看到 connect，但线程不会被阻塞

- Keep-Alive 复用:
    - 后续请求复用已有 TCP socket
    - connect 不再触发

- 禁用 Keep-Alive:
  Transport: &http.Transport{ DisableKeepAlives: true }
    - 每次请求都会触发新的 TCP connect

3. strace 中 connect 的表现
---------------------------
- UDP connect (DNS):
    - 返回 0，很快完成
    - strace 显示 connect，但不阻塞
- TCP connect (HTTP):
    - 返回 EINPROGRESS
    - strace 显示 connect，但不阻塞
- 结论:
    - strace 捕获的是系统调用本身，而非阻塞状态

4. bpftrace 捕获 connect 的限制
---------------------------------
- Go 非阻塞 connect + netpoller 可能导致 tracepoint:connect 不触发
- TCP Keep-Alive socket 复用也会跳过 connect trace
- 捕获方法:
    - 关闭 Keep-Alive
    - 使用 USDT probe 或抓包 tcpdump
    - 对 DNS 查询可 attach libc getaddrinfo 或 trace UDP connect

5. 核心结论
-------------
- Go pure resolver connect 非阻塞，线程不阻塞，但 syscall 仍会执行 → 可被 strace 捕获
- TCP connect 也是非阻塞，第一次请求触发 connect，后续复用不再触发
- 如果需要监控域名和连接 IP:
    - Go 代码层打印 domain
    - bpftrace attach USDT probe
    - tcpdump 抓包