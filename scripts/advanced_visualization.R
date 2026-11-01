# Load required libraries
library(ggplot2)
library(dplyr)
library(tidyr)

# 1. Load the dataset
df <- read.csv("data/master_measurements.csv", header = TRUE)

# 2. Reshape the data from wide to long format
df_long <- df %>%
  pivot_longer(
    cols = c("Seq", "Par", "Libc"),
    names_to = "Type",
    values_to = "Time"
  )

# 3. Ensure data types are properly formatted for ggplot
df_long$Size <- as.numeric(df_long$Size)
df_long$Time <- as.numeric(df_long$Time)
df_long$Type <- as.factor(df_long$Type)
df_long$Machine_ID <- as.factor(df_long$Machine_ID)

# 4. Create the ggplot with faceting and confidence intervals
p <- ggplot(df_long, aes(x = Size, y = Time, color = Type, fill = Type)) +
  geom_point(alpha = 0.3) + 
  geom_smooth(method = "loess", span = 0.8) + 
  facet_wrap(~Machine_ID, scales = "free_y") + 
  scale_x_continuous(trans = 'log10', labels = scales::comma) + 
  scale_y_continuous(labels = scales::comma) +
  labs(
    title = "Performance Evaluation of Quicksort Implementations",
    subtitle = "Comparing Sequential, Parallel, and libc qsort across architectures",
    x = "Array Size (Log Scale)",
    y = "Execution Time (Seconds)",
    color = "Algorithm Type",
    fill = "Algorithm Type"
  ) +
  theme_minimal() +
  theme(legend.position = "bottom")

# 5. Save the plot as a high-resolution PNG
ggsave("data/final_performance_plot.png", plot = p, width = 10, height = 6, dpi = 300)