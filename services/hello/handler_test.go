package main

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestHealthzGET_Returns200EmptyBody(t *testing.T) {
	rec := httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodGet, "/healthz", nil)
	healthzHandler(rec, req)

	assert.Equal(t, http.StatusOK, rec.Code)
	assert.Empty(t, rec.Body.String())
}

func TestHealthzPOST_Returns405(t *testing.T) {
	rec := httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodPost, "/healthz", nil)
	healthzHandler(rec, req)

	assert.Equal(t, http.StatusMethodNotAllowed, rec.Code)
}

func TestRootPOST_Returns405(t *testing.T) {
	rec := httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodPost, "/", nil)
	rootHandler(rec, req)

	assert.Equal(t, http.StatusMethodNotAllowed, rec.Code)
}

func TestRootGET_ReturnsIdentity(t *testing.T) {
	rec := httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodGet, "/", nil)
	rootHandler(rec, req)

	assert.Equal(t, http.StatusOK, rec.Code)
	assert.Equal(t, "application/json", rec.Header().Get("Content-Type"))

	raw := rec.Body.Bytes()
	assert.False(t, len(raw) > 0 && raw[len(raw)-1] == '\n', "body must not have a trailing newline")

	var body map[string]string
	require.NoError(t, json.Unmarshal(raw, &body), "body is not valid JSON")
	assert.Equal(t, "hello", body["service"])
	assert.Equal(t, "dev", body["version"], "default build-time version must be \"dev\"")
}
