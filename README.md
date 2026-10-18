# OBS Webcam

Use your phone as a webcam source in OBS Studio through a browser-based connection.

## Features

- Connect a phone and computer through a web browser.
- Stream video using WebRTC.
- Use a browser receiver page as a source in OBS Studio.
- Lightweight Node.js and Express server.

## Requirements

- [Node.js](https://nodejs.org/)
- [OBS Studio](https://obsproject.com/)
- A phone and computer connected to the same network, unless your server is hosted for remote access.

## Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/RixCOD/obs-webcam.git
   cd obs-webcam
   ```

2. Install dependencies:

   ```bash
   npm install
   ```

3. Start the server using the start command configured in `package.json`:

   ```bash
   npm start
   ```

   If no start script is configured, run:

   ```bash
   node server.js
   ```

4. Open the local address configured by your server in a browser.

## Using with OBS Studio

1. Start the server.
2. Open the phone page on your phone and allow camera access.
3. Open the receiver page on your computer.
4. In OBS Studio, add a **Browser** source and use the receiver page URL if the project supports loading it directly in OBS.
5. Confirm that the video appears in OBS.

## Project Structure

```text
obs-webcam/
├── public/
│   ├── index.html
│   └── receiver.html
├── server.js
├── package.json
├── package-lock.json
├── .gitignore
└── README.md
```
1. Open your project repository in a terminal or PowerShell.

2. Run these commands:

   ```powershell
   cd F:\Path to the repo\Git\obs-webcam
   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
   .\setup-obs-webcam.ps1
   ```

3. Wait for the script to install dependencies, set up the HTTPS certificate, and start `server.js`.

4. Open the HTTPS URL shown in the terminal to test the application.
## Security Notes

- Do not commit private keys, certificates, or `.env` files.
- Camera access requires browser permission.
- HTTPS may be required for camera access on devices other than localhost.

## License

No license has been specified yet.
