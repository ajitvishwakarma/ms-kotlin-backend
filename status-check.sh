#!/bin/bash

# =============================================================================
# 🔍 SERVICE MONITOR - One-time status check
# =============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color

# Service definitions
declare -A INFRASTRUCTURE_SERVICES=(
    ["ms-kotlin-mongodb"]="MongoDB:27018"
    ["ms-kotlin-mysql"]="MySQL:3307"
    ["ms-kotlin-zookeeper"]="Zookeeper:2181"
    ["ms-kotlin-kafka"]="Kafka:9092"
    ["ms-kotlin-kafka-ui"]="Kafka-UI:8090"
    ["ms-kotlin-vault"]="Vault:8200"
)

declare -A MICROSERVICES=(
    ["ms-kotlin-configuration-server"]="Config:8888"
    ["ms-kotlin-discover-server"]="Discovery:8761"
    ["ms-kotlin-product-service"]="Products:8082"
    ["ms-kotlin-order-service"]="Orders:8083"
)

# Status icons and colors
get_status_display() {
    local container_name=$1
    local status=""
    local health=""
    local icon=""
    local color=""
    
    # Check if container exists and get status
    if docker inspect "$container_name" >/dev/null 2>&1; then
        status=$(docker inspect --format='{{.State.Status}}' "$container_name" 2>/dev/null)
        health=$(docker inspect --format='{{.State.Health.Status}}' "$container_name" 2>/dev/null || echo "no-healthcheck")
        
        case "$status" in
            "running")
                case "$health" in
                    "healthy")
                        icon="✅"
                        color=$GREEN
                        status="HEALTHY"
                        ;;
                    "starting")
                        icon="⏳"
                        color=$YELLOW
                        status="STARTING"
                        ;;
                    "unhealthy")
                        icon="⚠️ "
                        color=$RED
                        status="UNHEALTHY"
                        ;;
                    "no-healthcheck")
                        icon="🟢"
                        color=$GREEN
                        status="RUNNING"
                        ;;
                    *)
                        icon="❓"
                        color=$PURPLE
                        status="UNKNOWN"
                        ;;
                esac
                ;;
            "restarting")
                icon="🔄"
                color=$YELLOW
                status="RESTARTING"
                ;;
            "paused")
                icon="⏸️ "
                color=$BLUE
                status="PAUSED"
                ;;
            "exited")
                icon="❌"
                color=$RED
                status="STOPPED"
                ;;
            "dead")
                icon="💀"
                color=$RED
                status="DEAD"
                ;;
            *)
                icon="❓"
                color=$PURPLE
                status="UNKNOWN"
                ;;
        esac
    else
        icon="⚫"
        color=$GRAY
        status="NOT RUNNING"
    fi
    
    echo -e "${color}${icon} ${status}${NC}"
}

get_uptime() {
    local container_name=$1
    if docker inspect "$container_name" >/dev/null 2>&1; then
        local started_at=$(docker inspect --format='{{.State.StartedAt}}' "$container_name" 2>/dev/null)
        if [ "$started_at" != "0001-01-01T00:00:00Z" ]; then
            echo "running"
        else
            echo "-"
        fi
    else
        echo "-"
    fi
}

show_header() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${WHITE}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${WHITE}║${NC} ${CYAN}🔍 Kotlin Microservices Health Monitor${NC} ${WHITE}║${NC} ${GRAY}${timestamp}${NC} ${WHITE}║${NC}"
    echo -e "${WHITE}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo
}

show_service_group() {
    local title=$1
    local -n services=$2
    local max_name_len=25
    
    echo -e "${WHITE}┌─ ${title} ${WHITE}$(printf '─%.0s' $(seq 1 $((60 - ${#title}))))"
    echo -e "${WHITE}│${NC}"
    printf "${WHITE}│${NC} %-${max_name_len}s %s %s\n" "SERVICE" "STATUS" "ENDPOINT"
    echo -e "${WHITE}│${NC} $(printf '─%.0s' $(seq 1 $max_name_len)) ────────── ─────────────────"
    
    for container_name in "${!services[@]}"; do
        local service_info="${services[$container_name]}"
        local service_name=$(echo "$service_info" | cut -d':' -f1)
        local port=$(echo "$service_info" | cut -d':' -f2)
        
        local status_display=$(get_status_display "$container_name")
        local endpoint="localhost:$port"
        
        printf "${WHITE}│${NC} %-${max_name_len}s %s ${CYAN}%s${NC}\n" \
            "$service_name" \
            "$status_display" \
            "$endpoint"
    done
    
    echo -e "${WHITE}└$(printf '─%.0s' $(seq 1 77))${NC}"
    echo
}

# One-time status check
show_header
show_service_group "🏗️  INFRASTRUCTURE SERVICES" INFRASTRUCTURE_SERVICES
show_service_group "🚀 MICROSERVICES" MICROSERVICES