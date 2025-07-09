#!/bin/bash

# DockerMasteryApp Local Development Script
# This script helps with local development using Docker Compose

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if Docker is running
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed or not in PATH"
        exit 1
    fi
    
    if ! docker info &> /dev/null; then
        print_error "Docker is not running. Please start Docker Desktop."
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose is not installed or not in PATH"
        exit 1
    fi
}

# Function to create environment file
create_env_file() {
    if [ ! -f "backend/.env" ]; then
        print_status "Creating backend/.env file..."
        cp backend/.env.example backend/.env
        print_status "Please edit backend/.env with your configuration"
    fi
}

# Function to start all services
start_services() {
    print_status "Starting all services..."
    
    # Build and start services
    docker-compose up -d --build
    
    print_status "Services started successfully!"
    print_status "Frontend: http://localhost:3000"
    print_status "Backend API: http://localhost:5000"
    print_status "Database: localhost:5432"
    print_status "Redis: localhost:6379"
}

# Function to stop all services
stop_services() {
    print_status "Stopping all services..."
    docker-compose down
    print_status "Services stopped successfully!"
}

# Function to view logs
view_logs() {
    local service=${1:-""}
    
    if [ -z "$service" ]; then
        print_status "Viewing logs for all services..."
        docker-compose logs -f
    else
        print_status "Viewing logs for $service..."
        docker-compose logs -f $service
    fi
}

# Function to run database migrations
run_migrations() {
    print_status "Running database migrations..."
    
    # Wait for database to be ready
    print_status "Waiting for database to be ready..."
    until docker-compose exec database pg_isready -U postgres; do
        sleep 2
    done
    
    # Run migrations (SQL file is already copied during build)
    print_status "Database is ready!"
    print_status "Migrations are automatically applied during database startup"
}

# Function to rebuild specific service
rebuild_service() {
    local service=${1:-""}
    
    if [ -z "$service" ]; then
        print_error "Please specify a service to rebuild (frontend, backend, database, redis)"
        exit 1
    fi
    
    print_status "Rebuilding $service..."
    docker-compose up -d --build $service
    print_status "$service rebuilt successfully!"
}

# Function to show service status
show_status() {
    print_status "Service status:"
    docker-compose ps
    
    print_status "\nResource usage:"
    docker stats --no-stream
}

# Function to clean up
cleanup() {
    print_warning "Cleaning up Docker resources..."
    
    # Stop and remove containers
    docker-compose down --volumes --remove-orphans
    
    # Remove images
    docker-compose down --rmi all
    
    # Prune unused resources
    docker system prune -f
    
    print_status "Cleanup completed!"
}

# Function to run tests
run_tests() {
    print_status "Running tests..."
    
    # Run backend tests
    docker-compose exec backend npm test
    
    # Run frontend tests (if configured)
    # docker-compose exec frontend npm test
    
    print_status "Tests completed!"
}

# Function to access database
access_db() {
    print_status "Accessing PostgreSQL database..."
    docker-compose exec database psql -U postgres -d dockermastery
}

# Function to access Redis
access_redis() {
    print_status "Accessing Redis CLI..."
    docker-compose exec redis redis-cli
}

# Function to monitor services
monitor_services() {
    print_status "Monitoring services (press Ctrl+C to stop)..."
    
    # Show real-time logs and stats
    docker-compose logs -f &
    LOGS_PID=$!
    
    # Show stats every 5 seconds
    while true; do
        clear
        echo "=== Service Status ==="
        docker-compose ps
        echo ""
        echo "=== Resource Usage ==="
        docker stats --no-stream
        echo ""
        echo "Press Ctrl+C to stop monitoring..."
        sleep 5
    done
}

# Function to show help
show_help() {
    echo "DockerMasteryApp Local Development Script"
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  start           - Start all services (default)"
    echo "  stop            - Stop all services"
    echo "  restart         - Restart all services"
    echo "  logs [service]  - View logs (optionally for specific service)"
    echo "  status          - Show service status and resource usage"
    echo "  migrate         - Run database migrations"
    echo "  rebuild [service] - Rebuild specific service"
    echo "  test            - Run tests"
    echo "  db              - Access PostgreSQL database"
    echo "  redis           - Access Redis CLI"
    echo "  monitor         - Monitor services in real-time"
    echo "  cleanup         - Clean up all Docker resources"
    echo "  help            - Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 start"
    echo "  $0 logs backend"
    echo "  $0 rebuild frontend"
}

# Main function
main() {
    # Check prerequisites
    check_docker
    create_env_file
    
    # Parse command line arguments
    case ${1:-start} in
        "start")
            start_services
            ;;
        "stop")
            stop_services
            ;;
        "restart")
            stop_services
            start_services
            ;;
        "logs")
            view_logs $2
            ;;
        "status")
            show_status
            ;;
        "migrate")
            run_migrations
            ;;
        "rebuild")
            rebuild_service $2
            ;;
        "test")
            run_tests
            ;;
        "db")
            access_db
            ;;
        "redis")
            access_redis
            ;;
        "monitor")
            monitor_services
            ;;
        "cleanup")
            cleanup
            ;;
        "help")
            show_help
            ;;
        *)
            print_error "Unknown command: $1"
            show_help
            exit 1
            ;;
    esac
}

# Run main function
main "$@"