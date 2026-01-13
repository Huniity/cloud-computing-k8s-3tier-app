#!/bin/bash

stop_port_forwarding() {
    echo "Stopping port forwarding..."
    pkill -f "kubectl port-forward" || true
    sleep 1
    echo "OK"
}

delete_resources() {
    echo "Deleting resources..."
    
    # Check if kubectl can connect to cluster
    if ! kubectl cluster-info &>/dev/null; then
        echo "Warning: Kubernetes cluster not accessible, skipping resource deletion"
        return 0
    fi
    
    kubectl delete -f ingress/ingress.yaml --ignore-not-found=true || true
    kubectl delete -f frontend/deployment.yaml --ignore-not-found=true || true
    kubectl delete -f frontend/service.yaml --ignore-not-found=true || true
    kubectl delete -f backend/deployment.yaml --ignore-not-found=true || true
    kubectl delete -f backend/service.yaml --ignore-not-found=true || true
    kubectl delete -f database/statefulset.yaml --ignore-not-found=true || true
    kubectl delete -f database/service.yaml --ignore-not-found=true || true
    kubectl delete -f backend/configmap.yaml --ignore-not-found=true || true
    kubectl delete -f backend/secret.yaml --ignore-not-found=true || true
    kubectl delete -f database/configmap.yaml --ignore-not-found=true || true
    kubectl delete -f database/secret.yaml --ignore-not-found=true || true
    kubectl delete -f frontend/configmap.yaml --ignore-not-found=true || true
    kubectl delete secret project-hub-tls --ignore-not-found=true || true
    sleep 2
    echo "OK"
}

remove_images() {
    echo "Removing Docker images from minikube..."
    minikube image rm backend:latest 2>/dev/null || true
    minikube cache delete backend:latest 2>/dev/null || true
    minikube image rm frontend:latest 2>/dev/null || true
    minikube cache delete frontend:latest 2>/dev/null || true
    minikube image rm database:latest 2>/dev/null || true
    minikube cache delete database:latest 2>/dev/null || true
    echo "OK"
}

clean_temp_files() {
    echo "Cleaning temp files..."
    rm -f /tmp/localhost.crt /tmp/localhost.key
    echo "OK"
}

delete_minikube() {
    echo "Deleting minikube cluster..."
    minikube delete || true
    echo "OK"
}

main() {
    echo "=== Cleanup ==="
    echo ""
    stop_port_forwarding
    echo ""
    delete_resources
    echo ""
    remove_images
    echo ""
    clean_temp_files
    echo ""
    delete_minikube
    echo ""
    echo "Cleanup complete"
}

main "$@"
