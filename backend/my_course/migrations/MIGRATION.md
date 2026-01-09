# Migration Guide

## Moving Your Existing Application to 3-Tier Architecture

### Step 1: Move Django Project Files to Backend

The Django project files should be moved or copied to the `/backend` folder. However, since the current setup references the project root, we're using bind mounts to keep them accessible.

**Current Structure Used**:
- Django project remains in root directory
- Backend container mounts entire project with `./:/app/`
- This allows live reloading during development

### Step 2: Frontend Setup

The Nginx configuration automatically:
- Serves templates from `my_course/templates` directory
- Serves static files from `my_course/static` directory
- Proxies API requests to backend service

### Step 3: Database Setup

PostgreSQL is now isolated in its own service with:
- Persistent volume (`postgres_data`) for data persistence
- Health checks to ensure readiness
- Separate environment configuration

## Running the Application

### Development
```bash
docker-compose up --build
```

### Production
```bash
docker-compose -f compose.yaml up -d
```

### Accessing Services

| Service | URL | Port |
|---------|-----|------|
| Frontend | http://localhost | 80 |
| Backend (API) | http://localhost:8000 | 8000 |
| Database | localhost:5432 | 5432 |
| Admin UI | http://localhost/admin | 80 |
| Adminer (DB Manager) | http://localhost:8080 | 8080 |

## Key Changes in Nginx Configuration

The `frontend/nginx.conf` file:

```nginx
# Static files routing
location /static/ { ... }
location /media/ { ... }

# API proxying
location /api/ { proxy_pass http://backend:8000; }

# Admin proxying
location /admin { proxy_pass http://backend:8000; }

# Frontend SPA routing
location / { try_files $uri $uri/ /index.html; }
```

## Future Improvements

1. **Separate Frontend Build**: Consider creating a dedicated React/Vue app in `/frontend/app`
2. **Environment-Specific Configs**: Create `compose.dev.yaml` and `compose.prod.yaml`
3. **CI/CD Pipeline**: Add GitHub Actions for automated builds and deployments
4. **Load Balancing**: Use a dedicated load balancer for production
5. **SSL/TLS**: Add SSL certificates to Nginx for HTTPS

## Troubleshooting

### Database Connection Issues
- Check `.env` file has correct `DATABASE_URL`
- Verify database is healthy: `docker-compose ps`

### Frontend Not Loading
- Check Nginx logs: `docker logs course-hub-frontend`
- Verify templates exist in `my_course/templates`

### Backend API Not Responding
- Check backend logs: `docker logs course-hub-backend`
- Verify backend service is running: `docker-compose ps`
