# Go Services Guidelines

One directory per service under `services/`. Each service is an independent Go module.

## Commands

```bash
go test ./...    # run all tests
go vet ./...     # check for issues
```

## Conventions

- Keep `main.go` thin; business logic in handlers/packages
- HTTP handlers are tested via `httptest`
