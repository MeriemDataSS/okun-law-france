# ============================================================
# PROJECT: Has the Okun Coefficient Remained Stable after the
#          COVID-19 Shock? Evidence from the French Economy
# ============================================================

# Prepare the data and samples
source("01_data_preparation.R")

# ============================================================
# 4. TIME VARIABLE FORMATTING FOR PLOTS
# ============================================================

# Convert time to an ordered factor
data$time <- factor(data$time, levels = unique(data$time))

# Define x-axis breaks and labels
x_breaks <- paste0(
  sprintf("%02d", 5:25), "-T1"
)

x_labels <- as.character(2005:2025)

# Position of the COVID-19 reference quarter
covid_quarter <- "20-T1"
covid_position <- match(covid_quarter, levels(data$time))

# Generic time series plotting function
plot_time_series <- function(df, y_var, color_line = "red",
                             title, subtitle) {
  
  ggplot(df, aes(x = time, y = {{ y_var }}, group = 1)) +
    
    geom_area(
      fill = color_line,
      alpha = 0.1
    ) +
    
    geom_line(
      color = color_line,
      linewidth = 0.8
    ) +
    
    geom_point(
      color = color_line,
      size = 1.5,
      fill = "white",
      stroke = 1
    ) +
    
    {
      if (!is.na(covid_position)) {
        geom_vline(
          xintercept = covid_position,
          color = "black",
          linetype = "dashed",
          linewidth = 0.8
        )
      }
    } +
    
    annotate(
      "text",
      x = covid_quarter,
      y = Inf,
      label = "COVID-19 Shock",
      vjust = 1.5,
      hjust = -0.1,
      color = "black",
      fontface = "italic",
      size = 3
    ) +
    
    scale_y_continuous(
      breaks = scales::pretty_breaks(n = 10)
    ) +
    
    scale_x_discrete(
      breaks = x_breaks,
      labels = x_labels,
      drop = FALSE
    ) +
    
    labs(
      title = title,
      subtitle = subtitle,
      x = "Year",
      y = NULL
    ) +
    
    theme_bw(base_family = "sans") +
    
    theme(
      plot.title = element_text(
        face = "bold",
        size = 16,
        color = "#2d3436"
      ),
      plot.subtitle = element_text(
        size = 10,
        color = "#636e72",
        margin = margin(b = 20)
      ),
      panel.grid.minor = element_blank(),
      panel.grid.major.x = element_blank(),
      axis.line.x = element_line(color = "black"),
      axis.text = element_text(color = "#2d3436"),
      axis.title = element_text(
        face = "bold.italic",
        size = 10
      ),
      plot.margin = margin(20, 20, 20, 20)
    )
}


# ============================================================
# 5. GRAPHICS
# ============================================================

# Graph 1: Quarterly real GDP growth rate
graph1 <- plot_time_series(
  df = data,
  y_var = gdp_rate,
  color_line = "red",
  title = "Quarterly Real GDP Growth Rate in France",
  subtitle = "Quarterly data, 2005–2025"
)

# Display graph
print(graph1)

# Export graph
ggsave(
  filename = "graph1.png",
  plot = graph1,
  width = 12,
  height = 6,
  units = "in",
  dpi = 600
)


# Graph 2: Quarterly unemployment rate

graph2 <- plot_time_series(
  df = data,
  y_var = unemp_rate,
  color_line = "blue",
  title = "Quarterly Unemployment Rate in France",
  subtitle = "Quarterly data, 2005–2025"
)

# Display graph
print(graph2)

# Export graph
ggsave(
  filename = "graph2.png",
  plot = graph2,
  width = 12,
  height = 6,
  units = "in",
  dpi = 600
)



# ============================================================
# Graph 3: GDP Growth vs. Unemployment
# ============================================================

# Reshape data to long format
data_long <- data %>%
  pivot_longer(
    cols = c(gdp_rate, unemp_rate),
    names_to = "series",
    values_to = "value"
  )

# Generic multi-series plotting function
plot_multi_series <- function(df, title, subtitle) {
  
  ggplot(
    df,
    aes(x = time, y = value, color = series, group = series)
  ) +
    
    geom_line(linewidth = 0.8) +
    
    geom_point(size = 1.5) +
    
    # Configure x-axis
    scale_x_discrete(
      breaks = x_breaks,
      labels = x_labels,
      expand = expansion(add = c(0.5, 1))
    ) +
    
    # Define series colors and legend labels
    scale_color_manual(
      values = c(
        "gdp_rate" = "#E74C3C",
        "unemp_rate" = "#2E86C1"
      ),
      breaks = c("gdp_rate", "unemp_rate"),
      labels = c(
        "gdp_rate" = "GDP growth rate",
        "unemp_rate" = "Unemployment rate"
      )
    ) +
    
    scale_y_continuous(
      breaks = scales::pretty_breaks(n = 8)
    ) +
    
    # Mark the COVID-19 reference quarter
    geom_vline(
      xintercept = covid_position,
      linetype = "dashed",
      color = "grey20",
      linewidth = 0.7
    ) +
    
    annotate(
      "text",
      x = covid_position,
      y = Inf,
      label = "COVID-19 Shock",
      vjust = 1.5,
      hjust = -0.1,
      fontface = "italic",
      size = 3
    ) +
    
    labs(
      title = title,
      subtitle = subtitle,
      x = "Year",
      y = NULL,
      color = NULL
    ) +
    
    theme_bw() +
    
    theme(
      legend.position = "bottom",
      legend.justification = "left",
      plot.title = element_text(face = "bold", size = 14),
      plot.subtitle = element_text(size = 10),
      axis.text.x = element_text(color = "black"),
      axis.text.y = element_text(color = "black"),
      legend.text = element_text(face = "bold"),
      panel.grid.major = element_line(color = "grey92"),
      panel.grid.minor = element_blank(),
      plot.margin = margin(20, 20, 20, 20)
    )
}

# Create graph
graph3 <- plot_multi_series(
  df = data_long,
  title = "GDP Growth and Unemployment in France",
  subtitle = "Quarterly data, 2005–2025"
)

# Display graph
print(graph3)

# Export graph
ggsave(
  filename = "graph3.png",
  plot = graph3,
  width = 12,
  height = 8,
  units = "in",
  dpi = 300,
  bg = "white"
)




# ============================================================


# ============================================================
# 8. SCATTER PLOT FUNCTION: OKUN'S LAW AND 9. SCATTER PLOTS
# ============================================================

# 8. SCATTER PLOT FUNCTION: OKUN'S LAW
# ============================================================

plot_okun <- function(data, main_title, sub_title,
                      point_color = "blue",
                      line_color = "red") {
  
  ggplot(data, aes(x = gdp_rate, y = delta_unemp)) +
    
    # Reference lines at zero
    geom_hline(
      yintercept = 0,
      linetype = "dashed",
      color = "grey70",
      linewidth = 0.5
    ) +
    
    geom_vline(
      xintercept = 0,
      linetype = "dashed",
      color = "grey70",
      linewidth = 0.5
    ) +
    
    # Observed data points
    geom_point(
      color = point_color,
      alpha = 0.6,
      size = 2
    ) +
    
    # Linear regression and confidence interval
    geom_smooth(
      method = "lm",
      formula = y ~ x,
      se = TRUE,
      color = line_color,
      fill = line_color,
      alpha = 0.1,
      linewidth = 1.2
    ) +
    
    # Labels
    labs(
      title = main_title,
      subtitle = sub_title,
      x = "GDP Growth Rate (%)",
      y = "Change in Unemployment Rate (percentage points)"
    ) +
    
    # Plot theme
    theme_bw(base_family = "sans") +
    
    theme(
      plot.title = element_text(
        face = "bold",
        size = 14,
        margin = margin(b = 10)
      ),
      plot.subtitle = element_text(
        color = "grey30",
        size = 11,
        margin = margin(b = 20)
      ),
      axis.title = element_text(
        face = "bold.italic",
        size = 10
      ),
      axis.text = element_text(color = "black"),
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(color = "grey95"),
      plot.margin = margin(20, 20, 20, 20)
    )
}



# ============================================================
# 9. SCATTER PLOTS
# ============================================================

# Graph 4: Full sample
g4 <- plot_okun(
  data = data_all,
  main_title = "Okun's Law in France",
  sub_title = "Full sample (2005–2025)"
)

print(g4)

ggsave(
  filename = "graph4.png",
  plot = g4,
  width = 12,
  height = 6,
  units = "in",
  dpi = 600
)


# Graph 5: Excluding 2020
g5 <- plot_okun(
  data = data_no_2020,
  main_title = "Okun's Law in France",
  sub_title = "Excluding 2020"
)

print(g5)

ggsave(
  filename = "graph5.png",
  plot = g5,
  width = 12,
  height = 6,
  units = "in",
  dpi = 600
)


# Graph 6: Pre-COVID period
g6 <- plot_okun(
  data = data_pre_covid,
  main_title = "Okun's Law in France",
  sub_title = "Pre-COVID period (before 2020)"
)

print(g6)

ggsave(
  filename = "graph6.png",
  plot = g6,
  width = 12,
  height = 6,
  units = "in",
  dpi = 600
)


# Graph 7: COVID and post-COVID period
g7 <- plot_okun(
  data = data_2020_2025,
  main_title = "Okun's Law in France",
  sub_title = "COVID and post-COVID period (2020 onwards)"
)

print(g7)

ggsave(
  filename = "graph7.png",
  plot = g7,
  width = 12,
  height = 6,
  units = "in",
  dpi = 600
)


# Graph 8: Post-COVID period
g8 <- plot_okun(
  data = data_2021_2025,
  main_title = "Okun's Law in France",
  sub_title = "Post-2020 period (2021 onwards)"
)

print(g8)

ggsave(
  filename = "graph8.png",
  plot = g8,
  width = 12,
  height = 6,
  units = "in",
  dpi = 600
)




# ============================================================
