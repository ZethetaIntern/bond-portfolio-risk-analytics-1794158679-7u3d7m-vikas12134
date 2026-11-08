-- ==============================================================================
-- Portfolio Data Analysis: Bond Portfolio Risk & Convexity Analytics
-- Script: sql/04_bond_portfolio_analysis.sql
-- Dialect: Microsoft SQL Server (T-SQL)
-- Target Table: dbo.bond_portfolio_data
-- Description: Business analysis queries covering bond distribution by type,
--              issuer concentration, currency exposure, maturity profile,
--              and coupon yield metrics.
-- ==============================================================================

-- ==============================================================================
-- Query 1: Bond Distribution by BondType
-- Analyzes portfolio allocation across bond structures, calculating issue count,
-- total market value (INR), and aggregate portfolio weight percentage.
-- ==============================================================================
SELECT
    COALESCE(BondType, 'Unknown')                       AS BondType,
    COUNT(*)                                            AS BondCount,
    SUM(MarketValue_INR)                                AS TotalMarketValue_INR,
    ROUND(SUM(PortfolioWeight) * 100.0, 4)              AS PortfolioWeight_Pct
FROM dbo.bond_portfolio_data
GROUP BY BondType
ORDER BY TotalMarketValue_INR DESC;
GO

-- ==============================================================================
-- Query 2: Bond Distribution by Issuer
-- Evaluates issuer concentration risk by aggregating holdings per issuing entity,
-- ranked by total capital invested in INR.
-- ==============================================================================
SELECT
    COALESCE(Issuer, 'Unknown')                         AS Issuer,
    COUNT(*)                                            AS BondCount,
    SUM(MarketValue_INR)                                AS TotalMarketValue_INR,
    ROUND(SUM(PortfolioWeight) * 100.0, 4)              AS PortfolioWeight_Pct
FROM dbo.bond_portfolio_data
GROUP BY Issuer
ORDER BY TotalMarketValue_INR DESC;
GO

-- ==============================================================================
-- Query 3: Portfolio Distribution by Currency
-- Examines currency exposures, measuring position count, local currency value,
-- total market value in base INR, and percentage portfolio share.
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
-- Query 4: Bonds Grouped by Maturity Year
-- Outlines redemption and reinvestment timeline by grouping maturities by year,
-- measuring bond counts, maturing capital (INR), and average remaining maturity.
-- ==============================================================================
SELECT
    YEAR(MaturityDate)                                  AS MaturityYear,
    COUNT(*)                                            AS BondCount,
    SUM(MarketValue_INR)                                AS TotalMarketValue_INR,
    ROUND(AVG(YearsToMaturity), 2)                      AS AvgYearsToMaturity,
    ROUND(SUM(PortfolioWeight) * 100.0, 4)              AS PortfolioWeight_Pct
FROM dbo.bond_portfolio_data
WHERE MaturityDate IS NOT NULL
GROUP BY YEAR(MaturityDate)
ORDER BY MaturityYear ASC;
GO

-- ==============================================================================
-- Query 5: Average Coupon Rate by BondType
-- Compares fixed-income yield characteristics across bond types, calculating
-- arithmetic average, value-weighted average, minimum, and maximum coupon rates.
-- ==============================================================================
SELECT
    COALESCE(BondType, 'Unknown')                       AS BondType,
    COUNT(*)                                            AS BondCount,
    ROUND(AVG(CouponRate) * 100.0, 4)                   AS AvgCouponRate_Pct,
    ROUND(MIN(CouponRate) * 100.0, 4)                   AS MinCouponRate_Pct,
    ROUND(MAX(CouponRate) * 100.0, 4)                   AS MaxCouponRate_Pct,
    ROUND(
        SUM(CouponRate * MarketValue_INR) / NULLIF(SUM(MarketValue_INR), 0) * 100.0, 
        4
    )                                                   AS WeightedAvgCouponRate_Pct
FROM dbo.bond_portfolio_data
GROUP BY BondType
ORDER BY AvgCouponRate_Pct DESC;
GO

