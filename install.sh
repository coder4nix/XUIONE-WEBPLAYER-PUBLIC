#!/bin/bash
# =============================================================================
# XUIONE WebPlayer PRO - Automated Installation Script
# =============================================================================
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/coder4nix/XUIONE-WEBPLAYER-PUBLIC/main/install.sh | sudo bash
#
#   Or download and run:
#   sudo bash install.sh              Install (interactive)
#   sudo bash install.sh -u           Uninstall completely
#   sudo bash install.sh -h           Show help
#
# =============================================================================

set -e

# =============================================================================
# Configuration
# =============================================================================
GITHUB_REPO="coder4nix/XUIONE-WEBPLAYER-PUBLIC"
GITHUB_API="https://api.github.com/repos/$GITHUB_REPO/releases/latest"
INSTALL_DIR="/opt/xuione-webplayer"
WEBUI_PORT=80

# =============================================================================
# Colors and Formatting
# =============================================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
NC='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'

CHECK="✓"
CROSS="✗"
ARROW="→"
BULLET="•"

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
    echo "║                  WebPlayer PRO Installer                       ║"
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
    echo "║                 WebPlayer PRO Uninstaller                      ║"
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

print_status() {
    local name="$1"
    local status="$2"
    local version="$3"

    printf "  ${GRAY}%-20s${NC}" "$name"
    if [ "$status" = "installed" ]; then
        echo -e "${GREEN}${CHECK} Installed${NC} ${DIM}($version)${NC}"
    elif [ "$status" = "missing" ]; then
        echo -e "${YELLOW}${CROSS} Missing${NC}"
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
    echo -e "${WHITE}${BOLD}XUIONE WebPlayer PRO Installer${NC}"
    echo ""
    echo -e "${WHITE}Usage:${NC}"
    echo "  sudo bash install.sh [OPTIONS]"
    echo ""
    echo -e "${WHITE}Options:${NC}"
    echo "  -u, --uninstall   Uninstall XUIONE WebPlayer PRO completely"
    echo "  -h, --help        Show this help message"
    echo "  -p, --port PORT   Specify port (default: 80)"
    echo ""
    echo -e "${WHITE}Examples:${NC}"
    echo "  sudo bash install.sh           # Interactive install"
    echo "  sudo bash install.sh -p 8080   # Install on port 8080"
    echo "  sudo bash install.sh -u        # Uninstall"
    echo ""
    echo -e "${WHITE}One-liner:${NC}"
    echo "  curl -fsSL https://raw.githubusercontent.com/coder4nix/XUIONE-WEBPLAYER-PUBLIC/main/install.sh | sudo bash"
    echo ""
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

install_node_suse() {
    print_step "Installing Node.js..."
    zypper install -y nodejs20 npm20 > /dev/null 2>&1 || \
    zypper install -y nodejs npm > /dev/null 2>&1
}

install_nginx_debian() { apt-get install -y nginx > /dev/null 2>&1; }
install_nginx_rhel() { yum install -y nginx > /dev/null 2>&1; }
install_nginx_fedora() { dnf install -y nginx > /dev/null 2>&1; }
install_nginx_arch() { pacman -S --noconfirm nginx > /dev/null 2>&1; }
install_nginx_alpine() { apk add nginx > /dev/null 2>&1; }
install_nginx_suse() { zypper install -y nginx > /dev/null 2>&1; }

install_ffmpeg_debian() { apt-get install -y ffmpeg > /dev/null 2>&1; }
install_ffmpeg_rhel() { yum install -y epel-release > /dev/null 2>&1 || true; yum install -y ffmpeg > /dev/null 2>&1 || true; }
install_ffmpeg_fedora() { dnf install -y ffmpeg > /dev/null 2>&1 || true; }
install_ffmpeg_arch() { pacman -S --noconfirm ffmpeg > /dev/null 2>&1; }
install_ffmpeg_alpine() { apk add ffmpeg > /dev/null 2>&1; }
install_ffmpeg_suse() { zypper install -y ffmpeg > /dev/null 2>&1; }

install_package() {
    local package="$1"
    $PKG_INSTALL "$package" > /dev/null 2>&1
}

# =============================================================================
# Download Release
# =============================================================================

download_release() {
    print_step "Fetching latest release info..."

    local release_info
    release_info=$(curl -s "$GITHUB_API" 2>/dev/null)

    if [ -z "$release_info" ]; then
        print_error "Failed to fetch release info"
        exit 1
    fi

    # Extract version and download URL
    RELEASE_VERSION=$(echo "$release_info" | grep -oP '"tag_name":\s*"\K[^"]+' | head -1)
    DOWNLOAD_URL=$(echo "$release_info" | grep -oP '"browser_download_url":\s*"\K[^"]+\.tar\.gz' | head -1)

    if [ -z "$RELEASE_VERSION" ] || [ -z "$DOWNLOAD_URL" ]; then
        print_error "Failed to parse release info"
        exit 1
    fi

    echo -e "  ${GRAY}Version:${NC} ${WHITE}$RELEASE_VERSION${NC}"

    print_step "Downloading XUIONE WebPlayer PRO $RELEASE_VERSION..."

    # Create install directory
    mkdir -p "$INSTALL_DIR"
    cd "$INSTALL_DIR"

    # Download and extract
    local archive_name="xuione-webplayer-pro.tar.gz"
    if ! curl -fsSL "$DOWNLOAD_URL" -o "$archive_name"; then
        print_error "Download failed"
        exit 1
    fi

    print_step "Extracting..."
    tar -xzf "$archive_name" --strip-components=1
    rm -f "$archive_name"

    print_success "Downloaded and extracted to $INSTALL_DIR"
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
        if [[ "$user_port" =~ ^[0-9]+$ ]] && [ "$user_port" -ge 1 ] && [ "$user_port" -le 65535 ]; then
            WEBUI_PORT="$user_port"
        else
            print_error "Invalid port number. Using default port 80."
            WEBUI_PORT=80
        fi
    fi

    # Check if port is in use
    if command -v lsof &> /dev/null && lsof -i ":$WEBUI_PORT" -sTCP:LISTEN >/dev/null 2>&1; then
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
# Configuration
# =============================================================================

configure_nginx() {
    print_step "Configuring Nginx..."

    # Create cache directory
    mkdir -p /var/cache/nginx/xuione-images
    chown www-data:www-data /var/cache/nginx/xuione-images 2>/dev/null || \
    chown nginx:nginx /var/cache/nginx/xuione-images 2>/dev/null || true
    chmod 755 /var/cache/nginx/xuione-images

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

    NETWORK_IP=$(get_network_ip)

    cat > "$NGINX_CONF_DIR/xuione-webplayer.conf" << EOF
# XUIONE WebPlayer PRO - Nginx Configuration
# Generated by install.sh

proxy_cache_path /var/cache/nginx/xuione-images
    levels=1:2
    keys_zone=xuione_images:100m
    max_size=10g
    inactive=30d
    use_temp_path=off;

upstream xuione_proxy {
    server 127.0.0.1:3003;
    keepalive 32;
}

upstream xuione_vite {
    server 127.0.0.1:3000;
    keepalive 8;
}

server {
    listen $WEBUI_PORT;
    listen [::]:$WEBUI_PORT;
    server_name localhost $NETWORK_IP _;

    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_comp_level 6;
    gzip_types text/plain text/css text/xml text/javascript
               application/javascript application/json
               application/vnd.ms-fontobject application/x-font-ttf
               font/opentype image/svg+xml image/x-icon;

    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;

    location /api/image {
        proxy_pass http://xuione_proxy;
        proxy_http_version 1.1;
        proxy_set_header Connection "";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;

        proxy_cache xuione_images;
        proxy_cache_valid 200 30d;
        proxy_cache_valid 404 1m;
        proxy_cache_use_stale error timeout updating http_500 http_502 http_503 http_504;
        proxy_cache_lock on;
        proxy_cache_key "\$arg_url";

        add_header Cache-Control "public, max-age=2592000, immutable" always;
        add_header X-Cache-Status \$upstream_cache_status always;
    }

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

    echo "$WEBUI_PORT" > "$INSTALL_DIR/.webui_port"

    if nginx -t > /dev/null 2>&1; then
        print_success "Nginx configuration valid"
    else
        print_warning "Nginx configuration has issues, but continuing..."
    fi

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
Description=XUIONE WebPlayer PRO - Professional IPTV Web Player
Documentation=https://github.com/coder4nix/XUIONE-WEBPLAYER-PUBLIC
After=network.target nginx.service

[Service]
Type=simple
User=root
WorkingDirectory=$INSTALL_DIR
ExecStartPre=$INSTALL_DIR/scripts/stop.sh
ExecStart=$INSTALL_DIR/scripts/start.sh
ExecStop=$INSTALL_DIR/scripts/stop.sh
Restart=on-failure
RestartSec=10
KillMode=control-group
KillSignal=SIGTERM
TimeoutStopSec=30
Environment=NODE_ENV=production
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
    cd "$INSTALL_DIR"
    npm install --production > /dev/null 2>&1
    print_success "Dependencies installed"
}

# =============================================================================
# Uninstall
# =============================================================================

uninstall() {
    print_uninstall_header

    print_section "Uninstalling XUIONE WebPlayer PRO"
    echo ""

    print_warning "This will completely remove XUIONE WebPlayer PRO:"
    echo ""
    echo -e "  ${GRAY}${BULLET}${NC} Stop and disable systemd service"
    echo -e "  ${GRAY}${BULLET}${NC} Remove Nginx configuration"
    echo -e "  ${GRAY}${BULLET}${NC} Clear image cache"
    echo -e "  ${GRAY}${BULLET}${NC} Remove application files"
    echo ""

    if ! confirm "Are you sure you want to uninstall?" "n"; then
        echo ""
        echo -e "${GRAY}Uninstall cancelled${NC}"
        exit 0
    fi

    echo ""

    # Stop and disable service
    if systemctl is-active --quiet xuione-webplayer 2>/dev/null; then
        print_step "Stopping service..."
        systemctl stop xuione-webplayer 2>/dev/null || true
        print_success "Service stopped"
    fi

    if systemctl is-enabled --quiet xuione-webplayer 2>/dev/null; then
        print_step "Disabling service..."
        systemctl disable xuione-webplayer 2>/dev/null || true
        print_success "Service disabled"
    fi

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

    if command -v nginx &> /dev/null; then
        print_step "Restarting Nginx..."
        systemctl restart nginx 2>/dev/null || service nginx restart 2>/dev/null || true
        print_success "Nginx restarted"
    fi

    # Clear cache
    if [ -d /var/cache/nginx/xuione-images ]; then
        print_step "Clearing image cache..."
        rm -rf /var/cache/nginx/xuione-images
        print_success "Image cache cleared"
    fi

    # Remove log files
    print_step "Removing log files..."
    rm -f /var/log/nginx/xuione-access.log 2>/dev/null || true
    rm -f /var/log/nginx/xuione-error.log 2>/dev/null || true
    print_success "Log files removed"

    # Remove application files
    if [ -d "$INSTALL_DIR" ]; then
        print_step "Removing application files..."
        rm -rf "$INSTALL_DIR"
        print_success "Application files removed"
    fi

    echo ""
    print_section "Uninstall Complete"
    echo ""
    print_success "XUIONE WebPlayer PRO has been completely uninstalled"
    echo ""
}

# =============================================================================
# Main Installation
# =============================================================================

main() {
    print_header

    # Detect OS
    print_section "System Detection"
    detect_os

    if [ "$OS_TYPE" = "unknown" ]; then
        print_error "Unsupported operating system"
        echo -e "  ${GRAY}Supported: Ubuntu, Debian, CentOS, RHEL, Fedora, Arch, Alpine, openSUSE${NC}"
        exit 1
    fi

    echo ""
    echo -e "  ${GRAY}Operating System:${NC}  ${WHITE}$OS_NAME${NC}"
    echo -e "  ${GRAY}Version:${NC}           ${WHITE}$OS_VERSION${NC}"
    echo -e "  ${GRAY}Package Manager:${NC}   ${WHITE}$PKG_MANAGER${NC}"
    echo -e "  ${GRAY}Install Path:${NC}      ${WHITE}$INSTALL_DIR${NC}"

    check_root

    # Port
    print_section "Port Configuration"
    select_port

    # Check packages
    print_section "Checking Requirements"
    echo ""

    check_curl
    check_node
    check_npm
    check_nginx
    check_ffmpeg

    print_status "curl" "$CURL_STATUS" "$CURL_VERSION"
    print_status "Node.js (>=18)" "$NODE_STATUS" "$NODE_VERSION"
    print_status "npm" "$NPM_STATUS" "$NPM_VERSION"
    print_status "Nginx" "$NGINX_STATUS" "$NGINX_VERSION"
    print_status "ffmpeg" "$FFMPEG_STATUS" "$FFMPEG_VERSION"

    # Install missing packages
    NEED_INSTALL=""
    [ "$CURL_STATUS" = "missing" ] && NEED_INSTALL="$NEED_INSTALL curl"
    [ "$NODE_STATUS" = "missing" ] || [ "$NODE_STATUS" = "outdated" ] && NEED_INSTALL="$NEED_INSTALL nodejs"
    [ "$NGINX_STATUS" = "missing" ] && NEED_INSTALL="$NEED_INSTALL nginx"
    [ "$FFMPEG_STATUS" = "missing" ] && NEED_INSTALL="$NEED_INSTALL ffmpeg"

    echo ""

    if [ -n "$NEED_INSTALL" ]; then
        print_warning "Missing packages:${YELLOW}$NEED_INSTALL${NC}"
        echo ""
        if ! confirm "Install missing packages?"; then
            exit 1
        fi
    else
        print_success "All required packages are installed"
    fi

    # Installation
    print_section "Installation"
    echo ""

    $PKG_UPDATE > /dev/null 2>&1 || true

    if [ "$CURL_STATUS" = "missing" ]; then
        print_step "Installing curl..."
        install_package curl
        print_success "curl installed"
    fi

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

    if [ "$FFMPEG_STATUS" = "missing" ]; then
        print_step "Installing ffmpeg..."
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
        fi
    fi

    # Download release
    print_section "Downloading XUIONE WebPlayer PRO"
    echo ""
    download_release

    # Configure
    print_section "Configuration"
    echo ""
    configure_nginx
    install_npm_dependencies
    create_systemd_service

    # Start service
    print_step "Starting service..."
    systemctl start xuione-webplayer 2>/dev/null || true
    sleep 3

    if systemctl is-active --quiet xuione-webplayer 2>/dev/null; then
        print_success "Service started"
    else
        print_warning "Service may need manual start"
    fi

    # Done
    NETWORK_IP=$(get_network_ip)

    print_section "Installation Complete"
    echo ""
    print_success "XUIONE WebPlayer PRO has been installed successfully!"
    echo ""
    echo -e "${WHITE}${BOLD}Next Step:${NC}"
    echo ""
    echo -e "  ${GRAY}Open the WebUI and enter your license key when prompted.${NC}"
    echo -e "  ${GRAY}Purchase a license at:${NC} ${CYAN}https://xuiwebplayer.com${NC}"
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
    echo -e "${WHITE}${BOLD}Commands:${NC}"
    echo ""
    echo -e "  ${GRAY}Start:${NC}     sudo systemctl start xuione-webplayer"
    echo -e "  ${GRAY}Stop:${NC}      sudo systemctl stop xuione-webplayer"
    echo -e "  ${GRAY}Status:${NC}    sudo systemctl status xuione-webplayer"
    echo -e "  ${GRAY}Logs:${NC}      sudo journalctl -u xuione-webplayer -f"
    echo -e "  ${GRAY}Uninstall:${NC} sudo bash $INSTALL_DIR/install.sh -u"
    echo ""
    echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
    echo ""
}

# =============================================================================
# Argument Parsing
# =============================================================================

while [[ $# -gt 0 ]]; do
    case "$1" in
        -u|--uninstall)
            check_root
            uninstall
            exit 0
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        -p|--port)
            WEBUI_PORT="$2"
            shift 2
            ;;
        *)
            print_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

main "$@"
