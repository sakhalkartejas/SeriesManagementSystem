<%@ Page Language="C#" AutoEventWireup="true"
    CodeBehind="ManageSeries.aspx.cs"
    Inherits="SeriesManagement.UI.ManageSeries" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>Manage Series</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
          rel="stylesheet" />

    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
</head>

<body>
<form id="form1" runat="server">

<div class="container mt-4">

    <h2 class="mb-4">Manage Series</h2>

    <div class="mb-3 d-flex gap-2">
        <a href="<%= AddSeriesUrl %>" class="btn btn-primary">
            Add New Series
        </a>
        <a href="Report.aspx" class="btn btn-outline-primary">
            Year / Gender Report
        </a>
        <a href="Default.aspx" class="btn btn-outline-secondary">
            Cancel
        </a>
    </div>

    <!-- Search Filters -->
    <div class="card p-3 mb-4">
        <h5>Search Series</h5>

        <div class="row g-3">

            <div class="col-md-3">
                <label>Series API ID</label>
                <input type="number" id="txtSearchAPIId"
                       class="form-control" />
            </div>

            <div class="col-md-3">
                <label>Series Name</label>
                <input type="text" id="txtSearchName"
                       class="form-control" />
            </div>

            <div class="col-md-3">
                <label>Series Type</label>
                <select id="ddlSearchType" class="form-select">
                    <option value="">All</option>
                    <option>International</option>
                    <option>Domestic</option>
                    <option>Women</option>
                    <option>Mens</option>
                </select>
            </div>

            <div class="col-md-3">
                <label>Start From Date</label>
                <input type="date" id="txtStartFrom"
                       class="form-control" />
            </div>

            <div class="col-md-3">
                <label>End To Date</label>
                <input type="date" id="txtEndTo"
                       class="form-control" />
            </div>

            <div class="col-md-3">
                <label>Sort By</label>
                <select id="ddlSortBy" class="form-select">
                    <option value="ASC">Start Date Ascending</option>
                    <option value="DESC">Start Date Descending</option>
                </select>
            </div>

            <div class="col-md-6 d-flex align-items-end gap-2">
                <button type="button" id="btnSearch"
                        class="btn btn-success">
                    Search
                </button>

                <button type="button" id="btnRefresh"
                        class="btn btn-secondary">
                    Refresh
                </button>
            </div>

        </div>
    </div>

    <!-- Series Table -->
    <div class="table-responsive">
        <table class="table table-bordered table-striped">
            <thead class="table-dark">
                <tr>
                    <th>Series ID</th>
                    <th>API ID</th>
                    <th>Series Name</th>
                    <th>Series Type</th>
                    <th>Status</th>
                    <th>Gender</th>
                    <th>Year</th>
                    <th>Start Date</th>
                    <th>End Date</th>
                    <th>Action</th>
                </tr>
            </thead>

            <tbody id="tblSeriesBody">
                <tr>
                    <td colspan="10" class="text-center">
                        Loading series...
                    </td>
                </tr>
            </tbody>
        </table>
    </div>

    <div id="message" class="mt-3"></div>

</div>

</form>

<script>
    var apiUrl = '<%= ResolveUrl("~/api/series") %>';

    $(document).ready(function () {
        loadSeries();

        $("#btnSearch").click(function () {
            loadSeries();
        });

        $("#btnRefresh").click(function () {
            $("#txtSearchAPIId, #txtSearchName, #txtStartFrom, #txtEndTo")
                .val("");

            $("#ddlSearchType").val("");
            $("#ddlSortBy").val("ASC");

            loadSeries();
        });
    });


    function loadSeries() {

        var searchData = {
            SeriesAPIId: $("#txtSearchAPIId").val(),
            SeriesName: $("#txtSearchName").val(),
            SeriesType: $("#ddlSearchType").val(),
            StartFrom: $("#txtStartFrom").val(),
            EndTo: $("#txtEndTo").val(),
            SortBy: $("#ddlSortBy").val()
        };

        $.ajax({
            url: apiUrl,
            type: "GET",
            data: searchData,
            dataType: "json",

            success: function (data) {
                displaySeries(data);
            },

            error: function (xhr) {

                console.log("Status:", xhr.status);
                console.log("Error:", xhr.responseText);

                $("#tblSeriesBody").html(
                    '<tr><td colspan="10" class="text-danger text-center">' +
                    'Unable to load series. HTTP Status: ' + xhr.status +
                    '</td></tr>'
                );
            }
        });
    }


    function displaySeries(data) {

        var html = "";

        if (!data || data.length === 0) {
            html = '<tr><td colspan="10" class="text-center">' +
                'No series records found.</td></tr>';
        }
        else {
            $.each(data, function (i, item) {

                html += "<tr>";
                html += "<td>" + item.SeriesId + "</td>";
                html += "<td>" + item.SeriesAPIId + "</td>";
                html += '<td><a href="' + item.EditUrl + '">' + escapeHtml(item.SeriesName) + '</a></td>';
                html += "<td>" + escapeHtml(item.SeriesType) + "</td>";
                html += "<td>" + escapeHtml(item.SeriesStatus) + "</td>";
                html += "<td>" + escapeHtml(item.Gender) + "</td>";
                html += "<td>" + escapeHtml(item.Year) + "</td>";
                html += "<td>" + formatDate(item.SeriesStartDate) + "</td>";
                html += "<td>" + formatDate(item.SeriesEndDate) + "</td>";

                html += '<td><button type="button" class="btn btn-sm btn-danger" ' +
                    'onclick="deleteSeries(' + item.SeriesId + ')">Delete</button></td>';

                html += "</tr>";
            });
        }

        $("#tblSeriesBody").html(html);
    }

    function escapeHtml(value) {
        return $("<div>").text(value == null ? "" : value).html();
    }

    function formatDate(value) {
        if (!value) return "";

        var date = new Date(value);

        if (isNaN(date.getTime())) return value;

        return date.toLocaleDateString();
    }

    function deleteSeries(id) {
        if (!confirm("Are you sure you want to delete this series?"))
            return;

        $.ajax({
            url: apiUrl + "/" + id,
            type: "DELETE",

            success: function () {
                alert("Series deleted successfully.");
                loadSeries();
            },

            error: function (xhr) {
                alert("Unable to delete series.");
                console.log(xhr.responseText);
            }
        });
    }
</script>

</body>
</html>