namespace WebsiteMonitorService;

public class WebsiteMonitorConfig
{
    public const string SectionName = "WebsiteMonitor";
    
    public List<string> Websites { get; set; } = [];
    public int CheckIntervalMinutes { get; set; } = 1;
    public int TimeoutSeconds { get; set; } = 30;
}