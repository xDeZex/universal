package telemetry

import (
	"context"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"go.opentelemetry.io/otel"
	semconv "go.opentelemetry.io/otel/semconv/v1.41.0"
)

func TestNewResource_SetsServiceNameAndVersion(t *testing.T) {
	res, err := newResource(context.Background(), "hello", "abc123")
	require.NoError(t, err)

	name, ok := res.Set().Value(semconv.ServiceNameKey)
	require.True(t, ok, "service.name attribute must be set")
	assert.Equal(t, "hello", name.AsString())

	version, ok := res.Set().Value(semconv.ServiceVersionKey)
	require.True(t, ok, "service.version attribute must be set")
	assert.Equal(t, "abc123", version.AsString())
}

func TestSetup_SucceedsAndReturnsWorkingShutdown(t *testing.T) {
	prev := otel.GetMeterProvider()
	t.Cleanup(func() { otel.SetMeterProvider(prev) })

	t.Setenv("OTEL_SERVICE_NAME", "hello-test")
	// A closed local port fails fast (connection refused) instead of hanging
	// on an unreachable default endpoint, keeping the test bounded.
	t.Setenv("OTEL_EXPORTER_OTLP_ENDPOINT", "http://127.0.0.1:1")

	shutdown, err := Setup(context.Background(), "test-version")
	require.NoError(t, err)
	require.NotNil(t, shutdown)

	ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
	defer cancel()
	_ = shutdown(ctx) // export failure (collector unreachable) is expected; must not hang or panic
}
