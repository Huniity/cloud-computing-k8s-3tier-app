#!/bin/bash

check_scripts() {
    for script in scripts/install.sh scripts/deploy.sh scripts/test.sh scripts/cleanup.sh; do
        [ -f "$script" ] || { echo "Script not found: $script"; return 1; }
        chmod +x "$script"
    done
}

full_setup() {
    echo "=== Full Setup ==="
    echo ""
    bash scripts/install.sh
    echo ""
    bash scripts/deploy.sh
    echo ""
    bash scripts/test.sh
    echo ""
    echo "Setup complete - Application ready at https://localhost:8443/"
}

view_logs() {
    echo "Choose which logs to view:"
    echo "  1) Frontend"
    echo "  2) Backend"
    echo "  3) Database"
    echo "  4) All"
    echo ""
    read -p "Choice: " choice
    
    case $choice in
        1) kubectl logs -l app=frontend --tail=50 --all-containers=true ;;
        2) kubectl logs -l app=backend --tail=50 --all-containers=true ;;
        3) kubectl logs -l app=database --tail=50 --all-containers=true ;;
        4) kubectl logs --all-namespaces --tail=20 ;;
        *) echo "Invalid choice" ;;
    esac
}

show_menu() {
    echo ""
    echo "=== Project Hub Deployment Manager ==="
    echo ""
    echo "1) Full Setup (install + deploy + test)"
    echo "2) Install Only"
    echo "3) Deploy Only"
    echo "4) Test Only"
    echo "5) Cleanup"
    echo "6) View Logs"
    echo "7) Exit"
    echo ""
}

main() {
    check_scripts || { echo "Error: Required scripts not found"; exit 1; }
    
    while true; do
        show_menu
        read -p "Choice [1-7]: " choice
        
        case $choice in
            1) full_setup ;;
            2) bash scripts/install.sh ;;
            3) bash scripts/deploy.sh ;;
            4) bash scripts/test.sh ;;
            5) bash scripts/cleanup.sh ;;
            6) view_logs ;;
            7) echo "Exiting"; exit 0 ;;
            *) echo "Invalid choice" ;;
        esac
        
        echo ""
        read -p "Press Enter to continue..."
    done
}

main "$@"
