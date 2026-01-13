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
    minikube start --profile=project-hub --nodes=1 || true
    kubectl config use-context project-hub
    echo "OK"
}

create_namespace() {
    echo "Creating namespace..."
    kubectl create namespace project-hub --dry-run=client -o yaml | kubectl apply -f -
    echo "OK"
}

enable_ingress() {
    echo "Enabling ingress and storage..."
    minikube -p project-hub addons enable ingress
    minikube -p project-hub addons enable ingress-dns
    minikube -p project-hub addons enable default-storageclass
    minikube -p project-hub addons enable storage-provisioner
    echo "OK"
}

build_images() {
    echo "Building Docker images..."
    
    docker build -f backend/Dockerfile -t backend:latest .
    docker build -f frontend/Dockerfile -t frontend:latest .
    docker build -f database/Dockerfile -t database:latest .
    
    echo "Loading images into minikube..."
    minikube -p project-hub cache add backend:latest
    minikube -p project-hub cache add frontend:latest
    minikube -p project-hub cache add database:latest
    echo "OK"
}

create_tls_secret() {
    echo "Creating TLS secret..."
    openssl req -x509 -newkey rsa:4096 -keyout /tmp/localhost.key -out /tmp/localhost.crt \
        -days 365 -nodes -subj "/CN=localhost" -addext "subjectAltName=DNS:localhost,DNS:project-hub" 2>/dev/null
    kubectl -n project-hub delete secret project-hub-tls --ignore-not-found=true
    kubectl -n project-hub create secret tls project-hub-tls --cert=/tmp/localhost.crt --key=/tmp/localhost.key
    echo "OK"
}

main() {
    echo "=== Installation ==="
    echo ""
    check_prerequisites
    echo ""
    start_minikube
    echo ""
    create_namespace
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
