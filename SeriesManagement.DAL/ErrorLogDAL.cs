using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace SeriesManagement.DAL
{
    public class ErrorLogDAL
    {
        private readonly string connectionString =
            ConfigurationManager.ConnectionStrings["SeriesDB"].ConnectionString;

        public void LogError(string message, string stackTrace, string source, string method)
        {
            using (SqlConnection con = new SqlConnection(connectionString))
            using (SqlCommand cmd = new SqlCommand("sp_LogError", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.Add("@ErrorMessage", SqlDbType.NVarChar, -1).Value =
                    (object)message ?? DBNull.Value;
                cmd.Parameters.Add("@StackTrace", SqlDbType.NVarChar, -1).Value =
                    (object)stackTrace ?? DBNull.Value;
                cmd.Parameters.Add("@ErrorSource", SqlDbType.NVarChar, 500).Value =
                    (object)source ?? DBNull.Value;
                cmd.Parameters.Add("@ErrorMethod", SqlDbType.NVarChar, 500).Value =
                    (object)method ?? DBNull.Value;

                con.Open();
                cmd.ExecuteNonQuery();
            }
        }
    }
}
