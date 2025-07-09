FROM postgres:15-alpine

# Set environment variables
ENV POSTGRES_DB=dockermastery
ENV POSTGRES_USER=postgres
ENV POSTGRES_PASSWORD=password

# Copy initialization script
COPY init.sql /docker-entrypoint-initdb.d/

# Expose port
EXPOSE 5432

# Add health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=5 \
  CMD pg_isready -U postgres -d dockermastery || exit 1