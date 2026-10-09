# Amir Touraji | Data & Financial Analytics Portfolio

Data analyst focused on **machine learning, financial data and business intelligence**. I build models and pipelines in Python and SQL and present results in Power BI. Computer Science graduate from York University, currently working as a bookkeeper.

**Website:** [amirtou.github.io/Portfolio](https://amirtou.github.io/Portfolio/) · **Email:** Amirreza.tou2025@gmail.com · **GitHub:** [@amirtou](https://github.com/amirtou)

---

## Featured project: Credit Risk Model

Predicts the probability that a loan applicant will default and turns it into a lending decision and a credit score.

- Logistic regression, random forest and LightGBM compared on 4,455 real bank loan applications. Best test **Gini 0.71** (ROC-AUC 0.855).
- The approval cut-off is chosen by **expected profit**. Approving everyone loses money; approving applicants with PD under 18% cuts the default rate of approved loans to **5.9%** and makes the portfolio profitable.
- SHAP explanations, plus a points-based **scorecard** with A–E grades whose default rates fall from 72% (E) to 2% (A).

→ [`projects/credit-risk-model`](projects/credit-risk-model)

## All projects

| Project | Summary | Key result | Stack |
|---|---|---|---|
| [Credit Risk Model](projects/credit-risk-model) | Loan default prediction, profit-based approval policy and credit scorecard | Gini 0.71 | Python, scikit-learn, LightGBM, SHAP |
| [Unified Customer Transactions](projects/unified-transactions) | Merges checking and credit-card data with customer profiles, then analyses it in Power BI and SQL | 2,000 transactions unified | Python, SQL, Power BI |
| [California House Price Model](projects/house-price-predictor) | Regression on census housing data | R² 0.58 → 0.81 | Python, scikit-learn |
| [Vaccination Pattern Clustering](projects/covid-vaccination-analysis) | K-means, PCA and regression pipeline (simulated data) | 3 country clusters | Python, scikit-learn, SciPy |
| [RANSAC Image Stitching](projects/ransac-image-stitching) | Feature matching and robust transform estimation for panoramas | Affine and homography stitching | Python, OpenCV |

Each project folder has its own README with results, method and run instructions.

## Skills

| Area | Tools |
|---|---|
| Machine learning | scikit-learn, LightGBM, SHAP, regression, classification, clustering, model evaluation |
| Data analysis | Python (pandas, NumPy), Matplotlib, Seaborn, Jupyter |
| Data engineering | SQL (PostgreSQL, MySQL), ETL, star-schema modelling, Azure Data Lake, Databricks |
| Business intelligence | Power BI (DAX), Excel (Power Query, pivot tables), Tableau |
| Finance | QuickBooks, ledger reconciliation, expense reporting, credit-risk metrics (PD, Gini, KS) |
| Programming | Python, SQL, Java, C, C++, Git |

## Repository structure

```
.
├── index.html                     # Portfolio website (served by GitHub Pages)
└── projects/
    ├── credit-risk-model/         # Notebook, data, figures, requirements
    ├── unified-transactions/      # Notebook, CSVs, SQL scripts, Power BI template
    ├── house-price-predictor/     # Notebook, requirements
    ├── covid-vaccination-analysis/# Python script, requirements
    └── ransac-image-stitching/    # Notebook, requirements
```

## Running a project

```bash
git clone https://github.com/amirtou/Portfolio.git
cd Portfolio/projects/<project-name>
pip install -r requirements.txt
jupyter notebook
```

## Education and certifications

- **Honours BSc, Computer Science** (Data Science focus), York University, 2020–2025
- **In progress:** AWS Data Engineering, Microsoft Azure Data Scientist
