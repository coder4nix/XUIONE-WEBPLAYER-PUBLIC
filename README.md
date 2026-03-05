# XUIONE WebPlayer PRO

<p align="center">
  <strong>Professional IPTV Web Player for Xtream Codes & XUI.ONE</strong>
</p>

<p align="center">
  <a href="#features">Features</a> •
  <a href="#installation">Installation</a> •
  <a href="#documentation">Documentation</a> •
  <a href="#Support">Support</a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/license-Commercial-orange.svg" alt="License">
  <img src="https://img.shields.io/badge/platform-Linux-green.svg" alt="Platform">
</p>


<img width="1920" height="919" alt="chrome_yU0Xiumm2Q" src="https://github.com/user-attachments/assets/f8fadb71-7595-4b11-bd28-7ee0b342f641" />

<img width="1920" height="919" alt="chrome_md98Un4Kpq" src="https://github.com/user-attachments/assets/4cfcccc2-a005-41c0-98cf-3ceb3cccf7d9" />

![chrome_L79TgoUwcF](https://github.com/user-attachments/assets/f14397c2-3ae6-4bae-8b53-e61712d2d71b)

<img width="1920" height="919" alt="chrome_LtSGAEZIVK" src="https://github.com/user-attachments/assets/d85d6ae5-4aaa-4f42-b7b7-a62350a4c0e7" />

<img width="1920" height="919" alt="image" src="https://github.com/user-attachments/assets/5bdbd89c-bbb4-4325-b838-7a8275c3cb77" />

<img width="1920" height="919" alt="chrome_TCHDoN4B1H" src="https://github.com/user-attachments/assets/797968ab-a8c2-4c43-842c-431ea9e1beed" />

<img width="1920" height="919" alt="chrome_asbJYE2EVM" src="https://github.com/user-attachments/assets/68b8151f-4123-4ff6-b34d-944b0c55738d" />

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
- **Xtream Codes/XUI.ONE API** - Full compatibility
- **1-Stream API** - Compatible with 1-Stream servers
- **Built-in Proxy** - Bypass CORS restrictions
- **Low Resource Usage** - Runs on minimal hardware

---

## Installation

### Quick Install (Recommended)

A valid license key is required. **[Get your license at xuiwebplayer.com](https://xuiwebplayer.com)**

Download and run the installer:

```bash
# AMD64 (most servers)
curl -Lo install https://xuiwebplayer.com/api/installer/binary?arch=amd64
chmod +x install
sudo ./install --license YOUR-LICENSE-KEY

# ARM64 (Raspberry Pi, ARM servers)
curl -Lo install https://xuiwebplayer.com/api/installer/binary?arch=arm64
chmod +x install
sudo ./install --license YOUR-LICENSE-KEY
```

The installer will:
- Verify your license key
- Detect your Linux distribution
- Install all required dependencies (Node.js 20, Nginx, ffmpeg)
- Download and configure the latest release
- Set up Nginx with optimized caching
- Create a systemd service for auto-start

### Requirements

- **Linux**: Ubuntu 22.04+, Debian 11+, CentOS/RHEL 8+, Fedora 36+, Arch, Alpine 3.15+
- **Hardware**: 1GB RAM, 1 CPU core minimum
- **License**: Valid XUIONE WebPlayer PRO license key

### After Installation

1. Open `http://your-server-ip` in your browser
2. Enter your license key when prompted (first launch only)
3. Go to **Settings** and add your IPTV provider credentials
4. Enjoy!

### Useful Commands

```bash
# Service management
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

### Customer Portal

Manage your license, billing, and downloads at: **[portal.xuiwebplayer.com](https://portal.xuiwebplayer.com)**

---

## License

XUIONE WebPlayer PRO is commercial software. A valid license is required for use.

**[Purchase License](https://xuiwebplayer.com)**

See [LICENSE.md](LICENSE.md) for full terms.

---

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history.

---

<p align="center">
  Made by <a href="https://github.com/coder4nix">coder4nix</a>
</p>
