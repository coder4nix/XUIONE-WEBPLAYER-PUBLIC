# XUIONE WebPlayer PRO

<p align="center">
  <strong>Professional IPTV Web Player for Xtream Codes & M3U</strong>
</p>

<p align="center">
  <a href="#features">Features</a> •
  <a href="#installation">Installation</a> •
  <a href="#documentation">Documentation</a> •
  <a href="#support">Support</a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/version-1.2.25-blue.svg" alt="Version">
  <img src="https://img.shields.io/badge/license-Commercial-orange.svg" alt="License">
  <img src="https://img.shields.io/badge/platform-Linux-green.svg" alt="Platform">
</p>

---

## Features

### Live TV
- **Channel Management** - Organize channels by categories and favorites
- **EPG Support** - Electronic Program Guide with 7-day schedule
- **Multi-Format** - Supports HLS, MPEG-DASH, and more
- **Catch-up TV** - Watch past programs (if supported by provider)

### Movies & Series
- **VOD Library** - Browse and search your movie collection
- **Series Support** - Full TV series with seasons and episodes
- **TMDB Integration** - Automatic movie/series metadata and posters
- **Continue Watching** - Resume where you left off

### User Experience
- **Modern UI** - Clean, responsive interface
- **Dark Mode** - Easy on the eyes
- **Multi-language** - English, German, and more
- **Keyboard Navigation** - Full keyboard and remote control support
- **Search** - Global search across all content

### Technical
- **Xtream Codes API** - Full compatibility
- **M3U/M3U8 Support** - Import playlists
- **Built-in Proxy** - Bypass CORS restrictions
- **Docker Ready** - Easy deployment
- **Low Resource Usage** - Runs on minimal hardware

---

## Installation

### Quick Install (Recommended)

Download and run the installer binary:

```bash
# AMD64 (most servers)
curl -fsSL https://github.com/coder4nix/XUIONE-WEBPLAYER-PUBLIC/releases/latest/download/install-linux-amd64 -o install
chmod +x install
sudo ./install

# ARM64 (Raspberry Pi, ARM servers)
curl -fsSL https://github.com/coder4nix/XUIONE-WEBPLAYER-PUBLIC/releases/latest/download/install-linux-arm64 -o install
chmod +x install
sudo ./install
```

The installer will:
- Detect your Linux distribution
- Install all required dependencies (Node.js 20, Nginx, ffmpeg)
- Download and extract the latest release
- Configure Nginx with optimized caching
- Create a systemd service for auto-start

### Requirements

- **Linux**: Ubuntu 22.04+, Debian 11+, CentOS/RHEL 8+, Fedora 36+, Arch, Alpine 3.15+
- **Hardware**: 1GB RAM, 1 CPU core minimum
- **License**: Valid XUIONE WebPlayer PRO license key

**[Get your license at xuiwebplayer.com](https://xuiwebplayer.com)**

### After Installation

1. Open `http://your-server-ip` in your browser
2. Enter your license key when prompted (first launch only)
3. Go to **Settings** → **Xtream Codes** or **M3U**
4. Add your IPTV provider credentials
5. Enjoy!

### Useful Commands

```bash
# Service management (with colored output)
sudo xuione start      # Start the service
sudo xuione stop       # Stop the service
sudo xuione restart    # Restart the service
sudo xuione status     # Show service status
sudo xuione logs       # Follow service logs

# Alternative systemctl commands
sudo systemctl start xuione-webplayer
sudo systemctl stop xuione-webplayer
sudo systemctl status xuione-webplayer

# Uninstall
sudo /opt/xuione-webplayer/install -u
```

### Manual Installation

<details>
<summary>Click to expand manual installation steps</summary>

1. **Download the latest release**

```bash
VERSION=$(curl -s https://api.github.com/repos/coder4nix/XUIONE-WEBPLAYER-PUBLIC/releases/latest | grep tag_name | cut -d'"' -f4)
wget "https://github.com/coder4nix/XUIONE-WEBPLAYER-PUBLIC/releases/download/${VERSION}/xuione-webplayer-pro-${VERSION}.tar.gz"
```

2. **Extract to /opt**

```bash
sudo mkdir -p /opt/xuione-webplayer
sudo tar -xzf xuione-webplayer-pro-*.tar.gz -C /opt/xuione-webplayer --strip-components=1
cd /opt/xuione-webplayer
```

3. **Install dependencies**

```bash
sudo npm install --production
```

4. **Start the server**

```bash
sudo npm start
```

</details>

### Docker Installation

```bash
docker run -d \
  --name xuione-webplayer \
  -p 80:3000 \
  -v xuione-data:/app/data \
  --restart unless-stopped \
  ghcr.io/coder4nix/xuione-webplayer:latest
```

---

## Documentation

Full documentation is available at: **[xuiwebplayer.com/docs](https://xuiwebplayer.com/docs/)**

---

## Support

### Bug Reports

Found a bug? Please [create an issue](https://github.com/coder4nix/XUIONE-WEBPLAYER-PUBLIC/issues/new?template=bug_report.md) with:
- Your XUIONE version
- Steps to reproduce
- Expected vs actual behavior
- Screenshots (if applicable)

### Feature Requests

Have an idea? [Submit a feature request](https://github.com/coder4nix/XUIONE-WEBPLAYER-PUBLIC/issues/new?template=feature_request.md)

---

## License

XUIONE WebPlayer PRO is commercial software. A valid license is required for use.

| Plan | Domains | Price |
|------|---------|-------|
| **Basic** | 1 domain | $9/month |
| **Pro** | 3 domains | $19/month |
| **Enterprise** | Unlimited | $49/month |

**[Purchase License](https://xuiwebplayer.com)**

See [LICENSE.md](LICENSE.md) for full terms.

---

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history.

---

<p align="center">
  Made by <a href="https://github.com/coder4nix">coder4nix</a>
</p>
