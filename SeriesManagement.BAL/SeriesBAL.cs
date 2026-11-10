
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using SeriesManagement.DAL;

namespace SeriesManagement.BAL
{
    public class SeriesBAL
    {
        private static readonly string[] Formats = { "ODI", "TEST", "T20", "T10" };

        private readonly SeriesDAL dal = new SeriesDAL();
        private readonly ReportDAL reportDal = new ReportDAL();
        private readonly ErrorLogDAL errorDAL = new ErrorLogDAL();

        private void ValidateSeries(SeriesModel model, bool isUpdate)
        {
            if (model == null)
                throw new SeriesValidationException("Series details are required.");

            if (string.IsNullOrWhiteSpace(model.SeriesName))
                throw new SeriesValidationException("Series Name is required.");

            if (model.SeriesName.Trim().Length > 250)
                throw new SeriesValidationException("Series Name cannot exceed 250 characters.");

            if (string.IsNullOrWhiteSpace(model.SeriesType))
                throw new SeriesValidationException("Series Type is required.");

            if (string.IsNullOrWhiteSpace(model.SeriesStatus))
                throw new SeriesValidationException("Series Status is required.");

            if (string.IsNullOrWhiteSpace(model.MatchStatus))
                throw new SeriesValidationException("Match Status is required.");

            if (string.IsNullOrWhiteSpace(model.Gender))
                throw new SeriesValidationException("Gender is required.");

            if (string.IsNullOrWhiteSpace(model.TrophyType))
                throw new SeriesValidationException("Trophy Type is required.");

            int year;
            if (string.IsNullOrWhiteSpace(model.Year) ||
                model.Year.Trim().Length != 4 ||
                !int.TryParse(model.Year.Trim(), out year))
            {
                throw new SeriesValidationException("Year must contain exactly four digits.");
            }

            if (model.SeriesStartDate == DateTime.MinValue ||
                model.SeriesEndDate == DateTime.MinValue)
            {
                throw new SeriesValidationException("Valid start and end dates are required.");
            }

            if (model.SeriesEndDate.Date < model.SeriesStartDate.Date)
                throw new SeriesValidationException("End date cannot be earlier than start date.");

            if (isUpdate && string.IsNullOrWhiteSpace(model.Description))
                throw new SeriesValidationException("Description is required during update.");

            if (model.Description != null && model.Description.Length > 500)
                throw new SeriesValidationException("Description cannot exceed 500 characters.");
        }

        

        // 1. INSERT SERIES
        public int InsertSeries(SeriesModel model)
        {
            try
            {
                ValidateSeries(model, false);

                return dal.InsertSeries(
                    model.SeriesName,
                    model.SeriesType,
                    model.SeriesStatus,
                    model.MatchStatus,
                    model.MatchFormat,
                    model.SeriesMatchType,
                    model.Gender,
                    model.Year,
                    model.TrophyType,
                    model.SeriesStartDate,
                    model.SeriesEndDate,
                    model.IsActive,
                    model.Description
                );
            }
            catch (Exception ex)
            {
                Log(ex, "InsertSeries");
                throw;
            }
        }

        public int UpdateSeries(SeriesModel model)
        {
            try
            {
                if (model == null || model.SeriesId <= 0)
                    throw new SeriesValidationException("Valid Series ID is required.");

                ValidateSeries(model, true);

                return dal.UpdateSeries(
                    model.SeriesId,
                    model.SeriesName,
                    model.SeriesType,
                    model.SeriesStatus,
                    model.MatchStatus,
                    model.MatchFormat,
                    model.SeriesMatchType,
                    model.Gender,
                    model.Year,
                    model.TrophyType,
                    model.SeriesStartDate,
                    model.SeriesEndDate,
                    model.IsActive,
                    model.Description
                );
            }
            catch (Exception ex)
            {
                Log(ex, "UpdateSeries");
                throw;
            }
        }

        // 3. SEARCH SERIES
        public DataTable SearchSeries(SearchModel search)
        {
            try
            {
                if (search == null)
                    search = new SearchModel();

                if (search.StartFrom.HasValue &&
                    search.EndTo.HasValue &&
                    search.StartFrom > search.EndTo)
                {
                    throw new SeriesValidationException("Start date cannot be after end date.");
                }

                return dal.SearchSeries(
                    search.SeriesAPIId,
                    search.SeriesName,
                    search.SeriesType,
                    search.StartFrom,
                    search.EndTo,
                    search.SortBy
                );
            }
            catch (Exception ex)
            {
                Log(ex, "SearchSeries");
                throw;
            }
        }

        public DataTable GetSeriesById(int seriesId)
        {
            try
            {
                if (seriesId <= 0)
                    throw new SeriesValidationException("Invalid Series ID.");

                return dal.GetSeriesById(seriesId);
            }
            catch (Exception ex)
            {
                Log(ex, "GetSeriesById");
                throw;
            }
        }

        public int DeleteSeries(int seriesId)
        {
            try
            {
                if (seriesId <= 0)
                    throw new SeriesValidationException("Invalid Series ID.");

                return dal.DeleteSeries(seriesId);
            }
            catch (Exception ex)
            {
                Log(ex, "DeleteSeries");
                throw;
            }
        }

        public List<string> GetReportYears()
        {
            try
            {
                return reportDal.GetYears();
            }
            catch (Exception ex)
            {
                Log(ex, "GetReportYears");
                throw;
            }
        }

        public FormatReportResult GetFormatReport(IList<string> years)
        {
            try
            {
                if (years == null || years.Count == 0)
                    throw new SeriesValidationException("Select at least one year.");

                var selected = new List<string>();
                foreach (string raw in years)
                {
                    string year = (raw ?? string.Empty).Trim();
                    int parsed;
                    if (year.Length != 4 || !int.TryParse(year, out parsed))
                        throw new SeriesValidationException("Each year must contain exactly four digits.");

                    if (!selected.Contains(year))
                        selected.Add(year);
                }

                DataTable counts = reportDal.GetFormatCounts(string.Join(",", selected));
                var lookup = new Dictionary<string, int>(StringComparer.OrdinalIgnoreCase);

                foreach (DataRow row in counts.Rows)
                {
                    string key = Convert.ToString(row["Year"]) + "|" +
                                 Convert.ToString(row["MatchFormat"]) + "|" +
                                 GenderBucket(Convert.ToString(row["Gender"]));
                    int value = Convert.ToInt32(row["SeriesCount"]);
                    if (lookup.ContainsKey(key))
                        lookup[key] += value;
                    else
                        lookup[key] = value;
                }

                var result = new FormatReportResult
                {
                    Years = selected,
                    Rows = new List<FormatReportRow>()
                };

                var totals = selected.Select(y => new GenderCount()).ToList();

                foreach (string format in Formats)
                {
                    var row = new FormatReportRow
                    {
                        MatchFormat = format,
                        Counts = new List<GenderCount>()
                    };

                    for (int i = 0; i < selected.Count; i++)
                    {
                        var cell = new GenderCount
                        {
                            Men = ReadCount(lookup, selected[i], format, "Men"),
                            Women = ReadCount(lookup, selected[i], format, "Women"),
                            Other = ReadCount(lookup, selected[i], format, "Other")
                        };
                        row.Counts.Add(cell);
                        totals[i].Men += cell.Men;
                        totals[i].Women += cell.Women;
                        totals[i].Other += cell.Other;
                    }

                    result.Rows.Add(row);
                }

                result.Rows.Add(new FormatReportRow
                {
                    MatchFormat = "Total",
                    Counts = totals
                });

                return result;
            }
            catch (Exception ex)
            {
                Log(ex, "GetFormatReport");
                throw;
            }
        }

        private static int ReadCount(Dictionary<string, int> lookup, string year, string format, string gender)
        {
            int value;
            string key = year + "|" + format + "|" + gender;
            return lookup.TryGetValue(key, out value) ? value : 0;
        }

        private static string GenderBucket(string gender)
        {
            string value = (gender ?? string.Empty).Trim().ToLowerInvariant();
            if (value.StartsWith("women") || value == "female")
                return "Women";
            if (value.StartsWith("men") || value == "male")
                return "Men";
            return "Other";
        }

        private void Log(Exception ex, string method)
        {
            try
            {
                errorDAL.LogError(ex.Message, ex.ToString(), "SeriesManagement", method);
            }
            catch
            {
                System.Diagnostics.Trace.TraceError(ex.ToString());
            }
        }
    }
}
