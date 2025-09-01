# Connection Racing within the IPv4 Stack

Even when a Go application is configured to use only the IPv4 stack, `strace` or other tracing tools can reveal multiple `connect()` system calls for a single HTTP request. This is not an error but a deliberate performance optimization strategy employed by Go's `net.Dialer`.

### The "Why": DNS-Based Load Balancing

For high availability and load distribution, large services (e.g., `google.com`, `baidu.com`) associate a single hostname with a list of multiple IP addresses. A single DNS query for an `A` record can return this entire list.

### The "How": The "Happy Eyeballs" Philosophy for a Single Address Family

Instead of trying the IP addresses from the DNS response sequentially (which would be slow if the first server in the list is unresponsive), the Go dialer applies the same philosophy as "Happy Eyeballs" within the single address family:

1.  It receives the list of IPv4 addresses from the DNS resolver.
2.  It may initiate connection attempts to **multiple addresses from that list in parallel**.
3.  This creates a race: the first connection to be successfully established wins.
4.  All other pending connection attempts are immediately canceled.

### Benefit: Minimized Connection Latency

This strategy significantly reduces the time it takes to establish a connection by bypassing potentially slow, overloaded, or geographically distant servers. It ensures that the application connects to the most responsive server from the available pool, improving user-perceived performance.