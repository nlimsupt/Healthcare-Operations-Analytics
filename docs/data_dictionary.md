# Data Dictionary

## Dataset Overview

This project uses seven instructional operational tables organized into four analytical modules: supplier risk, inventory planning, production planning, and manufacturing capacity. The source data exhibits were developed for the ASCM School Round 2020–21 Case Competition.

The datasets simulate operational activities within MediCrystals' supply chain, including supplier risk management at the company level, inventory planning at GlasWork Plant, and production and capacity planning at Fabricadas Plant. Each module represents a different aspect of healthcare manufacturing operations. Rather than forming a fully normalized relational database, the tables provide complementary operational perspectives that are analyzed independently when direct relationships are unavailable.

---

## Analytical Module Summary

| Analytical Module | Purpose | Granularity | Approx. Records |
|-------------------|---------|-------------|----------------:|
| Supplier Risk | Assess supplier performance and operational risk | One record per supplier | 12 suppliers |
| Inventory Planning | Monitor inventory and calculate replenishment metrics | One record per SKU | ~2,000 SKUs |
| Production Planning | Estimate production requirements and cycle times | One record per product in each source table | 3 products across 4 tables |
| Manufacturing Capacity | Evaluate plant availability and production constraints | One record per production unit | 14 production units |

---

## Supplier Risk Module

### Module Metadata

| Property | Value |
|----------|-------|
| Purpose | Evaluate supplier-related operational risks |
| Granularity | One record per supplier |
| Primary Key | Supplier Name |
| Derived Variables | No |
| Operational Scope | MediCrystals Supplier Network |

#### Variables

| Column | Type | Unit / Format | Description | Business Meaning |
|---------|------|---------------|-------------|------------------|
| Supplier Name | Text | — | Name of the supplier | Supplier identifier |
| Location | Text | Country | Country where the supplier is located | Geographic risk assessment |
| Revenue | Numeric | Million USD | Supplier revenue for fiscal year 2019 | Assess supplier financial capacity |
| Cash from Operations | Numeric | Million USD | Operating cash flow for fiscal year 2019 | Evaluate supplier liquidity and financial stability |
| Credit Rating | Integer | Score | Supplier credit rating score | Assess financial risk |
| S-OTD | Decimal | Ratio | Supplier on-time delivery performance | Measure supplier delivery reliability |
| Single Source | Boolean | Yes / No | Indicates whether the supplier is the only qualified source | Identify supply continuity risk |
| IP Protection | Boolean | Yes / No | Indicates whether the supplier owns critical intellectual property | Assess intellectual property dependency |
| Data Security | Integer | Score | Supplier data security assessment score | Evaluate information security risk |
| Labor Unrests | Boolean | Yes / No | Indicates whether the supplier has a history of labor disputes | Identify operational disruption risk |
| Environmental Incidents | Boolean | Yes / No | Indicates whether the supplier has a history of environmental incidents | Assess regulatory and sustainability risk |

---

## Inventory Planning Module

### Module Metadata

| Property | Value |
|----------|-------|
| Purpose | Inventory planning and replenishment analysis |
| Granularity | One record per SKU |
| Primary Key | SKU |
| Derived Variables | Yes (not included in the source data) |
| Operational Scope | GlasWork Plant |

#### Original Variables

| Column | Type | Unit / Format | Description | Business Meaning |
|---------|------|---------------|-------------|------------------|
| SKU | Text | — | Stock keeping unit | Product identifier |
| Std. Price | Numeric | Currency per unit | Standard unit price | Inventory valuation |
| On-Hand Stock | Numeric | Currency | Current on-hand inventory value | Available inventory value |
| Inventory in Units On-Hand | Integer | Units | Current inventory quantity | Physical inventory |
| APU | Integer | Units per month | Average monthly demand | Demand planning |
| October–September Demand | Numeric | Units per month | Twelve monthly demand fields covering the October–September planning period | Monthly demand profile |
| Demand for the Year | Numeric | Units per year | Total demand across the October–September planning period | Annual demand |
| APU Trend | Decimal | Percentage | Expected demand trend | Demand growth |
| S-OTD | Decimal | Ratio | Supplier delivery performance | Procurement reliability |
| Demand Variability (COV) | Decimal | Ratio | Demand coefficient of variation | Demand uncertainty |
| Lead Time | Integer | Days | Procurement lead time | Replenishment planning |

#### Derived Variables

| Column | Type | Unit / Format | Description | Business Meaning |
|---------|------|---------------|-------------|------------------|
| Obsolete Inventory | Numeric | Units | Estimated excess inventory after fulfilling annual demand | Inventory risk |
| Normalized COV | Decimal | Ratio | Normalized coefficient of variation | Standardize demand variability for comparison |
| Daily Demand | Numeric | Units per day | Average daily demand | Inventory planning |
| Demand During Lead Time | Numeric | Units | Expected demand during supplier lead time | Procurement planning |
| Standard Deviation During Lead Time | Numeric | Units | Demand variability during supplier lead time | Safety stock calculation |
| Safety Stock | Numeric | Units | Buffer inventory maintained to reduce stockout risk | Inventory protection |
| Reorder Point | Numeric | Units | Inventory level that triggers replenishment | Inventory replenishment |

---

## Production Planning Module

### Module Metadata

| Property | Value |
|----------|-------|
| Purpose | Estimate production requirements, process utilization, and quality performance |
| Source Tables | 4 |
| Common Key | Product |
| Granularity | One record per product in each source table |
| Derived Variables | No |
| Operational Scope | Fabricadas Plant |

### Source Tables

The Production Planning module consists of four operational tables:

| Table | Purpose |
|-------|---------|
| Demand Projections | Project production demand by product and quarter |
| Product Cycle Time | Measure total production cycle time |
| Process Cycle Time | Measure cycle time for each manufacturing process |
| Product Rejects | Measure reject rates by defect category |

### Variables by Source Table

#### Demand Projections

| Column | Type | Unit / Format | Description | Business Meaning |
|---------|------|---------------|-------------|------------------|
| Product | Text | — | Product category | Manufactured product |
| Q3 2020 Actual | Numeric | Units | Actual product demand for Q3 2020 | Historical demand baseline |
| Q4 2020 Projections | Numeric | Units | Projected product demand for Q4 2020 | Near-term production planning |
| Q1 2021 Projections | Numeric | Units | Projected product demand for Q1 2021 | Future production planning |
| Q2 2021 Projections | Numeric | Units | Projected product demand for Q2 2021 | Future production planning |

#### Product Cycle Time

| Column | Type | Unit / Format | Description | Business Meaning |
|---------|------|---------------|-------------|------------------|
| Product | Text | — | Product category | Manufactured product |
| Cycle Time | Numeric | Hours | Total cycle time required for the product | Overall capacity requirement |

#### Process Cycle Time

| Column | Type | Unit / Format | Description | Business Meaning |
|---------|------|---------------|-------------|------------------|
| Product | Text | — | Product category | Manufactured product |
| Tubing | Numeric | Hours per process | Time required for the tubing process | Process-capacity and bottleneck analysis |
| Hot-forming | Numeric | Hours per process | Time required for the hot-forming process | Process-capacity and bottleneck analysis |
| Washing | Numeric | Hours per process | Time required for the washing process | Process-capacity and bottleneck analysis |
| Packing | Numeric | Hours per process | Time required for the packing process | Process-capacity and bottleneck analysis |

#### Product Rejects

| Column | Type | Unit / Format | Description | Business Meaning |
|---------|------|---------------|-------------|------------------|
| Product | Text | — | Product category | Manufactured product |
| Bend Tubing Rejects | Decimal | Percentage | Reject rate associated with bend-tubing defects | Monitor tubing-related quality losses |
| Contamination Rejects | Decimal | Percentage | Reject rate associated with contamination | Monitor contamination-related quality losses |
| Glass Breakages | Decimal | Percentage | Reject rate associated with glass breakage | Monitor material and handling quality losses |
| Air Bubbles | Decimal | Percentage | Reject rate associated with air-bubble defects | Monitor forming-related quality losses |

---

## Manufacturing Capacity Module

### Module Metadata

| Property | Value |
|----------|-------|
| Purpose | Evaluate manufacturing availability and downtime |
| Granularity | One record per production unit |
| Primary Key | Production Unit |
| Derived Variables | No |
| Operational Scope | Fabricadas Plant |

#### Variables

| Column | Type | Unit / Format | Description | Business Meaning |
|---------|------|---------------|-------------|------------------|
| Production Unit | Text | — | Manufacturing resource | Production asset |
| Weekends & Holidays | Integer | Days | Non-operating days | Available production time |
| Planned Shutdown | Integer | Days | Scheduled downtime | Maintenance planning |
| Unplanned Shutdown | Integer | Days | Unexpected downtime | Operational risk |

---

## Module Relationships

The project modules represent complementary operational perspectives rather than a fully normalized relational database.

- The Supplier Risk module is analyzed independently because supplier records are not directly linked to individual SKUs.
- The Inventory Planning module contains SKU-level operational data and derived inventory planning metrics.
- The Production Planning and Manufacturing Capacity modules are analyzed together to evaluate production feasibility and capacity constraints at Fabricadas Plant.

---

## Data Quality Notes

- Supplier and inventory modules are not directly related through a common key.
- Several inventory planning metrics are derived from the original operational variables.
- Production planning data primarily contains projected demand, supplemented by a single quarter of actual demand, rather than a long history of production transactions.
- The modules represent an instructional operational scenario rather than a live enterprise information system.
