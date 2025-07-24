using System.ComponentModel.DataAnnotations;
using System.Collections.Generic;

namespace SnapLearnAPI.Models
{
    public class DetectedObject
    {
        [Key]
        public Guid Id { get; set; }
        public string Label { get; set; }
        public string ImagePath { get; set; }
        public int ImageWidth { get; set; }
        public int ImageHeight { get; set; }
        public double Confidence { get; set; }
        public float X { get; set; }
        public float Y { get; set; }
        // Navigation properties
        public ICollection<Player> Players { get; set; }
        public ICollection<Summary> Summaries { get; set; }
        public ICollection<QA> QAs { get; set; }
    }
} 