# Unified Customer Transactions

Combines a bank's checking-account and credit-card transactions with customer profiles into one clean dataset, then analyses it in Power BI and SQL.

## Highlights

- **2,000 transactions** from two sources (1,000 checking, 1,000 credit card) joined to **1,000 customer profiles**
- A Python cleaning step with validation checks: unique IDs, no lost rows
- A **Power BI dashboard** with DAX measures: total spend, customer count, average income, credit utilization, month-over-month change
- A **SQL analysis layer** on a star schema covering revenue, RFM segmentation, churn, data-quality auditing and window functions

## Files

| File | Purpose |
|---|---|
| `Customer_Info.csv` | Customer profiles: demographics, income, account type, join date |
| `Checking_Account.csv` | Checking transactions: type, amount, balance, branch city, channel |
| `Credit_Card.csv` | Credit-card purchases: merchant, category, amount, city |
| `Unifying_Transactions.ipynb` | Cleans, aligns and merges the three files |
| `Unified_Transactions.csv` | **Output:** the merged dataset used by the dashboard |
| `Unified_Transactions.pbit` | Power BI template for the dashboard |
| `00_schema_setup.sql` | Star schema: `fact_transactions`, `dim_customers`, `dim_products`, `dim_date` |
| `01_revenue_analysis.sql` | Monthly revenue and AOV, category margins, top products, QoQ growth, weekday vs weekend |
| `02_customer_segmentation.sql` | RFM scoring, 80/20 revenue concentration, new vs returning customers |
| `03_churn_analysis.sql` | Days since last purchase, churn rate by segment, at-risk high-value customers, retention trend |
| `04_data_audit_and_quality.sql` | Null audit, amount mismatches, orphaned and duplicate records, month-end reconciliation |
| `05_advanced_window_functions.sql` | Running totals, rolling averages, rankings, lead/lag, percentile benchmarks |

## How the data is unified

1. Parse dates and drop duplicate customers and transactions.
2. Rename columns so both transaction sources share `Date`, `Category`, `Amount` and `City`.
3. Give every row a unique `Transaction_ID`: checking keeps 1–1,000 and credit card is offset to 1,001–2,000. The `Source` column records where each row came from.
4. Left-join each transaction to its customer's profile.
5. Check that IDs are unique and no rows were lost, then export `Unified_Transactions.csv`.

In the output, `City_x` is where the transaction happened and `City_y` is the customer's home city. These names are kept because the Power BI template refers to them.

## SQL layer

The SQL scripts are written for a star-schema data warehouse that extends this dataset with product, order-status and discount fields. Run `00_schema_setup.sql` first to create the tables, then load your data and run any analysis script. They use standard SQL with window functions and CTEs (PostgreSQL syntax).

## Run it

```bash
pip install pandas jupyter
jupyter notebook Unifying_Transactions.ipynb
```

To open the dashboard, open `Unified_Transactions.pbit` in Power BI Desktop. The template still points to the CSV's original location on the author's computer, so on first load go to **Transform data → Data source settings → Change Source** and select `Unified_Transactions.csv` from this folder.
