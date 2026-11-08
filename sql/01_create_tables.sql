-- ==============================================================================
-- Database Schema Setup: Bond Portfolio Risk & Convexity Analytics
-- Script: sql/01_create_tables.sql
-- Dialect: Microsoft SQL Server (T-SQL)
-- Description: Table definitions matching cleaned datasets in data/cleaned/
-- ==============================================================================

-- Drop tables if they already exist (safe deployment order)
IF OBJECT_ID('dbo.bond_portfolio_data', 'U') IS NOT NULL DROP TABLE dbo.bond_portfolio_data;
IF OBJECT_ID('dbo.monte_carlo_scenarios', 'U') IS NOT NULL DROP TABLE dbo.monte_carlo_scenarios;
IF OBJECT_ID('dbo.yield_curve_history', 'U') IS NOT NULL DROP TABLE dbo.yield_curve_history;
GO

-- ==============================================================================
-- 1. Table: dbo.bond_portfolio_data
-- Purpose: Position-level inventory of fixed-income holdings with cash-flow
--          characteristics, pricing, duration, and convexity metrics.
-- ==============================================================================
CREATE TABLE dbo.bond_portfolio_data (
    -- Identification
    BondID                      VARCHAR(20)     NOT NULL,
    ISIN                        VARCHAR(12)     NOT NULL,
    Issuer                      VARCHAR(100)    NOT NULL,
    Sector                      VARCHAR(50)     NOT NULL,
    CreditRating                VARCHAR(10)     NOT NULL,
    Currency                    CHAR(3)         NOT NULL,
    
    -- Structure & Dates
    FaceValue                   INT             NOT NULL,
    CouponRate                  DECIMAL(9, 6)   NOT NULL,
    CouponFrequency             INT             NOT NULL,
    BondType                    VARCHAR(20)     NOT NULL,
    IssueDate                   DATE            NOT NULL,
    MaturityDate                DATE            NOT NULL,
    ValuationDate               DATE            NOT NULL,
    YearsToMaturity             DECIMAL(9, 4)   NOT NULL,
    OriginalMaturityYears       INT             NOT NULL,
    
    -- Valuation & Pricing
    YieldToMaturity             DECIMAL(9, 6)   NOT NULL,
    CleanPrice                  DECIMAL(12, 4)  NOT NULL,
    AccruedInterest             DECIMAL(12, 4)  NOT NULL,
    DirtyPrice                  DECIMAL(12, 4)  NOT NULL,
    
    -- Risk & Sensitivity Metrics
    MacaulayDuration            DECIMAL(9, 4)   NOT NULL,
    ModifiedDuration            DECIMAL(9, 4)   NOT NULL,
    Convexity                   DECIMAL(12, 4)  NOT NULL,
    DV01_Per100Face             DECIMAL(9, 4)   NOT NULL,
    EffectiveDuration           DECIMAL(9, 4)   NOT NULL,
    EffectiveConvexity          DECIMAL(12, 4)  NOT NULL,
    SpreadOverBenchmark_bps     INT             NOT NULL,
    OAS_bps                     INT             NOT NULL,
    ZSpread_bps                 INT             NOT NULL,
    KeyRateBucket               VARCHAR(10)     NOT NULL,
    
    -- Position & Portfolio Weights
    Quantity                    INT             NOT NULL,
    MarketValue_LocalCcy        DECIMAL(18, 2)  NOT NULL,
    MarketValue_INR             DECIMAL(18, 2)  NOT NULL,
    PortfolioWeight             DECIMAL(10, 8)  NOT NULL,
    
    -- Embedded Options & Floating Attributes
    IsCallable                  BIT             NOT NULL,
    CallDate                    DATE            NULL,     -- Populated only for callable bonds (IsCallable = 1)
    IsPutable                   BIT             NOT NULL,
    IsFloatingRate              BIT             NOT NULL,
    BenchmarkIndex              VARCHAR(20)     NOT NULL,
    
    -- Rate Shock Scenarios (Up/Down 50, 100, 200 bps)
    PriceChange_Up50bps         DECIMAL(9, 4)   NOT NULL,
    PriceChange_Dn50bps         DECIMAL(9, 4)   NOT NULL,
    PriceChange_Up100bps        DECIMAL(9, 4)   NOT NULL,
    PriceChange_Dn100bps        DECIMAL(9, 4)   NOT NULL,
    PriceChange_Up200bps        DECIMAL(9, 4)   NOT NULL,
    PriceChange_Dn200bps        DECIMAL(9, 4)   NOT NULL,

    -- Constraints: Primary key supported by unique BondID
    CONSTRAINT PK_bond_portfolio_data PRIMARY KEY CLUSTERED (BondID),
    CONSTRAINT UQ_bond_portfolio_data_ISIN UNIQUE (ISIN)
);
GO

-- ==============================================================================
-- 2. Table: dbo.monte_carlo_scenarios
-- Purpose: Simulated yield curve shift scenarios and corresponding portfolio
--          PnL, duration effect, convexity adjustment, and VaR contributions.
-- ==============================================================================
CREATE TABLE dbo.monte_carlo_scenarios (
    ScenarioID                  INT             NOT NULL,
    ParallelShift_bps           DECIMAL(9, 2)   NOT NULL,
    TwistFactor_bps             DECIMAL(9, 2)   NOT NULL,
    ButterflyFactor_bps         DECIMAL(9, 2)   NOT NULL,
    PnL_DurationEffect_INR      DECIMAL(18, 2)  NOT NULL,
    PnL_ConvexityEffect_INR     DECIMAL(18, 2)  NOT NULL,
    PnL_Total_INR               DECIMAL(18, 2)  NOT NULL,
    PnL_Pct                     DECIMAL(9, 4)   NOT NULL,
    VaR_Contribution            DECIMAL(18, 2)  NOT NULL,

    -- Constraints: Primary key supported by unique ScenarioID
    CONSTRAINT PK_monte_carlo_scenarios PRIMARY KEY CLUSTERED (ScenarioID)
);
GO

-- ==============================================================================
-- 3. Table: dbo.yield_curve_history
-- Purpose: Historical zero-coupon and par yield curve term structures, forward
--          rates, and discount factors across 11 standard maturity tenors.
-- Note: A composite primary key on (CurveDate, Tenor_Years) is not enforced
--       because the source data contains dual observations on 2024-05-30.
--       A non-clustered index is provided for query optimization.
-- ==============================================================================
CREATE TABLE dbo.yield_curve_history (
    CurveDate                   DATE            NOT NULL,
    Currency                    CHAR(3)         NOT NULL,
    Tenor_Years                 DECIMAL(5, 2)   NOT NULL,
    TenorLabel                  VARCHAR(5)      NOT NULL,
    Yield                       DECIMAL(9, 6)   NOT NULL,
    ZeroRate                    DECIMAL(9, 6)   NOT NULL,
    ForwardRate                 DECIMAL(9, 6)   NOT NULL,
    DiscountFactor              DECIMAL(9, 6)   NOT NULL
);
GO

-- Create Index for efficient curve lookup and filtering
CREATE NONCLUSTERED INDEX IX_yield_curve_history_Date_Tenor 
ON dbo.yield_curve_history (CurveDate, Tenor_Years);
GO
