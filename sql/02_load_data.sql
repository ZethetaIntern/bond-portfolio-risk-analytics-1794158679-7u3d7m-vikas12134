-- ==============================================================================
-- Data Ingestion: Bond Portfolio, Monte Carlo Scenarios, Yield Curve History
-- Script: sql/02_load_data.sql
-- Dialect: Microsoft SQL Server (T-SQL)
-- Description: BULK INSERT statements for cleaned CSV datasets into database tables
-- ==============================================================================

-- 1. Ingestion for dataset 1 (dbo.bond_portfolio_data)
-- Uses a temporary staging table to handle scientific notation in PortfolioWeight
-- and 'True'/'False' literals in BIT columns without precision loss.
IF OBJECT_ID('tempdb..#stage_bond_portfolio_data') IS NOT NULL
    DROP TABLE #stage_bond_portfolio_data;

CREATE TABLE #stage_bond_portfolio_data (
    BondID                      VARCHAR(20),
    ISIN                        VARCHAR(12),
    Issuer                      VARCHAR(100),
    Sector                      VARCHAR(50),
    CreditRating                VARCHAR(10),
    Currency                    CHAR(3),
    FaceValue                   INT,
    CouponRate                  DECIMAL(9, 6),
    CouponFrequency             INT,
    BondType                    VARCHAR(20),
    IssueDate                   DATE,
    MaturityDate                DATE,
    ValuationDate               DATE,
    YearsToMaturity             DECIMAL(9, 4),
    OriginalMaturityYears       INT,
    YieldToMaturity             DECIMAL(9, 6),
    CleanPrice                  DECIMAL(12, 4),
    AccruedInterest             DECIMAL(12, 4),
    DirtyPrice                  DECIMAL(12, 4),
    MacaulayDuration            DECIMAL(9, 4),
    ModifiedDuration            DECIMAL(9, 4),
    Convexity                   DECIMAL(12, 4),
    DV01_Per100Face             DECIMAL(9, 4),
    EffectiveDuration           DECIMAL(9, 4),
    EffectiveConvexity          DECIMAL(12, 4),
    SpreadOverBenchmark_bps     INT,
    OAS_bps                     INT,
    ZSpread_bps                 INT,
    KeyRateBucket               VARCHAR(10),
    Quantity                    INT,
    MarketValue_LocalCcy        DECIMAL(18, 2),
    MarketValue_INR             DECIMAL(18, 2),
    PortfolioWeight             VARCHAR(50),
    IsCallable                  VARCHAR(10),
    CallDate                    DATE NULL,
    IsPutable                   VARCHAR(10),
    IsFloatingRate              VARCHAR(10),
    BenchmarkIndex              VARCHAR(20),
    PriceChange_Up50bps         DECIMAL(9, 4),
    PriceChange_Dn50bps         DECIMAL(9, 4),
    PriceChange_Up100bps        DECIMAL(9, 4),
    PriceChange_Dn100bps        DECIMAL(9, 4),
    PriceChange_Up200bps        DECIMAL(9, 4),
    PriceChange_Dn200bps        DECIMAL(9, 4)
);

BULK INSERT #stage_bond_portfolio_data
FROM 'D:\INTERNSHIP2\data\cleaned\bond_portfolio_data_cleaned.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\r\n',
    TABLOCK,
    KEEPNULLS
);

INSERT INTO dbo.bond_portfolio_data (
    BondID, ISIN, Issuer, Sector, CreditRating, Currency,
    FaceValue, CouponRate, CouponFrequency, BondType,
    IssueDate, MaturityDate, ValuationDate, YearsToMaturity, OriginalMaturityYears,
    YieldToMaturity, CleanPrice, AccruedInterest, DirtyPrice,
    MacaulayDuration, ModifiedDuration, Convexity, DV01_Per100Face,
    EffectiveDuration, EffectiveConvexity, SpreadOverBenchmark_bps, OAS_bps, ZSpread_bps, KeyRateBucket,
    Quantity, MarketValue_LocalCcy, MarketValue_INR, PortfolioWeight,
    IsCallable, CallDate, IsPutable, IsFloatingRate, BenchmarkIndex,
    PriceChange_Up50bps, PriceChange_Dn50bps, PriceChange_Up100bps, PriceChange_Dn100bps,
    PriceChange_Up200bps, PriceChange_Dn200bps
)
SELECT
    BondID, ISIN, Issuer, Sector, CreditRating, Currency,
    FaceValue, CouponRate, CouponFrequency, BondType,
    IssueDate, MaturityDate, ValuationDate, YearsToMaturity, OriginalMaturityYears,
    YieldToMaturity, CleanPrice, AccruedInterest, DirtyPrice,
    MacaulayDuration, ModifiedDuration, Convexity, DV01_Per100Face,
    EffectiveDuration, EffectiveConvexity, SpreadOverBenchmark_bps, OAS_bps, ZSpread_bps, KeyRateBucket,
    Quantity, MarketValue_LocalCcy, MarketValue_INR,
    COALESCE(TRY_CAST(LTRIM(RTRIM(PortfolioWeight)) AS DECIMAL(10, 8)), CAST(CAST(LTRIM(RTRIM(PortfolioWeight)) AS FLOAT) AS DECIMAL(10, 8))),
    CASE WHEN LOWER(LTRIM(RTRIM(IsCallable))) IN ('true', '1') THEN 1 ELSE 0 END,
    CallDate,
    CASE WHEN LOWER(LTRIM(RTRIM(IsPutable))) IN ('true', '1') THEN 1 ELSE 0 END,
    CASE WHEN LOWER(LTRIM(RTRIM(IsFloatingRate))) IN ('true', '1') THEN 1 ELSE 0 END,
    BenchmarkIndex,
    PriceChange_Up50bps, PriceChange_Dn50bps, PriceChange_Up100bps, PriceChange_Dn100bps,
    PriceChange_Up200bps, PriceChange_Dn200bps
FROM #stage_bond_portfolio_data;

DROP TABLE #stage_bond_portfolio_data;
GO

-- 2. BULK INSERT for dataset 2 (dbo.monte_carlo_scenarios)
BULK INSERT dbo.monte_carlo_scenarios
FROM 'D:\INTERNSHIP2\data\cleaned\monte_carlo_scenarios_cleaned.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\r\n',
    TABLOCK,
    KEEPNULLS
);
GO

-- 3. BULK INSERT for dataset 3 (dbo.yield_curve_history)
BULK INSERT dbo.yield_curve_history
FROM 'D:\INTERNSHIP2\data\cleaned\yield_curve_history_cleaned.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\r\n',
    TABLOCK,
    KEEPNULLS
);
GO

-- 4. SELECT COUNT(*) validation query for each table
SELECT 'dbo.bond_portfolio_data' AS TableName, COUNT(*) AS RecordCount FROM dbo.bond_portfolio_data
UNION ALL
SELECT 'dbo.monte_carlo_scenarios' AS TableName, COUNT(*) AS RecordCount FROM dbo.monte_carlo_scenarios
UNION ALL
SELECT 'dbo.yield_curve_history' AS TableName, COUNT(*) AS RecordCount FROM dbo.yield_curve_history;
GO
