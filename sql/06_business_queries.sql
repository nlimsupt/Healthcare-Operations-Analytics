-- ============================================================
-- 06_business_queries.sql
-- Purpose:
-- Analyze inventory, supplier risk, production planning,
-- and manufacturing-capacity conditions to support
-- operational decision-making.
--
-- Source layers:
-- - Source tables: seven imported operational tables
-- - Feature view: inventory_features
-- ============================================================

USE healthcare_operations_analytics;

-- ============================================================
-- 1. INVENTORY DECISION SUPPORT — GLASWORK PLANT
-- ============================================================

-- ------------------------------------------------------------
-- 1.1 Inventory portfolio overview
-- ------------------------------------------------------------

SELECT
    COUNT(*) AS total_skus,
    ROUND(SUM(on_hand_stock_value), 2) AS total_inventory_value,
    SUM(inventory_units_on_hand) AS total_inventory_units,
    ROUND(SUM(annual_demand), 2) AS total_annual_demand,
    ROUND(AVG(standard_price), 2) AS average_standard_price,
    MIN(lead_time_days) AS minimum_lead_time_days,
    MAX(lead_time_days) AS maximum_lead_time_days,
    ROUND(AVG(lead_time_days), 2) AS average_lead_time_days,
    MIN(supplier_on_time_delivery) AS minimum_supplier_otd,
    MAX(supplier_on_time_delivery) AS maximum_supplier_otd,
    ROUND(AVG(supplier_on_time_delivery), 4) AS average_supplier_otd,
    ROUND(AVG(demand_variability_cov), 4) AS average_demand_variability_cov
FROM inventory_features;

-- ------------------------------------------------------------
-- 1.2 SKUs below their calculated reorder points
-- ------------------------------------------------------------

SELECT
    sku,
    inventory_units_on_hand,
    ROUND(reorder_point, 2) AS reorder_point,
    ROUND(reorder_point - inventory_units_on_hand, 2) AS units_below_reorder_point,
    ROUND(daily_demand, 2) AS daily_demand,
    lead_time_days,
    ROUND(safety_stock, 2) AS safety_stock,
    ROUND(on_hand_stock_value, 2) AS on_hand_stock_value
FROM inventory_features
WHERE inventory_units_on_hand < reorder_point
ORDER BY units_below_reorder_point DESC;

-- ------------------------------------------------------------
-- 1.3 Count and percentage of SKUs below reorder point
-- ------------------------------------------------------------

SELECT
    COUNT(*) AS total_skus,
    SUM(inventory_units_on_hand < reorder_point) AS skus_below_reorder_point,
    ROUND(100.0 * SUM(inventory_units_on_hand < reorder_point) / COUNT(*), 2) AS percentage_below_reorder_point
FROM inventory_features;

-- ------------------------------------------------------------
-- 1.4 Inventory risk classification
--
-- Below Reorder Point:
-- Current inventory is below the calculated reorder threshold.
--
-- Near Reorder Point:
-- Current inventory is between 100% and 120% of reorder point.
--
-- Above Reorder Point:
-- Current inventory exceeds 120% of reorder point.
-- ------------------------------------------------------------

SELECT
    CASE
        WHEN inventory_units_on_hand < reorder_point
            THEN 'Below Reorder Point'
        WHEN inventory_units_on_hand <= reorder_point * 1.20
            THEN 'Near Reorder Point'
        ELSE 'Above Reorder Point'
    END AS inventory_status,
    COUNT(*) AS sku_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS percentage_of_skus,
    ROUND(SUM(on_hand_stock_value), 2) AS total_inventory_value
FROM inventory_features
GROUP BY inventory_status
ORDER BY
    CASE inventory_status
        WHEN 'Below Reorder Point' THEN 1
        WHEN 'Near Reorder Point' THEN 2
        WHEN 'Above Reorder Point' THEN 3
    END;

-- ------------------------------------------------------------
-- 1.5 Highest-value inventory items
-- ------------------------------------------------------------

SELECT
    sku,
    standard_price,
    inventory_units_on_hand,
    ROUND(on_hand_stock_value, 2) AS on_hand_stock_value,
    ROUND(100.0 * on_hand_stock_value / SUM(on_hand_stock_value) OVER (), 4) AS percentage_of_total_inventory_value
FROM inventory_features
ORDER BY on_hand_stock_value DESC
LIMIT 20;

-- ------------------------------------------------------------
-- 1.6 Cumulative inventory-value concentration
-- Supports Pareto / ABC-style inventory analysis
-- ------------------------------------------------------------

WITH inventory_value_ranking AS (
    SELECT
        sku,
        on_hand_stock_value,
        SUM(on_hand_stock_value) OVER (ORDER BY on_hand_stock_value DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_inventory_value,
        SUM(on_hand_stock_value) OVER () AS total_inventory_value
    FROM inventory_features
)

SELECT
    sku,
    ROUND(on_hand_stock_value, 2) AS on_hand_stock_value,
    ROUND(100.0 * on_hand_stock_value / total_inventory_value, 4) AS percentage_of_total_value,
    ROUND(100.0 * cumulative_inventory_value / total_inventory_value, 2) AS cumulative_percentage_of_value
FROM inventory_value_ranking
ORDER BY on_hand_stock_value DESC;

-- ------------------------------------------------------------
-- 1.7 ABC Inventory Classification
--
-- This analysis applies an illustrative ABC inventory
-- classification based on cumulative on-hand inventory value.
--
-- Classification thresholds:
--   A = First ~80% of cumulative inventory value
--   B = Next ~15% (up to ~95%)
--   C = Remaining ~5%
--
-- The SKU that crosses each cumulative threshold is included
-- in the preceding class.
--
-- These thresholds are applied for analytical purposes and
-- are not provided by the source dataset.
-- ------------------------------------------------------------

WITH inventory_value_ranking AS (
    SELECT
        sku,
        on_hand_stock_value,
        SUM(on_hand_stock_value) OVER (ORDER BY on_hand_stock_value DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_inventory_value,
        SUM(on_hand_stock_value) OVER () AS total_inventory_value
    FROM inventory_features
),

abc_classification AS (
    SELECT
        sku,
        on_hand_stock_value,
        (100.0 * on_hand_stock_value / total_inventory_value) AS percentage_of_total_value,
        (100.0 * cumulative_inventory_value / total_inventory_value) AS cumulative_percentage_of_value,
        (100.0 * (cumulative_inventory_value - on_hand_stock_value) / total_inventory_value) AS cumulative_percentage_before_current,
        CASE
            WHEN
                (100.0 * (cumulative_inventory_value - on_hand_stock_value) / total_inventory_value) < 80
                THEN 'A'
            WHEN
                (100.0 * (cumulative_inventory_value - on_hand_stock_value) / total_inventory_value) < 95
                THEN 'B'
            ELSE 'C'
        END AS abc_class
    FROM inventory_value_ranking
)

SELECT
    abc_class,
    COUNT(*) AS sku_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS percentage_of_skus,
    ROUND(SUM(on_hand_stock_value), 2) AS total_inventory_value,
    ROUND(100.0 * SUM(on_hand_stock_value) / SUM(SUM(on_hand_stock_value)) OVER (), 2) AS percentage_of_inventory_value
FROM abc_classification
GROUP BY abc_class
ORDER BY
    CASE abc_class
        WHEN 'A' THEN 1
        WHEN 'B' THEN 2
        WHEN 'C' THEN 3
    END;

-- ------------------------------------------------------------
-- 1.8 Inventory coverage in months
-- ------------------------------------------------------------

SELECT
    sku,
    inventory_units_on_hand,
    average_monthly_usage,
    ROUND(
        inventory_units_on_hand
        / NULLIF(average_monthly_usage, 0),
        2
    ) AS months_of_inventory_coverage,
    ROUND(on_hand_stock_value, 2) AS on_hand_stock_value,
    ROUND(annual_demand, 2) AS annual_demand
FROM inventory_features
ORDER BY months_of_inventory_coverage DESC;

-- ------------------------------------------------------------
-- 1.9 SKUs with less than one month of inventory coverage
-- ------------------------------------------------------------

SELECT
    sku,
    inventory_units_on_hand,
    average_monthly_usage,
    ROUND(
        inventory_units_on_hand
        / NULLIF(average_monthly_usage, 0),
        2
    ) AS months_of_inventory_coverage,
    ROUND(reorder_point, 2) AS reorder_point,
    lead_time_days,
    ROUND(on_hand_stock_value, 2) AS on_hand_stock_value

FROM inventory_features
WHERE
    inventory_units_on_hand
    / NULLIF(average_monthly_usage, 0) < 1
ORDER BY months_of_inventory_coverage ASC;

-- ------------------------------------------------------------
-- 1.10 Potential excess inventory
--
-- This query treats inventory exceeding annual demand as
-- potential excess inventory for screening purposes.
-- ------------------------------------------------------------

SELECT
    sku,
    inventory_units_on_hand,
    ROUND(annual_demand, 2) AS annual_demand,
    ROUND(
        inventory_units_on_hand - annual_demand,
        2
    ) AS potential_excess_units,
    standard_price,
    ROUND(
        (inventory_units_on_hand - annual_demand)
        * standard_price,
        2
    ) AS potential_excess_value
FROM inventory_features
WHERE inventory_units_on_hand > annual_demand
ORDER BY potential_excess_value DESC;

-- ------------------------------------------------------------
-- 1.11 Highest safety-stock requirements
-- ------------------------------------------------------------

SELECT
    sku,
    ROUND(safety_stock, 2) AS safety_stock,
    ROUND(reorder_point, 2) AS reorder_point,
    ROUND(demand_during_lead_time, 2)
        AS demand_during_lead_time,
    ROUND(demand_variability_cov, 4)
        AS demand_variability_cov,
    ROUND(normalized_cov, 4) AS normalized_cov,
    lead_time_days,
    supplier_on_time_delivery
FROM inventory_features
ORDER BY safety_stock DESC
LIMIT 20;

-- ------------------------------------------------------------
-- 1.12 Relationship between variability, lead time,
-- and safety stock
-- ------------------------------------------------------------

SELECT
    sku,
    demand_variability_cov,
    lead_time_days,
    ROUND(daily_demand, 2) AS daily_demand,
    ROUND(safety_stock, 2) AS safety_stock,
    ROUND(reorder_point, 2) AS reorder_point
FROM inventory_features
ORDER BY
    demand_variability_cov DESC,
    lead_time_days DESC
LIMIT 25;

-- ------------------------------------------------------------
-- 1.13 Demand-trend distribution
-- ------------------------------------------------------------

SELECT
    CASE
        WHEN average_monthly_usage_trend < 0
            THEN 'Declining Demand'
        WHEN average_monthly_usage_trend = 0
            THEN 'Stable Demand'
        ELSE 'Growing Demand'
    END AS demand_trend_category,
    COUNT(*) AS sku_count,
    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage_of_skus,
    ROUND(SUM(annual_demand), 2)
        AS total_annual_demand,
    ROUND(SUM(on_hand_stock_value), 2)
        AS total_inventory_value
FROM inventory_features
GROUP BY demand_trend_category;

-- ------------------------------------------------------------
-- 1.14 Priority inventory exceptions
--
-- Combines reorder-point exposure, low supplier delivery
-- performance, and high demand variability.
--
-- These are screening conditions rather than a validated
-- predictive risk model.
-- ------------------------------------------------------------

SELECT
    sku,
    inventory_units_on_hand,
    ROUND(reorder_point, 2) AS reorder_point,
    ROUND(reorder_point - inventory_units_on_hand, 2)
        AS reorder_shortfall,
    supplier_on_time_delivery,
    demand_variability_cov,
    lead_time_days,
    ROUND(safety_stock, 2) AS safety_stock,
    ROUND(on_hand_stock_value, 2) AS on_hand_stock_value
FROM inventory_features
WHERE inventory_units_on_hand < reorder_point
  AND supplier_on_time_delivery < 0.80
ORDER BY
    reorder_shortfall DESC,
    demand_variability_cov DESC;

-- ============================================================
-- 2. SUPPLIER RISK ASSESSMENT — MEDICRYSTALS
-- ============================================================

-- ------------------------------------------------------------
-- 2.1 Supplier portfolio overview
-- ------------------------------------------------------------

SELECT
    COUNT(*) AS total_suppliers,
    ROUND(AVG(revenue), 2) AS average_revenue_million_usd,
    ROUND(AVG(cash_from_operations), 2)
        AS average_cash_from_operations_million_usd,
    ROUND(AVG(credit_rating), 2) AS average_credit_rating,
    ROUND(AVG(s_otd), 4) AS average_supplier_otd,
    ROUND(AVG(data_security), 2) AS average_data_security_score,
    SUM(single_source = 1) AS single_source_suppliers,
    SUM(ip_protection = 0) AS suppliers_without_ip_protection,
    SUM(labor_unrests = 1) AS suppliers_with_labor_unrests,
    SUM(environmental_incidents = 1)
        AS suppliers_with_environmental_incidents
FROM supplier_risk;

-- ------------------------------------------------------------
-- 2.2 Supplier delivery-performance ranking
-- ------------------------------------------------------------

SELECT
    supplier_name,
    location,
    s_otd,
    credit_rating,
    single_source,
    labor_unrests,
    environmental_incidents
FROM supplier_risk
ORDER BY s_otd ASC, single_source DESC;

-- ------------------------------------------------------------
-- 2.3 Single-source supplier exposure
-- ------------------------------------------------------------

SELECT
    supplier_name,
    location,
    revenue,
    cash_from_operations,
    credit_rating,
    s_otd,
    ip_protection,
    data_security,
    labor_unrests,
    environmental_incidents
FROM supplier_risk
WHERE single_source = 1
ORDER BY s_otd ASC;

-- ------------------------------------------------------------
-- 2.4 Suppliers with operational or regulatory indicators
-- ------------------------------------------------------------

SELECT
    supplier_name,
    location,
    s_otd,
    single_source,
    labor_unrests,
    environmental_incidents,
    data_security,
    ip_protection
FROM supplier_risk
WHERE labor_unrests = 1
   OR environmental_incidents = 1
   OR ip_protection = 0
ORDER BY
    environmental_incidents DESC,
    labor_unrests DESC,
    single_source DESC;

-- ------------------------------------------------------------
-- 2.5 Transparent supplier risk-indicator count
--
-- One point is assigned for each binary risk indicator:
-- - Single-source dependency
-- - No critical IP protection
-- - Labor unrest history
-- - Environmental incident history
--
-- This is a descriptive screening score, not a validated model.
-- ------------------------------------------------------------

SELECT
    supplier_name,
    location,
    s_otd,
    credit_rating,
    data_security,
    single_source,
    ip_protection,
    labor_unrests,
    environmental_incidents,
    (
        single_source
        + (ip_protection = 0)
        + labor_unrests
        + environmental_incidents
    ) AS binary_risk_indicator_count
FROM supplier_risk
ORDER BY
    binary_risk_indicator_count DESC,
    s_otd ASC;

-- ------------------------------------------------------------
-- 2.6 Supplier financial profile
-- ------------------------------------------------------------

SELECT
    supplier_name,
    location,
    revenue,
    cash_from_operations,
    ROUND(
        cash_from_operations / NULLIF(revenue, 0),
        4
    ) AS operating_cash_flow_margin,
    credit_rating,
    s_otd
FROM supplier_risk
ORDER BY operating_cash_flow_margin ASC;

-- ------------------------------------------------------------
-- 2.7 Comprehensive supplier-risk profile
--
-- This query presents supplier-risk indicators across four
-- dimensions: financial, operations, data management,
-- and regulatory risk.
--
-- Numeric indicators are converted to transparent 0–100
-- risk-oriented scores where appropriate:
-- - Higher score = higher risk
-- - No weighted overall risk score is created
--
-- Revenue and cash from operations are retained as financial
-- context rather than converted into risk scores.
--
-- Regulatory risk is reported as an indicator count because
-- only two binary indicators are available.
-- ------------------------------------------------------------

SELECT
    supplier_name,
    location,
    -- ========================================================
    -- Financial Risk
    -- ========================================================
    revenue,
    cash_from_operations,
    credit_rating,
    -- Credit rating ranges from 1 to 5.
    -- Lower credit rating = higher financial risk.
    ROUND(
        (6 - credit_rating) / 5.0 * 100,
        2
    ) AS credit_rating_risk_score,
    -- ========================================================
    -- Operations Risk
    -- ========================================================
    s_otd,
    -- S-OTD is stored as a ratio from 0 to 1.
    -- The score represents the percentage delivery shortfall.
    -- Example: S-OTD = 0.82 produces an 18% shortfall score.
    ROUND(
        (1 - s_otd) * 100,
        2
    ) AS delivery_shortfall_score,
    -- ========================================================
    -- Data Management Risk
    -- ========================================================
    single_source,
    ip_protection,
    data_security,
    -- Binary risk indicators:
    -- Single source = 1 means sourcing dependency is present.
    single_source AS single_source_risk_indicator,
    -- IP protection = 0 is treated as a risk indicator.
    CASE
        WHEN ip_protection = 0 THEN 1
        ELSE 0
    END AS no_ip_protection_risk_indicator,
    -- Data-security score ranges from 0 to 10.
    -- Lower data-security score = higher risk.
    ROUND(
        (10 - data_security) / 10.0 * 100,
        2
    ) AS data_security_gap_score,
    -- Count of binary data-management risk indicators.
    (
        single_source
        + CASE
            WHEN ip_protection = 0 THEN 1
            ELSE 0
          END
    ) AS data_management_binary_risk_count,
    -- ========================================================
    -- Regulatory Risk
    -- ========================================================
    labor_unrests,
    environmental_incidents,
    -- Count of regulatory risk indicators:
    -- 0 = no indicators present
    -- 1 = one indicator present
    -- 2 = both indicators present
    (
        labor_unrests
        + environmental_incidents
    ) AS regulatory_risk_indicator_count
FROM supplier_risk
ORDER BY
    credit_rating_risk_score DESC,
    delivery_shortfall_score DESC,
    data_security_gap_score DESC,
    regulatory_risk_indicator_count DESC;

-- ============================================================
-- 3. PRODUCTION CAPACITY ANALYSIS — FABRICADAS PLANT
-- ============================================================

-- ------------------------------------------------------------
-- Production
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- 3.1 Consolidated product-production profile
-- ------------------------------------------------------------

SELECT
    dp.product,
    -- Demand
    dp.q3_2020_actual,
    dp.q4_2020_projection,
    dp.q1_2021_projection,
    dp.q2_2021_projection,
    -- Total production time
    pct.cycle_time_hours,
    -- Process cycle times
    prct.tubing_hours,
    prct.hot_forming_hours,
    prct.washing_hours,
    prct.packing_hours,
    -- Quality reject rates
    pr.bend_tubing_reject_rate,
    pr.contamination_reject_rate,
    pr.glass_breakage_reject_rate,
    pr.air_bubble_reject_rate
FROM demand_projections AS dp
INNER JOIN product_cycle_time AS pct
    ON dp.product = pct.product
INNER JOIN process_cycle_time AS prct
    ON dp.product = prct.product
INNER JOIN product_rejects AS pr
    ON dp.product = pr.product
ORDER BY dp.product;

-- ------------------------------------------------------------
-- 3.2 Quarterly demand growth
-- ------------------------------------------------------------

SELECT
    product,
    q3_2020_actual,
    q4_2020_projection,
    q1_2021_projection,
    q2_2021_projection,
    ROUND(
        100.0
        * (q4_2020_projection - q3_2020_actual)
        / NULLIF(q3_2020_actual, 0),
        2
    ) AS q4_vs_q3_growth_percentage,
    ROUND(
        100.0
        * (q1_2021_projection - q4_2020_projection)
        / NULLIF(q4_2020_projection, 0),
        2
    ) AS q1_vs_q4_growth_percentage,
    ROUND(
        100.0
        * (q2_2021_projection - q1_2021_projection)
        / NULLIF(q1_2021_projection, 0),
        2
    ) AS q2_vs_q1_growth_percentage,
    ROUND(
        100.0
        * (q2_2021_projection - q3_2020_actual)
        / NULLIF(q3_2020_actual, 0),
        2
    ) AS q2_vs_q3_growth_percentage
FROM demand_projections
ORDER BY q2_vs_q3_growth_percentage DESC;

-- ------------------------------------------------------------
-- 3.3 Total projected demand by quarter
-- ------------------------------------------------------------

SELECT
    SUM(q3_2020_actual) AS total_q3_2020_actual,
    SUM(q4_2020_projection) AS total_q4_2020_projection,
    SUM(q1_2021_projection) AS total_q1_2021_projection,
    SUM(q2_2021_projection) AS total_q2_2021_projection
FROM demand_projections;

-- ------------------------------------------------------------
-- 3.4 Process-cycle-time bottleneck by product
-- ------------------------------------------------------------

SELECT
    product,
    tubing_hours,
    hot_forming_hours,
    washing_hours,
    packing_hours,
    GREATEST(
        tubing_hours,
        hot_forming_hours,
        washing_hours,
        packing_hours
    ) AS longest_process_time_hours,
    CASE
        WHEN tubing_hours = GREATEST(
            tubing_hours,
            hot_forming_hours,
            washing_hours,
            packing_hours
        ) THEN 'Tubing'
        WHEN hot_forming_hours = GREATEST(
            tubing_hours,
            hot_forming_hours,
            washing_hours,
            packing_hours
        ) THEN 'Hot-forming'
        WHEN washing_hours = GREATEST(
            tubing_hours,
            hot_forming_hours,
            washing_hours,
            packing_hours
        ) THEN 'Washing'
        WHEN packing_hours = GREATEST(
            tubing_hours,
            hot_forming_hours,
            washing_hours,
            packing_hours
        ) THEN 'Packing'
    END AS potential_bottleneck_process
FROM process_cycle_time
ORDER BY longest_process_time_hours DESC;

-- ------------------------------------------------------------
-- 3.5 Product cycle-time reconciliation
--
-- Compares the reported total product cycle time with the
-- sum of the four listed process cycle times.
-- ------------------------------------------------------------

SELECT
    pct.product,
    pct.cycle_time_hours AS reported_cycle_time_hours,
    (
        prct.tubing_hours
        + prct.hot_forming_hours
        + prct.washing_hours
        + prct.packing_hours
    ) AS summed_process_cycle_time_hours,
    ROUND(
        pct.cycle_time_hours
        - (
            prct.tubing_hours
            + prct.hot_forming_hours
            + prct.washing_hours
            + prct.packing_hours
        ),
        4
    ) AS cycle_time_difference_hours
FROM product_cycle_time AS pct
INNER JOIN process_cycle_time AS prct
    ON pct.product = prct.product
ORDER BY ABS(cycle_time_difference_hours) DESC;

-- ------------------------------------------------------------
-- 3.6 Largest reported reject category by product
-- ------------------------------------------------------------

SELECT
    product,
    bend_tubing_reject_rate,
    contamination_reject_rate,
    glass_breakage_reject_rate,
    air_bubble_reject_rate,
    GREATEST(
        bend_tubing_reject_rate,
        contamination_reject_rate,
        glass_breakage_reject_rate,
        air_bubble_reject_rate
    ) AS highest_reject_rate,
    CASE
        WHEN bend_tubing_reject_rate = GREATEST(
            bend_tubing_reject_rate,
            contamination_reject_rate,
            glass_breakage_reject_rate,
            air_bubble_reject_rate
        ) THEN 'Bend Tubing'
        WHEN contamination_reject_rate = GREATEST(
            bend_tubing_reject_rate,
            contamination_reject_rate,
            glass_breakage_reject_rate,
            air_bubble_reject_rate
        ) THEN 'Contamination'
        WHEN glass_breakage_reject_rate = GREATEST(
            bend_tubing_reject_rate,
            contamination_reject_rate,
            glass_breakage_reject_rate,
            air_bubble_reject_rate
        ) THEN 'Glass Breakage'
        WHEN air_bubble_reject_rate = GREATEST(
            bend_tubing_reject_rate,
            contamination_reject_rate,
            glass_breakage_reject_rate,
            air_bubble_reject_rate
        ) THEN 'Air Bubbles'
    END AS highest_reject_category
FROM product_rejects
ORDER BY highest_reject_rate DESC;

-- ------------------------------------------------------------
-- 3.7 Reported reject-rate profile
--
-- The sum is used only as a descriptive indicator because the
-- source does not confirm whether defect categories overlap.
--
-- The average represents the mean reported defect rate across
-- the four defect categories and should not be interpreted as
-- the overall product reject rate.
-- ------------------------------------------------------------

SELECT
    product,
    ROUND(
        bend_tubing_reject_rate
        + contamination_reject_rate
        + glass_breakage_reject_rate
        + air_bubble_reject_rate,
        4
    ) AS summed_reported_defect_rates,
    ROUND(
        (
            bend_tubing_reject_rate
            + contamination_reject_rate
            + glass_breakage_reject_rate
            + air_bubble_reject_rate
        ) / 4,
        4
    ) AS average_reported_defect_rate
FROM product_rejects
ORDER BY
    summed_reported_defect_rates DESC;

-- ------------------------------------------------------------
-- 3.8 Approximate cycle-time requirement for Q2 demand
--
-- This multiplication is an analytical workload indicator.
-- Its operational interpretation depends on whether cycle time
-- is reported per individual unit, batch, or another basis.
-- ------------------------------------------------------------

SELECT
    dp.product,
    dp.q2_2021_projection,
    pct.cycle_time_hours,
    ROUND(
        dp.q2_2021_projection
        * pct.cycle_time_hours,
        2
    ) AS projected_q2_cycle_time_requirement
FROM demand_projections AS dp
INNER JOIN product_cycle_time AS pct
    ON dp.product = pct.product
ORDER BY projected_q2_cycle_time_requirement DESC;

-- ------------------------------------------------------------
-- Manufacturing Capacity
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- 3.9 Manufacturing downtime overview
-- ------------------------------------------------------------

SELECT
    COUNT(*) AS total_production_units,
    SUM(weekends_holidays_days)
        AS total_weekends_holidays_days,
    SUM(planned_shutdown_days)
        AS total_planned_shutdown_days,
    SUM(unplanned_shutdown_days)
        AS total_unplanned_shutdown_days,
    SUM(
        weekends_holidays_days
        + planned_shutdown_days
        + unplanned_shutdown_days
    ) AS total_non_operating_days
FROM manufacturing_capacity;

-- ------------------------------------------------------------
-- 3.10 Total downtime by production unit
-- ------------------------------------------------------------

SELECT
    production_unit,
    weekends_holidays_days,
    planned_shutdown_days,
    unplanned_shutdown_days,
    (
        weekends_holidays_days
        + planned_shutdown_days
        + unplanned_shutdown_days
    ) AS total_non_operating_days
FROM manufacturing_capacity
ORDER BY
    total_non_operating_days DESC,
    unplanned_shutdown_days DESC;

-- ------------------------------------------------------------
-- 3.11 Production units with highest unplanned downtime
--
-- The percentage represents unplanned shutdown days as a
-- share of the unit's reported non-operating days.
-- It does not represent overall capacity utilization.
-- ------------------------------------------------------------

SELECT
    production_unit,
    unplanned_shutdown_days,
    planned_shutdown_days,
    weekends_holidays_days,
    ROUND(
        100.0 * unplanned_shutdown_days
        / NULLIF(
            weekends_holidays_days
            + planned_shutdown_days
            + unplanned_shutdown_days,
            0
        ),
        2
    ) AS unplanned_share_of_non_operating_days
FROM manufacturing_capacity
ORDER BY
    unplanned_shutdown_days DESC,
    unplanned_share_of_non_operating_days DESC;

-- ------------------------------------------------------------
-- 3.12 Downtime composition by production unit
-- ------------------------------------------------------------

SELECT
    production_unit,
    (
        weekends_holidays_days
        + planned_shutdown_days
        + unplanned_shutdown_days
    ) AS total_non_operating_days,
    ROUND(
        100.0 * weekends_holidays_days
        / NULLIF(
            weekends_holidays_days
            + planned_shutdown_days
            + unplanned_shutdown_days,
            0
        ),
        2
    ) AS weekends_holidays_percentage,
    ROUND(
        100.0 * planned_shutdown_days
        / NULLIF(
            weekends_holidays_days
            + planned_shutdown_days
            + unplanned_shutdown_days,
            0
        ),
        2
    ) AS planned_shutdown_percentage,
    ROUND(
        100.0 * unplanned_shutdown_days
        / NULLIF(
            weekends_holidays_days
            + planned_shutdown_days
            + unplanned_shutdown_days,
            0
        ),
        2
    ) AS unplanned_shutdown_percentage
FROM manufacturing_capacity
ORDER BY total_non_operating_days DESC;

-- ------------------------------------------------------------
-- 3.13 Production units above average downtime
--
-- This query identifies units whose total non-operating days
-- exceed the average across all production units.
-- ------------------------------------------------------------

WITH unit_downtime AS (
    SELECT
        production_unit,
        weekends_holidays_days,
        planned_shutdown_days,
        unplanned_shutdown_days,
        (
            weekends_holidays_days
            + planned_shutdown_days
            + unplanned_shutdown_days
        ) AS total_non_operating_days
    FROM manufacturing_capacity
),
downtime_average AS (
    SELECT
        AVG(total_non_operating_days)
            AS average_non_operating_days
    FROM unit_downtime
)
SELECT
    ud.production_unit,
    ud.weekends_holidays_days,
    ud.planned_shutdown_days,
    ud.unplanned_shutdown_days,
    ud.total_non_operating_days,
    ROUND(
        da.average_non_operating_days,
        2
    ) AS average_non_operating_days,
    ROUND(
        ud.total_non_operating_days
        - da.average_non_operating_days,
        2
    ) AS days_above_average
FROM unit_downtime AS ud
CROSS JOIN downtime_average AS da
WHERE
    ud.total_non_operating_days
    > da.average_non_operating_days
ORDER BY
    days_above_average DESC,
    ud.unplanned_shutdown_days DESC;

-- ------------------------------------------------------------
-- 3.14 Relative downtime priority classification
--
-- Priority is based on the production-unit distribution:
-- - High Priority: total downtime at or above the upper quartile
-- - Moderate Priority: between the median and upper quartile
-- - Standard Monitoring: below the median
--
-- This is a relative screening classification, not a validated
-- capacity-risk model.
-- ------------------------------------------------------------

WITH unit_downtime AS (
    SELECT
        production_unit,
        weekends_holidays_days,
        planned_shutdown_days,
        unplanned_shutdown_days,
        (
            weekends_holidays_days
            + planned_shutdown_days
            + unplanned_shutdown_days
        ) AS total_non_operating_days
    FROM manufacturing_capacity
),
downtime_distribution AS (
    SELECT
        unit_downtime.*,
        NTILE(4) OVER (
            ORDER BY total_non_operating_days
        ) AS downtime_quartile
    FROM unit_downtime
)
SELECT
    production_unit,
    weekends_holidays_days,
    planned_shutdown_days,
    unplanned_shutdown_days,
    total_non_operating_days,
    downtime_quartile,
    CASE
        WHEN downtime_quartile = 4
            THEN 'High Priority'
        WHEN downtime_quartile = 3
            THEN 'Moderate Priority'
        ELSE 'Standard Monitoring'
    END AS downtime_priority
FROM downtime_distribution
ORDER BY
    downtime_quartile DESC,
    total_non_operating_days DESC,
    unplanned_shutdown_days DESC;

-- ------------------------------------------------------------
-- 3.15 Production-capacity decision-support summary
--
-- This query places production requirements and reported
-- downtime indicators in one management summary.
--
-- The metrics must not be directly compared as equivalent
-- measures. Demand is reported in units, cycle-time workload
-- depends on the source cycle-time basis, and downtime is
-- reported in days.
--
-- Because product-to-production-unit mappings, operating hours,
-- production rates, and planning-period capacity are unavailable,
-- this query does not calculate capacity utilization or confirm
-- whether projected demand can be fulfilled.
-- ------------------------------------------------------------

WITH production_requirements AS (
    SELECT
        SUM(dp.q2_2021_projection)
            AS total_q2_projected_demand,
        ROUND(
            SUM(
                dp.q2_2021_projection
                * pct.cycle_time_hours
            ),
            2
        ) AS total_projected_q2_cycle_time_requirement
    FROM demand_projections AS dp
    INNER JOIN product_cycle_time AS pct
        ON dp.product = pct.product
),
capacity_exposure AS (
    SELECT
        COUNT(*) AS total_production_units,
        SUM(
            weekends_holidays_days
            + planned_shutdown_days
            + unplanned_shutdown_days
        ) AS total_reported_non_operating_days,
        SUM(planned_shutdown_days)
            AS total_planned_shutdown_days,
        SUM(unplanned_shutdown_days)
            AS total_unplanned_shutdown_days,
        ROUND(
            AVG(
                weekends_holidays_days
                + planned_shutdown_days
                + unplanned_shutdown_days
            ),
            2
        ) AS average_non_operating_days_per_unit
    FROM manufacturing_capacity
)
SELECT
    pr.total_q2_projected_demand,
    pr.total_projected_q2_cycle_time_requirement,
    ce.total_production_units,
    ce.total_reported_non_operating_days,
    ce.total_planned_shutdown_days,
    ce.total_unplanned_shutdown_days,
    ce.average_non_operating_days_per_unit
FROM production_requirements AS pr
CROSS JOIN capacity_exposure AS ce;