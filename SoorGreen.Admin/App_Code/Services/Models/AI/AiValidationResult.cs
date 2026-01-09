namespace SoorGreen.Admin.Models.AI
{
    public class ReportValidationResult
    {
        public string Status { get; set; }
        public ValidationData Report { get; set; }

        public class ValidationData
        {
            public string Status { get; set; }
            public double Confidence { get; set; }
            public string Message { get; set; }
            public string[] Warnings { get; set; }
            public string[] Recommendations { get; set; }
        }
    }
}