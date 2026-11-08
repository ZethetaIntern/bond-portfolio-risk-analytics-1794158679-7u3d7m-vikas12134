import json
import os

BASE_DIR = r"D:\INTERNSHIP2\power_bi"
SEMANTIC_DIR = os.path.join(BASE_DIR, "BondPortfolioRisk.SemanticModel")
REPORT_DIR = os.path.join(BASE_DIR, "BondPortfolioRisk.Report")

os.makedirs(SEMANTIC_DIR, exist_ok=True)
os.makedirs(REPORT_DIR, exist_ok=True)

# ------------------------------------------------------------------------------
# 1. model.bim (Semantic Model Definition)
# ------------------------------------------------------------------------------
model_bim = {
    "name": "BondPortfolioRisk",
    "compatibilityLevel": 1567,
    "model": {
        "culture": "en-US",
        "dataAccessOptions": {
            "legacyRedirects": True,
            "returnErrorValuesAsNull": True
        },
        "defaultPowerBIDataSourceVersion": "powerBI_V3",
        "sourceQueryCulture": "en-US",
        "tables": [
            {
                "name": "bond_portfolio_data",
                "columns": [
                    {"name": "BondID", "dataType": "string", "sourceColumn": "BondID", "isKey": True},
                    {"name": "ISIN", "dataType": "string", "sourceColumn": "ISIN"},
                    {"name": "Issuer", "dataType": "string", "sourceColumn": "Issuer"},
                    {"name": "Sector", "dataType": "string", "sourceColumn": "Sector"},
                    {"name": "CreditRating", "dataType": "string", "sourceColumn": "CreditRating"},
                    {"name": "Currency", "dataType": "string", "sourceColumn": "Currency"},
                    {"name": "FaceValue", "dataType": "int64", "sourceColumn": "FaceValue", "formatString": "#,0"},
                    {"name": "CouponRate", "dataType": "double", "sourceColumn": "CouponRate", "formatString": "0.0000%"},
                    {"name": "CouponFrequency", "dataType": "int64", "sourceColumn": "CouponFrequency"},
                    {"name": "BondType", "dataType": "string", "sourceColumn": "BondType"},
                    {"name": "IssueDate", "dataType": "dateTime", "sourceColumn": "IssueDate", "formatString": "yyyy-MM-dd"},
                    {"name": "MaturityDate", "dataType": "dateTime", "sourceColumn": "MaturityDate", "formatString": "yyyy-MM-dd"},
                    {"name": "ValuationDate", "dataType": "dateTime", "sourceColumn": "ValuationDate", "formatString": "yyyy-MM-dd"},
                    {"name": "YearsToMaturity", "dataType": "double", "sourceColumn": "YearsToMaturity", "formatString": "0.00"},
                    {"name": "OriginalMaturityYears", "dataType": "int64", "sourceColumn": "OriginalMaturityYears"},
                    {"name": "YieldToMaturity", "dataType": "double", "sourceColumn": "YieldToMaturity", "formatString": "0.0000%"},
                    {"name": "CleanPrice", "dataType": "double", "sourceColumn": "CleanPrice", "formatString": "#,0.0000"},
                    {"name": "AccruedInterest", "dataType": "double", "sourceColumn": "AccruedInterest", "formatString": "#,0.0000"},
                    {"name": "DirtyPrice", "dataType": "double", "sourceColumn": "DirtyPrice", "formatString": "#,0.0000"},
                    {"name": "MacaulayDuration", "dataType": "double", "sourceColumn": "MacaulayDuration", "formatString": "0.0000"},
                    {"name": "ModifiedDuration", "dataType": "double", "sourceColumn": "ModifiedDuration", "formatString": "0.0000"},
                    {"name": "Convexity", "dataType": "double", "sourceColumn": "Convexity", "formatString": "0.0000"},
                    {"name": "DV01_Per100Face", "dataType": "double", "sourceColumn": "DV01_Per100Face", "formatString": "0.0000"},
                    {"name": "EffectiveDuration", "dataType": "double", "sourceColumn": "EffectiveDuration", "formatString": "0.0000"},
                    {"name": "EffectiveConvexity", "dataType": "double", "sourceColumn": "EffectiveConvexity", "formatString": "0.0000"},
                    {"name": "SpreadOverBenchmark_bps", "dataType": "int64", "sourceColumn": "SpreadOverBenchmark_bps", "formatString": "#,0"},
                    {"name": "OAS_bps", "dataType": "int64", "sourceColumn": "OAS_bps", "formatString": "#,0"},
                    {"name": "ZSpread_bps", "dataType": "int64", "sourceColumn": "ZSpread_bps", "formatString": "#,0"},
                    {"name": "KeyRateBucket", "dataType": "string", "sourceColumn": "KeyRateBucket"},
                    {"name": "Quantity", "dataType": "int64", "sourceColumn": "Quantity", "formatString": "#,0"},
                    {"name": "MarketValue_LocalCcy", "dataType": "double", "sourceColumn": "MarketValue_LocalCcy", "formatString": "#,0.00"},
                    {"name": "MarketValue_INR", "dataType": "double", "sourceColumn": "MarketValue_INR", "formatString": "₹#,0.00"},
                    {"name": "PortfolioWeight", "dataType": "double", "sourceColumn": "PortfolioWeight", "formatString": "0.0000%"},
                    {"name": "IsCallable", "dataType": "boolean", "sourceColumn": "IsCallable"},
                    {"name": "CallDate", "dataType": "dateTime", "sourceColumn": "CallDate", "formatString": "yyyy-MM-dd"},
                    {"name": "IsPutable", "dataType": "boolean", "sourceColumn": "IsPutable"},
                    {"name": "IsFloatingRate", "dataType": "boolean", "sourceColumn": "IsFloatingRate"},
                    {"name": "BenchmarkIndex", "dataType": "string", "sourceColumn": "BenchmarkIndex"},
                    {"name": "PriceChange_Up50bps", "dataType": "double", "sourceColumn": "PriceChange_Up50bps", "formatString": "+0.0000;-0.0000;0.0000"},
                    {"name": "PriceChange_Dn50bps", "dataType": "double", "sourceColumn": "PriceChange_Dn50bps", "formatString": "+0.0000;-0.0000;0.0000"},
                    {"name": "PriceChange_Up100bps", "dataType": "double", "sourceColumn": "PriceChange_Up100bps", "formatString": "+0.0000;-0.0000;0.0000"},
                    {"name": "PriceChange_Dn100bps", "dataType": "double", "sourceColumn": "PriceChange_Dn100bps", "formatString": "+0.0000;-0.0000;0.0000"},
                    {"name": "PriceChange_Up200bps", "dataType": "double", "sourceColumn": "PriceChange_Up200bps", "formatString": "+0.0000;-0.0000;0.0000"},
                    {"name": "PriceChange_Dn200bps", "dataType": "double", "sourceColumn": "PriceChange_Dn200bps", "formatString": "+0.0000;-0.0000;0.0000"},
                    {
                        "type": "calculated",
                        "name": "MaturityYear",
                        "dataType": "int64",
                        "isDataTypeInferred": True,
                        "expression": "YEAR('bond_portfolio_data'[MaturityDate])"
                    }
                ],
                "partitions": [
                    {
                        "name": "bond_portfolio_data-Partition",
                        "mode": "import",
                        "source": {
                            "type": "m",
                            "expression": [
                                "let",
                                '    Source = Sql.Database(".", "BondPortfolioRisk"),',
                                '    dbo_bond_portfolio_data = Source{[Schema="dbo",Item="bond_portfolio_data"]}[Data]',
                                "in",
                                "    dbo_bond_portfolio_data"
                            ]
                        }
                    }
                ]
            },
            {
                "name": "monte_carlo_scenarios",
                "columns": [
                    {"name": "ScenarioID", "dataType": "int64", "sourceColumn": "ScenarioID", "isKey": True},
                    {"name": "ParallelShift_bps", "dataType": "double", "sourceColumn": "ParallelShift_bps", "formatString": "0.00"},
                    {"name": "TwistFactor_bps", "dataType": "double", "sourceColumn": "TwistFactor_bps", "formatString": "0.00"},
                    {"name": "ButterflyFactor_bps", "dataType": "double", "sourceColumn": "ButterflyFactor_bps", "formatString": "0.00"},
                    {"name": "PnL_DurationEffect_INR", "dataType": "double", "sourceColumn": "PnL_DurationEffect_INR", "formatString": "₹#,0.00"},
                    {"name": "PnL_ConvexityEffect_INR", "dataType": "double", "sourceColumn": "PnL_ConvexityEffect_INR", "formatString": "₹#,0.00"},
                    {"name": "PnL_Total_INR", "dataType": "double", "sourceColumn": "PnL_Total_INR", "formatString": "₹#,0.00"},
                    {"name": "PnL_Pct", "dataType": "double", "sourceColumn": "PnL_Pct", "formatString": "0.0000%"},
                    {"name": "VaR_Contribution", "dataType": "double", "sourceColumn": "VaR_Contribution", "formatString": "₹#,0.00"}
                ],
                "partitions": [
                    {
                        "name": "monte_carlo_scenarios-Partition",
                        "mode": "import",
                        "source": {
                            "type": "m",
                            "expression": [
                                "let",
                                '    Source = Sql.Database(".", "BondPortfolioRisk"),',
                                '    dbo_monte_carlo_scenarios = Source{[Schema="dbo",Item="monte_carlo_scenarios"]}[Data]',
                                "in",
                                "    dbo_monte_carlo_scenarios"
                            ]
                        }
                    }
                ]
            },
            {
                "name": "yield_curve_history",
                "columns": [
                    {"name": "CurveDate", "dataType": "dateTime", "sourceColumn": "CurveDate", "formatString": "yyyy-MM-dd"},
                    {"name": "Currency", "dataType": "string", "sourceColumn": "Currency"},
                    {"name": "Tenor_Years", "dataType": "double", "sourceColumn": "Tenor_Years", "formatString": "0.00"},
                    {"name": "TenorLabel", "dataType": "string", "sourceColumn": "TenorLabel"},
                    {"name": "Yield", "dataType": "double", "sourceColumn": "Yield", "formatString": "0.0000%"},
                    {"name": "ZeroRate", "dataType": "double", "sourceColumn": "ZeroRate", "formatString": "0.0000%"},
                    {"name": "ForwardRate", "dataType": "double", "sourceColumn": "ForwardRate", "formatString": "0.0000%"},
                    {"name": "DiscountFactor", "dataType": "double", "sourceColumn": "DiscountFactor", "formatString": "0.000000"}
                ],
                "partitions": [
                    {
                        "name": "yield_curve_history-Partition",
                        "mode": "import",
                        "source": {
                            "type": "m",
                            "expression": [
                                "let",
                                '    Source = Sql.Database(".", "BondPortfolioRisk"),',
                                '    dbo_yield_curve_history = Source{[Schema="dbo",Item="yield_curve_history"]}[Data]',
                                "in",
                                "    dbo_yield_curve_history"
                            ]
                        }
                    }
                ]
            },
            {
                "name": "_KeyRateMapping",
                "columns": [
                    {"type": "calculatedTableColumn", "name": "KeyRateBucket", "dataType": "string", "isNameInferred": True, "isDataTypeInferred": True, "sourceColumn": "[KeyRateBucket]", "isKey": True},
                    {"type": "calculatedTableColumn", "name": "TenorLabel", "dataType": "string", "isNameInferred": True, "isDataTypeInferred": True, "sourceColumn": "[TenorLabel]"},
                    {"type": "calculatedTableColumn", "name": "Tenor_Years", "dataType": "double", "isNameInferred": True, "isDataTypeInferred": True, "sourceColumn": "[Tenor_Years]"},
                    {"type": "calculatedTableColumn", "name": "BucketOrder", "dataType": "int64", "isNameInferred": True, "isDataTypeInferred": True, "sourceColumn": "[BucketOrder]"}
                ],
                "partitions": [
                    {
                        "name": "_KeyRateMapping-Partition",
                        "mode": "import",
                        "source": {
                            "type": "calculated",
                            "expression": (
                                'DATATABLE(\n'
                                '    "KeyRateBucket", STRING,\n'
                                '    "TenorLabel", STRING,\n'
                                '    "Tenor_Years", DOUBLE,\n'
                                '    "BucketOrder", INTEGER,\n'
                                '    {\n'
                                '        {"0-1Y", "1Y", 1.0, 1},\n'
                                '        {"1-2Y", "2Y", 2.0, 2},\n'
                                '        {"2-3Y", "3Y", 3.0, 3},\n'
                                '        {"3-5Y", "5Y", 5.0, 4},\n'
                                '        {"5-7Y", "7Y", 7.0, 5},\n'
                                '        {"7-10Y", "10Y", 10.0, 6},\n'
                                '        {"10-15Y", "15Y", 15.0, 7},\n'
                                '        {"15-20Y", "20Y", 20.0, 8},\n'
                                '        {"20Y+", "30Y", 30.0, 9}\n'
                                '    }\n'
                                ')'
                            )
                        }
                    }
                ]
            },
            {
                "name": "RateShockParameter",
                "columns": [
                    {"type": "calculatedTableColumn", "name": "ScenarioName", "dataType": "string", "isNameInferred": True, "isDataTypeInferred": True, "sourceColumn": "[ScenarioName]"},
                    {"type": "calculatedTableColumn", "name": "Shock_bps", "dataType": "int64", "isNameInferred": True, "isDataTypeInferred": True, "sourceColumn": "[Shock_bps]"},
                    {"type": "calculatedTableColumn", "name": "Direction", "dataType": "string", "isNameInferred": True, "isDataTypeInferred": True, "sourceColumn": "[Direction]"},
                    {"type": "calculatedTableColumn", "name": "SortOrder", "dataType": "int64", "isNameInferred": True, "isDataTypeInferred": True, "sourceColumn": "[SortOrder]"}
                ],
                "partitions": [
                    {
                        "name": "RateShockParameter-Partition",
                        "mode": "import",
                        "source": {
                            "type": "calculated",
                            "expression": (
                                'DATATABLE(\n'
                                '    "ScenarioName", STRING,\n'
                                '    "Shock_bps", INTEGER,\n'
                                '    "Direction", STRING,\n'
                                '    "SortOrder", INTEGER,\n'
                                '    {\n'
                                '        {"Rate Shock -200 bps", -200, "Downward", 1},\n'
                                '        {"Rate Shock -100 bps", -100, "Downward", 2},\n'
                                '        {"Rate Shock  -50 bps",  -50, "Downward", 3},\n'
                                '        {"Rate Shock  +50 bps",   50, "Upward",   4},\n'
                                '        {"Rate Shock +100 bps",  100, "Upward",   5},\n'
                                '        {"Rate Shock +200 bps",  200, "Upward",   6}\n'
                                '    }\n'
                                ')'
                            )
                        }
                    }
                ]
            },
            {
                "name": "_Measures",
                "columns": [
                    {"type": "calculatedTableColumn", "name": "MeasureCategory", "dataType": "string", "isNameInferred": True, "isDataTypeInferred": True, "sourceColumn": "[MeasureCategory]", "isHidden": True}
                ],
                "partitions": [
                    {
                        "name": "_Measures-Partition",
                        "mode": "import",
                        "source": {
                            "type": "calculated",
                            "expression": 'ROW("MeasureCategory", "Portfolio Core Measures")'
                        }
                    }
                ],
                "measures": [
                    {
                        "name": "Total Bonds",
                        "expression": "COUNTROWS('bond_portfolio_data')",
                        "formatString": "#,0"
                    },
                    {
                        "name": "Total Portfolio Market Value",
                        "expression": "SUM('bond_portfolio_data'[MarketValue_INR])",
                        "formatString": "₹#,0.00"
                    },
                    {
                        "name": "Average Coupon Rate",
                        "expression": "AVERAGE('bond_portfolio_data'[CouponRate])",
                        "formatString": "0.0000%"
                    },
                    {
                        "name": "Weighted Average Coupon Rate",
                        "expression": "DIVIDE(SUMX('bond_portfolio_data', 'bond_portfolio_data'[CouponRate] * 'bond_portfolio_data'[MarketValue_INR]), [Total Portfolio Market Value], 0)",
                        "formatString": "0.0000%"
                    },
                    {
                        "name": "Portfolio Weight %",
                        "expression": "DIVIDE([Total Portfolio Market Value], CALCULATE([Total Portfolio Market Value], ALL('bond_portfolio_data')), 0)",
                        "formatString": "0.00%"
                    },
                    {
                        "name": "Issuer Exposure %",
                        "expression": "DIVIDE(SUM('bond_portfolio_data'[MarketValue_INR]), CALCULATE(SUM('bond_portfolio_data'[MarketValue_INR]), ALLSELECTED('bond_portfolio_data')), 0)",
                        "formatString": "0.00%"
                    },
                    {
                        "name": "Bond Type Exposure %",
                        "expression": "DIVIDE(SUM('bond_portfolio_data'[MarketValue_INR]), CALCULATE(SUM('bond_portfolio_data'[MarketValue_INR]), ALLSELECTED('bond_portfolio_data')), 0)",
                        "formatString": "0.00%"
                    },
                    {
                        "name": "Portfolio Effective Duration",
                        "expression": "DIVIDE(SUMX('bond_portfolio_data', 'bond_portfolio_data'[EffectiveDuration] * 'bond_portfolio_data'[MarketValue_INR]), [Total Portfolio Market Value], 0)",
                        "formatString": "0.0000"
                    },
                    {
                        "name": "Portfolio Effective Convexity",
                        "expression": "DIVIDE(SUMX('bond_portfolio_data', 'bond_portfolio_data'[EffectiveConvexity] * 'bond_portfolio_data'[MarketValue_INR]), [Total Portfolio Market Value], 0)",
                        "formatString": "0.0000"
                    },
                    {
                        "name": "Total DV01",
                        "expression": "SUMX('bond_portfolio_data', 'bond_portfolio_data'[DV01_Per100Face] * ('bond_portfolio_data'[Quantity] * 'bond_portfolio_data'[FaceValue] / 100))",
                        "formatString": "₹#,0.00"
                    },
                    {
                        "name": "Estimated Price Shock Impact INR",
                        "expression": (
                            "VAR ShockChoice = SELECTEDVALUE('RateShockParameter'[Shock_bps], 100)\n"
                            "RETURN\n"
                            "SWITCH(\n"
                            "    ShockChoice,\n"
                            "    -200, SUMX('bond_portfolio_data', ('bond_portfolio_data'[PriceChange_Dn200bps] / NULLIF('bond_portfolio_data'[CleanPrice], 0)) * 'bond_portfolio_data'[MarketValue_INR]),\n"
                            "    -100, SUMX('bond_portfolio_data', ('bond_portfolio_data'[PriceChange_Dn100bps] / NULLIF('bond_portfolio_data'[CleanPrice], 0)) * 'bond_portfolio_data'[MarketValue_INR]),\n"
                            "    -50,  SUMX('bond_portfolio_data', ('bond_portfolio_data'[PriceChange_Dn50bps]  / NULLIF('bond_portfolio_data'[CleanPrice], 0)) * 'bond_portfolio_data'[MarketValue_INR]),\n"
                            "    50,   SUMX('bond_portfolio_data', ('bond_portfolio_data'[PriceChange_Up50bps]  / NULLIF('bond_portfolio_data'[CleanPrice], 0)) * 'bond_portfolio_data'[MarketValue_INR]),\n"
                            "    100,  SUMX('bond_portfolio_data', ('bond_portfolio_data'[PriceChange_Up100bps] / NULLIF('bond_portfolio_data'[CleanPrice], 0)) * 'bond_portfolio_data'[MarketValue_INR]),\n"
                            "    200,  SUMX('bond_portfolio_data', ('bond_portfolio_data'[PriceChange_Up200bps] / NULLIF('bond_portfolio_data'[CleanPrice], 0)) * 'bond_portfolio_data'[MarketValue_INR]),\n"
                            "    0\n"
                            ")"
                        ),
                        "formatString": "₹#,0.00"
                    },
                    {
                        "name": "Price Shock Portfolio Return %",
                        "expression": "DIVIDE([Estimated Price Shock Impact INR], [Total Portfolio Market Value], 0)",
                        "formatString": "+0.00%;-0.00%;0.00%"
                    },
                    {
                        "name": "Simulated Duration P&L",
                        "expression": "SUM('monte_carlo_scenarios'[PnL_DurationEffect_INR])",
                        "formatString": "₹#,0.00"
                    },
                    {
                        "name": "Simulated Convexity P&L",
                        "expression": "SUM('monte_carlo_scenarios'[PnL_ConvexityEffect_INR])",
                        "formatString": "₹#,0.00"
                    },
                    {
                        "name": "Simulated Total P&L",
                        "expression": "SUM('monte_carlo_scenarios'[PnL_Total_INR])",
                        "formatString": "₹#,0.00"
                    },
                    {
                        "name": "Average Scenario P&L",
                        "expression": "AVERAGE('monte_carlo_scenarios'[PnL_Total_INR])",
                        "formatString": "₹#,0.00"
                    },
                    {
                        "name": "95% VaR (INR)",
                        "expression": "PERCENTILE.INC('monte_carlo_scenarios'[PnL_Total_INR], 0.05)",
                        "formatString": "₹#,0.00"
                    },
                    {
                        "name": "95% VaR (%)",
                        "expression": "PERCENTILE.INC('monte_carlo_scenarios'[PnL_Pct], 0.05)",
                        "formatString": "-0.00%"
                    },
                    {
                        "name": "99% VaR (INR)",
                        "expression": "PERCENTILE.INC('monte_carlo_scenarios'[PnL_Total_INR], 0.01)",
                        "formatString": "₹#,0.00"
                    },
                    {
                        "name": "99% VaR (%)",
                        "expression": "PERCENTILE.INC('monte_carlo_scenarios'[PnL_Pct], 0.01)",
                        "formatString": "-0.00%"
                    },
                    {
                        "name": "95% Expected Shortfall (INR)",
                        "expression": (
                            "VAR VaR95 = [95% VaR (INR)]\n"
                            "RETURN\n"
                            "CALCULATE(AVERAGE('monte_carlo_scenarios'[PnL_Total_INR]), 'monte_carlo_scenarios'[PnL_Total_INR] <= VaR95)"
                        ),
                        "formatString": "₹#,0.00"
                    },
                    {
                        "name": "99% Expected Shortfall (INR)",
                        "expression": (
                            "VAR VaR99 = [99% VaR (INR)]\n"
                            "RETURN\n"
                            "CALCULATE(AVERAGE('monte_carlo_scenarios'[PnL_Total_INR]), 'monte_carlo_scenarios'[PnL_Total_INR] <= VaR99)"
                        ),
                        "formatString": "₹#,0.00"
                    }
                ]
            }
        ],
        "relationships": [
            {
                "name": "Rel_Bond_KeyRateMapping",
                "fromTable": "bond_portfolio_data",
                "fromColumn": "KeyRateBucket",
                "toTable": "_KeyRateMapping",
                "toColumn": "KeyRateBucket"
            },
            {
                "name": "Rel_YieldCurve_KeyRateMapping",
                "fromTable": "yield_curve_history",
                "fromColumn": "TenorLabel",
                "toTable": "_KeyRateMapping",
                "toColumn": "TenorLabel"
            }
        ]
    }
}

with open(os.path.join(SEMANTIC_DIR, "model.bim"), "w", encoding="utf-8") as f:
    json.dump(model_bim, f, indent=2)

print("model.bim created successfully.")

# ------------------------------------------------------------------------------
# 2. report.json (Report Layout & Visual Containers)
# ------------------------------------------------------------------------------
report_layout = {
    "config": json.dumps({
        "version": "5.54",
        "themeCollection": {
            "baseTheme": {
                "name": "CY24SU06",
                "version": "5.54",
                "type": 2
            }
        },
        "activeSectionIndex": 0,
        "defaultDrillFilterOtherVisuals": True
    }),
    "layoutOptimization": 0,
    "sections": [
        {
            "name": "ReportSection_Overview",
            "displayName": "1. Portfolio Overview",
            "filters": "[]",
            "ordinal": 0,
            "width": 1280,
            "height": 720,
            "visualContainers": [
                {
                    "x": 20, "y": 20, "z": 1000, "width": 280, "height": 110,
                    "config": json.dumps({
                        "name": "kpi_market_value",
                        "singleVisual": {
                            "visualType": "card",
                            "projections": {"Values": [{"queryRef": "_Measures.Total Portfolio Market Value"}]}
                        }
                    })
                },
                {
                    "x": 320, "y": 20, "z": 1001, "width": 220, "height": 110,
                    "config": json.dumps({
                        "name": "kpi_total_bonds",
                        "singleVisual": {
                            "visualType": "card",
                            "projections": {"Values": [{"queryRef": "_Measures.Total Bonds"}]}
                        }
                    })
                },
                {
                    "x": 560, "y": 20, "z": 1002, "width": 220, "height": 110,
                    "config": json.dumps({
                        "name": "kpi_weighted_coupon",
                        "singleVisual": {
                            "visualType": "card",
                            "projections": {"Values": [{"queryRef": "_Measures.Weighted Average Coupon Rate"}]}
                        }
                    })
                },
                {
                    "x": 800, "y": 20, "z": 1003, "width": 220, "height": 110,
                    "config": json.dumps({
                        "name": "kpi_effective_duration",
                        "singleVisual": {
                            "visualType": "card",
                            "projections": {"Values": [{"queryRef": "_Measures.Portfolio Effective Duration"}]}
                        }
                    })
                },
                {
                    "x": 1040, "y": 20, "z": 1004, "width": 220, "height": 110,
                    "config": json.dumps({
                        "name": "kpi_effective_convexity",
                        "singleVisual": {
                            "visualType": "card",
                            "projections": {"Values": [{"queryRef": "_Measures.Portfolio Effective Convexity"}]}
                        }
                    })
                },
                {
                    "x": 20, "y": 150, "z": 1005, "width": 400, "height": 260,
                    "config": json.dumps({
                        "name": "donut_currency_share",
                        "singleVisual": {
                            "visualType": "donutChart",
                            "projections": {
                                "Category": [{"queryRef": "bond_portfolio_data.Currency"}],
                                "Y": [{"queryRef": "_Measures.Total Portfolio Market Value"}]
                            }
                        }
                    })
                },
                {
                    "x": 440, "y": 150, "z": 1006, "width": 580, "height": 260,
                    "config": json.dumps({
                        "name": "treemap_sector_rating",
                        "singleVisual": {
                            "visualType": "treemap",
                            "projections": {
                                "Group": [{"queryRef": "bond_portfolio_data.Sector"}],
                                "Details": [{"queryRef": "bond_portfolio_data.CreditRating"}],
                                "Values": [{"queryRef": "_Measures.Total Portfolio Market Value"}]
                            }
                        }
                    })
                },
                {
                    "x": 1040, "y": 150, "z": 1007, "width": 220, "height": 550,
                    "config": json.dumps({
                        "name": "slicer_currency_sector",
                        "singleVisual": {
                            "visualType": "slicer",
                            "projections": {"Values": [{"queryRef": "bond_portfolio_data.Currency"}]}
                        }
                    })
                },
                {
                    "x": 20, "y": 430, "z": 1008, "width": 1000, "height": 270,
                    "config": json.dumps({
                        "name": "bar_maturity_ladder",
                        "singleVisual": {
                            "visualType": "columnChart",
                            "projections": {
                                "Category": [{"queryRef": "bond_portfolio_data.MaturityYear"}],
                                "Y": [{"queryRef": "_Measures.Total Portfolio Market Value"}]
                            }
                        }
                    })
                }
            ]
        },
        {
            "name": "ReportSection_Composition",
            "displayName": "2. Portfolio Composition",
            "filters": "[]",
            "ordinal": 1,
            "width": 1280,
            "height": 720,
            "visualContainers": [
                {
                    "x": 20, "y": 20, "z": 2000, "width": 680, "height": 330,
                    "config": json.dumps({
                        "name": "bar_top10_issuers",
                        "singleVisual": {
                            "visualType": "barChart",
                            "projections": {
                                "Category": [{"queryRef": "bond_portfolio_data.Issuer"}],
                                "Y": [{"queryRef": "_Measures.Total Portfolio Market Value"}]
                            }
                        }
                    })
                },
                {
                    "x": 720, "y": 20, "z": 2001, "width": 540, "height": 330,
                    "config": json.dumps({
                        "name": "pie_bondtype_split",
                        "singleVisual": {
                            "visualType": "pieChart",
                            "projections": {
                                "Category": [{"queryRef": "bond_portfolio_data.BondType"}],
                                "Y": [{"queryRef": "_Measures.Total Portfolio Market Value"}]
                            }
                        }
                    })
                },
                {
                    "x": 20, "y": 370, "z": 2002, "width": 1240, "height": 330,
                    "config": json.dumps({
                        "name": "matrix_issuer_details",
                        "singleVisual": {
                            "visualType": "pivotTable",
                            "projections": {
                                "Rows": [
                                    {"queryRef": "bond_portfolio_data.Issuer"},
                                    {"queryRef": "bond_portfolio_data.Sector"},
                                    {"queryRef": "bond_portfolio_data.CreditRating"}
                                ],
                                "Values": [
                                    {"queryRef": "_Measures.Total Bonds"},
                                    {"queryRef": "_Measures.Total Portfolio Market Value"},
                                    {"queryRef": "_Measures.Portfolio Weight %"},
                                    {"queryRef": "_Measures.Portfolio Effective Duration"},
                                    {"queryRef": "_Measures.Portfolio Effective Convexity"}
                                ]
                            }
                        }
                    })
                }
            ]
        },
        {
            "name": "ReportSection_Sensitivity",
            "displayName": "3. Risk & Interest Rate Sensitivity",
            "filters": "[]",
            "ordinal": 2,
            "width": 1280,
            "height": 720,
            "visualContainers": [
                {
                    "x": 20, "y": 20, "z": 3000, "width": 300, "height": 110,
                    "config": json.dumps({
                        "name": "kpi_dv01_total",
                        "singleVisual": {
                            "visualType": "card",
                            "projections": {"Values": [{"queryRef": "_Measures.Total DV01"}]}
                        }
                    })
                },
                {
                    "x": 340, "y": 20, "z": 3001, "width": 300, "height": 110,
                    "config": json.dumps({
                        "name": "kpi_impact_selected_shock",
                        "singleVisual": {
                            "visualType": "card",
                            "projections": {"Values": [{"queryRef": "_Measures.Estimated Price Shock Impact INR"}]}
                        }
                    })
                },
                {
                    "x": 660, "y": 20, "z": 3002, "width": 300, "height": 110,
                    "config": json.dumps({
                        "name": "kpi_return_selected_shock",
                        "singleVisual": {
                            "visualType": "card",
                            "projections": {"Values": [{"queryRef": "_Measures.Price Shock Portfolio Return %"}]}
                        }
                    })
                },
                {
                    "x": 980, "y": 20, "z": 3003, "width": 280, "height": 330,
                    "config": json.dumps({
                        "name": "slicer_rateshock_choice",
                        "singleVisual": {
                            "visualType": "slicer",
                            "projections": {"Values": [{"queryRef": "RateShockParameter.ScenarioName"}]}
                        }
                    })
                },
                {
                    "x": 20, "y": 150, "z": 3004, "width": 940, "height": 260,
                    "config": json.dumps({
                        "name": "tornado_rateshock_curve",
                        "singleVisual": {
                            "visualType": "columnChart",
                            "projections": {
                                "Category": [{"queryRef": "RateShockParameter.ScenarioName"}],
                                "Y": [{"queryRef": "_Measures.Estimated Price Shock Impact INR"}]
                            }
                        }
                    })
                },
                {
                    "x": 20, "y": 430, "z": 3005, "width": 1240, "height": 270,
                    "config": json.dumps({
                        "name": "scatter_duration_vs_convexity",
                        "singleVisual": {
                            "visualType": "scatterChart",
                            "projections": {
                                "Details": [{"queryRef": "bond_portfolio_data.Issuer"}],
                                "X": [{"queryRef": "_Measures.Portfolio Effective Duration"}],
                                "Y": [{"queryRef": "_Measures.Portfolio Effective Convexity"}],
                                "Size": [{"queryRef": "_Measures.Total Portfolio Market Value"}]
                            }
                        }
                    })
                }
            ]
        },
        {
            "name": "ReportSection_YieldCurve",
            "displayName": "4. Yield Curve Analysis",
            "filters": "[]",
            "ordinal": 3,
            "width": 1280,
            "height": 720,
            "visualContainers": [
                {
                    "x": 20, "y": 20, "z": 4000, "width": 960, "height": 360,
                    "config": json.dumps({
                        "name": "line_term_structure",
                        "singleVisual": {
                            "visualType": "lineChart",
                            "projections": {
                                "Category": [{"queryRef": "yield_curve_history.Tenor_Years"}],
                                "Y": [
                                    {"queryRef": "yield_curve_history.ZeroRate"},
                                    {"queryRef": "yield_curve_history.Yield"}
                                ]
                            }
                        }
                    })
                },
                {
                    "x": 1000, "y": 20, "z": 4001, "width": 260, "height": 680,
                    "config": json.dumps({
                        "name": "slicer_curvedate",
                        "singleVisual": {
                            "visualType": "slicer",
                            "projections": {"Values": [{"queryRef": "yield_curve_history.CurveDate"}]}
                        }
                    })
                },
                {
                    "x": 20, "y": 400, "z": 4002, "width": 960, "height": 300,
                    "config": json.dumps({
                        "name": "column_net_spreads",
                        "singleVisual": {
                            "visualType": "columnChart",
                            "projections": {
                                "Category": [{"queryRef": "bond_portfolio_data.KeyRateBucket"}],
                                "Y": [{"queryRef": "bond_portfolio_data.SpreadOverBenchmark_bps"}]
                            }
                        }
                    })
                }
            ]
        },
        {
            "name": "ReportSection_MonteCarlo",
            "displayName": "5. Monte Carlo Simulation & VaR",
            "filters": "[]",
            "ordinal": 4,
            "width": 1280,
            "height": 720,
            "visualContainers": [
                {
                    "x": 20, "y": 20, "z": 5000, "width": 290, "height": 110,
                    "config": json.dumps({
                        "name": "kpi_var95_inr",
                        "singleVisual": {
                            "visualType": "card",
                            "projections": {"Values": [{"queryRef": "_Measures.95% VaR (INR)"}]}
                        }
                    })
                },
                {
                    "x": 330, "y": 20, "z": 5001, "width": 290, "height": 110,
                    "config": json.dumps({
                        "name": "kpi_es95_inr",
                        "singleVisual": {
                            "visualType": "card",
                            "projections": {"Values": [{"queryRef": "_Measures.95% Expected Shortfall (INR)"}]}
                        }
                    })
                },
                {
                    "x": 640, "y": 20, "z": 5002, "width": 290, "height": 110,
                    "config": json.dumps({
                        "name": "kpi_var99_inr",
                        "singleVisual": {
                            "visualType": "card",
                            "projections": {"Values": [{"queryRef": "_Measures.99% VaR (INR)"}]}
                        }
                    })
                },
                {
                    "x": 950, "y": 20, "z": 5003, "width": 310, "height": 110,
                    "config": json.dumps({
                        "name": "kpi_es99_inr",
                        "singleVisual": {
                            "visualType": "card",
                            "projections": {"Values": [{"queryRef": "_Measures.99% Expected Shortfall (INR)"}]}
                        }
                    })
                },
                {
                    "x": 20, "y": 150, "z": 5004, "width": 780, "height": 260,
                    "config": json.dumps({
                        "name": "scatter_shift_vs_pnl",
                        "singleVisual": {
                            "visualType": "scatterChart",
                            "projections": {
                                "Details": [{"queryRef": "monte_carlo_scenarios.ScenarioID"}],
                                "X": [{"queryRef": "monte_carlo_scenarios.ParallelShift_bps"}],
                                "Y": [{"queryRef": "monte_carlo_scenarios.PnL_Total_INR"}]
                            }
                        }
                    })
                },
                {
                    "x": 820, "y": 150, "z": 5005, "width": 440, "height": 260,
                    "config": json.dumps({
                        "name": "waterfall_pnl_decomposition",
                        "singleVisual": {
                            "visualType": "columnChart",
                            "projections": {
                                "Y": [
                                    {"queryRef": "_Measures.Simulated Duration P&L"},
                                    {"queryRef": "_Measures.Simulated Convexity P&L"},
                                    {"queryRef": "_Measures.Simulated Total P&L"}
                                ]
                            }
                        }
                    })
                },
                {
                    "x": 20, "y": 430, "z": 5006, "width": 1240, "height": 270,
                    "config": json.dumps({
                        "name": "histogram_pnl_distribution",
                        "singleVisual": {
                            "visualType": "columnChart",
                            "projections": {
                                "Category": [{"queryRef": "monte_carlo_scenarios.ScenarioID"}],
                                "Y": [{"queryRef": "monte_carlo_scenarios.PnL_Total_INR"}]
                            }
                        }
                    })
                }
            ]
        }
    ]
}

with open(os.path.join(REPORT_DIR, "report.json"), "w", encoding="utf-8") as f:
    json.dump(report_layout, f, indent=2)

print("report.json created successfully with 5 dashboard pages.")

