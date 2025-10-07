using WebsiteMonitorService;
using Wisegar.Toolkit.Services.Email;

var builder = Host.CreateApplicationBuilder(args);

// Configure the service for Windows
builder.Services.AddWindowsService(options =>
{
    options.ServiceName = "Website Monitor Service";
});

// Configure application settings
builder.Services.Configure<WebsiteMonitorConfig>(
    builder.Configuration.GetSection(WebsiteMonitorConfig.SectionName));

builder.Services.Configure<EmailSettings>(
    builder.Configuration.GetSection(EmailSettings.SectionName));

// Add HttpClient
builder.Services.AddHttpClient();

// Register the email service
builder.Services.AddScoped<IEmailService, EmailSmtpService>();

// Register the background worker
builder.Services.AddHostedService<Worker>();

var host = builder.Build();
host.Run();
