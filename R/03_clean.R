# ============================================================
# 03_clean.R
# ------------------------------------------------------------
# Purpose:
# - Begin the cleaning stage of the pipeline
# - Load the ingested dataset
# - Prepare structure for cleaning steps
# - Log row and column counts before cleaning
#
# Note:
# - Cleaning will be implemented one issue class at a time
# - This script will be expanded during Week 2
# ============================================================

# ------------------------------------------------------------
# Load required utilities and packages
# ------------------------------------------------------------
source("R/00_config.R")
source("R/utils_logging.R")

library(dplyr)
library(here)

log_message("Starting cleaning step")

# ------------------------------------------------------------
# Load ingested dataset
# ------------------------------------------------------------
raw_data <- readRDS(INTERMEDIATE_DATA_PATH)

log_message(
  paste(
    "Loaded raw_data for cleaning with",
    nrow(raw_data),
    "rows and",
    ncol(raw_data),
    "columns"
  )
)

# ------------------------------------------------------------
# Create working copy for cleaning
# ------------------------------------------------------------
clean_data <- raw_data

log_message("Created clean_data working copy from raw_data")

# ------------------------------------------------------------
# Baseline missingness before cleaning
# ------------------------------------------------------------
missing_before_cleaning <- data.frame(
  variable = names(clean_data),
  missing_count_before = sapply(clean_data, function(x) sum(is.na(x)))
)

write.csv(
  missing_before_cleaning,
  MISSING_BEFORE_CLEANING_FILE,
  row.names = FALSE
)

log_message("Saved baseline missingness before cleaning")

# ------------------------------------------------------------
# Save initial cleaning-stage dataset
# ------------------------------------------------------------
saveRDS(clean_data, CLEAN_STAGE1_PATH)

log_message("Saved baseline missingness before cleaning")

log_message("Cleaning script structure completed")