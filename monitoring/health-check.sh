#!/bin/bash

# 📊 Simple Health Check Script
# Basic monitoring for your apps

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Default values
URL="http://localhost:3000"
TIMEOUT=5

# Usage
usage() {
    cat << EOF
📊 Simple Health Check

Usage: $0 [OPTIONS]

Options:
    -u, --url URL          URL to check [default: http://localhost:3000]
    -t, --timeout SEC      Timeout in seconds [default: 5]
    -h, --help             Show this help

Examples:
    $0
    $0 -u http://myapp.com:8080
    $0 --url http://localhost:3000/health --timeout 10
EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -u|--url)
            URL="$2"
            shift 2
            ;;
        -t|--timeout)
            TIMEOUT="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Health check function
check_health() {
    local url="$1"
    local timeout="$2"
    
    echo "🔍 Checking: $url"
    
    # Try to get response
    if response=$(curl -s --max-time "$timeout" "$url" 2>/dev/null); then
        # Check if it's JSON and has status
        if echo "$response" | jq -e '.status' >/dev/null 2>&1; then
            status=$(echo "$response" | jq -r '.status')
            if [[ "$status" == "OK" ]]; then
                echo -e "✅ ${GREEN}Healthy${NC} - Status: $status"
                return 0
            else
                echo -e "⚠️ ${YELLOW}Warning${NC} - Status: $status"
                return 1
            fi
        else
            # Just check HTTP status
            http_code=$(curl -s -o /dev/null -w "%{http_code}" --max-time "$timeout" "$url" 2>/dev/null || echo "000")
            if [[ "$http_code" == "200" ]]; then
                echo -e "✅ ${GREEN}Healthy${NC} - HTTP: $http_code"
                return 0
            else
                echo -e "❌ ${RED}Unhealthy${NC} - HTTP: $http_code"
                return 1
            fi
        fi
    else
        echo -e "❌ ${RED}Unreachable${NC} - Connection failed"
        return 1
    fi
}

# Docker container check
check_docker() {
    if command -v docker >/dev/null 2>&1; then
        echo
        echo "🐳 Docker Containers:"
        
        containers=$(docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || echo "")
        
        if [[ -n "$containers" ]]; then
            echo "$containers"
            
            # Check for unhealthy containers
            unhealthy=$(docker ps --filter "health=unhealthy" --format "{{.Names}}" 2>/dev/null || echo "")
            if [[ -n "$unhealthy" ]]; then
                echo -e "⚠️ ${YELLOW}Unhealthy containers: $unhealthy${NC}"
            fi
        else
            echo "No containers running"
        fi
    fi
}

# System resources check
check_resources() {
    echo
    echo "💻 System Resources:"
    
    # CPU usage (simplified)
    if command -v top >/dev/null 2>&1; then
        cpu=$(top -l 1 -s 0 | grep "CPU usage" | awk '{print $3}' | sed 's/%//' 2>/dev/null || echo "unknown")
        echo "  CPU: ${cpu}%"
    fi
    
    # Memory usage
    if command -v free >/dev/null 2>&1; then
        mem=$(free | awk 'NR==2{printf "%.1f", $3*100/$2}' 2>/dev/null || echo "unknown")
        echo "  Memory: ${mem}%"
    elif [[ "$(uname)" == "Darwin" ]]; then
        # macOS memory check
        mem=$(vm_stat | awk '/Pages active/ {active=$3} /Pages inactive/ {inactive=$3} /Pages speculative/ {spec=$3} /Pages wired/ {wired=$4} /Pages free/ {free=$3} END {total=(active+inactive+spec+wired+free); used=(active+inactive+spec+wired); printf "%.1f", used*100/total}' 2>/dev/null || echo "unknown")
        echo "  Memory: ${mem}%"
    fi
    
    # Disk usage
    if command -v df >/dev/null 2>&1; then
        disk=$(df / | awk 'NR==2{print $5}' | sed 's/%//' 2>/dev/null || echo "unknown")
        echo "  Disk: ${disk}%"
    fi
}

# Main health check
main() {
    echo "🏥 Basic Health Check"
    echo "===================="
    
    # Check main URL
    if check_health "$URL" "$TIMEOUT"; then
        health_status=0
    else
        health_status=1
    fi
    
    # Additional health endpoints
    base_url=$(echo "$URL" | sed 's|/[^/]*$||')
    
    if [[ "$URL" != *"/health" ]]; then
        echo
        health_url="$base_url/health"
        echo "🔍 Checking health endpoint: $health_url"
        check_health "$health_url" "$TIMEOUT" || true
    fi
    
    # Check Docker containers
    check_docker
    
    # Check system resources
    check_resources
    
    echo
    if [[ $health_status -eq 0 ]]; then
        echo -e "🎉 ${GREEN}Overall Status: Healthy${NC}"
    else
        echo -e "⚠️ ${YELLOW}Overall Status: Issues Detected${NC}"
    fi
    
    echo
    echo -e "${YELLOW}💡 Need advanced monitoring?${NC}"
    echo "   - Real-time dashboards"
    echo "   - Automated alerts"
    echo "   - Performance metrics"
    echo "   - Log aggregation"
    echo
    echo "   Upgrade to Enterprise DevOps Toolkit!"
    echo "   https://github.com/kasbahcode/devops-toolkit"
    
    exit $health_status
}

# Run main function
main "$@" 