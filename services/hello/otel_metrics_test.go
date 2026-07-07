package main

import (
	"context"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/sdk/metric"
	"go.opentelemetry.io/otel/sdk/metric/metricdata"
	semconv "go.opentelemetry.io/otel/semconv/v1.41.0"
)

// newTestMeterProvider installs a ManualReader-backed MeterProvider as the
// global provider for the duration of the test, restoring the previous
// global provider on cleanup.
func newTestMeterProvider(t *testing.T) *metric.ManualReader {
	t.Helper()
	prev := otel.GetMeterProvider()
	t.Cleanup(func() { otel.SetMeterProvider(prev) })

	reader := metric.NewManualReader()
	otel.SetMeterProvider(metric.NewMeterProvider(metric.WithReader(reader)))
	return reader
}

// findHistogramDataPoint locates the single data point recorded for the
// named histogram instrument, or fails the test if it's missing or
// ambiguous.
func findHistogramDataPoint(t *testing.T, rm metricdata.ResourceMetrics, name string) metricdata.HistogramDataPoint[float64] {
	t.Helper()
	for _, sm := range rm.ScopeMetrics {
		for _, m := range sm.Metrics {
			if m.Name != name {
				continue
			}
			hist, ok := m.Data.(metricdata.Histogram[float64])
			require.True(t, ok, "metric %q is not a float64 histogram", name)
			require.Len(t, hist.DataPoints, 1, "expected exactly one data point for %q", name)
			return hist.DataPoints[0]
		}
	}
	t.Fatalf("no metric named %q was recorded", name)
	return metricdata.HistogramDataPoint[float64]{}
}

func collect(t *testing.T, reader *metric.ManualReader) metricdata.ResourceMetrics {
	t.Helper()
	var rm metricdata.ResourceMetrics
	require.NoError(t, reader.Collect(context.Background(), &rm))
	return rm
}

func TestOtelRootGET_RecordsMetric(t *testing.T) {
	reader := newTestMeterProvider(t)

	rec := httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodGet, "/", nil)
	newMux().ServeHTTP(rec, req)
	assert.Equal(t, http.StatusOK, rec.Code)

	dp := findHistogramDataPoint(t, collect(t, reader), "http.server.request.duration")
	statusCode, ok := dp.Attributes.Value(semconv.HTTPResponseStatusCodeKey)
	require.True(t, ok, "http.response.status_code attribute must be present")
	assert.Equal(t, int64(http.StatusOK), statusCode.AsInt64())
}

func TestOtelRootPOST_405StillRecordsMetric(t *testing.T) {
	reader := newTestMeterProvider(t)

	rec := httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodPost, "/", nil)
	newMux().ServeHTTP(rec, req)
	assert.Equal(t, http.StatusMethodNotAllowed, rec.Code)

	dp := findHistogramDataPoint(t, collect(t, reader), "http.server.request.duration")
	statusCode, ok := dp.Attributes.Value(semconv.HTTPResponseStatusCodeKey)
	require.True(t, ok, "http.response.status_code attribute must be present")
	assert.Equal(t, int64(http.StatusMethodNotAllowed), statusCode.AsInt64())
}

func TestOtelHealthz_NoMetricsRecorded(t *testing.T) {
	for _, method := range []string{http.MethodGet, http.MethodPost} {
		t.Run(method, func(t *testing.T) {
			reader := newTestMeterProvider(t)

			rec := httptest.NewRecorder()
			req := httptest.NewRequest(method, "/healthz", nil)
			newMux().ServeHTTP(rec, req)

			rm := collect(t, reader)
			for _, sm := range rm.ScopeMetrics {
				for _, m := range sm.Metrics {
					t.Fatalf("expected no metrics for /healthz, got %q", m.Name)
				}
			}
		})
	}
}
