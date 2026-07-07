package main

import (
	"context"
	"encoding/json"
	"errors"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/ollibolli/universal/services/hello/internal/telemetry"
	"go.opentelemetry.io/contrib/instrumentation/net/http/otelhttp"
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
	mux.Handle("/", otelhttp.NewHandler(
		http.HandlerFunc(rootHandler),
		"root",
		// otelhttp's default span name formatter ignores the operation name
		// and derives "{method} {route}" instead; use the operation verbatim
		// so the span is tagged "root" as required.
		otelhttp.WithSpanNameFormatter(func(operation string, r *http.Request) string {
			return operation
		}),
	))
	mux.HandleFunc("/healthz", healthzHandler)
	return mux
}

func main() {
	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()

	shutdown, err := telemetry.Setup(ctx, version)
	if err != nil {
		log.Fatal(err)
	}

	tracesShutdown, err := telemetry.SetupTraces(ctx, version)
	if err != nil {
		log.Fatal(err)
	}

	srv := &http.Server{Addr: ":8080", Handler: newMux()}
	go func() {
		log.Println("listening on :8080")
		if err := srv.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
			log.Fatal(err)
		}
	}()

	<-ctx.Done()
	stop()

	srvShutdownCtx, srvCancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer srvCancel()
	if err := srv.Shutdown(srvShutdownCtx); err != nil {
		log.Println("server shutdown:", err)
	}

	telemetryShutdownCtx, telemetryCancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer telemetryCancel()
	if err := shutdown(telemetryShutdownCtx); err != nil {
		log.Println("telemetry shutdown:", err)
	}

	tracesShutdownCtx, tracesCancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer tracesCancel()
	if err := tracesShutdown(tracesShutdownCtx); err != nil {
		log.Println("traces shutdown:", err)
	}
}
