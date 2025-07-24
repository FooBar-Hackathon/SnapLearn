using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace SnapLearnAPI.Models
{
    public class Summary
    {
        [Key]
        public Guid Id { get; set; }
        [ForeignKey("Object")]
        public Guid ObjectId { get; set; }
        public string Content { get; set; }
        // Navigation property
        public DetectedObject Object { get; set; }
    }
} 