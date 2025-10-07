using Microsoft.Extensions.Options;
using Wisegar.Toolkit.Services.Email;

namespace WebsiteMonitorService;

public class Worker : BackgroundService
{
    private readonly ILogger<Worker> _logger;
    private readonly WebsiteMonitorConfig _config;
    private readonly HttpClient _httpClient;
    private readonly IServiceProvider _serviceProvider;

    public Worker(ILogger<Worker> logger, IOptions<WebsiteMonitorConfig> config, HttpClient httpClient, IServiceProvider serviceProvider)
    {
        _logger = logger;
        _config = config.Value;
        _httpClient = httpClient;
        _serviceProvider = serviceProvider;
        _httpClient.Timeout = TimeSpan.FromSeconds(_config.TimeoutSeconds);
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation("Website Monitor Service started. Monitoring {count} websites every {interval} minutes.",
            _config.Websites.Count, _config.CheckIntervalMinutes);

        // Send complex test email at startup
        await SendComplexEmailTest();

        while (!stoppingToken.IsCancellationRequested)
        {
            await CheckWebsites();
            await Task.Delay(TimeSpan.FromMinutes(_config.CheckIntervalMinutes), stoppingToken);
        }
    }

    private async Task CheckWebsites()
    {
        foreach (var website in _config.Websites)
        {
            await CheckWebsite(website);
        }
    }

    private async Task CheckWebsite(string url)
    {
        var timestamp = DateTime.Now;

        try
        {
            var response = await _httpClient.GetAsync(url);
            var statusCode = (int)response.StatusCode;
            var isOnline = response.IsSuccessStatusCode;

            var status = isOnline ? "ONLINE" : "OFFLINE";

            _logger.LogInformation("Site: {url} | Status Code: {statusCode} | Status: {status} | Time: {timestamp:yyyy-MM-dd HH:mm:ss}",
                url, statusCode, status, timestamp);

            // Write to the specific log file
            await WriteToLogFile(url, statusCode, status, timestamp);

            // If it is not status 200, send error email
            if (statusCode != 200)
            {
                _logger.LogError("ERROR LOG: Web {url} returned status code {statusCode} (it's not 200)", url, statusCode);
                await SendErrorEmail(url, statusCode, status);
            }
            else
            {
                // TEMPORARY: Send success email to ALL sites that are working properly
                await SendSuccessEmail(url, statusCode, status);
            }
        }
        catch (HttpRequestException ex)
        {
            _logger.LogError("Error connecting to {url}: {error} | Hour: {timestamp:yyyy-MM-dd HH:mm:ss}",
                url, ex.Message, timestamp);

            await WriteToLogFile(url, 0, "ERROR", timestamp, ex.Message);
            await SendErrorEmail(url, 0, "ERROR", ex.Message);
        }
        catch (TaskCanceledException ex) when (ex.InnerException is TimeoutException)
        {
            _logger.LogWarning("Timeout when connecting with {url} | Hour: {timestamp:yyyy-MM-dd HH:mm:ss}",
                url, timestamp);

            await WriteToLogFile(url, 0, "TIMEOUT", timestamp, "Request timeout");
            await SendErrorEmail(url, 0, "TIMEOUT", "Request timeout");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Unexpected error while checking {url} | Hour: {timestamp:yyyy-MM-dd HH:mm:ss}",
                url, timestamp);

            await WriteToLogFile(url, 0, "ERROR", timestamp, ex.Message);
            await SendErrorEmail(url, 0, "ERROR", ex.Message);
        }
    }

    private async Task WriteToLogFile(string url, int statusCode, string status, DateTime timestamp, string? errorMessage = null)
    {
        try
        {
            var logDirectory = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "Logs");
            Directory.CreateDirectory(logDirectory);

            var logFileName = $"website-monitor-{timestamp:yyyy-MM-dd}.log";
            var logFilePath = Path.Combine(logDirectory, logFileName);

            var logEntry = errorMessage != null
                ? $"{timestamp:yyyy-MM-dd HH:mm:ss} | {url} | Status Code: {statusCode} | Status: {status} | Error: {errorMessage}{Environment.NewLine}"
                : $"{timestamp:yyyy-MM-dd HH:mm:ss} | {url} | Status Code: {statusCode} | Status: {status}{Environment.NewLine}";

            await File.AppendAllTextAsync(logFilePath, logEntry);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error writing to log file");
        }
    }

    private async Task SendErrorEmail(string url, int statusCode, string status, string? errorMessage = null)
    {
        try
        {
            using var scope = _serviceProvider.CreateScope();
            var emailService = scope.ServiceProvider.GetRequiredService<IEmailService>();
            await emailService.SendErrorNotificationAsync(url, statusCode, status, errorMessage);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error sending notification email for {url}", url);
        }
    }

    private async Task SendSuccessEmail(string url, int statusCode, string status)
    {
        try
        {
            using var scope = _serviceProvider.CreateScope();
            var emailService = scope.ServiceProvider.GetRequiredService<IEmailService>();

            // Test simple email
            await emailService.SendEmailAsync(
                to: "yariel.re@gmail.com",
                subject: "✅ SUCCESS: Website Working Correctly",
                body: $@"
                <html>
                <body style='font-family: Arial, sans-serif;'>
                    <h2 style='color: #28a745;'>✅ Website Up and Running</h2>
                    <div style='background-color: #d4edda; padding: 15px; border-radius: 5px; border-left: 4px solid #28a745;'>
                        <p><strong>Website:</strong> <a href='{url}'>{url}</a></p>
                        <p><strong>Status Code:</strong> {statusCode}</p>
                        <p><strong>Status:</strong> <span style='color: #28a745; font-weight: bold;'>{status}</span></p>
                        <p><strong>Date and Time:</strong> {DateTime.Now:yyyy-MM-dd HH:mm:ss}</p>
                    </div>
                    <p style='font-size: 12px; color: #666;'>
                        This message was automatically generated by the Website Monitor Service.
                    </p>
                </body>
                </html>",
                isHtml: true
            );

            _logger.LogInformation("Success email sent to {url}", url);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error sending success email for {url}", url);
        }
    }

    private async Task SendComplexEmailTest()
    {
        try
        {
            using var scope = _serviceProvider.CreateScope();
            var emailService = scope.ServiceProvider.GetRequiredService<IEmailService>();

            // Create a complex test email
            var emailMessage = new EmailMessage
            {
                To = new List<string> { "hurshelann30@gmail.com" },
                Subject = "🧪 Complex Email Test - Monitor Service",
                Body = @"
                <html>
                <body style='font-family: Arial, sans-serif; line-height: 1.6; color: #333;'>
                    <div style='max-width: 600px; margin: 0 auto; padding: 20px;'>
                        <div style='background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0;'>
                            <h1 style='margin: 0; font-size: 28px;'>🧪 Complex Email Test</h1>
                        </div>
                        <div style='background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px;'>
                            <h2 style='color: #667eea;'>Tested Features:</h2>
                            <ul>
                                <li>✅ HTML Email with Styles</li>
                                <li>✅ High priority</li>
                                <li>✅ Custom headers</li>
                                <li>✅ Generic email service</li>
                            </ul>
                            
                            <div style='background: white; padding: 20px; border-radius: 5px; margin: 20px 0; border-left: 4px solid #28a745;'>
                                <h3 style='margin-top: 0; color: #28a745;'>System Status:</h3>
                                <p>All services working correctly</p>
                                <p><strong>Timestamp:</strong> " + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss") + @"</p>
                            </div>
                        </div>
                    </div>
                </body>
                </html>",
                IsHtml = true,
                Priority = EmailPriority.High,
                CustomHeaders = new Dictionary<string, string>
                {
                    { "X-Test-Type", "Complex-Email-Test" },
                    { "X-Service", "Website-Monitor" }
                }
            };

            await emailService.SendEmailAsync(emailMessage);
            _logger.LogInformation("Complex test email sent successfully");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error sending complex test email");
        }
    }
}
