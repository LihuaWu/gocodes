# Performance Concerns of "Happy Eyeballs" in High Concurrency

The "Happy Eyeballs" algorithm (RFC 8305) is designed to minimize user-perceived connection latency on dual-stack (IPv4/IPv6) networks by racing connection attempts. While effective for client applications, this strategy has significant performance implications in high-concurrency services.

The fundamental trade-off of Happy Eyeballs is **prioritizing the latency of individual connections over the efficient use of aggregate system resources.**

### 1. Socket/File Descriptor Pressure

This is the most critical concern. For every outgoing connection to a dual-stack host, the algorithm may briefly open **two** sockets (one for IPv4, one for IPv6).

*   **Impact:** In a service handling thousands of requests per second, this can lead to **double the number of file descriptors** being consumed during the brief connection phase. This can rapidly lead to resource exhaustion and `too many open files` errors if the system's `ulimit` is not tuned for this workload.

### 2. Increased DNS Traffic

To race both connection types, the client must first perform DNS lookups for both `A` (IPv4) and `AAAA` (IPv6) records.

*   **Impact:** This effectively **doubles the query load** on your DNS infrastructure. While often negligible, in a very high-throughput environment, this can become a bottleneck or a notable operational cost.

### 3. Wasted Work (CPU and Network)

For every successful connection, there was another connection attempt that was initiated and then immediately canceled.

*   **Impact:** This represents a small but non-zero amount of wasted CPU cycles and network packets. At a massive scale, this aggregate waste can become a measurable source of system overhead.

### Conclusion

Due to these concerns, services operating at high concurrency often require the ability to disable Happy Eyeballs and force a single network stack (e.g., IPv4-only). This sacrifices the lowest possible latency on unpredictable networks for more stable, predictable, and efficient resource utilization.