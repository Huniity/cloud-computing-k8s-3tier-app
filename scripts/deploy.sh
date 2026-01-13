#!/bin/bash

set -e

apply_configs() {
    echo "Applying configs..."
    kubectl apply -f backend/configmap.yaml
    kubectl apply -f backend/secret.yaml
    kubectl apply -f database/configmap.yaml
    kubectl apply -f database/secret.yaml
    kubectl apply -f frontend/configmap.yaml
    echo "OK"
}

deploy_database() {
    echo "Deploying database..."
    kubectl apply -f database/statefulset.yaml
    kubectl apply -f database/service.yaml
    kubectl rollout status statefulset/postgres --timeout=2m
    echo "OK"
}

deploy_backend() {
    echo "Deploying backend..."
    kubectl apply -f backend/deployment.yaml
    kubectl apply -f backend/service.yaml
    kubectl rollout status deployment/backend --timeout=2m
    echo "OK"
}

init_database() {
    echo "Initializing database..."
    
    # Wait for backend pod to be ready
    BACKEND_POD=$(kubectl get pods -l app=backend -o jsonpath='{.items[0].metadata.name}')
    echo "Using pod: $BACKEND_POD"
    
    # Run migrations
    echo "Running migrations..."
    kubectl exec "$BACKEND_POD" -- poetry run python manage.py migrate
    
    # Load fixtures (order matters - groups before users)
    echo "Loading fixtures..."
    kubectl exec "$BACKEND_POD" -- poetry run python manage.py loaddata fixtures/group.json
    kubectl exec "$BACKEND_POD" -- poetry run python manage.py loaddata fixtures/user.json
    kubectl exec "$BACKEND_POD" -- poetry run python manage.py loaddata fixtures/course.json
    
    # Create test users
    echo "Creating test users..."
    kubectl exec "$BACKEND_POD" -- poetry run python create_test_users.py
    
    echo "OK"
}

deploy_frontend() {
    echo "Deploying frontend..."
    kubectl apply -f frontend/deployment.yaml
    kubectl apply -f frontend/service.yaml
    kubectl rollout status deployment/frontend --timeout=2m
    echo "OK"
}

deploy_ingress() {
    echo "Deploying ingress..."
    kubectl apply -f ingress/ingress.yaml
    echo "OK"
}

setup_port_forwarding() {
    echo "Setting up port forwarding..."
    pkill -f "kubectl port-forward" || true
    sleep 1
    kubectl port-forward svc/frontend 8080:80 &
    kubectl port-forward svc/backend 8000:8000 &
    kubectl -n ingress-nginx port-forward svc/ingress-nginx-controller 8443:443 &
    sleep 2
    echo "OK"
}

print_access_info() {
    echo ""
    echo "Access your application at:"
    echo "  HTTP:  http://localhost:8080/"
    echo "  HTTPS: https://localhost:8443/"
    echo "  API:   http://localhost:8000/api/"
}

main() {
    echo "=== Deployment ==="
    echo ""
    apply_configs
    echo ""
    deploy_database
    echo ""
    deploy_backend
    echo ""
    init_database
    echo ""
    deploy_frontend
    echo ""
    deploy_ingress
    echo ""
    setup_port_forwarding
    echo ""
    echo "Deployment complete"
    print_access_info
}

main "$@"
