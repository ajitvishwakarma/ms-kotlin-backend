#!/bin/bash

# =============================================================================
# 🔍 SERVICE MONITOR - Real-time health monitoring with colorful indicators
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
            local uptime=$(docker inspect --format='{{.State.StartedAt}}' "$container_name" 2>/dev/null | xargs -I {} date -d {} +%s 2>/dev/null || echo "0")
            local current=$(date +%s)
            local diff=$((current - uptime))
            
            if [ $diff -gt 86400 ]; then
                echo "$((diff / 86400))d $((diff % 86400 / 3600))h"
            elif [ $diff -gt 3600 ]; then
                echo "$((diff / 3600))h $((diff % 3600 / 60))m"
            elif [ $diff -gt 60 ]; then
                echo "$((diff / 60))m $((diff % 60))s"
            else
                echo "${diff}s"
            fi
        else
            echo "0s"
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
    printf "${WHITE}│${NC} %-${max_name_len}s %s %s %s\n" "SERVICE" "STATUS" "UPTIME" "ENDPOINT"
    echo -e "${WHITE}│${NC} $(printf '─%.0s' $(seq 1 $max_name_len)) ────────── ──────── ─────────────────"
    
    for container_name in "${!services[@]}"; do
        local service_info="${services[$container_name]}"
        local service_name=$(echo "$service_info" | cut -d':' -f1)
        local port=$(echo "$service_info" | cut -d':' -f2)
        
        local status_display=$(get_status_display "$container_name")
        local uptime=$(get_uptime "$container_name")
        local endpoint="localhost:$port"
        
        printf "${WHITE}│${NC} %-${max_name_len}s %s %-8s ${CYAN}%s${NC}\n" \
            "$service_name" \
            "$status_display" \
            "$uptime" \
            "$endpoint"
    done
    
    echo -e "${WHITE}└$(printf '─%.0s' $(seq 1 77))${NC}"
    echo
}

show_summary() {
    local total=0
    local running=0
    local healthy=0
    local starting=0
    local stopped=0
    
    # Count infrastructure services
    for container_name in "${!INFRASTRUCTURE_SERVICES[@]}"; do
        ((total++))
        if docker inspect "$container_name" >/dev/null 2>&1; then
            local status=$(docker inspect --format='{{.State.Status}}' "$container_name" 2>/dev/null)
            local health=$(docker inspect --format='{{.State.Health.Status}}' "$container_name" 2>/dev/null || echo "no-healthcheck")
            
            if [ "$status" = "running" ]; then
                ((running++))
                if [ "$health" = "healthy" ] || [ "$health" = "no-healthcheck" ]; then
                    ((healthy++))
                elif [ "$health" = "starting" ]; then
                    ((starting++))
                fi
            else
                ((stopped++))
            fi
        else
            ((stopped++))
        fi
    done
    
    # Count microservices
    for container_name in "${!MICROSERVICES[@]}"; do
        ((total++))
        if docker inspect "$container_name" >/dev/null 2>&1; then
            local status=$(docker inspect --format='{{.State.Status}}' "$container_name" 2>/dev/null)
            local health=$(docker inspect --format='{{.State.Health.Status}}' "$container_name" 2>/dev/null || echo "no-healthcheck")
            
            if [ "$status" = "running" ]; then
                ((running++))
                if [ "$health" = "healthy" ] || [ "$health" = "no-healthcheck" ]; then
                    ((healthy++))
                elif [ "$health" = "starting" ]; then
                    ((starting++))
                fi
            else
                ((stopped++))
            fi
        else
            ((stopped++))
        fi
    done
    
    echo -e "${WHITE}┌─ SUMMARY ────────────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${WHITE}│${NC}"
    printf "${WHITE}│${NC} ${GREEN}✅ Healthy: %2d${NC}  ${YELLOW}⏳ Starting: %2d${NC}  ${RED}❌ Stopped: %2d${NC}  ${BLUE}📊 Total: %2d${NC}\n" \
        "$healthy" "$starting" "$stopped" "$total"
    echo -e "${WHITE}│${NC}"
    
    # Overall status
    if [ $healthy -eq $total ]; then
        echo -e "${WHITE}│${NC} ${GREEN}🎉 All services are healthy and running!${NC}"
    elif [ $running -gt 0 ]; then
        if [ $starting -gt 0 ]; then
            echo -e "${WHITE}│${NC} ${YELLOW}⏳ Some services are still starting up...${NC}"
        else
            echo -e "${WHITE}│${NC} ${YELLOW}⚠️  Some services need attention${NC}"
        fi
    else
        echo -e "${WHITE}│${NC} ${RED}🛑 No services are running${NC}"
    fi
    
    echo -e "${WHITE}│${NC}"
    echo -e "${WHITE}└──────────────────────────────────────────────────────────────────────────────┘${NC}"
}

show_quick_actions() {
    echo
    echo -e "${WHITE}┌─ QUICK ACTIONS ──────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${WHITE}│${NC} ${CYAN}./start-infra.sh${NC}     - Start infrastructure services"
    echo -e "${WHITE}│${NC} ${CYAN}./start-dev.sh${NC}       - Start development services"
    echo -e "${WHITE}│${NC} ${CYAN}./stop-infra.sh${NC}      - Stop infrastructure"
    echo -e "${WHITE}│${NC} ${CYAN}./stop-dev.sh${NC}        - Stop development services"
    echo -e "${WHITE}│${NC} ${GRAY}Ctrl+C${NC}               - Exit monitor"
    echo -e "${WHITE}└──────────────────────────────────────────────────────────────────────────────┘${NC}"
}

monitor_loop() {
    local refresh_interval=${1:-3}
    
    echo -e "${CYAN}🔍 Starting service monitor... (refresh every ${refresh_interval}s)${NC}"
    echo -e "${GRAY}Press Ctrl+C to exit${NC}"
    echo
    
    while true; do
        clear
        show_header
        show_service_group "🏗️  INFRASTRUCTURE SERVICES" INFRASTRUCTURE_SERVICES
        show_service_group "🚀 MICROSERVICES" MICROSERVICES
        show_summary
        show_quick_actions
        
        sleep $refresh_interval
    done
}

show_help() {
    echo -e "${CYAN}🔍 Service Health Monitor${NC}"
    echo
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Options:"
    echo "  -i, --interval SECONDS    Refresh interval (default: 3)"
    echo "  -h, --help               Show this help"
    echo
    echo "Examples:"
    echo "  $0                       Monitor with 3-second refresh"
    echo "  $0 -i 5                  Monitor with 5-second refresh"
    echo "  $0 --interval 1          Monitor with 1-second refresh"
}

# Parse command line arguments
REFRESH_INTERVAL=3

while [[ $# -gt 0 ]]; do
    case $1 in
        -i|--interval)
            REFRESH_INTERVAL="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Validate refresh interval
if ! [[ "$REFRESH_INTERVAL" =~ ^[0-9]+$ ]] || [ "$REFRESH_INTERVAL" -lt 1 ]; then
    echo "Error: Refresh interval must be a positive integer"
    exit 1
fi

# Start monitoring
monitor_loop $REFRESH_INTERVAL