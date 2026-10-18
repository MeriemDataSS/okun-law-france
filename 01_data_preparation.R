# ============================================================
# PROJECT: Has the Okun Coefficient Remained Stable after the
#          COVID-19 Shock? Evidence from the French Economy
# ============================================================

# Load required packages
library(tidyverse)
library(readxl)
library(ggplot2)
library(stargazer)
library(tseries)
library(lmtest)

# ============================================================
# 1. DATA IMPORT
# ============================================================


# Import quarterly unemployment data from INSEE
data_unemp <- read_excel(
  path = "unemployment_data.xlsx",
  sheet = "valeurs_trimestrielles",
  range = "A1:B66"
)

# Import GDP data from INSEE
data_gdp <- read_excel(
  path = "gdp_data.xlsx",
  sheet = "Données",
  range = "A1:B66"
)



# ============================================================
# 2. DATA CLEANING
# ============================================================

# Select and rename unemployment variables
data_unemp <- data_unemp %>%
  mutate(
    time = trimestre,
    unemp_rate = txch,
    .keep = "none"
  ) %>%
  arrange(time)


# Select and rename GDP variables
data_gdp <- data_gdp %>%
  mutate(
    time = trimestre,
    gdp_rate = tcpib,
    .keep = "none"
  ) %>%
  arrange(time)


# Format quarterly time variable
format_time <- function(x) {
  paste0(substr(x, 3, 4), "-", substr(x, 6, 7))
}

data_unemp <- data_unemp %>%
  mutate(time = format_time(time))

data_gdp <- data_gdp %>%
  mutate(time = format_time(time))




# ============================================================
# 3. MERGE DATA
# ============================================================

# Merge unemployment and GDP data by quarter
data <- data_unemp %>%
  inner_join(data_gdp, by = "time") %>%
  arrange(time)



# ============================================================


# 6. VARIABLE CONSTRUCTION
# ============================================================

# Sort observations chronologically
data <- data %>%
  arrange(time)

# Compute quarterly change in the unemployment rate
data <- data %>%
  mutate(
    delta_unemp = unemp_rate - lag(unemp_rate)
  )

# Create COVID-19 dummy variable
data <- data %>%
  mutate(
    time = as.character(time),
    covid = as.integer(time >= "20-T1")
  )

# Select variables for econometric analysis
data_all <- data %>%
  select(time, gdp_rate, delta_unemp, covid)



# ============================================================
# 7. SAMPLE SPLITTING: COVID-19 ANALYSIS
# ============================================================

# Observations during 2020
data_2020 <- data_all %>%
  filter(time >= "20-T1", time <= "20-T4")

# Exclude observations from 2020
data_no_2020 <- data_all %>%
  filter(time < "20-T1" | time > "20-T4")

# Pre-COVID period (before 2020)
data_pre_covid <- data_all %>%
  filter(time < "20-T1")

# COVID and post-COVID period (2020 onwards)
data_2020_2025 <- data_all %>%
  filter(time >= "20-T1")

# Post-2020 period (2021 onwards)
data_2021_2025 <- data_all %>%
  filter(time > "20-T4")



# ============================================================

# Pre-2020 period (2010–2019)
data_2010_2019 <- data_all %>%
  filter(time >= "10-T1", time <= "19-T4")

