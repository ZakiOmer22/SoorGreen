// App_Code/Helpers/AiHelper.cs - FIXED
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Web.UI.WebControls;

namespace SoorGreen.Admin.Helpers
{
    public static class AiHelper
    {
        // Image processing helper
        public static byte[] ProcessImageForAI(FileUpload fileUpload)
        {
            if (!fileUpload.HasFile)
                return null;

            var file = fileUpload.PostedFile;

            // Check file size
            var maxSize = ConfigurationManager.AppSettings["AiMaxFileSize"] ?? "10485760";
            if (file.ContentLength > Convert.ToInt32(maxSize))
                throw new Exception("File size too large. Maximum 10MB allowed.");

            // Check file type
            var allowedExtensions = new[] { ".jpg", ".jpeg", ".png", ".gif", ".bmp" };
            var extension = Path.GetExtension(file.FileName).ToLower();

            // Manual check for C# 5
            bool isValidExtension = false;
            foreach (var ext in allowedExtensions)
            {
                if (ext == extension)
                {
                    isValidExtension = true;
                    break;
                }
            }

            if (!isValidExtension)
                throw new Exception("Invalid file type. Allowed: JPG, PNG, GIF, BMP");

            // Resize image if needed and convert to byte array
            using (System.Drawing.Image image = System.Drawing.Image.FromStream(file.InputStream))
            {
                // Resize if image is too large
                var maxDimension = 1024;
                System.Drawing.Image resizedImage = image;
                if (image.Width > maxDimension || image.Height > maxDimension)
                {
                    resizedImage = ResizeImage(image, maxDimension);
                }

                using (var ms = new MemoryStream())
                {
                    // Save as JPEG for consistency
                    var encoder = GetEncoder(ImageFormat.Jpeg);
                    var encoderParams = new EncoderParameters(1);
                    encoderParams.Param[0] = new EncoderParameter(Encoder.Quality, 85L); // 85% quality

                    resizedImage.Save(ms, encoder, encoderParams);

                    // Dispose resized image if different from original
                    if (resizedImage != image)
                        resizedImage.Dispose();

                    return ms.ToArray();
                }
            }
        }

        private static System.Drawing.Image ResizeImage(System.Drawing.Image image, int maxDimension)
        {
            int newWidth, newHeight;

            if (image.Width > image.Height)
            {
                newWidth = maxDimension;
                newHeight = (int)((float)image.Height / image.Width * maxDimension);
            }
            else
            {
                newHeight = maxDimension;
                newWidth = (int)((float)image.Width / image.Height * maxDimension);
            }

            var destRect = new Rectangle(0, 0, newWidth, newHeight);
            var destImage = new Bitmap(newWidth, newHeight);

            destImage.SetResolution(image.HorizontalResolution, image.VerticalResolution);

            using (var graphics = Graphics.FromImage(destImage))
            {
                graphics.CompositingMode = System.Drawing.Drawing2D.CompositingMode.SourceCopy;
                graphics.CompositingQuality = System.Drawing.Drawing2D.CompositingQuality.HighQuality;
                graphics.InterpolationMode = System.Drawing.Drawing2D.InterpolationMode.HighQualityBicubic;
                graphics.SmoothingMode = System.Drawing.Drawing2D.SmoothingMode.HighQuality;
                graphics.PixelOffsetMode = System.Drawing.Drawing2D.PixelOffsetMode.HighQuality;

                using (var wrapMode = new ImageAttributes())
                {
                    wrapMode.SetWrapMode(System.Drawing.Drawing2D.WrapMode.TileFlipXY);
                    graphics.DrawImage(image, destRect, 0, 0, image.Width, image.Height, GraphicsUnit.Pixel, wrapMode);
                }
            }

            return destImage;
        }

        private static ImageCodecInfo GetEncoder(ImageFormat format)
        {
            var codecs = ImageCodecInfo.GetImageDecoders();
            foreach (var codec in codecs)
            {
                if (codec.FormatID == format.Guid)
                {
                    return codec;
                }
            }
            return null;
        }

        // Waste type mapping
        public static string MapWasteCategoryToType(string aiCategory)
        {
            var mapping = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
            mapping.Add("plastic", "Recyclable");
            mapping.Add("paper", "Recyclable");
            mapping.Add("glass", "Recyclable");
            mapping.Add("metal", "Recyclable");
            mapping.Add("organic", "Biodegradable");
            mapping.Add("food", "Biodegradable");
            mapping.Add("hazardous", "Hazardous");
            mapping.Add("medical", "Hazardous");
            mapping.Add("electronic", "E-Waste");
            mapping.Add("construction", "Construction");
            mapping.Add("mixed", "Mixed");
            mapping.Add("other", "General");

            var lowerCategory = aiCategory.ToLower();
            if (mapping.ContainsKey(lowerCategory))
            {
                return mapping[lowerCategory];
            }
            return "General";
        }

        // Convert image to base64 for display
        public static string ImageToBase64(byte[] imageBytes)
        {
            if (imageBytes == null || imageBytes.Length == 0)
                return string.Empty;

            return "data:image/jpeg;base64," + Convert.ToBase64String(imageBytes);
        }
    }
}