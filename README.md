# 🚀## 📋 **Essential Documentation**
- **🚀 [QUICK-START.md](QUICK-START.md)** - Get up and running in 30 seconds
- **📋 [PROJECT-LOG.md](PROJECT-LOG.md)** - Complete project status, what's done, what's next
- **🎯 [KOTLIN-JAVA-INTERVIEW-NOTES.md](KOTLIN-JAVA-INTERVIEW-NOTES.md)** - Learning materials
- **🔧 [TROUBLESHOOTING.md](TROUBLESHOOTING.md)** - Common issues and solutionsin Microservices - Interview Preparation Environment

**Purpose**: Kotlin-based microservices for interview preparation and Java-to-Kotlin transition learning.

## � **Documentation Quick Links**
- **🚀 [QUICK-START.md](QUICK-START.md)** - Get up and running in 30 seconds
- **📋 [PROJECT-LOG.md](PROJECT-LOG.md)** - Complete project status, what's done, what's next
- **🎯 [Kotlin Interview Notes](docs/guides/KOTLIN-JAVA-INTERVIEW-NOTES.md)** - Learning materials
- **🔧 [Troubleshooting](TROUBLESHOOTING.md)** - Common issues and solutions

## ⚡ **Quick Start**

```bash
# Start infrastructure (databases, Kafka, Vault with auto-secrets)
./start-infra.sh

# Start microservices (Config, Discovery, Business Services)
./start-dev.sh

# Check everything is running
./status-check.sh
```

## 📁 **Project Structure**

📦 ms-kotlin-backend/

├── 🚀 **Main Scripts** (Interview Focus)# Start microservices (Config, Discovery, Business Services)  ./start-infra.sh

```
📦 ms-kotlin-backend/
├── 🚀 **Main Scripts** (Interview Focus)
│   ├── start-infra.sh              → Infrastructure only
│   ├── start-dev.sh                → Development services
│   ├── stop-infra.sh               → Stop infrastructure  
│   ├── stop-dev.sh                 → Stop development
│   ├── monitor.sh                  → Real-time health monitoring
│   └── status-check.sh             → One-time status check
│
├── 🛠️ **Utility Scripts**
│   └── script-utils/               → Build optimization tools
│       ├── optimize-builds.sh      → Gradle optimizations
│       └── optimize-docker-builds.sh → Docker build caching
│
├── 🏗️ **Core Services**
│   └── core-services/              
│       ├── configuration-server/   → Spring Cloud Config
│       └── discover-server/        → Eureka Service Discovery
│
├── 🏢 **Business Services**        → **MAIN FOCUS FOR INTERVIEWS**
│   └── business-services/          
│       ├── product-service/        → Kotlin + MongoDB  
│       ├── order-service/          → Kotlin + MySQL
│       └── microservices-config-server/ → Config properties
│
└── 🏗️ **Infrastructure** 
    ├── databases/                  → MongoDB + MySQL + init scripts
    ├── kafka/                      → Messaging + UI
    └── vault/                      → Secrets management + JSON configs
        └── secrets/                → Secret configuration files

└── 📚 **Documentation**

    └── docs/                       → Interview guides & architecture├── 🛠️ **Utility Scripts**│   ├── start-infra.sh              → Infrastructure only

```

│   └── script-utils/               → Monitoring & optimization tools│   ├── start-dev.sh                → Development services

## 🎯 **Quick Commands**

│       ├── monitor.sh              → Real-time health monitoring│   ├── stop-infra.sh               → Stop infrastructure  

### **Main Workflow** (Interview Focus)

```bash│       ├── status-check.sh         → One-time status check│   └── stop-dev.sh                 → Stop development

# Start infrastructure (databases, Kafka, Vault)

./start-infra.sh│       ├── optimize-builds.sh      → Gradle optimizations│



# Start development services (Config, Discovery, Business)│       └── optimize-docker-builds.sh → Docker build caching├── 🛠️ **Utility Scripts**

./start-dev.sh

││   └── script-utils/               → Monitoring & optimization tools

# Stop services

./stop-dev.sh                      # Stop development services only├── 🏗️ **Core Services**│       ├── monitor.sh              → Real-time health monitoring

./stop-infra.sh                    # Stop infrastructure

```│   ├── core-services/              │       ├── status-check.sh         → One-time status check



### **Monitoring & Status**│   │   ├── configuration-server/   → Spring Cloud Config│       ├── optimize-builds.sh      → Gradle optimizations

```bash

# Real-time colorful monitoring dashboard│   │   └── discovery-server/       → Eureka Service Discovery│       └── optimize-docker-builds.sh → Docker build caching

./monitor.sh

│   └── business-services/          → **MAIN FOCUS FOR INTERVIEWS**│

# One-time status check

./status-check.sh│       ├── product-service/        → Kotlin + MongoDB  ├── 🏗️ **Core Services**



# Monitor with custom refresh interval│       └── order-service/          → Kotlin + MySQL│   ├── core-services/              

./monitor.sh --interval 5

││   │   ├── configuration-server/   → Spring Cloud Config

# Quick help

./monitor.sh --help├── 🛠️ **Infrastructure** │   │   └── discovery-server/       → Eureka Service Discovery

```

│   ├── databases/                  → MongoDB + MySQL│   └── business-services/          → **MAIN FOCUS FOR INTERVIEWS**

### **Build Optimizations**

```bash│   ├── kafka/                      → Messaging + UI│       ├── product-service/        → Kotlin + MongoDB  

# Gradle build optimizations (run once after setup)

./script-utils/optimize-builds.sh│   ├── vault/                      → Secrets management│       └── order-service/          → Kotlin + MySQL



# Docker build cache optimization│   └── init-data/                  → Sample data for all services│

./script-utils/optimize-docker-builds.sh

```│├── 🛠️ **Infrastructure** 



## 📖 **Documentation**└── 📚 **Documentation**│   ├── databases/                  → MongoDB + MySQL



- **📚 Main Guide**: [`docs/README.md`](docs/README.md) - Complete setup & usage guide    └── docs/                       → Interview guides & architecture│   ├── kafka/                      → Messaging + UI

- **🔧 Troubleshooting**: [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md) - Common issues & solutions

- **🧠 Interview Notes**: [`docs/guides/KOTLIN-JAVA-INTERVIEW-NOTES.md`](docs/guides/KOTLIN-JAVA-INTERVIEW-NOTES.md) - Kotlin concepts for Java developers```│   ├── vault/                      → Secrets management



## 🌐 **Service Endpoints**│   └── init-data/                  → Sample data for all services



| Service | Port | Purpose | Health Check |## 🎯 **Quick Commands**│

|---------|------|---------|--------------|

| **Infrastructure** |└── 📚 **Documentation**

| MongoDB | 27018 | Product Database | `mongosh --port 27018` |

| MySQL | 3307 | Order Database | `mysql -h localhost -P 3307 -u root -p` |### **Main Workflow** (Interview Focus)    └── docs/                       → Interview guides & architecture

| Kafka UI | 8090 | Message Broker UI | http://localhost:8090 |

| Vault | 8200 | Secrets Management | http://localhost:8200 |```bash├── � Infrastructure

| **Microservices** |

| Config Server | 8888 | Configuration | http://localhost:8888/actuator/health |# Start infrastructure (databases, Kafka, Vault)│   ├── vault-docker/               → HashiCorp Vault (secrets)

| Discovery Server | 8761 | Service Registry | http://localhost:8761 |

| Product Service | 8082 | Product APIs | http://localhost:8082/actuator/health |./start-infra.sh│   ├── kafka-docker/               → Kafka messaging

| Order Service | 8083 | Order APIs | http://localhost:8083/actuator/health |

│   └── microservices-config-server/ → External configs

## 🎓 **Interview Focus Areas**

# Start development services (Config, Discovery, Business)│

### **Kotlin Language Features** (business-services/)

- Data classes vs Java POJOs./start-dev.sh├── 📜 Build Optimizations

- Null safety and type system

- Coroutines vs Java threads│   └── scripts/

- Extension functions and DSL

# Stop services│       ├── build/                  → Gradle optimizations

### **Microservices Patterns**

- Service discovery (Eureka)./stop-dev.sh                      # Stop development services only│       ├── environment/            → Environment scripts

- Configuration management (Spring Cloud Config)

- Database per service (MongoDB, MySQL)./stop-infra.sh                    # Stop infrastructure│       └── optimization/           → Performance tools

- Message-driven architecture (Kafka)

```│

### **Spring Boot + Kotlin**

- Auto-configuration differences├── 📚 Documentation

- Dependency injection patterns

- Repository and service layers### **Monitoring & Status**│   ├── setup/                      → Installation guides

- RESTful API design

```bash│   ├── troubleshooting/            → Issue resolution

## 🚀 **Getting Started**

# Real-time colorful monitoring dashboard│   ├── guides/                     → Feature guides

1. **Clone & Setup**

   ```bash./script-utils/monitor.sh│   └── architecture/               → System design

   git clone <repository-url>

   cd ms-kotlin-backend│

   ```

# One-time status check├── 🐳 Docker & Configs

2. **Start Environment**

   ```bash./script-utils/status-check.sh│   ├── docker/                     → Docker configurations

   # Start infrastructure

   ./start-infra.sh│   ├── configs/                    → Service configurations

   

   # In a new terminal, start monitoring# Monitor with custom refresh interval│   └── init-scripts/               → Database initialization

   ./monitor.sh

   ./script-utils/monitor.sh --interval 5```

   # Start development services

   ./start-dev.sh

   ```

# Quick help## 🎯 **Quick Commands**

3. **Verify Setup**

   ```bash./script-utils/monitor.sh --help

   # Check all services are healthy

   ./status-check.sh```### **Main Workflow** (Interview Focus)

   ```

```bash

4. **Start Development**

   - Open `business-services/` in IntelliJ IDEA### **Build Optimizations**# Start infrastructure (databases, Kafka, Vault)

   - Focus on `product-service` and `order-service`

   - Practice Kotlin patterns and microservices concepts```bash./start-infra.sh



## 🛠️ **Development Workflow**# Gradle build optimizations (run once after setup)



### **For IntelliJ Development** (Recommended)./script-utils/optimize-builds.sh# Start development services (Config, Discovery, Business)

```bash

# 1. Start infrastructure only./start-dev.sh

./start-infra.sh

# Docker build cache optimization

# 2. Open business services in IntelliJ

# 3. Run services from IDE for debugging./script-utils/optimize-docker-builds.sh# Stop services

```

```./stop-dev.sh                      # Stop development services only

### **For Docker Development**

```bash./stop-infra.sh                    # Stop infrastructure

# Start everything in Docker

./start-infra.sh && ./start-dev.sh## 📖 **Documentation**```

```



### **Optimization Setup** (Run Once)

```bash- **📚 Main Guide**: [`docs/README.md`](docs/README.md) - Complete setup & usage guide### **Monitoring & Status**

# Optimize Gradle builds

./script-utils/optimize-builds.sh- **🔧 Troubleshooting**: [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md) - Common issues & solutions```bash



# Optimize Docker builds- **🧠 Interview Notes**: [`docs/guides/KOTLIN-JAVA-INTERVIEW-NOTES.md`](docs/guides/KOTLIN-JAVA-INTERVIEW-NOTES.md) - Kotlin concepts for Java developers# Real-time colorful monitoring dashboard

./script-utils/optimize-docker-builds.sh

```./script-utils/monitor.sh



## 🔐 **Vault Secrets Management**## 🌐 **Service Endpoints**



Secrets are managed via JSON files in `infrastructure/vault/secrets/`:# One-time status check



- **`product-service.json`**: MongoDB connection details| Service | Port | Purpose | Health Check |./script-utils/status-check.sh

- **`order-service.json`**: MySQL connection details

|---------|------|---------|--------------|

These files are automatically loaded into Vault when infrastructure starts. Modify these files to update secrets.

| **Infrastructure** |# Monitor with custom refresh interval

## 📊 **Project Philosophy**

| MongoDB | 27018 | Product Database | `mongosh --port 27018` |./script-utils/monitor.sh --interval 5

This project prioritizes **interview preparation efficiency**:

| MySQL | 3307 | Order Database | `mysql -h localhost -P 3307 -u root -p` |

- ✅ **Quick setup** - Infrastructure automated with init scripts in place

- ✅ **Focused learning** - Business services are the main target  | Kafka UI | 8090 | Message Broker UI | http://localhost:8090 |# Quick help

- ✅ **Real-world patterns** - Production-ready microservices architecture

- ✅ **Kotlin mastery** - Side-by-side Java comparisons in documentation| Vault | 8200 | Secrets Management | http://localhost:8200 |./script-utils/monitor.sh --help

- ✅ **Time-efficient** - Monitoring and optimization scripts at root level

| **Microservices** |```

## 🔄 **Next Steps**

| Config Server | 8888 | Configuration | http://localhost:8888/actuator/health |

After mastering the basics:

- Add API Gateway (planned)| Discovery Server | 8761 | Service Registry | http://localhost:8761 |### **Build Optimizations**

- Implement Circuit Breaker patterns (planned)

- Add centralized logging (planned)| Product Service | 8082 | Product APIs | http://localhost:8082/actuator/health |```bash

- Enhance Vault integration (planned)

| Order Service | 8083 | Order APIs | http://localhost:8083/actuator/health |# Gradle build optimizations (run once after setup)

---

./script-utils/optimize-builds.sh

**Happy Learning! 🎯**

## 🎓 **Interview Focus Areas**

For questions, check [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md) or the monitoring dashboard with `./monitor.sh`.
# Docker build cache optimization

### **Kotlin Language Features** (business-services/)./script-utils/optimize-docker-builds.sh

- Data classes vs Java POJOs```

- Null safety and type system

- Coroutines vs Java threads## 📖 **Documentation**

- Extension functions and DSL

| Topic | Location | Description |

### **Microservices Patterns**|-------|----------|-------------|

- Service discovery (Eureka)| **Setup** | [`docs/setup/`](docs/setup/) | Installation & configuration |

- Configuration management (Spring Cloud Config)| **Troubleshooting** | [`docs/troubleshooting/`](docs/troubleshooting/) | Common issues & solutions |

- Database per service (MongoDB, MySQL)| **Guides** | [`docs/guides/`](docs/guides/) | Feature guides & best practices |

- Message-driven architecture (Kafka)| **Architecture** | [`docs/architecture/`](docs/architecture/) | System design & patterns |



### **Spring Boot + Kotlin**## 🛠️ **Key Features**

- Auto-configuration differences

- Dependency injection patterns- ✅ **Modular Architecture**: Start infrastructure and services independently

- Repository and service layers- ✅ **Real-time Monitoring**: Live service status, health checks, and logs

- RESTful API design- ✅ **Auto-optimized Builds**: 70-90% faster with Gradle & Docker caching

- ✅ **Health Monitoring**: Comprehensive endpoint testing and validation

## 🚀 **Getting Started**- ✅ **Complete Automation**: Infrastructure → Core Services → Business Services

- ✅ **Cross-platform**: Windows/WSL/Linux compatible

1. **Clone & Setup**- ✅ **Troubleshooting**: Detailed guides and automatic issue detection

   ```bash- ✅ **Interview-ready**: Kotlin/Java comparisons and best practices

   git clone <repository-url>

   cd ms-kotlin-backend## 🏃 **Getting Started**

   ```

### **Quick Start (30 seconds)**

2. **Start Environment**```bash

   ```bash./start.sh                    # Starts everything automatically

   # Start infrastructure./test-environment.sh all     # Verify everything is healthy

   ./start-infra.sh```

   

   # In a new terminal, start monitoring### **Development Workflow**

   ./script-utils/monitor.sh```bash

   # 1. Start infrastructure

   # Start development services./start-infrastructure.sh

   ./start-dev.sh

   ```# 2. Build and start services

./start.sh services

3. **Verify Setup**

   ```bash# 3. Monitor real-time

   # Check all services are healthy./monitor.sh

   ./script-utils/status-check.sh

   ```# 4. Test everything

./test-environment.sh all

4. **Start Development**```

   - Open `business-services/` in IntelliJ IDEA

   - Focus on `product-service` and `order-service`## 📊 **Infrastructure Components**

   - Practice Kotlin patterns and microservices concepts

| Service | Port | Purpose | Health Check |

## 🛠️ **Development Workflow**|---------|------|---------|--------------|

| **Kafka** | 9092 | Message broker | Zookeeper + Kafka brokers |

### **For IntelliJ Development** (Recommended)| **Kafka UI** | 8090 | Message monitoring | http://localhost:8090 |

```bash| **Zookeeper** | 2181 | Kafka coordination | Internal health check |

# 1. Start infrastructure only| **Vault** | 8200 | Secrets management | http://localhost:8200/v1/sys/health |

./start-infra.sh| **MongoDB** | 27018 | Document database | Database connectivity |

| **MySQL** | 3307 | Relational database | Database connectivity |

# 2. Open business services in IntelliJ

# 3. Run services from IDE for debugging## 🏗️ **Microservices**

```

| Service | Port | Purpose | Dependencies |

### **For Docker Development**|---------|------|---------|--------------|

```bash| **Configuration Server** | 8888 | Centralized config | Vault, Git repo |

# Start everything in Docker| **Discovery Server** | 8761 | Service registry | Configuration Server |

./start-infra.sh && ./start-dev.sh| **Product Service** | 8082 | Product management | Discovery, Config, MySQL |

```| **Order Service** | 8083 | Order processing | Discovery, Config, Product, MongoDB |



### **Optimization Setup** (Run Once)## 🔧 **Monitoring & Tools**

```bash

# Optimize Gradle builds| Tool | Command | Purpose |

./script-utils/optimize-builds.sh|------|---------|---------|

| **Real-time Monitor** | `./monitor.sh` | Live service status & logs |

# Optimize Docker builds| **Health Checker** | `./test-environment.sh` | Endpoint validation |

./script-utils/optimize-docker-builds.sh| **Infrastructure Status** | `./start-infrastructure.sh status` | Infrastructure health |

```| **Service Logs** | `./start.sh logs [service]` | Individual service logs |



## 📊 **Project Philosophy**---



This project prioritizes **interview preparation efficiency**:## 📊 **Project Stats**



- ✅ **Quick setup** - Infrastructure automated- **Infrastructure Services**: 6 (Kafka, Vault, DBs, etc.)

- ✅ **Focused learning** - Business services are the main target  - **Microservices**: 4 (Config, Discovery, Product, Order)

- ✅ **Real-world patterns** - Production-ready microservices architecture- **Build Time**: 30-60 seconds (optimized)

- ✅ **Kotlin mastery** - Side-by-side Java comparisons in documentation- **Startup Time**: 2-3 minutes (complete environment)

- ✅ **Time-efficient** - Monitoring and optimization scripts included- **Documentation**: Comprehensive guides + troubleshooting

- **Scripts**: Fully automated environment with health monitoring

## 🔄 **Next Steps**

**For detailed guides, see the [`docs/`](docs/) directory and [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md).**

After mastering the basics:
- Add API Gateway (planned)
- Implement Circuit Breaker patterns (planned)
- Add centralized logging (planned)
- Enhance Vault integration (planned)

---

**Happy Learning! 🎯**

For questions, check [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md) or the monitoring dashboard with `./script-utils/monitor.sh`.