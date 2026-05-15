# ============================================================
# 05_export.R
# ------------------------------------------------------------
# Purpose:
# - Export final cleaned and imputed dataset
# - Save outputs in required formats for submission
# ============================================================

source("R/00_config.R")
source("R/utils_logging.R")

library(haven)
library(openxlsx)
library(here)

log_message("Starting export step")

# Load final imputed dataset
final_data <- readRDS(here("data", "imputed_data_stage1.rds"))

# Load data dictionary
data_dictionary <- read.csv(here("outputs", "data_dictionary.csv"))

# Export CSV
write.csv(
  final_data,
  here("outputs", "final_cleaned_imputed_data.csv"),
  row.names = FALSE
)

# Export RDS
saveRDS(
  final_data,
  here("outputs", "final_cleaned_imputed_data.rds")
)

# Export Stata
write_dta(
  final_data,
  here("outputs", "final_cleaned_imputed_data.dta")
)

# Export SPSS
write_sav(
  final_data,
  here("outputs", "final_cleaned_imputed_data.sav")
)

# Export Excel with data + dictionary
wb <- createWorkbook()

addWorksheet(wb, "Final Data")
writeData(wb, "Final Data", final_data)

addWorksheet(wb, "Data Dictionary")
writeData(wb, "Data Dictionary", data_dictionary)

saveWorkbook(
  wb,
  here("outputs", "final_cleaned_imputed_data.xlsx"),
  overwrite = TRUE
)

log_message("Exported final dataset to CSV, RDS, Stata, SPSS, and Excel")
log_message("Export step completed successfully")