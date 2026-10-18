from pathlib import Path
import pypandoc

readme = r"""# Has the Okun Coefficient Remained Stable after the COVID-19 Shock? Evidence from France

## Project Overview

This project investigates whether the relationship between economic growth and changes in unemployment in France remained stable after the COVID-19 shock.

The analysis uses quarterly French macroeconomic data from **Q1 2010 to Q4 2025**. It examines the relationship described by Okun's law and tests whether the post-COVID period is associated with a change in this relationship.

Two specifications are compared:
- **Including 2020**, to capture the exceptional disruption during the pandemic year.
- **Excluding 2020**, to assess whether the relationship changed beyond the initial shock.

## Research Question

**Did the COVID-19 shock lead to a lasting change in the relationship between GDP growth and unemployment in France?**

## Data

The study uses quarterly macroeconomic data for France collected from **INSEE**.

The main variables are:
- **Real GDP growth rate:** quarterly percentage change in real GDP.
- **Change in the unemployment rate:** difference in the unemployment rate between consecutive quarters.
- **Post-COVID dummy:** indicator for the post-COVID period, defined according to the specification being estimated.
- **Interaction term:** GDP growth multiplied by the post-COVID dummy, used to test whether the relationship between growth and unemployment changed after the COVID-19 shock.

The data series were collected separately, cleaned, and merged into a single dataset before the analysis.

## Methodology

The empirical analysis uses an augmented Okun model:

\[
\Delta u_t = \alpha + \beta g_t + \gamma D_t + \delta(D_t \times g_t) + \varepsilon_t
\]

where:
- \(\Delta u_t\) is the change in the unemployment rate;
- \(g_t\) is the real GDP growth rate;
- \(D_t\) is the post-COVID dummy;
- \(D_t \times g_t\) is the interaction between the dummy and GDP growth;
- \(\delta\) captures the change in the relationship between GDP growth and unemployment in the post-COVID period.

The interaction coefficient is examined in two samples: one including 2020 and another excluding it.

## Analysis Workflow

The project is organized into three R scripts.

### 1. `01_data_preparation.R`

This script is intended for preparing the data used in the analysis:
- importing the source datasets;
- cleaning and organizing the data;
- merging the datasets;
- constructing the variables required for the empirical model;
- preparing the samples used for the comparison.

### 2. `02_exploratory_analysis.R`

This script presents the exploratory analysis, including:
- time-series plots of the main macroeconomic variables;
- scatter plots examining the relationship between GDP growth and unemployment;
- comparisons of the full sample and the sample excluding 2020;
- visual examination of the pre-COVID and post-COVID periods.

### 3. `03_econometric_analysis.R`

This script covers the econometric analysis, including:
- descriptive statistics;
- stationarity tests (ADF, Phillips–Perron and KPSS);
- estimation of the augmented Okun model;
- comparison of results with and without 2020;
- residual and model validation tests, including Jarque–Bera, Breusch–Godfrey and Breusch–Pagan tests;
- presentation of estimation results.

*The descriptions above should match the final contents of the scripts. Adjust any item that is not implemented in the corresponding file.*

## Main Findings

The report presents the following results:

- **When 2020 is included:** the estimated interaction coefficient is positive (\(0.1802\)) and weakly significant at the 10% level. This suggests a temporary change in the relationship during the period that includes the exceptional pandemic shock.
- **When 2020 is excluded:** the interaction coefficient is positive (\(0.0481\)) but not statistically significant. The analysis therefore does not find evidence of a significant lasting change between the pre-COVID and post-COVID periods once 2020 is excluded.
- **Model checks:** the report evaluates residual normality, autocorrelation and homoscedasticity. The model including 2020 has non-normal residuals, while the reported tests for autocorrelation and heteroscedasticity do not indicate problems. The model excluding 2020 passes the three reported residual checks.

Overall, the results are consistent with the interpretation that 2020 was an exceptional disruption, rather than evidence of a statistically significant lasting change in the estimated relationship.

## Repository Structure

```text
okun-law-france/
├── README.md
├── 01_data_preparation.R
├── 02_exploratory_analysis.R
├── 03_econometric_analysis.R
├── data/
└── graphs/
```

This is a suggested structure. Keep only the folders and files that actually exist in the repository. Do not upload datasets if their terms of use or source restrictions do not permit redistribution.

## How to Run

1. Install R and, if needed, RStudio.
2. Download or clone this repository.
3. Install the R packages required by the scripts.
4. Make sure the input data are available at the file paths expected by the scripts.
5. Run the scripts in order:
   1. `01_data_preparation.R`
   2. `02_exploratory_analysis.R`
   3. `03_econometric_analysis.R`

The required packages, data paths and execution details should be confirmed against the final R scripts before publishing the repository.

## Limitations

The post-COVID period contains a limited number of quarterly observations. The findings should therefore be interpreted in light of the sample size and the period covered by the data.
"""

output_path = Path("/mnt/data/README.md")
pypandoc.convert_text(
    readme,
    "md",
    format="md",
    outputfile=str(output_path),
    extra_args=["--standalone"]
)
print(f"README created: {output_path}")
