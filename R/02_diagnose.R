# ============================================================
# 02_diagnose.R
# ------------------------------------------------------------
# Purpose:
# - Diagnose data quality issues
# - Check missingness, sentinels, duplicates, dates, and logic
# - Do NOT clean or change the data in this script
# ============================================================

source("R/utils_logging.R")

library(dplyr)
library(readr)
library(stringr)
library(lubridate)
library(here)

log_message("Starting diagnostics step")

# Load intermediate dataset created by 01_ingest.R
raw_data <- readRDS(here("data", "raw_data.rds"))

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
  here("outputs", "missing_summary.csv"),
  row.names = FALSE
)

log_message("Saved missing_summary.csv")

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
  here("outputs", "sentinel_summary.csv"),
  row.names = FALSE
)

log_message("Saved sentinel_summary.csv")

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
    parsed_transaction_date = suppressWarnings(ymd(transaction_date)),
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
    quantity_nonpositive = !is.na(quantity) & quantity <= 0,
    price_negative = !is.na(price_per_unit) & price_per_unit < 0,
    total_spent_negative = !is.na(total_spent) & total_spent < 0
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
    total_mismatch = can_check_total & abs(total_spent - expected_total_spent) > 0.01
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
  here("outputs", "recoverable_cross_field.csv"),
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
  here("outputs", "discount_applied_summary.csv"),
  row.names = FALSE
)

log_message("Saved discount_applied_summary.csv")

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
  here("outputs", "diagnostics_overview.csv"),
  row.names = FALSE
)

log_message("Saved diagnostics_overview.csv")
log_message("Diagnostics step completed successfully")
