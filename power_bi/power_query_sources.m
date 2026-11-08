// ==============================================================================
// Bond Portfolio Risk & Convexity Analytics - Power Query M Expressions
// File: d:\INTERNSHIP2\power_bi\power_query_sources.m
// Target Database: SQL Server [BondPortfolioRisk] on localhost / .
// ==============================================================================

// Query 1: bond_portfolio_data
let
    Source = Sql.Database(".", "BondPortfolioRisk"),
    dbo_bond_portfolio_data = Source{[Schema="dbo",Item="bond_portfolio_data"]}[Data],
    #"Changed Types" = Table.TransformColumnTypes(dbo_bond_portfolio_data,{
        {"BondID", type text},
        {"ISIN", type text},
        {"Issuer", type text},
        {"Sector", type text},
        {"CreditRating", type text},
        {"Currency", type text},
        {"FaceValue", Int64.Type},
        {"CouponRate", type number},
        {"CouponFrequency", Int64.Type},
        {"BondType", type text},
        {"IssueDate", type date},
        {"MaturityDate", type date},
        {"ValuationDate", type date},
        {"YearsToMaturity", type number},
        {"OriginalMaturityYears", Int64.Type},
        {"YieldToMaturity", type number},
        {"CleanPrice", type number},
        {"AccruedInterest", type number},
        {"DirtyPrice", type number},
        {"MacaulayDuration", type number},
        {"ModifiedDuration", type number},
        {"Convexity", type number},
        {"DV01_Per100Face", type number},
        {"EffectiveDuration", type number},
        {"EffectiveConvexity", type number},
        {"SpreadOverBenchmark_bps", Int64.Type},
        {"OAS_bps", Int64.Type},
        {"ZSpread_bps", Int64.Type},
        {"KeyRateBucket", type text},
        {"Quantity", Int64.Type},
        {"MarketValue_LocalCcy", type number},
        {"MarketValue_INR", type number},
        {"PortfolioWeight", type number},
        {"IsCallable", type logical},
        {"CallDate", type date},
        {"IsPutable", type logical},
        {"IsFloatingRate", type logical},
        {"BenchmarkIndex", type text},
        {"PriceChange_Up50bps", type number},
        {"PriceChange_Dn50bps", type number},
        {"PriceChange_Up100bps", type number},
        {"PriceChange_Dn100bps", type number},
        {"PriceChange_Up200bps", type number},
        {"PriceChange_Dn200bps", type number}
    })
in
    #"Changed Types"

// Query 2: monte_carlo_scenarios
let
    Source = Sql.Database(".", "BondPortfolioRisk"),
    dbo_monte_carlo_scenarios = Source{[Schema="dbo",Item="monte_carlo_scenarios"]}[Data],
    #"Changed Types" = Table.TransformColumnTypes(dbo_monte_carlo_scenarios,{
        {"ScenarioID", Int64.Type},
        {"ParallelShift_bps", type number},
        {"TwistFactor_bps", type number},
        {"ButterflyFactor_bps", type number},
        {"PnL_DurationEffect_INR", type number},
        {"PnL_ConvexityEffect_INR", type number},
        {"PnL_Total_INR", type number},
        {"PnL_Pct", type number},
        {"VaR_Contribution", type number}
    })
in
    #"Changed Types"

// Query 3: yield_curve_history
let
    Source = Sql.Database(".", "BondPortfolioRisk"),
    dbo_yield_curve_history = Source{[Schema="dbo",Item="yield_curve_history"]}[Data],
    #"Changed Types" = Table.TransformColumnTypes(dbo_yield_curve_history,{
        {"CurveDate", type date},
        {"Currency", type text},
        {"Tenor_Years", type number},
        {"TenorLabel", type text},
        {"Yield", type number},
        {"ZeroRate", type number},
        {"ForwardRate", type number},
        {"DiscountFactor", type number}
    })
in
    #"Changed Types"

