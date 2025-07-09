# DockerMasteryApp 🐳

A production-ready, full-stack containerized microservices application showcasing modern DevOps practices on AWS.

## 🏗️ Architecture

**Frontend**: React with TypeScript, Tailwind CSS, and Vite
- Modern, responsive UI with real-time monitoring dashboard
- Service health indicators and metrics visualization
- Built with performance and user experience in mind

**Backend**: Node.js REST API with Express
- Robust API with proper middleware, logging, and error handling
- JWT authentication and rate limiting
- Redis caching for improved performance
- Comprehensive health checks and monitoring endpoints

**Database**: PostgreSQL with connection pooling
- Structured data storage with proper indexing
- Database migrations and seed data
- Backup and recovery strategies

**Cache**: Redis for session management and caching
- High-performance caching layer
- Session storage and real-time data caching
- Persistent storage with proper configuration

**Infrastructure**: AWS ECS with Fargate
- Containerized microservices deployment
- Auto-scaling based on CPU and memory usage
- Load balancing with health checks
- Secure VPC with public and private subnets

## 🚀 Features

### Application Features
- **Real-time Dashboard**: Monitor all microservices health and performance
- **Service Discovery**: Automatic service registration and discovery
- **API Gateway**: Centralized API management with rate limiting
- **Caching Layer**: Redis-based caching for improved performance
- **Health Monitoring**: Comprehensive health checks and monitoring
- **Auto-scaling**: Dynamic scaling based on demand

### DevOps Features
- **Containerization**: Docker containers for all services
- **Orchestration**: Docker Compose for local development
- **CI/CD Ready**: GitHub Actions workflows (configurable)
- **Infrastructure as Code**: CloudFormation templates
- **Monitoring**: CloudWatch integration for logs and metrics
- **Security**: VPC, security groups, and IAM roles configured

## 📋 Prerequisites

- Docker and Docker Compose
- AWS CLI configured with appropriate permissions
- Node.js 18+ (for local development)
- PostgreSQL client (optional, for database access)

## 🛠️ Quick Start

### Local Development

1. **Clone and setup**:
```bash
git clone <repository-url>
cd DockerMasteryApp
chmod +x scripts/local-dev.sh
```

2. **Start all services**:
```bash
./scripts/local-dev.sh start
```

3. **Access the application**:
   - Frontend: http://localhost:3000
   - Backend API: http://localhost:5000
   - Database: localhost:5432
   - Redis: localhost:6379

### AWS Deployment

1. **Configure AWS credentials**:
```bash
aws configure
```

2. **Deploy to AWS**:
```bash
chmod +x scripts/deploy.sh
./scripts/deploy.sh deploy
```

3. **Access your deployed application**:
   - The script will provide the Load Balancer DNS name
   - Example: http://your-alb-dns-name.us-east-1.elb.amazonaws.com

## 📁 Project Structure

```
DockerMasteryApp/
├── src/                          # React frontend source
│   ├── components/              # Reusable UI components
│   ├── pages/                   # Page components
│   └── App.tsx                  # Main application component
├── backend/                     # Node.js backend
│   ├── routes/                  # API routes
│   ├── middleware/              # Express middleware
│   ├── models/                  # Database models
│   └── server.js                # Main server file
├── database/                    # PostgreSQL setup
│   ├── migrations/              # Database migrations
│   ├── seeds/                   # Seed data
│   └── init.sql                 # Database initialization
├── redis/                       # Redis configuration
│   └── redis.conf               # Redis configuration file
├── aws/                         # AWS Infrastructure
│   ├── cloudformation.yaml      # Main infrastructure template
│   └── ecs-tasks.yaml           # ECS task definitions
├── scripts/                     # Deployment scripts
│   ├── deploy.sh                # AWS deployment script
│   └── local-dev.sh             # Local development script
├── docker-compose.yml           # Local development setup
└── README.md                    # This file
```

## 🎯 Available Commands

### Local Development
```bash
# Start all services
./scripts/local-dev.sh start

# Stop all services
./scripts/local-dev.sh stop

# View logs
./scripts/local-dev.sh logs [service]

# Show service status
./scripts/local-dev.sh status

# Rebuild specific service
./scripts/local-dev.sh rebuild [service]

# Access database
./scripts/local-dev.sh db

# Access Redis CLI
./scripts/local-dev.sh redis

# Clean up resources
./scripts/local-dev.sh cleanup
```

### AWS Deployment
```bash
# Deploy to AWS
./scripts/deploy.sh deploy

# Check deployment status
./scripts/deploy.sh status

# Clean up AWS resources
./scripts/deploy.sh cleanup
```

## 🔧 Configuration

### Environment Variables

**Backend (.env)**:
```env
NODE_ENV=production
PORT=5000
DB_HOST=localhost
DB_PORT=5432
DB_NAME=dockermastery
DB_USER=postgres
DB_PASSWORD=your-password
REDIS_HOST=localhost
REDIS_PORT=6379
FRONTEND_URL=http://localhost:3000
```

**Frontend**:
```env
VITE_API_URL=http://localhost:5000
```

### AWS Configuration

Update `aws/cloudformation.yaml` parameters:
- VPC CIDR blocks
- Instance types
- Database configuration
- Auto-scaling settings

## 🌐 API Endpoints

### Health & Monitoring
- `GET /health` - Service health check
- `GET /api/status` - System status
- `GET /api/metrics` - Performance metrics

### User Management
- `GET /api/users` - List users
- `POST /api/users` - Create user
- `PUT /api/users/:id` - Update user
- `DELETE /api/users/:id` - Delete user

## 📊 Monitoring

### Application Metrics
- **Response Time**: API response times
- **Throughput**: Requests per second
- **Error Rate**: Error percentage
- **Active Users**: Current active users

### Infrastructure Metrics
- **CPU Usage**: Container CPU utilization
- **Memory Usage**: Container memory usage
- **Network I/O**: Network traffic
- **Database Connections**: Active DB connections

## 🛡️ Security

### Application Security
- **Rate Limiting**: API rate limiting implemented
- **Input Validation**: Request validation and sanitization
- **CORS Configuration**: Proper CORS setup
- **Security Headers**: Helmet.js security headers

### Infrastructure Security
- **VPC**: Private subnets for databases
- **Security Groups**: Restrictive security group rules
- **IAM Roles**: Principle of least privilege
- **Encryption**: Data encryption at rest and in transit

## 🔄 CI/CD Pipeline

The application is ready for CI/CD integration with:
- **GitHub Actions**: Automated testing and deployment
- **AWS CodePipeline**: Native AWS CI/CD
- **Jenkins**: Self-hosted CI/CD solution

## 📈 Scaling

### Horizontal Scaling
- **ECS Auto Scaling**: Automatic scaling based on CPU/memory
- **Load Balancer**: Distributes traffic across instances
- **Database Read Replicas**: Scale read operations

### Vertical Scaling
- **Container Resources**: Adjustable CPU and memory limits
- **Database Instance**: Scalable RDS instance types
- **Cache Cluster**: Redis cluster scaling

## 🐛 Troubleshooting

### Common Issues

1. **Database Connection Issues**:
   - Check database service status
   - Verify connection strings
   - Ensure security groups allow database access

2. **Container Startup Issues**:
   - Check Docker logs: `docker-compose logs [service]`
   - Verify environment variables
   - Check resource limits

3. **Load Balancer Issues**:
   - Check target group health
   - Verify security group rules
   - Check ECS service status

### Debugging Commands

```bash
# Check container logs
docker-compose logs -f [service]

# Check container status
docker-compose ps

# Access container shell
docker-compose exec [service] /bin/sh

# Check AWS ECS logs
aws logs describe-log-groups --log-group-name-prefix /aws/ecs/
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes with proper tests
4. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🔗 Links

- [Docker Documentation](https://docs.docker.com/)
- [AWS ECS Documentation](https://docs.aws.amazon.com/ecs/)
- [React Documentation](https://reactjs.org/docs/)
- [Node.js Documentation](https://nodejs.org/docs/)

---

**DockerMasteryApp** - Showcasing modern containerized microservices architecture on AWS 🚀