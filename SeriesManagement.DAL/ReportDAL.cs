using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace SeriesManagement.DAL
{
    public class ReportDAL
    {
        private readonly string connectionString =
            ConfigurationManager.ConnectionStrings["SeriesDB"].ConnectionString;

        public List<string> GetYears()
        {
            var years = new List<string>();

            using (SqlConnection con = new SqlConnection(connectionString))
            using (SqlCommand cmd = new SqlCommand("prcSeriesYears", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                con.Open();

                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        years.Add(Convert.ToString(reader["Year"]));
                    }
                }
            }

            return years;
        }

        public DataTable GetFormatCounts(string yearsCsv)
        {
            DataTable dt = new DataTable();

            using (SqlConnection con = new SqlConnection(connectionString))
            using (SqlCommand cmd = new SqlCommand("prcSeriesFormatReport", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add("@Years", SqlDbType.NVarChar, 400).Value =
                    string.IsNullOrWhiteSpace(yearsCsv) ? (object)DBNull.Value : yearsCsv;

                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                {
                    da.Fill(dt);
                }
            }

            return dt;
        }
    }
}
