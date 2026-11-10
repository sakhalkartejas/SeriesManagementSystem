
using System;
using System.Text;
using System.Web;
using System.Web.Security;

namespace SeriesManagement.UI.Helpers
{
    public static class QueryHelper
    {
        private static readonly string Purpose =
            "SeriesManagement.Edit";

        public static string Encrypt(string value)
        {
            byte[] data = Encoding.UTF8.GetBytes(value);

            byte[] encrypted =
                MachineKey.Protect(data, Purpose);

            return HttpServerUtility.UrlTokenEncode(encrypted);
        }

        public static string Decrypt(string token)
        {
            if (string.IsNullOrWhiteSpace(token))
                throw new Exception("Encrypted token is missing.");

            byte[] encrypted =
                HttpServerUtility.UrlTokenDecode(token);

            if (encrypted == null)
                throw new Exception("Invalid encrypted token.");

            byte[] data =
                MachineKey.Unprotect(encrypted, Purpose);

            if (data == null)
                throw new Exception("Invalid or expired token.");

            return Encoding.UTF8.GetString(data);
        }
    }
}
