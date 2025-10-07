namespace Wisegar.Monitor.Settings;

public class MonitorSettings
{
    public const string SectionName = "Monitor";

    public List<string> Websites { get; set; } = [];
    public int CheckIntervalMinutes { get; set; } = 1;
    public int TimeoutSeconds { get; set; } = 30;
}