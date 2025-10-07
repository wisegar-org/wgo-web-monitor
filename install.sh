@echo off

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