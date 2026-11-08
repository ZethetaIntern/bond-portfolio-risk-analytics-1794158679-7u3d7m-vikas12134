import subprocess

sql_query = """
SET NOCOUNT ON;

-- 1. Portfolio Overview
SELECT 
    'Portfolio Overview' AS Domain,
    COUNT(*) AS TotalBonds,
    SUM(MarketValue_INR) AS TotalPortfolioMarketValue_INR,
    ROUND(AVG(CouponRate) * 100.0, 4) AS AvgCouponRate_Pct,
    ROUND(SUM(CouponRate * (PortfolioWeight * 100.0)) / NULLIF(SUM(PortfolioWeight * 100.0), 0), 4) AS WeightedAvgCouponRate_Pct,
    ROUND(SUM(EffectiveDuration * PortfolioWeight), 4) AS PortfolioEffectiveDuration,
    ROUND(SUM(EffectiveConvexity * PortfolioWeight), 4) AS PortfolioEffectiveConvexity
FROM dbo.bond_portfolio_data;

-- 2. Value-at-Risk & Expected Shortfall
WITH RankedScenarios AS (
    SELECT 
        PnL_Total_INR, 
        PnL_Pct, 
        ROW_NUMBER() OVER (ORDER BY PnL_Total_INR ASC) AS RankAsc 
    FROM dbo.monte_carlo_scenarios
)
SELECT 
    'Monte Carlo VaR' AS Domain,
    (SELECT PnL_Total_INR FROM RankedScenarios WHERE RankAsc = 50) AS VaR_95_INR,
    (SELECT PnL_Pct FROM RankedScenarios WHERE RankAsc = 50) AS VaR_95_Pct,
    (SELECT ROUND(AVG(PnL_Total_INR), 2) FROM RankedScenarios WHERE RankAsc <= 50) AS ES_95_INR,
    (SELECT PnL_Total_INR FROM RankedScenarios WHERE RankAsc = 10) AS VaR_99_INR,
    (SELECT PnL_Pct FROM RankedScenarios WHERE RankAsc = 10) AS VaR_99_Pct,
    (SELECT ROUND(AVG(PnL_Total_INR), 2) FROM RankedScenarios WHERE RankAsc <= 10) AS ES_99_INR;

-- 3. Rate Shock Impacts
SELECT 
    'Rate Shock Impacts' AS Domain,
    ROUND(SUM((PriceChange_Dn100bps / NULLIF(CleanPrice, 0)) * MarketValue_INR), 2) AS PortValImpact_Dn100_INR,
    ROUND(SUM((PriceChange_Up100bps / NULLIF(CleanPrice, 0)) * MarketValue_INR), 2) AS PortValImpact_Up100_INR
FROM dbo.bond_portfolio_data;
"""

cmd = ["sqlcmd", "-S", ".", "-d", "BondPortfolioRisk", "-E", "-C", "-W", "-Q", sql_query]
result = subprocess.run(cmd, capture_output=True, text=True)
print("=== SQL Server Baseline Validation ===")
print(result.stdout)

