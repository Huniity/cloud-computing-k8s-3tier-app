# lazy.jorge.ps1 - PowerShell version of make lazy.jorge

# Create .env
@"
POSTGRES_DB=hub_db
POSTGRES_USER=postgres
POSTGRES_USERNAME=postgres
POSTGRES_PASSWORD=qwerty
POSTGRES_HOST=database
POSTGRES_PORT=5432
DATABASE_URL=postgresql://postgres:qwerty@database:5432/hub_db
DJANGO_DEBUG=False
"@ | Set-Content ".env"

Start-Sleep -Seconds 1

# Start containers
docker compose up --build --force-recreate -d

Start-Sleep -Seconds 10

# Migrate
docker compose run --rm backend poetry run python manage.py migrate

Start-Sleep -Seconds 2

# Load fixtures
docker compose run --rm backend poetry run python manage.py loaddata fixtures/group.json

Start-Sleep -Seconds 1

docker compose run --rm backend poetry run python manage.py loaddata fixtures/user.json

Start-Sleep -Seconds 1

docker compose run --rm backend poetry run python manage.py loaddata fixtures/course.json

Start-Sleep -Seconds 1

# Open browser
Start-Process "http://localhost"

# Show logs
docker compose logs -f
