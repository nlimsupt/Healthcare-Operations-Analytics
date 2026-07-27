# Business Case

## Business Context

This project uses instructional operational data exhibits originally developed for the ASCM School Round 2020–21 Case Competition. The datasets simulate supplier, inventory, production, and manufacturing-capacity decisions within the fictional healthcare manufacturing operations of MediCrystals, Co.

The portfolio analysis also draws on the Harvard Global Health Delivery Project case, *Building the Supply Chain for COVID-19 Vaccines*, as supplementary industry context for supply-chain disruption and healthcare manufacturing challenges.

The case centers on MediCrystals, Co. and examines operational activities across its supplier network and two operational plants. Supplier risk is assessed at the MediCrystals company level, inventory planning is evaluated at GlasWork Plant, and production and manufacturing capacity are analyzed at Fabricadas Plant.

During periods of operational disruption, demand may increase unexpectedly, supplier performance may decline, lead times may become longer, and production capacity may be constrained. Without a structured analytics process, organizations may struggle to identify critical operational risks and prioritize effective responses.

While the Harvard case focuses on vaccine manufacturing during the COVID-19 pandemic, this project extends the analysis into a broader operational analytics framework applicable to healthcare manufacturing environments facing supplier disruptions, demand surges, material shortages, production interruptions, and other forms of operational uncertainty.

---

## Data Sources

This project is based on two complementary sources:

1. Operational data exhibits originally developed for the ASCM School Round 2020–21 Case Competition. These instructional datasets cover supplier risk at the MediCrystals company level, inventory planning at GlasWork Plant, and production and manufacturing capacity at Fabricadas Plant.

2. Harvard Global Health Delivery Project. *Building the Supply Chain for COVID-19 Vaccines* (GHD-045), 2021, used as supplementary industry context for vaccine manufacturing and supply-chain disruption.

---

## Business Problem

The case scenario provides operational data covering MediCrystals' supplier network, inventory operations at GlasWork Plant, and demand, production, and capacity planning at Fabricadas Plant. However, the data is distributed across separate datasets and does not provide decision-makers with a consolidated view of operational performance and risk.

Decision-makers need a clearer way to:

- identify inventory items at risk of shortage or excess;
- evaluate supplier risk across multiple business dimensions;
- detect production constraints and potential bottlenecks;
- prioritize operational issues based on business impact; and
- understand how changes in demand, lead time, or service-level requirements may affect inventory and capacity decisions.

The absence of a structured analytics and reporting process may lead to reactive decision-making, excess working capital, material shortages, delayed production, and insufficient preparation for operational disruptions.

---

## Project Objective

The objective of this project is to develop an operational analytics solution that transforms fragmented operational data into actionable decision support for MediCrystals management.

The solution will combine data preparation, business-oriented feature engineering, SQL analysis, Python-based exploratory analysis, scenario analysis, and Power BI dashboards to help management monitor and prioritize supplier risk at the company level, inventory performance at GlasWork Plant, and production and capacity constraints at Fabricadas Plant.

---

## Business Objectives

The project aims to:

1. Evaluate inventory health across approximately 2,000 SKUs at GlasWork Plant.
2. Identify items with potential stockout, excess, or obsolete inventory risk.
3. Derive operational inventory metrics such as daily demand, demand during lead time, safety stock, and reorder point.
4. Assess supplier risk across financial, operational, data-management, and regulatory dimensions.
5. Compare projected demand with available production capacity at Fabricadas Plant.
6. Identify products, production processes, or production units that may require operational attention.
7. Evaluate how changes in demand, lead time, service level, or capacity may affect operational requirements.
8. Present the results through clear and interactive management dashboards.

---

## Key Stakeholders

### Executive Management

Executive management requires a high-level view of operational exposure, major risks, and areas requiring management attention.

### Inventory and Materials Management

Inventory and materials management teams at GlasWork Plant need to monitor stock availability, inventory value, reorder requirements, and excess or obsolete inventory.

### Procurement and Supplier Management

Procurement and supplier management teams need to evaluate supplier reliability and identify financial, operational, regulatory, or data-related risks.

### Production and Operations Management

Production and operations managers at Fabricadas Plant need to compare demand requirements with available production capacity, monitor quality losses and downtime, and identify potential bottlenecks.

### Business Intelligence and Analytics Team

The business intelligence and analytics team is responsible for preparing the data, defining analytical metrics, performing the analysis, and developing decision-support dashboards.

---

## Key Business Questions

### GlasWork Inventory

- Which SKUs are currently below or close to their calculated reorder points?
- Which items have the greatest potential stockout exposure?
- Which SKUs hold excessive or potentially obsolete inventory?
- Which items account for the largest share of total inventory value?
- How do demand variability and lead time affect safety-stock requirements?
- How would changes in demand or service-level targets affect required inventory?

### MediCrystals Supplier Risk

- Which suppliers present the greatest overall risk?
- Which suppliers have weak delivery performance or single-source exposure?
- Which suppliers show signs of financial, regulatory, operational, or data-management risk?
- Which risk dimensions require the most management attention?

### Fabricadas Production and Capacity

- Is projected demand aligned with available production capacity?
- Which products or processes are most likely to experience capacity constraints?
- Where are the potential production bottlenecks?
- How would reduced capacity or increased demand affect production priorities?

### Management Decision Support

- Which operational risks should management prioritize first?
- Which risks can be addressed through inventory policy, supplier action, or capacity planning?
- How can operational performance be communicated through a consolidated dashboard?

---

## Scope of Analysis

The project is organized into four analytical modules:

1. **Supplier Risk Assessment — MediCrystals**

   - financial risk
   - delivery and operational risk
   - single-source exposure
   - data-management risk
   - regulatory and environmental risk

2. **Inventory Decision Support — GlasWork Plant**

   - inventory availability
   - inventory value
   - demand variability
   - lead-time exposure
   - safety stock
   - reorder point
   - excess and obsolete inventory
   - SKU prioritization

3. **Production Planning — Fabricadas Plant**

   - projected demand
   - product cycle times
   - process cycle times
   - rejection rates
   - quality-related production losses
   - potential process bottlenecks

4. **Manufacturing Capacity — Fabricadas Plant**

   - production-unit availability
   - planned shutdowns
   - unplanned shutdowns
   - effective production capacity
   - utilization and capacity constraints

---

## Data and Analytical Limitations

The datasets are instructional datasets designed for educational analysis rather than live production data. The datasets represent separate operational views within the MediCrystals case and do not provide a complete relational mapping across the supplier network, GlasWork Plant, and Fabricadas Plant.

In particular, the available case data does not directly map individual suppliers to specific SKUs. Supplier and inventory risks will therefore be analyzed as separate modules and will not be presented as record-level causal relationships. This design choice reflects the structure of the available case data rather than an analytical assumption. The production and manufacturing-capacity datasets share a common operational context at Fabricadas Plant, but they do not provide a complete transactional mapping between individual products and specific production units.

The inventory data represents a case-based operational snapshot with monthly demand values rather than a long historical transaction series. The project will therefore emphasize inventory planning and scenario analysis rather than claiming to perform a fully validated time-series forecast.

All derived metrics, assumptions, and analytical limitations will be documented clearly throughout the project.

---

## Expected Deliverables

The project will produce:

- documented source and processed datasets;
- a comprehensive data dictionary;
- reproducible data validation, preparation, and feature engineering workflows;
- SQL scripts for data preparation and business analysis;
- Python notebooks for exploratory data analysis and scenario analysis;
- interactive Power BI dashboards for decision support;
- key analytical findings and business insights;
- prioritized business recommendations; and
- complete documentation of the end-to-end analytics workflow.

---

## Expected Business Value

The proposed analytics solution is intended to help management move from fragmented reporting toward structured operational decision support.

By identifying high-risk suppliers, inventory concerns at GlasWork Plant, and production and capacity constraints at Fabricadas Plant, decision-makers can better prioritize actions, reduce avoidable inventory exposure, prepare for disruption, and allocate operational resources more effectively.

Although the instructional datasets and fictional business scenario originated from an educational case competition focused on pandemic-related supply chain challenges, the analytical framework developed in this project is designed to be adaptable to a wide range of healthcare manufacturing and operational disruption scenarios.
