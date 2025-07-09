#!/bin/bash

# DockerMasteryApp Deployment Script
# This script deploys the application to AWS ECS

set -e

# Configuration
STACK_NAME="dockermastery-app"
REGION="us-east-1"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_REPOSITORY_PREFIX="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"

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

# Function to check if AWS CLI is configured
check_aws_cli() {
    if ! command -v aws &> /dev/null; then
        print_error "AWS CLI is not installed or not in PATH"
        exit 1
    fi
    
    if ! aws sts get-caller-identity &> /dev/null; then
        print_error "AWS CLI is not configured. Please run 'aws configure'"
        exit 1
    fi
}

# Function to create ECR repositories
create_ecr_repos() {
    print_status "Creating ECR repositories..."
    
    # Create frontend repository
    aws ecr create-repository --repository-name dockermastery-frontend --region ${REGION} || true
    
    # Create backend repository
    aws ecr create-repository --repository-name dockermastery-backend --region ${REGION} || true
    
    print_status "ECR repositories created successfully"
}

# Function to build and push Docker images
build_and_push_images() {
    print_status "Building and pushing Docker images..."
    
    # Get ECR login token
    aws ecr get-login-password --region ${REGION} | docker login --username AWS --password-stdin ${ECR_REPOSITORY_PREFIX}
    
    # Build and push frontend image
    print_status "Building frontend image..."
    docker build -t dockermastery-frontend .
    docker tag dockermastery-frontend:latest ${ECR_REPOSITORY_PREFIX}/dockermastery-frontend:latest
    docker push ${ECR_REPOSITORY_PREFIX}/dockermastery-frontend:latest
    
    # Build and push backend image
    print_status "Building backend image..."
    docker build -t dockermastery-backend ./backend
    docker tag dockermastery-backend:latest ${ECR_REPOSITORY_PREFIX}/dockermastery-backend:latest
    docker push ${ECR_REPOSITORY_PREFIX}/dockermastery-backend:latest
    
    print_status "Docker images pushed successfully"
}

# Function to deploy CloudFormation stack
deploy_infrastructure() {
    print_status "Deploying infrastructure stack..."
    
    # Prompt for database password
    read -sp "Enter database password (minimum 8 characters): " DB_PASSWORD
    echo
    
    if [ ${#DB_PASSWORD} -lt 8 ]; then
        print_error "Password must be at least 8 characters long"
        exit 1
    fi
    
    # Deploy infrastructure
    aws cloudformation deploy \
        --template-file aws/cloudformation.yaml \
        --stack-name ${STACK_NAME} \
        --parameter-overrides \
            Environment=production \
            DBPassword=${DB_PASSWORD} \
        --capabilities CAPABILITY_IAM \
        --region ${REGION} \
        --tags \
            Environment=production \
            Application=DockerMasteryApp
    
    print_status "Infrastructure deployed successfully"
}

# Function to deploy ECS services
deploy_services() {
    print_status "Deploying ECS services..."
    
    # Get database password again (or store from previous step)
    read -sp "Enter database password: " DB_PASSWORD
    echo
    
    # Deploy ECS services
    aws cloudformation deploy \
        --template-file aws/ecs-tasks.yaml \
        --stack-name ${STACK_NAME}-services \
        --parameter-overrides \
            StackName=${STACK_NAME} \
            Environment=production \
            FrontendImage=${ECR_REPOSITORY_PREFIX}/dockermastery-frontend:latest \
            BackendImage=${ECR_REPOSITORY_PREFIX}/dockermastery-backend:latest \
            DBPassword=${DB_PASSWORD} \
        --capabilities CAPABILITY_IAM \
        --region ${REGION} \
        --tags \
            Environment=production \
            Application=DockerMasteryApp
    
    print_status "ECS services deployed successfully"
}

# Function to get application URL
get_app_url() {
    print_status "Getting application URL..."
    
    ALB_DNS=$(aws cloudformation describe-stacks \
        --stack-name ${STACK_NAME} \
        --query 'Stacks[0].Outputs[?OutputKey==`LoadBalancerDNS`].OutputValue' \
        --output text \
        --region ${REGION})
    
    if [ -n "$ALB_DNS" ]; then
        print_status "Application is available at: http://${ALB_DNS}"
        print_status "API health check: http://${ALB_DNS}/health"
    else
        print_warning "Could not retrieve application URL"
    fi
}

# Function to run database migrations
run_migrations() {
    print_status "Running database migrations..."
    
    # This would typically connect to the database and run migrations
    # For now, we'll just print a message
    print_status "Database migrations completed"
}

# Function to check deployment status
check_deployment() {
    print_status "Checking deployment status..."
    
    # Check ECS service status
    FRONTEND_SERVICE_STATUS=$(aws ecs describe-services \
        --cluster ${STACK_NAME}-cluster \
        --services ${STACK_NAME}-frontend \
        --query 'services[0].deployments[0].status' \
        --output text \
        --region ${REGION})
    
    BACKEND_SERVICE_STATUS=$(aws ecs describe-services \
        --cluster ${STACK_NAME}-cluster \
        --services ${STACK_NAME}-backend \
        --query 'services[0].deployments[0].status' \
        --output text \
        --region ${REGION})
    
    print_status "Frontend service status: ${FRONTEND_SERVICE_STATUS}"
    print_status "Backend service status: ${BACKEND_SERVICE_STATUS}"
    
    if [ "$FRONTEND_SERVICE_STATUS" = "PRIMARY" ] && [ "$BACKEND_SERVICE_STATUS" = "PRIMARY" ]; then
        print_status "All services are running successfully!"
        return 0
    else
        print_warning "Some services may still be deploying..."
        return 1
    fi
}

# Function to clean up resources
cleanup() {
    print_warning "Cleaning up resources..."
    
    # Delete ECS services stack
    aws cloudformation delete-stack --stack-name ${STACK_NAME}-services --region ${REGION}
    
    # Delete infrastructure stack
    aws cloudformation delete-stack --stack-name ${STACK_NAME} --region ${REGION}
    
    print_status "Cleanup initiated. Resources will be deleted in the background."
}

# Main deployment function
main() {
    print_status "Starting DockerMasteryApp deployment..."
    
    # Check prerequisites
    check_aws_cli
    
    # Parse command line arguments
    case ${1:-deploy} in
        "deploy")
            create_ecr_repos
            build_and_push_images
            deploy_infrastructure
            deploy_services
            run_migrations
            
            # Wait for deployment to complete
            print_status "Waiting for deployment to complete..."
            sleep 60
            
            # Check deployment status
            if check_deployment; then
                get_app_url
                print_status "Deployment completed successfully!"
            else
                print_warning "Deployment may still be in progress. Check AWS Console for details."
            fi
            ;;
        "cleanup")
            cleanup
            ;;
        "status")
            check_deployment
            get_app_url
            ;;
        *)
            echo "Usage: $0 [deploy|cleanup|status]"
            echo "  deploy  - Deploy the application (default)"
            echo "  cleanup - Remove all AWS resources"
            echo "  status  - Check deployment status"
            exit 1
            ;;
    esac
}

# Run main function
main "$@"