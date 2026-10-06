# Amir Touraji — Portfolio

Data analyst working with financial data: SQL, Python, Power BI and bookkeeping.

**Live site:** https://amirtou.github.io/Portfolio/ (served from `index.html` via GitHub Pages)

```python
info = {
    "pronouns": ["he", "him"],
    "programming_languages": ["Python", "SQL", "Java", "C", "C++", "HTML", "CSS"],
    "tools": ["Power BI", "Excel", "QuickBooks", "Git", "Databricks", "Azure Data Lake"],
    "fields": ["Financial Data Analysis", "Business Intelligence", "Data Engineering", "Machine Learning"],
}
```

---

## Projects

| Project | What it shows | Stack | Folder |
|---|---|---|---|
| **Credit Risk Model** | Predicts loan default on 4,455 bank applications (LightGBM Gini 0.71), picks the approval cut-off by expected profit, explains decisions with SHAP and builds an A–E credit scorecard | Python, scikit-learn, LightGBM, SHAP | [`projects/credit-risk-model`](projects/credit-risk-model) |
| **Unified Customer Transactions** | Merges 1,000 checking and 1,000 credit-card records with customer profiles into 2,000 clean rows, models them as a star schema and analyses revenue, segments and churn | Python, SQL, Power BI | [`projects/unified-transactions`](projects/unified-transactions) |
| **California House Price Model** | Linear regression baseline (R² 0.56) improved to R² 0.81 with a random forest | Python, scikit-learn | [`projects/house-price-predictor`](projects/house-price-predictor) |
| **Vaccination Pattern Clustering** | K-means and PCA to group countries by vaccination, GDP and healthcare metrics (simulated data) | Python, scikit-learn | [`projects/covid-vaccination-analysis`](projects/covid-vaccination-analysis) |
| **RANSAC Image Stitching** | FLANN feature matching and RANSAC homography estimation to align overlapping images | Python, OpenCV, Kornia | [`projects/ransac-image-stitching`](projects/ransac-image-stitching) |

## Repository layout

```
index.html              the portfolio website
projects/<name>/        one folder per project: code, data, and its own README where needed
Images/                 image assets
```

To add a project: create `projects/<project-name>/`, put the code and a short README in it, then add a card to the Projects section of `index.html`.

## Skills

- **Analysis & BI:** Power BI (DAX), Excel (Power Query, pivot tables), Tableau, regression and forecasting
- **Data engineering:** SQL (PostgreSQL, MySQL), ETL pipelines, star-schema modelling, Azure Data Lake, Databricks
- **Programming:** Python (pandas, NumPy, scikit-learn, LightGBM, SHAP, Matplotlib, Seaborn), Java, C, C++
- **Finance tools:** QuickBooks, ledger reconciliation, expense reporting, Salesforce CRM
- **Languages:** English (fluent), Farsi (native), Spanish (intermediate)

## Education

- Honours BSc in Computer Science (Data Science focus), York University, 2020–2025
- In progress: AWS Data Engineering, Azure Data Scientist certifications

## Contact

Amirreza.tou2025@gmail.com · [github.com/amirtou](https://github.com/amirtou)
