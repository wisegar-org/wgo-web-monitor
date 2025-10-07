using Wisegar.Monitor.Services;
using Wisegar.Monitor.Settings;
using Wisegar.Toolkit.Services.Email;

var builder = Host.CreateApplicationBuilder(args);

if (OperatingSystem.IsWindows())
{
    builder.Services.AddWindowsService(options =>
    {
        options.ServiceName = "Website Monitor Service";
    });
}

if (OperatingSystem.IsLinux())
{
    builder.Services.AddSystemd();
}

// Configure application settings
builder.Services.Configure<MonitorSettings>(
    builder.Configuration.GetSection(MonitorSettings.SectionName));

builder.Services.Configure<EmailSettings>(
    builder.Configuration.GetSection(EmailSettings.SectionName));

// Add HttpClient
builder.Services.AddHttpClient();

// Register the email service
builder.Services.AddScoped<IEmailService, EmailSmtpService>();

// Register the background worker
builder.Services.AddHostedService<MonitorServiceWorker>();

var host = builder.Build();

host.Run();
