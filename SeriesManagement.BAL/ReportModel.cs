using System.Collections.Generic;

namespace SeriesManagement.BAL
{
    public class GenderCount
    {
        public int Men { get; set; }
        public int Women { get; set; }
        public int Other { get; set; }
    }

    public class FormatReportRow
    {
        public string MatchFormat { get; set; }
        public List<GenderCount> Counts { get; set; }
    }

    public class FormatReportResult
    {
        public List<string> Years { get; set; }
        public List<FormatReportRow> Rows { get; set; }
    }
}
