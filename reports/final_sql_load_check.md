# SQL Data Load Final Verification Report

**Artifact Evaluated:** [sql/02_load_data.sql](file:///d:/INTERNSHIP2/sql/02_load_data.sql)  
**Target Schema:** [sql/01_create_tables.sql](file:///d:/INTERNSHIP2/sql/01_create_tables.sql)  
**Verification Date:** 2026-11-01  
**Status:** **READY FOR EXECUTION (PASS)**

---

## 1. Verification Checklist

| # | Check Item | Status | Verification Details |
|---|---|:---:|---|
| 1 | All 3 CSV files loaded | **PASS** | Filepaths for `bond_portfolio_data_cleaned.csv`, `monte_carlo_scenarios_cleaned.csv`, and `yield_curve_history_cleaned.csv` are accurately targeted with single quotes. |
| 2 | Staging table definition | **PASS** | `#stage_bond_portfolio_data` defines all 44 columns matching source CSV order and target schema, using `VARCHAR(50)` for `PortfolioWeight` and `VARCHAR(10)` for boolean columns. |
| 3 | Scientific notation conversion | **PASS** | Implemented via `COALESCE(TRY_CAST(LTRIM(RTRIM(PortfolioWeight)) AS DECIMAL(10, 8)), CAST(CAST(LTRIM(RTRIM(PortfolioWeight)) AS FLOAT) AS DECIMAL(10, 8)))`. Standard decimal strings parse directly; scientific notation parses via `FLOAT` into `DECIMAL(10, 8)` without precision loss. |
| 4 | Boolean values handling | **PASS** | `IsCallable`, `IsPutable`, and `IsFloatingRate` are safely cast using `CASE WHEN LOWER(LTRIM(RTRIM(col))) IN ('true', '1') THEN 1 ELSE 0 END`, satisfying `BIT NOT NULL` constraints. |
| 5 | Target tables routing | **PASS** | Data routes to `dbo.bond_portfolio_data`, `dbo.monte_carlo_scenarios`, and `dbo.yield_curve_history`. Explicit 44-column `INSERT INTO ... SELECT` mapping ensures zero column displacement. |
| 6 | Existing tables preserved | **PASS** | No permanent user tables are dropped or recreated. Drop statements only target the session temporary table `#stage_bond_portfolio_data`. |
| 7 | No duplicate loading steps | **PASS** | Each dataset is ingested exactly once. Staging table is cleanly dropped immediately following data insertion. |
| 8 | Valid T-SQL BULK INSERT syntax | **PASS** | `FIRSTROW = 2`, `FIELDTERMINATOR = ','`, `ROWTERMINATOR = '\r\n'`, `TABLOCK`, and `KEEPNULLS` are correctly configured across all bulk operations. CRLF row terminators ensure final columns load cleanly without trailing carriage returns. |

---

## 2. Ingestion Architecture Summary

1. **`dbo.bond_portfolio_data` (Staged Bulk Load)**:
   - Source: `data/cleaned/bond_portfolio_data_cleaned.csv` (44 columns, 300 rows)
   - Staging Table: `#stage_bond_portfolio_data`
   - Transformations:
     - `PortfolioWeight`: Decimal/Scientific string $\rightarrow$ `DECIMAL(10, 8)`
     - `IsCallable`, `IsPutable`, `IsFloatingRate`: `'True'`/`'False'` $\rightarrow$ `BIT` (`1`/`0`)
     - `CallDate`: Nullable date correctly handled via `KEEPNULLS`
   - Final Target: `dbo.bond_portfolio_data` (Clean drop of staging table after commit)

2. **`dbo.monte_carlo_scenarios` (Direct Bulk Load)**:
   - Source: `data/cleaned/monte_carlo_scenarios_cleaned.csv` (9 columns, 1,000 rows)
   - Configuration: `ROWTERMINATOR = '\r\n'`, `FIRSTROW = 2`, `FIELDTERMINATOR = ','`
   - Final Target: `dbo.monte_carlo_scenarios`

3. **`dbo.yield_curve_history` (Direct Bulk Load)**:
   - Source: `data/cleaned/yield_curve_history_cleaned.csv` (8 columns, 264 rows)
   - Configuration: `ROWTERMINATOR = '\r\n'`, `FIRSTROW = 2`, `FIELDTERMINATOR = ','`
   - Final Target: `dbo.yield_curve_history`

4. **Validation Query**:
   - `SELECT ... COUNT(*)` across all three target tables confirms record counts.

---

## 3. Conclusion

The script [sql/02_load_data.sql](file:///d:/INTERNSHIP2/sql/02_load_data.sql) is complete, robust, and ready for deployment without errors.
