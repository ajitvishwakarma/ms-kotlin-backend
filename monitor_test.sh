#!/bin/bash
# =============================================================================
# ��� ULTRA-FAST Kotlin Microservices Monitor - Optimized & Compact
# =============================================================================

set +e

# Colors
RED='\033[0;31m' GREEN='\033[0;32m' YELLOW='\033[1;33m' BLUE='\033[0;34m'
PURPLE='\033[0;35m' CYAN='\033[0;36m' WHITE='\033[1;37m' GRAY='\033[0;90m' NC='\033[0m'

# Service definitions (compact)
declare -A SERVICES=(
    ["ms-kotlin-mongodb"]="MongoDB:27018:infra"
    ["ms-kotlin-mysql"]="MySQL:3307:infra"
    ["ms-kotlin-zookeeper"]="Zookeeper:2181:infra"
    ["ms-kotlin-kafka"]="Kafka:9092:infra"
    ["ms-kotlin-kafka-ui"]="Kafka-UI:8090:infra"
    ["ms-kotlin-vault"]="Vault:8200:infra"
    ["ms-kotlin-configuration-server"]="Config:8888:micro"
    ["ms-kotlin-discover-server"]="Discovery:8761:micro"
    ["ms-kotlin-product-service"]="Products:8082:micro"
    ["ms-kotlin-order-service"]="Orders:8083:micro"
)

# Single function for status collection and display (BLAZING FAST)
get_service_status() {
    local container=$1
    local status_health=${2:-""}
    
    if [ -n "$status_health" ]; then
        local status=$(echo "$status_health" | cut -d':' -f1)
        local health=$(echo "$status_health" | cut -d':' -f2)
    else
        if docker inspect "$container" >/dev/null 2>&1; then
            status=$(docker inspect --format='{{.State.Status}}' "$container" 2>/dev/null)
            health=$(docker inspect --format='{{.State.Health.Status}}' "$container" 2>/dev/null || echo "no-healthcheck")
        else
            status="NOT_RUNNING"; health="unknown"
        fi
    fi
    
    # Unified status mapping (compact)
    case "$status:$health" in
        "running:healthy"|"running:no-healthcheck") echo -e "${GREEN}✅ HEALTHY${NC}" ;;
        "running:starting") echo -e "${YELLOW}⏳ STARTING${NC}" ;;
        "running:unhealthy") echo -e "${RED}⚠️  UNHEALTHY${NC}" ;;
        "restarting:"*) echo -e "${YELLOW}��� RESTARTING${NC}" ;;
        "exited:"*|"NOT_RUNNING:"*) echo -e "${GRAY}⚫ STOPPED${NC}" ;;
        *) echo -e "${PURPLE}❓ UNKNOWN${NC}" ;;
    esac
}

# Ultra-fast bulk status collection
collect_all_status() {
    declare -g -A STATUS_CACHE
    local docker_output=$(docker ps -a --format "{{.Names}}:{{.Status}}" --filter "name=ms-kotlin-" 2>/dev/null || echo "")
    
    # Parse docker output once
    while IFS=':' read -r name status; do
        [ -n "$name" ] && STATUS_CACHE["$name"]=$(
            case "$status" in
                *"(healthy)"*) echo "running:healthy" ;;
                *"(starting)"*) echo "running:starting" ;;
                *"(unhealthy)"*) echo "running:unhealthy" ;;
                "Up"*) echo "running:no-healthcheck" ;;
                "Restarting"*) echo "restarting:unknown" ;;
                "Exited"*) echo "exited:unknown" ;;
                *) echo "unknown:unknown" ;;
            esac
        )
    done <<< "$docker_output"
    
    # Fill missing containers
    for container in "${!SERVICES[@]}"; do
        [ -z "${STATUS_CACHE[$container]}" ] && STATUS_CACHE["$container"]="NOT_RUNNING:unknown"
    done
}

# Compact dashboard display
show_dashboard() {
    collect_all_status
    local timestamp=$(date '+%H:%M:%S')
    local infra_output="" micro_output="" summary=""
    local total=0 healthy=0 starting=0 stopped=0
    
    # Build display content in parallel loops
    for container in "${!SERVICES[@]}"; do
        local info="${SERVICES[$container]}"
        local name=$(echo "$info" | cut -d':' -f1)
        local port=$(echo "$info" | cut -d':' -f2)
        local type=$(echo "$info" | cut -d':' -f3)
        local status_display=$(get_service_status "$container" "${STATUS_CACHE[$container]}")
        local line="║ $(printf "%-12s %s ${CYAN}:%s${NC}" "$name" "$status_display" "$port")"
        
        # Count for summary
        ((total++))
        case "${STATUS_CACHE[$container]}" in
            "running:healthy"|"running:no-healthcheck") ((healthy++)) ;;
            "running:starting") ((starting++)) ;;
            *) ((stopped++)) ;;
        esac
        
        # Group by service type
        if [ "$type" = "infra" ]; then
            infra_output+="$line\n"
        else
            micro_output+="$line\n"
        fi
    done
    
    # Summary status
    if [ $healthy -eq $total ]; then
        summary="${GREEN}��� All services healthy${NC}"
    elif [ $((healthy + starting)) -gt 0 ]; then
        summary="${YELLOW}⏳ Services starting up${NC}"
    else
        summary="${RED}��� No services running${NC}"
    fi
    
    # Ultra-compact display (single output)
    clear
    echo -e "${WHITE}╔════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${WHITE}║${NC} ${CYAN}��� Kotlin Microservices Monitor${NC} ${WHITE}║${NC} ${GRAY}$timestamp${NC} ${WHITE}║${NC}"
    echo -e "${WHITE}╠════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${WHITE}║${NC} ${WHITE}���️  INFRASTRUCTURE${NC}                                            ${WHITE}║${NC}"
    echo -e "$infra_output"
    echo -e "${WHITE}╠────────────────────────────────────────────────────────────────────╢${NC}"
    echo -e "${WHITE}║${NC} ${WHITE}��� MICROSERVICES${NC}                                               ${WHITE}║${NC}"
    echo -e "$micro_output"
    echo -e "${WHITE}╠════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${WHITE}║${NC} ${GREEN}✅ ${healthy}${NC} ${YELLOW}⏳ ${starting}${NC} ${RED}❌ ${stopped}${NC} ${BLUE}��� ${total}${NC} │ $summary                  ${WHITE}║${NC}"
    echo -e "${WHITE}╚════════════════════════════════════════════════════════════════════╝${NC}"
    echo -e "${GRAY}⚡ Ultra-fast refresh │ ${CYAN}Ctrl+C${NC}${GRAY} to exit │ ${CYAN}./start-infra.sh${NC} ${CYAN}./start-dev.sh${NC}${GRAY} to launch${NC}"
}

# Main monitor loop (optimized)
monitor_loop() {
    local interval=${1:-0.3}  # Even faster default
    echo -e "${CYAN}��� Starting ultra-fast monitor (${interval}s refresh)...${NC}"
    
    # Hide cursor for cleaner display
    tput civis 2>/dev/null || true
    trap 'tput cnorm 2>/dev/null || true; exit' INT TERM EXIT
    
    while true; do
        local start=$(date +%s 2>/dev/null)
        show_dashboard
        local end=$(date +%s 2>/dev/null)
        local duration=$((end - start))
        [ $duration -eq 0 ] && duration="< 1"
        echo -e "${GRAY}Update time: ${duration}s${NC}"
        sleep $interval
    done
}

# Help function (simplified)
show_help() {
    echo -e "${CYAN}��� Ultra-Fast Kotlin Microservices Monitor${NC}"
    echo
    echo "Usage: $0 [INTERVAL]"
    echo
    echo "Examples:"
    echo "  $0           Ultra-fast (0.3s refresh)"
    echo "  $0 0.1       Blazing fast (0.1s refresh)"  
    echo "  $0 1         Standard (1s refresh)"
    echo "  $0 -h        Show this help"
    echo
    echo -e "${GRAY}Tip: Use 0.1-0.5s for real-time monitoring, 1-2s for battery saving${NC}"
}

# Parse arguments (simplified)
case "${1:-}" in
    -h|--help) show_help; exit 0 ;;
    "") monitor_loop 0.3 ;;
    *) 
        # Simple validation without bc dependency
        if [[ "$1" =~ ^[0-9]+\.?[0-9]*$ ]] && [ "${1%.*}" -ge 0 ] 2>/dev/null; then
            monitor_loop "$1"
        else
            echo "Error: Invalid interval '$1'. Use a positive number (e.g., 0.3, 1, 2)"
            exit 1
        fi
        ;;
esac
