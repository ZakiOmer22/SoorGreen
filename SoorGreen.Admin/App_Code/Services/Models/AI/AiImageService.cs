// App_Code/Services/AiImageService.cs
using System;
using System.Threading.Tasks;

namespace SoorGreen.Admin
{
    public class AiImageService
    {
        public static async Task<ImageClassificationResult> ClassifyWasteImage(byte[] imageBytes, string fileName)
        {
            try
            {
                // Mock implementation (replace with actual API call)
                await Task.Delay(100); // Simulate API call

                return new ImageClassificationResult
                {
                    Status = "ok",
                    Result = new ImageClassificationResult.ResultData
                    {
                        Status = "success",
                        Detections = new System.Collections.Generic.List<ImageClassificationResult.Detection>
                        {
                            new ImageClassificationResult.Detection { Class = "plastic", Confidence = 0.85 },
                            new ImageClassificationResult.Detection { Class = "metal", Confidence = 0.65 }
                        }
                    }
                };
            }
            catch (Exception)
            {
                // Return mock data
                return new ImageClassificationResult
                {
                    Status = "ok",
                    Result = new ImageClassificationResult.ResultData
                    {
                        Status = "success",
                        Detections = new System.Collections.Generic.List<ImageClassificationResult.Detection>
                        {
                            new ImageClassificationResult.Detection { Class = "plastic", Confidence = 0.85 },
                            new ImageClassificationResult.Detection { Class = "metal", Confidence = 0.65 }
                        }
                    }
                };
            }
        }
    }
}