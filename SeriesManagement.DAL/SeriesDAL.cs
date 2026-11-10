using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace SeriesManagement.DAL
{
    public class SeriesDAL
    {
        private readonly string connectionString =
            ConfigurationManager.ConnectionStrings["SeriesDB"].ConnectionString;

        public int InsertSeries(
            string seriesName, string seriesType,
            string seriesStatus, string matchStatus, string matchFormat,
            string seriesMatchType, string gender, string year,
            string trophyType, DateTime startDate, DateTime endDate,
            bool isActive, string description)
        {
            using (SqlConnection con = new SqlConnection(connectionString))
            using (SqlCommand cmd = new SqlCommand("prdTbLSeriesInsert", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.Add("@SeriesName", SqlDbType.NVarChar, 250).Value = seriesName;
                cmd.Parameters.Add("@SeriesType", SqlDbType.NVarChar, 20).Value = seriesType;
                cmd.Parameters.Add("@SeriesStatus", SqlDbType.NVarChar, 20).Value = seriesStatus;
                cmd.Parameters.Add("@MatchStatus", SqlDbType.NVarChar, 20).Value = matchStatus;
                cmd.Parameters.Add("@MatchFormat", SqlDbType.VarChar, 20).Value = DbValue(matchFormat);
                cmd.Parameters.Add("@SeriesMatchType", SqlDbType.NVarChar, 60).Value = DbValue(seriesMatchType);
                cmd.Parameters.Add("@Gender", SqlDbType.NVarChar, 20).Value = gender;
                cmd.Parameters.Add("@Year", SqlDbType.VarChar, 4).Value = year;
                cmd.Parameters.Add("@TrophyType", SqlDbType.NVarChar, 100).Value = trophyType;
                cmd.Parameters.Add("@SeriesStartDate", SqlDbType.Date).Value = startDate.Date;
                cmd.Parameters.Add("@SeriesEndDate", SqlDbType.Date).Value = endDate.Date;
                cmd.Parameters.Add("@IsActive", SqlDbType.Bit).Value = isActive;
                cmd.Parameters.Add("@Description", SqlDbType.NVarChar, 500).Value = DbValue(description);

                con.Open();
                return ReadInt(cmd.ExecuteScalar());
            }
        }

        public int UpdateSeries(
            int seriesId, string seriesName,
            string seriesType, string seriesStatus, string matchStatus,
            string matchFormat, string seriesMatchType, string gender,
            string year, string trophyType, DateTime startDate,
            DateTime endDate, bool isActive, string description)
        {
            using (SqlConnection con = new SqlConnection(connectionString))
            using (SqlCommand cmd = new SqlCommand("prcTblSeriesUpdate", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.Add("@SeriesId", SqlDbType.Int).Value = seriesId;
                cmd.Parameters.Add("@SeriesName", SqlDbType.NVarChar, 250).Value = seriesName;
                cmd.Parameters.Add("@SeriesType", SqlDbType.NVarChar, 20).Value = seriesType;
                cmd.Parameters.Add("@SeriesStatus", SqlDbType.NVarChar, 20).Value = seriesStatus;
                cmd.Parameters.Add("@MatchStatus", SqlDbType.NVarChar, 20).Value = matchStatus;
                cmd.Parameters.Add("@MatchFormat", SqlDbType.VarChar, 20).Value = DbValue(matchFormat);
                cmd.Parameters.Add("@SeriesMatchType", SqlDbType.NVarChar, 60).Value = DbValue(seriesMatchType);
                cmd.Parameters.Add("@Gender", SqlDbType.NVarChar, 20).Value = gender;
                cmd.Parameters.Add("@Year", SqlDbType.VarChar, 4).Value = year;
                cmd.Parameters.Add("@TrophyType", SqlDbType.NVarChar, 100).Value = trophyType;
                cmd.Parameters.Add("@SeriesStartDate", SqlDbType.Date).Value = startDate.Date;
                cmd.Parameters.Add("@SeriesEndDate", SqlDbType.Date).Value = endDate.Date;
                cmd.Parameters.Add("@IsActive", SqlDbType.Bit).Value = isActive;
                cmd.Parameters.Add("@Description", SqlDbType.NVarChar, 500).Value = DbValue(description);

                con.Open();
                return ReadInt(cmd.ExecuteScalar());
            }
        }

        public DataTable SearchSeries(
            int? seriesAPIId, string seriesName,
            string seriesType, DateTime? startFrom,
            DateTime? endTo, string sortBy)
        {
            DataTable dt = new DataTable();

            using (SqlConnection con = new SqlConnection(connectionString))
            using (SqlCommand cmd = new SqlCommand("prcTblSeriesSearch", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.Add("@SeriesAPIId", SqlDbType.Int).Value =
                    seriesAPIId.HasValue ? (object)seriesAPIId.Value : DBNull.Value;

                cmd.Parameters.Add("@SeriesName", SqlDbType.NVarChar, 250).Value = DbValue(seriesName);
                cmd.Parameters.Add("@SeriesType", SqlDbType.NVarChar, 20).Value = DbValue(seriesType);
                cmd.Parameters.Add("@StartFrom", SqlDbType.Date).Value =
                    startFrom.HasValue ? (object)startFrom.Value.Date : DBNull.Value;
                cmd.Parameters.Add("@EndTo", SqlDbType.Date).Value =
                    endTo.HasValue ? (object)endTo.Value.Date : DBNull.Value;

                string direction = string.Equals(sortBy, "DESC", StringComparison.OrdinalIgnoreCase)
                    ? "DESC"
                    : "ASC";
                cmd.Parameters.Add("@SortBy", SqlDbType.VarChar, 4).Value = direction;

                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                {
                    da.Fill(dt);
                }
            }

            return dt;
        }

        public DataTable GetSeriesById(int seriesId)
        {
            DataTable dt = new DataTable();

            using (SqlConnection con = new SqlConnection(connectionString))
            using (SqlCommand cmd = new SqlCommand("prcTblSeriesGetById", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add("@SeriesId", SqlDbType.Int).Value = seriesId;

                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                {
                    da.Fill(dt);
                }
            }

            return dt;
        }

        public int DeleteSeries(int seriesId)
        {
            using (SqlConnection con = new SqlConnection(connectionString))
            using (SqlCommand cmd = new SqlCommand("prcTblSeriesDelete", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add("@SeriesId", SqlDbType.Int).Value = seriesId;

                con.Open();
                return ReadInt(cmd.ExecuteScalar());
            }
        }

        private static object DbValue(string value)
        {
            return string.IsNullOrWhiteSpace(value)
                ? (object)DBNull.Value
                : value.Trim();
        }

        private static int ReadInt(object value)
        {
            if (value == null || value == DBNull.Value)
                return 0;

            return Convert.ToInt32(value);
        }
    }
}
