Continue the Bond Portfolio SQL project.

IMPORTANT: The database contains 3 tables. Do not restrict analysis to dbo.bond_portfolio_data.

TASK: Inspect the database schema.

1. Identify all 3 existing user tables.
2. Retrieve their column names and data types.
3. Identify primary keys and foreign-key relationships.
4. Identify how the three tables can be connected for analysis.
5. Do not modify tables or data.
6. Do not create files.
7. Execute only one lightweight, read-only schema inspection query.
8. Do not scan unrelated project files or run multiple terminal commands.

Return a compact schema summary showing all 3 tables and their relationships.

Stop after reporting the results.-- ==============================================================================
-- Portfolio Financial Metrics: Bond Portfolio Risk & Convexity Analytics
-- Script: sql/05_bond_portfolio_metrics.sql
-- Dialect: Microsoft SQL Server (T-SQL)
-- Target Table: dbo.bond_portfolio_data
-- Description: Core portfolio-level financial metrics including market valuation,
--              coupon yield measures, weight verification, rate-type split,
--              maturity horizon analysis, currency exposures, and executive summary.
-- ==============================================================================

-- ==============================================================================
-- Metric 1: Total Number of Bonds
-- Counts total positions and verifies uniqueness across portfolio holdings.
-- ==============================================================================
SELECT
    COUNT(*)                                            AS TotalBondCount,
    COUNT(DISTINCT BondID)                              AS UniqueBondCount,
    COUNT(DISTINCT ISIN)                                AS UniqueISINCount
FROM dbo.bond_portfolio_data;
GO

-- ==============================================================================
-- Metric 2: Total Portfolio Market Value (INR)
-- Calculates aggregate invested capital in portfolio base currency (INR).
-- ==============================================================================
SELECT
    SUM(MarketValue_INR)                                AS TotalPortfolioMarketValue_INR,
    ROUND(AVG(MarketValue_INR), 2)                      AS AvgMarketValuePerBond_INR,
    MIN(MarketValue_INR)                                AS MinMarketValue_INR,
    MAX(MarketValue_INR)                                AS MaxMarketValue_INR
FROM dbo.bond_portfolio_data;
GO

-- ==============================================================================
-- Metric 3: Average Coupon Rate
-- Simple arithmetic mean coupon across all portfolio positions.
-- ==============================================================================
SELECT
    ROUND(AVG(CouponRate) * 100.0, 4)                   AS AvgCouponRate_Pct,
    ROUND(MIN(CouponRate) * 100.0, 4)                   AS MinCouponRate_Pct,
    ROUND(MAX(CouponRate) * 100.0, 4)                   AS MaxCouponRate_Pct
FROM dbo.bond_portfolio_data;
GO

-- ==============================================================================
-- Metric 4: Weighted Average Coupon Rate Using PortfolioWeight_Pct
-- Computes capital-weighted coupon yield based on relative position weights.
-- ==============================================================================
SELECT
    ROUND(
        SUM(CouponRate * (PortfolioWeight * 100.0)) / 
        NULLIF(SUM(PortfolioWeight * 100.0), 0), 
        4
    )                                                   AS WeightedAvgCouponRate_Pct
FROM dbo.bond_portfolio_data;
GO

-- ==============================================================================
-- Metric 5: Average Face Value
-- Evaluates nominal par size across portfolio holdings.
-- ==============================================================================
SELECT
    ROUND(AVG(CAST(FaceValue AS DECIMAL(18, 2))), 2)    AS AvgFaceValue,
    MIN(FaceValue)                                      AS MinFaceValue,
    MAX(FaceValue)                                      AS MaxFaceValue,
    SUM(CAST(FaceValue AS BIGINT) * Quantity)           AS TotalNominalFaceValue
FROM dbo.bond_portfolio_data;
GO

-- ==============================================================================
-- Metric 6: Total Portfolio Weight Percentage
-- Validates allocation completeness (target sum = 100.0%).
-- ==============================================================================
SELECT
    SUM(PortfolioWeight)                                AS TotalPortfolioWeight_Decimal,
    ROUND(SUM(PortfolioWeight) * 100.0, 4)              AS TotalPortfolioWeight_Pct
FROM dbo.bond_portfolio_data;
GO

-- ==============================================================================
-- Metric 7: Fixed-Rate vs Floating-Rate Bond Counts
-- Analyzes interest rate structure split across portfolio holdings.
-- ==============================================================================
SELECT
    CASE 
        WHEN IsFloatingRate = 1 THEN 'Floating Rate'
        ELSE 'Fixed Rate'
    END                                                 AS RateType,
    COUNT(*)                                            AS BondCount,
    SUM(MarketValue_INR)                                AS TotalMarketValue_INR,
    ROUND(SUM(PortfolioWeight) * 100.0, 4)              AS PortfolioWeight_Pct
FROM dbo.bond_portfolio_data
GROUP BY IsFloatingRate
ORDER BY IsFloatingRate ASC;
GO

-- ==============================================================================
-- Metric 8: Bonds Approaching Maturity
-- Identifies near-term maturities (under 1 year and under 3 years) from valuation date.
-- ==============================================================================
SELECT
    CASE 
        WHEN YearsToMaturity <= 1.0 THEN '<= 1 Year'
        WHEN YearsToMaturity <= 3.0 THEN '1 to 3 Years'
        WHEN YearsToMaturity <= 5.0 THEN '3 to 5 Years'
        ELSE '> 5 Years'
    END                                                 AS MaturityBucket,
    COUNT(*)                                            AS BondCount,
    SUM(MarketValue_INR)                                AS TotalMarketValue_INR,
    ROUND(SUM(PortfolioWeight) * 100.0, 4)              AS PortfolioWeight_Pct,
    ROUND(AVG(YearsToMaturity), 2)                      AS AvgYearsToMaturity
FROM dbo.bond_portfolio_data
GROUP BY 
    CASE 
        WHEN YearsToMaturity <= 1.0 THEN '<= 1 Year'
        WHEN YearsToMaturity <= 3.0 THEN '1 to 3 Years'
        WHEN YearsToMaturity <= 5.0 THEN '3 to 5 Years'
        ELSE '> 5 Years'
    END
ORDER BY MIN(YearsToMaturity) ASC;
GO

-- ==============================================================================
-- Metric 9: Portfolio Market Value by Currency
-- Currency allocation summary showing local values, base INR values, and weight shares.
-- ==============================================================================
SELECT
    COALESCE(Currency, 'Unknown')                       AS Currency,
    COUNT(*)                                            AS BondCount,
    SUM(MarketValue_LocalCcy)                           AS TotalMarketValue_LocalCcy,
    SUM(MarketValue_INR)                                AS TotalMarketValue_INR,
    ROUND(SUM(PortfolioWeight) * 100.0, 4)              AS PortfolioWeight_Pct
FROM dbo.bond_portfolio_data
GROUP BY Currency
ORDER BY TotalMarketValue_INR DESC;
GO

-- ==============================================================================
-- Metric 10: Overall Portfolio Summary Dashboard
-- Single unified executive record aggregating all core portfolio metrics.
-- ==============================================================================
SELECT
    COUNT(*)                                            AS TotalBonds,
    SUM(MarketValue_INR)                                AS TotalMarketValue_INR,
    ROUND(AVG(CouponRate) * 100.0, 4)                   AS AvgCouponRate_Pct,
    ROUND(
        SUM(CouponRate * (PortfolioWeight * 100.0)) / 
        NULLIF(SUM(PortfolioWeight * 100.0), 0), 
        4
    )                                                   AS WeightedAvgCouponRate_Pct,
    ROUND(AVG(CAST(FaceValue AS DECIMAL(18, 2))), 2)    AS AvgFaceValue,
    ROUND(SUM(PortfolioWeight) * 100.0, 4)              AS TotalPortfolioWeight_Pct,
    SUM(CASE WHEN IsFloatingRate = 0 THEN 1 ELSE 0 END) AS FixedRateBondCount,
    SUM(CASE WHEN IsFloatingRate = 1 THEN 1 ELSE 0 END) AS FloatingRateBondCount,
    SUM(CASE WHEN YearsToMaturity <= 1.0 THEN 1 ELSE 0 END) AS BondsMaturingWithin1Yr,
    SUM(CASE WHEN YearsToMaturity <= 3.0 THEN 1 ELSE 0 END) AS BondsMaturingWithin3Yrs,
    ROUND(AVG(YearsToMaturity), 2)                      AS AvgYearsToMaturity,
    ROUND(AVG(ModifiedDuration), 4)                     AS AvgModifiedDuration,
    ROUND(AVG(Convexity), 4)                            AS AvgConvexity
FROM dbo.bond_portfolio_data;
GO

