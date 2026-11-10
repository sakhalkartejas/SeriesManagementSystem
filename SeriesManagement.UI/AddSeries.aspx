
<%@ Page Language="C#" AutoEventWireup="true"
    CodeBehind="AddSeries.aspx.cs"
    Inherits="SeriesManagement.UI.AddSeries" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>Add / Update Series</title>

    <meta name="viewport" content="width=device-width, initial-scale=1" />

    <link href="Content/bootstrap.min.css" rel="stylesheet" />

    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
</head>

<body>

    <div class="container mt-4 mb-5">

        <h2 id="pageTitle">Add Series</h2>
        <hr />

        <input type="hidden" id="hdnMode"
               value="<%= PageMode %>" />

        <input type="hidden" id="hdnSeriesId"
               value="<%= EditSeriesId %>" />

        <div class="row">

            <%--<!-- Series API ID -->
            <div class="col-md-6 mb-3">
                <label>Series API ID</label>
                <input type="text" id="txtSeriesAPIId"
                       class="form-control" readonly />
            </div>

            <!-- Series ID -->
            <div class="col-md-6 mb-3">
                <label>Series ID</label>
                <input type="text" id="txtSeriesId"
                       class="form-control" readonly />
            </div>--%>

            <!-- Series Name -->
            <div class="col-md-6 mb-3">
                <label>Series Name *</label>
                <input type="text" id="txtSeriesName"
                       class="form-control" maxlength="250" />
            </div>

            <!-- Series Type -->
            <div class="col-md-6 mb-3">
                <label>Series Type *</label>
                <select id="ddlSeriesType" class="form-control">
                    <option value="">-- Select Series Type --</option>
                    <option value="International">International</option>
                    <option value="Domestic">Domestic</option>
                    <option value="Women">Women</option>
                    <option value="Mens">Mens</option>
                </select>
            </div>

            <!-- Series Status -->
            <div class="col-md-6 mb-3">
                <label>Series Status *</label>
                <select id="ddlSeriesStatus" class="form-control">
                    <option value="">-- Select Status --</option>
                    <option value="Scheduled">Scheduled</option>
                    <option value="Completed">Completed</option>
                    <option value="Live">Live</option>
                    <option value="Abandon">Abandon</option>
                </select>
            </div>

            <!-- Match Status -->
            <div class="col-md-6 mb-3">
                <label>Match Status *</label>
                <select id="ddlMatchStatus" class="form-control">
                    <option value="">-- Select Match Status --</option>
                    <option value="Scheduled">Scheduled</option>
                    <option value="Completed">Completed</option>
                    <option value="Live">Live</option>
                    <option value="Abandon">Abandon</option>
                </select>
            </div>

            <!-- Match Format -->
            <div class="col-md-6 mb-3">
                <label>Match Format</label>
                <select id="ddlMatchFormat" class="form-control">
                    <option value="">-- Select Format --</option>
                    <option value="ODI">ODI</option>
                    <option value="TEST">TEST</option>
                    <option value="T20">T20</option>
                    <option value="T10">T10</option>
                </select>
            </div>

            <!-- Series Match Type -->
            <div class="col-md-6 mb-3">
                <label>Series Match Type</label>
                <select id="ddlSeriesMatchType" class="form-control">
                    <option value="">-- Select Match Type --</option>
                    <option value="ODI">ODI</option>
                    <option value="TEST">TEST</option>
                    <option value="T20I">T20I</option>
                    <option value="LIST A">LIST A</option>
                    <option value="T20(Domestic)">T20(Domestic)</option>
                    <option value="First class">First class</option>
                </select>
            </div>

            <!-- Gender -->
            <div class="col-md-6 mb-3">
                <label>Gender *</label>
                <select id="ddlGender" class="form-control">
                    <option value="">-- Select Gender --</option>
                    <option value="Mens">Mens</option>
                    <option value="Womens">Womens</option>
                    <option value="Other">Other</option>
                </select>
            </div>

            <!-- Year -->
            <div class="col-md-6 mb-3">
                <label>Year *</label>
                <input type="text" id="txtYear"
                       class="form-control"
                       maxlength="4"
                       inputmode="numeric" />
            </div>

            <!-- Trophy Type -->
            <div class="col-md-6 mb-3">
                <label>Trophy Type *</label>
                <select id="ddlTrophyType" class="form-control">
                    <option value="">-- Select Trophy --</option>
                    <option value="Asia Cup">Asia Cup</option>
                    <option value="ICC World Cup T20">
                        ICC World Cup T20
                    </option>
                </select>
            </div>

            <!-- Start Date -->
            <div class="col-md-6 mb-3">
                <label>Series Start Date *</label>
                <input type="date" id="txtStartDate"
                       class="form-control" />
            </div>

            <!-- End Date -->
            <div class="col-md-6 mb-3">
                <label>Series End Date *</label>
                <input type="date" id="txtEndDate"
                       class="form-control" />
            </div>

            <!-- Is Active -->
            <div class="col-md-6 mb-3">
                <label>Is Active *</label>
                <select id="ddlIsActive" class="form-control">
                    <option value="">-- Select Status --</option>
                    <option value="true">Yes</option>
                    <option value="false">No</option>
                </select>
            </div>

            <!-- Description -->
            <div class="col-md-12 mb-3">
                <label>Description</label>
                <textarea id="txtDescription"
                          class="form-control"
                          rows="4"
                          maxlength="500"></textarea>
            </div>

        </div>

        <!-- Buttons -->
        <div class="mb-3">

            <button type="button"
                    id="btnSave"
                    class="btn btn-primary">
                Save
            </button>

            <button type="button"
                    id="btnRefresh"
                    class="btn btn-secondary">
                Refresh
            </button>

            <button type="button"
                    id="btnCancel"
                    class="btn btn-danger">
                Cancel
            </button>

        </div>

        <div id="message" role="status"
             aria-live="polite"></div>

    </div>

    <script type="text/javascript">

        var apiUrl = '<%= ResolveUrl("~/api/series") %>';

        // PAGE LOAD
        $(document).ready(function () {

            var mode = $("#hdnMode").val();

            if (mode === "E") {

                $("#pageTitle").text("Update Series");
                $("#btnSave").text("Update");
                $("#apiIdContainer, #seriesIdContainer").show();

                $("#txtDescription").prop("required", true);

                loadSeries();
            }
            else {

                $("#pageTitle").text("Add Series");

                $("#txtSeriesAPIId").val("");
                $("#txtSeriesId").val("");
            }

            $("#btnSave").on("click", saveSeries);
            $("#btnRefresh").on("click", refreshForm);
            $("#btnCancel").on("click", cancelForm);

        });


        // LOAD EXISTING SERIES
        function loadSeries() {

            var id = $("#hdnSeriesId").val();

            if (!id || parseInt(id) <= 0) {
                showMessage("Invalid Series ID.", false);
                return;
            }

            $("#btnSave").prop("disabled", true);

            $.ajax({

                url: apiUrl + "/" + encodeURIComponent(id),
                type: "GET",
                dataType: "json",

                success: function (data) {

                    var item = Array.isArray(data) ? data[0] : data;

                    if (!item) {
                        showMessage("Series not found.", false);
                        return;
                    }

                    $("#txtSeriesId").val(item.SeriesId);
                    $("#txtSeriesAPIId").val(item.SeriesAPIId);

                    $("#txtSeriesName").val(item.SeriesName);
                    $("#ddlSeriesType").val(item.SeriesType);
                    $("#ddlSeriesStatus").val(item.SeriesStatus);
                    $("#ddlMatchStatus").val(item.MatchStatus);
                    $("#ddlMatchFormat").val(item.MatchFormat);
                    $("#ddlSeriesMatchType").val(item.SeriesMatchType);
                    $("#ddlGender").val(item.Gender);
                    $("#txtYear").val(item.Year);
                    $("#ddlTrophyType").val(item.TrophyType);

                    $("#txtStartDate").val(
                        formatDate(item.SeriesStartDate)
                    );

                    $("#txtEndDate").val(
                        formatDate(item.SeriesEndDate)
                    );

                    $("#ddlIsActive").val(
                        String(item.IsActive).toLowerCase()
                    );

                    $("#txtDescription").val(item.Description);

                    showMessage("Series details loaded successfully.", true);
                },

                error: function (xhr) {

                    showMessage(
                        "Unable to load series details.",
                        false
                    );

                },

                complete: function () {
                    $("#btnSave").prop("disabled", false);
                }

            });

        }


        // DATE FORMAT
        function formatDate(value) {

            if (!value) return "";

            var date = new Date(value);

            if (isNaN(date.getTime())) return "";

            var year = date.getFullYear();
            var month = String(date.getMonth() + 1).padStart(2, "0");
            var day = String(date.getDate()).padStart(2, "0");

            return year + "-" + month + "-" + day;
        }


        // VALIDATION
        function validateForm() {

            var mode = $("#hdnMode").val();

            if (!$("#txtSeriesName").val().trim()) {
                showMessage("Series Name is required.", false);
                return false;
            }

            if (!$("#ddlSeriesType").val()) {
                showMessage("Select Series Type.", false);
                return false;
            }

            if (!$("#ddlSeriesStatus").val()) {
                showMessage("Select Series Status.", false);
                return false;
            }

            if (!$("#ddlMatchStatus").val()) {
                showMessage("Select Match Status.", false);
                return false;
            }

            if (!$("#ddlGender").val()) {
                showMessage("Select Gender.", false);
                return false;
            }

            var year = $("#txtYear").val().trim();

            if (!/^\d{4}$/.test(year)) {
                showMessage("Year must contain exactly four digits.", false);
                return false;
            }

            if (!$("#ddlTrophyType").val()) {
                showMessage("Select Trophy Type.", false);
                return false;
            }

            if (!$("#txtStartDate").val()) {
                showMessage("Start Date is required.", false);
                return false;
            }

            if (!$("#txtEndDate").val()) {
                showMessage("End Date is required.", false);
                return false;
            }

            if ($("#txtEndDate").val() < $("#txtStartDate").val()) {
                showMessage(
                    "End Date cannot be earlier than Start Date.",
                    false
                );
                return false;
            }

            if (!$("#ddlIsActive").val()) {
                showMessage("Select Is Active.", false);
                return false;
            }

            if (mode === "E" &&
                !$("#txtDescription").val().trim()) {

                showMessage(
                    "Description is required during update.",
                    false
                );

                return false;
            }

            if ($("#txtDescription").val().length > 500) {
                showMessage(
                    "Description cannot exceed 500 characters.",
                    false
                );
                return false;
            }

            return true;
        }


        // SAVE / UPDATE SERIES
        function saveSeries() {

            if (!validateForm()) {
                return;
            }

            var mode = $("#hdnMode").val();

            var model = {

                SeriesAPIId:
                    parseInt($("#txtSeriesAPIId").val()) || 0,

                SeriesName:
                    $("#txtSeriesName").val().trim(),

                SeriesType:
                    $("#ddlSeriesType").val(),

                SeriesStatus:
                    $("#ddlSeriesStatus").val(),

                MatchStatus:
                    $("#ddlMatchStatus").val(),

                MatchFormat:
                    $("#ddlMatchFormat").val(),

                SeriesMatchType:
                    $("#ddlSeriesMatchType").val(),

                Gender:
                    $("#ddlGender").val(),

                Year:
                    $("#txtYear").val().trim(),

                TrophyType:
                    $("#ddlTrophyType").val(),

                SeriesStartDate:
                    $("#txtStartDate").val(),

                SeriesEndDate:
                    $("#txtEndDate").val(),

                IsActive:
                    $("#ddlIsActive").val() === "true",

                Description:
                    $("#txtDescription").val().trim()
            };

            var requestType = "POST";
            var requestUrl = apiUrl;

            if (mode === "E") {

                model.SeriesId =
                    parseInt($("#hdnSeriesId").val());

                requestType = "PUT";

                requestUrl += "/" +
                    encodeURIComponent(model.SeriesId);
            }

            $("#btnSave").prop("disabled", true);

            $.ajax({

                url: requestUrl,

                type: requestType,

                contentType: "application/json; charset=utf-8",

                data: JSON.stringify(model),

                success: function (response) {

                    showMessage(
                        response.Message ||
                        "Operation completed successfully.",
                        true
                    );

                    setTimeout(function () {
                        window.location.href = "ManageSeries.aspx";
                    }, 1000);

                },

                error: function (xhr) {

                    var message = "Unable to save series.";

                    if (xhr.responseJSON &&
                        xhr.responseJSON.Message) {

                        message = xhr.responseJSON.Message;
                    }

                    showMessage(message, false);

                },

                complete: function () {
                    $("#btnSave").prop("disabled", false);
                }

            });

        }


        // REFRESH FORM
        function refreshForm() {

            if ($("#hdnMode").val() === "E") {

                $("#message").empty();

                loadSeries();

            }
            else {

                $(".container input, .container select, .container textarea")
                    .not("#hdnMode, #hdnSeriesId")
                    .val("");

                $("#message").empty();
            }

        }


        // CANCEL
        function cancelForm() {

            window.location.href = "ManageSeries.aspx";

        }


        // MESSAGE
        function showMessage(message, success) {

            $("#message")
                .removeClass("text-success text-danger")
                .addClass(success ? "text-success" : "text-danger")
                .text(message);

        }

    </script>

</body>
</html>
