package main

import (
	"fmt"
	"net/http"
)

func stupidLoggerMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		fmt.Println(r.URL)
		// Our middleware logic goes here...
		next.ServeHTTP(w, r)
	})
}

func main() {
	http.Handle("/", stupidLoggerMiddleware(http.FileServer(http.Dir("./"))))
	// Only ever listen on the nebula IP, burned into the binary.
	// Never, ever listen on anything widely exposed
	err := http.ListenAndServe("{{ nebula_ip }}:{{ listen_port }}", nil)
	if err != nil {
		fmt.Println("listen error", err)
	}
}
