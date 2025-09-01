± |main ✓| → strace -e trace=network ./http-client   https://tv.springserve.com
--- SIGURG {si_signo=SIGURG, si_code=SI_TKILL, si_pid=2005822, si_uid=0} ---
Fetching URL: https://tv.springserve.com (HTTP/2 enabled: true)

socket(AF_INET, SOCK_DGRAM|SOCK_CLOEXEC|SOCK_NONBLOCK, IPPROTO_IP) = 6
setsockopt(6, SOL_SOCKET, SO_BROADCAST, [1], 4) = 0
connect(6, {sa_family=AF_INET, sin_port=htons(53), sin_addr=inet_addr("172.20.0.10")}, 16) = 0
getsockname(6, {sa_family=AF_INET, sin_port=htons(44742), sin_addr=inet_addr("10.28.54.152")}, [112->16]) = 0
getpeername(6, {sa_family=AF_INET, sin_port=htons(53), sin_addr=inet_addr("172.20.0.10")}, [112->16]) = 0
socket(AF_INET, SOCK_DGRAM|SOCK_CLOEXEC|SOCK_NONBLOCK, IPPROTO_IP) = 6
setsockopt(6, SOL_SOCKET, SO_BROADCAST, [1], 4) = 0
connect(6, {sa_family=AF_INET, sin_port=htons(53), sin_addr=inet_addr("172.20.0.10")}, 16) = 0
getsockname(6, {sa_family=AF_INET, sin_port=htons(60132), sin_addr=inet_addr("10.28.54.152")}, [112->16]) = 0
getpeername(6, {sa_family=AF_INET, sin_port=htons(53), sin_addr=inet_addr("172.20.0.10")}, [112->16]) = 0
socket(AF_INET, SOCK_DGRAM|SOCK_CLOEXEC|SOCK_NONBLOCK, IPPROTO_IP) = 6
setsockopt(6, SOL_SOCKET, SO_BROADCAST, [1], 4) = 0
connect(6, {sa_family=AF_INET, sin_port=htons(53), sin_addr=inet_addr("172.20.0.10")}, 16) = 0
getsockname(6, {sa_family=AF_INET, sin_port=htons(37276), sin_addr=inet_addr("10.28.54.152")}, [112->16]) = 0
getpeername(6, {sa_family=AF_INET, sin_port=htons(53), sin_addr=inet_addr("172.20.0.10")}, [112->16]) = 0
socket(AF_INET, SOCK_DGRAM|SOCK_CLOEXEC|SOCK_NONBLOCK, IPPROTO_IP) = 6
setsockopt(6, SOL_SOCKET, SO_BROADCAST, [1], 4) = 0
connect(6, {sa_family=AF_INET, sin_port=htons(9), sin_addr=inet_addr("107.22.208.203")}, 16) = 0
getsockname(6, {sa_family=AF_INET, sin_port=htons(51180), sin_addr=inet_addr("10.28.54.152")}, [112->16]) = 0
getpeername(6, {sa_family=AF_INET, sin_port=htons(9), sin_addr=inet_addr("107.22.208.203")}, [112->16]) = 0
socket(AF_INET, SOCK_DGRAM|SOCK_CLOEXEC|SOCK_NONBLOCK, IPPROTO_IP) = 6
setsockopt(6, SOL_SOCKET, SO_BROADCAST, [1], 4) = 0
connect(6, {sa_family=AF_INET, sin_port=htons(9), sin_addr=inet_addr("18.214.224.43")}, 16) = 0
getsockname(6, {sa_family=AF_INET, sin_port=htons(47063), sin_addr=inet_addr("10.28.54.152")}, [112->16]) = 0
getpeername(6, {sa_family=AF_INET, sin_port=htons(9), sin_addr=inet_addr("18.214.224.43")}, [112->16]) = 0
socket(AF_INET, SOCK_DGRAM|SOCK_CLOEXEC|SOCK_NONBLOCK, IPPROTO_IP) = 6
setsockopt(6, SOL_SOCKET, SO_BROADCAST, [1], 4) = 0
connect(6, {sa_family=AF_INET, sin_port=htons(9), sin_addr=inet_addr("23.23.153.107")}, 16) = 0
getsockname(6, {sa_family=AF_INET, sin_port=htons(34957), sin_addr=inet_addr("10.28.54.152")}, [112->16]) = 0
getpeername(6, {sa_family=AF_INET, sin_port=htons(9), sin_addr=inet_addr("23.23.153.107")}, [112->16]) = 0
socket(AF_INET, SOCK_DGRAM|SOCK_CLOEXEC|SOCK_NONBLOCK, IPPROTO_IP) = 6
setsockopt(6, SOL_SOCKET, SO_BROADCAST, [1], 4) = 0
connect(6, {sa_family=AF_INET, sin_port=htons(9), sin_addr=inet_addr("34.195.238.3")}, 16) = 0
getsockname(6, {sa_family=AF_INET, sin_port=htons(58319), sin_addr=inet_addr("10.28.54.152")}, [112->16]) = 0
getpeername(6, {sa_family=AF_INET, sin_port=htons(9), sin_addr=inet_addr("34.195.238.3")}, [112->16]) = 0
socket(AF_INET, SOCK_DGRAM|SOCK_CLOEXEC|SOCK_NONBLOCK, IPPROTO_IP) = 6
setsockopt(6, SOL_SOCKET, SO_BROADCAST, [1], 4) = 0
connect(6, {sa_family=AF_INET, sin_port=htons(9), sin_addr=inet_addr("54.243.45.189")}, 16) = 0
getsockname(6, {sa_family=AF_INET, sin_port=htons(40488), sin_addr=inet_addr("10.28.54.152")}, [112->16]) = 0
getpeername(6, {sa_family=AF_INET, sin_port=htons(9), sin_addr=inet_addr("54.243.45.189")}, [112->16]) = 0
socket(AF_INET, SOCK_DGRAM|SOCK_CLOEXEC|SOCK_NONBLOCK, IPPROTO_IP) = 6
setsockopt(6, SOL_SOCKET, SO_BROADCAST, [1], 4) = 0
connect(6, {sa_family=AF_INET, sin_port=htons(9), sin_addr=inet_addr("54.91.22.14")}, 16) = 0
getsockname(6, {sa_family=AF_INET, sin_port=htons(60956), sin_addr=inet_addr("10.28.54.152")}, [112->16]) = 0
getpeername(6, {sa_family=AF_INET, sin_port=htons(9), sin_addr=inet_addr("54.91.22.14")}, [112->16]) = 0
socket(AF_INET, SOCK_DGRAM|SOCK_CLOEXEC|SOCK_NONBLOCK, IPPROTO_IP) = 6
setsockopt(6, SOL_SOCKET, SO_BROADCAST, [1], 4) = 0
connect(6, {sa_family=AF_INET, sin_port=htons(9), sin_addr=inet_addr("54.84.57.166")}, 16) = 0
getsockname(6, {sa_family=AF_INET, sin_port=htons(52332), sin_addr=inet_addr("10.28.54.152")}, [112->16]) = 0
getpeername(6, {sa_family=AF_INET, sin_port=htons(9), sin_addr=inet_addr("54.84.57.166")}, [112->16]) = 0
socket(AF_INET, SOCK_DGRAM|SOCK_CLOEXEC|SOCK_NONBLOCK, IPPROTO_IP) = 6
setsockopt(6, SOL_SOCKET, SO_BROADCAST, [1], 4) = 0
connect(6, {sa_family=AF_INET, sin_port=htons(9), sin_addr=inet_addr("54.145.215.17")}, 16) = 0
getsockname(6, {sa_family=AF_INET, sin_port=htons(53363), sin_addr=inet_addr("10.28.54.152")}, [112->16]) = 0
getpeername(6, {sa_family=AF_INET, sin_port=htons(9), sin_addr=inet_addr("54.145.215.17")}, [112->16]) = 0
socket(AF_INET, SOCK_STREAM|SOCK_CLOEXEC|SOCK_NONBLOCK, IPPROTO_IP) = 6
connect(6, {sa_family=AF_INET, sin_port=htons(443), sin_addr=inet_addr("107.22.208.203")}, 16) = -1 EINPROGRESS (Operation now in progress)
--- SIGURG {si_signo=SIGURG, si_code=SI_TKILL, si_pid=2005822, si_uid=0} ---
--- SIGURG {si_signo=SIGURG, si_code=SI_TKILL, si_pid=2005822, si_uid=0} ---
--- SIGURG {si_signo=SIGURG, si_code=SI_TKILL, si_pid=2005822, si_uid=0} ---
--- SIGURG {si_signo=SIGURG, si_code=SI_TKILL, si_pid=2005822, si_uid=0} ---
Status: 200 OK
Status Code: 200
+++ exited with 0 +++