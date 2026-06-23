package main

import (
	"encoding/json"
	"log"
	"net/http"
)

var version = "dev"

type identity struct {
	Service string `json:"service"`
	Version string `json:"version"`
}

func rootHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
		return
	}
	b, err := json.Marshal(identity{Service: "hello", Version: version})
	if err != nil {
		http.Error(w, "internal error", http.StatusInternalServerError)
		return
	}
	w.Header().Set("Content-Type", "application/json")
	_, _ = w.Write(b)
}

func healthzHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
		return
	}
}

func newMux() *http.ServeMux {
	mux := http.NewServeMux()
	mux.HandleFunc("/", rootHandler)
	mux.HandleFunc("/healthz", healthzHandler)
	return mux
}

func main() {
	log.Println("listening on :8080")
	if err := http.ListenAndServe(":8080", newMux()); err != nil {
		log.Fatal(err)
	}
}
