#!/bin/bash

# =============================================================================
# 🚀 BLAZING FAST STATUS CHECK - Using docker ps (fastest possible)
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
declare -A INFRA_SERVICES=(
    ["ms-kotlin-mongodb"]="MongoDB:27018"
    ["ms-kotlin-mysql"]="MySQL:3307"
    ["ms-kotlin-zookeeper"]="Zookeeper:2181"
    ["ms-kotlin-kafka"]="Kafka:9092"
    ["ms-kotlin-kafka-ui"]="Kafka-UI:8090"
    ["ms-kotlin-vault"]="Vault:8200"
)

declare -A MICRO_SERVICES=(
    ["ms-kotlin-configuration-server"]="Config:8888"
    ["ms-kotlin-discover-server"]="Discovery:8761"
    ["ms-kotlin-product-service"]="Products:8082"
    ["ms-kotlin-order-service"]="Orders:8083"
)

show_header() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${WHITE}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${WHITE}║${NC} ${CYAN}🚀 Blazing Fast Status Check${NC} ${WHITE}║${NC} ${GRAY}${timestamp}${NC} ${WHITE}║${NC}"
    echo -e "${WHITE}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo
}

get_status_icon() {
    local status_info=$1
    
    if [[ "$status_info" == *"(healthy)"* ]]; then
        echo -e "${GREEN}✅ HEALTHY${NC}"
    elif [[ "$status_info" == *"(starting)"* ]]; then
        echo -e "${YELLOW}⏳ STARTING${NC}"
    elif [[ "$status_info" == *"(unhealthy)"* ]]; then
        echo -e "${RED}⚠️  UNHEALTHY${NC}"
    elif [[ "$status_info" == "Up"* ]]; then
        echo -e "${GREEN}🟢 RUNNING${NC}"
    elif [[ "$status_info" == "Restarting"* ]]; then
        echo -e "${YELLOW}🔄 RESTARTING${NC}"
    elif [[ "$status_info" == "Paused"* ]]; then
        echo -e "${BLUE}⏸️  PAUSED${NC}"
    elif [[ "$status_info" == "Exited"* ]]; then
        echo -e "${RED}❌ STOPPED${NC}"
    else
        echo -e "${GRAY}⚫ NOT RUNNING${NC}"
    fi
}

show_service_group() {
    local title=$1
    local -n services=$2
    local -n status_data=$3
    
    echo -e "${WHITE}┌─ ${title} ────────────────────────────────${NC}"
    echo -e "${WHITE}│${NC}"
    printf "${WHITE}│${NC} %-25s %s %s\n" "SERVICE" "STATUS" "ENDPOINT"
    echo -e "${WHITE}│${NC} ───────────────────────── ────────── ─────────────────"
    
    for container_name in "${!services[@]}"; do
        local service_info="${services[$container_name]}"
        local service_name=$(echo "$service_info" | cut -d':' -f1)
        local port=$(echo "$service_info" | cut -d':' -f2)
        
        local status_info="${status_data[$container_name]:-"NOT_RUNNING"}"
        local status_display=$(get_status_icon "$status_info")
        
        printf "${WHITE}│${NC} %-25s %s ${CYAN}localhost:${port}${NC}\n" \
            "$service_name" \
            "$status_display"
    done
    
    echo -e "${WHITE}└─────────────────────────────────────────────────────────────────────────────${NC}"
    echo
}

# BLAZING FAST STATUS CHECK
start_time=$(date +%s.%N 2>/dev/null || date +%s)

echo -e "${CYAN}🚀 Blazing Fast Status Check${NC}"
echo

# Single docker ps call - fastest possible
docker_output=$(docker ps -a --format "{{.Names}}:{{.Status}}" --filter "name=ms-kotlin-" 2>/dev/null || echo "")

# Parse into associative array for instant lookup
declare -A container_status
while IFS=':' read -r name status; do
    if [ -n "$name" ]; then
        container_status["$name"]="$status"
    fi
done <<< "$docker_output"

# Display results instantly
show_header
show_service_group "🏗️  INFRASTRUCTURE SERVICES" INFRA_SERVICES container_status
show_service_group "🚀 MICROSERVICES" MICRO_SERVICES container_status

# Calculate performance
end_time=$(date +%s.%N 2>/dev/null || date +%s)
processing_time=$(echo "$end_time - $start_time" | bc 2>/dev/null || echo "< 0.1")

# Summary
total_containers=$((${#INFRA_SERVICES[@]} + ${#MICRO_SERVICES[@]}))
running_count=$(echo "$docker_output" | grep -c "Up" 2>/dev/null || echo "0")

echo -e "${GREEN}🚀 Status check completed in ${processing_time}s using single 'docker ps' call!${NC}"
echo -e "${GRAY}📊 ${running_count}/${total_containers} containers running${NC}"