# Official WordPress img
FROM wordpress:latest

# Setting metadata for the image
LABEL maintainer="rajat@55tech.com"
LABEL description="Docker image for WordPress"

# Expose port 80
EXPOSE 8001:80

# Start the WordPress application
CMD ["apache2-foreground"]
