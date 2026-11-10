/*
    Series Management database script.
    Core procedures required by the specification:
      prdTbLSeriesInsert, prcTblSeriesUpdate, prcTblSeriesSearch
    Supporting procedures for delete, fetch-by-id, error log, and the year report.
*/
USE master;
GO

IF DB_ID(N'SeriesManagementDB') IS NULL
BEGIN
    CREATE DATABASE SeriesManagementDB;
END
GO

USE SeriesManagementDB;
GO

IF OBJECT_ID(N'dbo.Seq_SeriesAPI', N'SO') IS NULL
BEGIN
    CREATE SEQUENCE dbo.Seq_SeriesAPI
        AS INT
        START WITH 1001
        INCREMENT BY 1;
END
GO

IF OBJECT_ID(N'dbo.tbl_Series', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.tbl_Series
    (
        SeriesId        INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_tbl_Series PRIMARY KEY,
        SeriesAPIId     INT NOT NULL CONSTRAINT DF_tbl_Series_SeriesAPIId DEFAULT (NEXT VALUE FOR dbo.Seq_SeriesAPI),
        SeriesName      NVARCHAR(250) NOT NULL,
        SeriesType      NVARCHAR(20) NOT NULL,
        SeriesStatus    NVARCHAR(20) NOT NULL,
        MatchStatus     NVARCHAR(20) NOT NULL,
        MatchFormat     VARCHAR(20) NULL,
        SeriesMatchType NVARCHAR(60) NULL,
        Gender          NVARCHAR(20) NOT NULL,
        [Year]          VARCHAR(4) NOT NULL,
        TrophyType      NVARCHAR(100) NOT NULL,
        SeriesStartDate DATE NOT NULL,
        SeriesEndDate   DATE NOT NULL,
        IsActive        BIT NOT NULL CONSTRAINT DF_tbl_Series_IsActive DEFAULT (1),
        [Description]   NVARCHAR(500) NULL,
        IsDeleted       BIT NOT NULL CONSTRAINT DF_tbl_Series_IsDeleted DEFAULT (0),
        CreatedDate     DATETIME NOT NULL CONSTRAINT DF_tbl_Series_CreatedDate DEFAULT (GETDATE()),
        ModifiedDate    DATETIME NULL,
        CONSTRAINT CK_tbl_Series_Dates CHECK (SeriesEndDate >= SeriesStartDate),
        CONSTRAINT CK_tbl_Series_Year CHECK ([Year] LIKE '[0-9][0-9][0-9][0-9]')
    );
END
GO

IF COL_LENGTH(N'dbo.tbl_Series', N'IsDeleted') IS NULL
BEGIN
    ALTER TABLE dbo.tbl_Series
        ADD IsDeleted BIT NOT NULL CONSTRAINT DF_tbl_Series_IsDeleted DEFAULT (0);
END
GO

IF OBJECT_ID(N'dbo.ErrorLog', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.ErrorLog
    (
        LogId         INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_ErrorLog PRIMARY KEY,
        ErrorMessage  NVARCHAR(MAX) NULL,
        ErrorSource   NVARCHAR(500) NULL,
        ErrorMethod   NVARCHAR(500) NULL,
        StackTrace    NVARCHAR(MAX) NULL,
        CreatedDate   DATETIME NOT NULL CONSTRAINT DF_ErrorLog_CreatedDate DEFAULT (GETDATE())
    );
END
GO

/* Earlier test rows were truncated because the insert parameter was NVARCHAR(10). */
UPDATE dbo.tbl_Series
SET SeriesType = N'International'
WHERE SeriesType = N'Internatio';
GO

CREATE OR ALTER PROCEDURE dbo.prdTbLSeriesInsert
    @SeriesName       NVARCHAR(250),
    @SeriesType       NVARCHAR(20),
    @SeriesStatus     NVARCHAR(20),
    @MatchStatus      NVARCHAR(20),
    @MatchFormat      VARCHAR(20) = NULL,
    @SeriesMatchType  NVARCHAR(60) = NULL,
    @Gender           NVARCHAR(20),
    @Year             VARCHAR(4),
    @TrophyType       NVARCHAR(100),
    @SeriesStartDate  DATE,
    @SeriesEndDate    DATE,
    @IsActive         BIT,
    @Description      NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.tbl_Series
    (
        SeriesName, SeriesType, SeriesStatus, MatchStatus, MatchFormat,
        SeriesMatchType, Gender, [Year], TrophyType, SeriesStartDate,
        SeriesEndDate, IsActive, [Description]
    )
    VALUES
    (
        @SeriesName, @SeriesType, @SeriesStatus, @MatchStatus, @MatchFormat,
        @SeriesMatchType, @Gender, @Year, @TrophyType, @SeriesStartDate,
        @SeriesEndDate, @IsActive, @Description
    );

    SELECT CAST(SCOPE_IDENTITY() AS INT) AS SeriesId;
END
GO

CREATE OR ALTER PROCEDURE dbo.prcTblSeriesUpdate
    @SeriesId         INT,
    @SeriesName       NVARCHAR(250),
    @SeriesType       NVARCHAR(20),
    @SeriesStatus     NVARCHAR(20),
    @MatchStatus      NVARCHAR(20),
    @MatchFormat      VARCHAR(20) = NULL,
    @SeriesMatchType  NVARCHAR(60) = NULL,
    @Gender           NVARCHAR(20),
    @Year             VARCHAR(4),
    @TrophyType       NVARCHAR(100),
    @SeriesStartDate  DATE,
    @SeriesEndDate    DATE,
    @IsActive         BIT,
    @Description      NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.tbl_Series
    SET
        SeriesName = @SeriesName,
        SeriesType = @SeriesType,
        SeriesStatus = @SeriesStatus,
        MatchStatus = @MatchStatus,
        MatchFormat = NULLIF(@MatchFormat, ''),
        SeriesMatchType = NULLIF(@SeriesMatchType, ''),
        Gender = @Gender,
        [Year] = @Year,
        TrophyType = @TrophyType,
        SeriesStartDate = @SeriesStartDate,
        SeriesEndDate = @SeriesEndDate,
        IsActive = @IsActive,
        [Description] = @Description,
        ModifiedDate = GETDATE()
    WHERE SeriesId = @SeriesId
      AND IsDeleted = 0;

    SELECT @@ROWCOUNT AS AffectedRows;
END
GO

CREATE OR ALTER PROCEDURE dbo.prcTblSeriesSearch
    @SeriesAPIId INT = NULL,
    @SeriesName  NVARCHAR(250) = NULL,
    @SeriesType  NVARCHAR(20) = NULL,
    @StartFrom   DATE = NULL,
    @EndTo       DATE = NULL,
    @SortBy      VARCHAR(4) = 'ASC'
AS
BEGIN
    SET NOCOUNT ON;

    IF @SortBy NOT IN ('ASC', 'DESC')
        SET @SortBy = 'ASC';

    SELECT
        SeriesId,
        SeriesAPIId,
        SeriesName,
        SeriesType,
        SeriesStatus,
        MatchStatus,
        MatchFormat,
        SeriesMatchType,
        Gender,
        [Year],
        TrophyType,
        SeriesStartDate,
        SeriesEndDate,
        IsActive,
        [Description]
    FROM dbo.tbl_Series
    WHERE IsDeleted = 0
      AND (@SeriesAPIId IS NULL OR SeriesAPIId = @SeriesAPIId)
      AND (@SeriesName IS NULL OR SeriesName LIKE N'%' + @SeriesName + N'%')
      AND (@SeriesType IS NULL OR SeriesType = @SeriesType)
      AND (@StartFrom IS NULL OR SeriesStartDate >= @StartFrom)
      AND (@EndTo IS NULL OR SeriesEndDate <= @EndTo)
    ORDER BY
        CASE WHEN @SortBy = 'ASC' THEN SeriesStartDate END ASC,
        CASE WHEN @SortBy = 'DESC' THEN SeriesStartDate END DESC,
        SeriesId ASC;
END
GO

CREATE OR ALTER PROCEDURE dbo.prcTblSeriesGetById
    @SeriesId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        SeriesId,
        SeriesAPIId,
        SeriesName,
        SeriesType,
        SeriesStatus,
        MatchStatus,
        MatchFormat,
        SeriesMatchType,
        Gender,
        [Year],
        TrophyType,
        SeriesStartDate,
        SeriesEndDate,
        IsActive,
        [Description]
    FROM dbo.tbl_Series
    WHERE SeriesId = @SeriesId
      AND IsDeleted = 0;
END
GO

CREATE OR ALTER PROCEDURE dbo.prcTblSeriesDelete
    @SeriesId INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.tbl_Series
    SET IsDeleted = 1,
        ModifiedDate = GETDATE()
    WHERE SeriesId = @SeriesId
      AND IsDeleted = 0;

    SELECT @@ROWCOUNT AS AffectedRows;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_LogError
    @ErrorMessage NVARCHAR(MAX),
    @StackTrace   NVARCHAR(MAX) = NULL,
    @ErrorSource  NVARCHAR(500) = NULL,
    @ErrorMethod  NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.ErrorLog
    (
        ErrorMessage,
        ErrorSource,
        ErrorMethod,
        StackTrace
    )
    VALUES
    (
        @ErrorMessage,
        ISNULL(@ErrorSource, N'Application'),
        ISNULL(@ErrorMethod, N'Unknown'),
        @StackTrace
    );
END
GO

CREATE OR ALTER PROCEDURE dbo.prcSeriesYears
AS
BEGIN
    SET NOCOUNT ON;

    SELECT DISTINCT [Year]
    FROM dbo.tbl_Series
    WHERE IsDeleted = 0
      AND [Year] IS NOT NULL
    ORDER BY [Year];
END
GO

CREATE OR ALTER PROCEDURE dbo.prcSeriesFormatReport
    @Years NVARCHAR(400)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        s.[Year],
        s.MatchFormat,
        s.Gender,
        COUNT(*) AS SeriesCount
    FROM dbo.tbl_Series AS s
    WHERE s.IsDeleted = 0
      AND s.MatchFormat IN ('ODI', 'TEST', 'T20', 'T10')
      AND (N',' + REPLACE(ISNULL(@Years, N''), N' ', N'') + N',') LIKE N'%,' + s.[Year] + N',%'
    GROUP BY s.[Year], s.MatchFormat, s.Gender;
END
GO
