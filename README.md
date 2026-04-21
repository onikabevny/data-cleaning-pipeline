# Data Cleaning & Imputation Pipeline

## Overview

This project implements a reproducible data cleaning and imputation pipeline in R.

The pipeline performs:

* Data ingestion
* Data quality diagnostics
* Data cleaning and standardization
* Missing data imputation (basic methods)
* Multi-format data export
* Automated Word report generation

The pipeline is designed specifically for the assigned dataset and scoped variables, ensuring all processing remains within defined analytical boundaries.

---

## Dataset & Scope

The assigned dataset for this project is:

**retail_store_sales**

The scope of this assignment is restricted to the following variables:

* Transaction ID
* Customer ID
* Category
* Item
* Quantity
* Price Per Unit
* Total Spent
* Payment Method
* Location
* Transaction Date
* Discount Applied

### Data Quality Requirements

The pipeline is designed to address the following data quality issues within the scoped variables:

* Handle sentinel values such as `"ERROR"` and `"UNKNOWN"`
* Validate the relationship:
  **Total Spent = Quantity × Price Per Unit**
* Identify and handle inconsistencies in this relationship (flag or correct where appropriate)
* Impute missing values using cross-field relationships where values are recoverable
* Normalize the **Discount Applied** variable into a consistent tri-valued format
* Identify and handle missing, inconsistent, or invalid entries across key variables

### Scope Limitation

All cleaning, validation, and imputation steps are strictly limited to the assigned variables, in accordance with the assignment requirements.

---

## How to Run

1. Open R in the project directory (preferably via the `.Rproj` file)

2. Install required packages (if not already installed):

```r id="r4j3pl"
install.packages(c("tidyverse", "naniar", "haven", "openxlsx", "rmarkdown", "janitor", "lubridate", "here"))
```

3. Run the pipeline:

```r id="qjv4g2"
source("run_pipeline.R")
```

---

## Project Structure

* `raw/` → raw dataset (never modified)
* `data/` → intermediate datasets
* `outputs/` → cleaned datasets and report
* `reports/` → weekly progress reports
* `presentation/` → final slides
* `R/` → pipeline scripts

### Scripts

* `00_config.R` → paths and parameters
* `01_ingest.R` → load raw data
* `02_diagnose.R` → data diagnostics
* `03_clean.R` → cleaning steps
* `04_impute.R` → missing data handling
* `05_export.R` → export outputs
* `utils_*.R` → helper functions
* `run_pipeline.R` → main entry point
* `06_report.Rmd` → automated Word report

---

## Outputs

All outputs are saved in `outputs/`:

### Cleaned Dataset

* `.sav` (SPSS)
* `.dta` (Stata)
* `.xlsx` (Excel)
* `.rds` (R)

### Additional Outputs

* Data dictionary (`data_dictionary.csv`)
* Diagnostics outputs (missingness, duplicates, logic checks)
* Automated Word report (`.docx`)

---

## Reproducibility

* The pipeline runs end-to-end with a single command
* Raw data is never modified
* All steps are scripted and logged

---

## Notes

* Only basic imputation methods are used (mean, median, mode, or rule-based imputation)
* No advanced modeling or machine learning is applied
* The pipeline is designed for clarity, reproducibility, and readability
