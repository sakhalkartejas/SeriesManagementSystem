SERIES MANAGEMENT - UPDATED PROJECT
===================================

I reviewed your uploaded SeriesManagement.zip and updated the existing project source:
- Manage Series now opens encrypted Edit mode by clicking the Series Name.
- Add Series link uses encrypted Mode=A token.
- Series ID and Series API ID are displayed read-only in Update mode.
- Report.aspx now contains a Year multi-select report UI using AJAX.
- Report.aspx.cs is added to the UI project compilation.
- BAL logs validation exceptions to the ErrorLog stored procedure.
- Database upgrade script included for old schema/string truncation.

IMPORTANT: I cannot execute/build classic ASP.NET Web Forms (.NET Framework 4.8) in this environment.
You must run this in Visual Studio on Windows and verify locally. No claim of successful compile/runtime is made.

RUN STEPS
---------
1. Extract this ZIP.
2. Open SeriesManagement.slnx (or open SeriesManagement.UI.csproj in Visual Studio).
3. Restore NuGet packages if Visual Studio prompts.
4. Back up SeriesManagementDB first.
5. In SQL Server Management Studio, run Database/SeriesManagement.sql.
   This creates missing DB/table/procedures, but does not drop your existing data.
6. If the table already existed with SeriesType length 10, run Database/Upgrade_ExistingDatabase.sql.
7. Check SeriesManagement.UI/Web.config connection string:
   Data Source=DESKTOP-J13ISE9\\SQLEXPRESS; Initial Catalog=SeriesManagementDB; Integrated Security=True.
   Change the SQL Server instance if it differs on your machine.
8. Build Solution (Ctrl+Shift+B).
9. Set SeriesManagement.UI as startup project.
10. Run (F5). Try:
    - ManageSeries.aspx
    - Add Series
    - Click Series Name to edit
    - Search, refresh, delete
    - Report.aspx

API endpoints
-------------
GET    /api/series
GET    /api/series/{id}
POST   /api/series
PUT    /api/series/{id}
DELETE /api/series/{id}
GET    /api/report/years
GET    /api/report?years=2025,2026

If Visual Studio reports an error:
- Capture the FIRST error in Error List (not all cascading errors).
- Send the error text or screenshot and I can fix it.

NOTE:
The sample test rows from earlier can have arbitrary/legacy values. For real records,
choose Match Status and Trophy Type explicitly from the Add/Update form.
