# ============================================================
# 02_diagnose.R
# ------------------------------------------------------------
# Purpose:
# - Diagnose data quality issues
# - Check missingness, sentinels, duplicates, dates, and logic
# - Do NOT clean or change the data in this script
# ============================================================

source("R/00_config.R")
source("R/utils_logging.R")

library(dplyr)
library(readr)
library(stringr)
library(lubridate)
library(here)

log_message("Starting diagnostics step")

# Load intermediate dataset created by 01_ingest.R
raw_data <- readRDS(INTERMEDIATE_DATA_PATH)

log_message(paste("Diagnostics running on", nrow(raw_data), "rows and", ncol(raw_data), "columns"))

# ------------------------------------------------------------
# 1. Missingness summary
# ------------------------------------------------------------

missing_summary <- data.frame(
  variable = names(raw_data),
  missing_count = sapply(raw_data, function(x) sum(is.na(x))),
  missing_percent = round(sapply(raw_data, function(x) mean(is.na(x)) * 100), 2)
)

write.csv(
  missing_summary,
  MISSING_SUMMARY_FILE,
  row.names = FALSE
)

log_message(paste("Saved missing_summary.csv to", MISSING_SUMMARY_FILE))

# ------------------------------------------------------------
# 2. Sentinel values: ERROR / UNKNOWN
# ------------------------------------------------------------

sentinel_summary <- data.frame(
  variable = names(raw_data),
  error_count = sapply(raw_data, function(x) sum(as.character(x) == "ERROR", na.rm = TRUE)),
  unknown_count = sapply(raw_data, function(x) sum(as.character(x) == "UNKNOWN", na.rm = TRUE)),
  blank_string_count = sapply(raw_data, function(x) sum(trimws(as.character(x)) == "", na.rm = TRUE))
)

write.csv(
  sentinel_summary,
  SENTINEL_SUMMARY_FILE,
  row.names = FALSE
)

log_message(paste("Saved sentinel_summary.csv to", SENTINEL_SUMMARY_FILE))

# ------------------------------------------------------------
# 3. Duplicate checks
# ------------------------------------------------------------

duplicate_transaction_ids <- raw_data %>%
  filter(!is.na(transaction_id)) %>%
  count(transaction_id, name = "duplicate_count") %>%
  filter(duplicate_count > 1)

write.csv(
  duplicate_transaction_ids,
  here("outputs", "duplicate_transaction_ids.csv"),
  row.names = FALSE
)

log_message(paste("Duplicate transaction IDs:", nrow(duplicate_transaction_ids)))

exact_duplicate_rows <- raw_data %>%
  group_by(across(everything())) %>%
  filter(n() > 1) %>%
  ungroup()

write.csv(
  exact_duplicate_rows,
  here("outputs", "exact_duplicate_rows.csv"),
  row.names = FALSE
)

log_message(paste("Exact duplicate rows:", nrow(exact_duplicate_rows)))

# ------------------------------------------------------------
# 4. Date parsing check
# ------------------------------------------------------------

date_check <- raw_data %>%
  mutate(
    parsed_transaction_date = suppressWarnings(dmy(transaction_date)),
    date_parse_failed = !is.na(transaction_date) & is.na(parsed_transaction_date)
  )

date_parse_issues <- date_check %>%
  filter(date_parse_failed) %>%
  select(transaction_id, transaction_date)

write.csv(
  date_parse_issues,
  here("outputs", "date_parse_issues.csv"),
  row.names = FALSE
)

log_message(paste("Date parse issues:", nrow(date_parse_issues)))

# ------------------------------------------------------------
# 5. Numeric range checks
# ------------------------------------------------------------

numeric_logic_issues <- raw_data %>%
  mutate(
    quantity_nonpositive = !is.na(quantity) & quantity < MIN_VALID_QUANTITY,
    price_negative = !is.na(price_per_unit) & price_per_unit < MIN_VALID_PRICE,
    total_spent_negative = !is.na(total_spent) & total_spent < MIN_VALID_TOTAL_SPENT
  ) %>%
  filter(quantity_nonpositive | price_negative | total_spent_negative) %>%
  select(
    transaction_id,
    quantity,
    price_per_unit,
    total_spent,
    quantity_nonpositive,
    price_negative,
    total_spent_negative
  )

write.csv(
  numeric_logic_issues,
  here("outputs", "numeric_logic_issues.csv"),
  row.names = FALSE
)

log_message(paste("Numeric logic issues:", nrow(numeric_logic_issues)))

# ------------------------------------------------------------
# 6. Total Spent validation
# Total Spent should equal Quantity * Price Per Unit
# ------------------------------------------------------------

spending_logic_check <- raw_data %>%
  mutate(
    expected_total_spent = quantity * price_per_unit,
    can_check_total = !is.na(quantity) & !is.na(price_per_unit) & !is.na(total_spent),
    total_mismatch = can_check_total & abs(total_spent - expected_total_spent) > TOTAL_SPENT_TOLERANCE
  )

spending_mismatches <- spending_logic_check %>%
  filter(total_mismatch) %>%
  select(transaction_id, quantity, price_per_unit, total_spent, expected_total_spent)

write.csv(
  spending_mismatches,
  here("outputs", "spending_mismatches.csv"),
  row.names = FALSE
)

log_message(paste("Spending mismatches:", nrow(spending_mismatches)))

# ------------------------------------------------------------
# 7. Cross-field recoverability
# ------------------------------------------------------------

recoverable_cross_field <- raw_data %>%
  mutate(
    recover_total_spent = is.na(total_spent) & !is.na(quantity) & !is.na(price_per_unit),
    recover_quantity = is.na(quantity) & !is.na(total_spent) & !is.na(price_per_unit),
    recover_price_per_unit = is.na(price_per_unit) & !is.na(total_spent) & !is.na(quantity)
  ) %>%
  filter(recover_total_spent | recover_quantity | recover_price_per_unit)

write.csv(
  recoverable_cross_field,
  CROSS_FIELD_RECOVERY_FILE,
  row.names = FALSE
)

log_message(paste("Potentially recoverable cross-field rows:", nrow(recoverable_cross_field)))

# ------------------------------------------------------------
# 8. Discount Applied summary
# ------------------------------------------------------------

discount_summary <- raw_data %>%
  mutate(discount_applied = as.character(discount_applied)) %>%
  count(discount_applied, sort = TRUE, name = "count") %>%
  mutate(percent = round(count / sum(count) * 100, 2))

write.csv(
  discount_summary,
  DISCOUNT_SUMMARY_FILE,
  row.names = FALSE
)

log_message(paste("Saved discount_applied_summary.csv to", DISCOUNT_SUMMARY_FILE))

# ------------------------------------------------------------
# 9. Diagnostics overview
# ------------------------------------------------------------

diagnostics_overview <- data.frame(
  metric = c(
    "Rows",
    "Columns",
    "Duplicate Transaction IDs",
    "Exact Duplicate Rows",
    "Date Parse Issues",
    "Numeric Logic Issues",
    "Spending Mismatches",
    "Potentially Recoverable Cross-Field Rows"
  ),
  value = c(
    nrow(raw_data),
    ncol(raw_data),
    nrow(duplicate_transaction_ids),
    nrow(exact_duplicate_rows),
    nrow(date_parse_issues),
    nrow(numeric_logic_issues),
    nrow(spending_mismatches),
    nrow(recoverable_cross_field)
  )
)

write.csv(
  diagnostics_overview,
  DIAGNOSTICS_OVERVIEW_FILE,
  row.names = FALSE
)

log_message(paste("Saved diagnostics_overview.csv to", DIAGNOSTICS_OVERVIEW_FILE))
log_message("Diagnostics step completed successfully")