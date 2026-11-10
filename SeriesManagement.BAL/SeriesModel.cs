using System;

namespace SeriesManagement.BAL
{
    public class SeriesModel
    {
        public int SeriesId { get; set; }
        public int SeriesAPIId { get; set; }

        public string SeriesName { get; set; }
        public string SeriesType { get; set; }
        public string SeriesStatus { get; set; }
        public string MatchStatus { get; set; }

        public string MatchFormat { get; set; }
        public string SeriesMatchType { get; set; }

        public string Gender { get; set; }
        public string Year { get; set; }
        public string TrophyType { get; set; }

        public DateTime SeriesStartDate { get; set; }
        public DateTime SeriesEndDate { get; set; }

        public bool IsActive { get; set; }
        public string Description { get; set; }
    }
}
