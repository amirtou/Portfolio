# Vaccination Pattern Clustering

An end-to-end analysis pipeline that groups countries by vaccination, economic and healthcare indicators. It uses K-means clustering, PCA and regression.

> **Note:** the script runs on a **simulated** 20-country dataset generated with a fixed random seed. The data was built so that higher vaccination lowers mortality, so the numbers below show that the pipeline works. They are not real-world findings. To analyse real data, swap the data-loading step for a source such as [Our World in Data](https://github.com/owid/covid-19-data).

## What it does

| Step | Technique | Output |
|---|---|---|
| Explore | Correlation matrix, scatter plots | `correlation_matrix.png`, `vaccination_vs_gdp.png`, `deaths_vs_vaccination.png` |
| Choose cluster count | Elbow method on K-means inertia | `elbow_curve.png` |
| Cluster countries | K-means (k = 3) on standardised features, PCA for 2-D plotting | `vaccination_clusters.png` |
| Measure the vaccination–mortality link | Linear regression with p-value and R² | `vaccination_effectiveness.png` |
| Report | Printed summary of findings and recommendations | console + `processed_covid_vaccination_data.csv` |

## Sample output (simulated data)

- Correlation between vaccination rate and deaths per million: **−0.96** (R² 0.93)
- K-means separates a high-vaccination cluster (8 countries, about 76% vaccinated) from two lower-vaccination clusters (about 33–36% vaccinated).

## Run it

```bash
pip install -r requirements.txt
python covid_vaccination_analysis.py
```

Charts and the processed CSV are written to the current folder.
