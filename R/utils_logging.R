# ============================================================
# utils_logging.R
# ------------------------------------------------------------
# Purpose:
# - Define helper functions for pipeline logging
# - Write timestamped messages to a log file
# ============================================================

library(here)

# Path to pipeline log file
log_file <- here("outputs", "pipeline_log.txt")

# ------------------------------------------------------------
# Function: log_message
# ------------------------------------------------------------
# Writes a timestamped message to both the console and the log file
log_message <- function(message) {
  timestamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
  entry <- paste0("[", timestamp, "] ", message)
  
  cat(entry, "\n")
  
  write(
    entry,
    file = log_file,
    append = TRUE
  )
}

# ------------------------------------------------------------
# Function: log_rows
# ------------------------------------------------------------
# Logs the number of rows and columns in a dataset
log_rows <- function(stage_name, data_object) {
  log_message(
    paste(
      stage_name,
      "- Rows:", nrow(data_object),
      "| Columns:", ncol(data_object)
    )
  )
}