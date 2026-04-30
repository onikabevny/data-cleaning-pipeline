# ============================================================
# utils_data_dictionary.R
# ------------------------------------------------------------
# Purpose:
# - Create a simple data dictionary
# - Document variables, types, and missingness
# ============================================================

source("R/00_config.R")
source("R/utils_logging.R")

library(dplyr)
library(here)

log_message("Starting data dictionary creation")

# Load cleaned dataset
clean_data <- readRDS(CLEAN_STAGE1_PATH)

# Create dictionary
data_dictionary <- data.frame(
  variable = names(clean_data),
  data_type = sapply(clean_data, class),
  missing_count = sapply(clean_data, function(x) sum(is.na(x))),
  missing_percent = round(
    sapply(clean_data, function(x) mean(is.na(x)) * 100), 2
  ),
  description = c(
    "Unique transaction identifier",
    "Customer identifier",
    "Product category",
    "Item name",
    "Price per unit",
    "Quantity purchased",
    "Total amount spent",
    "Payment method used",
    "Transaction location",
    "Date of transaction",
    "Whether discount was applied"
  ),
  notes = c(
    "No issues",
    "No issues",
    "No issues",
    "Contains missing values",
    "Fully recovered via cross-field logic",
    "Missing values remain after cleaning",
    "Missing values remain after cleaning",
    "No issues",
    "No issues",
    "No issues",
    "Standardized to TRUE/FALSE"
  )
)

# Save output
write.csv(
  data_dictionary,
  here("outputs", "data_dictionary.csv"),
  row.names = FALSE
)

log_message("Saved data_dictionary.csv")
log_message("Data dictionary creation completed")