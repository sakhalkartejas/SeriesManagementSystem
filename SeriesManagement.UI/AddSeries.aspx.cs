
using System;
using System.Web;
using System.Web.UI;
using SeriesManagement.UI.Helpers;

namespace SeriesManagement.UI
{
    public partial class AddSeries : Page
    {
        public string PageMode { get; private set; } = "A";

        public int EditSeriesId { get; private set; } = 0;

        protected void Page_Init(object sender, EventArgs e)
        {
            string token = Request.QueryString["data"];

            // ADD MODE
            if (string.IsNullOrWhiteSpace(token))
            {
                PageMode = "A";
                EditSeriesId = 0;
                return;
            }

            // EDIT MODE
            try
            {
                string queryData = QueryHelper.Decrypt(token);

                var values =
                    HttpUtility.ParseQueryString(queryData);

                string mode = values["Mode"];
                string sid = values["Sid"];

                if (string.Equals(mode, "A", StringComparison.OrdinalIgnoreCase))
                {
                    PageMode = "A";
                    EditSeriesId = 0;
                    return;
                }

                int seriesId;

                if (mode != "E" ||
                    !int.TryParse(sid, out seriesId) ||
                    seriesId <= 0)
                {
                    throw new Exception("Invalid edit request.");
                }

                PageMode = "E";
                EditSeriesId = seriesId;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError(
                    "AddSeries Page_Init: " + ex
                );

                Response.Redirect(
                    "ManageSeries.aspx?Error=InvalidRequest",
                    false
                );

                Context.ApplicationInstance.CompleteRequest();
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (PageMode == "A")
                {
                    // Prepare Add Series form
                }
                else if (PageMode == "E")
                {
                    // Load existing Series details
                    LoadSeriesDetails();
                }
            }
        }

        private void LoadSeriesDetails()
        {
            // We will implement database binding
            // after checking your BAL and ASPX controls.
        }
    }
}
