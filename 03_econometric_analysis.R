# ============================================================
# PROJECT: Has the Okun Coefficient Remained Stable after the
#          COVID-19 Shock? Evidence from the French Economy
# ============================================================

# Prepare the data and samples
source("01_data_preparation.R")

# Load packages used in the econometric analysis
library(stargazer)
library(tseries)
library(lmtest)
library(tidyverse)

# 10. DESCRIPTIVE STATISTICS FUNCTION
# ============================================================

# Descriptive statistics (2010–2019 and 2021–2025)
#=================================================

descriptive_stats <- function(data, period, output_file) {
  
  # Calculate descriptive statistics
  stats_table <- data %>%
    summarise(
      Min_gdp       = round(min(gdp_rate, na.rm = TRUE), 3),
      Q1_gdp        = round(quantile(gdp_rate, 0.25, na.rm = TRUE), 3),
      Median_gdp    = round(median(gdp_rate, na.rm = TRUE), 3),
      Mean_gdp      = round(mean(gdp_rate, na.rm = TRUE), 3),
      Q3_gdp        = round(quantile(gdp_rate, 0.75, na.rm = TRUE), 3),
      Max_gdp       = round(max(gdp_rate, na.rm = TRUE), 3),
      SD_gdp        = round(sd(gdp_rate, na.rm = TRUE), 3),
      
      Min_unemployment     = round(min(delta_unemp, na.rm = TRUE), 3),
      Q1_unemployment      = round(quantile(delta_unemp, 0.25, na.rm = TRUE), 3),
      Median_unemployment  = round(median(delta_unemp, na.rm = TRUE), 3),
      Mean_unemployment    = round(mean(delta_unemp, na.rm = TRUE), 3),
      Q3_unemployment      = round(quantile(delta_unemp, 0.75, na.rm = TRUE), 3),
      Max_unemployment     = round(max(delta_unemp, na.rm = TRUE), 3),
      SD_unemployment      = round(sd(delta_unemp, na.rm = TRUE), 3)
    )
  
  # Reshape the table
  stats_table_long <- stats_table %>%
    pivot_longer(
      cols = everything(),
      names_to = c("Stat", "Variable"),
      names_pattern = "^(.*?)_(.*)$",
      values_to = "Value"
    ) %>%
    pivot_wider(
      names_from = Stat,
      values_from = Value
    )
  
  # Add the period
  stats_table_long <- stats_table_long %>%
    mutate(Period = period) %>%
    select(Period, Variable, Min, Q1, Median, Mean, Q3, Max, SD)
  
  # Export results as CSV
  write.csv(
    stats_table_long,
    file = output_file,
    row.names = FALSE
  )
  
  # Display results in the console
  print(stats_table_long)
  
  return(stats_table_long)
}


# Descriptive statistics (2010–2019)
#===================================

# Pre-2020 period (2010–2019)
data_2010_2019 <- data_all %>%
  filter(time >= "10-T1", time <= "19-T4")

stats_table_before2020 <- descriptive_stats(
  data = data_2010_2019,
  period = "2010–2019",
  output_file = "stats_table_before2020.csv"
)


# Descriptive statistics (2021–2025)
#===================================

stats_table_after2020 <- descriptive_stats(
  data = data_2021_2025,
  period = "2021–2025",
  output_file = "stats_table_after2020.csv"
)





# =====================================================
# 11. ORDINARY LEAST SQUARES ESTIMATION (OLS)
# =====================================================

# ------------------------------------
# MODEL 1: 2010-2025 (including 2020)
# ------------------------------------

# Simple OLS: delta_unemp ~ gdp_rate

model1 <- lm(data = na.omit(data_2010_2019), formula = delta_unemp ~ gdp_rate)
summary(model1)


# Sub-period 2020-2025

model2 <- lm(data = data_2020_2025, formula = delta_unemp ~ gdp_rate)
summary(model2)


# ------------------------------------
# MODEL 2: 2020 only
# ------------------------------------

# Dummy variable + interaction

model2020 <- lm(data = data_2020, formula = delta_unemp ~ gdp_rate)
summary(model2020)


# =====================================================
# PERIOD STUDY: 2010-2025 (with and without 2020)
# Stationarity + OLS Estimation + Validation
# =====================================================


# ------------------------------------
# 2010-2025 including 2020
# ------------------------------------


# 1. STATIONARITY TESTS
# ------------------------------------

library(tseries)

# GDP rate
data_all <- na.omit(data_all)

serie <- data_all$gdp_rate

adf.test(serie, alternative = "stationary")  # ADF test
pp.test(serie)                               # PP test
kpss.test(serie)                             # KPSS test


# Delta unemployment
serie <- data_all$delta_unemp

adf.test(serie, alternative = "stationary")  # ADF test
pp.test(serie)                               # PP test
kpss.test(serie)                             # KPSS test


# 2. OLS ESTIMATION
# ------------------------------------

model_all <- lm(
  data = data_all,
  formula = delta_unemp ~ gdp_rate * covid
)

summary(model_all)


# 3. MODEL VALIDATION
# ------------------------------------

# Normality of residuals: Jarque-Bera test
jarque.bera.test(residuals(model_all))


# Autocorrelation: Breusch-Godfrey (BG) test
library(lmtest)

bgtest(model_all, order = 5)


# Heteroscedasticity: Breusch-Pagan test
bptest(model_all)


# ----------------------------------------------------------------
# 2010-2025 excluding 2020
# ----------------------------------------------------------------


# 1. STATIONARITY TESTS
# ------------------------------------

# GDP rate
data_no_2020 <- na.omit(data_no_2020)

serie <- data_no_2020$gdp_rate

adf.test(serie, alternative = "stationary")
pp.test(serie)
kpss.test(serie)


# Delta unemployment
serie <- data_no_2020$delta_unemp

adf.test(serie, alternative = "stationary")
pp.test(serie)
kpss.test(serie)


# 2. OLS ESTIMATION
# ------------------------------------

model_no_2020 <- lm(
  data = data_no_2020,
  formula = delta_unemp ~ gdp_rate * covid
)

summary(model_no_2020)


# 3. MODEL VALIDATION
# ------------------------------------

# Normality of residuals
jarque.bera.test(residuals(model_no_2020))


# Autocorrelation: BG test
bgtest(model_no_2020, order = 5)


# Heteroscedasticity: BP test
bptest(model_no_2020)




# =====================================================
# COMBINE OLS RESULTS WITH STARGAZER
# =====================================================

# Rename variables for display in the table

var_labels <- c(
  "gdp_rate"       = "GDP growth rate",
  "delta_unemp"    = "Change in unemployment rate",
  "covid"          = "COVID",
  "gdp_rate:covid" = "GDP growth rate * COVID"
)


# Stargazer: two models 2010-2025 with 2020 (1) and without 2020 (2)

stargazer(
  model_all,          # Model 2010-2025 including 2020
  model_no_2020,      # Model 2010-2025 excluding 2020
  type = "text",
  title = "OLS Estimation: 2010-2025 with 2020 (1) and without 2020 (2)",
  dep.var.labels = "Change in unemployment rate",
  covariate.labels = c(
    "GDP growth rate",
    "COVID",
    "GDP growth rate * COVID"
  ),
  star.char = "*",
  star.cutoffs = c(0.05, 0.01, 0.001),
  digits = 3,
  single.row = TRUE
)

