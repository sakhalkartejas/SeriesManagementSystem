
using System;

namespace SeriesManagement.BAL
{
    public class SearchModel
    {
        public int? SeriesAPIId { get; set; }

        public string SeriesName { get; set; }

        public string SeriesType { get; set; }

        public DateTime? StartFrom { get; set; }

        public DateTime? EndTo { get; set; }

        public string SortBy { get; set; }
    }
}
