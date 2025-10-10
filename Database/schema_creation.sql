-- =====================================================
-- Olist: Brazilian E-Commerce Data Warehouse
-- Schema Design - 3 Fact Tables and 7 Dimension Tables
-- =====================================================

-- Drop existing tables
DROP TABLE IF EXISTS fact_sales CASCADE;
DROP TABLE IF EXISTS fact_delivery_performance CASCADE;
DROP TABLE IF EXISTS fact_customer_reviews CASCADE;
DROP TABLE IF EXISTS dim_date CASCADE;
DROP TABLE IF EXISTS dim_geography CASCADE;
DROP TABLE IF EXISTS dim_customer CASCADE;
DROP TABLE IF EXISTS dim_product CASCADE;
DROP TABLE IF EXISTS dim_seller CASCADE;
DROP TABLE IF EXISTS dim_payment_type CASCADE;
DROP TABLE IF EXISTS dim_order_status CASCADE;

-- =====================================================
-- DIMENSION TABLES
-- =====================================================

-- DIM_DATE - Standard Date Dimension
CREATE TABLE dim_date (
    date_key SERIAL PRIMARY KEY,
    full_date DATE UNIQUE NOT NULL,
    day_of_week INTEGER CHECK (day_of_week BETWEEN 1 AND 7), -- 1=Sunday
    day_name VARCHAR(10) NOT NULL,
    day_of_month INTEGER CHECK (day_of_month BETWEEN 1 AND 31),
    month_number INTEGER CHECK (month_number BETWEEN 1 AND 12),
    month_name VARCHAR(10) NOT NULL,
    quarter_number INTEGER CHECK (quarter_number BETWEEN 1 AND 4),
    year_number INTEGER CHECK (year_number > 2000),
    is_weekend BOOLEAN NOT NULL DEFAULT FALSE
);

-- DIM_GEOGRAPHY - Geographic Dimension
CREATE TABLE dim_geography (
    geography_key SERIAL PRIMARY KEY,
    zip_code VARCHAR(10) NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(2) NOT NULL,
    region VARCHAR(20) NOT NULL, -- Northeast, Southeast, South, North, Center-West
    latitude DECIMAL(10,7),
    longitude DECIMAL(10,7),
    CONSTRAINT uq_geography_zip UNIQUE (zip_code)
);

-- DIM_CUSTOMER - Customer Dimension (SCD Type 2)
CREATE TABLE dim_customer (
    customer_key SERIAL PRIMARY KEY,
    customer_id VARCHAR(50) NOT NULL,
    customer_unique_id VARCHAR(50) NOT NULL,
    customer_zip_code VARCHAR(10) NOT NULL,
    customer_city VARCHAR(100) NOT NULL,
    customer_state VARCHAR(2) NOT NULL,
    customer_region VARCHAR(20) NOT NULL,
    -- SCD Type 2 fields
    effective_date DATE NOT NULL DEFAULT CURRENT_DATE,
    expiry_date DATE DEFAULT '9999-12-31',
    is_current BOOLEAN DEFAULT TRUE,
    CONSTRAINT chk_customer_dates CHECK (effective_date <= expiry_date),
    CONSTRAINT uq_customer_version UNIQUE (customer_id, effective_date)
);

-- DIM_PRODUCT - Product Dimension
CREATE TABLE dim_product (
    product_key SERIAL PRIMARY KEY,
    product_id VARCHAR(50) UNIQUE NOT NULL,
    product_category_portuguese VARCHAR(100),
    product_category_english VARCHAR(100),
	product_name_length INTEGER,
    product_photos_qty INTEGER DEFAULT 0,
    product_weight_grams INTEGER,
    product_length_cm INTEGER,
    product_height_cm INTEGER,
    product_width_cm INTEGER,
    -- Derived attributes
    product_volume_cm3 INTEGER,
    product_size_category VARCHAR(20) DEFAULT 'Unknown', -- Small, Medium, Large, XLarge
	product_category_level_1 VARCHAR(50),
    has_complete_attributes BOOLEAN DEFAULT FALSE -- TRUE if no nulls in key attributes
);

-- DIM_SELLER - Seller Dimension
CREATE TABLE dim_seller (
    seller_key SERIAL PRIMARY KEY,
    seller_id VARCHAR(50) UNIQUE NOT NULL,
    seller_zip_code VARCHAR(10) NOT NULL,
    seller_city VARCHAR(100) NOT NULL,
    seller_state VARCHAR(2) NOT NULL,
    seller_region VARCHAR(20) NOT NULL
);

-- DIM_PAYMENT_TYPE - Payment Method Dimension
CREATE TABLE dim_payment_type (
    payment_type_key SERIAL PRIMARY KEY,
    payment_type VARCHAR(20) UNIQUE NOT NULL, -- credit_card, boleto, voucher, debit_card
    payment_method_category VARCHAR(20) NOT NULL -- Card, Cash, Digital, Other
);

-- DIM_ORDER_STATUS - Order Status Dimension
CREATE TABLE dim_order_status (
    order_status_key SERIAL PRIMARY KEY,
    order_status VARCHAR(20) UNIQUE NOT NULL, -- delivered, shipped, processing, canceled, etc.
    status_category VARCHAR(20) NOT NULL, -- Completed, In Progress, Cancelled
    is_final_status BOOLEAN DEFAULT FALSE -- TRUE for delivered, canceled or unavailable
);

-- =====================================================
-- FACT TABLES
-- =====================================================

-- FACT_SALES - Grain: One row per order item
CREATE TABLE fact_sales (
    sales_key SERIAL PRIMARY KEY,
    -- Business Keys
    order_id VARCHAR(50) NOT NULL,
    order_item_id INTEGER NOT NULL,
    -- Foreign Keys to Dimensions
    customer_key INTEGER NOT NULL REFERENCES dim_customer(customer_key),
    product_key INTEGER NOT NULL REFERENCES dim_product(product_key),
    seller_key INTEGER NOT NULL REFERENCES dim_seller(seller_key),
    purchase_date_key INTEGER NOT NULL REFERENCES dim_date(date_key),
    payment_type_key INTEGER NOT NULL REFERENCES dim_payment_type(payment_type_key),
    -- Additive Measures
    item_price DECIMAL(10,2) NOT NULL CHECK (item_price >= 0),
    freight_value DECIMAL(10,2) NOT NULL CHECK (freight_value >= 0),
	-- Derived Measures (calculated during ETL)
    total_item_value DECIMAL(10,2) NOT NULL CHECK (total_item_value >= 0),
	-- Total payement
    payment_value DECIMAL(10,2) NOT NULL CHECK (payment_value >= 0),
    quantity INTEGER DEFAULT 1 CHECK (quantity > 0),
    CONSTRAINT uq_sales_grain UNIQUE(order_id, order_item_id)
);

-- FACT_DELIVERY_PERFORMANCE - Grain: One row per order
CREATE TABLE fact_delivery_performance (
    delivery_key SERIAL PRIMARY KEY,
    -- Business Key
    order_id VARCHAR(50) UNIQUE NOT NULL,
    -- Foreign Keys to Dimensions
    customer_key INTEGER NOT NULL REFERENCES dim_customer(customer_key),
    seller_key INTEGER NOT NULL REFERENCES dim_seller(seller_key),
    order_date_key INTEGER NOT NULL REFERENCES dim_date(date_key),
    approved_date_key INTEGER REFERENCES dim_date(date_key),
    delivered_date_key INTEGER REFERENCES dim_date(date_key),
    est_delivery_date_key INTEGER REFERENCES dim_date(date_key),
    order_status_key INTEGER NOT NULL REFERENCES dim_order_status(order_status_key),
    -- Additive Measures
    order_value DECIMAL(10,2) NOT NULL CHECK (order_value >= 0),
    freight_value DECIMAL(10,2) NOT NULL CHECK (freight_value >= 0),
    item_count INTEGER NOT NULL CHECK (item_count > 0),
    -- Delivery Performance Measures
    estimated_delivery_days INTEGER,
    actual_delivery_days INTEGER,
    delivery_delay_days INTEGER,
	delivery_performance_score DECIMAL(3,2), -- Calculated composite score (0.00-1.00)
    -- Performance Flags
    is_on_time BOOLEAN,
    is_delivered BOOLEAN DEFAULT FALSE
);

-- FACT_CUSTOMER_REVIEWS - Grain: One row per review
CREATE TABLE fact_customer_reviews (
    review_key SERIAL PRIMARY KEY,
    -- Business Keys
    review_id VARCHAR(50) UNIQUE NOT NULL,
    order_id VARCHAR(50) NOT NULL,
    -- Foreign Keys to Dimensions
    customer_key INTEGER NOT NULL REFERENCES dim_customer(customer_key),
    product_key INTEGER NOT NULL REFERENCES dim_product(product_key),
    seller_key INTEGER NOT NULL REFERENCES dim_seller(seller_key),
    review_date_key INTEGER NOT NULL REFERENCES dim_date(date_key),
    -- Measures
    review_score INTEGER NOT NULL CHECK (review_score BETWEEN 1 AND 5),
    -- Review Analysis Flags
	review_score_category VARCHAR(10), -- 'Poor', 'Fair', 'Good', 'Excellent'
    is_positive_review BOOLEAN, -- score >= 4
    is_negative_review BOOLEAN, -- score <= 2
    has_comment BOOLEAN DEFAULT FALSE
);

-- =====================================================
-- INDEXES FOR PERFORMANCE OPTIMIZATION
-- =====================================================

-- Date Dimension Indexes
CREATE INDEX idx_dim_date_full_date ON dim_date(full_date);
CREATE INDEX idx_dim_date_year_month ON dim_date(year_number, month_number);
CREATE INDEX idx_dim_date_quarter ON dim_date(quarter_number, year_number);

-- Geography Dimension Indexes
CREATE INDEX idx_dim_geography_state ON dim_geography(state);
CREATE INDEX idx_dim_geography_region ON dim_geography(region);
CREATE INDEX idx_dim_geography_city_state ON dim_geography(city, state);

-- Customer Dimension Indexes
CREATE INDEX idx_dim_customer_unique_id ON dim_customer(customer_unique_id);
CREATE INDEX idx_dim_customer_current ON dim_customer(is_current) WHERE is_current = TRUE;
CREATE INDEX idx_dim_customer_state ON dim_customer(customer_state);

-- Product Dimension Indexes
CREATE INDEX idx_dim_product_category_eng ON dim_product(product_category_english);
CREATE INDEX idx_dim_product_size_cat ON dim_product(product_size_category);
CREATE INDEX idx_dim_product_complete ON dim_product(has_complete_attributes);

-- Seller Dimension Indexes
CREATE INDEX idx_dim_seller_state ON dim_seller(seller_state);

-- Fact Sales Indexes
CREATE INDEX idx_fact_sales_date_customer ON fact_sales(purchase_date_key, customer_key);
CREATE INDEX idx_fact_sales_product ON fact_sales(product_key);
CREATE INDEX idx_fact_sales_seller ON fact_sales(seller_key);
CREATE INDEX idx_fact_sales_payment_type ON fact_sales(payment_type_key);
CREATE INDEX idx_fact_sales_order_id ON fact_sales(order_id);

-- Fact Delivery Performance Indexes
CREATE INDEX idx_fact_delivery_performance_date_status ON fact_delivery_performance(order_date_key, order_status_key);
CREATE INDEX idx_fact_delivery_customer ON fact_delivery_performance(customer_key);
CREATE INDEX idx_fact_delivery_seller ON fact_delivery_performance(seller_key);
CREATE INDEX idx_fact_delivery_delivered_date ON fact_delivery_performance(delivered_date_key);
CREATE INDEX idx_fact_delivery_on_time ON fact_delivery_performance(is_on_time);

-- Fact Reviews Indexes
CREATE INDEX idx_fact_reviews_customer ON fact_customer_reviews(customer_key);
CREATE INDEX idx_fact_reviews_product ON fact_customer_reviews(product_key);
CREATE INDEX idx_fact_reviews_seller ON fact_customer_reviews(seller_key);
CREATE INDEX idx_fact_reviews_date ON fact_customer_reviews(review_date_key);
CREATE INDEX idx_fact_reviews_score ON fact_customer_reviews(review_score);
CREATE INDEX idx_fact_reviews_order_id ON fact_customer_reviews(order_id);

-- =====================================================
-- DATA QUALITY CONSTRAINTS
-- =====================================================

-- Add check constraints for business rules
ALTER TABLE fact_sales ADD CONSTRAINT chk_sales_total_calc 
    CHECK (total_item_value = item_price + freight_value);

ALTER TABLE fact_delivery_performance ADD CONSTRAINT chk_delivery_dates
    CHECK (
        (delivered_date_key IS NULL OR delivered_date_key >= order_date_key) AND
        (est_delivery_date_key IS NULL OR est_delivery_date_key >= order_date_key)
    );
-- =====================================================
-- END OF SCHEMA
-- =====================================================