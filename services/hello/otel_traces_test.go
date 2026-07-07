package main

import (
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/attribute"
	"go.opentelemetry.io/otel/sdk/resource"
	sdktrace "go.opentelemetry.io/otel/sdk/trace"
	"go.opentelemetry.io/otel/sdk/trace/tracetest"
	semconv "go.opentelemetry.io/otel/semconv/v1.41.0"
)

// newTestTracerProvider installs an InMemoryExporter-backed TracerProvider as
// the global provider for the duration of the test, restoring the previous
// global provider on cleanup.
func newTestTracerProvider(t *testing.T) *tracetest.InMemoryExporter {
	t.Helper()
	prev := otel.GetTracerProvider()
	t.Cleanup(func() { otel.SetTracerProvider(prev) })

	exporter := tracetest.NewInMemoryExporter()
	res := resource.NewSchemaless(
		semconv.ServiceName("hello"),
		semconv.ServiceVersion("test-version"),
	)
	tp := sdktrace.NewTracerProvider(
		sdktrace.WithSyncer(exporter),
		sdktrace.WithResource(res),
	)
	otel.SetTracerProvider(tp)
	return exporter
}

// findSpanAttribute locates the value of the named attribute on a span, or
// fails the test if it's missing.
func findSpanAttribute(t *testing.T, attrs []attribute.KeyValue, key attribute.Key) attribute.Value {
	t.Helper()
	for _, kv := range attrs {
		if kv.Key == key {
			return kv.Value
		}
	}
	t.Fatalf("attribute %q not found", key)
	return attribute.Value{}
}

func TestOtelRootGET_RecordsSpan(t *testing.T) {
	exporter := newTestTracerProvider(t)

	rec := httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodGet, "/", nil)
	newMux().ServeHTTP(rec, req)
	assert.Equal(t, http.StatusOK, rec.Code)

	spans := exporter.GetSpans()
	require.Len(t, spans, 1)
	span := spans[0]
	assert.Equal(t, "root", span.Name)

	statusCode := findSpanAttribute(t, span.Attributes, semconv.HTTPResponseStatusCodeKey)
	assert.Equal(t, int64(http.StatusOK), statusCode.AsInt64())

	name, ok := span.Resource.Set().Value(semconv.ServiceNameKey)
	require.True(t, ok, "service.name attribute must be set")
	assert.Equal(t, "hello", name.AsString())

	version, ok := span.Resource.Set().Value(semconv.ServiceVersionKey)
	require.True(t, ok, "service.version attribute must be set")
	assert.Equal(t, "test-version", version.AsString())
}

func TestOtelRootPOST_405StillRecordsSpan(t *testing.T) {
	exporter := newTestTracerProvider(t)

	rec := httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodPost, "/", nil)
	newMux().ServeHTTP(rec, req)
	assert.Equal(t, http.StatusMethodNotAllowed, rec.Code)

	spans := exporter.GetSpans()
	require.Len(t, spans, 1)
	span := spans[0]
	assert.Equal(t, "root", span.Name)

	statusCode := findSpanAttribute(t, span.Attributes, semconv.HTTPResponseStatusCodeKey)
	assert.Equal(t, int64(http.StatusMethodNotAllowed), statusCode.AsInt64())
}
