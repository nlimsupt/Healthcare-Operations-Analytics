# Methodology

## Overview

This project follows an end-to-end analytics workflow to transform fragmented operational data into actionable business insights for MediCrystals, Co. The methodology covers supplier risk at the company level, inventory planning at GlasWork Plant, and production and manufacturing-capacity analysis at Fabricadas Plant.

---

## Project Workflow

The project consists of the following stages:

1. Business Understanding
2. Data Understanding
3. Data Preparation
4. Database Design and Data Loading
5. Data Validation
6. Feature Engineering
7. SQL Analysis
8. Exploratory and Scenario Analysis
9. Dashboard Development
10. Business Recommendations

---

## 1. Business Understanding

The project begins by identifying the operational challenges represented in the MediCrystals case, including supplier risk at the company level, inventory planning at GlasWork Plant, and production and manufacturing-capacity constraints at Fabricadas Plant. Business objectives and analytical questions are defined to ensure that the analysis supports practical operational decision-making across the company and plant levels.

---

## 2. Data Understanding

The available datasets are reviewed to understand their structure, business context, and relationships. Each analytical module is examined to understand its granularity, variables, and role within the overall operational workflow.

---

## 3. Data Preparation

The source exhibits are reviewed and reorganized into seven analysis-ready tables. Formula-based Excel fields are converted to stored values before CSV export, column structures are standardized, and identifier fields such as SKU are preserved as text.

Missing values and duplicate records are initially checked in Excel. Data types, units, percentages, ratios, and categorical values are reviewed before the source tables are imported into MySQL for formal validation and analysis.

---

## 4. Database Design and Data Loading

A MySQL database is designed to organize the seven source tables according to their operational granularity and analytical purpose. Table names and column names are standardized using consistent naming conventions, and appropriate data types and primary keys are defined before loading the prepared CSV files.

The database preserves the limitations of the source data. Relationships are created only where supported by valid common keys, and no supplier-to-SKU or product-to-production-unit relationship is assumed when such mappings are unavailable.

---

## 5. Data Validation

After loading the source tables into MySQL, validation queries are used to confirm row counts, primary-key uniqueness, missing values, duplicate records, valid ranges, categorical values, and consistency between source files and database tables.

Additional checks are performed for inventory quantities, demand values, percentages, supplier-performance ratios, cycle times, rejection rates, and shutdown days before analytical calculations are performed.

---

## 6. Feature Engineering

Additional analytical variables are created to support inventory planning and operational analysis. The calculation logic is documented and implemented through reproducible SQL and Python workflows, depending on the analytical requirement.

The derived inventory variables are based on inventory-management formulas introduced in the original coursework and are not part of the source datasets.

Examples include:

- Obsolete Inventory
- Normalized COV
- Daily Demand
- Demand During Lead Time
- Standard Deviation During Lead Time
- Safety Stock
- Reorder Point

---

## 7. SQL Analysis

SQL is used to retrieve, aggregate, validate, and summarize operational data. Analytical queries are developed to assess supplier risk across the MediCrystals supplier network, inventory status at GlasWork Plant, and production and capacity conditions at Fabricadas Plant.

Because the source exhibits do not provide complete relational mappings across all modules, tables are joined only where a supported common key exists.

---

## 8. Exploratory and Scenario Analysis

Python is used to conduct deeper exploratory analysis and evaluate operational scenarios. The analysis examines patterns in supplier performance, inventory exposure, production requirements, quality losses, downtime, and capacity availability.

Scenario analysis is used to evaluate how changes in assumptions such as demand, lead time, service level, supplier performance, or available capacity may affect inventory and operational requirements. These scenarios are intended to support sensitivity analysis and decision-making rather than validated predictive forecasting.

---

## 9. Dashboard Development

Interactive Power BI dashboards are developed to communicate operational KPIs and analytical findings. The dashboard structure includes an executive overview for MediCrystals, supplier-risk analysis, GlasWork inventory decision support, and Fabricadas production and capacity analysis.

The dashboards are designed to support prioritization and decision-making without implying unsupported record-level relationships between operational modules.

---

## 10. Business Recommendations

The final stage translates analytical findings into practical business recommendations. Insights from SQL analysis, exploratory analysis, scenario analysis, and dashboards are combined to support operational improvements and management decision-making.

---

## Tools and Techniques by Project Component

| Project Component | Objective | Primary Tools / Techniques |
|---------------|-----------|----------------------------|
| Business Understanding | Define business problems, operational scopes, objectives, and analytical questions | Business analysis |
| Data Understanding | Review source-table structures, granularity, variables, and relationships | Excel, business domain knowledge |
| Data Preparation | Standardize source tables and prepare analysis-ready CSV files | Excel, data cleaning |
| Database Design and Loading | Define schemas, keys, data types, and load seven source tables | MySQL |
| Data Validation | Verify completeness, uniqueness, ranges, formats, and source-to-database consistency | SQL, Excel |
| Feature Engineering | Create documented inventory and operational metrics | SQL, Python, inventory-management formulas |
| SQL Analysis | Retrieve, aggregate, and summarize operational performance and risk | MySQL |
| Exploratory and Scenario Analysis | Examine patterns and test operational assumptions | Python, Pandas, Matplotlib, descriptive statistics |
| Dashboard Development | Present management KPIs and operational insights | Power BI |
| Business Recommendations | Translate findings into prioritized operational actions | Business analysis, data storytelling |
| Documentation | Record assumptions, datasets, calculations, limitations, and analytical decisions | Markdown, GitHub |