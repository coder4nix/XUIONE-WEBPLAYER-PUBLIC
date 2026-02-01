# XUIONE WebPlayer

<p align="center">
  <strong>Professional IPTV Web Player for Xtream Codes & M3U</strong>
</p>

<p align="center">
  <a href="#features">Features</a> •
  <a href="#screenshots">Screenshots</a> •
  <a href="#installation">Installation</a> •
  <a href="#documentation">Documentation</a> •
  <a href="#support">Support</a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/version-1.2.16-blue.svg" alt="Version">
  <img src="https://img.shields.io/badge/license-Commercial-orange.svg" alt="License">
  <img src="https://img.shields.io/badge/platform-Web-green.svg" alt="Platform">
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

## Screenshots

<p align="center">
  <em>Screenshots coming soon</em>
</p>

---

## Installation

### Requirements

- Node.js 18+ or Docker
- Valid XUIONE WebPlayer License

### Quick Start (Docker)

```bash
# Download latest release
# See Releases section for download link

# Run with Docker
docker run -d \
  -p 3000:3000 \
  -e LICENSE_KEY=XXXX-XXXX-XXXX-XXXX \
  --name xuione \
  xuione-webplayer:latest
```

### Manual Installation

1. Download the latest release from [Releases](https://github.com/coder4nix/XUIONE-WEBPLAYER-PUBLIC/releases)
2. Extract the archive
3. Configure your license key
4. Start the server

```bash
# Extract
tar -xzf xuione-webplayer-v1.2.16.tar.gz
cd xuione-webplayer

# Configure
cp .env.example .env
# Edit .env and add your LICENSE_KEY

# Start
npm start
```

### First Setup

1. Open `http://localhost:3000` in your browser
2. Enter your license key when prompted
3. Go to Settings → Xtream Codes
4. Add your IPTV provider credentials
5. Enjoy!

---

## Documentation

- [Getting Started Guide](docs/getting-started.md)
- [Configuration Options](docs/configuration.md)
- [Docker Deployment](docs/docker.md)
- [Troubleshooting](docs/troubleshooting.md)
- [FAQ](docs/faq.md)

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

XUIONE WebPlayer is commercial software. A valid license is required for use.

- **Basic License** - 1 domain, personal use
- **Pro License** - 3 domains, commercial use
- **Enterprise License** - Unlimited domains, priority support

See [LICENSE.md](LICENSE.md) for full terms.

---

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history.

---

<p align="center">
  Made by <a href="https://github.com/coder4nix">coder4nix</a>
</p>
