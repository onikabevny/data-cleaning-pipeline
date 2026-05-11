# ============================================================
# 04_impute.R
# ------------------------------------------------------------
# Purpose:
# - Implement basic imputation methods
# - Handle remaining missing values
# - Compare missingness before and after imputation
# ============================================================

# ------------------------------------------------------------
# Load required utilities and packages
# ------------------------------------------------------------
source("R/00_config.R")
source("R/utils_logging.R")

library(dplyr)
library(here)

log_message("Starting imputation step")

# ------------------------------------------------------------
# Load cleaned dataset
# ------------------------------------------------------------
clean_data <- readRDS(CLEAN_STAGE1_PATH)

log_message(
  paste(
    "Loaded clean_data for imputation with",
    nrow(clean_data),
    "rows and",
    ncol(clean_data),
    "columns"
  )
)

# ------------------------------------------------------------
# Create working copy for imputation
# ------------------------------------------------------------
imputed_data <- clean_data

log_message("Created imputed_data working copy")

# ------------------------------------------------------------
# Baseline missingness before imputation
# ------------------------------------------------------------
missing_before_imputation <- data.frame(
  variable = names(imputed_data),
  missing_count_before = sapply(imputed_data, function(x) sum(is.na(x)))
)

write.csv(
  missing_before_imputation,
  here("outputs", "missing_before_imputation.csv"),
  row.names = FALSE
)

log_message("Saved missing_before_imputation.csv")

# ------------------------------------------------------------
# Imputation steps will be added below
# ------------------------------------------------------------

log_message("Imputation script structure completed")



# ------------------------------------------------------------
# STEP 1: Median imputation for remaining numeric variables
# ------------------------------------------------------------

log_message("Starting median imputation for numeric variables")

# Count missing BEFORE imputation
quantity_missing_before <- sum(is.na(imputed_data$quantity))
total_spent_missing_before <- sum(is.na(imputed_data$total_spent))

# Calculate median values using observed data only
quantity_median <- median(imputed_data$quantity, na.rm = TRUE)
total_spent_median <- median(imputed_data$total_spent, na.rm = TRUE)

log_message(paste("Median quantity used for imputation:", quantity_median))
log_message(paste("Median total_spent used for imputation:", total_spent_median))

# Apply median imputation
imputed_data <- imputed_data %>%
  mutate(
    quantity = ifelse(
      is.na(quantity),
      quantity_median,
      quantity
    ),
    total_spent = ifelse(
      is.na(total_spent),
      total_spent_median,
      total_spent
    )
  )

# Count missing AFTER imputation
quantity_missing_after <- sum(is.na(imputed_data$quantity))
total_spent_missing_after <- sum(is.na(imputed_data$total_spent))

# Log number of values imputed
log_message(paste("Imputed quantity values:", quantity_missing_before - quantity_missing_after))
log_message(paste("Imputed total_spent values:", total_spent_missing_before - total_spent_missing_after))



# ------------------------------------------------------------
# STEP 2: Missingness AFTER numeric imputation
# ------------------------------------------------------------

missing_after_numeric_imputation <- data.frame(
  variable = names(imputed_data),
  missing_count_after_numeric_imputation = sapply(imputed_data, function(x) sum(is.na(x)))
)

write.csv(
  missing_after_numeric_imputation,
  here("outputs", "missing_after_numeric_imputation.csv"),
  row.names = FALSE
)

log_message("Saved missing_after_numeric_imputation.csv")


# ------------------------------------------------------------
# Save imputed dataset
# ------------------------------------------------------------

saveRDS(imputed_data, here("data", "imputed_data_stage1.rds"))

log_message("Saved imputed dataset to data/imputed_data_stage1.rds")
log_message("Imputation step completed successfully")


# ------------------------------------------------------------
# STEP 3: Handle remaining categorical/logical missingness
# ------------------------------------------------------------

log_message("Starting handling of remaining categorical/logical missingness")

# Count missing BEFORE
item_missing_before <- sum(is.na(imputed_data$item))
discount_missing_before <- sum(is.na(imputed_data$discount_applied))

# Create missingness indicators instead of forcing uncertain values
imputed_data <- imputed_data %>%
  mutate(
    item_missing_flag = is.na(item),
    discount_applied_missing_flag = is.na(discount_applied)
  )

# Count missing AFTER
item_missing_after <- sum(is.na(imputed_data$item))
discount_missing_after <- sum(is.na(imputed_data$discount_applied))

log_message(paste("Item missing values left unchanged:", item_missing_after))
log_message(paste("Discount_applied missing values left unchanged:", discount_missing_after))
log_message("Created item_missing_flag and discount_applied_missing_flag")


# ------------------------------------------------------------
# Save imputed dataset
# ------------------------------------------------------------

saveRDS(imputed_data, here("data", "imputed_data_stage1.rds"))

log_message("Saved imputed dataset to data/imputed_data_stage1.rds")
log_message("Imputation step completed successfully")