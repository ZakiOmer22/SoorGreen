// App_Code/Models/ImageClassificationResult.cs
using System.Collections.Generic;

namespace SoorGreen.Admin
{
    public class ImageClassificationResult
    {
        public string Status { get; set; }
        public ResultData Result { get; set; }

        public class ResultData
        {
            public List<Detection> Detections { get; set; }
            public string Status { get; set; }
        }

        public class Detection
        {
            public string Class { get; set; }
            public double Confidence { get; set; }
        }
    }
}