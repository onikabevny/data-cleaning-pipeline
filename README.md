# data-cleaning-pipeline

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

---

## How to Run

1. Open R in the project directory
2. Install required packages (if not already installed):

```r
install.packages(c("tidyverse", "naniar", "haven", "openxlsx", "rmarkdown"))
```

3. Run the pipeline:

```r
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

* Cleaned dataset:

  * `.sav` (SPSS)
  * `.dta` (Stata)
  * `.xlsx` (Excel)
  * `.rds` (R)

* Data dictionary (`data_dictionary.csv`)

* Automated Word report (`.docx`)

---

## Reproducibility

* The pipeline runs end-to-end with a single command
* Raw data is never modified
* All steps are scripted and logged

---

## Notes

* Only basic imputation methods are used (mean, median, mode)
* No advanced modeling or machine learning is applied
* Designed for clarity, reproducibility, and readability
