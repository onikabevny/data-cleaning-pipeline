# ============================================================
# 01_ingest.R
# ------------------------------------------------------------
# Purpose:
# - Read the raw retail_store_sales dataset
# - Perform initial validation checks (rows, columns)
# - Standardize column names
# - Save a reproducible intermediate copy
# ============================================================



# Load logging utilities
source("R/utils_logging.R")


library(readr)
library(dplyr)
library(janitor)
library(here)

log_message("Starting ingestion step")

# ------------------------------------------------------------
# Check that file exists
# ------------------------------------------------------------
file_path <- here("raw", "retail_store_sales.csv")

if (!file.exists(file_path)) {
  stop("ERROR: Dataset not found in raw/ folder")
}

# ------------------------------------------------------------
# Read dataset
# ------------------------------------------------------------
raw_data <- read_csv(
  file_path,
  show_col_types = FALSE,
  na = c("", "NA")
)

log_message(paste("Raw data loaded with", nrow(raw_data), "rows and", ncol(raw_data), "columns"))

# ------------------------------------------------------------
# Standardize column names
# ------------------------------------------------------------
raw_data <- raw_data %>%
  clean_names()

log_message("Column names standardized to snake_case")

# Log column names (useful for debugging & documentation)
log_message(paste("Columns:", paste(names(raw_data), collapse = ", ")))

# ------------------------------------------------------------
# Save intermediate dataset
# ------------------------------------------------------------
saveRDS(raw_data, here("data", "raw_data.rds"))

log_message("Saved intermediate raw dataset to data/raw_data.rds")