# ============================================================
# MAIN PIPELINE SCRIPT (run_pipeline.R)
# ------------------------------------------------------------
# This script serves as the single entry point for the entire
# data cleaning and imputation pipeline.
#
# Running this script will:
# 1. Load configuration and helper functions
# 2. Execute each stage of the pipeline in order
# 3. Generate all outputs (cleaned data + report)
#
# The pipeline is fully automated and reproducible.
# ============================================================


# Print a message to the console indicating the pipeline has started
cat("=== PIPELINE START ===\n")


# ------------------------------------------------------------
# Load logging utilities
# ------------------------------------------------------------
# This script defines helper functions such as:
# - log_message(): writes messages with timestamps
# These logs are saved to a file for tracking pipeline activity
source("R/utils_logging.R")


# Record the start of the pipeline in the log file
log_message("Pipeline started")


# ------------------------------------------------------------
# Define pipeline stages
# ------------------------------------------------------------
# Each script represents a distinct stage of the pipeline.
# The order is important and follows the required workflow:
#
# 00_config   → define paths and parameters
# 01_ingest   → load raw data
# 02_diagnose → explore data issues (no changes made)
# 03_clean    → clean and standardize data
# 04_impute   → handle missing values
# 05_export   → save outputs in required formats
scripts <- list(
  "R/00_config.R",
  "R/01_ingest.R",
  "R/02_diagnose.R",
  "R/03_clean.R",
  "R/04_impute.R",
  "R/05_export.R"
)


# ------------------------------------------------------------
# Execute pipeline stages
# ------------------------------------------------------------
# Loop through each script and run it sequentially.
# Before running each script, log which stage is being executed.
for (script in scripts) {
  
  # Log current stage
  log_message(paste("Running", script))
  
  # Execute the script
  source(script)
}


# ------------------------------------------------------------
# Render automated report
# ------------------------------------------------------------
# After all data processing steps are complete,
# generate the Word report using R Markdown.
# This report includes diagnostics, cleaning decisions,
# and summary statistics based on the cleaned dataset.
log_message("Rendering report")
rmarkdown::render("06_report.Rmd")


# Record completion of the pipeline in the log file
log_message("Pipeline completed")


# Print a message to the console indicating the pipeline has finished
cat("=== PIPELINE END ===\n")