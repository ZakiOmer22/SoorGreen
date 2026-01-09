// App_Code/Models/ReportAnalysisResult.cs
namespace SoorGreen.Admin
{
    public class ReportAnalysisResult
    {
        public string Status { get; set; }
        public AnalysisData Report { get; set; }

        public class AnalysisData
        {
            public string Status { get; set; }
            public double Confidence { get; set; }
            public string Message { get; set; }
            public string RiskLevel { get; set; }
            public double TrustScore { get; set; }
        }
    }
}