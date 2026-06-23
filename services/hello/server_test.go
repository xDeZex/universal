package main

import (
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestServer_AcceptsHTTPConnections(t *testing.T) {
	srv := httptest.NewServer(newMux())
	defer srv.Close()

	for _, path := range []string{"/", "/healthz"} {
		resp, err := http.Get(srv.URL + path)
		require.NoError(t, err, "GET %s", path)
		resp.Body.Close()
		assert.Equal(t, http.StatusOK, resp.StatusCode, "GET %s", path)
	}
}
