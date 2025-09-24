# 🚀 Quick Start Guide

> **For when you need to quickly get back into development**

## ⚡ **Immediate Actions**

### **Start Working (30 seconds)**
```bash
# 1. Start everything
./start-infra.sh && ./start-dev.sh

# 2. Check status
./status-check.sh

# 3. Open key URLs
# - Eureka: http://localhost:8761
# - Vault: http://localhost:8200/ui (token: myroot)
```

### **If Services Don't Start**
```bash
# Check what's running
docker ps

# Check logs
docker logs ms-kotlin-[service-name]

# Restart infrastructure
./stop-infra.sh && ./start-infra.sh
```

## 🎯 **Current Focus**
- **Main Task**: Test full microservices stack
- **Learning Goal**: Kotlin development in business-services/
- **Files to Work On**: 
  - `business-services/product-service/src/main/kotlin/`
  - `business-services/order-service/src/main/kotlin/`

## 📍 **What's Done**
✅ Infrastructure (Vault, DBs, Kafka)  
✅ Project organization  
✅ Secrets auto-loading  
⚠️ **Next**: Test services startup

## 🔗 **Key Files**
- **Main Log**: `PROJECT-LOG.md`
- **Instructions**: `.github/copilot-instructions.md`
- **Kotlin Notes**: `docs/guides/KOTLIN-JAVA-INTERVIEW-NOTES.md`
- **Troubleshooting**: `TROUBLESHOOTING.md`