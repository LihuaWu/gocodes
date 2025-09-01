### **Design: A Layered Model of Go HTTP Timeouts**

This design organizes timeout scenarios based on the layer of the Go networking stack where they are configured and enforced. It separates the "happy path" (how things are supposed to work) from the "failure analysis" (how things can break).

#### **Part 1: The Layers of Control**

This part describes the primary timeout mechanisms, from the highest level of abstraction (the user's intent) down to the low-level network operations.

**Layer 1: The Application Layer — The Overall Deadline**
*   **Concept:** This layer represents the total time budget for the entire operation. It answers the question: "How long am I willing to wait for this entire task?"
*   **Primary Tool:** `context.Context`. A `context` with a timeout is the canonical way to enforce an overall time limit, designed to be passed down through all subsequent layers.
*   **Scenario to Demonstrate:**
    *   **1. The Master Clock:** A request with a `context` timeout is made to a server that is slow to write its response body. The request is cancelled mid-body-read, proving the `context` monitors the entire duration.

**Layer 2: The Transport Layer — Phase-Specific Deadlines**
*   **Concept:** This layer handles the mechanics of an individual HTTP transaction and offers granular timeouts for specific phases.
*   **Scenarios to Demonstrate:**
    *   **2. TLS Handshake Timeout:** Using `transport.TLSHandshakeTimeout`, we will show a timeout occurring after a successful TCP connection but during the security negotiation.
    *   **3. Response Header Timeout:** Using `transport.ResponseHeaderTimeout`, we will show a timeout caused by a server that is slow to begin sending a response.

**Layer 3: The Network Connection Layer — Connection Establishment**
*   **Concept:** This layer is responsible for the most fundamental step: establishing the raw network connection.
*   **Primary Tool:** `net.Dialer.Timeout`.
*   **Scenario to Demonstrate:**
    *   **4. Dial Timeout:** The client attempts to connect to an unreachable IP address. We will configure `dialer.Timeout` to show the connection attempt itself failing with a timeout.

---

#### **Part 2: Failure Analysis — When Layers Don't Cooperate**

This part explores scenarios where timeout mechanisms fail or interact in unexpected ways.

**Failure Scenario 1: Context Ignored by Blocking DNS Call (via Monkey-Patching)**
*   **Concept:** Go's `context` is cooperative. If a function in the call stack enters an uninterruptible, blocking state (as can happen with `cgo`-based DNS resolvers), the context's cancellation signal will be ignored. We can reliably demonstrate this by using `gomonkey` to replace the real DNS lookup function with a mock that simulates a perfect, uninterruptible block.
*   **Demonstration Design:**
    *   **Tooling:** This test requires the `github.com/agiledragon/gomonkey` library.
    *   **Mocking Strategy:** In a Go test, use `gomonkey.ApplyFunc` to patch the `net.lookupHost` function. The replacement function will be a simple `func` that blocks indefinitely by reading from a channel that is never written to.
    *   **Execution:**
        1.  Create an `http.Client` request to any hostname.
        2.  Wrap the `client.Do(req)` call in a `context.WithTimeout` of 1 second.
        3.  Run the test using the required build flags to disable compiler optimizations for `gomonkey`: `go test -gcflags="all=-N -l"`.
    *   **Expected Outcome:** The program will **hang** indefinitely, ignoring the 1-second context deadline. This proves that when a function called by the HTTP client is uninterruptibly blocked, the `context` is powerless.

**Failure Scenario 2: The Multi-Layer Timeout Race**
*   **Concept:** Timeouts at different layers (`context`, `transport`, `dialer`) are independent timers. When multiple timeouts are active on a single request, they "race," and **the first one to expire cancels the request.**
*   **Demonstration:** We will construct a scenario with timeouts configured at all three layers and show which one wins.
    *   **Setup:** Create a client with the following configuration:
        *   Layer 1 (Application): `context.WithTimeout` set to **3 seconds**.
        *   Layer 2 (Transport): `transport.ResponseHeaderTimeout` set to **2 seconds**.
        *   Layer 3 (Network): `dialer.Timeout` set to **1 second**.
    *   **Execution:** Make a request to a non-routable IP address.
    *   **Expected Outcome:** The request will fail after approximately **1 second**. The error will be an `i/o timeout`, indicating that the shortest timeout—the `dialer.Timeout` from the Network Layer—won the race. We can then alter the mock and timeout values to demonstrate other layers winning in turn.

---
