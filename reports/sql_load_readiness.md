# SQL Ingestion Readiness Verification Report

**Project:** Bond Portfolio Risk & Convexity Analytics  
**Date:** 2026-11-01  
**Artifact Evaluated:** [sql/02_load_data.sql](file:///d:/INTERNSHIP2/sql/02_load_data.sql)  
**Schema Definition:** [sql/01_create_tables.sql](file:///d:/INTERNSHIP2/sql/01_create_tables.sql)  
**Source Datasets:**  
1. [data/cleaned/bond_portfolio_data_cleaned.csv](file:///d:/INTERNSHIP2/data/cleaned/bond_portfolio_data_cleaned.csv)
2. [data/cleaned/monte_carlo_scenarios_cleaned.csv](file:///d:/INTERNSHIP2/data/cleaned/monte_carlo_scenarios_cleaned.csv)
3. [data/cleaned/yield_curve_history_cleaned.csv](file:///d:/INTERNSHIP2/data/cleaned/yield_curve_history_cleaned.csv)

---

## 1. Executive Summary & Verification Checklist

| # | Verification Check | Status | Key Finding Summary |
|---|---|:---:|---|
| 1 | File Paths Existence | **PASS** | All 3 cleaned CSV files exist at the specified absolute filesystem locations. |
| 2 | CSV Headers vs. SQL Columns | **PASS** | Column counts and header names match SQL table definitions 100% across all 3 tables. |
| 3 | Exact Column Order Alignment | **PASS** | Column sequential order in CSVs matches `CREATE TABLE` definitions exactly. |
| 4 | Data Type Compatibility | **FAIL** | Scientific notation in `PortfolioWeight` and `'True'`/`'False'` strings in `BIT` columns. |
| 5 | NULL vs. NOT NULL Constraints | **PASS** | Zero NOT NULL constraint violations. Only `CallDate` contains empty values (`DATE NULL`). |
| 6 | BULK INSERT Settings Compatibility | **FAIL** | `ROWTERMINATOR = '\n'` fails on Windows CRLF files (`\r\n`), corrupting the final column. |

**Overall Readiness Status:** **FAIL (NOT READY FOR EXECUTION)**  
Execution of `sql/02_load_data.sql` in its current state will abort with runtime conversion errors.

---

## 2. Detailed Verification Findings

### Check 1: File Paths Existence (**PASS**)
All file paths referenced in [sql/02_load_data.sql](file:///d:/INTERNSHIP2/sql/02_load_data.sql) were verified on the local disk:
* `D:\INTERNSHIP2\data\cleaned\bond_portfolio_data_cleaned.csv` — **Found** (93,109 bytes, 301 lines).
* `D:\INTERNSHIP2\data\cleaned\monte_carlo_scenarios_cleaned.csv` — **Found** (71,872 bytes, 1,001 lines).
* `D:\INTERNSHIP2\data\cleaned\yield_curve_history_cleaned.csv` — **Found** (15,769 bytes, 265 lines).

---

### Check 2: CSV Headers Match SQL Table Columns (**PASS**)
Header names and column counts were cross-checked against [sql/01_create_tables.sql](file:///d:/INTERNSHIP2/sql/01_create_tables.sql):
* **`dbo.bond_portfolio_data`**: 44 CSV headers match all 44 SQL columns exactly (names, casing, and count).
* **`dbo.monte_carlo_scenarios`**: 9 CSV headers match all 9 SQL columns exactly.
* **`dbo.yield_curve_history`**: 8 CSV headers match all 8 SQL columns exactly.

---

### Check 3: Column Order Matches Exactly (**PASS**)
Sequential column indexing in each CSV file was compared position-by-position against the corresponding SQL table schema:
* **`dbo.bond_portfolio_data`**: Columns 1 to 44 match 1-to-1 from `BondID` through `PriceChange_Dn200bps`.
* **`dbo.monte_carlo_scenarios`**: Columns 1 to 9 match 1-to-1 from `ScenarioID` through `VaR_Contribution`.
* **`dbo.yield_curve_history`**: Columns 1 to 8 match 1-to-1 from `CurveDate` through `DiscountFactor`.

---

### Check 4: Data Type Compatibility (**FAIL**)
Data values were evaluated against the SQL Server data types defined in DDL:
* **`dbo.yield_curve_history`**: All columns (`DATE`, `CHAR(3)`, `DECIMAL(5,2)`, `VARCHAR(5)`, `DECIMAL(9,6)`) are compatible.
* **`dbo.monte_carlo_scenarios`**: All columns (`INT`, `DECIMAL(9,2)`, `DECIMAL(18,2)`, `DECIMAL(9,4)`) are compatible.
* **`dbo.bond_portfolio_data`**: **INCOMPATIBLE (2 defects found)**:
  1. **Scientific Notation in Decimal Column (`PortfolioWeight`)**:  
     The table defines `PortfolioWeight DECIMAL(10, 8) NOT NULL`. The cleaned CSV contains **11 records** formatted in scientific exponential notation (e.g., `'1e-06'`, `'8e-06'`, `'2e-06'`, `'8.4e-05'`, `'1.7e-05'`). SQL Server's bulk ingestion parser cannot cast exponential notation into `DECIMAL`/`NUMERIC`, triggering `Error converting data type varchar to numeric`.
  2. **Text Boolean Literals in `BIT` Columns (`IsCallable`, `IsPutable`, `IsFloatingRate`)**:  
     The table defines these columns as `BIT NOT NULL`. The CSV contains string literals `'True'` and `'False'`. SQL Server `BULK INSERT` in character mode does not perform implicit string-to-boolean conversion and strictly expects `1` or `0`, causing `Msg 4864 (Bulk load data conversion error)`.

---

### Check 5: NULL Values vs. NOT NULL Constraints (**PASS**)
Nullability across all rows was checked against table column constraints:
* **`dbo.bond_portfolio_data`**:
  * 43 columns are defined as `NOT NULL`: **0 nulls / 0 empty strings found** across all 300 rows.
  * 1 column is defined as `DATE NULL` (`CallDate`): Contains **283 empty cells** (corresponding to non-callable bonds where `IsCallable = False`) and **17 valid ISO dates** (`YYYY-MM-DD`). Because `CallDate` permits NULLs, this conforms to the constraint.
* **`dbo.monte_carlo_scenarios`**: All 9 columns are `NOT NULL`: **0 nulls / 0 empty strings found** across all 1,000 rows.
* **`dbo.yield_curve_history`**: All 8 columns are `NOT NULL`: **0 nulls / 0 empty strings found** across all 264 rows.

---

### Check 6: BULK INSERT Settings Compatibility (**FAIL**)
Evaluation of `BULK INSERT ... WITH (...)` options in [sql/02_load_data.sql](file:///d:/INTERNSHIP2/sql/02_load_data.sql):
* `FIRSTROW = 2`: **Correct** (skips CSV header line).
* `FIELDTERMINATOR = ','`: **Correct** (fields are comma-delimited without unescaped comma conflicts).
* `KEEPNULLS`: **Correct** (ensures empty `CallDate` fields are ingested as `NULL`).
* `TABLOCK`: **Correct** (standard bulk logging optimization).
* **`ROWTERMINATOR = '\n'`**: **FATAL MISCONFIGURATION**:
  * All three CSV files are formatted with **Windows CRLF line terminators (`\r\n` / `0x0D 0x0A`)**.
  * Specifying `ROWTERMINATOR = '\n'` causes SQL Server to treat only `\n` (`0x0A`) as the line break, leaving the carriage return character `\r` (`0x0D`) appended to the final column of every row.
  * In all three tables, the final column is a fixed numeric decimal:
    * `dbo.bond_portfolio_data` col 44: `PriceChange_Dn200bps DECIMAL(9, 4)`
    * `dbo.monte_carlo_scenarios` col 9: `VaR_Contribution DECIMAL(18, 2)`
    * `dbo.yield_curve_history` col 8: `DiscountFactor DECIMAL(9, 6)`
  * Parsing strings with trailing carriage returns (e.g., `"-3.5736\r"`) into `DECIMAL` fails immediately with `Msg 4864 Bulk load data conversion error`.

---

## 3. Recommended Remediation Plan (Informational Only)

To enable successful ingestion without modifying database structures:
1. **Source Data Formatting (`scripts/clean_datasets.py`)**:
   * Format `PortfolioWeight` using fixed-point representation (e.g., `float_format='%.8f'`) to prevent exponential output.
   * Format boolean columns as integer flags (`1` and `0`) instead of `'True'` and `'False'`.
2. **Bulk Ingestion Script (`sql/02_load_data.sql`)**:
   * Update row terminator to `ROWTERMINATOR = '\r\n'` (or use `ROWTERMINATOR = '0x0a'` if converted to LF).
