# 🚀 Kotlin-Java Microservices Environment

## 📁 **Project Organization**

```
📦 ms-kotlin-backend/
├── 🚀 Core Automation
│   ├── start.sh                    → Main environment control
│   ├── start-infrastructure.sh     → Infrastructure startup
│   ├── stop.sh                     → Stop environment
│   ├── monitor.sh                  → Real-time monitoring
│   ├── test-environment.sh         → Health checking
│   └── docker-compose.yml          → Container orchestration
│
├── 🏗️ Microservices
│   ├── configuration-server/       → Spring Cloud Config
│   ├── discover-server/            → Eureka Discovery
│   ├── product-service/            → Product management
│   └── order-service/              → Order management
│
├── � Infrastructure
│   ├── vault-docker/               → HashiCorp Vault (secrets)
│   ├── kafka-docker/               → Kafka messaging
│   └── microservices-config-server/ → External configs
│
├── 📜 Build Optimizations
│   └── scripts/
│       ├── build/                  → Gradle optimizations
│       ├── environment/            → Environment scripts
│       └── optimization/           → Performance tools
│
├── 📚 Documentation
│   ├── setup/                      → Installation guides
│   ├── troubleshooting/            → Issue resolution
│   ├── guides/                     → Feature guides
│   └── architecture/               → System design
│
├── 🐳 Docker & Configs
│   ├── docker/                     → Docker configurations
│   ├── configs/                    → Service configurations
│   └── init-scripts/               → Database initialization
```

## 🎯 **Quick Commands**

### **Complete Environment**
```bash
./start.sh                         # Start complete environment (default)
./start.sh status                  # Check all services status
./start.sh restart                 # Restart all services
./start.sh logs [service-name]     # View service logs
./stop.sh                          # Stop all services
```

### **Modular Infrastructure**
```bash
./start-infrastructure.sh          # Start infrastructure only
./start.sh infrastructure          # Alternative infrastructure start
./start.sh services                # Start microservices only
```

### **Development & Debugging**
```bash
./start.sh build                   # Build all services
./start.sh clean                   # Clean containers & cache
./monitor.sh                       # Real-time monitoring dashboard
./test-environment.sh              # Health checks & endpoint testing
./test-environment.sh infrastructure # Test infrastructure only
./test-environment.sh all          # Complete system health check
```

### **Build Optimizations**
```bash
./scripts/build/optimize-builds.sh        # Gradle optimizations
./scripts/build/optimize-docker-builds.sh # Docker layer caching
```

## 📖 **Documentation**

| Topic | Location | Description |
|-------|----------|-------------|
| **Setup** | [`docs/setup/`](docs/setup/) | Installation & configuration |
| **Troubleshooting** | [`docs/troubleshooting/`](docs/troubleshooting/) | Common issues & solutions |
| **Guides** | [`docs/guides/`](docs/guides/) | Feature guides & best practices |
| **Architecture** | [`docs/architecture/`](docs/architecture/) | System design & patterns |

## 🛠️ **Key Features**

- ✅ **Modular Architecture**: Start infrastructure and services independently
- ✅ **Real-time Monitoring**: Live service status, health checks, and logs
- ✅ **Auto-optimized Builds**: 70-90% faster with Gradle & Docker caching
- ✅ **Health Monitoring**: Comprehensive endpoint testing and validation
- ✅ **Complete Automation**: Infrastructure → Core Services → Business Services
- ✅ **Cross-platform**: Windows/WSL/Linux compatible
- ✅ **Troubleshooting**: Detailed guides and automatic issue detection
- ✅ **Interview-ready**: Kotlin/Java comparisons and best practices

## 🏃 **Getting Started**

### **Quick Start (30 seconds)**
```bash
./start.sh                    # Starts everything automatically
./test-environment.sh all     # Verify everything is healthy
```

### **Development Workflow**
```bash
# 1. Start infrastructure
./start-infrastructure.sh

# 2. Build and start services
./start.sh services

# 3. Monitor real-time
./monitor.sh

# 4. Test everything
./test-environment.sh all
```

## 📊 **Infrastructure Components**

| Service | Port | Purpose | Health Check |
|---------|------|---------|--------------|
| **Kafka** | 9092 | Message broker | Zookeeper + Kafka brokers |
| **Kafka UI** | 8090 | Message monitoring | http://localhost:8090 |
| **Zookeeper** | 2181 | Kafka coordination | Internal health check |
| **Vault** | 8200 | Secrets management | http://localhost:8200/v1/sys/health |
| **MongoDB** | 27018 | Document database | Database connectivity |
| **MySQL** | 3307 | Relational database | Database connectivity |

## 🏗️ **Microservices**

| Service | Port | Purpose | Dependencies |
|---------|------|---------|--------------|
| **Configuration Server** | 8888 | Centralized config | Vault, Git repo |
| **Discovery Server** | 8761 | Service registry | Configuration Server |
| **Product Service** | 8082 | Product management | Discovery, Config, MySQL |
| **Order Service** | 8083 | Order processing | Discovery, Config, Product, MongoDB |

## 🔧 **Monitoring & Tools**

| Tool | Command | Purpose |
|------|---------|---------|
| **Real-time Monitor** | `./monitor.sh` | Live service status & logs |
| **Health Checker** | `./test-environment.sh` | Endpoint validation |
| **Infrastructure Status** | `./start-infrastructure.sh status` | Infrastructure health |
| **Service Logs** | `./start.sh logs [service]` | Individual service logs |

---

## 📊 **Project Stats**

- **Infrastructure Services**: 6 (Kafka, Vault, DBs, etc.)
- **Microservices**: 4 (Config, Discovery, Product, Order)
- **Build Time**: 30-60 seconds (optimized)
- **Startup Time**: 2-3 minutes (complete environment)
- **Documentation**: Comprehensive guides + troubleshooting
- **Scripts**: Fully automated environment with health monitoring

**For detailed guides, see the [`docs/`](docs/) directory and [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md).**
