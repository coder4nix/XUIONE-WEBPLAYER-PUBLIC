#!/bin/bash
# =============================================================================
# XUIONE WebPlayer - Automated Installation Script
# =============================================================================
#
# Usage:
#   sudo bash install.sh              Install (interactive port selection)
#   sudo bash install.sh -u           Uninstall completely
#   sudo bash install.sh -uninstall   Uninstall completely
#   sudo bash install.sh -h           Show help
#
# =============================================================================

set -e

# =============================================================================
# Colors and Formatting
# =============================================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
NC='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'

# Box drawing characters
BOX_TL="╔"
BOX_TR="╗"
BOX_BL="╚"
BOX_BR="╝"
BOX_H="═"
BOX_V="║"
CHECK="✓"
CROSS="✗"
ARROW="→"
BULLET="•"

# Default port
WEBUI_PORT=80

# =============================================================================
# Helper Functions
# =============================================================================

print_header() {
    clear
    echo -e "${CYAN}"
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║                                                                ║"
    echo "║   ██╗  ██╗██╗   ██╗██╗ ██████╗ ███╗   ██╗███████╗             ║"
    echo "║   ╚██╗██╔╝██║   ██║██║██╔═══██╗████╗  ██║██╔════╝             ║"
    echo "║    ╚███╔╝ ██║   ██║██║██║   ██║██╔██╗ ██║█████╗               ║"
    echo "║    ██╔██╗ ██║   ██║██║██║   ██║██║╚██╗██║██╔══╝               ║"
    echo "║   ██╔╝ ██╗╚██████╔╝██║╚██████╔╝██║ ╚████║███████╗             ║"
    echo "║   ╚═╝  ╚═╝ ╚═════╝ ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝             ║"
    echo "║                                                                ║"
    echo "║                    WebPlayer Installer                         ║"
    echo "║                                                                ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_uninstall_header() {
    clear
    echo -e "${RED}"
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║                                                                ║"
    echo "║   ██╗  ██╗██╗   ██╗██╗ ██████╗ ███╗   ██╗███████╗             ║"
    echo "║   ╚██╗██╔╝██║   ██║██║██╔═══██╗████╗  ██║██╔════╝             ║"
    echo "║    ╚███╔╝ ██║   ██║██║██║   ██║██╔██╗ ██║█████╗               ║"
    echo "║    ██╔██╗ ██║   ██║██║██║   ██║██║╚██╗██║██╔══╝               ║"
    echo "║   ██╔╝ ██╗╚██████╔╝██║╚██████╔╝██║ ╚████║███████╗             ║"
    echo "║   ╚═╝  ╚═╝ ╚═════╝ ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝             ║"
    echo "║                                                                ║"
    echo "║                   WebPlayer Uninstaller                        ║"
    echo "║                                                                ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_section() {
    echo ""
    echo -e "${BLUE}┌──────────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${BLUE}│${NC} ${WHITE}${BOLD}$1${NC}"
    echo -e "${BLUE}└──────────────────────────────────────────────────────────────────┘${NC}"
}

print_step() {
    echo -e "${CYAN}${ARROW}${NC} $1"
}

print_success() {
    echo -e "${GREEN}${CHECK}${NC} $1"
}

print_error() {
    echo -e "${RED}${CROSS}${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}!${NC} $1"
}

print_info() {
    echo -e "${GRAY}${BULLET}${NC} $1"
}

print_status() {
    local name="$1"
    local status="$2"
    local version="$3"

    printf "  ${GRAY}%-20s${NC}" "$name"
    if [ "$status" = "installed" ]; then
        echo -e "${GREEN}${CHECK} Installed${NC} ${DIM}($version)${NC}"
    elif [ "$status" = "missing" ]; then
        echo -e "${YELLOW}${CROSS} Missing${NC}"
    elif [ "$status" = "installing" ]; then
        echo -e "${CYAN}${ARROW} Installing...${NC}"
    fi
}

confirm() {
    local prompt="$1"
    local default="${2:-y}"

    if [ "$default" = "y" ]; then
        prompt="$prompt [Y/n] "
    else
        prompt="$prompt [y/N] "
    fi

    echo -e -n "${YELLOW}?${NC} $prompt"
    read -r response

    if [ -z "$response" ]; then
        response="$default"
    fi

    case "$response" in
        [yY][eE][sS]|[yY]) return 0 ;;
        *) return 1 ;;
    esac
}

get_network_ip() {
    ip -4 addr show scope global 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -1 || \
    hostname -I 2>/dev/null | awk '{print $1}' || \
    echo "N/A"
}

show_help() {
    echo -e "${WHITE}${BOLD}XUIONE WebPlayer Installer${NC}"
    echo ""
    echo -e "${WHITE}Usage:${NC}"
    echo "  sudo bash install.sh [OPTIONS]"
    echo ""
    echo -e "${WHITE}Options:${NC}"
    echo "  -u, -uninstall    Uninstall XUIONE WebPlayer completely"
    echo "  -h, -help         Show this help message"
    echo ""
    echo -e "${WHITE}Examples:${NC}"
    echo "  sudo bash install.sh     # Install (interactive port selection)"
    echo "  sudo bash install.sh -u  # Uninstall completely"
    echo ""
}

spinner() {
    local pid=$1
    local message="$2"
    local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local i=0

    while kill -0 $pid 2>/dev/null; do
        i=$(( (i+1) % 10 ))
        printf "\r${CYAN}${spin:$i:1}${NC} $message"
        sleep 0.1
    done
    printf "\r"
}

# =============================================================================
# OS Detection
# =============================================================================

detect_os() {
    OS_TYPE=""
    OS_NAME=""
    OS_VERSION=""
    OS_ID=""
    PKG_MANAGER=""
    PKG_INSTALL=""
    PKG_UPDATE=""

    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS_NAME="$NAME"
        OS_VERSION="$VERSION_ID"
        OS_ID="$ID"

        case "$ID" in
            ubuntu|debian|linuxmint|pop)
                OS_TYPE="debian"
                PKG_MANAGER="apt"
                PKG_INSTALL="apt-get install -y"
                PKG_UPDATE="apt-get update"
                ;;
            centos|rhel|rocky|almalinux)
                OS_TYPE="rhel"
                PKG_MANAGER="yum"
                PKG_INSTALL="yum install -y"
                PKG_UPDATE="yum check-update || true"
                ;;
            fedora)
                OS_TYPE="fedora"
                PKG_MANAGER="dnf"
                PKG_INSTALL="dnf install -y"
                PKG_UPDATE="dnf check-update || true"
                ;;
            arch|manjaro|endeavouros)
                OS_TYPE="arch"
                PKG_MANAGER="pacman"
                PKG_INSTALL="pacman -S --noconfirm"
                PKG_UPDATE="pacman -Sy"
                ;;
            opensuse*|sles)
                OS_TYPE="suse"
                PKG_MANAGER="zypper"
                PKG_INSTALL="zypper install -y"
                PKG_UPDATE="zypper refresh"
                ;;
            alpine)
                OS_TYPE="alpine"
                PKG_MANAGER="apk"
                PKG_INSTALL="apk add"
                PKG_UPDATE="apk update"
                ;;
            *)
                OS_TYPE="unknown"
                ;;
        esac
    else
        OS_TYPE="unknown"
    fi
}

# Version comparison helper (returns 0 if $1 >= $2)
version_gte() {
    [ "$(printf '%s\n' "$2" "$1" | sort -V | head -n1)" = "$2" ]
}

check_os_version() {
    local min_version=""
    local version_ok=true

    case "$OS_ID" in
        ubuntu)
            min_version="22.04"
            ;;
        debian)
            min_version="11"
            ;;
        linuxmint)
            min_version="21"
            ;;
        pop)
            min_version="22.04"
            ;;
        centos|rhel|rocky|almalinux)
            min_version="8"
            ;;
        fedora)
            min_version="36"
            ;;
        arch|manjaro|endeavouros)
            # Rolling release - no minimum version
            min_version=""
            ;;
        opensuse*|sles)
            min_version="15.4"
            ;;
        alpine)
            min_version="3.15"
            ;;
        *)
            min_version=""
            ;;
    esac

    if [ -n "$min_version" ] && [ -n "$OS_VERSION" ]; then
        if ! version_gte "$OS_VERSION" "$min_version"; then
            version_ok=false
        fi
    fi

    if [ "$version_ok" = false ]; then
        echo ""
        print_error "Unsupported OS version: $OS_NAME $OS_VERSION"
        echo ""
        echo -e "  ${GRAY}Minimum required versions:${NC}"
        echo -e "  ${GRAY}${BULLET}${NC} Ubuntu 22.04+"
        echo -e "  ${GRAY}${BULLET}${NC} Debian 11+"
        echo -e "  ${GRAY}${BULLET}${NC} Linux Mint 21+"
        echo -e "  ${GRAY}${BULLET}${NC} Pop!_OS 22.04+"
        echo -e "  ${GRAY}${BULLET}${NC} CentOS/RHEL/Rocky/AlmaLinux 8+"
        echo -e "  ${GRAY}${BULLET}${NC} Fedora 36+"
        echo -e "  ${GRAY}${BULLET}${NC} openSUSE 15.4+"
        echo -e "  ${GRAY}${BULLET}${NC} Alpine 3.15+"
        echo -e "  ${GRAY}${BULLET}${NC} Arch/Manjaro/EndeavourOS (any version)"
        echo ""
        if ! confirm "Continue anyway (not recommended)?" "n"; then
            exit 1
        fi
    fi
}

# =============================================================================
# Package Checks
# =============================================================================

check_root() {
    if [ "$EUID" -ne 0 ]; then
        print_error "This script must be run as root"
        echo -e "  ${GRAY}Run: ${WHITE}sudo bash install.sh${NC}"
        exit 1
    fi
}

check_node() {
    if command -v node &> /dev/null; then
        NODE_VERSION=$(node -v 2>/dev/null | sed 's/v//')
        NODE_MAJOR=$(echo "$NODE_VERSION" | cut -d'.' -f1)
        if [ "$NODE_MAJOR" -ge 18 ]; then
            NODE_STATUS="installed"
        else
            NODE_STATUS="outdated"
        fi
    else
        NODE_STATUS="missing"
        NODE_VERSION=""
    fi
}

check_npm() {
    if command -v npm &> /dev/null; then
        NPM_VERSION=$(npm -v 2>/dev/null)
        NPM_STATUS="installed"
    else
        NPM_STATUS="missing"
        NPM_VERSION=""
    fi
}

check_nginx() {
    if command -v nginx &> /dev/null; then
        NGINX_VERSION=$(nginx -v 2>&1 | sed 's/.*\///')
        NGINX_STATUS="installed"
    else
        NGINX_STATUS="missing"
        NGINX_VERSION=""
    fi
}

check_git() {
    if command -v git &> /dev/null; then
        GIT_VERSION=$(git --version | sed 's/git version //')
        GIT_STATUS="installed"
    else
        GIT_STATUS="missing"
        GIT_VERSION=""
    fi
}

check_curl() {
    if command -v curl &> /dev/null; then
        CURL_VERSION=$(curl --version | head -1 | awk '{print $2}')
        CURL_STATUS="installed"
    else
        CURL_STATUS="missing"
        CURL_VERSION=""
    fi
}

check_ffmpeg() {
    if command -v ffprobe &> /dev/null; then
        FFMPEG_VERSION=$(ffprobe -version 2>/dev/null | head -1 | awk '{print $3}')
        FFMPEG_STATUS="installed"
    else
        FFMPEG_STATUS="missing"
        FFMPEG_VERSION=""
    fi
}

# =============================================================================
# Installation Functions
# =============================================================================

install_node_debian() {
    print_step "Adding NodeSource repository..."
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - > /dev/null 2>&1
    print_step "Installing Node.js..."
    apt-get install -y nodejs > /dev/null 2>&1
}

install_node_rhel() {
    print_step "Adding NodeSource repository..."
    curl -fsSL https://rpm.nodesource.com/setup_20.x | bash - > /dev/null 2>&1
    print_step "Installing Node.js..."
    yum install -y nodejs > /dev/null 2>&1
}

install_node_fedora() {
    print_step "Installing Node.js..."
    dnf install -y nodejs > /dev/null 2>&1
}

install_node_arch() {
    print_step "Installing Node.js..."
    pacman -S --noconfirm nodejs npm > /dev/null 2>&1
}

install_node_alpine() {
    print_step "Installing Node.js..."
    apk add nodejs npm > /dev/null 2>&1
}

install_nginx_debian() {
    apt-get install -y nginx > /dev/null 2>&1
}

install_nginx_rhel() {
    yum install -y nginx > /dev/null 2>&1
}

install_nginx_fedora() {
    dnf install -y nginx > /dev/null 2>&1
}

install_nginx_arch() {
    pacman -S --noconfirm nginx > /dev/null 2>&1
}

install_nginx_alpine() {
    apk add nginx > /dev/null 2>&1
}

install_ffmpeg_debian() {
    apt-get install -y ffmpeg > /dev/null 2>&1
}

install_ffmpeg_rhel() {
    # RHEL/CentOS may need EPEL or RPM Fusion
    yum install -y epel-release > /dev/null 2>&1 || true
    yum install -y ffmpeg > /dev/null 2>&1 || \
    yum install -y ffmpeg-free > /dev/null 2>&1 || true
}

install_ffmpeg_fedora() {
    dnf install -y ffmpeg > /dev/null 2>&1 || \
    dnf install -y ffmpeg-free > /dev/null 2>&1 || true
}

install_ffmpeg_arch() {
    pacman -S --noconfirm ffmpeg > /dev/null 2>&1
}

install_ffmpeg_alpine() {
    apk add ffmpeg > /dev/null 2>&1
}

install_ffmpeg_suse() {
    zypper install -y ffmpeg > /dev/null 2>&1
}

install_node_suse() {
    print_step "Installing Node.js..."
    zypper install -y nodejs20 npm20 > /dev/null 2>&1 || \
    zypper install -y nodejs npm > /dev/null 2>&1
}

install_nginx_suse() {
    zypper install -y nginx > /dev/null 2>&1
}

install_package() {
    local package="$1"
    $PKG_INSTALL "$package" > /dev/null 2>&1
}

# =============================================================================
# Port Selection
# =============================================================================

select_port() {
    echo ""
    echo -e "${WHITE}${BOLD}WebUI Port Configuration${NC}"
    echo ""
    echo -e "  ${GRAY}The WebUI will be accessible on this port.${NC}"
    echo -e "  ${GRAY}Default: 80 (standard HTTP)${NC}"
    echo ""

    echo -e -n "${YELLOW}?${NC} Enter port number [80]: "
    read -r user_port

    if [ -n "$user_port" ]; then
        # Validate port number
        if [[ "$user_port" =~ ^[0-9]+$ ]] && [ "$user_port" -ge 1 ] && [ "$user_port" -le 65535 ]; then
            WEBUI_PORT="$user_port"
        else
            print_error "Invalid port number. Using default port 80."
            WEBUI_PORT=80
        fi
    fi

    # Check if port is already in use
    if lsof -i ":$WEBUI_PORT" -sTCP:LISTEN >/dev/null 2>&1; then
        local pid=$(lsof -t -i ":$WEBUI_PORT" -sTCP:LISTEN 2>/dev/null | head -1)
        local process=$(ps -p "$pid" -o comm= 2>/dev/null || echo "unknown")
        print_warning "Port $WEBUI_PORT is already in use by $process (PID: $pid)"
        if ! confirm "Continue anyway?"; then
            exit 1
        fi
    fi

    echo ""
    print_success "WebUI will be accessible on port $WEBUI_PORT"
}

# =============================================================================
# Configuration Functions
# =============================================================================

configure_nginx() {
    print_step "Creating cache directory..."
    mkdir -p /var/cache/nginx/xuione-images
    chown www-data:www-data /var/cache/nginx/xuione-images 2>/dev/null || \
    chown nginx:nginx /var/cache/nginx/xuione-images 2>/dev/null || true
    chmod 755 /var/cache/nginx/xuione-images

    print_step "Configuring Nginx for port $WEBUI_PORT..."

    # Determine nginx config path
    if [ -d /etc/nginx/sites-enabled ]; then
        NGINX_CONF_DIR="/etc/nginx/sites-enabled"
        rm -f "$NGINX_CONF_DIR/default"
    elif [ -d /etc/nginx/conf.d ]; then
        NGINX_CONF_DIR="/etc/nginx/conf.d"
        rm -f "$NGINX_CONF_DIR/default.conf"
    else
        NGINX_CONF_DIR="/etc/nginx/conf.d"
        mkdir -p "$NGINX_CONF_DIR"
    fi

    # Get network IP for server_name
    NETWORK_IP=$(get_network_ip)

    # Create nginx config with selected port
    cat > "$NGINX_CONF_DIR/xuione-webplayer.conf" << EOF
# =============================================================================
# XUIONE WebPlayer - Nginx Configuration with Image Caching
# =============================================================================
# Port $WEBUI_PORT → Nginx → Vite (3000) + proxy.js (3003)
# Generated by install.sh
# =============================================================================

# Image cache zone - 10GB, 30 days retention
proxy_cache_path /var/cache/nginx/xuione-images
    levels=1:2
    keys_zone=xuione_images:100m
    max_size=10g
    inactive=30d
    use_temp_path=off;

# Upstream for Node.js proxy server
upstream xuione_proxy {
    server 127.0.0.1:3003;
    keepalive 32;
}

# Upstream for Vite dev server
upstream xuione_vite {
    server 127.0.0.1:3000;
    keepalive 8;
}

server {
    listen $WEBUI_PORT;
    listen [::]:$WEBUI_PORT;
    server_name localhost $NETWORK_IP;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_comp_level 6;
    gzip_types text/plain text/css text/xml text/javascript
               application/javascript application/json
               application/vnd.ms-fontobject application/x-font-ttf
               font/opentype image/svg+xml image/x-icon
               image/jpeg image/png image/webp;

    # Security Headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;

    # IMAGE CACHE
    location /api/image {
        proxy_pass http://xuione_proxy;
        proxy_http_version 1.1;
        proxy_set_header Connection "";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;

        proxy_cache xuione_images;
        proxy_cache_valid 200 30d;
        proxy_cache_valid 404 1m;
        proxy_cache_valid 500 502 503 504 10s;
        proxy_cache_use_stale error timeout updating http_500 http_502 http_503 http_504;
        proxy_cache_lock on;
        proxy_cache_lock_timeout 5s;
        proxy_cache_revalidate on;
        proxy_cache_background_update on;
        proxy_cache_key "\$arg_url";

        add_header Cache-Control "public, max-age=2592000, immutable" always;
        add_header X-Cache-Status \$upstream_cache_status always;

        proxy_connect_timeout 10s;
        proxy_read_timeout 30s;
        proxy_send_timeout 10s;

        proxy_buffering on;
        proxy_buffer_size 4k;
        proxy_buffers 8 32k;
        proxy_busy_buffers_size 64k;
    }

    # API ROUTES
    location /api/ {
        proxy_pass http://xuione_proxy;
        proxy_http_version 1.1;
        proxy_set_header Connection "";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;

        proxy_buffering off;
        proxy_request_buffering off;
        proxy_connect_timeout 60s;
        proxy_read_timeout 600s;
        proxy_send_timeout 600s;
    }

    # VITE DEV SERVER
    location / {
        proxy_pass http://xuione_vite;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;

        proxy_read_timeout 86400;
    }

    access_log /var/log/nginx/xuione-access.log;
    error_log /var/log/nginx/xuione-error.log;
}
EOF

    # Save port to config file for reference
    echo "$WEBUI_PORT" > "$SCRIPT_DIR/.webui_port"

    print_step "Testing Nginx configuration..."
    if nginx -t > /dev/null 2>&1; then
        print_success "Nginx configuration valid"
    else
        print_warning "Nginx configuration has issues, but continuing..."
    fi

    print_step "Starting Nginx..."
    systemctl enable nginx > /dev/null 2>&1 || true
    systemctl restart nginx > /dev/null 2>&1 || service nginx restart > /dev/null 2>&1 || true
}

create_systemd_service() {
    if ! command -v systemctl &> /dev/null; then
        print_warning "Systemd not available, skipping service creation"
        return
    fi

    print_step "Creating systemd service..."

    cat > /etc/systemd/system/xuione-webplayer.service << EOF
[Unit]
Description=XUIONE WebPlayer - Professional IPTV Web Player
Documentation=https://github.com/coder4nix/XUIONE-WEBPLAYER
After=network.target nginx.service

[Service]
Type=simple
User=root
WorkingDirectory=$SCRIPT_DIR
ExecStartPre=$SCRIPT_DIR/scripts/stop.sh
ExecStart=$SCRIPT_DIR/scripts/start.sh
ExecStop=$SCRIPT_DIR/scripts/stop.sh
Restart=on-failure
RestartSec=10
KillMode=control-group
KillSignal=SIGTERM
TimeoutStopSec=30
Environment=NODE_ENV=development
Environment=PATH=/usr/local/bin:/usr/bin:/bin

StandardOutput=journal
StandardError=journal
SyslogIdentifier=xuione-webplayer

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable xuione-webplayer > /dev/null 2>&1
    print_success "Systemd service created"
}

install_npm_dependencies() {
    print_step "Installing npm dependencies..."
    cd "$SCRIPT_DIR"
    npm install > /dev/null 2>&1
    print_success "Dependencies installed"
}

# =============================================================================
# Uninstall Function
# =============================================================================

uninstall() {
    print_uninstall_header

    print_section "Uninstalling XUIONE WebPlayer"
    echo ""

    print_warning "This will completely remove XUIONE WebPlayer:"
    echo ""
    echo -e "  ${GRAY}${BULLET}${NC} Stop and disable systemd service"
    echo -e "  ${GRAY}${BULLET}${NC} Remove Nginx configuration"
    echo -e "  ${GRAY}${BULLET}${NC} Clear image cache"
    echo -e "  ${GRAY}${BULLET}${NC} Remove log files"
    echo ""

    if ! confirm "Are you sure you want to uninstall?" "n"; then
        print_info "Uninstall cancelled"
        exit 0
    fi

    echo ""

    # Stop and disable service
    if systemctl is-active --quiet xuione-webplayer 2>/dev/null; then
        print_step "Stopping XUIONE WebPlayer service..."
        systemctl stop xuione-webplayer 2>/dev/null || true
        print_success "Service stopped"
    fi

    if systemctl is-enabled --quiet xuione-webplayer 2>/dev/null; then
        print_step "Disabling XUIONE WebPlayer service..."
        systemctl disable xuione-webplayer 2>/dev/null || true
        print_success "Service disabled"
    fi

    # Remove systemd service file
    if [ -f /etc/systemd/system/xuione-webplayer.service ]; then
        print_step "Removing systemd service file..."
        rm -f /etc/systemd/system/xuione-webplayer.service
        systemctl daemon-reload 2>/dev/null || true
        print_success "Service file removed"
    fi

    # Remove Nginx configuration
    print_step "Removing Nginx configuration..."
    rm -f /etc/nginx/sites-enabled/xuione-webplayer.conf 2>/dev/null || true
    rm -f /etc/nginx/conf.d/xuione-webplayer.conf 2>/dev/null || true
    print_success "Nginx configuration removed"

    # Restart Nginx
    if command -v nginx &> /dev/null; then
        print_step "Restarting Nginx..."
        systemctl restart nginx 2>/dev/null || service nginx restart 2>/dev/null || true
        print_success "Nginx restarted"
    fi

    # Clear image cache
    if [ -d /var/cache/nginx/xuione-images ]; then
        print_step "Clearing image cache..."
        rm -rf /var/cache/nginx/xuione-images
        print_success "Image cache cleared"
    fi

    # Remove log files
    print_step "Removing log files..."
    rm -f /var/log/nginx/xuione-access.log 2>/dev/null || true
    rm -f /var/log/nginx/xuione-error.log 2>/dev/null || true
    rm -f /var/log/xuione-webplayer.log 2>/dev/null || true
    print_success "Log files removed"

    # Remove port config file
    rm -f "$SCRIPT_DIR/.webui_port" 2>/dev/null || true

    echo ""
    print_section "Uninstall Complete"
    echo ""
    print_success "XUIONE WebPlayer has been completely uninstalled"
    echo ""

    echo -e "${YELLOW}!${NC} ${GRAY}Note: The following were NOT removed:${NC}"
    echo -e "  ${GRAY}${BULLET}${NC} Application files in $SCRIPT_DIR"
    echo -e "  ${GRAY}${BULLET}${NC} Node.js and npm"
    echo -e "  ${GRAY}${BULLET}${NC} Nginx"
    echo ""

    if confirm "Do you also want to delete the application files?" "n"; then
        print_step "Removing application files..."
        # Don't delete if we're in the directory
        cd /tmp
        rm -rf "$SCRIPT_DIR"
        print_success "Application files removed"
    fi

    echo ""
    echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
    echo ""
}

# =============================================================================
# Main Installation
# =============================================================================

main() {
    # Get script directory
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    print_header

    # Detect OS
    print_section "System Detection"
    detect_os

    if [ "$OS_TYPE" = "unknown" ]; then
        print_error "Unsupported operating system"
        echo -e "  ${GRAY}Supported: Ubuntu 22.04+, Debian 11+, CentOS/RHEL 8+, Fedora 36+, Arch, Alpine 3.15+, openSUSE 15.4+${NC}"
        exit 1
    fi

    echo ""
    echo -e "  ${GRAY}Operating System:${NC}  ${WHITE}$OS_NAME${NC}"
    echo -e "  ${GRAY}Version:${NC}           ${WHITE}$OS_VERSION${NC}"
    echo -e "  ${GRAY}Package Manager:${NC}   ${WHITE}$PKG_MANAGER${NC}"
    echo -e "  ${GRAY}Install Path:${NC}      ${WHITE}$SCRIPT_DIR${NC}"

    # Check OS version meets minimum requirements
    check_os_version

    # Check root
    check_root

    # Port selection
    print_section "Port Configuration"
    select_port

    # Check installed packages
    print_section "Checking Requirements"
    echo ""

    check_curl
    check_git
    check_node
    check_npm
    check_nginx
    check_ffmpeg

    print_status "curl" "$CURL_STATUS" "$CURL_VERSION"
    print_status "git" "$GIT_STATUS" "$GIT_VERSION"
    print_status "Node.js (≥18)" "$NODE_STATUS" "$NODE_VERSION"
    print_status "npm" "$NPM_STATUS" "$NPM_VERSION"
    print_status "Nginx" "$NGINX_STATUS" "$NGINX_VERSION"
    print_status "ffmpeg/ffprobe" "$FFMPEG_STATUS" "$FFMPEG_VERSION"

    # Determine what needs to be installed
    NEED_INSTALL=""
    [ "$CURL_STATUS" = "missing" ] && NEED_INSTALL="$NEED_INSTALL curl"
    [ "$GIT_STATUS" = "missing" ] && NEED_INSTALL="$NEED_INSTALL git"
    [ "$NODE_STATUS" = "missing" ] || [ "$NODE_STATUS" = "outdated" ] && NEED_INSTALL="$NEED_INSTALL nodejs"
    [ "$NGINX_STATUS" = "missing" ] && NEED_INSTALL="$NEED_INSTALL nginx"
    [ "$FFMPEG_STATUS" = "missing" ] && NEED_INSTALL="$NEED_INSTALL ffmpeg"

    echo ""

    if [ -n "$NEED_INSTALL" ]; then
        print_warning "Missing packages:${YELLOW}$NEED_INSTALL${NC}"
        echo ""
        if ! confirm "Install missing packages?"; then
            print_error "Installation cancelled"
            exit 1
        fi
    else
        print_success "All required packages are installed"
    fi

    # Installation
    print_section "Installation"
    echo ""

    # Update package manager
    print_step "Updating package manager..."
    $PKG_UPDATE > /dev/null 2>&1 || true
    print_success "Package manager updated"

    # Install curl if missing
    if [ "$CURL_STATUS" = "missing" ]; then
        print_step "Installing curl..."
        install_package curl
        print_success "curl installed"
    fi

    # Install git if missing
    if [ "$GIT_STATUS" = "missing" ]; then
        print_step "Installing git..."
        install_package git
        print_success "git installed"
    fi

    # Install Node.js if missing or outdated
    if [ "$NODE_STATUS" = "missing" ] || [ "$NODE_STATUS" = "outdated" ]; then
        case "$OS_TYPE" in
            debian) install_node_debian ;;
            rhel) install_node_rhel ;;
            fedora) install_node_fedora ;;
            arch) install_node_arch ;;
            alpine) install_node_alpine ;;
            suse) install_node_suse ;;
        esac
        print_success "Node.js installed"
    fi

    # Install Nginx if missing
    if [ "$NGINX_STATUS" = "missing" ]; then
        print_step "Installing Nginx..."
        case "$OS_TYPE" in
            debian) install_nginx_debian ;;
            rhel) install_nginx_rhel ;;
            fedora) install_nginx_fedora ;;
            arch) install_nginx_arch ;;
            alpine) install_nginx_alpine ;;
            suse) install_nginx_suse ;;
        esac
        print_success "Nginx installed"
    fi

    # Install ffmpeg if missing (required for stream info feature)
    if [ "$FFMPEG_STATUS" = "missing" ]; then
        print_step "Installing ffmpeg (for stream info)..."
        case "$OS_TYPE" in
            debian) install_ffmpeg_debian ;;
            rhel) install_ffmpeg_rhel ;;
            fedora) install_ffmpeg_fedora ;;
            arch) install_ffmpeg_arch ;;
            alpine) install_ffmpeg_alpine ;;
            suse) install_ffmpeg_suse ;;
        esac
        if command -v ffprobe &> /dev/null; then
            print_success "ffmpeg installed"
        else
            print_warning "ffmpeg installation may require manual setup (optional feature)"
        fi
    fi

    # Configure Nginx
    print_section "Configuration"
    echo ""
    configure_nginx

    # Install npm dependencies
    install_npm_dependencies

    # Create systemd service
    create_systemd_service

    # Get network IP for display
    NETWORK_IP=$(get_network_ip)

    # Done!
    print_section "Installation Complete"
    echo ""
    print_success "XUIONE WebPlayer has been installed successfully!"
    echo ""
    echo -e "${WHITE}${BOLD}Quick Start:${NC}"
    echo ""
    echo -e "  ${CYAN}sudo systemctl start xuione-webplayer${NC}"
    echo ""
    echo -e "${WHITE}${BOLD}Access:${NC}"
    echo ""
    if [ "$WEBUI_PORT" = "80" ]; then
        echo -e "  ${GRAY}Local:${NC}   ${GREEN}http://localhost${NC}"
        echo -e "  ${GRAY}Network:${NC} ${GREEN}http://${NETWORK_IP}${NC}"
    else
        echo -e "  ${GRAY}Local:${NC}   ${GREEN}http://localhost:${WEBUI_PORT}${NC}"
        echo -e "  ${GRAY}Network:${NC} ${GREEN}http://${NETWORK_IP}:${WEBUI_PORT}${NC}"
    fi
    echo ""
    echo -e "${WHITE}${BOLD}Useful Commands:${NC}"
    echo ""
    echo -e "  ${GRAY}Start:${NC}     sudo systemctl start xuione-webplayer"
    echo -e "  ${GRAY}Stop:${NC}      sudo systemctl stop xuione-webplayer"
    echo -e "  ${GRAY}Status:${NC}    sudo systemctl status xuione-webplayer"
    echo -e "  ${GRAY}Logs:${NC}      sudo journalctl -u xuione-webplayer -f"
    echo -e "  ${GRAY}Uninstall:${NC} sudo bash install.sh -u"
    echo ""
    echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
    echo ""
}

# =============================================================================
# Argument Parsing
# =============================================================================

while [[ $# -gt 0 ]]; do
    case "$1" in
        -u|-uninstall|--uninstall)
            SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
            check_root
            uninstall
            exit 0
            ;;
        -h|-help|--help)
            show_help
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Run main function
main "$@"
