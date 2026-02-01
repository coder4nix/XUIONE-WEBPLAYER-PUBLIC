# Getting Started with XUIONE WebPlayer

## Prerequisites

- Node.js 18+ or Docker
- Valid XUIONE WebPlayer license key
- IPTV provider credentials (Xtream Codes or M3U)

## Installation Methods

### Method 1: Docker (Recommended)

```bash
docker run -d \
  -p 3000:3000 \
  -e LICENSE_KEY=YOUR-LICENSE-KEY \
  -v xuione-data:/app/data \
  --name xuione \
  xuione-webplayer:latest
```

### Method 2: Manual Installation

1. Download the latest release
2. Extract the archive
3. Install dependencies: `npm install`
4. Configure environment: `cp .env.example .env`
5. Start the server: `npm start`

## First-Time Setup

1. Open your browser and navigate to `http://localhost:3000`
2. Enter your license key when prompted
3. Navigate to **Settings → Xtream Codes**
4. Enter your IPTV provider details:
   - Server URL
   - Username
   - Password
5. Click **Save & Connect**
6. Wait for channels to load
7. Enjoy!

## Next Steps

- [Configuration Options](configuration.md)
- [Troubleshooting](troubleshooting.md)
- [FAQ](faq.md)
