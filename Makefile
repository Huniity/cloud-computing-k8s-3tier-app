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
	@echo "ALLOWED_HOSTS=localhost,127.0.0.1,backend" >> .env
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
