<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Report.aspx.cs" Inherits="SeriesManagement.UI.SeriesReport" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Series Report</title>
    <link href="Content/bootstrap.min.css" rel="stylesheet" />
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
</head>
<body>
    <div class="container py-4">
        <div class="d-flex justify-content-between align-items-center mb-3">
            <h2>Series Report</h2>
            <a href="ManageSeries.aspx" class="btn btn-outline-secondary">Back to Manage Series</a>
        </div>

        <div class="card p-3 mb-3">
            <label for="ddlYears" class="form-label">Select Year(s) (Ctrl + click to select multiple)</label>
            <select id="ddlYears" multiple class="form-select" size="6"></select>
            <div class="mt-3">
                <button type="button" id="btnGenerate" class="btn btn-primary">Generate Report</button>
                <button type="button" id="btnSelectAll" class="btn btn-outline-primary">Select All Years</button>
            </div>
            <div id="reportMessage" class="mt-2"></div>
        </div>

        <div id="reportArea" class="table-responsive"></div>
    </div>

<script>
    var reportApi = '<%= ResolveUrl("~/api/report") %>';

    $(function () {
        loadYears();

        $("#btnSelectAll").on("click", function () {
            $("#ddlYears option").prop("selected", true);
        });

        $("#btnGenerate").on("click", function () {
            var years = $("#ddlYears").val() || [];
            if (!years.length) {
                $("#reportMessage").html("<div class='alert alert-warning'>Select at least one year.</div>");
                return;
            }

            $("#reportMessage").html("<div class='text-muted'>Generating report...</div>");
            $.ajax({
                url: reportApi,
                type: "GET",
                data: { years: years.join(",") },
                dataType: "json",
                success: renderReport,
                error: function (xhr) {
                    var msg = "Unable to generate report (HTTP " + xhr.status + ").";
                    try {
                        if (xhr.responseJSON && xhr.responseJSON.Message) msg = xhr.responseJSON.Message;
                    } catch (e) { }
                    $("#reportMessage").html("<div class='alert alert-danger'>" + escapeHtml(msg) + "</div>");
                    $("#reportArea").empty();
                }
            });
        });
    });

    function loadYears() {
        $.ajax({
            url: reportApi + "/years",
            type: "GET",
            dataType: "json",
            success: function (years) {
                var $ddl = $("#ddlYears").empty();
                $.each(years, function (_, year) {
                    $("<option>").val(year).text(year).appendTo($ddl);
                });
                if (years.length) $("#ddlYears option:last").prop("selected", true);
                if (!years.length) $("#reportMessage").html("<div class='alert alert-info'>No years found in the database.</div>");
            },
            error: function (xhr) {
                $("#reportMessage").html("<div class='alert alert-danger'>Could not load years. HTTP " + xhr.status + "</div>");
            }
        });
    }

    function renderReport(result) {
        if (!result || !result.Years || !result.Rows) {
            $("#reportMessage").html("<div class='alert alert-warning'>No report data returned.</div>");
            return;
        }

        var html = "<table class='table table-bordered table-striped align-middle'><thead class='table-dark'><tr><th rowspan='2'>Match Format</th>";
        $.each(result.Years, function (_, year) {
            html += "<th colspan='3' class='text-center'>" + escapeHtml(year) + "</th>";
        });
        html += "</tr><tr>";
        $.each(result.Years, function () {
            html += "<th>Men</th><th>Women</th><th>Other</th>";
        });
        html += "</tr></thead><tbody>";

        $.each(result.Rows, function (_, row) {
            var total = String(row.MatchFormat).toLowerCase() === "total";
            html += "<tr" + (total ? " class='table-warning fw-bold'" : "") + "><th>" + escapeHtml(row.MatchFormat) + "</th>";
            $.each(row.Counts || [], function (_, counts) {
                html += "<td>" + numberValue(counts.Men) + "</td>";
                html += "<td>" + numberValue(counts.Women) + "</td>";
                html += "<td>" + numberValue(counts.Other) + "</td>";
            });
            html += "</tr>";
        });

        html += "</tbody></table>";
        $("#reportArea").html(html);
        $("#reportMessage").html("<div class='alert alert-success'>Report generated successfully.</div>");
    }

    function numberValue(value) {
        return value == null ? 0 : value;
    }

    function escapeHtml(value) {
        return $("<div>").text(value == null ? "" : value).html();
    }
</script>
</body>
</html>
