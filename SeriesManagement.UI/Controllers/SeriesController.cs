using System;
using System.Data;
using System.Net;
using System.Web;
using SeriesManagement.BAL;
using SeriesManagement.UI.Helpers;
using System.Web.Http;

namespace SeriesManagement.UI.Controllers
{
    public class SeriesRow : SeriesModel
    {
        public string EditUrl { get; set; }
    }

    [RoutePrefix("api/series")]
    public class SeriesController : ApiController
    {
        private readonly SeriesBAL bal = new SeriesBAL();

        [HttpGet]
        [Route("")]
        public IHttpActionResult Search([FromUri] SearchModel search)
        {
            try
            {
                if (search == null)
                    search = new SearchModel();

                DataTable result = bal.SearchSeries(search);
                var seriesList = new System.Collections.Generic.List<SeriesRow>();

                foreach (DataRow row in result.Rows)
                {
                    SeriesRow item = Map(row);
                    item.EditUrl = BuildEditUrl(item.SeriesId);
                    seriesList.Add(item);
                }

                return Ok(seriesList);
            }
            catch (SeriesValidationException ex)
            {
                return Content(HttpStatusCode.BadRequest, new { Success = false, Message = ex.Message });
            }
            catch (Exception)
            {
                return Content(HttpStatusCode.InternalServerError, new { Success = false, Message = "Unable to search series." });
            }
        }

        [HttpGet]
        [Route("{id:int}")]
        public IHttpActionResult Get(int id)
        {
            try
            {
                if (id <= 0)
                    return BadRequest("Invalid Series ID.");

                DataTable result = bal.GetSeriesById(id);

                if (result == null || result.Rows.Count == 0)
                    return NotFound();

                return Ok(Map(result.Rows[0]));
            }
            catch (SeriesValidationException ex)
            {
                return Content(HttpStatusCode.BadRequest, new { Success = false, Message = ex.Message });
            }
            catch (Exception)
            {
                return Content(HttpStatusCode.InternalServerError, new { Success = false, Message = "Unable to fetch series." });
            }
        }

        [HttpPost]
        [Route("")]
        public IHttpActionResult Insert(SeriesModel model)
        {
            try
            {
                if (model == null)
                    return BadRequest("Series details are required.");

                int result = bal.InsertSeries(model);

                if (result <= 0)
                    return BadRequest("Series could not be inserted.");

                return Ok(new
                {
                    Success = true,
                    Message = "Series added successfully.",
                    SeriesId = result
                });
            }
            catch (SeriesValidationException ex)
            {
                return Content(HttpStatusCode.BadRequest, new { Success = false, Message = ex.Message });
            }
            catch (Exception)
            {
                return Content(HttpStatusCode.InternalServerError, new { Success = false, Message = "Unable to save series." });
            }
        }

        [HttpPut]
        [Route("{id:int}")]
        public IHttpActionResult Update(int id, SeriesModel model)
        {
            try
            {
                if (id <= 0)
                    return BadRequest("Invalid Series ID.");

                if (model == null)
                    return BadRequest("Series details are required.");

                model.SeriesId = id;

                int result = bal.UpdateSeries(model);

                if (result <= 0)
                    return NotFound();

                return Ok(new
                {
                    Success = true,
                    Message = "Series updated successfully."
                });
            }
            catch (SeriesValidationException ex)
            {
                return Content(HttpStatusCode.BadRequest, new { Success = false, Message = ex.Message });
            }
            catch (Exception)
            {
                return Content(HttpStatusCode.InternalServerError, new { Success = false, Message = "Unable to update series." });
            }
        }

        [HttpDelete]
        [Route("{id:int}")]
        public IHttpActionResult Delete(int id)
        {
            try
            {
                if (id <= 0)
                    return BadRequest("Invalid Series ID.");

                int result = bal.DeleteSeries(id);

                if (result <= 0)
                    return NotFound();

                return Ok(new
                {
                    Success = true,
                    Message = "Series deleted successfully."
                });
            }
            catch (SeriesValidationException ex)
            {
                return Content(HttpStatusCode.BadRequest, new { Success = false, Message = ex.Message });
            }
            catch (Exception)
            {
                return Content(HttpStatusCode.InternalServerError, new { Success = false, Message = "Unable to delete series." });
            }
        }

        private static SeriesRow Map(DataRow row)
        {
            return new SeriesRow
            {
                SeriesId = Convert.ToInt32(row["SeriesId"]),
                SeriesAPIId = row["SeriesAPIId"] == DBNull.Value ? 0 : Convert.ToInt32(row["SeriesAPIId"]),
                SeriesName = Text(row, "SeriesName"),
                SeriesType = Text(row, "SeriesType"),
                SeriesStatus = Text(row, "SeriesStatus"),
                MatchStatus = Text(row, "MatchStatus"),
                MatchFormat = Text(row, "MatchFormat"),
                SeriesMatchType = Text(row, "SeriesMatchType"),
                Gender = Text(row, "Gender"),
                Year = Text(row, "Year"),
                TrophyType = Text(row, "TrophyType"),
                SeriesStartDate = Convert.ToDateTime(row["SeriesStartDate"]),
                SeriesEndDate = Convert.ToDateTime(row["SeriesEndDate"]),
                IsActive = row["IsActive"] != DBNull.Value && Convert.ToBoolean(row["IsActive"]),
                Description = Text(row, "Description")
            };
        }

        private static string Text(DataRow row, string column)
        {
            if (!row.Table.Columns.Contains(column) || row[column] == DBNull.Value)
                return string.Empty;

            return Convert.ToString(row[column]);
        }

        private static string BuildEditUrl(int seriesId)
        {
            string token = QueryHelper.Encrypt("Mode=E&Sid=" + seriesId);
            string page = VirtualPathUtility.ToAbsolute("~/AddSeries.aspx");
            return page + "?data=" + token;
        }
    }
}
