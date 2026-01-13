#!/bin/bash

set -e

check_prerequisites() {
    echo "Checking prerequisites..."
    command -v docker >/dev/null || { echo "Docker not installed"; exit 1; }
    command -v kubectl >/dev/null || { echo "kubectl not installed"; exit 1; }
    command -v minikube >/dev/null || { echo "minikube not installed"; exit 1; }
    echo "OK"
}

start_minikube() {
    echo "Starting minikube with single node..."
    minikube start --nodes=1 || true
    kubectl config use-context minikube
    echo "OK"
}

enable_ingress() {
    echo "Enabling ingress and storage..."
    minikube addons enable ingress
    minikube addons enable ingress-dns
    minikube addons enable default-storageclass
    minikube addons enable storage-provisioner
    echo "OK"
}

build_images() {
    echo "Building Docker images..."
    
    # Build images
    docker build -f backend/Dockerfile -t backend:latest .
    docker build -f frontend/Dockerfile -t frontend:latest .
    docker build -f database/Dockerfile -t database:latest .
    
    # Get minikube's Docker socket if using docker driver
    MINIKUBE_STATUS=$(minikube status -f '{{.Host}}')
    if [ "$MINIKUBE_STATUS" = "Running" ]; then
        # Load images into minikube cache
        echo "Loading images into minikube..."
        minikube cache add backend:latest
        minikube cache add frontend:latest
        minikube cache add database:latest
    else
        echo "Minikube is not running"
        exit 1
    fi
    echo "OK"
}

create_tls_secret() {
    echo "Creating TLS secret..."
    openssl req -x509 -newkey rsa:4096 -keyout /tmp/localhost.key -out /tmp/localhost.crt \
        -days 365 -nodes -subj "/CN=localhost" 2>/dev/null
    kubectl delete secret project-hub-tls --ignore-not-found=true
    kubectl create secret tls project-hub-tls --cert=/tmp/localhost.crt --key=/tmp/localhost.key
    echo "OK"
}

main() {
    echo "=== Installation ==="
    echo ""
    check_prerequisites
    echo ""
    start_minikube
    echo ""
    enable_ingress
    echo ""
    build_images
    echo ""
    create_tls_secret
    echo ""
    echo "Installation complete"
}

main "$@"
