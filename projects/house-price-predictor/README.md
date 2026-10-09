# California House Price Model

Predicts median house values across California census districts. A linear regression baseline is compared with a random forest.

## Results

| Model | Test R² | Test MSE |
|---|---|---|
| Linear regression | 0.58 | 0.56 |
| **Random forest** (100 trees) | **0.81** | — |

The random forest explains about 23 percentage points more of the variance than the linear baseline. That gap shows the relationship between income, location and price is strongly non-linear.

## Data

The [California Housing dataset](https://scikit-learn.org/stable/datasets/real_world.html#california-housing-dataset) from the 1990 U.S. Census, loaded with `sklearn.datasets.fetch_california_housing`. It has 20,640 districts and 8 features. The target is median house value in hundreds of thousands of dollars, capped at $500k.

## Method

1. **Explore:** correlation heatmap and feature distributions
2. **Split:** 80% train / 20% test (`random_state=42`)
3. **Baseline:** ordinary least-squares linear regression, checked with actual-vs-predicted and residual plots
4. **Improve:** random forest regressor on the same split

## Run it

```bash
pip install -r requirements.txt
jupyter notebook HousePrice_Predictor.ipynb
```

Or open it in Google Colab with the badge at the top of the notebook. The dataset downloads automatically on first run.

## Next steps

- Tune tree depth and leaf size with cross-validation
- Try gradient boosting (LightGBM or XGBoost)
- Report RMSE in dollars alongside R²
