# Methodology

## Overview

This project follows an end-to-end analytics workflow to transform operational data into actionable business insights for healthcare manufacturing operations. The methodology covers the complete analytics process, from understanding the business problem to developing data-driven recommendations.

---

## Project Workflow

The project consists of the following stages:

1. Business Understanding
2. Data Understanding
3. Data Preparation
4. Feature Engineering
5. Exploratory Data Analysis (EDA)
6. SQL Analysis
7. Dashboard Development
8. Predictive Analytics
9. Business Recommendations

---

## 1. Business Understanding

The project begins by identifying the operational challenges faced by healthcare manufacturers, including supplier risks, inventory planning, production efficiency, and manufacturing capacity. The business objectives are defined to ensure that the analysis addresses practical operational decision-making.

---

## 2. Data Understanding

The available datasets are reviewed to understand their structure, business context, and relationships. Each dataset is examined to identify its granularity, variables, and role within the overall operational workflow.

---

## 3. Data Preparation

The datasets are prepared for analysis by validating data quality and ensuring consistency across variables. Missing values are verified using the COUNTBLANK() function in Excel, while duplicate records are checked using Excel's Remove Duplicates feature. No missing values or duplicate records are identified. Data types and variable consistency are also reviewed before the datasets are prepared for downstream analysis in Python and SQL.

---

## 4. Feature Engineering

Additional analytical variables are created to support inventory planning and operational analysis. These derived variables are calculated using inventory management formulas introduced during the course and are not part of the original case dataset.

Examples include:

- Daily Demand
- Demand During Lead Time
- Safety Stock
- Reorder Point
- Obsolete Inventory

---

## 5. Exploratory Data Analysis (EDA)

Exploratory analysis is conducted to understand operational patterns, identify potential risks, and summarize key characteristics of the data. Summary statistics and visualizations are used to examine supplier performance, inventory levels, production efficiency, and manufacturing capacity.

---

## 6. SQL Analysis

SQL is used to retrieve, aggregate, and summarize operational data through analytical queries. Queries are developed to support inventory monitoring, supplier evaluation, production reporting, and operational performance measurement.

---

## 7. Dashboard Development

Interactive dashboards are developed to present key operational metrics and business insights. The dashboards are designed to provide decision-makers with an integrated view of supplier performance, inventory status, production operations, and manufacturing capacity.

---

## 8. Predictive Analytics

Predictive models are developed to estimate future operational outcomes and support proactive decision-making. Depending on the business scenario, predictive analysis may include demand forecasting, inventory optimization, or operational risk prediction.

---

## 9. Business Recommendations

The final stage translates analytical findings into practical business recommendations. Insights from descriptive analysis, SQL reporting, dashboards, and predictive analytics are combined to support operational improvements and strategic decision-making.

---

## Tools and Techniques by Project Component

| Project Component | Objective | Primary Tools / Techniques |
|---------------|-----------|----------------------------|
| Business Understanding | Define the business problem, project objectives, and expected outcomes | Business analysis |
| Data Understanding | Review dataset structure, variables, and business context | Excel, Business domain knowledge |
| Data Preparation | Validate data quality, organize datasets, and prepare data for analysis | Excel, Data validation |
| Feature Engineering | Create analytical variables to support inventory planning and operational analysis | Python (Pandas), Inventory management formulas |
| Exploratory Data Analysis (EDA) | Identify patterns, trends, and potential operational issues | Python (Pandas, Matplotlib), Descriptive statistics |
| SQL Analysis | Retrieve, aggregate, and summarize operational data | MySQL |
| Dashboard Development | Visualize key operational KPIs and business insights | Power BI |
| Predictive Analytics | Develop predictive models to support operational decision-making | Python (Scikit-learn) |
| Business Recommendations | Translate analytical findings into actionable recommendations | Business analysis, Data storytelling |
| Documentation | Document project assumptions, datasets, methodology, and analytical decisions | Markdown, GitHub |