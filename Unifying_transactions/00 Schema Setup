-- ============================================================
-- 00_schema_setup.sql
-- Author: AmirReza Touraji
-- Description: Star schema for customer transaction analysis
--              Mirrors the Power BI dashboard project dataset
-- ============================================================

-- Dimension: Customers
CREATE TABLE dim_customers (
    customer_id     INT PRIMARY KEY,
    full_name       VARCHAR(100),
    email           VARCHAR(150),
    region          VARCHAR(50),       -- e.g. 'West', 'East', 'Central'
    segment         VARCHAR(50),       -- e.g. 'Premium', 'Standard', 'Basic'
    join_date       DATE,
    is_active       BOOLEAN DEFAULT TRUE
);

-- Dimension: Products
CREATE TABLE dim_products (
    product_id      INT PRIMARY KEY,
    product_name    VARCHAR(100),
    category        VARCHAR(50),       -- e.g. 'Electronics', 'Apparel', 'Home'
    unit_price      DECIMAL(10, 2),
    cost_price      DECIMAL(10, 2)
);

-- Dimension: Date (calendar table)
CREATE TABLE dim_date (
    date_id         INT PRIMARY KEY,   -- e.g. 20240115
    full_date       DATE,
    year            INT,
    quarter         INT,
    month           INT,
    month_name      VARCHAR(20),
    week            INT,
    day_of_week     VARCHAR(10),
    is_weekend      BOOLEAN
);

-- Fact: Transactions
CREATE TABLE fact_transactions (
    transaction_id  BIGINT PRIMARY KEY,
    customer_id     INT REFERENCES dim_customers(customer_id),
    product_id      INT REFERENCES dim_products(product_id),
    date_id         INT REFERENCES dim_date(date_id),
    quantity        INT,
    unit_price      DECIMAL(10, 2),
    discount_pct    DECIMAL(5, 2) DEFAULT 0,
    total_amount    DECIMAL(12, 2),    -- quantity * unit_price * (1 - discount_pct/100)
    payment_method  VARCHAR(30),       -- 'Credit Card', 'Debit', 'PayPal', etc.
    status          VARCHAR(20)        -- 'Completed', 'Refunded', 'Pending'
);
