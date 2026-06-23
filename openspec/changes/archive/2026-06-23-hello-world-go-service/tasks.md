## 1. Root endpoint returns service identity

- [x] 1.1 GET / returns 200 with JSON body containing "service" and "version" fields
- [x] 1.2 POST / returns 405 Method Not Allowed

## 2. Health endpoint returns 200

- [x] 2.1 GET /healthz returns 200 with empty body
- [x] 2.2 POST /healthz returns 405 Method Not Allowed

## 3. Service listens on port 8080

- [x] 3.1 Binary binds to port 8080 on startup and accepts HTTP connections

