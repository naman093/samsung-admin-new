# Multi-stage build for Flutter web application

# Stage 1: Build the Flutter web app
FROM ghcr.io/cirruslabs/flutter:stable AS build

# Accept build arguments for Supabase configuration
ARG SUPABASE_URL
ARG SUPABASE_ANON_KEY
ARG FIREBASE_API_KEY
ARG FIREBASE_AUTH_DOMAIN
ARG FIREBASE_PROJECT_ID
ARG FIREBASE_STORAGE_BUCKET
ARG FIREBASE_MESSAGING_SENDER_ID
ARG FIREBASE_APP_ID

# Set working directory
WORKDIR /app

# Copy pubspec.yaml first (pubspec.lock may not exist)
COPY pubspec.yaml ./

# Get dependencies (this will generate pubspec.lock if it doesn't exist)
RUN flutter pub get

# Copy the rest of the application
COPY . .

# Create .env file with Supabase credentials
# If build args are provided, use them; otherwise create empty file
RUN if [ -n "$SUPABASE_URL" ] && [ -n "$SUPABASE_ANON_KEY" ] && [ -n "$FIREBASE_API_KEY" ] && [ -n "$FIREBASE_AUTH_DOMAIN" ] && [ -n "$FIREBASE_PROJECT_ID" ] && [ -n "$FIREBASE_STORAGE_BUCKET" ] && [ -n "$FIREBASE_MESSAGING_SENDER_ID" ] && [ -n "$FIREBASE_APP_ID" ]; then \
      echo "SUPABASE_URL=$SUPABASE_URL" > .env && \
      echo "SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY" >> .env; \
      echo "FIREBASE_API_KEY=$FIREBASE_API_KEY" >> .env; \
      echo "FIREBASE_AUTH_DOMAIN=$FIREBASE_AUTH_DOMAIN" >> .env; \
      echo "FIREBASE_PROJECT_ID=$FIREBASE_PROJECT_ID" >> .env; \
      echo "FIREBASE_STORAGE_BUCKET=$FIREBASE_STORAGE_BUCKET" >> .env; \
      echo "FIREBASE_MESSAGING_SENDER_ID=$FIREBASE_MESSAGING_SENDER_ID" >> .env; \
      echo "FIREBASE_APP_ID=$FIREBASE_APP_ID" >> .env; \
    else \
      touch .env; \
    fi

# Build the Flutter web app
# Use --release for production build
RUN flutter build web --release

# Stage 2: Serve the built app with nginx
FROM nginx:alpine

# Copy built files from build stage
COPY --from=build /app/build/web /usr/share/nginx/html

# Copy nginx configuration for client-side routing and optimization
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
