# obs-webcam setup helper
# Run this script from any location. It uses the project folder next to this script
# unless -ProjectPath is supplied.

param(
    [string]$ProjectPath = $PSScriptRoot,
    [int]$Port = 3000
)

$ErrorActionPreference = "Stop"

function Write-Step([string]$Message) {
    Write-Host "`n==> $Message" -ForegroundColor Cyan
}

function Fail([string]$Message) {
    Write-Host "`nERROR: $Message" -ForegroundColor Red
    exit 1
}

try {
    if ([string]::IsNullOrWhiteSpace($ProjectPath)) {
        Fail "Project path is empty. Save this script in your project folder or pass -ProjectPath."
    }

    $ProjectPath = [System.IO.Path]::GetFullPath($ProjectPath)
    if (-not (Test-Path -LiteralPath $ProjectPath -PathType Container)) {
        Fail "Project folder not found: $ProjectPath"
    }

    Set-Location -LiteralPath $ProjectPath
    Write-Host "Project: $ProjectPath" -ForegroundColor Green

    # Check Node.js / npm
    Write-Step "Checking Node.js and npm"
    $node = Get-Command node -ErrorAction SilentlyContinue
    $npm = Get-Command npm -ErrorAction SilentlyContinue
    if (-not $node -or -not $npm) {
        Fail "Node.js/npm not found. Install the current LTS version from https://nodejs.org/ and reopen PowerShell."
    }
    node --version
    npm --version

    # Install package dependencies
    Write-Step "Installing npm dependencies"
    if (Test-Path -LiteralPath (Join-Path $ProjectPath "package-lock.json")) {
        npm ci
    } elseif (Test-Path -LiteralPath (Join-Path $ProjectPath "package.json")) {
        npm install
    } else {
        Fail "package.json not found in $ProjectPath"
    }
    if ($LASTEXITCODE -ne 0) { Fail "npm dependency installation failed." }

    # Ensure generated private key/certificate are ignored by Git.
    Write-Step "Checking .gitignore"
    $gitignore = Join-Path $ProjectPath ".gitignore"
    $requiredIgnore = @("node_modules/", ".env", "key.pem", "cert.pem")
    if (Test-Path -LiteralPath $gitignore) {
        $existing = Get-Content -LiteralPath $gitignore
    } else {
        $existing = @()
    }
    foreach ($entry in $requiredIgnore) {
        if (-not ($existing -contains $entry)) {
            Add-Content -LiteralPath $gitignore -Value $entry
        }
    }

    # Create a locally-trusted development certificate with mkcert if available.
    # mkcert is recommended because phones otherwise warn about self-signed certs.
    $certPath = Join-Path $ProjectPath "cert.pem"
    $keyPath = Join-Path $ProjectPath "key.pem"
    $mkcert = Get-Command mkcert -ErrorAction SilentlyContinue
    if (-not ((Test-Path -LiteralPath $certPath) -and (Test-Path -LiteralPath $keyPath))) {
        Write-Step "Creating HTTPS certificate"
        if ($mkcert) {
            $ipAddresses = @()
            $adapters = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
                Where-Object {
                    $_.IPAddress -match '^\d{1,3}(\.\d{1,3}){3}$' -and
                    $_.IPAddress -notlike "127.*" -and
                    $_.IPAddress -notlike "169.254.*"
                } |
                Select-Object -ExpandProperty IPAddress -Unique
            $names = @("localhost", "127.0.0.1", "::1") + $adapters
            & mkcert -cert-file $certPath -key-file $keyPath @names
            if ($LASTEXITCODE -ne 0) { Fail "mkcert could not create the certificate." }
            Write-Host "Created certificate using mkcert." -ForegroundColor Green
            Write-Host "For phone trust, install mkcert's local root CA on the phone; see https://github.com/FiloSottile/mkcert#mobile-devices" -ForegroundColor Yellow
        } else {
            $openssl = Get-Command openssl -ErrorAction SilentlyContinue
            if (-not $openssl) {
                Fail "Neither mkcert nor OpenSSL was found. Install mkcert (recommended) or OpenSSL, then run this script again. mkcert: https://github.com/FiloSottile/mkcert"
            }

            # OpenSSL self-signed certificate with SAN entries for localhost and LAN IPv4s.
            $sanParts = @("DNS:localhost", "IP:127.0.0.1", "IP:::1")
            $adapters = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
                Where-Object {
                    $_.IPAddress -match '^\d{1,3}(\.\d{1,3}){3}$' -and
                    $_.IPAddress -notlike "127.*" -and
                    $_.IPAddress -notlike "169.254.*"
                } |
                Select-Object -ExpandProperty IPAddress -Unique
            foreach ($ip in $adapters) { $sanParts += "IP:$ip" }
            $san = $sanParts -join ","
            $opensslConfig = Join-Path $ProjectPath "openssl-cert.cnf"
            @"
[req]
default_bits = 2048
prompt = no
default_md = sha256
x509_extensions = v3_req
distinguished_name = dn

[dn]
CN = localhost

[v3_req]
subjectAltName = $san
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
"@ | Set-Content -LiteralPath $opensslConfig -Encoding ascii

            & openssl req -x509 -nodes -days 365 -newkey rsa:2048 `
                -keyout $keyPath -out $certPath -config $opensslConfig
            $opensslExit = $LASTEXITCODE
            Remove-Item -LiteralPath $opensslConfig -Force -ErrorAction SilentlyContinue
            if ($opensslExit -ne 0) { Fail "OpenSSL certificate generation failed." }
            Write-Host "Created self-signed certificate with local IP SANs." -ForegroundColor Green
            Write-Host "Browsers/phones will still show a trust warning until this certificate is trusted." -ForegroundColor Yellow
        }
    } else {
        Write-Host "Existing cert.pem and key.pem found; leaving them unchanged." -ForegroundColor Green
    }

    # Report the LAN addresses for phone testing.
    Write-Step "Local network addresses"
    $lanIPs = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
        Where-Object {
            $_.IPAddress -match '^\d{1,3}(\.\d{1,3}){3}$' -and
            $_.IPAddress -notlike "127.*" -and
            $_.IPAddress -notlike "169.254.*"
        } |
        Select-Object -ExpandProperty IPAddress -Unique
    foreach ($ip in $lanIPs) {
        Write-Host "Phone URL (if on same Wi-Fi): https://${ip}:$Port/" -ForegroundColor Yellow
    }
    Write-Host "Local URL: https://localhost:$Port/" -ForegroundColor Yellow

    # Run the server. Server must actually be configured to use HTTPS.
    Write-Step "Starting server"
    Write-Host "This script assumes server.js reads key.pem/cert.pem and starts HTTPS on port $Port." -ForegroundColor Yellow
    Write-Host "Press Ctrl+C to stop the server." -ForegroundColor Gray
    node .\server.js
    if ($LASTEXITCODE -ne 0) {
        Fail "server.js exited with an error. Check that it uses HTTPS, reads key.pem/cert.pem, and listens on port $Port."
    }
}
catch {
    Write-Host "`nERROR: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
