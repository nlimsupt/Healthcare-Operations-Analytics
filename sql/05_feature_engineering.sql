-- ============================================================
-- 05_feature_engineering.sql
-- Purpose:
-- Create reproducible inventory-planning metrics while
-- preserving the original inventory_planning source table.
--
-- Source assumptions:
-- - Planning year = 360 days
-- - Desired service level = 98%
-- - Z-score for 98% service level = 2.05374891
-- - Minimum observed COV = 0.09
-- - Maximum observed COV = 3.46
-- ============================================================

USE healthcare_operations_analytics;

DROP VIEW IF EXISTS inventory_features;

CREATE VIEW inventory_features AS

WITH constants AS (
    SELECT
        360.0 AS planning_days,
        0.09 AS minimum_cov,
        3.46 AS maximum_cov,
        0.98 AS desired_service_level,
        2.05374891 AS service_level_z_score
),

-- ------------------------------------------------------------
-- Step 1: Calculate first-level inventory metrics
-- ------------------------------------------------------------
base_metrics AS (
    SELECT
        ip.*,
        
        -- Formula from original coursework:
        -- Annual demand minus current inventory units
        (
            ip.annual_demand
            - ip.inventory_units_on_hand
        ) AS obsolete_inventory,

        -- Normalize demand variability to a 0–1 scale
        (
            (ip.demand_variability_cov - c.minimum_cov)
            / NULLIF(c.maximum_cov - c.minimum_cov, 0)
        ) AS normalized_cov,

        -- Average daily demand based on a 360-day planning year
        (
            ip.annual_demand
            / c.planning_days
        ) AS daily_demand,

        c.desired_service_level,
        c.service_level_z_score
    FROM inventory_planning AS ip
    CROSS JOIN constants AS c
),

-- ------------------------------------------------------------
-- Step 2: Calculate demand during supplier lead time
-- ------------------------------------------------------------
lead_time_metrics AS (
    SELECT
        bm.*,
        (
            bm.daily_demand
            * bm.lead_time_days
        ) AS demand_during_lead_time
    FROM base_metrics AS bm
),

-- ------------------------------------------------------------
-- Step 3: Calculate demand deviation during lead time
-- ------------------------------------------------------------
variability_metrics AS (
    SELECT
        ltm.*,
        (
            ltm.normalized_cov
            * ltm.demand_during_lead_time
        ) AS standard_deviation_during_lead_time
    FROM lead_time_metrics AS ltm
),

-- ------------------------------------------------------------
-- Step 4: Calculate safety stock
-- ------------------------------------------------------------
safety_stock_metrics AS (
    SELECT
        vm.*,
        (
            vm.service_level_z_score
            * vm.standard_deviation_during_lead_time
        ) AS safety_stock
    FROM variability_metrics AS vm
)

-- ------------------------------------------------------------
-- Step 5: Calculate final reorder point
-- ------------------------------------------------------------
SELECT
    ssm.sku,
    ssm.standard_price,
    ssm.on_hand_stock_value,
    ssm.inventory_units_on_hand,
    ssm.average_monthly_usage,

    ssm.october_demand,
    ssm.november_demand,
    ssm.december_demand,
    ssm.january_demand,
    ssm.february_demand,
    ssm.march_demand,
    ssm.april_demand,
    ssm.may_demand,
    ssm.june_demand,
    ssm.july_demand,
    ssm.august_demand,
    ssm.september_demand,

    ssm.annual_demand,
    ssm.average_monthly_usage_trend,
    ssm.supplier_on_time_delivery,
    ssm.demand_variability_cov,
    ssm.lead_time_days,

    -- Derived inventory metrics
    ssm.obsolete_inventory,
    ssm.normalized_cov,
    ssm.daily_demand,
    ssm.demand_during_lead_time,
    ssm.standard_deviation_during_lead_time,
    ssm.desired_service_level,
    ssm.service_level_z_score,
    ssm.safety_stock,
    (
        ssm.demand_during_lead_time
        + ssm.safety_stock
    ) AS reorder_point
FROM safety_stock_metrics AS ssm;