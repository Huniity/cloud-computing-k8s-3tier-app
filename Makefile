poetry.install:
	cd backend && poetry install

runserver:
	cd backend && poetry run python manage.py runserver 

logs:
	docker compose logs -f

down:
	docker compose down --volumes

start:
	cd backend && COMPOSE_BAKE=True poetry run python manage.py runserver

migrate:
	cd backend && poetry run python manage.py migrate

migration:
	cd backend && poetry run python manage.py makemigrations

super:
	cd backend && poetry run python manage.py createsuperuser

newapp:
	cd backend && poetry run python manage.py startapp $(app)
	@# to execute run `make newapp app=cenas`

test:
	cd backend && poetry run pytest -vvv

compose.super:
	docker compose run --rm backend poetry run python manage.py createsuperuser

compose.start:
	docker compose up --build --force-recreate -d

compose.migrate:
	docker compose run --rm backend poetry run python manage.py migrate

compose.migration:
	docker compose run --rm backend poetry run python manage.py makemigrations

compose.collectstatic:
	docker compose exec backend poetry run python manage.py collectstatic --noinput

compose.test:
	docker compose run --rm backend poetry run pytest -vvv

compose.group:
	docker compose run --rm backend poetry run python manage.py loaddata fixtures/group.json

compose.user:
	docker compose run --rm backend poetry run python manage.py loaddata fixtures/user.json

compose.course:
	docker compose run --rm backend poetry run python manage.py loaddata fixtures/course.json

compose.logs:
	docker compose logs -f

open.terminal:
	code --new-window

open.browser:
	@{ command -v xdg-open >/dev/null && xdg-open http://localhost; } || \
	{ command -v open >/dev/null && open http://localhost; } || \
	{ command -v explorer >/dev/null && explorer "http://localhost"; } || \
	{ command -v python3 >/dev/null && python3 -m webbrowser http://localhost; } || \
	echo "Could not open browser automatically. Please visit http://localhost in your browser."

create.env:
	@echo "POSTGRES_DB=hub_db" > .env
	@echo "POSTGRES_USER=postgres" >> .env
	@echo "POSTGRES_PASSWORD=qwerty" >> .env
	@echo "POSTGRES_HOST=database" >> .env
	@echo "POSTGRES_PORT=5432" >> .env
	@echo "DATABASE_URL=postgresql://postgres:qwerty@database:5432/hub_db" >> .env
	@echo "DJANGO_DEBUG=False" >> .env
	@echo "SECRET_KEY=django-insecure-_g!xn78w26aj^pw*$$2&^&fl_3wbtspd+3eay%2*3mgb4^u$jg" >> .env
	@echo "ALLOWED_HOSTS=localhost,127.0.0.1,backend,frontend" >> .env
	@echo ".env file created successfully."

lazy.jorge:
	make create.env
	sleep 1
	make poetry.install
	sleep 2
	make compose.start
	sleep 10
	make compose.migrate
	sleep 2
	make compose.collectstatic
	sleep 1
	make compose.group
	sleep 1
	make compose.user
	sleep 1
	make compose.course
	sleep 1
	make open.browser
	make compose.logs

# ===== Kubernetes Commands =====

minikube.start:
	minikube start
	minikube addons enable ingress
	minikube addons enable registry

minikube.stop:
	minikube stop

minikube.delete:
	minikube delete

minikube.dashboard:
	minikube dashboard

minikube.tunnel:
	minikube tunnel

image.build:
	@echo "Building Docker images for Kubernetes..."
	eval $$(minikube -p minikube docker-env)
	docker build -t frontend:latest -f frontend/Dockerfile .
	minikube cache add frontend:latest
	docker build -t backend:latest -f backend/Dockerfile .
	minikube cache add backend:latest
	docker build -t database:latest -f database/Dockerfile .
	minikube cache add database:latest
	@echo "Docker images built successfully."

k8s.deploy:
	@echo "Deploying to Kubernetes..."
	kubectl apply -f database/
	kubectl apply -f backend/
	kubectl apply -f frontend/
	kubectl apply -f ingress/
	@echo "Waiting for database to be ready..."
	kubectl wait --for=condition=ready pod -l app=postgres --timeout=300s
	@echo "Waiting for backend pods to be ready..."
	kubectl wait --for=condition=ready pod -l app=backend --timeout=300s

k8s.migrate:
	@echo "Running migrations..."
	kubectl exec -it deployment/backend -- poetry run python manage.py migrate

k8s.collectstatic:
	@echo "Collecting static files..."
	kubectl exec -it deployment/backend -- poetry run python manage.py collectstatic --noinput

k8s.group:
	@echo "Loading group fixtures..."
	kubectl exec -it deployment/backend -- poetry run python manage.py loaddata fixtures/group.json

k8s.user:
	@echo "Loading user fixtures..."
	kubectl exec -it deployment/backend -- poetry run python manage.py loaddata fixtures/user.json

k8s.course:
	@echo "Loading course fixtures..."
	kubectl exec -it deployment/backend -- poetry run python manage.py loaddata fixtures/course.json

k8s.super:
	@echo "Creating superuser..."
	kubectl exec -it deployment/backend -- poetry run python manage.py createsuperuser

k8s.logs:
	kubectl logs -f deployment/backend

k8s.pods:
	kubectl get pods

k8s.services:
	kubectl get services

k8s.delete:
	@echo "Deleting all resources..."
	kubectl delete -f ingress/
	kubectl delete -f frontend/
	kubectl delete -f backend/
	kubectl delete -f database/

k8s.lazy.jorge: minikube.start image.build k8s.deploy
	@echo "Database and backend pods are ready, starting initialization..."
	sleep 3
	make k8s.migrate
	sleep 2
	make k8s.collectstatic
	sleep 1
	make k8s.group
	sleep 1
	make k8s.user
	sleep 1
	make k8s.course
	@echo ""
	@echo "🎉 Kubernetes cluster is ready!"
	@echo ""
	@echo "Helpful commands:"
	@echo "  - View pods:       make k8s.pods"
	@echo "  - View services:   make k8s.services"
	@echo "  - View logs:       make k8s.logs"
	@echo "  - Create admin:    make k8s.super"
	@echo "  - Dashboard:       make minikube.dashboard"
	@echo "  - Tunnel:          make minikube.tunnel"
