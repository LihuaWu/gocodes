package main

import (
	"fmt"
	"io"
	"log"
	"net/http"
	"net/http/httptest"
	"strings"
	"time"
)

func main() {
	// 1. 设置一个模拟的 HTTP 服务器
	// /slow 路径会根据 'delay' 参数延迟响应
	// /fast 路径会立即响应
	ts := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		switch r.URL.Path {
		case "/slow":
			// 从查询参数获取延迟时间
			delayStr := r.URL.Query().Get("delay")
			delay, err := time.ParseDuration(delayStr)
			if err != nil {
				http.Error(w, "Invalid delay parameter", http.StatusBadRequest)
				return
			}
			log.Printf("【服务器】收到 /slow 请求，将延迟响应 %v...", delay)
			time.Sleep(delay) // 模拟长时间处理
			fmt.Fprintf(w, "Hello from slow server after %v!", delay)
			log.Printf("【服务器】/slow 请求在 %v 后完成响应。", delay)
		case "/fast":
			log.Println("【服务器】收到 /fast 请求，立即响应。")
			fmt.Fprintf(w, "Hello from fast server!")
			log.Println("【服务器】/fast 请求已完成响应。")
		default:
			http.Error(w, "Not Found", http.StatusNotFound)
		}
	}))
	defer ts.Close() // 确保服务器在程序结束时关闭

	// 2. 创建一个设置了Timeout的 http.Client
	// 客户端超时设置为 2 秒
	clientTimeout := 2 * time.Second
	client := &http.Client{
		Timeout: clientTimeout, // 设置客户端全局超时 [2]
	}
	log.Printf("【客户端】创建 http.Client，全局超时设置为: %v\n", clientTimeout)

	// --- 第一个请求：预期超时失败 ---
	log.Println("\n--- 开始第一个请求 (预期超时失败) ---")
	slowRequestDelay1 := 3 * time.Second // 延迟时间大于客户端超时
	url1 := fmt.Sprintf("%s/slow?delay=%s", ts.URL, slowRequestDelay1.String())
	resp1, err1 := client.Get(url1)
	if err1 != nil {
		log.Printf("【客户端】第一个请求失败，符合预期: %v\n", err1)
		// 检查错误信息是否包含超时关键字 [3]
		if strings.Contains(err1.Error(), "context deadline exceeded") || strings.Contains(err1.Error(), "Client.Timeout exceeded") {
			log.Println("【客户端】第一个请求明确达到了客户端超时限制。")
		}
	} else {
		defer resp1.Body.Close()
		body1, _ := io.ReadAll(resp1.Body)
		log.Printf("【客户端】第一个请求成功 (意外情况): Status=%d, Body=%s\n", resp1.StatusCode, body1)
	}

	// 稍作等待，让服务器端有机会清理第一个请求的连接，避免对后续请求造成不必要的干扰。
	time.Sleep(100 * time.Millisecond)

	// --- 第二个请求：预期成功 (证明超时不会累加) ---
	log.Println("\n--- 开始第二个请求 (预期成功) ---")
	url2 := fmt.Sprintf("%s/fast", ts.URL)
	resp2, err2 := client.Get(url2)
	if err2 != nil {
		log.Printf("【客户端】第二个请求失败 (意外情况): %v\n", err2)
	} else {
		defer resp2.Body.Close()
		body2, _ := io.ReadAll(resp2.Body)
		log.Printf("【客户端】第二个请求成功，符合预期: Status=%d, Body=%s\n", resp2.StatusCode, body2)
	}

	// --- 第三个请求：预期成功 (证明超时是针对每个请求独立计算的) ---
	log.Println("\n--- 开始第三个请求 (预期成功，延迟时间在超时范围内) ---")
	shortSlowRequestDelay := 1 * time.Second // 延迟时间小于客户端超时
	url3 := fmt.Sprintf("%s/slow?delay=%s", ts.URL, shortSlowRequestDelay.String())
	resp3, err3 := client.Get(url3)
	if err3 != nil {
		log.Printf("【客户端】第三个请求失败 (意外情况): %v\n", err3)
	} else {
		defer resp3.Body.Close()
		body3, _ := io.ReadAll(resp3.Body)
		log.Printf("【客户端】第三个请求成功，符合预期: Status=%d, Body=%s\n", resp3.StatusCode, body3)
	}
}
