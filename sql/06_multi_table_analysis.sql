-- ==============================================================================
-- Multi-Table Relational Analysis: Bond Portfolio Risk & Convexity Analytics
-- Script: sql/06_multi_table_analysis.sql
-- Dialect: Microsoft SQL Server (T-SQL)
-- Target Tables: dbo.bond_portfolio_data, dbo.monte_carlo_scenarios, dbo.yield_curve_history
-- Description: Comprehensive multi-table analyses linking position-level inventory,
--              market term structures, and Monte Carlo scenario simulations.
-- ==============================================================================

-- ==============================================================================
-- Section 1: Combined Portfolio Overview
-- Integrates baseline portfolio inventory metrics from dbo.bond_portfolio_data with
-- aggregate Monte Carlo risk/VaR simulation statistics and benchmark curve yields.
-- ==============================================================================
WITH PortfolioSummary AS (
    SELECT
        COUNT(*)                                            AS TotalBonds,
        SUM(MarketValue_INR)                                AS TotalPortfolioMarketValue_INR,
        ROUND(AVG(CouponRate) * 100.0, 4)                   AS AvgCouponRate_Pct,
        ROUND(SUM(CouponRate * PortfolioWeight) * 100.0, 4) AS WeightedAvgCouponRate_Pct,
        ROUND(SUM(EffectiveDuration * PortfolioWeight), 4)  AS PortfolioEffectiveDuration,
        ROUND(SUM(EffectiveConvexity * PortfolioWeight), 4) AS PortfolioEffectiveConvexity,
        ROUND(AVG(YieldToMaturity) * 100.0, 4)              AS AvgYTM_Pct
    FROM dbo.bond_portfolio_data
),
ScenarioSummary AS (
    SELECT
        COUNT(*)                                            AS TotalScenarios,
        ROUND(AVG(ParallelShift_bps), 2)                    AS AvgParallelShift_bps,
        ROUND(AVG(PnL_Total_INR), 2)                        AS AvgScenarioPnL_INR,
        MIN(PnL_Total_INR)                                  AS WorstCasePnL_INR,
        MAX(PnL_Total_INR)                                  AS BestCasePnL_INR,
        MIN(VaR_Contribution)                               AS MaxVaR_Contribution_INR,
        SUM(VaR_Contribution)                               AS TotalVaR_Contribution_INR
    FROM dbo.monte_carlo_scenarios
),
YieldCurveSummary AS (
    SELECT
        COUNT(DISTINCT CurveDate)                           AS ObservedCurveDates,
        COUNT(DISTINCT Currency)                            AS YieldCurveCurrencies,
        ROUND(AVG(ZeroRate) * 100.0, 4)                     AS AvgMarketZeroRate_Pct
    FROM dbo.yield_curve_history
)
SELECT
    p.TotalBonds,
    p.TotalPortfolioMarketValue_INR,
    p.AvgCouponRate_Pct,
    p.WeightedAvgCouponRate_Pct,
    p.PortfolioEffectiveDuration,
    p.PortfolioEffectiveConvexity,
    p.AvgYTM_Pct,
    s.TotalScenarios,
    s.AvgParallelShift_bps,
    s.AvgScenarioPnL_INR,
    s.WorstCasePnL_INR,
    s.BestCasePnL_INR,
    y.ObservedCurveDates,
    y.YieldCurveCurrencies,
    y.AvgMarketZeroRate_Pct
FROM PortfolioSummary p
CROSS JOIN ScenarioSummary s
CROSS JOIN YieldCurveSummary y;
GO

-- ==============================================================================
-- Section 2: Issuer-wise Portfolio Analysis
-- Evaluates issuer concentration, credit spreads, risk exposures, and maps to benchmark
-- curve yields by joining pre-aggregated valuation date yield curves to avoid duplicate counting.
-- ==============================================================================
WITH ValuationYields AS (
    SELECT
        Currency,
        TenorLabel,
        AVG(Yield)                                      AS BenchmarkYield,
        AVG(ZeroRate)                                   AS BenchmarkZeroRate
    FROM dbo.yield_curve_history
    WHERE CurveDate = (SELECT MAX(CurveDate) FROM dbo.yield_curve_history)
    GROUP BY Currency, TenorLabel
)
SELECT
    COALESCE(b.Issuer, 'Unknown')                       AS Issuer,
    COALESCE(b.Sector, 'Unknown')                       AS Sector,
    COALESCE(b.CreditRating, 'NR')                      AS CreditRating,
    COUNT(DISTINCT b.BondID)                            AS BondCount,
    SUM(b.MarketValue_INR)                              AS TotalMarketValue_INR,
    ROUND(SUM(b.PortfolioWeight) * 100.0, 4)            AS PortfolioWeight_Pct,
    ROUND(AVG(b.CouponRate) * 100.0, 4)                 AS AvgCouponRate_Pct,
    ROUND(AVG(b.YieldToMaturity) * 100.0, 4)            AS AvgYTM_Pct,
    ROUND(AVG(CAST(b.SpreadOverBenchmark_bps AS DECIMAL(9, 2))), 2) AS AvgSpreadOverBenchmark_bps,
    ROUND(AVG(b.EffectiveDuration), 4)                  AS AvgEffectiveDuration,
    ROUND(AVG(b.EffectiveConvexity), 4)                 AS AvgEffectiveConvexity,
    ROUND(AVG(vy.BenchmarkZeroRate) * 100.0, 4)         AS AvgBenchmarkZeroRate_Pct
FROM dbo.bond_portfolio_data b
LEFT JOIN ValuationYields vy
    ON b.Currency = vy.Currency
   AND vy.TenorLabel = CASE b.KeyRateBucket
       WHEN '0-1Y' THEN '1Y'
       WHEN '1-2Y' THEN '2Y'
       WHEN '2-3Y' THEN '3Y'
       WHEN '3-5Y' THEN '5Y'
       WHEN '5-7Y' THEN '7Y'
       WHEN '7-10Y' THEN '10Y'
       WHEN '10-15Y' THEN '15Y'
       WHEN '15-20Y' THEN '20Y'
       WHEN '20Y+' THEN '30Y'
   END
GROUP BY b.Issuer, b.Sector, b.CreditRating
ORDER BY TotalMarketValue_INR DESC;
GO

-- ==============================================================================
-- Section 3: Bond Distribution Across Related Tables
-- Evaluates cross-table coverage of portfolio bonds against historical yield curve tenors,
-- checking alignment across currencies, key rate buckets, and discount factors.
-- ==============================================================================
SELECT
    b.Currency,
    b.KeyRateBucket,
    COUNT(DISTINCT b.BondID)                            AS PortfolioBondCount,
    SUM(b.MarketValue_INR)                              AS TotalMarketValue_INR,
    ROUND(SUM(b.PortfolioWeight) * 100.0, 4)            AS PortfolioWeight_Pct,
    COUNT(DISTINCT y.CurveDate)                         AS MatchingCurveDatesCount,
    ROUND(AVG(y.ZeroRate) * 100.0, 4)                   AS AvgMatchingZeroRate_Pct,
    ROUND(AVG(y.DiscountFactor), 6)                     AS AvgDiscountFactor
FROM dbo.bond_portfolio_data b
LEFT JOIN dbo.yield_curve_history y
    ON b.Currency = y.Currency
   AND y.TenorLabel = CASE b.KeyRateBucket
       WHEN '0-1Y' THEN '1Y'
       WHEN '1-2Y' THEN '2Y'
       WHEN '2-3Y' THEN '3Y'
       WHEN '3-5Y' THEN '5Y'
       WHEN '5-7Y' THEN '7Y'
       WHEN '7-10Y' THEN '10Y'
       WHEN '10-15Y' THEN '15Y'
       WHEN '15-20Y' THEN '20Y'
       WHEN '20Y+' THEN '30Y'
   END
   AND y.CurveDate = (SELECT MAX(CurveDate) FROM dbo.yield_curve_history WHERE CurveDate <= b.ValuationDate)
GROUP BY b.Currency, b.KeyRateBucket
ORDER BY b.Currency ASC, b.KeyRateBucket ASC;
GO

-- ==============================================================================
-- Section 4: Interest Rate and Yield Analysis
-- Connects individual bond contractual yields (CouponRate, YieldToMaturity) to matching
-- contemporaneous market zero rates and par yields from dbo.yield_curve_history.
-- Computes the net spread between bond YTM and market zero rates.
-- ==============================================================================
WITH ContemporaneousCurve AS (
    SELECT
        CurveDate,
        Currency,
        TenorLabel,
        AVG(Yield)                                      AS MarketParYield,
        AVG(ZeroRate)                                   AS MarketZeroRate,
        AVG(DiscountFactor)                             AS MarketDiscountFactor
    FROM dbo.yield_curve_history
    GROUP BY CurveDate, Currency, TenorLabel
)
SELECT
    b.Currency,
    b.KeyRateBucket,
    COUNT(b.BondID)                                     AS BondCount,
    ROUND(AVG(b.CouponRate) * 100.0, 4)                 AS AvgBondCoupon_Pct,
    ROUND(AVG(b.YieldToMaturity) * 100.0, 4)            AS AvgBondYTM_Pct,
    ROUND(AVG(c.MarketParYield) * 100.0, 4)             AS AvgMarketParYield_Pct,
    ROUND(AVG(c.MarketZeroRate) * 100.0, 4)             AS AvgMarketZeroRate_Pct,
    ROUND(AVG(b.YieldToMaturity - c.MarketZeroRate) * 10000.0, 2) AS CalculatedNetSpread_bps,
    ROUND(AVG(CAST(b.SpreadOverBenchmark_bps AS DECIMAL(9, 2))), 2) AS StoredSpreadOverBenchmark_bps,
    ROUND(AVG(CAST(b.ZSpread_bps AS DECIMAL(9, 2))), 2) AS AvgZSpread_bps
FROM dbo.bond_portfolio_data b
INNER JOIN ContemporaneousCurve c
    ON b.Currency = c.Currency
   AND c.TenorLabel = CASE b.KeyRateBucket
       WHEN '0-1Y' THEN '1Y'
       WHEN '1-2Y' THEN '2Y'
       WHEN '2-3Y' THEN '3Y'
       WHEN '3-5Y' THEN '5Y'
       WHEN '5-7Y' THEN '7Y'
       WHEN '7-10Y' THEN '10Y'
       WHEN '10-15Y' THEN '15Y'
       WHEN '15-20Y' THEN '20Y'
       WHEN '20Y+' THEN '30Y'
   END
   AND c.CurveDate = (SELECT MAX(CurveDate) FROM dbo.yield_curve_history WHERE CurveDate <= b.ValuationDate)
GROUP BY b.Currency, b.KeyRateBucket
ORDER BY b.Currency ASC, b.KeyRateBucket ASC;
GO

-- ==============================================================================
-- Section 5: Maturity and Risk Analysis
-- Links maturity profiles and duration sensitivities from dbo.bond_portfolio_data with
-- stress-testing rate shifts and portfolio PnL distributions from dbo.monte_carlo_scenarios.
-- ==============================================================================
WITH MaturityBucketAnalysis AS (
    SELECT
        CASE 
            WHEN b.YearsToMaturity <= 1.0 THEN '<= 1 Year'
            WHEN b.YearsToMaturity <= 3.0 THEN '1 to 3 Years'
            WHEN b.YearsToMaturity <= 5.0 THEN '3 to 5 Years'
            WHEN b.YearsToMaturity <= 10.0 THEN '5 to 10 Years'
            ELSE '> 10 Years'
        END                                             AS MaturityTenorBucket,
        COUNT(DISTINCT b.BondID)                        AS BondCount,
        SUM(b.MarketValue_INR)                          AS MarketValue_INR,
        ROUND(SUM(b.PortfolioWeight) * 100.0, 4)        AS Weight_Pct,
        ROUND(AVG(b.YearsToMaturity), 2)                AS AvgYearsToMaturity,
        ROUND(AVG(b.ModifiedDuration), 4)               AS AvgModifiedDuration,
        ROUND(AVG(b.EffectiveDuration), 4)              AS AvgEffectiveDuration,
        ROUND(AVG(b.EffectiveConvexity), 4)             AS AvgEffectiveConvexity,
        ROUND(AVG(b.PriceChange_Up100bps), 4)           AS AvgPriceChg_Up100bps,
        ROUND(AVG(b.PriceChange_Dn100bps), 4)           AS AvgPriceChg_Dn100bps
    FROM dbo.bond_portfolio_data b
    GROUP BY 
        CASE 
            WHEN b.YearsToMaturity <= 1.0 THEN '<= 1 Year'
            WHEN b.YearsToMaturity <= 3.0 THEN '1 to 3 Years'
            WHEN b.YearsToMaturity <= 5.0 THEN '3 to 5 Years'
            WHEN b.YearsToMaturity <= 10.0 THEN '5 to 10 Years'
            ELSE '> 10 Years'
        END
),
ScenarioShockStats AS (
    SELECT
        AVG(CASE WHEN ParallelShift_bps = 100.00 THEN PnL_Total_INR END)  AS PnL_ParallelUp100_INR,
        AVG(CASE WHEN ParallelShift_bps = -100.00 THEN PnL_Total_INR END) AS PnL_ParallelDn100_INR,
        AVG(PnL_DurationEffect_INR)                                       AS AvgDurationEffect_INR,
        AVG(PnL_ConvexityEffect_INR)                                      AS AvgConvexityEffect_INR
    FROM dbo.monte_carlo_scenarios
)
SELECT
    m.MaturityTenorBucket,
    m.BondCount,
    m.MarketValue_INR,
    m.Weight_Pct,
    m.AvgYearsToMaturity,
    m.AvgModifiedDuration,
    m.AvgEffectiveDuration,
    m.AvgEffectiveConvexity,
    m.AvgPriceChg_Up100bps,
    m.AvgPriceChg_Dn100bps,
    s.PnL_ParallelUp100_INR,
    s.PnL_ParallelDn100_INR,
    s.AvgDurationEffect_INR,
    s.AvgConvexityEffect_INR
FROM MaturityBucketAnalysis m
CROSS JOIN ScenarioShockStats s
ORDER BY m.AvgYearsToMaturity ASC;
GO

-- ==============================================================================
-- Section 6: Identify Records Without Matching Relationships
-- Detects data discrepancies and unmapped foreign dimensions using LEFT JOINs:
-- 6.1: Bonds whose Currency or KeyRateBucket have no match in dbo.yield_curve_history.
-- 6.2: Yield curve tenors without matching bonds on prevailing valuation date.
-- 6.3: Relational completeness summary.
-- ==============================================================================

-- 6.1: Unmapped Bonds (Non-INR positions lacking matching domestic yield curve)
SELECT
    b.BondID,
    b.ISIN,
    b.Issuer,
    b.Currency,
    b.ValuationDate,
    b.KeyRateBucket,
    b.YearsToMaturity,
    b.MarketValue_INR
FROM dbo.bond_portfolio_data b
LEFT JOIN dbo.yield_curve_history y
    ON b.Currency = y.Currency
   AND y.TenorLabel = CASE b.KeyRateBucket
       WHEN '0-1Y' THEN '1Y'
       WHEN '1-2Y' THEN '2Y'
       WHEN '2-3Y' THEN '3Y'
       WHEN '3-5Y' THEN '5Y'
       WHEN '5-7Y' THEN '7Y'
       WHEN '7-10Y' THEN '10Y'
       WHEN '10-15Y' THEN '15Y'
       WHEN '15-20Y' THEN '20Y'
       WHEN '20Y+' THEN '30Y'
   END
   AND y.CurveDate = (SELECT MAX(CurveDate) FROM dbo.yield_curve_history WHERE CurveDate <= b.ValuationDate)
WHERE y.CurveDate IS NULL;
GO

-- 6.2: Unutilized Yield Curve Tenors on Prevailing Valuation Date
SELECT
    y.CurveDate,
    y.Currency,
    y.Tenor_Years,
    y.TenorLabel,
    y.ZeroRate,
    y.DiscountFactor
FROM dbo.yield_curve_history y
LEFT JOIN dbo.bond_portfolio_data b
    ON y.Currency = b.Currency
   AND y.TenorLabel = CASE b.KeyRateBucket
       WHEN '0-1Y' THEN '1Y'
       WHEN '1-2Y' THEN '2Y'
       WHEN '2-3Y' THEN '3Y'
       WHEN '3-5Y' THEN '5Y'
       WHEN '5-7Y' THEN '7Y'
       WHEN '7-10Y' THEN '10Y'
       WHEN '10-15Y' THEN '15Y'
       WHEN '15-20Y' THEN '20Y'
       WHEN '20Y+' THEN '30Y'
   END
WHERE b.BondID IS NULL
  AND y.CurveDate = (SELECT MAX(CurveDate) FROM dbo.yield_curve_history);
GO

-- 6.3: Relational Completeness Summary
SELECT
    'Foreign Currency Bonds Without Matching Yield Curve (USD/GBP/EUR/AUD/JPY)' AS AuditCheck,
    COUNT(*)                                            AS UnmatchedRecordCount
FROM dbo.bond_portfolio_data b
LEFT JOIN dbo.yield_curve_history y
    ON b.Currency = y.Currency
   AND y.TenorLabel = CASE b.KeyRateBucket
       WHEN '0-1Y' THEN '1Y'
       WHEN '1-2Y' THEN '2Y'
       WHEN '2-3Y' THEN '3Y'
       WHEN '3-5Y' THEN '5Y'
       WHEN '5-7Y' THEN '7Y'
       WHEN '7-10Y' THEN '10Y'
       WHEN '10-15Y' THEN '15Y'
       WHEN '15-20Y' THEN '20Y'
       WHEN '20Y+' THEN '30Y'
   END
   AND y.CurveDate = (SELECT MAX(CurveDate) FROM dbo.yield_curve_history WHERE CurveDate <= b.ValuationDate)
WHERE y.CurveDate IS NULL

UNION ALL

SELECT
    'Unutilized Yield Curve Tenors on Prevailing Valuation Date (3M, 6M)' AS AuditCheck,
    COUNT(*)                                            AS UnmatchedRecordCount
FROM dbo.yield_curve_history y
LEFT JOIN dbo.bond_portfolio_data b
    ON y.Currency = b.Currency
   AND y.TenorLabel = CASE b.KeyRateBucket
       WHEN '0-1Y' THEN '1Y'
       WHEN '1-2Y' THEN '2Y'
       WHEN '2-3Y' THEN '3Y'
       WHEN '3-5Y' THEN '5Y'
       WHEN '5-7Y' THEN '7Y'
       WHEN '7-10Y' THEN '10Y'
       WHEN '10-15Y' THEN '15Y'
       WHEN '15-20Y' THEN '20Y'
       WHEN '20Y+' THEN '30Y'
   END
WHERE b.BondID IS NULL
  AND y.CurveDate = (SELECT MAX(CurveDate) FROM dbo.yield_curve_history);
GO


-- ==============================================================================
-- Section 7: Interest Rate Sensitivity Analysis (50, 100, 200 bps Up/Down)
-- Evaluates portfolio-wide interest rate sensitivity across standard parallel shock
-- scenarios (±50, ±100, ±200 bps) using bond-level price change vectors, calculating
-- weighted price impacts, aggregate monetary portfolio PnL, and percentage return impacts.
-- ==============================================================================
WITH PortfolioBaseline AS (
    SELECT 
        SUM(MarketValue_INR) AS TotalMarketValue_INR
    FROM dbo.bond_portfolio_data
),
RateShockAggregates AS (
    SELECT
        -- Up 50 bps
        ROUND(SUM(PortfolioWeight * PriceChange_Up50bps), 4)                    AS WAvgPriceChg_Up50,
        ROUND(SUM((PriceChange_Up50bps / NULLIF(CleanPrice, 0)) * MarketValue_INR), 2) AS PortValImpact_Up50_INR,
        -- Dn 50 bps
        ROUND(SUM(PortfolioWeight * PriceChange_Dn50bps), 4)                    AS WAvgPriceChg_Dn50,
        ROUND(SUM((PriceChange_Dn50bps / NULLIF(CleanPrice, 0)) * MarketValue_INR), 2) AS PortValImpact_Dn50_INR,
        -- Up 100 bps
        ROUND(SUM(PortfolioWeight * PriceChange_Up100bps), 4)                   AS WAvgPriceChg_Up100,
        ROUND(SUM((PriceChange_Up100bps / NULLIF(CleanPrice, 0)) * MarketValue_INR), 2) AS PortValImpact_Up100_INR,
        -- Dn 100 bps
        ROUND(SUM(PortfolioWeight * PriceChange_Dn100bps), 4)                   AS WAvgPriceChg_Dn100,
        ROUND(SUM((PriceChange_Dn100bps / NULLIF(CleanPrice, 0)) * MarketValue_INR), 2) AS PortValImpact_Dn100_INR,
        -- Up 200 bps
        ROUND(SUM(PortfolioWeight * PriceChange_Up200bps), 4)                   AS WAvgPriceChg_Up200,
        ROUND(SUM((PriceChange_Up200bps / NULLIF(CleanPrice, 0)) * MarketValue_INR), 2) AS PortValImpact_Up200_INR,
        -- Dn 200 bps
        ROUND(SUM(PortfolioWeight * PriceChange_Dn200bps), 4)                   AS WAvgPriceChg_Dn200,
        ROUND(SUM((PriceChange_Dn200bps / NULLIF(CleanPrice, 0)) * MarketValue_INR), 2) AS PortValImpact_Dn200_INR
    FROM dbo.bond_portfolio_data
)
SELECT
    v.ScenarioName,
    v.RateShift_bps,
    v.Direction,
    v.WeightedAvgPriceChange,
    v.EstimatedPortfolioImpact_INR,
    ROUND((v.EstimatedPortfolioImpact_INR / NULLIF(b.TotalMarketValue_INR, 0)) * 100.0, 4) AS PortfolioReturnImpact_Pct
FROM RateShockAggregates r
CROSS JOIN PortfolioBaseline b
CROSS APPLY (
    VALUES
        ('Rate Shock -200 bps', -200, 'Downward', r.WAvgPriceChg_Dn200, r.PortValImpact_Dn200_INR, 1),
        ('Rate Shock -100 bps', -100, 'Downward', r.WAvgPriceChg_Dn100, r.PortValImpact_Dn100_INR, 2),
        ('Rate Shock  -50 bps',  -50, 'Downward', r.WAvgPriceChg_Dn50,  r.PortValImpact_Dn50_INR,  3),
        ('Rate Shock  +50 bps',   50, 'Upward',   r.WAvgPriceChg_Up50,  r.PortValImpact_Up50_INR,  4),
        ('Rate Shock +100 bps',  100, 'Upward',   r.WAvgPriceChg_Up100, r.PortValImpact_Up100_INR, 5),
        ('Rate Shock +200 bps',  200, 'Upward',   r.WAvgPriceChg_Up200, r.PortValImpact_Up200_INR, 6)
) v(ScenarioName, RateShift_bps, Direction, WeightedAvgPriceChange, EstimatedPortfolioImpact_INR, Ord)
ORDER BY v.Ord;
GO

-- ==============================================================================
-- Section 8: Portfolio Risk Concentration Analysis by Issuer, Currency and BondType
-- Assesses multi-dimensional exposure concentrations across Issuer, Currency, and BondType,
-- measuring bond positions, market capital invested, percentage portfolio contributions,
-- cumulative exposure shares, and weighted duration/convexity risk metrics.
-- ==============================================================================
WITH ConcentrationBase AS (
    SELECT
        COALESCE(b.Issuer, 'Unknown')                       AS Issuer,
        COALESCE(b.Currency, 'Unknown')                     AS Currency,
        COALESCE(b.BondType, 'Unknown')                     AS BondType,
        COUNT(b.BondID)                                     AS BondCount,
        SUM(b.MarketValue_INR)                              AS TotalMarketValue_INR,
        ROUND(SUM(b.PortfolioWeight) * 100.0, 4)            AS PortfolioExposure_Pct,
        ROUND(
            SUM(b.EffectiveDuration * b.PortfolioWeight) / NULLIF(SUM(b.PortfolioWeight), 0), 
            4
        )                                                   AS WeightedEffectiveDuration,
        ROUND(
            SUM(b.EffectiveConvexity * b.PortfolioWeight) / NULLIF(SUM(b.PortfolioWeight), 0), 
            4
        )                                                   AS WeightedEffectiveConvexity
    FROM dbo.bond_portfolio_data b
    GROUP BY b.Issuer, b.Currency, b.BondType
)
SELECT
    DENSE_RANK() OVER (ORDER BY TotalMarketValue_INR DESC)  AS ConcentrationRank,
    Issuer,
    Currency,
    BondType,
    BondCount,
    TotalMarketValue_INR,
    PortfolioExposure_Pct,
    ROUND(
        SUM(PortfolioExposure_Pct) OVER (ORDER BY TotalMarketValue_INR DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW),
        4
    )                                                       AS CumulativeExposure_Pct,
    WeightedEffectiveDuration,
    WeightedEffectiveConvexity
FROM ConcentrationBase
ORDER BY TotalMarketValue_INR DESC;
GO
