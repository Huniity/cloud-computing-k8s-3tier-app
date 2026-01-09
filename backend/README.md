# Project Hub - Course Management System

![Django](https://img.shields.io/badge/Django-5.1.7-green)
![Python](https://img.shields.io/badge/Python-3.12.9%2B-blue)
![Typer](https://img.shields.io/badge/Typer-0.15.2%2B-violet)

## What?
A full-featured course HUB system with user authentication, course enrollment, and administrative tools using CLI.

## Why?
Why did I choose this project? Well this is a personal project facing problems that I encountered when I tried to get back to my studies. Too much time wasted searching schools through inumerous website. So I decided I could gather all the informations, and make the connection easier between Students and Mentors. Mentors and Schools can gain visibility and Student on their side find what they suit them better at a distance of a click, on a single website. This E-HUB is a gateway to the future for the tomorrow's students.

## How?
Using Django and Python makes a create combination for Database. I also integrated Postgres and using container for security, stability and contained informations.

## Features

### Core Functionalities
- **User Authentication System**
  - Signup with automatic group assignment (Student)
  - Login/Logout functionality
  - Role-based access control
- **Course Management**
  - Create/Read/Update/Delete courses
  - Course enrollment system
  - Student-Mentor relationship management
  - Feature for enrollment management
- **Dashboard Views**
  - Students: View enrolled courses
  - Mentors: Manage created courses
- **Administration**
  - Custom CLI for user management
  - Automated group assignments
  - Database management interface

### Technical Highlights
- Custom Typer CLI integration
- PostgreSQL database support
- Pytest test suite with 85%+ coverage
- Django class-based views

## Installation and how to run🛠️
Run this commands to installand start the app. After all is set,
  website will be available on: localhost:8000/admin for Django Administration and localhost:8000/ for the project UI/Website.

  Commands:

- `make lazy.jorge`

  Command that starts the project ready to use.
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
