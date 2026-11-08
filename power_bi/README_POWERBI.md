# Bond Portfolio Risk & Convexity Analytics — Power BI Implementation

**Project:** Bond Portfolio Fixed-Income Analytics  
**Artifact Path:** `d:\INTERNSHIP2\power_bi\`  
**Target Database:** `BondPortfolioRisk` on `localhost` (Microsoft SQL Server)  
**File Format:** Power BI Project (`.pbip`) + Tabular Semantic Model (`model.bim`)  

---

## 1. Project Files Directory Structure

```
d:\INTERNSHIP2\power_bi\
├── BondPortfolioRisk.pbip                    # Master Power BI Project launcher
├── BondPortfolioRisk.Report\
│   ├── definition.pbir                      # Semantic model linkage definition
│   └── report.json                          # Complete layout for 5 dashboard pages & visuals
├── BondPortfolioRisk.SemanticModel\
│   ├── definition.pbism                     # Model version definition
│   └── model.bim                            # Tabular Model Schema (Tables, Relationships, DAX)
├── dax_measures_reference.dax               # Production DAX scripts with financial notes
├── power_query_sources.m                    # Power Query M import queries
└── test_dax_validation.py                   # Automated validation script against SQL Server
```

---

## 2. Imported Tables & Data Model Architecture

The semantic model imports the 3 core database tables and adds a calculated bridge table and a What-If parameter table:

1. **`bond_portfolio_data` (Fact - Positions):** 44 columns, 300 positions.
2. **`monte_carlo_scenarios` (Fact - Simulations):** 9 columns, 1,000 scenarios.
3. **`yield_curve_history` (Timeseries - Benchmarks):** 8 columns, 264 curve points.
4. **`_KeyRateMapping` (Bridge Dimension):** Maps position range buckets (`0-1Y`, `1-2Y`, etc.) to discrete curve tenors (`1Y`, `2Y`, etc.).
5. **`RateShockParameter` (Disconnected Parameter):** Drives dynamic $\pm 50, \pm 100, \pm 200\text{ bps}$ price shock modeling.
6. **`_Measures` (Measure Storage):** Houses all 26 verified business and risk DAX measures.

---

## 3. Verified DAX Measures Summary

| Measure Name | DAX Expression Summary | Validated Value |
|---|---|:---:|
| **Total Bonds** | `COUNTROWS('bond_portfolio_data')` | **300** |
| **Total Portfolio Market Value** | `SUM('bond_portfolio_data'[MarketValue_INR])` | **₹32,059,345.97** |
| **Average Coupon Rate** | `AVERAGE('bond_portfolio_data'[CouponRate])` | **6.4047%** |
| **Weighted Average Coupon Rate** | `DIVIDE(SUMX(..., CouponRate * MarketValue_INR), [Total Value], 0)` | **6.8544%** |
| **Portfolio Effective Duration** | `DIVIDE(SUMX(..., EffectiveDuration * MarketValue_INR), [Total Value], 0)` | **4.2038 yrs** |
| **Portfolio Effective Convexity** | `DIVIDE(SUMX(..., EffectiveConvexity * MarketValue_INR), [Total Value], 0)` | **44.0315** |
| **Total DV01** | `SUMX(..., DV01_Per100Face * FaceValue * Qty / 100)` | **₹13,478.92** |
| **Price Shock Impact (-100 bps)** | `SUMX(..., (PriceChange_Dn100bps / CleanPrice) * MarketValue_INR)` | **-₹1,276,866.02** |
| **Price Shock Impact (+100 bps)** | `SUMX(..., (PriceChange_Up100bps / CleanPrice) * MarketValue_INR)` | **+₹1,418,124.56** |
| **95% VaR (INR)** | `PERCENTILE.INC('monte_carlo_scenarios'[PnL_Total_INR], 0.05)` | **-₹1,983,083.13** |
| **95% VaR (%)** | `PERCENTILE.INC('monte_carlo_scenarios'[PnL_Pct], 0.05)` | **-6.19%** |
| **95% Expected Shortfall (INR)**| `CALCULATE(AVERAGE(PnL_Total_INR), PnL_Total_INR <= [95% VaR])` | **-₹2,377,153.69** |
| **99% VaR (INR)** | `PERCENTILE.INC('monte_carlo_scenarios'[PnL_Total_INR], 0.01)` | **-₹2,600,761.77** |
| **99% VaR (%)** | `PERCENTILE.INC('monte_carlo_scenarios'[PnL_Pct], 0.01)` | **-8.11%** |
| **99% Expected Shortfall (INR)**| `CALCULATE(AVERAGE(PnL_Total_INR), PnL_Total_INR <= [99% VaR])` | **-₹2,999,457.15** |

---

## 4. Five Dashboard Pages

1. **Page 1: Portfolio Overview**
   - KPI Cards: Total Market Value, Total Bonds, Weighted Coupon, Effective Duration, Convexity.
   - Donut Chart: Currency distribution (INR 78.0%, USD 10.7%, GBP 4.7%, EUR 4.3%, AUD 2.4%, JPY 0.01%).
   - Treemap: Sector & Credit Rating allocation.
   - Column Chart: Annual Maturity Redemption Ladder (2025–2063).
   - Slicer: Currency & Sector filters.

2. **Page 2: Portfolio Composition**
   - Bar Chart: Top 10 Issuers ranked by market capital (GoI 21.6%, US Treasury 10.7%, Muthoot 5.9%).
   - Pie Chart: Bond Type split (100% Fixed).
   - Pivot Table: Multi-level matrix with Issuer, Sector, Credit Rating, Positions, Weight %, Duration, and Convexity.

3. **Page 3: Risk & Interest Rate Sensitivity**
   - KPI Cards: Total DV01, Dynamic Price Shock Impact (INR), Dynamic Portfolio Return %.
   - Tornado/Column Chart: Price Change Impact across $\pm 50, \pm 100, \pm 200\text{ bps}$.
   - Scatter Chart: Duration vs. Convexity trade-off by Issuer.
   - Interactive Slicer: `RateShockParameter` selecting target shock scenario.

4. **Page 4: Yield Curve Analysis**
   - Line Chart: Benchmark Term Structure (`ZeroRate` and `ParYield` across Tenors `3M` to `30Y`).
   - Column Chart: Net Spreads over Sovereign Benchmark by Key Rate Bucket.
   - Slicer: Curve Observation Date timeline.

5. **Page 5: Monte Carlo Simulation & VaR**
   - Column/Histogram: 1,000-scenario PnL frequency distribution.
   - KPI Cards: 95% VaR, 95% Expected Shortfall, 99% VaR, 99% Expected Shortfall.
   - Scatter Chart: Parallel Shift (bps) vs Simulated PnL (INR).
   - Waterfall Chart: Duration PnL effect vs. Convexity adjustment decomposition.

---

## 5. How to Open the Project in Power BI Desktop

Double-click `d:\INTERNSHIP2\power_bi\BondPortfolioRisk.pbip`, or in Power BI Desktop select **File > Open report** and choose `BondPortfolioRisk.pbip`.

