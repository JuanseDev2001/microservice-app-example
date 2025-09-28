# Microservice App - PRFT DevOps Training

This is the application you are going to use through the whole training. This, hopefully, will teach you the fundamentals you need in a real project. You will find a basic TODO application designed with a [microservice architecture](https://microservices.io). Although is a TODO application, it is interesting because the microservices that compose it are written in different programming language or frameworks (Go, Python, Vue, Java, and NodeJS). With this design you will experiment with multiple build tools and environments.

## Architecture

Take a look at the components diagram that describes them and their interactions.
![microservice-app-example](/arch-img/Microservices.png)

## Components 
In each folder you can find a more in-depth explanation of each component:

### 1. **Users API** - Spring Boot (Java)
- **Location**: `/users-api`  
- **Port**: 9081 (external) → 8081 (internal)
- **Technology**: Java with Spring Boot
- **Purpose**: Provides user profile management and authentication data
- **Endpoints**:
  - `GET /users` - List all users
  - `GET /users/:username` - Get specific user by username
- **Dependencies**: Requires JWT authentication, connects to Redis
- **Environment Variables**:
  - `SERVER_PORT=8081` - Internal service port
  - `REDIS_HOST=redis` - Redis connection
  - `JWT_SECRET=myfancysecret` - Token validation

### 2. **Auth API** - Go
- **Location**: `/auth-api`
- **Port**: 9080 (external) → 8080 (internal)  
- **Technology**: Go
- **Purpose**: Handles user authentication and JWT token generation
- **Endpoints**:
  - `POST /login` - Authenticate user and return JWT token
- **Hardcoded Users**:
  | Username | Password |
  |----------|----------|
  | admin    | admin    |
  | johnd    | foo      |
  | janed    | ddd      |
- **Environment Variables**:
  - `AUTH_API_PORT=8080` - Service port
  - `USERS_API_ADDRESS=http://users-api:8081` - Users API connection
  - `JWT_SECRET=myfancysecret` - Token generation secret

### 3. **TODOs API** - Node.js
- **Location**: `/todos-api`
- **Port**: 9082 (external) → 8082 (internal)
- **Technology**: Node.js/Express
- **Purpose**: CRUD operations for TODO items with Redis logging
- **Endpoints**:
  - `GET /todos` - List all TODOs for authenticated user
  - `POST /todos` - Create new TODO (logged to Redis)
  - `DELETE /todos/:taskId` - Delete TODO by ID (logged to Redis)
- **Data Structure**:
  ```json
  {
    "id": 1,
    "userId": 1,
    "content": "Create new todo"
  }
  ```
- **Environment Variables**:
  - `TODO_API_PORT=8082` - Service port
  - `JWT_SECRET=foo` - Token validation
  - `REDIS_HOST=redis` - Redis connection for logging
  - `REDIS_CHANNEL=log_channel` - Redis pub/sub channel

### 4. **Log Message Processor** - Python
- **Location**: `/log-message-processor`
- **Technology**: Python
- **Purpose**: Consumes Redis queue messages and logs TODO operations
- **Functionality**: Listens to Redis pub/sub channel for CREATE/DELETE operations
- **Message Format**:
  ```json
  {
    "opName": "CREATE",
    "username": "admin", 
    "todoId": 5
  }
  ```
- **Environment Variables**:
  - `REDIS_HOST=redis` - Redis connection
  - `REDIS_PORT=6379` - Redis port
  - `REDIS_CHANNEL=log_channel` - Listening channel

### 5. **Frontend** - Vue.js
- **Location**: `/frontend`
- **Port**: 9083 (external) → 80 (internal)
- **Technology**: Vue.js SPA
- **Purpose**: Web UI for the TODO application
- **Features**:
  - User authentication interface
  - TODO management (create, view, delete)
  - Real-time updates
- **Environment Variables**:
  - `VUE_APP_API_URL=http://localhost:9082` - TODOs API connection

### 6. **Redis** - Cache & Message Broker
- **Technology**: Redis (latest)
- **Port**: 6379
- **Purpose**: 
  - Session storage for user authentication
  - Message queue for operation logging
  - Cache for application data

## Infrastructure & Deployment

### Azure Cloud Infrastructure (Terraform)

The application is deployed on **Microsoft Azure** using Infrastructure as Code:

#### **Resource Components**:
- **Resource Group**: `microapp-staging-rg`
- **Virtual Network**: `10.0.0.0/16` with subnet `10.0.1.0/24`
- **Virtual Machine**: Ubuntu 22.04 LTS (Standard_B2s)
- **Public IP**: Static IP with Standard SKU
- **Network Security Group**: Configured firewall rules
- **Network Interface**: Connects VM to VNet and Public IP

#### **Security Rules**:
- **SSH (22)**: Remote administration
- **HTTP (80)**: Web traffic  
- **Frontend (9083)**: Vue.js application
- **APIs (9080-9082)**: Microservice endpoints

#### **VM Configuration**:
- **OS**: Ubuntu 22.04 LTS (Canonical)
- **Size**: Standard_B2s (2 vCPUs, 4GB RAM)
- **Storage**: Premium SSD
- **Authentication**: SSH key-based (no passwords)
- **Initialization**: Cloud-init with minimal setup

### CI/CD Pipeline Architecture

The project implements a **fully automated DevOps pipeline** using GitHub Actions:

#### **1. Infrastructure Pipeline** (`infrastructure-staging.yml`)
- **Triggers**: Push to `env/staging` branch or manual dispatch
- **Purpose**: Provisions Azure infrastructure using Terraform
- **Key Features**:
  - Validates Terraform configuration
  - Destroys existing resources cleanly before creating new ones
  - Provisions VM with all required networking
  - Captures dynamic VM IP address
  - Auto-triggers deployment pipeline upon completion

#### **2. Deployment Pipeline** (`deploy-staging.yml`)  
- **Triggers**: Auto-triggered by infrastructure pipeline or manual dispatch
- **Purpose**: Deploys applications to the provisioned VM
- **Key Features**:
  - **Dynamic IP Detection**: Automatically discovers VM IP from Azure
  - **SSH Deployment**: Securely connects to VM for deployment
  - **Docker Setup**: Installs Docker and Docker Compose on VM
  - **Service Deployment**: Launches all microservices using Docker Compose
  - **Health Checking**: Verifies all services are running correctly

#### **3. CI/CD Pipeline** (`ci-cd.yml`)
- **Purpose**: Continuous integration for code validation
- **Features**: Validates Docker Compose configuration

### Deployment Architecture

#### **Container Orchestration**:
```yaml
# Service Dependencies Flow:
Redis (6379)
  ↓
Users API (9081) ← Auth API (9080)
  ↓                    ↓
TODOs API (9082) ← Frontend (9083)
  ↓
Log Processor (background)
```

#### **Network Communication**:
- **Internal**: Services communicate via Docker network using service names
- **External**: Public access through Azure VM's public IP
- **Security**: JWT tokens for API authentication
- **Logging**: Async message passing via Redis pub/sub

### Environment Variables & Configuration

| Service | Key Variables | Purpose |
|---------|---------------|---------|
| **Users API** | `SERVER_PORT`, `REDIS_HOST`, `JWT_SECRET` | Port, Redis connection, token validation |
| **Auth API** | `AUTH_API_PORT`, `USERS_API_ADDRESS`, `JWT_SECRET` | Port, service discovery, token generation |
| **TODOs API** | `TODO_API_PORT`, `JWT_SECRET`, `REDIS_HOST`, `REDIS_CHANNEL` | Port, auth, logging queue |
| **Frontend** | `VUE_APP_API_URL` | API endpoint discovery |
| **Log Processor** | `REDIS_HOST`, `REDIS_PORT`, `REDIS_CHANNEL` | Queue connection |

## Getting Started

### Prerequisites
- Azure subscription with appropriate permissions
- GitHub repository with configured secrets:
  - `AZURE_CREDENTIALS` - Azure Service Principal
  - `SSH_PRIVATE_KEY` - VM access key
  - Terraform variables in `staging.tfvars`

### Automated Deployment
1. **Push code** to `env/staging` branch
2. **Infrastructure pipeline** automatically provisions Azure resources
3. **Deployment pipeline** automatically deploys applications  
4. **Access application** at `http://<VM-IP>:9083`

### Manual Deployment
1. Trigger **Infrastructure Pipeline** from GitHub Actions
2. Trigger **Deployment Pipeline** from GitHub Actions (or wait for auto-trigger)
3. Monitor pipeline logs for deployment status and service URLs

### Development Workflow
1. Make changes to any microservice
2. Commit and push to `env/staging`
3. Pipelines automatically deploy updated services
4. Test changes on live environment

### Service Endpoints
Once deployed, access services at:
- **Frontend**: `http://<VM-IP>:9083` - Main application UI
- **Auth API**: `http://<VM-IP>:9080/login` - Authentication
- **Users API**: `http://<VM-IP>:9081/users` - User data
- **TODOs API**: `http://<VM-IP>:9082/todos` - TODO operations

### Technology Stack Summary
| Component | Technology | Version | Purpose |
|-----------|------------|---------|---------|
| **Frontend** | Vue.js + Node.js | 8.17.0 | User interface |
| **Auth API** | Go | 1.18.2 | Authentication service |  
| **Users API** | Java + Spring Boot | OpenJDK 8 | User management |
| **TODOs API** | Node.js + Express | 8.17.0 | Business logic |
| **Log Processor** | Python | 3.6 | Background processing |
| **Database** | Redis | 7.0 | Cache + Message queue |
| **Infrastructure** | Terraform + Azure | Latest | Cloud provisioning |
| **CI/CD** | GitHub Actions | - | Automation pipeline |
| **Containerization** | Docker + Compose | Latest | Service orchestration |

## Design Patterns Implementation

The application implements several **microservice design patterns** for resilience, performance, and reliability:

### 1. **Circuit Breaker Pattern** 🔧
**Location**: TODOs API (`todoController.js`)
**Library**: Opossum Circuit Breaker
**Purpose**: Prevents cascading failures when Redis logging service is unavailable

#### Implementation:
```javascript
// Circuit breaker configuration
this._redisBreaker = new CircuitBreaker(
    (message) => {
        return new Promise((resolve, reject) => {
            this._redisClient.publish(this._logChannel, message, (err, reply) => {
                if (err) return reject(err);
                resolve(reply);
            });
        });
    },
    {
        timeout: 2000,                    // 2 second timeout
        errorThresholdPercentage: 10,     // Open circuit at 10% error rate
        resetTimeout: 10000,              // Retry after 10 seconds
        volumeThreshold: 3                // Minimum 3 calls before evaluation
    }
);
```

#### Features:
- **Timeout Protection**: Prevents hanging on Redis publish operations (2s timeout)
- **Error Threshold**: Opens circuit when 10% of calls fail
- **Auto Recovery**: Attempts reconnection every 10 seconds
- **Graceful Degradation**: Continues TODO operations even if logging fails
- **Fallback Mechanism**: Returns "Redis no disponible" when circuit is open

#### Benefits:
- **Prevents System Overload**: Stops calling failed Redis service
- **Fast Failure**: Immediate response when circuit is open
- **Self-Healing**: Automatically retries when service recovers
- **User Experience**: TODO operations continue working

### 2. **Cache-Aside Pattern** 💾
**Location**: TODOs API (`todoController.js`)  
**Library**: Memory-Cache (in-memory caching)
**Purpose**: Improves performance and reduces data access latency

#### Implementation:
```javascript
// Cache-aside read pattern
_getTodoData(userID) {
    var data = cache.get(userID);  // 1. Check cache first
    if (data == null) {            // 2. Cache miss
        data = {                   // 3. Load from "database" (default data)
            items: { /* default todos */ },
            lastInsertedID: 3
        };
        this._setTodoData(userID, data);  // 4. Store in cache
    }
    return data;  // 5. Return cached data
}

// Cache-aside write pattern  
_setTodoData(userID, data) {
    cache.put(userID, data);  // Update cache when data changes
}
```

#### Cache Strategy:
- **Read-Through**: Check cache first, load from source on miss
- **Write-Through**: Update cache immediately when data changes  
- **User-Scoped**: Each user has separate cached TODO data
- **In-Memory**: Fast access using memory-cache library

#### Benefits:
- **Performance**: Instant data access for cached users
- **Scalability**: Reduces load on underlying data store
- **Simplicity**: Application controls cache lifecycle
- **Consistency**: Cache updated on every write operation

### Pattern Benefits Summary

| Pattern | Purpose | Benefit | Implementation |
|---------|---------|---------|----------------|
| **Circuit Breaker** | Fault tolerance | Prevents cascade failures | Opossum library with Redis |
| **Cache-Aside** | Performance | Fast data access | Memory-cache with user scoping |


These patterns work together to create a **resilient, performant, and maintainable** microservice architecture that can handle failures gracefully while providing excellent user experience.