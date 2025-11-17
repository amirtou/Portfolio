
# Transaction Data Unification

A data analysis pipeline that cleans, matches, and consolidates transaction data from multiple banking sources into a unified dataset.

## 📁 Files

- `Checking_Account.csv` - Checking account transaction records
- `Credit_Card.csv` - Credit card transaction records
- `Customer_Info.csv` - Customer demographic and account information
- `Unifying_Transactions.ipynb` - Main analysis notebook
- `Unified_Transactions.csv` - Output: cleaned and consolidated transaction data

## 🎯 Purpose

This project unifies transaction data from checking accounts and credit cards, enriching it with customer information to enable comprehensive financial analysis.

## 🔧 What It Does

- Cleans and standardizes transaction data from multiple sources
- Matches transactions with customer information
- Consolidates checking and credit card records into a single dataset
- Handles missing values and data inconsistencies
- Standardizes date formats and transaction categories

## 📊 Output

The `Unified_Transactions.csv` contains a consolidated view of all transactions with associated customer information, ready for further analysis and reporting.

## 🚀 Usage

1. Ensure all CSV files are in the same directory as the notebook
2. Open `Unifying_Transactions.ipynb` in Jupyter Notebook
3. Run all cells to generate the unified dataset

## 📦 Dependencies
```
pandas
numpy
```

## 📝 Notes

- All source data files must be present before running the notebook
- The output file will be overwritten if it already exists
