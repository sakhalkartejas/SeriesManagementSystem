using System;
using System.Web.UI;
using SeriesManagement.UI.Helpers;

namespace SeriesManagement.UI
{
    public partial class ManageSeries : Page
    {
        public string AddSeriesUrl { get; private set; }

        protected void Page_Load(object sender, EventArgs e)
        {
            AddSeriesUrl = ResolveUrl("~/AddSeries.aspx?data=" + QueryHelper.Encrypt("Mode=A"));
        }
    }
}
