// App_Code/Services/AiValidationService.cs
using System;

namespace SoorGreen.Admin
{
    public class AiValidationService
    {
        public static ReportValidationResult ValidateReport(string wasteType, decimal weight, string location)
        {
            try
            {
                // Simple validation logic (replace with actual API call when ready)
                var result = new ReportValidationResult
                {
                    Status = "ok",
                    Report = new ReportValidationResult.ValidationData
                    {
                        Status = weight > 1000 ? "suspicious" : "valid",
                        Confidence = weight > 1000 ? 0.6 : 0.95,
                        Message = weight > 1000 ?
                            "Weight seems unusually high. Please verify." :
                            "Report appears valid",
                        Warnings = weight > 1000 ?
                            new string[] { "Unusually high weight for " + wasteType } :
                            new string[0],
                        Recommendations = new string[] { "Submit clear photos for better validation" }
                    }
                };

                return result;
            }
            catch (Exception)
            {
                // Return mock validation
                return new ReportValidationResult
                {
                    Status = "ok",
                    Report = new ReportValidationResult.ValidationData
                    {
                        Status = "valid",
                        Confidence = 0.95,
                        Message = "Report validated (Mock)",
                        Warnings = new string[0],
                        Recommendations = new string[0]
                    }
                };
            }
        }
    }
}