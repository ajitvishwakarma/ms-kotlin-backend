# 🛠️ Script Utilities

This folder contains build optimization utilities. Monitoring scripts have been moved to root level for easy access.

## 📋 Available Scripts

### Build Optimization
- **`optimize-builds.sh`** - Gradle build optimization setup
- **`optimize-docker-builds.sh`** - Docker build cache optimization

## � **Monitoring Scripts (Now at Root Level)**

For easy access, monitoring scripts are now at the root:
- **`../monitor.sh`** - Real-time colorful health monitoring
- **`../status-check.sh`** - One-time status check

## 🚀 Usage Examples

### Build Optimizations
```bash
# Optimize all Gradle builds for faster compilation
./script-utils/optimize-builds.sh

# Optimize Docker builds with shared cache
./script-utils/optimize-docker-builds.sh
```

### Monitoring (From Root)
```bash
# Real-time monitoring
./monitor.sh

# Quick status check
./status-check.sh

# Monitor with custom refresh interval
./monitor.sh --interval 5
```

## 🎯 When to Use

### During Development
- **monitor.sh**: Keep running in a separate terminal to watch service health
- **status-check.sh**: Quick check when things seem down

### Setup & Optimization
- **optimize-builds.sh**: Run once after cloning to speed up Gradle builds
- **optimize-docker-builds.sh**: Run to set up Docker build caching

## 🔗 Integration with Main Scripts

These utilities work alongside the main scripts:
- `start-infra.sh` - Start infrastructure
- `start-dev.sh` - Start development services  
- `stop-infra.sh` - Stop infrastructure
- `stop-dev.sh` - Stop development services

**Typical Workflow:**
```bash
# 1. Start infrastructure
./start-infra.sh

# 2. Start monitoring in background
./script-utils/monitor.sh &

# 3. Start development services
./start-dev.sh

# 4. Develop with real-time health visibility
```

## 📁 Script Organization

All utility scripts are now consolidated in this folder instead of scattered across multiple directories. This provides:
- ✅ Single location for all utilities
- ✅ Easy discovery and maintenance
- ✅ Clear separation from main workflow scripts
- ✅ Better project organization

---

**Note:** Main workflow scripts remain at the root level for easy access:
- `./start-infra.sh` and `./start-dev.sh` (most frequently used)
- Utility scripts here in `./script-utils/` (occasional use)