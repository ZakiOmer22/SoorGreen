// App_Code/Services/AiApiClient.cs
using System;
using System.IO;
using System.Net;
using System.Text;
using System.Threading.Tasks;
using Newtonsoft.Json;

namespace SoorGreen.Admin
{
    public class AiApiClient
    {
        private static string _baseUrl = "http://127.0.0.1:5000/api/ai";

        static AiApiClient()
        {
            // Get base URL from config
            var configUrl = System.Configuration.ConfigurationManager.AppSettings["AI_ENGINE_URL"];
            if (!string.IsNullOrEmpty(configUrl))
            {
                _baseUrl = configUrl;
            }
        }

        public static async Task<T> PostAsync<T>(string endpoint, object data)
        {
            try
            {
                string url = _baseUrl + endpoint;
                string json = JsonConvert.SerializeObject(data);

                using (var client = new WebClient())
                {
                    client.Headers[HttpRequestHeader.ContentType] = "application/json";
                    client.Headers[HttpRequestHeader.Accept] = "application/json";

                    string responseContent = await client.UploadStringTaskAsync(url, "POST", json);
                    return JsonConvert.DeserializeObject<T>(responseContent);
                }
            }
            catch (Exception ex)
            {
                // Log error - C# 6 compatible
                System.Diagnostics.Debug.WriteLine("AI API Error (" + endpoint + "): " + ex.Message);
                throw;
            }
        }

        public static T Post<T>(string endpoint, object data)
        {
            return PostAsync<T>(endpoint, data).GetAwaiter().GetResult();
        }

        // For file uploads (image classification)
        public static async Task<T> UploadFileAsync<T>(string endpoint, byte[] fileBytes, string fileName)
        {
            try
            {
                string url = _baseUrl + endpoint;

                using (var client = new WebClient())
                {
                    // Create boundary for multipart form data
                    string boundary = "---------------------------" + DateTime.Now.Ticks.ToString("x");
                    client.Headers[HttpRequestHeader.ContentType] = "multipart/form-data; boundary=" + boundary;

                    // Build multipart form data
                    using (var stream = new MemoryStream())
                    {
                        byte[] boundaryBytes = Encoding.ASCII.GetBytes("\r\n--" + boundary + "\r\n");

                        // Add file part
                        string header = string.Format(
                            "Content-Disposition: form-data; name=\"image\"; filename=\"{0}\"\r\n" +
                            "Content-Type: application/octet-stream\r\n\r\n",
                            fileName);
                        byte[] headerBytes = Encoding.UTF8.GetBytes(header);

                        stream.Write(boundaryBytes, 0, boundaryBytes.Length);
                        stream.Write(headerBytes, 0, headerBytes.Length);
                        stream.Write(fileBytes, 0, fileBytes.Length);

                        // Add closing boundary
                        byte[] closingBoundary = Encoding.ASCII.GetBytes("\r\n--" + boundary + "--\r\n");
                        stream.Write(closingBoundary, 0, closingBoundary.Length);

                        // Upload
                        byte[] responseBytes = await client.UploadDataTaskAsync(url, "POST", stream.ToArray());
                        string responseContent = Encoding.UTF8.GetString(responseBytes);
                        return JsonConvert.DeserializeObject<T>(responseContent);
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("AI Upload Error (" + endpoint + "): " + ex.Message);
                throw;
            }
        }
    }
}