using SkiaSharp;
using SnapLearnAPI.Models;
using SnapLearnAPI.Utils;
using Tesseract;
using YoloDotNet;
using YoloDotNet.Enums;
using YoloDotNet.Extensions;
using YoloDotNet.Models;

namespace SnapLearnAPI.Services
{
    public class VisionService
    {
        private readonly Yolo _yolo;
  

        public VisionService(string modelPath = "yolov8m.onnx")
        {
            var exeDirectory = AppContext.BaseDirectory;
            modelPath = Path.Combine(exeDirectory, "ml", modelPath);
            // Initialize YOLO model
            _yolo = new Yolo(new YoloOptions
            {
                OnnxModel = modelPath,
                ImageResize = ImageResize.Proportional,
                Cuda = false,
                //PrimeGpu = true,
                //GpuId = 0,
            });

            Console.WriteLine($"Model Type: {_yolo.ModelInfo}");
        }

        public MemoryStream DetectAndDraw(Stream imageStream)
        {
            // Reset the input stream position
            imageStream.Position = 0;

            using var image = SKBitmap.Decode(imageStream);
            var results = _yolo.RunObjectDetection(image, confidence: Constants.CONFIDENCE_THRESHOLD, iou: 0.7);
            image.Draw(results);

            // Encode the image properly
            using var data = image.Encode(SKEncodedImageFormat.Png, 100);
            var outputStream = new MemoryStream();
            data.SaveTo(outputStream);
            outputStream.Position = 0;

            return outputStream;
        }

        public async Task<List<DetectedObject>> DetectObjectsAsync(Stream imageStream)
        {
            // Run object detection on a background thread
            return await Task.Run(() => DetectObjects(imageStream));
        }

        public List<DetectedObject> DetectObjects(Stream imageStream)
        {

            using var image = SKBitmap.Decode(imageStream);

            var results = _yolo.RunObjectDetection(image, confidence: Constants.CONFIDENCE_THRESHOLD, iou: 0.7);
            // Convert results to ObjectDetection format
            return results.Select(r => new DetectedObject
            {
                Label = r.Label.Name,
                Confidence = r.Confidence,
                X = r.BoundingBox.Left,
                Y = r.BoundingBox.Top,
                ImageWidth = r.BoundingBox.Width,
                ImageHeight = r.BoundingBox.Height,


            }).Cast<DetectedObject>().ToList();
        }

        public async Task<string> ExtractTextAsync(Stream imageStream, string language = "eng")
        {
            // Run OCR on a background thread
            return await Task.Run(() => ExtractText(imageStream, language));
        }

        public string ExtractText(Stream imageStream, string language = "eng")
        {
            try
            {
                imageStream.Position = 0;
                using (var engine = new TesseractEngine(@"./tessdata", language, EngineMode.Default))
                using (var img = Pix.LoadFromMemory(ReadFully(imageStream)))
                using (var page = engine.Process(img))
                {
                    var text = page.GetText();
                    return string.IsNullOrWhiteSpace(text) ? null : text.Trim();
                }
            }
            catch
            {
                return null;
            }
        }

        private static byte[] ReadFully(Stream input)
        {
            using (var ms = new MemoryStream())
            {
                input.CopyTo(ms);
                return ms.ToArray();
            }
        }

    }
}
