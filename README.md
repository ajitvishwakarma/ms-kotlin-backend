# 🚀 Kotlin-Java Microservices (Organized Structure)

## 📁 **Project Organization**

```
📦 ms-kotlin-backend/
├── 🚀 Quick Start
│   ├── start.sh           → Start environment
│   ├── stop.sh            → Stop environment  
│   └── docker-compose.yml → Main Docker config
│
├── 🏗️ Services
│   ├── configuration-server/
│   ├── discover-server/
│   ├── product-service/
│   └── order-service/
│
├── 📜 Scripts
│   ├── environment/       → Start/stop scripts
│   ├── build/             → Build optimizations
│   └── optimization/      → Performance scripts
│
├── 📚 Documentation
│   ├── setup/            → Setup guides
│   ├── troubleshooting/  → Issue resolution
│   ├── guides/           → Feature guides
│   └── architecture/     → System design
│
├── 🐳 Docker
│   ├── compose/          → Docker Compose files
│   └── infrastructure/   → Docker configs
│
├── ⚙️ Configs
│   ├── gradle/           → Build configurations
│   ├── docker/           → Docker settings
│   └── services/         → Service configs
│
└── 🔧 Infrastructure
    ├── vault-docker/     → HashiCorp Vault
    ├── kafka-docker/     → Kafka setup
    └── microservices-config-server/
```

## 🎯 **Quick Commands**

### **Start Everything**
```bash
./start.sh                    # Full environment
./start.sh build              # Build + start
./start.sh status              # Check status
```

### **Stop Everything**
```bash
./stop.sh                     # Graceful stop
./stop.sh force               # Force stop
./stop.sh clean               # Deep clean
```

### **Build Optimizations**
```bash
./scripts/build/optimize-builds.sh           # Gradle optimizations
./scripts/build/optimize-docker-builds.sh    # Docker optimizations
```

## 📖 **Documentation**

| Topic | Location | Description |
|-------|----------|-------------|
| **Setup** | [`docs/setup/`](docs/setup/) | Installation & configuration |
| **Troubleshooting** | [`docs/troubleshooting/`](docs/troubleshooting/) | Common issues & solutions |
| **Guides** | [`docs/guides/`](docs/guides/) | Feature guides & best practices |
| **Architecture** | [`docs/architecture/`](docs/architecture/) | System design & patterns |

## 🛠️ **Key Features**

- ✅ **Auto-optimized builds** (70-90% faster)
- ✅ **Docker layer caching** (60-80% faster)
- ✅ **Health monitoring** with detailed status
- ✅ **Complete automation** (start, build, monitor, stop)
- ✅ **Comprehensive documentation** (setup to troubleshooting)
- ✅ **Interview-ready** Kotlin/Java comparisons

## 🏃 **Getting Started**

1. **Quick Start**: `./start.sh`
2. **Documentation**: Browse [`docs/`](docs/) folder
3. **Troubleshooting**: Check [`docs/troubleshooting/`](docs/troubleshooting/)

---

## 📊 **Project Stats**

- **Services**: 4 microservices + infrastructure
- **Build Time**: 30-60 seconds (optimized)
- **Documentation**: Comprehensive guides
- **Scripts**: Fully automated environment

**For detailed guides, see the [`docs/`](docs/) directory.**
