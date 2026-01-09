FROM nginx:alpine

# Remove default nginx config
RUN rm /etc/nginx/conf.d/default.conf

# Copy custom nginx config
COPY ./frontend/nginx.conf /etc/nginx/conf.d/default.conf

# Create directories for static files and media
# RUN mkdir -p /usr/share/nginx/html/static
# RUN mkdir -p /usr/share/nginx/html/media

# Copy frontend HTML pages
COPY ./frontend/html/ /usr/share/nginx/html/

# Copy frontend CSS and JS
COPY ./frontend/css/ /usr/share/nginx/html/static/css/
COPY ./frontend/js/ /usr/share/nginx/html/static/js/

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
