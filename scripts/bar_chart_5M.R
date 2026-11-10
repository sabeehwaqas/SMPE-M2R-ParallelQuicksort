# Load required libraries
library(ggplot2)
library(dplyr)
library(tidyr)

# 1. Load the dataset
df <- read.csv("data/master_measurements.csv", header = TRUE)

# 2. Reshape and filter for ONLY the 5,000,000 array size
df_long <- df %>%
  pivot_longer(
    cols = c("Seq", "Par", "Libc"),
    names_to = "Type",
    values_to = "Time"
  ) %>%
  filter(Size == 5000000)

# 3. Create a grouped bar chart
p <- ggplot(df_long, aes(x = Machine_ID, y = Time, fill = Type)) +
  # Use position_dodge to place the bars side-by-side instead of stacking them
  geom_bar(stat = "identity", position = position_dodge(width = 0.8), width = 0.7) +
  labs(
    title = "Peak Load: Execution Time at 5,000,000 Array Size",
    subtitle = "Direct comparison of algorithm efficiency across hardware architectures",
    x = "Machine Architecture",
    y = "Execution Time (Seconds)",
    fill = "Algorithm Type"
  ) +
  theme_minimal() +
  theme(
    legend.position = "bottom",
    # Angle the x-axis text slightly so the machine names don't overlap
    axis.text.x = element_text(angle = 15, hjust = 1)
  )

# 4. Save the high-resolution plot
ggsave("data/5M_array_comparison.png", plot = p, width = 10, height = 6, dpi = 300)