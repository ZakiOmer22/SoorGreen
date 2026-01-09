// App_Code/Services/AiService.cs
using System;
using System.IO;
using System.Text;
using System.Net;
using System.Web.UI.WebControls;
using System.Drawing;
using System.Drawing.Imaging;
using Newtonsoft.Json;

namespace SoorGreen.Admin.Services
{
    public class AiService
    {
        private string _apiBaseUrl = "http://localhost:5000";

        public AiService(string apiUrl)
        {
            _apiBaseUrl = apiUrl;
        }

        public AiService()
        {
            // Get from config if available
            var apiUrl = System.Configuration.ConfigurationManager.AppSettings["AiApiBaseUrl"];
            if (!string.IsNullOrEmpty(apiUrl))
            {
                _apiBaseUrl = apiUrl;
            }
        }

        // Synchronous waste classification
        public string ClassifyWaste(byte[] imageBytes)
        {
            try
            {
                string url = _apiBaseUrl + "/api/classify";
                string boundary = "------------------------" + DateTime.Now.Ticks.ToString("x");
                string contentType = "multipart/form-data; boundary=" + boundary;
                byte[] postData = BuildMultipartFormData(imageBytes, "image", "waste_image.jpg", boundary);

                HttpWebRequest request = (HttpWebRequest)WebRequest.Create(url);
                request.Method = "POST";
                request.ContentType = contentType;
                request.ContentLength = postData.Length;

                using (Stream stream = request.GetRequestStream())
                {
                    stream.Write(postData, 0, postData.Length);
                }

                using (HttpWebResponse response = (HttpWebResponse)request.GetResponse())
                using (StreamReader reader = new StreamReader(response.GetResponseStream()))
                {
                    string json = reader.ReadToEnd();
                    ClassificationResult result = JsonConvert.DeserializeObject<ClassificationResult>(json);
                    if (result != null && !string.IsNullOrEmpty(result.Category))
                        return result.Category;
                    else
                        return "Unknown";
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("AI Service Error: " + ex.Message);
                return "Error";
            }
        }

        // Helper method for C# 5 compatibility
        public string ClassifyWasteSimple(byte[] imageBytes)
        {
            return ClassifyWaste(imageBytes);
        }

        // Multipart form data builder
        private byte[] BuildMultipartFormData(byte[] fileBytes, string paramName, string fileName, string boundary)
        {
            string lineBreak = "\r\n";
            string header = "--" + boundary + lineBreak +
                            "Content-Disposition: form-data; name=\"" + paramName + "\"; filename=\"" + fileName + "\"" + lineBreak +
                            "Content-Type: application/octet-stream" + lineBreak + lineBreak;
            string footer = lineBreak + "--" + boundary + "--" + lineBreak;

            using (MemoryStream ms = new MemoryStream())
            {
                ms.Write(Encoding.UTF8.GetBytes(header), 0, header.Length);
                ms.Write(fileBytes, 0, fileBytes.Length);
                ms.Write(Encoding.UTF8.GetBytes(footer), 0, footer.Length);
                return ms.ToArray();
            }
        }
    }

    // Classification Result Model
    public class ClassificationResult
    {
        public string Category { get; set; }
        public float Confidence { get; set; }
        public string[] Classes { get; set; }
        public float[] Probabilities { get; set; }
    }
}

//public class RouteRequest { public Location[] Locations { get; set; } public VehicleInfo Vehicle { get; set; } public Constraints Constraints { get; set; } }
//    public class Location { public string Id { get; set; } public double Latitude { get; set; } public double Longitude { get; set; } public string Address { get; set; } public int Priority { get; set; } public double WasteVolume { get; set; } }
//    public class VehicleInfo { public string Type { get; set; } public double Capacity { get; set; } public double Speed { get; set; } public string FuelType { get; set; } }
//    public class Constraints { public TimeWindow TimeWindow { get; set; } public bool ConsiderTraffic { get; set; } public bool ConsiderWeather { get; set; } public double MaxRouteDistance { get; set; } public int MaxStops { get; set; } }
//    public class TimeWindow { public DateTime Start { get; set; } public DateTime End { get; set; } }
//    public class RouteOptimizationResult { public Route[] Routes { get; set; } public OptimizationMetrics Metrics { get; set; } public string VisualizationUrl { get; set; } }
//    public class Route { public Location[] Sequence { get; set; } public double TotalDistance { get; set; } public double TotalTime { get; set; } public double TotalWaste { get; set; } public double FuelConsumption { get; set; } public double Cost { get; set; } }
//    public class OptimizationMetrics { public double TotalSavings { get; set; } public double EfficiencyImprovement { get; set; } public double FuelSaved { get; set; } public double TimeSaved { get; set; } }

//    public class HotspotRequest { public string Area { get; set; } public DateTime StartDate { get; set; } public DateTime EndDate { get; set; } public string WasteType { get; set; } }
//    public class HotspotResult { public Hotspot[] Hotspots { get; set; } public HeatmapData Heatmap { get; set; } public Recommendations Recommendations { get; set; } }
//    public class Hotspot { public string Location { get; set; } public double Latitude { get; set; } public double Longitude { get; set; } public string Severity { get; set; } public int ReportsCount { get; set; } public DateTime LastReportDate { get; set; } }
//    public class HeatmapData { public double[][] Coordinates { get; set; } public double[] Intensities { get; set; } public string ImageUrl { get; set; } }
//    public class Recommendations { public string[] ImmediateActions { get; set; } public string[] PreventiveMeasures { get; set; } public ResourceAllocation[] Resources { get; set; } }
//    public class ResourceAllocation { public string ResourceType { get; set; } public int Quantity { get; set; } public string PriorityArea { get; set; } }

//    public class ForecastRequest { public string Area { get; set; } public string WasteType { get; set; } public int ForecastDays { get; set; } public HistoricalData[] History { get; set; } }
//    public class HistoricalData { public DateTime Date { get; set; } public double Amount { get; set; } public string Weather { get; set; } public bool IsHoliday { get; set; } }
//    public class ForecastResult { public ForecastData[] Forecast { get; set; } public TrendAnalysis Trends { get; set; } public Alert[] Alerts { get; set; } public Recommendations Recommendations { get; set; } }
//    public class ForecastData { public DateTime Date { get; set; } public double PredictedAmount { get; set; } public double LowerBound { get; set; } public double UpperBound { get; set; } public double Confidence { get; set; } }
//    public class TrendAnalysis { public string TrendDirection { get; set; } public double TrendStrength { get; set; } public PeakInfo[] Peaks { get; set; } public SeasonalityInfo Seasonality { get; set; } }
//    public class PeakInfo { public DateTime Date { get; set; } public double Value { get; set; } public string Reason { get; set; } }
//    public class SeasonalityInfo { public string Pattern { get; set; } public double Impact { get; set; } public string[] Factors { get; set; } }

//    public class Alert { public string Type { get; set; } public string Message { get; set; } public string Severity { get; set; } public DateTime ExpectedDate { get; set; } public string[] Actions { get; set; } }

//    public class ReportAnalysisRequest { public string ReportId { get; set; } public string ReportType { get; set; } public string Content { get; set; } public Attachment[] Attachments { get; set; } public Metadata Metadata { get; set; } }
//    public class Attachment { public string Type { get; set; } public string Url { get; set; } public byte[] Data { get; set; } }
//    public class Metadata { public string ReporterId { get; set; } public string Location { get; set; } public DateTime ReportDate { get; set; } public string[] Tags { get; set; } }

//    public class ReportAnalysisResult { public AnalysisSummary Summary { get; set; } public SentimentAnalysis Sentiment { get; set; } public Issue[] Issues { get; set; } public string[] Keywords { get; set; } public Category[] Categories { get; set; } public string Priority { get; set; } public ValidationResult Validation { get; set; } public ActionItem[] ActionItems { get; set; } }
//    public class AnalysisSummary { public string MainTopic { get; set; } public string[] KeyPoints { get; set; } public double UrgencyScore { get; set; } public double CompletenessScore { get; set; } }
//    public class SentimentAnalysis { public string OverallSentiment { get; set; } public double SentimentScore { get; set; } public Emotion[] Emotions { get; set; } }
//    public class Emotion { public string Type { get; set; } public double Intensity { get; set; } }
//    public class Issue { public string Description { get; set; } public string Type { get; set; } public string Severity { get; set; } public string Location { get; set; } public string[] Evidence { get; set; } }
//    public class Category { public string Name { get; set; } public double Confidence { get; set; } public string[] Subcategories { get; set; } }
//    public class ValidationResult { public bool IsValid { get; set; } public string[] IssuesFound { get; set; } public Suggestion[] Suggestions { get; set; } public double Confidence { get; set; } }
//    public class Suggestion { public string Field { get; set; } public string Message { get; set; } public string Recommendation { get; set; } }
//    public class ActionItem { public string Action { get; set; } public string Responsible { get; set; } public DateTime Deadline { get; set; } public string Priority { get; set; } }
//}
