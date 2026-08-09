-- ============================================================
-- 04_validation.sql
-- Purpose:
-- Validate row counts, primary keys, missing values,
-- accepted values, numeric ranges, and cross-table consistency.
-- ============================================================

USE healthcare_operations_analytics;

-- ============================================================
-- 1. ROW COUNT VALIDATION
-- ============================================================

SELECT 'supplier_risk' AS table_name, COUNT(*) AS total_rows
FROM supplier_risk
UNION ALL
SELECT 'inventory_planning', COUNT(*)
FROM inventory_planning
UNION ALL
SELECT 'demand_projections', COUNT(*)
FROM demand_projections
UNION ALL
SELECT 'product_cycle_time', COUNT(*)
FROM product_cycle_time
UNION ALL
SELECT 'process_cycle_time', COUNT(*)
FROM process_cycle_time
UNION ALL
SELECT 'product_rejects', COUNT(*)
FROM product_rejects
UNION ALL
SELECT 'manufacturing_capacity', COUNT(*)
FROM manufacturing_capacity;

-- ============================================================
-- 2. PRIMARY-KEY UNIQUENESS
-- ============================================================

-- Supplier Risk
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT supplier_name) AS unique_keys
FROM supplier_risk;

SELECT
    supplier_name,
    COUNT(*) AS duplicate_count
FROM supplier_risk
GROUP BY supplier_name
HAVING COUNT(*) > 1;

-- Inventory Planning
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT sku) AS unique_keys
FROM inventory_planning;

SELECT
    sku,
    COUNT(*) AS duplicate_count
FROM inventory_planning
GROUP BY sku
HAVING COUNT(*) > 1;

-- Demand Projections
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT product) AS unique_keys
FROM demand_projections;

SELECT
    product,
    COUNT(*) AS duplicate_count
FROM demand_projections
GROUP BY product
HAVING COUNT(*) > 1;

-- Product Cycle Time
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT product) AS unique_keys
FROM product_cycle_time;

SELECT
    product,
    COUNT(*) AS duplicate_count
FROM product_cycle_time
GROUP BY product
HAVING COUNT(*) > 1;

-- Process Cycle Time
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT product) AS unique_keys
FROM process_cycle_time;

SELECT
    product,
    COUNT(*) AS duplicate_count
FROM process_cycle_time
GROUP BY product
HAVING COUNT(*) > 1;

-- Product Rejects
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT product) AS unique_keys
FROM product_rejects;

SELECT
    product,
    COUNT(*) AS duplicate_count
FROM product_rejects
GROUP BY product
HAVING COUNT(*) > 1;

-- Manufacturing Capacity
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT production_unit) AS unique_keys
FROM manufacturing_capacity;

SELECT
    production_unit,
    COUNT(*) AS duplicate_count
FROM manufacturing_capacity
GROUP BY production_unit
HAVING COUNT(*) > 1;

-- ============================================================
-- 3. MISSING-VALUE VALIDATION
-- ============================================================

-- Supplier Risk
SELECT
    SUM(supplier_name IS NULL) AS supplier_name_nulls,
    SUM(location IS NULL) AS location_nulls,
    SUM(revenue IS NULL) AS revenue_nulls,
    SUM(cash_from_operations IS NULL) AS cash_from_operations_nulls,
    SUM(credit_rating IS NULL) AS credit_rating_nulls,
    SUM(s_otd IS NULL) AS s_otd_nulls,
    SUM(single_source IS NULL) AS single_source_nulls,
    SUM(ip_protection IS NULL) AS ip_protection_nulls,
    SUM(data_security IS NULL) AS data_security_nulls,
    SUM(labor_unrests IS NULL) AS labor_unrests_nulls,
    SUM(environmental_incidents IS NULL) AS environmental_incidents_nulls
FROM supplier_risk;

-- Inventory Planning
SELECT
    SUM(sku IS NULL) AS sku_nulls,
    SUM(standard_price IS NULL) AS standard_price_nulls,
    SUM(on_hand_stock_value IS NULL) AS on_hand_stock_value_nulls,
    SUM(inventory_units_on_hand IS NULL) AS inventory_units_nulls,
    SUM(average_monthly_usage IS NULL) AS average_monthly_usage_nulls,
    SUM(october_demand IS NULL) AS october_nulls,
    SUM(november_demand IS NULL) AS november_nulls,
    SUM(december_demand IS NULL) AS december_nulls,
    SUM(january_demand IS NULL) AS january_nulls,
    SUM(february_demand IS NULL) AS february_nulls,
    SUM(march_demand IS NULL) AS march_nulls,
    SUM(april_demand IS NULL) AS april_nulls,
    SUM(may_demand IS NULL) AS may_nulls,
    SUM(june_demand IS NULL) AS june_nulls,
    SUM(july_demand IS NULL) AS july_nulls,
    SUM(august_demand IS NULL) AS august_nulls,
    SUM(september_demand IS NULL) AS september_nulls,
    SUM(annual_demand IS NULL) AS annual_demand_nulls,
    SUM(average_monthly_usage_trend IS NULL) AS trend_nulls,
    SUM(supplier_on_time_delivery IS NULL) AS supplier_otd_nulls,
    SUM(demand_variability_cov IS NULL) AS cov_nulls,
    SUM(lead_time_days IS NULL) AS lead_time_nulls
FROM inventory_planning;

-- Demand Projections
SELECT
    SUM(product IS NULL) AS product_nulls,
    SUM(q3_2020_actual IS NULL) AS q3_2020_actual_nulls,
    SUM(q4_2020_projection IS NULL) AS q4_2020_projection_nulls,
    SUM(q1_2021_projection IS NULL) AS q1_2021_projection_nulls,
    SUM(q2_2021_projection IS NULL) AS q2_2021_projection_nulls
FROM demand_projections;

-- Product Cycle Time
SELECT
    SUM(product IS NULL) AS product_nulls,
    SUM(cycle_time_hours IS NULL) AS cycle_time_nulls
FROM product_cycle_time;

-- Process Cycle Time
SELECT
    SUM(product IS NULL) AS product_nulls,
    SUM(tubing_hours IS NULL) AS tubing_nulls,
    SUM(hot_forming_hours IS NULL) AS hot_forming_nulls,
    SUM(washing_hours IS NULL) AS washing_nulls,
    SUM(packing_hours IS NULL) AS packing_nulls
FROM process_cycle_time;

-- Product Rejects
SELECT
    SUM(product IS NULL) AS product_nulls,
    SUM(bend_tubing_reject_rate IS NULL) AS bend_tubing_nulls,
    SUM(contamination_reject_rate IS NULL) AS contamination_nulls,
    SUM(glass_breakage_reject_rate IS NULL) AS glass_breakage_nulls,
    SUM(air_bubble_reject_rate IS NULL) AS air_bubble_nulls
FROM product_rejects;

-- Manufacturing Capacity
SELECT
    SUM(production_unit IS NULL) AS production_unit_nulls,
    SUM(weekends_holidays_days IS NULL) AS weekends_holidays_nulls,
    SUM(planned_shutdown_days IS NULL) AS planned_shutdown_nulls,
    SUM(unplanned_shutdown_days IS NULL) AS unplanned_shutdown_nulls
FROM manufacturing_capacity;

-- ============================================================
-- 4. CATEGORICAL-VALUE VALIDATION
-- ============================================================

-- Boolean fields must contain only 0 or 1
SELECT *
FROM supplier_risk
WHERE single_source NOT IN (0, 1)
   OR ip_protection NOT IN (0, 1)
   OR labor_unrests NOT IN (0, 1)
   OR environmental_incidents NOT IN (0, 1);

-- Review supplier locations
SELECT
    location,
    COUNT(*) AS supplier_count
FROM supplier_risk
GROUP BY location
ORDER BY supplier_count DESC, location;

-- Review product labels across production tables
SELECT DISTINCT product
FROM demand_projections
ORDER BY product;

SELECT DISTINCT product
FROM product_cycle_time
ORDER BY product;

SELECT DISTINCT product
FROM process_cycle_time
ORDER BY product;

SELECT DISTINCT product
FROM product_rejects
ORDER BY product;

-- ============================================================
-- 5. NUMERIC-RANGE VALIDATION
-- ============================================================

-- Supplier Risk profiling
SELECT
    MIN(revenue) AS min_revenue,
    MAX(revenue) AS max_revenue,
    MIN(cash_from_operations) AS min_cash_from_operations,
    MAX(cash_from_operations) AS max_cash_from_operations,
    MIN(credit_rating) AS min_credit_rating,
    MAX(credit_rating) AS max_credit_rating,
    MIN(s_otd) AS min_s_otd,
    MAX(s_otd) AS max_s_otd,
    MIN(data_security) AS min_data_security,
    MAX(data_security) AS max_data_security
FROM supplier_risk;

-- Invalid supplier values
SELECT *
FROM supplier_risk
WHERE revenue < 0
   OR s_otd < 0
   OR s_otd > 1;

-- Inventory profiling
SELECT
    MIN(standard_price) AS min_standard_price,
    MAX(standard_price) AS max_standard_price,
    MIN(on_hand_stock_value) AS min_stock_value,
    MAX(on_hand_stock_value) AS max_stock_value,
    MIN(inventory_units_on_hand) AS min_inventory_units,
    MAX(inventory_units_on_hand) AS max_inventory_units,
    MIN(average_monthly_usage) AS min_apu,
    MAX(average_monthly_usage) AS max_apu,
    MIN(average_monthly_usage_trend) AS min_apu_trend,
    MAX(average_monthly_usage_trend) AS max_apu_trend,
    MIN(supplier_on_time_delivery) AS min_supplier_otd,
    MAX(supplier_on_time_delivery) AS max_supplier_otd,
    MIN(demand_variability_cov) AS min_cov,
    MAX(demand_variability_cov) AS max_cov,
    MIN(lead_time_days) AS min_lead_time,
    MAX(lead_time_days) AS max_lead_time
FROM inventory_planning;

-- Invalid inventory values
SELECT *
FROM inventory_planning
WHERE standard_price < 0
   OR on_hand_stock_value < 0
   OR inventory_units_on_hand < 0
   OR average_monthly_usage < 0
   OR annual_demand < 0
   OR supplier_on_time_delivery < 0
   OR supplier_on_time_delivery > 1
   OR demand_variability_cov < 0
   OR lead_time_days < 0;

-- Invalid monthly demand
SELECT *
FROM inventory_planning
WHERE october_demand < 0
   OR november_demand < 0
   OR december_demand < 0
   OR january_demand < 0
   OR february_demand < 0
   OR march_demand < 0
   OR april_demand < 0
   OR may_demand < 0
   OR june_demand < 0
   OR july_demand < 0
   OR august_demand < 0
   OR september_demand < 0;

-- Invalid production demand
SELECT *
FROM demand_projections
WHERE q3_2020_actual < 0
   OR q4_2020_projection < 0
   OR q1_2021_projection < 0
   OR q2_2021_projection < 0;

-- Invalid cycle times
SELECT *
FROM product_cycle_time
WHERE cycle_time_hours < 0;

SELECT *
FROM process_cycle_time
WHERE tubing_hours < 0
   OR hot_forming_hours < 0
   OR washing_hours < 0
   OR packing_hours < 0;

-- Invalid reject rates
SELECT *
FROM product_rejects
WHERE bend_tubing_reject_rate < 0
   OR bend_tubing_reject_rate > 1
   OR contamination_reject_rate < 0
   OR contamination_reject_rate > 1
   OR glass_breakage_reject_rate < 0
   OR glass_breakage_reject_rate > 1
   OR air_bubble_reject_rate < 0
   OR air_bubble_reject_rate > 1;

-- Invalid shutdown-day values
SELECT *
FROM manufacturing_capacity
WHERE weekends_holidays_days < 0
   OR planned_shutdown_days < 0
   OR unplanned_shutdown_days < 0;
   
-- ============================================================
-- 6. CALCULATION CONSISTENCY
-- ============================================================

SELECT
    sku,
    annual_demand,
    (
        COALESCE(october_demand, 0) +
        COALESCE(november_demand, 0) +
        COALESCE(december_demand, 0) +
        COALESCE(january_demand, 0) +
        COALESCE(february_demand, 0) +
        COALESCE(march_demand, 0) +
        COALESCE(april_demand, 0) +
        COALESCE(may_demand, 0) +
        COALESCE(june_demand, 0) +
        COALESCE(july_demand, 0) +
        COALESCE(august_demand, 0) +
        COALESCE(september_demand, 0)
    ) AS calculated_annual_demand,
    annual_demand - (
        COALESCE(october_demand, 0) +
        COALESCE(november_demand, 0) +
        COALESCE(december_demand, 0) +
        COALESCE(january_demand, 0) +
        COALESCE(february_demand, 0) +
        COALESCE(march_demand, 0) +
        COALESCE(april_demand, 0) +
        COALESCE(may_demand, 0) +
        COALESCE(june_demand, 0) +
        COALESCE(july_demand, 0) +
        COALESCE(august_demand, 0) +
        COALESCE(september_demand, 0)
    ) AS difference
FROM inventory_planning
WHERE ABS(
    annual_demand - (
        COALESCE(october_demand, 0) +
        COALESCE(november_demand, 0) +
        COALESCE(december_demand, 0) +
        COALESCE(january_demand, 0) +
        COALESCE(february_demand, 0) +
        COALESCE(march_demand, 0) +
        COALESCE(april_demand, 0) +
        COALESCE(may_demand, 0) +
        COALESCE(june_demand, 0) +
        COALESCE(july_demand, 0) +
        COALESCE(august_demand, 0) +
        COALESCE(september_demand, 0)
    )
) > 0.01;

-- ============================================================
-- 7. CROSS-TABLE PRODUCT CONSISTENCY
-- ============================================================

-- Products appearing in demand projections
-- but missing from another production table
SELECT
    dp.product,
    CASE
        WHEN pct.product IS NULL THEN 'Missing from product_cycle_time'
        WHEN prct.product IS NULL THEN 'Missing from process_cycle_time'
        WHEN pr.product IS NULL THEN 'Missing from product_rejects'
    END AS validation_issue
FROM demand_projections AS dp
LEFT JOIN product_cycle_time AS pct
    ON dp.product = pct.product
LEFT JOIN process_cycle_time AS prct
    ON dp.product = prct.product
LEFT JOIN product_rejects AS pr
    ON dp.product = pr.product
WHERE pct.product IS NULL
   OR prct.product IS NULL
   OR pr.product IS NULL;

-- Compare all product sets
SELECT
    product,
    SUM(source_table = 'demand_projections') AS in_demand_projections,
    SUM(source_table = 'product_cycle_time') AS in_product_cycle_time,
    SUM(source_table = 'process_cycle_time') AS in_process_cycle_time,
    SUM(source_table = 'product_rejects') AS in_product_rejects
FROM (
    SELECT product, 'demand_projections' AS source_table
    FROM demand_projections
    UNION ALL
    SELECT product, 'product_cycle_time'
    FROM product_cycle_time
    UNION ALL
    SELECT product, 'process_cycle_time'
    FROM process_cycle_time
    UNION ALL
    SELECT product, 'product_rejects'
    FROM product_rejects
) AS product_sources
GROUP BY product
ORDER BY product;

-- ============================================================
-- 8. FINAL VALIDATION SUMMARY
-- ============================================================

SELECT
    'supplier_risk' AS table_name,
    COUNT(*) AS total_rows,
    COUNT(DISTINCT supplier_name) AS unique_primary_keys,
    SUM(supplier_name IS NULL) AS null_primary_keys
FROM supplier_risk
UNION ALL
SELECT
    'inventory_planning',
    COUNT(*),
    COUNT(DISTINCT sku),
    SUM(sku IS NULL)
FROM inventory_planning
UNION ALL
SELECT
    'demand_projections',
    COUNT(*),
    COUNT(DISTINCT product),
    SUM(product IS NULL)
FROM demand_projections
UNION ALL
SELECT
    'product_cycle_time',
    COUNT(*),
    COUNT(DISTINCT product),
    SUM(product IS NULL)
FROM product_cycle_time
UNION ALL
SELECT
    'process_cycle_time',
    COUNT(*),
    COUNT(DISTINCT product),
    SUM(product IS NULL)
FROM process_cycle_time
UNION ALL
SELECT
    'product_rejects',
    COUNT(*),
    COUNT(DISTINCT product),
    SUM(product IS NULL)
FROM product_rejects
UNION ALL
SELECT
    'manufacturing_capacity',
    COUNT(*),
    COUNT(DISTINCT production_unit),
    SUM(production_unit IS NULL)
FROM manufacturing_capacity;