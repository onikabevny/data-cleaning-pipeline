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

log_message(paste("Saved baseline missingness before cleaning to", MISSING_BEFORE_CLEANING_FILE))


# ------------------------------------------------------------
# STEP 1: Cross-field recovery
# ------------------------------------------------------------

log_message("Starting cross-field recovery")

# Count missing BEFORE
missing_total_before <- sum(is.na(clean_data$total_spent))
missing_price_before <- sum(is.na(clean_data$price_per_unit))
missing_quantity_before <- sum(is.na(clean_data$quantity))

# Apply recovery
clean_data <- clean_data %>%
  mutate(
    total_spent = ifelse(
      is.na(total_spent) & !is.na(quantity) & !is.na(price_per_unit),
      quantity * price_per_unit,
      total_spent
    ),
    
    price_per_unit = ifelse(
      is.na(price_per_unit) & !is.na(quantity) & !is.na(total_spent),
      total_spent / quantity,
      price_per_unit
    ),
    
    quantity = ifelse(
      is.na(quantity) & !is.na(total_spent) & !is.na(price_per_unit) & price_per_unit != 0,
      total_spent / price_per_unit,
      quantity
    )
  )

# Count missing AFTER
missing_total_after <- sum(is.na(clean_data$total_spent))
missing_price_after <- sum(is.na(clean_data$price_per_unit))
missing_quantity_after <- sum(is.na(clean_data$quantity))

# Log recovered values
log_message(paste("Recovered total_spent:", missing_total_before - missing_total_after))
log_message(paste("Recovered price_per_unit:", missing_price_before - missing_price_after))
log_message(paste("Recovered quantity:", missing_quantity_before - missing_quantity_after))




# ------------------------------------------------------------
# STEP 2: Verification of cross-field recovery
# ------------------------------------------------------------

log_message("Verifying cross-field recovery")

# Recalculate expected totals
verification_check <- clean_data %>%
  mutate(
    expected_total_spent = quantity * price_per_unit,
    can_check = !is.na(quantity) & !is.na(price_per_unit) & !is.na(total_spent),
    still_mismatch = can_check & abs(total_spent - expected_total_spent) > TOTAL_SPENT_TOLERANCE
  )

remaining_mismatches <- verification_check %>%
  filter(still_mismatch)

log_message(paste("Remaining mismatches after recovery:", nrow(remaining_mismatches)))

# ------------------------------------------------------------
# STEP 3: Missingness AFTER cleaning
# ------------------------------------------------------------

missing_after_cleaning <- data.frame(
  variable = names(clean_data),
  missing_count_after = sapply(clean_data, function(x) sum(is.na(x)))
)

write.csv(
  missing_after_cleaning,
  MISSING_AFTER_CLEANING_FILE,
  row.names = FALSE
)

log_message(paste("Saved missing_after_cleaning to", MISSING_AFTER_CLEANING_FILE))

# ------------------------------------------------------------
# STEP 4: Missingness comparison
# ------------------------------------------------------------

missing_comparison <- merge(
  missing_before_cleaning,
  missing_after_cleaning,
  by = "variable"
)

missing_comparison$recovered <- 
  missing_comparison$missing_count_before - missing_comparison$missing_count_after

write.csv(
  missing_comparison,
  MISSING_COMPARISON_FILE,
  row.names = FALSE
)

log_message(paste("Saved missing_comparison to", MISSING_COMPARISON_FILE))


# ------------------------------------------------------------
# Save cleaning-stage dataset after cross-field recovery
# ------------------------------------------------------------
saveRDS(clean_data, CLEAN_STAGE1_PATH)

log_message(paste("Saved cleaning-stage dataset after cross-field recovery to", CLEAN_STAGE1_PATH))


log_message("Cleaning step completed successfully")