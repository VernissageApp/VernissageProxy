# Use official nginx image as the base image
FROM nginx:latest

# Use custom ngix file (for rewriting to index.html).
COPY ./nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Stay nginx in the foreground.
CMD ["nginx", "-g", "daemon off;"]