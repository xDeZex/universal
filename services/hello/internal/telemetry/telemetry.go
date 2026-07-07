package telemetry

import (
	"context"
	"os"

	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/exporters/otlp/otlpmetric/otlpmetrichttp"
	"go.opentelemetry.io/otel/sdk/metric"
	"go.opentelemetry.io/otel/sdk/resource"
	semconv "go.opentelemetry.io/otel/semconv/v1.41.0"
)

func newResource(ctx context.Context, serviceName, serviceVersion string) (*resource.Resource, error) {
	return resource.New(ctx,
		resource.WithAttributes(
			semconv.ServiceName(serviceName),
			semconv.ServiceVersion(serviceVersion),
		),
	)
}

// Setup builds a MeterProvider backed by an OTLP HTTP metric exporter and
// registers it as the global provider. The returned shutdown func flushes
// and stops the provider; callers should invoke it on exit. serviceVersion
// populates the resource's service.version attribute.
func Setup(ctx context.Context, serviceVersion string) (shutdown func(context.Context) error, err error) {
	exporter, err := otlpmetrichttp.New(ctx)
	if err != nil {
		return nil, err
	}

	res, err := newResource(ctx, os.Getenv("OTEL_SERVICE_NAME"), serviceVersion)
	if err != nil {
		return nil, err
	}

	mp := metric.NewMeterProvider(
		metric.WithReader(metric.NewPeriodicReader(exporter)),
		metric.WithResource(res),
	)
	otel.SetMeterProvider(mp)

	return mp.Shutdown, nil
}
