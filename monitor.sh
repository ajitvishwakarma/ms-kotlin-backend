#!/bin/bash

# =============================================================================
# 🔍 SERVICE MONITOR - Real-time health monitoring with colorful indicators
# =============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\    local refresh_interval=${1:-1}  # Real-time 1-second refresh for instant updates
    
    echo -e "${CYAN}🚀 Starting blazing fast monitor... (refresh every ${refresh_interval}s)${NC}"[0;34m'
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

# BLAZING FAST: Single docker ps call for all container status
get_all_container_status() {
    local -n result_array=$1
    
    # Single docker ps call - much faster than multiple docker inspect calls
    local docker_output=$(docker ps -a --format "{{.Names}}:{{.Status}}" --filter "name=ms-kotlin-" 2>/dev/null || echo "")
    
    # Parse into associative array for instant lookup
    while IFS=':' read -r name status; do
        if [ -n "$name" ]; then
            # Convert docker ps status to our format
            if [[ "$status" == *"(healthy)"* ]]; then
                result_array["$name"]="running:healthy"
            elif [[ "$status" == *"(starting)"* ]]; then
                result_array["$name"]="running:starting"
            elif [[ "$status" == *"(unhealthy)"* ]]; then
                result_array["$name"]="running:unhealthy"
            elif [[ "$status" == "Up"* ]]; then
                result_array["$name"]="running:no-healthcheck"
            elif [[ "$status" == "Restarting"* ]]; then
                result_array["$name"]="restarting:unknown"
            elif [[ "$status" == "Paused"* ]]; then
                result_array["$name"]="paused:unknown"
            elif [[ "$status" == "Exited"* ]]; then
                result_array["$name"]="exited:unknown"
            else
                result_array["$name"]="unknown:unknown"
            fi
        fi
    done <<< "$docker_output"
    
    # Fill in missing containers (not running)
    for container_name in "${!INFRASTRUCTURE_SERVICES[@]}" "${!MICROSERVICES[@]}"; do
        if [ -z "${result_array[$container_name]}" ]; then
            result_array["$container_name"]="NOT_RUNNING:unknown"
        fi
    done
}

# Status icons and colors (optimized for cached data)
get_status_display() {
    local container_name=$1
    local status_health=${2:-""}
    local status=""
    local health=""
    local icon=""
    local color=""
    
    # If cached status_health is provided, use it (much faster)
    if [ -n "$status_health" ]; then
        status=$(echo "$status_health" | cut -d':' -f1)
        health=$(echo "$status_health" | cut -d':' -f2)
    else
        # Fallback to individual docker inspect (slower)
        if docker inspect "$container_name" >/dev/null 2>&1; then
            status=$(docker inspect --format='{{.State.Status}}' "$container_name" 2>/dev/null)
            health=$(docker inspect --format='{{.State.Health.Status}}' "$container_name" 2>/dev/null || echo "no-healthcheck")
        else
            status="NOT_RUNNING"
            health="unknown"
        fi
    fi
    
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
        "NOT_RUNNING")
            icon="⚫"
            color=$GRAY
            status="NOT RUNNING"
            ;;
        *)
            icon="❓"
            color=$PURPLE
            status="UNKNOWN"
            ;;
    esac
    
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
    local -n status_cache=$3  # New parameter for cached status
    local max_name_len=25
    local output=""
    
    # Build the entire output at once for instant display
    output+="${WHITE}┌─ ${title} ${WHITE}$(printf '─%.0s' $(seq 1 $((60 - ${#title}))))\n"
    output+="${WHITE}│${NC}\n"
    output+="${WHITE}│${NC} $(printf "%-${max_name_len}s %s %s" "SERVICE" "STATUS" "ENDPOINT")\n"
    output+="${WHITE}│${NC} $(printf '─%.0s' $(seq 1 $max_name_len)) ────────── ─────────────────\n"
    
    for container_name in "${!services[@]}"; do
        local service_info="${services[$container_name]}"
        local service_name=$(echo "$service_info" | cut -d':' -f1)
        local port=$(echo "$service_info" | cut -d':' -f2)
        
        # Use cached status if available (blazing fast!)
        local cached_status="${status_cache[$container_name]:-""}"
        local status_display=$(get_status_display "$container_name" "$cached_status")
        local endpoint="localhost:$port"
        
        output+="${WHITE}│${NC} $(printf "%-${max_name_len}s %s ${CYAN}%s${NC}" \
            "$service_name" \
            "$status_display" \
            "$endpoint")\n"
    done
    
    output+="${WHITE}└$(printf '─%.0s' $(seq 1 77))${NC}\n"
    output+="\n"
    
    # Print all at once for instant display
    echo -e "$output"
}

show_summary() {
    local -n status_cache=$1  # Use cached status data
    local total=0
    local running=0
    local healthy=0
    local starting=0
    local stopped=0
    local output=""
    
    # Count infrastructure services using cached data
    for container_name in "${!INFRASTRUCTURE_SERVICES[@]}"; do
        ((total++))
        local cached_status="${status_cache[$container_name]:-"NOT_RUNNING:unknown"}"
        local status=$(echo "$cached_status" | cut -d':' -f1)
        local health=$(echo "$cached_status" | cut -d':' -f2)
        
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
    done
    
    # Count microservices using cached data
    for container_name in "${!MICROSERVICES[@]}"; do
        ((total++))
        local cached_status="${status_cache[$container_name]:-"NOT_RUNNING:unknown"}"
        local status=$(echo "$cached_status" | cut -d':' -f1)
        local health=$(echo "$cached_status" | cut -d':' -f2)
        
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
    done
    
    # Build output all at once
    output+="${WHITE}┌─ SUMMARY ────────────────────────────────────────────────────────────────────┐${NC}\n"
    output+="${WHITE}│${NC}\n"
    output+="${WHITE}│${NC} ${GREEN}✅ Healthy: ${healthy}${NC}  ${YELLOW}⏳ Starting: ${starting}${NC}  ${RED}❌ Stopped: ${stopped}${NC}  ${BLUE}📊 Total: ${total}${NC}\n"
    output+="${WHITE}│${NC}\n"
    
    # Overall status
    if [ $healthy -eq $total ]; then
        output+="${WHITE}│${NC} ${GREEN}🎉 All services are healthy and running!${NC}\n"
    elif [ $running -gt 0 ]; then
        if [ $starting -gt 0 ]; then
            output+="${WHITE}│${NC} ${YELLOW}⏳ Some services are still starting up...${NC}\n"
        else
            output+="${WHITE}│${NC} ${YELLOW}⚠️  Some services need attention${NC}\n"
        fi
    else
        output+="${WHITE}│${NC} ${RED}🛑 No services are running${NC}\n"
    fi
    
    output+="${WHITE}│${NC}\n"
    output+="${WHITE}└──────────────────────────────────────────────────────────────────────────────┘${NC}\n"
    
    # Print all at once
    echo -e "$output"
}

show_quick_actions() {
    local output=""
    
    output+="\n"
    output+="${WHITE}┌─ QUICK ACTIONS ──────────────────────────────────────────────────────────────┐${NC}\n"
    output+="${WHITE}│${NC} ${CYAN}./start-infra.sh${NC}     - Start infrastructure services\n"
    output+="${WHITE}│${NC} ${CYAN}./start-dev.sh${NC}       - Start development services\n"
    output+="${WHITE}│${NC} ${CYAN}./stop-infra.sh${NC}      - Stop infrastructure\n"
    output+="${WHITE}│${NC} ${CYAN}./stop-dev.sh${NC}        - Stop development services\n"
    output+="${WHITE}│${NC} ${GRAY}Ctrl+C${NC}               - Exit monitor\n"
    output+="${WHITE}└──────────────────────────────────────────────────────────────────────────────┘${NC}\n"
    
    # Print all at once
    echo -e "$output"
}

monitor_loop() {
    local refresh_interval=${1:-2}  # Faster default for real-time feel
    
    echo -e "${CYAN}� Starting blazing fast monitor... (refresh every ${refresh_interval}s)${NC}"
    echo -e "${GRAY}Press Ctrl+C to exit${NC}"
    echo
    
    # Hide cursor for better experience
    tput civis 2>/dev/null || true
    
    # Trap to restore cursor on exit
    trap 'tput cnorm 2>/dev/null || true; exit' INT TERM EXIT
    
    while true; do
        # Start timer for performance
        local start_time=$(date +%s.%N 2>/dev/null || date +%s)
        
        # BLAZING FAST: Clear cache and get fresh status with single docker ps call
        unset container_status_cache
        declare -A container_status_cache
        get_all_container_status container_status_cache
        
        # Collect ALL display content first, then show at once
        local header_content=$(show_header)
        local infra_content=$(show_service_group "🏗️  INFRASTRUCTURE SERVICES" INFRASTRUCTURE_SERVICES container_status_cache)
        local micro_content=$(show_service_group "🚀 MICROSERVICES" MICROSERVICES container_status_cache)
        local summary_content=$(show_summary container_status_cache)
        local actions_content=$(show_quick_actions)
        
        # Calculate performance
        local end_time=$(date +%s.%N 2>/dev/null || date +%s)
        local processing_time=$(echo "$end_time - $start_time" | bc 2>/dev/null || echo "< 0.1")
        
        # Display everything at once for instant real-time effect
        clear
        echo -e "$header_content"
        echo -e "$infra_content"
        echo -e "$micro_content"
        echo -e "$summary_content"
        echo -e "$actions_content"
        
        # Show performance at bottom
        echo -e "${GRAY}⚡ Update: ${processing_time}s | Next refresh in ${refresh_interval}s${NC}"
        
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
REFRESH_INTERVAL=1  # Default to 1 second for real-time monitoring

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