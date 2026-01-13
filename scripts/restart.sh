#!/bin/bash

set -e

restart_frontend() {
    echo "Restarting frontend..."
    kubectl rollout restart deployment/frontend
    kubectl rollout status deployment/frontend --timeout=2m
    echo "OK"
}

restart_backend() {
    echo "Restarting backend..."
    kubectl rollout restart deployment/backend
    kubectl rollout status deployment/backend --timeout=2m
    echo "OK"
}

restart_database() {
    echo "Restarting database..."
    kubectl rollout restart statefulset/postgres
    kubectl rollout status statefulset/postgres --timeout=2m
    echo "OK"
}

restart_all() {
    echo "Restarting all services..."
    kubectl rollout restart statefulset/postgres
    kubectl rollout status statefulset/postgres --timeout=2m
    kubectl rollout restart deployment/backend
    kubectl rollout status deployment/backend --timeout=2m
    kubectl rollout restart deployment/frontend
    kubectl rollout status deployment/frontend --timeout=2m
    echo "OK"
}

main() {
    echo "=== Restart ==="
    echo ""
    restart_frontend
    echo ""
    restart_backend
    echo ""
    restart_database
    echo ""
    echo "Restart complete"
}

main "$@"
