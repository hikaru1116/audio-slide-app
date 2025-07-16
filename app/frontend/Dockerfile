# Build stage
FROM node:18-alpine AS builder

WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm ci --prefer-offline --no-audit --no-fund --silent

# Copy source code (leverage Docker layer caching)
COPY . .

# Build argument for API base URL
ARG REACT_APP_API_BASE_URL=/api
ENV REACT_APP_API_BASE_URL=$REACT_APP_API_BASE_URL

# Build the application for production
RUN npm run build

# Production stage
FROM nginx:alpine

# Remove default nginx config
RUN rm /etc/nginx/conf.d/default.conf

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy built application
COPY --from=builder /app/dist /usr/share/nginx/html

# Set proper permissions for nginx files
RUN chmod 644 /etc/nginx/conf.d/default.conf && \
    chmod -R 755 /usr/share/nginx/html

# Expose port
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]