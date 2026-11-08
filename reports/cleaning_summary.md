# Data Cleaning Summary Report

**Project:** Bond Portfolio Risk & Convexity  
**Date of Execution:** 2026-10-27  
**Stage:** Stage 1 – Data Cleaning & Quality Audit  
**Status:** Completed (Conservative Approach)

---

## 1. Executive Summary

This report documents the conservative data cleaning and quality audit performed on the three primary project datasets located in `data/raw/`. 

All original raw files have been preserved completely intact. Standardized, cleaned datasets have been generated and exported to `data/cleaned/` following the naming convention `<original_name>_cleaned.csv`:
- `data/cleaned/bond_portfolio_data_cleaned.csv`
- `data/cleaned/monte_carlo_scenarios_cleaned.csv`
- `data/cleaned/yield_curve_history_cleaned.csv`

In accordance with strict conservative data engineering principles, no financial metrics (duration, convexity, DV01) were recalculated or modified, and no missing data was artificially fabricated.

---

## 2. Dataset-by-Dataset Audit & Cleaning Summary

### 2.1 Dataset: `bond_portfolio_data.csv`

| Metric | Details |
|---|---|
| **Original File** | `data/raw/bond_portfolio_data.csv` |
| **Cleaned File** | `data/cleaned/bond_portfolio_data_cleaned.csv` |
| **Rows Before Cleaning** | 300 |
| **Rows After Cleaning** | 300 |
| **Columns Count** | 44 |
| **Duplicates Removed** | 0 |
| **Missing Values Handled** | 283 in `CallDate` (preserved as legitimate structural nulls) |

#### Columns Changed & Formatted:
- **Date Formatting:** Standardized `IssueDate`, `MaturityDate`, `ValuationDate`, and `CallDate` into ISO-8601 format (`YYYY-MM-DD`).
- **Data Type Casting:** Explicitly cast boolean flags (`IsCallable`, `IsPutable`, `IsFloatingRate`), integer indicators (`FaceValue`, `CouponFrequency`, `OriginalMaturityYears`, `Quantity`, `SpreadOverBenchmark_bps`, `OAS_bps`, `ZSpread_bps`), and floating-point pricing and duration fields.
- **Categorical Trimming:** Standardized and trimmed text values across categorical fields (`Issuer`, `Sector`, `CreditRating`, `Currency`, `BondType`, `KeyRateBucket`, `BenchmarkIndex`).

#### Missing Values & Business Rule Analysis:
- `CallDate` contained **283 null values**. An audit revealed that exactly **17 bonds have `IsCallable = True`**, each possessing a valid `CallDate`. The remaining **283 bonds have `IsCallable = False`**, for which a call date is structurally inapplicable. No synthetic dates were invented; nulls were preserved as valid business representations of non-callable instruments.
- All other 43 columns contain **0 missing values** (100% complete).

#### Invalid Records & Quality Observations Identified:
1. **Date Logical Hierarchy:** All 300 records satisfied the chronological integrity rule:
   $$\text{IssueDate} < \text{ValuationDate} (2024-10-31) < \text{MaturityDate}$$
   All 17 `CallDate` records fall strictly between `IssueDate` and `MaturityDate`.
2. **Dirty Price vs. Clean Price Discrepancy:** In 295 out of 300 records, the reported `DirtyPrice` differs slightly from the sum of $\text{CleanPrice} + \text{AccruedInterest}$ by an amount ranging from 0.01 to 2.21 points (e.g., Row 0 has Clean = 99.0052, Accrued = 0.0411, but Dirty = 99.3134). In keeping with the conservative policy, the raw values were preserved and flagged for downstream valuation review rather than overwritten.
3. **Price Sensitivity Convention:** Columns `PriceChange_Up50bps`, `PriceChange_Up100bps`, and `PriceChange_Up200bps` report positive numerical values, representing the absolute price change / loss magnitude under upward yield shocks.

#### Assumptions Made:
- The base valuation date is uniform across the portfolio at `2024-10-31`.
- `MarketValue_LocalCcy` reflects `(Quantity * CleanPrice) / FaceValue`.
- Currency conversions to INR reflect fixed snapshot exchange rates (`USD ~ 83.50`, `EUR ~ 90.80`, `GBP ~ 105.20`, `AUD ~ 54.30`, `JPY ~ 0.56`, `INR = 1.00`).
- Total portfolio market value in INR sums to ₹32,059,345.97, and portfolio weights sum to 1.00000 (within $5 \times 10^{-7}$ rounding tolerance).

---

### 2.2 Dataset: `monte_carlo_scenarios.csv`

| Metric | Details |
|---|---|
| **Original File** | `data/raw/monte_carlo_scenarios.csv` |
| **Cleaned File** | `data/cleaned/monte_carlo_scenarios_cleaned.csv` |
| **Rows Before Cleaning** | 1,000 |
| **Rows After Cleaning** | 1,000 |
| **Columns Count** | 9 |
| **Duplicates Removed** | 0 |
| **Missing Values Handled** | 0 (0% missing) |

#### Columns Changed & Formatted:
- Explicitly cast `ScenarioID` to standard integer.
- Formatted floating-point precision for curve shock factors (`ParallelShift_bps`, `TwistFactor_bps`, `ButterflyFactor_bps`) and portfolio PnL outcomes (`PnL_DurationEffect_INR`, `PnL_ConvexityEffect_INR`, `PnL_Total_INR`, `PnL_Pct`, `VaR_Contribution`).

#### Missing Values & Duplicates:
- 0 missing values across all 9 columns.
- 0 duplicate rows; `ScenarioID` is unique and contiguous from 1 to 1,000.

#### Invalid Records & Quality Observations Identified:
1. **PnL Additivity Verification:** Verified that:
   $$\text{PnL\_Total\_INR} \approx \text{PnL\_DurationEffect\_INR} + \text{PnL\_ConvexityEffect\_INR}$$
   The relationship holds across all 1,000 scenarios within standard numerical rounding tolerance (maximum discrepancy $\le 0.01$ INR).
2. **Convexity Contribution:** All convexity effects (`PnL_ConvexityEffect_INR`) are non-negative ($\ge 0.01$ INR), correctly reflecting positive portfolio convexity buffering rate swings.
3. **VaR Metric Relationship:** Verified that `VaR_Contribution` matches $|\text{PnL\_Total\_INR}|$, representing the loss magnitude used for tail-risk percentile ordering.

#### Assumptions Made:
- The 1,000 Monte Carlo scenarios represent a pre-generated joint distribution of curve shifts (level, slope/twist, curvature/butterfly).
- No scenario rows were altered, dropped, or simulated afresh.

---

### 2.3 Dataset: `yield_curve_history.csv`

| Metric | Details |
|---|---|
| **Original File** | `data/raw/yield_curve_history.csv` |
| **Cleaned File** | `data/cleaned/yield_curve_history_cleaned.csv` |
| **Rows Before Cleaning** | 264 |
| **Rows After Cleaning** | 264 |
| **Columns Count** | 8 |
| **Duplicates Removed** | 0 |
| **Missing Values Handled** | 0 (0% missing) |

#### Columns Changed & Formatted:
- **Date Formatting:** Standardized `CurveDate` to ISO-8601 string (`YYYY-MM-DD`).
- **Text Trimming:** Standardized `Currency` and `TenorLabel` strings.
- **Float Casting:** Cast `Tenor_Years`, `Yield`, `ZeroRate`, `ForwardRate`, and `DiscountFactor` to 64-bit floats.

#### Missing Values & Duplicates:
- 0 missing values across all columns.
- 0 duplicate records across the composite key `(CurveDate, Tenor_Years)`.

#### Invalid Records & Quality Observations Identified:
1. **Grid Completeness:** Exactly 24 historical observation dates spanning `2022-12-30` to `2024-10-30`. Each date contains the complete standard 11-tenor spectrum:
   `[3M, 6M, 1Y, 2Y, 3Y, 5Y, 7Y, 10Y, 15Y, 20Y, 30Y]` ($24 \times 11 = 264$ records).
2. **Economic Viability:** 
   - All yields and spot rates fall within a realistic sovereign range ($6.04\%$ to $7.96\%$).
   - Discount factors are strictly bounded within $(0, 1)$ and are monotonically decreasing with tenor maturity.

#### Assumptions Made:
- The history provides historical benchmarks for INR curve calibration and scenario stress-testing.

---

## 3. Data Integrity & Verification Summary

| Dataset | Raw Record Count | Cleaned Record Count | Missing Data Rate | Schema Status |
|---|---|---|---|---|
| **Bond Portfolio Data** | 300 | 300 | 0.0% (excl. CallDate) | Verified & Validated |
| **Monte Carlo Scenarios** | 1,000 | 1,000 | 0.0% | Verified & Validated |
| **Yield Curve History** | 264 | 264 | 0.0% | Verified & Validated |

All cleaned files have been written to `data/cleaned/` with UTF-8 encoding and preserved headers.
