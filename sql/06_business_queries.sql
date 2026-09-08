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
        100.0 * on_hand_stock_value / total_inventory_value AS percentage_of_total_value,
        100.0 * cumulative_inventory_value / total_inventory_value AS cumulative_percentage_of_value,
        100.0 * (cumulative_inventory_value - on_hand_stock_value) / total_inventory_value AS cumulative_percentage_before_current,
        CASE
            WHEN
                100.0 * (cumulative_inventory_value - on_hand_stock_value) / total_inventory_value < 80
                THEN 'A'
            WHEN
                100.0 * (cumulative_inventory_value - on_hand_stock_value) / total_inventory_value < 95
                THEN 'B'
            ELSE 'C'
        END AS abc_class
    FROM inventory_value_ranking
)

SELECT
    abc_class,
    COUNT(*) AS sku_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS percentage_of_total_skus,
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
--
-- Inventory coverage is calculated using projected average
-- monthly demand (annual demand / 12).
-- ------------------------------------------------------------

SELECT
    sku,
    inventory_units_on_hand,
    ROUND(annual_demand / 12, 2) AS projected_average_monthly_demand,
    ROUND(inventory_units_on_hand / NULLIF(annual_demand / 12, 0), 2) AS months_of_inventory_coverage,
    ROUND(on_hand_stock_value, 2) AS on_hand_stock_value,
    ROUND(annual_demand, 2) AS annual_demand
FROM inventory_features
ORDER BY months_of_inventory_coverage DESC;

-- ------------------------------------------------------------
-- 1.9 SKUs with Less Than One Month of Inventory Coverage
--
-- Inventory coverage is calculated using projected average
-- monthly demand, defined as annual projected demand / 12.
--
-- SKUs with less than one month of projected coverage are
-- flagged for replenishment review.
--
-- The one-month threshold is used as an analytical screening
-- rule rather than a confirmed company policy.
-- ------------------------------------------------------------

SELECT
    sku,
    inventory_units_on_hand,
    ROUND(annual_demand / 12, 2) AS projected_average_monthly_demand,
    ROUND(inventory_units_on_hand / NULLIF(annual_demand / 12, 0), 2) AS months_of_inventory_coverage,
    ROUND(reorder_point, 2) AS reorder_point,
    lead_time_days,
    ROUND(on_hand_stock_value, 2) AS on_hand_stock_value
FROM inventory_features
WHERE
    inventory_units_on_hand / NULLIF(annual_demand / 12, 0) < 1
ORDER BY months_of_inventory_coverage ASC;

-- ------------------------------------------------------------
-- 1.10 One-month inventory coverage shortfall exposure
--
-- Identifies SKUs with less than one month of projected
-- inventory coverage and estimates the number of additional
-- units and inventory value required to reach one month
-- of projected average demand.
--
-- The estimated value is based on standard price and should
-- not be interpreted as lost revenue or an actual purchase
-- order requirement.
-- ------------------------------------------------------------

WITH shortfall_exposure AS (
    SELECT
        sku,
        inventory_units_on_hand,
        annual_demand / 12.0 AS projected_average_monthly_demand,
        (annual_demand / 12.0) - inventory_units_on_hand AS inventory_shortfall_units,
        standard_price,
        ((annual_demand / 12.0) - inventory_units_on_hand) * standard_price AS estimated_shortfall_inventory_value
    FROM inventory_features
    WHERE
        inventory_units_on_hand / NULLIF(annual_demand / 12.0, 0) < 1
)

SELECT
    sku,
    inventory_units_on_hand,
    ROUND(projected_average_monthly_demand, 2) AS projected_average_monthly_demand,
    ROUND(inventory_shortfall_units, 2) AS inventory_shortfall_units,
    standard_price,
    ROUND(estimated_shortfall_inventory_value, 2) AS estimated_shortfall_inventory_value,
	ROUND(SUM(estimated_shortfall_inventory_value) OVER (), 2) AS total_shortfall_inventory_value,
    ROUND(100.0 * estimated_shortfall_inventory_value / SUM(estimated_shortfall_inventory_value) OVER (), 2) AS percentage_of_total_shortfall_exposure
FROM shortfall_exposure
ORDER BY
    estimated_shortfall_inventory_value DESC;

-- ------------------------------------------------------------
-- 1.11 Potential excess inventory
--
-- This query treats inventory exceeding annual demand as
-- potential excess inventory for screening purposes.
-- ------------------------------------------------------------

SELECT
    sku,
    inventory_units_on_hand,
    ROUND(annual_demand, 2) AS annual_demand,
    ROUND(inventory_units_on_hand - annual_demand, 2) AS potential_excess_units,
    ROUND(100.0 * (inventory_units_on_hand - annual_demand) / NULLIF(annual_demand, 0), 2) AS excess_inventory_percentage,
    standard_price,
    ROUND((inventory_units_on_hand - annual_demand) * standard_price, 2) AS potential_excess_value
FROM inventory_features
WHERE inventory_units_on_hand > annual_demand
ORDER BY potential_excess_value DESC;

-- ------------------------------------------------------------
-- 1.12 Highest safety-stock requirements
-- ------------------------------------------------------------

SELECT
    sku,
    ROUND(annual_demand, 2) AS annual_demand,
    ROUND(safety_stock, 2) AS safety_stock,
    ROUND(100.0 * safety_stock / NULLIF(annual_demand, 0), 2) AS safety_stock_percentage_of_annual_demand,
    ROUND(reorder_point, 2) AS reorder_point,
    ROUND(demand_during_lead_time, 2) AS demand_during_lead_time,
    ROUND(demand_variability_cov, 4) AS demand_variability_cov,
    ROUND(normalized_cov, 4) AS normalized_cov,
    lead_time_days,
    supplier_on_time_delivery
FROM inventory_features
ORDER BY safety_stock DESC
LIMIT 20;

-- ------------------------------------------------------------
-- 1.13 Demand Trend Summary
--
-- Inventory items are classified as Growing, Stable, or
-- Declining Demand based on the projected average monthly
-- usage trend.
--
-- The query summarizes the number of SKUs, projected annual
-- demand, and inventory value within each demand category.
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
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS percentage_of_total_skus,
    ROUND(SUM(annual_demand), 2) AS total_annual_demand,
    ROUND(SUM(on_hand_stock_value), 2) AS total_inventory_value
FROM inventory_features
GROUP BY demand_trend_category;

-- ------------------------------------------------------------
-- 1.14 Prioritized Inventory Exceptions
--
-- Identifies inventory items currently below their
-- calculated reorder points.
--
-- Results are prioritized by:
-- 1. Reorder shortfall (highest first)
-- 2. Supplier on-time delivery (lowest first)
-- 3. Demand variability (highest first)
--
-- Supplier delivery performance and demand variability are
-- used as supporting prioritization indicators rather than
-- hard screening thresholds.
--
-- This is an analytical prioritization report rather than a
-- validated predictive risk model.
-- ------------------------------------------------------------

SELECT
    sku,
    inventory_units_on_hand,
    ROUND(reorder_point, 2) AS reorder_point,
    ROUND(reorder_point - inventory_units_on_hand, 2) AS reorder_shortfall,
    supplier_on_time_delivery,
    demand_variability_cov,
    lead_time_days,
    ROUND(safety_stock, 2) AS safety_stock,
    ROUND(on_hand_stock_value, 2) AS on_hand_stock_value
FROM inventory_features
WHERE inventory_units_on_hand < reorder_point 
ORDER BY
    reorder_shortfall DESC,
    supplier_on_time_delivery ASC,
    demand_variability_cov DESC;

-- ============================================================
-- 2. SUPPLIER RISK ASSESSMENT — MEDICRYSTALS
-- ============================================================

-- ------------------------------------------------------------
-- 2.1 Supplier portfolio overview
-- ------------------------------------------------------------

SELECT
    COUNT(*) AS total_suppliers,
    ROUND(SUM(revenue), 2) AS average_revenue_million_usd,
    ROUND(SUM(cash_from_operations), 2) AS average_cash_from_operations_million_usd,
    ROUND(AVG(credit_rating), 2) AS average_credit_rating,
    ROUND(AVG(s_otd), 4) AS average_supplier_otd,
    ROUND(AVG(data_security), 2) AS average_data_security_score,
    SUM(single_source = 1) AS single_source_suppliers,
    SUM(ip_protection = 0) AS suppliers_without_ip_protection,
    SUM(labor_unrests = 1) AS suppliers_with_labor_unrests,
    SUM(environmental_incidents = 1) AS suppliers_with_environmental_incidents
FROM supplier_risk;

-- ------------------------------------------------------------
-- 2.2 Supplier delivery-performance ranking
-- ------------------------------------------------------------

SELECT
    supplier_name,
    location,
    s_otd,
    ROUND(100 * s_otd, 2) AS supplier_otd_percentage
FROM supplier_risk
ORDER BY 
	s_otd ASC;

-- ------------------------------------------------------------
-- 2.3 Single-source supplier exposure
-- ------------------------------------------------------------

SELECT
    supplier_name,
    location,
    single_source,
    ip_protection,
    data_security
FROM supplier_risk
ORDER BY
    single_source DESC,
    ip_protection DESC,
    data_security DESC,
    supplier_name ASC;

-- ------------------------------------------------------------
-- 2.4 Suppliers with operational or regulatory indicators
-- ------------------------------------------------------------

SELECT
    supplier_name,
    location,
    labor_unrests,
    environmental_incidents
FROM supplier_risk
WHERE labor_unrests = 1 OR environmental_incidents = 1
ORDER BY 
	labor_unrests DESC,
    environmental_incidents DESC;

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
    single_source,
    ip_protection,
    labor_unrests,
    environmental_incidents,
    single_source + (ip_protection = 0) + labor_unrests + environmental_incidents AS binary_risk_indicator_count
FROM supplier_risk
ORDER BY
	binary_risk_indicator_count DESC;

-- ------------------------------------------------------------
-- 2.6 Supplier financial profile
-- ------------------------------------------------------------

SELECT
    supplier_name,
    location,
    revenue,
    cash_from_operations,
    ROUND(cash_from_operations / NULLIF(revenue, 0), 4) AS operating_cash_flow_margin,
    credit_rating,
    s_otd
FROM supplier_risk
ORDER BY operating_cash_flow_margin ASC;

-- ------------------------------------------------------------
-- 2.7 Supplier quantitative performance profile
--
-- This query summarizes supplier performance across three
-- quantitative dimensions: credit quality, delivery
-- performance, and data security.
--
-- All numeric indicators are normalized to a transparent
-- 0–100 performance scale:
-- - Higher score = better performance
-- - Lower score = weaker performance
--
-- An equally weighted overall performance score is calculated
-- as a descriptive summary of the three quantitative
-- dimensions. It is intended for comparison purposes only
-- and should not be interpreted as a validated supplier
-- evaluation model.
-- 
-- Composite score is calculated from credit, delivery, and data security performance only.
-- ------------------------------------------------------------

WITH supplier_performance AS (
    SELECT
        supplier_name,
        location,
        credit_rating,
        s_otd,
        data_security,
        (credit_rating - 1) * 25 AS credit_performance_score,
        s_otd * 100 AS delivery_performance_score,
        data_security * 10 AS data_security_performance_score
    FROM supplier_risk
)

SELECT
    supplier_name,
    location,
    credit_rating,
    s_otd,
    data_security,
    credit_performance_score,
    delivery_performance_score,
    data_security_performance_score,
    ROUND((credit_performance_score + delivery_performance_score + data_security_performance_score) / 3, 2) AS composite_performance_score
FROM supplier_performance
ORDER BY composite_performance_score ASC;

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
    ROUND(100.0 * (q4_2020_projection - q3_2020_actual) / NULLIF(q3_2020_actual, 0), 2) AS q4_vs_q3_growth_percentage,
    ROUND(100.0 * (q1_2021_projection - q4_2020_projection) / NULLIF(q4_2020_projection, 0), 2) AS q1_vs_q4_growth_percentage,
    ROUND(100.0 * (q2_2021_projection - q1_2021_projection) / NULLIF(q1_2021_projection, 0), 2) AS q2_vs_q1_growth_percentage,
    ROUND(100.0 * (q2_2021_projection - q3_2020_actual) / NULLIF(q3_2020_actual, 0), 2) AS q2_vs_q3_growth_percentage
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
-- 3.4 Product Cycle Time Profile
-- ------------------------------------------------------------

SELECT
    product,
    tubing_hours,
    hot_forming_hours,
    washing_hours,
    packing_hours,
    tubing_hours + hot_forming_hours + washing_hours + packing_hours AS summed_process_cycle_time_hours,
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
ORDER BY summed_process_cycle_time_hours DESC;

-- ------------------------------------------------------------
-- 3.5 Largest reported reject category by product
-- ------------------------------------------------------------

SELECT
    product,
    bend_tubing_reject_rate,
    contamination_reject_rate,
    glass_breakage_reject_rate,
    air_bubble_reject_rate,
    ROUND(bend_tubing_reject_rate + contamination_reject_rate + glass_breakage_reject_rate + air_bubble_reject_rate, 4) AS summed_reported_defect_rates,
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
-- 3.7 Approximate cycle-time requirement for Q2 demand
--
-- This multiplication is an analytical workload indicator.
-- Its operational interpretation depends on whether cycle time
-- is reported per individual unit, batch, or another basis.
-- ------------------------------------------------------------

SELECT
    dp.product,
    dp.q2_2021_projection,
    pct.cycle_time_hours,
    ROUND(dp.q2_2021_projection * pct.cycle_time_hours, 2) AS projected_q2_cycle_time_requirement
FROM demand_projections AS dp
INNER JOIN product_cycle_time AS pct
    ON dp.product = pct.product
ORDER BY projected_q2_cycle_time_requirement DESC;

-- ------------------------------------------------------------
-- Manufacturing Capacity
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- 3.8 Total downtime by production unit
-- ------------------------------------------------------------

SELECT
    production_unit,
    weekends_holidays_days,
    planned_shutdown_days,
    unplanned_shutdown_days,
    weekends_holidays_days + planned_shutdown_days + unplanned_shutdown_days AS total_non_operating_days
FROM manufacturing_capacity
ORDER BY
    total_non_operating_days DESC,
    unplanned_shutdown_days DESC;

-- ------------------------------------------------------------
-- 3.9 Manufacturing downtime summary
-- ------------------------------------------------------------

SELECT
    COUNT(*) AS total_production_units,
    SUM(weekends_holidays_days)
        AS total_weekends_holidays_days,
    SUM(planned_shutdown_days)
        AS total_planned_shutdown_days,
    SUM(unplanned_shutdown_days)
        AS total_unplanned_shutdown_days,
    SUM(weekends_holidays_days + planned_shutdown_days + unplanned_shutdown_days) AS total_non_operating_days
FROM manufacturing_capacity;

