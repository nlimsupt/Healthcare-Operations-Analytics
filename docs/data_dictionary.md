# Data Dictionary

## Dataset Overview

This project uses four operational datasets derived from the Harvard Global Health Delivery Project case, *Building the Supply Chain for COVID-19 Vaccines*.

Each dataset represents a different aspect of healthcare manufacturing operations, including supplier risk, inventory planning, production planning, and manufacturing capacity. Rather than forming a fully normalized relational database, the datasets provide complementary operational perspectives that are analyzed independently when direct relationships are unavailable.

---

## Dataset Summary

| Dataset | Purpose | Granularity | Approx. Records |
|---------|----------|-------------|----------------:|
| Supplier Risk | Assess supplier performance and operational risk | One record per supplier | 12 suppliers |
| Inventory Planning | Monitor inventory and calculate replenishment metrics | One record per SKU | ~2,000 SKUs |
| Production Planning | Estimate production requirements and cycle times | One record per product | 3 products |
| Manufacturing Capacity | Evaluate plant availability and production constraints | One record per production unit | 14 production units |

---

## Supplier Risk Dataset

### Dataset Metadata

| Property | Value |
|----------|-------|
| Purpose | Evaluate supplier-related operational risks |
| Granularity | One record per supplier |
| Primary Key | Supplier Name |
| Derived Variables | No |
| Related Module | Supplier Risk Assessment |

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

## Inventory Planning Dataset

### Dataset Metadata

| Property | Value |
|----------|-------|
| Purpose | Inventory planning and replenishment analysis |
| Granularity | One record per SKU |
| Primary Key | SKU |
| Derived Variables | Yes |
| Related Module | Inventory Decision Support |

#### Original Variables

| Column | Type | Unit / Format | Description | Business Meaning |
|---------|------|---------------|-------------|------------------|
| SKU | Text | — | Stock keeping unit | Product identifier |
| Std. Price | Numeric | Currency per unit | Standard unit price | Inventory valuation |
| On-Hand Stock | Numeric | Currency | Current on-hand inventory value | Available inventory value |
| Inventory in Units On-Hand | Integer | Units | Current inventory quantity | Physical inventory |
| APU | Integer | Units per month | Average monthly demand | Demand planning |
| Monthly Demand | Numeric | Units | Monthly demand (October–September) | Monthly demand analysis |
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

## Production Planning Dataset

### Dataset Metadata

| Property | Value |
|----------|-------|
| Purpose | Estimate production requirements and process utilization |
| Granularity | One record per product |
| Primary Key | Product |
| Derived Variables | No |
| Related Module | Production Capacity Analysis |

#### Variables

| Column | Type | Unit / Format | Description | Business Meaning |
|---------|------|---------------|-------------|------------------|
| Product | Text | — | Product category | Manufactured product |
| Quarterly Demand | Numeric | Units | Projected production demand | Production planning |
| Cycle Time | Numeric | Hours | Total production time | Capacity planning |
| Process Cycle Time | Numeric | Hours | Time required for each manufacturing stage | Bottleneck analysis |
| Reject Rate | Decimal | Percentage | Average production rejects | Quality performance |

---

## Manufacturing Capacity Dataset

### Dataset Metadata

| Property | Value |
|----------|-------|
| Purpose | Evaluate manufacturing availability and downtime |
| Granularity | One record per production unit |
| Primary Key | Production Unit |
| Derived Variables | No |
| Related Module | Production Capacity Analysis |

#### Variables

| Column | Type | Unit / Format | Description | Business Meaning |
|---------|------|---------------|-------------|------------------|
| Production Unit | Text | — | Manufacturing resource | Production asset |
| Weekends & Holidays | Integer | Days | Non-operating days | Available production time |
| Planned Shutdown | Integer | Days | Scheduled downtime | Maintenance planning |
| Unplanned Shutdown | Integer | Days | Unexpected downtime | Operational risk |

---

## Dataset Relationships

The project datasets represent complementary operational perspectives rather than a fully normalized relational database.
- The Supplier Risk dataset is analyzed independently because supplier records are not directly linked to individual SKUs.
- The Inventory Planning dataset contains SKU-level operational data and derived inventory planning metrics.
- The Production Planning and Manufacturing Capacity datasets are analyzed together to evaluate production feasibility and capacity constraints.

---

## Data Quality Notes

- Supplier and inventory datasets are not directly related through a common key.
- Several inventory planning metrics are derived from the original operational variables.
- Production planning data is based on projected demand rather than historical production transactions.
- The datasets represent a case-based operational scenario rather than a live enterprise information system.
