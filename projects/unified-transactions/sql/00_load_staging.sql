-- ============================================================
-- 00_load_staging.sql
-- Load the three raw source files into typed staging tables.
-- Nothing is changed here; the raw data is preserved as-is.
-- ============================================================

CREATE OR REPLACE TABLE stg_customers AS
SELECT
    Customer_ID::INTEGER                       AS customer_id,
    First_Name || ' ' || Last_Name             AS full_name,
    Email                                      AS email,
    Gender                                     AS gender,
    City                                       AS home_city,
    strptime(Join_Date, '%m/%d/%Y')::DATE      AS join_date,
    Age::INTEGER                               AS age,
    Income::DOUBLE                             AS annual_income,
    Account_Type                               AS account_type
FROM read_csv('Customer_Info.csv', header = true, all_varchar = true);

CREATE OR REPLACE TABLE stg_checking AS
SELECT
    Transaction_ID::INTEGER                    AS source_record_id,
    Customer_ID::INTEGER                       AS customer_id,
    strptime(Transaction_Date, '%m/%d/%Y')::DATE AS txn_date,
    Transaction_Type                           AS txn_type,
    Amount::DOUBLE                             AS amount,
    TRY_CAST(Account_Balance AS DOUBLE)        AS account_balance,
    Branch_City                                AS txn_city,
    Channel                                    AS channel
FROM read_csv('Checking_Account.csv', header = true, all_varchar = true);

CREATE OR REPLACE TABLE stg_credit_card AS
SELECT
    Card_Id::INTEGER                           AS source_record_id,
    Customer_ID::INTEGER                       AS customer_id,
    strptime(Transaction_Date, '%m/%d/%Y')::DATE AS txn_date,
    Merchant                                   AS merchant,
    Amount::DOUBLE                             AS amount,
    Category                                   AS category,
    City                                       AS txn_city
FROM read_csv('Credit_Card.csv', header = true, all_varchar = true);
