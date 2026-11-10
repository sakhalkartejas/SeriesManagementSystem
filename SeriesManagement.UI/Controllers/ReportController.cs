using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Web.Http;
using SeriesManagement.BAL;

namespace SeriesManagement.UI.Controllers
{
    [RoutePrefix("api/report")]
    public class ReportController : ApiController
    {
        private readonly SeriesBAL bal = new SeriesBAL();

        [HttpGet]
        [Route("years")]
        public IHttpActionResult Years()
        {
            try
            {
                return Ok(bal.GetReportYears());
            }
            catch (Exception)
            {
                return Content(HttpStatusCode.InternalServerError, new { Success = false, Message = "Unable to load years." });
            }
        }

        [HttpGet]
        [Route("")]
        public IHttpActionResult Get([FromUri] string years)
        {
            try
            {
                var selected = new List<string>();
                if (!string.IsNullOrWhiteSpace(years))
                {
                    selected.AddRange(
                        years.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries)
                             .Select(y => y.Trim()));
                }

                return Ok(bal.GetFormatReport(selected));
            }
            catch (SeriesValidationException ex)
            {
                return Content(HttpStatusCode.BadRequest, new { Success = false, Message = ex.Message });
            }
            catch (Exception)
            {
                return Content(HttpStatusCode.InternalServerError, new { Success = false, Message = "Unable to build the report." });
            }
        }
    }
}
