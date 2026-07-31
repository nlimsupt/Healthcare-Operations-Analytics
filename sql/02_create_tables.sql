CREATE TABLE supplier_risk (
	supplier_name VARCHAR(100) PRIMARY KEY,
    location VARCHAR(100),
    revenue DECIMAL(10,2),
    cash_from_operation DECIMAL(10,2),
    credit_rating INT,
    s_otd DECIMAL(5,2),
    single_source BOOLEAN,
    ip_protection BOOLEAN,
    data_security INT,
    labor_unrests BOOLEAN,
    environmental_incidents BOOLEAN
);

CREATE TABLE inventory_planning (
	sku VARCHAR(50) PRIMARY KEY,
    standard_price DECIMAL(14,2) NOT NULL,
    on_hand_stock_value DECIMAL(16,2) NOT NULL,
    inventory_units_on_hand INT NOT NULL,
    average_monthly_usage DECIMAL(14,2) NOT NULL,
    october_demand DECIMAL(14,2),
    november_demand DECIMAL(14,2),
    december_demand DECIMAL(14,2),
    january_demand DECIMAL(14,2),
    february_demand DECIMAL(14,2),
    march_demand DECIMAL(14,2),
    april_demand DECIMAL(14,2),
    may_demand DECIMAL(14,2),
    june_demand DECIMAL(14,2),
    july_demand DECIMAL(14,2),
    august_demand DECIMAL(14,2),
    september_demand DECIMAL(14,2),
    annual_demand DECIMAL(14,2),
    average_monthly_usage_trend DECIMAL(10,4),
    supplier_on_time_delivery DECIMAL(10,4),
    demand_variability_cov DECIMAL(10,4),
    lead_time_days INT
);

CREATE TABLE demand_projections (
    product VARCHAR(100) PRIMARY KEY,
    q3_2020_actual DECIMAL(16, 2) NOT NULL,
    q4_2020_projection DECIMAL(16, 2) NOT NULL,
    q1_2021_projection DECIMAL(16, 2) NOT NULL,
    q2_2021_projection DECIMAL(16, 2) NOT NULL
);

CREATE TABLE product_cycle_time (
    product VARCHAR(100) PRIMARY KEY,
    cycle_time_hours DECIMAL(12, 4) NOT NULL
);

CREATE TABLE process_cycle_time (
    product VARCHAR(100) PRIMARY KEY,
    tubing_hours DECIMAL(12, 4) NOT NULL,
    hot_forming_hours DECIMAL(12, 4) NOT NULL,
    washing_hours DECIMAL(12, 4) NOT NULL,
    packing_hours DECIMAL(12, 4) NOT NULL
);

CREATE TABLE product_rejects (
    product VARCHAR(100) PRIMARY KEY,
    bend_tubing_reject_rate DECIMAL(10, 6) NOT NULL,
    contamination_reject_rate DECIMAL(10, 6) NOT NULL,
    glass_breakage_reject_rate DECIMAL(10, 6) NOT NULL,
    air_bubble_reject_rate DECIMAL(10, 6) NOT NULL
);

CREATE TABLE manufacturing_capacity (
    production_unit VARCHAR(100) PRIMARY KEY,
    weekends_holidays_days INT NOT NULL,
    planned_shutdown_days INT NOT NULL,
    unplanned_shutdown_days INT NOT NULL
);