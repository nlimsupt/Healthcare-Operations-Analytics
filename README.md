# Healthcare Operations Analytics | SQL & MySQL

## Project Overview

This project analyzes healthcare manufacturing operations using MySQL to evaluate inventory performance, supplier risk, and production capacity. Based on the MediCrystals case scenario, the analysis transforms operational datasets into measurable KPIs and actionable insights to support inventory planning, supplier evaluation, and operational decision-making.

The project covers three business areas:

- **Inventory Management:** Evaluate stock availability, replenishment requirements, inventory value concentration, and potential shortage or excess inventory.
- **Supplier Risk Assessment:** Examine delivery reliability, financial performance, supplier dependency, and operational risk indicators.
- **Production & Capacity Analysis:** Assess demand growth, production cycle times, quality performance, and manufacturing downtime.

## Tools & Techniques

**Tools:** MySQL, SQL, Excel

**SQL Techniques:** Data Validation, Data Transformation, Feature Engineering, Common Table Expressions (CTEs), Window Functions, Conditional Aggregation, CASE Statements, KPI Calculations

**Business Analytics:** Inventory Analysis, ABC Classification, Reorder Point, Safety Stock, Supplier Performance Analysis, Demand Trends, Production Capacity Analysis

## Key Findings

### Inventory Performance
- Analyzed **2,010 SKUs** representing approximately **$46.0 million** in inventory value.
- Identified **1,564 SKUs (77.81%)** below their calculated reorder points, highlighting potential replenishment priorities.
- Found that **208 Class A SKUs** accounted for **80.07%** of total inventory value, indicating concentrated inventory investment.

### Supplier Risk
- Evaluated **12 suppliers** across delivery performance, financial indicators, and operational risk factors.
- Identified **6 single-source suppliers (50%)**, highlighting potential supplier dependency.
- Found supplier on-time delivery performance ranging from **63% to 94%**.

### Production & Manufacturing Capacity
- Analyzed demand projections, production cycle times, quality indicators, and downtime across three product lines.
- Identified packing as the longest production process across all three product lines.
- Evaluated **14 production units**, identifying uneven unplanned downtime ranging from 15 to 25 days.

For the full analysis and supporting business interpretations, see [Analysis Summary](reports/Analysis_Summary.md).

## Project Workflow

1. **Data Preparation:** Organized instructional source data into seven structured datasets.
2. **Database Development:** Created MySQL tables with defined data types and primary keys.
3. **Data Validation:** Checked data completeness, uniqueness, consistency, and validity.
4. **Feature Engineering:** Derived inventory planning measures including safety stock, reorder points, and demand during lead time.
5. **SQL Analysis:** Developed analytical queries to calculate KPIs, evaluate operational performance, and identify potential risks.
6. **Business Insights:** Interpreted SQL results to identify operational priorities and decision-support opportunities.

## Repository Structure

| Directory | Description |
|---|---|
| `data/raw/` | Original instructional datasets |
| `data/processed/` | Prepared datasets |
| `data/exports/` | Exported SQL analysis results |
| `sql/` | Database creation, validation, feature engineering, and business analysis scripts |
| `docs/` | Business context, methodology, and data dictionary |
| `reports/` | Detailed analysis findings and interpretations |

## Documentation

- [Business Case](docs/business_case.md)
- [Data Dictionary](docs/data_dictionary.md)
- [Methodology](docs/methodology.md)
- [SQL Scripts](sql/)
- [Analysis Summary](reports/Analysis_Summary.md)

## Data Sources

This project uses instructional operational data exhibits from the **ASCM School Round 2020–21 Case Competition**, featuring the fictional healthcare manufacturing company MediCrystals, Co.

The Harvard Global Health Delivery Project case *Building the Supply Chain for COVID-19 Vaccines* (2021) provides supplementary industry context.

The datasets represent a case-based analytical scenario rather than actual hospital or patient-level operational records.
