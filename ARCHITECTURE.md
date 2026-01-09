# 3-Tier Architecture Setup

## Overview

Your application is now split into three distinct components:

### 1. **Frontend** (`/frontend`)
- **Technology**: Nginx
- **Purpose**: Serves static files and acts as a reverse proxy
- **Port**: 80 (HTTP)
- **Features**:
  - Serves HTML templates from `my_course/templates`
  - Serves static files (CSS, JS) from `my_course/static`
  - Routes API calls to backend service
  - Handles routing for single-page applications

### 2. **Backend** (`/backend`)
- **Technology**: Django/Python
- **Purpose**: REST API and business logic
- **Port**: 8000
- **Features**:
  - Django REST endpoints
  - Admin interface at `/admin`
  - Database operations
  - User authentication

### 3. **Database** (`/database`)
- **Technology**: PostgreSQL 17 (Alpine)
- **Purpose**: Data persistence
- **Port**: 5432
- **Features**:
  - Persistent volume for data
  - Health checks to ensure readiness
  - Environment-based configuration

## Updated Docker Compose

The new `compose.yaml` includes:

```yaml
- database: PostgreSQL service with persistent storage
- backend: Django application service
- frontend: Nginx reverse proxy and static file server
- adminer: Optional database management UI (port 8080)
```

### Service Communication

```
Client (Browser)
    ↓
Nginx Frontend (Port 80)
    ├→ Static Files (/static, /templates)
    └→ API Requests (/api/*, /admin) → Django Backend (Port 8000)
                                            ↓
                                       PostgreSQL (Port 5432)
```

## How to Run

1. **Start all services**:
   ```bash
   docker-compose up --build
   ```

2. **Access the application**:
   - **Frontend**: http://localhost
   - **Admin**: http://localhost/admin
   - **Backend Direct**: http://localhost:8000 (for debugging)
   - **Database Manager**: http://localhost:8080 (Adminer)

## File Structure

```
project/
├── frontend/
│   ├── Dockerfile
│   └── nginx.conf
├── backend/
│   └── Dockerfile
├── database/
│   └── Dockerfile
├── compose.yaml
└── [other Django files]
```

## Environment Variables

Make sure your `.env` file contains:
```
POSTGRES_DB=your_database_name
POSTGRES_USER=your_user
POSTGRES_PASSWORD=your_password
DATABASE_URL=postgresql://user:password@database:5432/dbname
```

## Notes

- **Volumes**:
  - `postgres_data`: Persistent PostgreSQL data
  - Backend mounts entire project for live reload during development
  - Frontend mounts templates and static files as read-only

- **Networks**: All services communicate on `course-hub-network`

- **Health Checks**: Database includes health check to ensure readiness before backend starts

- **Hot Reload**: Backend service reloads on code changes (development mode)
