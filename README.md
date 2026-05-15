# Data Cleaning & Imputation Pipeline

## Overview

This project implements a reproducible data cleaning and imputation pipeline in R for the assigned `retail_store_sales` dataset.

The pipeline was developed using a modular workflow designed to support reproducibility, transparency, consistency, and structured data processing.

The pipeline performs:

* Data ingestion
* Data quality diagnostics
* Data cleaning and standardization
* Missing data imputation (basic methods)
* Validation and consistency checks
* Data dictionary generation
* Multi-format data export
* Automated Word report generation

The pipeline is designed specifically for the assigned dataset and scoped variables, ensuring all processing remains within defined analytical boundaries.

---

## Pipeline Architecture

Raw Data → Ingestion → Diagnostics → Cleaning → Imputation → Validation → Data Dictionary → Export → Automated Report

---

## Dataset & Scope

The assigned dataset for this project is:

**`retail_store_sales`**

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

* Normalize the `discount_applied` variable into a consistent logical format (`TRUE/FALSE`) while preserving unresolved missing values

* Identify and handle missing, inconsistent, or invalid entries across key variables

### Scope Limitation

All cleaning, validation, and imputation steps are strictly limited to the assigned variables, in accordance with the assignment requirements.

---

## How to Run

### 1. Open the Project

Open RStudio in the project directory (preferably using the `.Rproj` file).

### 2. Install Required Packages

Run the following command if the required packages are not already installed:

```r
install.packages(c(
  "tidyverse",
  "naniar",
  "haven",
  "openxlsx",
  "rmarkdown",
  "janitor",
  "lubridate",
  "here",
  "flextable",
  "officer",
  "scales"
))
```

### 3. Run the Pipeline

```r
source("run_pipeline.R")
```

---

## Final Pipeline Execution

Running:

```r
source("run_pipeline.R")
```

will automatically execute:

1. Configuration loading
2. Data ingestion
3. Data diagnostics
4. Data cleaning
5. Missing data imputation
6. Validation checks
7. Data dictionary generation
8. Multi-format exports
9. Automated Word report rendering

All outputs are generated automatically and saved in the appropriate folders.

---

## Project Structure

* `raw/` → raw dataset (never modified)
* `data/` → intermediate datasets
* `outputs/` → cleaned datasets and report outputs
* `reports/` → weekly progress reports
* `presentation/` → final presentation slides
* `R/` → pipeline scripts and utility functions

### Scripts

* `00_config.R` → paths, parameters, and validation rules
* `01_ingest.R` → raw data ingestion
* `02_diagnose.R` → data diagnostics and issue detection
* `03_clean.R` → cleaning and standardization procedures
* `04_impute.R` → missing data handling and imputation
* `05_export.R` → export outputs
* `utils_dictionary.R` → automated data dictionary generation
* `utils_logging.R` → pipeline logging utilities
* `run_pipeline.R` → main pipeline entry point
* `06_report.Rmd` → automated Word report generation

---

## Outputs

All outputs are saved in the `outputs/` folder.

### Final Exported Dataset Formats

The finalized cleaned and imputed dataset is exported in the following formats:

* `.csv`
* `.xlsx` (Excel)
* `.sav` (SPSS)
* `.dta` (Stata)
* `.rds` (R)

### Additional Outputs

The pipeline also generates:

* Data dictionary (`data_dictionary.csv`)
* Diagnostics summaries
* Missingness summaries
* Cleaning and imputation comparison summaries
* Validation summaries
* Pipeline log file (`pipeline_log.txt`)
* Automated Word report (`06_report.docx`)

---

## Reproducibility

The pipeline was designed to support full reproducibility and traceability.

Key reproducibility features include:

* End-to-end execution using a single command
* Raw data preservation (raw files are never modified)
* Modular pipeline structure
* Centralized configuration settings
* Automated logging of all major pipeline stages
* Automated report generation
* Scripted transformations and validation checks
* Version-controlled development using Git and GitHub
* The repository maintains version-controlled development through meaningful staged commits

---

## Notes

* Only basic imputation methods are used (median imputation, hot-deck imputation, and rule-based approaches)
* No advanced predictive modeling or machine learning methods were applied
* The pipeline was designed for clarity, readability, maintainability, and reproducibility
* Some unresolved missing values were intentionally retained where no reliable deterministic recovery or imputation strategy could be justified
