#!/bin/bash

set -e

check_pods() {
    echo "Checking pods..."
    kubectl get pods --all-namespaces
    echo ""
}

test_http() {
    echo "Testing HTTP (localhost:8080)..."
    curl -s -f http://localhost:8080/ >/dev/null && echo "OK" || echo "FAILED"
}

test_api() {
    echo "Testing API (localhost:8000/api/courses/)..."
    curl -s -f http://localhost:8000/api/courses/ >/dev/null && echo "OK" || echo "FAILED"
}

test_https() {
    echo "Testing HTTPS (localhost:8443)..."
    curl -s -k -f https://localhost:8443/ >/dev/null && echo "OK" || echo "FAILED"
}

test_pod_recreation() {
    echo ""
    echo "Testing pod recreation..."
    POD=$(kubectl -n project-hub get pods -o jsonpath='{.items[0].metadata.name}')
    echo "Killing pod: $POD"
    kubectl -n project-hub delete pod $POD --wait=false
    echo "Waiting for recreation..."
    sleep 3
    kubectl -n project-hub get pods --no-headers | head -3
}

print_urls() {
    echo ""
    echo "Application URLs:"
    echo "  HTTP:  http://localhost:8080/"
    echo "  HTTPS: https://localhost:8443/"
    echo "  API:   http://localhost:8000/api/"
}

main() {
    echo "=== Tests ==="
    echo ""
    check_pods
    test_http
    test_api
    test_https
    echo ""
    echo "Tests complete"
    print_urls
}

main "$@"
