## ADDED Requirements

### Requirement: Root endpoint returns service identity

The service SHALL respond to `GET /` with HTTP 200 and a JSON body containing `service` (the string `"hello"`) and `version` (the short git commit SHA baked in at build time via `-ldflags`).

#### Scenario: Happy path — valid request

- **WHEN** a client sends `GET /` to the hello service
- **THEN** the response status is 200, Content-Type is `application/json`, and the body is `{"service":"hello","version":"<sha>"}` where `<sha>` is a non-empty string

#### Scenario: Error/rejection — wrong method

- **WHEN** a client sends `POST /` to the hello service
- **THEN** the response status is 405 Method Not Allowed

---

### Requirement: Health endpoint returns 200

The service SHALL respond to `GET /healthz` with HTTP 200 and an empty body. This endpoint is used by Kubernetes liveness and readiness probes.

#### Scenario: Happy path — probe check

- **WHEN** a client sends `GET /healthz`
- **THEN** the response status is 200 and the body is empty

#### Scenario: Error/rejection — wrong method

- **WHEN** a client sends `POST /healthz`
- **THEN** the response status is 405 Method Not Allowed

---

### Requirement: Service listens on port 8080

The service SHALL bind to `0.0.0.0:8080` on startup. The port MUST be the only network listener.

#### Scenario: Happy path — server starts

- **WHEN** the binary is executed
- **THEN** it binds to port 8080 and accepts HTTP connections

#### Scenario: Error/rejection — port already in use

- **WHEN** port 8080 is already bound by another process
- **THEN** the service exits with a non-zero status and logs the error
