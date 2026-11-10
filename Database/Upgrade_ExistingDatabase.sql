/*
Run this once against SeriesManagementDB if your existing database was created
before the current version of the project. Back up the database first.
*/
USE SeriesManagementDB;
GO

-- SeriesType must fit the full "International" value (13 characters).
IF COL_LENGTH('dbo.tbl_Series', 'SeriesType') IS NOT NULL
BEGIN
    ALTER TABLE dbo.tbl_Series ALTER COLUMN SeriesType NVARCHAR(20) NOT NULL;
END
GO

-- Correct older truncated value from previous insert parameter size.
UPDATE dbo.tbl_Series
SET SeriesType = N'International'
WHERE SeriesType = N'Internatio';
GO

-- Previous test data sometimes had NULL in mandatory fields. These fallback values
-- are only for historical test rows; new form submissions must supply actual choices.
UPDATE dbo.tbl_Series
SET MatchStatus = ISNULL(MatchStatus, SeriesStatus),
    TrophyType = ISNULL(TrophyType, N'Asia Cup')
WHERE MatchStatus IS NULL OR TrophyType IS NULL;
GO

-- Ensure the current required procedures and ErrorLog table are installed:
-- Execute Database/SeriesManagement.sql after reviewing it. It contains CREATE OR ALTER
-- procedure definitions and creates table objects only when they do not already exist.

-- Stored procedure update references ModifiedDate.
IF COL_LENGTH('dbo.tbl_Series', 'ModifiedDate') IS NULL
BEGIN
    ALTER TABLE dbo.tbl_Series ADD ModifiedDate DATETIME NULL;
END
GO

-- Soft-delete column used by current search/get/delete procedures.
IF COL_LENGTH('dbo.tbl_Series', 'IsDeleted') IS NULL
BEGIN
    ALTER TABLE dbo.tbl_Series
        ADD IsDeleted BIT NOT NULL CONSTRAINT DF_tbl_Series_IsDeleted_Upgrade DEFAULT (0);
END
GO
