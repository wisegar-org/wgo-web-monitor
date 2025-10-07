using WebsiteMonitorService;
using Wisegar.Toolkit.Services.Email;

var builder = Host.CreateApplicationBuilder(args);

// Configurar el servicio para Windows
builder.Services.AddWindowsService(options =>
{
    options.ServiceName = "Website Monitor Service";
});

// Configurar la configuración
builder.Services.Configure<WebsiteMonitorConfig>(
    builder.Configuration.GetSection(WebsiteMonitorConfig.SectionName));

builder.Services.Configure<EmailSettings>(
    builder.Configuration.GetSection(EmailSettings.SectionName));

// Agregar HttpClient
builder.Services.AddHttpClient();

// Agregar el servicio de email
builder.Services.AddScoped<IEmailService, EmailSmtpService>();

// Agregar el worker
builder.Services.AddHostedService<Worker>();

var host = builder.Build();
host.Run();
