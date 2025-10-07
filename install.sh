@echo off

:: === DOWNLOAD SERVICE RELEASE ===
# Clone the latest published release from GitHub
REPO_URL="https://github.com/wisegar-org/wgo-web-monitor.git"
RELEASE_API="https://api.github.com/repos/wisegar-org/wgo-web-monitor/releases/latest"
TMP_DIR="/tmp/wgo-web-monitor-release"

# Clean up any previous temp directory
rm -rf "$TMP_DIR"
mkdir -p "$TMP_DIR"

# Get the latest release tarball URL
TARBALL_URL=$(curl -s $RELEASE_API | grep "tarball_url" | cut -d '"' -f 4)

# Download and extract the latest release
curl -L "$TARBALL_URL" -o "$TMP_DIR/release.tar.gz"
mkdir -p "$EXEC_PATH"
tar -xzf "$TMP_DIR/release.tar.gz" --strip-components=1 -C "$EXEC_PATH"

# Move extracted files to /opt/wisegar/monitor
mkdir -p /opt/wisegar/monitor
mv "$EXEC_PATH"/* /opt/wisegar/monitor/

echo "Downloaded and extracted the latest release to $EXEC_PATH"

:: === CONFIGURATION ===
set SERVICE_NAME=WisegarMonitor
set SERVICE_DESCRIPTION=Wisegar Monitor Service
set EXEC_PATH=/opt/wisegar/monitor
set USER=www-data
set ENVIRONMENT=Production


:: === CREATE SYSTEMD SERVICE FILE ===
echo [Unit] > /etc/systemd/system/%SERVICE_NAME%.service
echo Description=%SERVICE_DESCRIPTION% >> /etc/systemd/system/%SERVICE_NAME%.service
echo After=network.target >> /etc/systemd/system/%SERVICE_NAME%.service

echo [Service] >> /etc/systemd/system/%SERVICE_NAME%.service
echo Type=simple >> /etc/systemd/system/%SERVICE_NAME%.service
echo User=%USER% >> /etc/systemd/system/%SERVICE_NAME%.service
echo WorkingDirectory=%EXEC_PATH% >> /etc/systemd/system/%SERVICE_NAME%.service
echo Environment=ENVIRONMENT=%ENVIRONMENT% >> /etc/systemd/system/%SERVICE_NAME%.service
echo ExecStart=%EXEC_PATH%/start.sh >> /etc/systemd/system/%SERVICE_NAME%.service
echo Restart=on-failure >> /etc/systemd/system/%SERVICE_NAME%.service

echo [Install] >> /etc/systemd/system/%SERVICE_NAME%.service
echo WantedBy=multi-user.target >> /etc/systemd/system/%SERVICE_NAME%.service

echo Systemd service file created at /etc/systemd/system/%SERVICE_NAME%.service

:: === RELOAD SYSTEMD, ENABLE AND START SERVICE ===
systemctl daemon-reload
systemctl enable %SERVICE_NAME%
systemctl start %SERVICE_NAME%
echo Service %SERVICE_NAME% has been started and enabled to run at boot.
systemctl status %SERVICE_NAME%
echo To view logs, use: journalctl -u %SERVICE_NAME% -f
echo Installation complete.