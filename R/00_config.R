# ============================================================
# 00_config.R
# ------------------------------------------------------------
# Purpose:
# - Store all paths, parameters, and key decisions
# - Ensure pipeline is modular, reproducible, and maintainable
# ============================================================

library(here)

# ------------------------------------------------------------
# PATHS
# ------------------------------------------------------------

RAW_DATA_PATH <- here("raw", "retail_store_sales.csv")

INTERMEDIATE_DATA_PATH <- here("data", "raw_data.rds")

CLEAN_STAGE1_PATH <- here("data", "clean_data_stage1.rds")

CLEAN_DATA_PATH <- here("data", "clean_data.rds")

OUTPUTS_PATH <- here("outputs")

REPORTS_PATH <- here("reports")

LOG_FILE <- here("outputs", "pipeline_log.txt")


# ------------------------------------------------------------
# SCOPED VARIABLES (FROM ASSIGNMENT)
# ------------------------------------------------------------

SCOPED_VARIABLES <- c(
  "transaction_id",
  "customer_id",
  "category",
  "item",
  "quantity",
  "price_per_unit",
  "total_spent",
  "payment_method",
  "location",
  "transaction_date",
  "discount_applied"
)


# ------------------------------------------------------------
# SENTINEL VALUES (FOR DETECTION / FUTURE USE)
# ------------------------------------------------------------

SENTINEL_VALUES <- c(
  "ERROR",
  "UNKNOWN",
  "",
  "NA",
  "N/A"
)


# ------------------------------------------------------------
# DISCOUNT APPLIED STANDARDIZATION
# ------------------------------------------------------------
# Final cleaned format:
# TRUE  = discount was applied
# FALSE = discount was not applied
# NA    = missing/unknown

DISCOUNT_TRUE_VALUES <- c(TRUE, "TRUE", "True", "true")

DISCOUNT_FALSE_VALUES <- c(FALSE, "FALSE", "False", "false")



# ------------------------------------------------------------
# CROSS-FIELD RELATIONSHIP
# ------------------------------------------------------------

# Total Spent = Quantity × Price Per Unit

TOTAL_SPENT_TOLERANCE <- 0.01


# ------------------------------------------------------------
# NUMERIC VALIDATION RULES
# ------------------------------------------------------------

MIN_VALID_QUANTITY <- 1

MIN_VALID_PRICE <- 0

MIN_VALID_TOTAL_SPENT <- 0


# ------------------------------------------------------------
# DATE SETTINGS
# ------------------------------------------------------------

DATE_FORMAT_EXPECTED <- "%d/%m/%Y"


# ------------------------------------------------------------
# OUTPUT FILES (FOR PIPELINE CONSISTENCY)
# ------------------------------------------------------------

MISSING_SUMMARY_FILE <- here("outputs", "missing_summary.csv")

SENTINEL_SUMMARY_FILE <- here("outputs", "sentinel_summary.csv")

DIAGNOSTICS_OVERVIEW_FILE <- here("outputs", "diagnostics_overview.csv")

CROSS_FIELD_RECOVERY_FILE <- here("outputs", "recoverable_cross_field.csv")

DISCOUNT_SUMMARY_FILE <- here("outputs", "discount_applied_summary.csv")

MISSING_BEFORE_CLEANING_FILE <- here("outputs", "missing_before_cleaning.csv")

MISSING_AFTER_CLEANING_FILE <- here("outputs", "missing_after_cleaning.csv")


# ------------------------------------------------------------
# NOTES
# ------------------------------------------------------------
# - All rules and thresholds should be defined here
# - Do NOT hardcode values inside scripts
# - Modify this file if requirements change