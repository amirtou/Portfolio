# AmirReza Touraji | Data & Financial Analytics Portfolio

Operations and data analyst in Toronto focused on **financial data, machine learning and business intelligence**. I work in finance operations, reconciling large financial datasets with SQL and reviewing KYB/KYC documents for corporate onboarding. Outside work I build ML models and BI dashboards. Computer Science graduate from York University.

**Website:** [amirtou.github.io/Portfolio](https://amirtou.github.io/Portfolio/) · **Email:** amirreza.tou2025@gmail.com · **LinkedIn:** [linkedin.com/in/amirtou](https://www.linkedin.com/in/amirtou) · **GitHub:** [@amirtou](https://github.com/amirtou)

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
| Data & analytics | SQL (PostgreSQL, MySQL), Python (pandas, NumPy), Excel (pivot tables, VLOOKUP, SUMIF, macros), data validation & QA |
| Business intelligence | Power BI (DAX), Tableau, Metabase |
| Machine learning | scikit-learn, LightGBM, SHAP, classification, regression, clustering, credit-risk metrics (PD, Gini, KS) |
| Automation & AI | Claude (AI workflow automation), Apache Airflow, Docker, Git/GitHub |
| Operations & compliance | KYB/KYC review, corporate account onboarding, FINTRAC recordkeeping, process documentation |
| Finance | Financial reconciliation, sales and cash-flow reporting |

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

## Experience

- **Operations & Account Support**, Levelwear, Richmond Hill, ON (Feb 2026 – present): SQL reconciliation of financial datasets, KYB/KYC review and corporate account onboarding, Excel dashboards tracking orders against targets
- **Financial Data & Reporting Analyst**, Patinouva Texture Inc., Toronto, ON (Feb 2025 – Feb 2026): BI dashboards for sales, transactions and cash flow; root-cause analysis of statement discrepancies; automated reconciliation steps

## Education and certifications

- **Honours BSc, Computer Science**, York University, 2025
- **Investment Funds in Canada (IFIC)**, in progress
- **Google:** Data Models and Pipelines; Foundations of Business Intelligence
