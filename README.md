# Website Monitor Service — Documentation (English)

This guide explains how to configure, run and install the Website Monitor Service project on Windows.

## Overview

The project is a .NET 8 Windows service that periodically performs HTTP checks on a list of websites and sends email notifications when one or more sites return errors (status code different from 200), timeouts or exceptions.

Main files:

- `Program.cs` — service bootstrap and DI registration
- `Worker.cs` — background worker that performs checks and sends emails
- `WebsiteMonitorConfig.cs` — configuration for URLs and intervals
- `EmailSettings.cs`, `EmailService.cs` — email settings and sending logic
- `appsettings.json` — application configuration (sites, email)

## Prerequisites

- .NET 8 SDK / Runtime installed on the machine
- Access to an SMTP server to send emails (e.g. Gmail with app password or another corporate SMTP)
- Administrative privileges to install a Windows service

## Configuration

Open `appsettings.json` and edit the `WebsiteMonitor` and `EmailSettings` sections.

Example:

```json
{
  "WebsiteMonitor": {
    "Websites": [
      "https://example1.ch",
      "https://example2.ch"
    ],
    "CheckIntervalMinutes": 5,
    "TimeoutSeconds": 30
  },
  "EmailSettings": {
    "SmtpServer": "smtp.server.com",
    "SmtpPort": 587,
    "EnableSsl": true,
    "Username": "your_email@yourdomain.com",
    "Password": "your_app_password",
    "FromEmail": "your_email@yourdomain.com",
    "FromName": "Website Monitor Service",
    "ToEmails": ["admin@yourdomain.com"],
    "Subject": "ALERT: Website Down"
  }
}
```

Gmail notes: enable two-factor authentication and create an App Password to avoid SMTP access issues.

## Run in development

From the project folder in PowerShell:

```powershell
# Run in development mode
dotnet run
```

The app reads `appsettings.json` from the working directory (by default the project folder when running `dotnet run`).

## Create production publish

To publish the executable:

```powershell
dotnet publish -c Release -o .\publish
```

After publishing, files are available in the `publish\` folder (including the executable).

## Install as a Windows Service

This repository provides a PowerShell installer script to create the Windows service. Legacy batch installers and any `scripts/` uninstall batch have been removed. Before running the installer, open the script and verify the `$servicePath` value points to the correct executable in your `publish\` folder.

Installer script:

- `install-service.ps1` — PowerShell installer (root). Recommended: performs elevation checks and prints clearer output.

Quick examples (run from an elevated PowerShell prompt):

Using `sc.exe` manually:

```powershell
# Create and start the service using sc.exe
sc.exe create "Website Monitor" binPath= "C:\full\path\to\publish\WebsiteMonitorService.exe" DisplayName= "Website Monitor Service"
sc.exe start "Website Monitor"

# To stop and remove the service
sc.exe stop "Website Monitor"
sc.exe delete "Website Monitor"
```

Using the PowerShell installer (recommended):

```powershell
# From an elevated PowerShell prompt in the repo root
# If your execution policy blocks scripts, run with ExecutionPolicy Bypass:
powershell -ExecutionPolicy Bypass -File .\install-service.ps1
# Or run interactively after setting execution policy for the session:
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass; .\install-service.ps1
```

Notes:

- Always verify the `$servicePath` inside the script points to your published executable.
- Run the PowerShell installer as Administrator — the script checks for elevation and will prompt if not elevated.
- To uninstall the service you can run the `sc.exe stop` and `sc.exe delete` commands shown above.

## Logs

Logs are written to the `Logs` folder relative to the executable directory. File name: `website-monitor-YYYY-MM-DD.log`.

Typical log line:

- timestamp | url | status code | status | optional error message

If the service does not write logs, check `Logs` folder permissions and that the executable has the necessary rights.

## Email Notifications

The service sends emails in these main cases:

- Status code different from 200
- Timeout or network exceptions

The email body includes the URL, status code, state (OFFLINE/ERROR/TIMEOUT), timestamp and the error message (if any).

## Quick customizations

- Check interval: `WebsiteMonitor:CheckIntervalMinutes` in `appsettings.json`
- HTTP timeout: `WebsiteMonitor:TimeoutSeconds`
- Add/remove sites: `WebsiteMonitor:Websites`
- Change recipients: `EmailSettings:ToEmails`

To change notification logic or email templates, edit `EmailService.cs` or `Worker.cs`.

## Troubleshooting

- Problem: emails are not sent
  - Verify `EmailSettings` (SMTP server, port, credentials)
  - For Gmail: use an App Password and check security blocks
  - Check logs in `Logs` for delivery errors

- Problem: service does not start
  - Run the `.exe` manually from the `publish` folder to see exceptions
  - Check Windows Event Viewer (Application logs)
  - Make sure the service was created with the correct `binPath`

## Suggestions and next steps

- Add retry/backoff for HTTP checks
- Avoid sending a success email for every healthy site (current code sends success emails for working sites; consider removing or throttling these)
- Protect credentials: use Key Vault, environment variables or other secret management instead of storing passwords in plain text in `appsettings.json`

## Contact

If you need help with configuration or want me to update the main project `README.md`, tell me which sections to modify and I will update them directly.

---

Useful files in the repository: `Program.cs`, `Worker.cs`, `appsettings.json`, `install-service.bat`, `uninstall-service.bat`.

## Maintainers

This project is actively maintained by the following contributors:

| Name              | Role                        | GitHub Handle     | Responsibilities                          |
|-------------------|-----------------------------|-------------------|-------------------------------------------|
| Yariel Rodriguez       | Lead Architect & Maintainer | [@yarielre](https://github.com/yarielre) | Platform architecture, development, maintainer|

> For questions, contributions, or partnership inquiries, please contact the lead maintainer via GitHub or Email to [Info](info@wisegar.org)  
