
 # Project Hub - Course Management System

![Django](https://img.shields.io/badge/Django-5.1.7-green)
![Python](https://img.shields.io/badge/Python-3.12.9%2B-blue)
![Kubernetes](https://img.shields.io/badge/Kubernetes-Latest-blue)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15-336791)

## Overview

Project Hub is a full-featured course management system built with Django, deployed on Kubernetes. It enables seamless interaction between Students and Mentors through an intuitive web interface with role-based access control, course enrollment, and administrative tools.

### Key Features

- **User Authentication** - Signup, login, and role-based access control
- **Course Management** - Create, manage, and enroll in courses
- **Student Dashboard** - View enrolled courses and track progress
- **Mentor Dashboard** - Manage created courses and students
- **RESTful API** - Built with Django REST Framework
- **Admin Interface** - Django admin for administrative tasks
- **HTTPS Support** - Self-signed certificates included

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      User's Browser                              │
│                   (localhost:8443 HTTPS)                         │
└─────────────────────┬───────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────────┐
│                    NGINX Ingress                                 │
│              (TLS Termination, Routing)                          │
└─────────────────────┬───────────────────────────────────────────┘
                      │
          ┌───────────┴───────────┬───────────────┐
          ▼                       ▼               ▼
    ┌──────────────┐      ┌──────────────┐  ┌──────────────┐
    │   Frontend   │      │   Backend    │  │   Database   │
    │   (Nginx)    │      │   (Django)   │  │  (PostgreSQL)│
    │              │      │              │  │              │
    │ HTML/CSS/JS  │      │  REST API    │  │   Tables     │
    │ (Port 80)    │      │  (Port 8000) │  │  (Port 5432) │
    └──────────────┘      └──────────────┘  └──────────────┘
```

## Prerequisites

- Docker
- kubectl
- Minikube (for local development)
- OpenSSL (for TLS certificate generation)

## Installation & Setup

### Quick Start (One Command)

```bash
make setup
```

This runs: `install` → `deploy` → `test`

### Step-by-Step Setup

**Step 1: Install & Prepare**
```bash
make install
```
- Starts minikube
- Enables ingress addon
- Builds Docker images
- Creates TLS certificate

**Step 2: Deploy Application**
```bash
make deploy
```
- Applies all Kubernetes configs
- Deploys database, backend, frontend
- Sets up port forwarding
- Enables HTTPS access

**Step 3: Test**
```bash
make test
```
- Verifies all pods are running
- Tests HTTP endpoints
- Tests API connectivity

### Access the Application

After setup completes, access:

| Service | URL | Port |
|---------|-----|------|
| Frontend (HTTP) | http://localhost:8080 | 8080 |
| Backend API | http://localhost:8000/api | 8000 |
| Frontend (HTTPS) | https://localhost:8443 | 8443 |
| Admin Panel | http://localhost:8000/admin | 8000 |

**Note:** HTTPS uses self-signed certificate. Accept the browser warning on first access.

## Available Commands

```bash
make install    # Setup minikube and build images
make deploy     # Deploy to Kubernetes
make test       # Run tests
make cleanup    # Remove all resources
make setup      # Full setup (install + deploy + test)
make help       # Show all commands
```

Or use the interactive menu:
```bash
bash scripts/setup.sh
```

## Project Structure

```
├── backend/                 # Django REST API
│   ├── learning_hub/       # Django settings
│   ├── my_course/          # Course app
│   ├── cli/                # CLI tools
│   └── Dockerfile
│
├── frontend/               # Nginx + HTML/CSS/JS
│   ├── html/              # HTML pages
│   ├── css/               # Stylesheets
│   ├── js/                # JavaScript
│   ├── nginx.conf         # Nginx configuration
│   └── Dockerfile
│
├── database/              # PostgreSQL
│   ├── init.sql          # Initial schema
│   ├── Dockerfile
│   └── statefulset.yaml
│
├── ingress/              # Kubernetes ingress + TLS
│   ├── ingress.yaml
│   ├── tls.crt
│   └── tls.key
│
├── scripts/              # Automation scripts
│   ├── install.sh
│   ├── deploy.sh
│   ├── test.sh
│   ├── cleanup.sh
│   └── setup.sh
│
└── Makefile.local        # Make commands
```

## Cleanup

Remove all resources and reset:

```bash
make cleanup
```

## Troubleshooting

### Port Already in Use
```bash
pkill -f "kubectl port-forward"
```

### View Logs
```bash
bash scripts/setup.sh  # Select option 6
# Or directly:
kubectl logs -l app=frontend
kubectl logs -l app=backend
kubectl logs -l app=database
```

### Restart Services
```bash
kubectl rollout restart deployment/frontend
kubectl rollout restart deployment/backend
```

## Technologies Used

- **Frontend:** HTML5, CSS3, JavaScript, Nginx
- **Backend:** Django 5.1, Django REST Framework, Python 3.12
- **Database:** PostgreSQL 15
- **Infrastructure:** Kubernetes, Docker, Minikube
- **Security:** TLS/HTTPS, Self-signed certificates

## License

This project is licensed under the MIT License.
  This commands creates the .env file so you don't have to. Builds the container, migrates data, injects the data from .Json in the Postgres DB, opens the browser on the index of the app and finally re-opens logs.
  You can at anytime, log in or logout and create new user on the website. New comers always get Student role, to grants Mentor access you can proceed to Django Administration or using the CLI commands on the CLI section of this README.md.
  Following links have profiles already created so you can see how this SAaS works, from Student side to Mentor side.
  Following links available in case you need too and respective credentials:

  - http://localhost:8000/
  Access to following users:
    - User: Student
      - Password: useruser
      - Grants access to a Student user, with respective roles to see courses, enroll and check where you are enrolled.
    - User: Mentor
      - Password: useruser
      - Grants access to a Mentor user, with respectve roles to create, see own courses and who is enrolled to them. 

  - http://localhost:8000/admin
    - User: admin
      - Password: admin
      - Grants access to admininstration of Django.

  - http://localhost:8080/
  Access to Postgres:
    - System: PostgreSQL
    - Server: database
    - Username: postgres
    - Password: qwerty
    - Database: hub_db



### CLI Commands for Admin use Only
- `docker compose run --rm web poetry run python cli/cli.py super`
- `docker compose run --rm web poetry run python cli/cli.py create-user` 
- `docker compose run --rm web poetry run python cli/cli.py delete-user <username>`
- `docker compose run --rm web poetry run python cli/cli.py group-user <username> <groupname>`
- `docker compose run --rm web poetry run python cli/cli.py reset-group <username>`
- `docker compose run --rm web poetry run python cli/cli.py list-course`
- `docker compose run --rm web poetry run python cli/cli.py list-course --short`
- `docker compose run --rm web poetry run python cli/cli.py list-course --save`


### Requirements 
- Python 3.12.9+
- Docker 4.39.0 for Container compatilibty using Debian Docker in Docker.
- PostgreSQL
- Typer

### Dependencies
```toml
dependencies = [
    "django (>=5.1.7,<6.0.0)",
    "uvicorn (>=0.34.0,<0.35.0)",
    "psycopg2-binary (>=2.9.10,<3.0.0)",
    "typer (>=0.15.2,<0.16.0)",
    "whitenoise (>=6.9.0,<7.0.0)"
]
[tool.poetry.group.dev.dependencies]
pytest-django = "^4.10.0"
```

### How did I structured my project
![Diagram](HUB_Diagram.png)

### Project Structure
```projecthub/
├── .devcontainer/       
├── my_project/              
│   └── templates/          
├── my_course/       
│   ├── migrations/
│   ├── __init__.py
│   ├── admin.py
│   ├── apps.py
│   ├── forms.py
│   ├── models.py
│   ├── urls.py
│   └── views.py
├── static/   
├── projecthub/     
│   ├── settings.py
│   ├── urls.py
│   ├── asgi.py
│   └── wsgi.py
├── .env
├── compose.yaml
├── Dockerfile
├── manage.py
└── ...other root files ```
