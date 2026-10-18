# OBS Webcam

<p align="center">
  <strong>Turn your phone into a webcam for OBS Studio.</strong>
  <br />
  Stream your phone's camera to your computer using a browser-based WebRTC connection.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Node.js-Backend-339933?logo=nodedotjs&logoColor=white" alt="Node.js" />
  <img src="https://img.shields.io/badge/WebRTC-Video%20Streaming-333333?logo=webrtc&logoColor=white" alt="WebRTC" />
  <img src="https://img.shields.io/badge/OBS%20Studio-Compatible-302E31?logo=obsstudio&logoColor=white" alt="OBS Studio" />
  <img src="https://img.shields.io/badge/Platform-Windows-0078D4?logo=windows&logoColor=white" alt="Windows" />
</p>

---

## Overview

**OBS Webcam** is a browser-based project designed to connect your phone's camera to OBS Studio through a computer running a Node.js and Express server.

The project uses WebRTC for video streaming and provides browser pages for the phone and receiver.

## Features

| Feature | Description |
|---|---|
| Phone camera | Access your phone camera through a browser |
| WebRTC streaming | Send video between connected browser pages |
| OBS integration | Use the receiver page as an OBS Browser source, if supported by the current setup |
| HTTPS setup | PowerShell script helps generate local development certificates |
| Simple setup | Install dependencies and start the server with one script |

## Requirements

- [Node.js](https://nodejs.org/)
- [OBS Studio](https://obsproject.com/)
- A phone and computer connected to the same Wi-Fi network for local testing
- Windows PowerShell
- `mkcert` or OpenSSL for certificate generation

## Getting Started

### 1. Clone the repository

```powershell
git clone https://github.com/RixCOD/obs-webcam.git
cd obs-webcam
```

### 2. Run the setup script

Make sure `setup-obs-webcam.ps1` is in the repository's root folder.

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\setup-obs-webcam.ps1
```

The script is intended to:

- Check Node.js and npm
- Install project dependencies
- Update `.gitignore` for local secrets and certificates
- Generate HTTPS certificates if needed
- Start `server.js`

### 3. Connect your phone

1. Start the server.
2. Find the HTTPS URL printed in the terminal.
3. Open the appropriate URL on your phone while connected to the same network.
4. Grant camera permission when prompted.

> **Note:** Self-signed certificates may trigger browser warnings. Your phone may need to trust the certificate before camera access will work.

## Using OBS Studio

1. Start the project server.
2. Open the phone camera page in your phone's browser.
3. Open the receiver page on your computer.
4. In OBS Studio, add a **Browser** source.
5. Enter the receiver page URL if your current implementation supports it.
6. Confirm that the video appears in OBS.

## Project Structure

```text
obs-webcam/
├── public/
│   ├── index.html
│   └── receiver.html
├── server.js
├── package.json
├── package-lock.json
├── setup-obs-webcam.ps1
├── .gitignore
└── README.md
```

## Security

- Never commit `key.pem`, private keys, or `.env` files.
- Allow camera access only on devices and pages you trust.
- HTTPS certificates must be valid for the hostname or IP address you use.
- A certificate warning does not mean the connection is trusted or secure.

## Contributing

Contributions, bug reports, and suggestions are welcome. Open an issue to discuss a change before submitting a pull request.

## License

No license has been specified yet.

---

<p align="center">
  Made for creators using <a href="https://obsproject.com/">OBS Studio</a>.
</p>
