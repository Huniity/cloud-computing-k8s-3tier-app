.PHONY: install deploy test cleanup setup logs restart help

help:
	@echo "Available commands:"
	@echo "  make install    - Install and setup minikube, build images"
	@echo "  make deploy     - Deploy application to Kubernetes"
	@echo "  make test       - Run tests"
	@echo "  make restart    - Restart all services (frontend/backend/database)"
	@echo "  make cleanup    - Clean up all resources"
	@echo "  make setup      - Full setup (install + deploy + test)"
	@echo "  make logs       - View pod logs (interactive)"
	@echo ""

install:
	bash scripts/install.sh

deploy:
	bash scripts/deploy.sh

test:
	bash scripts/test.sh

restart:
	bash scripts/restart.sh

cleanup:
	bash scripts/cleanup.sh

setup:
	bash scripts/install.sh && bash scripts/deploy.sh && bash scripts/test.sh

logs:
	bash scripts/setup.sh
