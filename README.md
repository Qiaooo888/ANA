# ana: R Package for Data Analysis and Visualization

## Overview

The `ana` package provides a comprehensive toolkit for exploratory data analysis in R, featuring automatic variable analysis, visualization, and survival time calculations. The package includes both Chinese interface functions and optimized survival analysis utilities.

## Installation

### Common Installation Issues

Many users encounter the error `Error in library(ana) : there is no package called 'ana'` after installing from GitHub. This typically occurs because:

1. The package lacks proper R package structure
2. Missing DESCRIPTION file
3. No proper namespace configuration

### Proper Installation Methods

#### Method 1: Source Installation (Recommended)

```r
# Download the repository
# Then source the main file directly:
source("path/to/ana.R")

# For survival time functions, source individually as needed:
source("path/to/a_survival_time.R")
source("path/to/a_survival_time_table.R")
# etc.
```

#### Method 2: Create Local Package Structure

Create a proper package structure first:

```bash
ana/
├── DESCRIPTION
├── NAMESPACE
├── R/
│   ├── ana.R
│   ├── a_survival_time.R
│   ├── a_survival_time_table.R
│   ├── a_survival_time_C++.R
│   ├── a_survival_time_large.R
│   └── a_survival_time_ram.R
└── man/
```

Create `DESCRIPTION` file:
```
Package: ana
Type: Package
Title: Data Analysis and Visualization Tools
Version: 1.0.0
Author: Your Name
Maintainer: Your Name <your.email@example.com>
Description: Comprehensive toolkit for exploratory data analysis with automatic 
    variable analysis, visualization, and survival time calculations.
License: GPL-3
Encoding: UTF-8
LazyData: true
Imports:
    haven,
    ggplot2,
    dplyr,
    scales,
    knitr,
    rmarkdown,
    data.table,
    parallel,
    foreach,
    doParallel,
    Rcpp
RoxygenNote: 7.2.3
```

Create `NAMESPACE` file:
```
export(ana)
export(alook)
export(avar)
export(a_survival_time_improved)
export(a_survival_time_dt)
export(a_survival_time_rcpp)
export(a_survival_time_parallel)
export(a_survival_time_memory)
```

Then install:
```r
# Install from local directory
install.packages("path/to/ana", repos = NULL, type = "source")

# Or use devtools
devtools::install("path/to/ana")
```

## Dependencies

The package requires the following R packages:

### Core Dependencies
- `haven`: For reading SPSS/Stata/SAS files
- `ggplot2`: For visualization
- `dplyr`: For data manipulation
- `scales`: For plot scales
- `knitr`: For reporting
- `rmarkdown`: For document generation

### Additional Dependencies for Survival Functions
- `data.table`: For optimized data.table version
- `Rcpp`: For C++ optimized version
- `parallel`, `foreach`, `doParallel`: For parallel processing version

Install all dependencies:
```r
install.packages(c("haven", "ggplot2", "dplyr", "scales", 
                   "knitr", "rmarkdown", "data.table", 
                   "Rcpp", "parallel", "foreach", "doParallel"))
```

## Main Functions

### 1. `ana()` - Basic Analysis

Performs comprehensive descriptive statistics on specified variables.

```r
# Analyze specific variables
ana(mydata, "var1", "var2", "var3")

# Analyze all suitable variables (auto-selects up to 10)
ana(mydata)
```

**Features:**
- Automatic type detection (numeric, factor, character, logical, date)
- Missing value analysis
- Descriptive statistics for numeric variables
- Frequency tables for categorical variables
- Handles special values (Inf, NaN)

### 2. `alook()` - Visual Analysis

Creates automatic visualizations based on variable types.

```r
# Visualize specific variables
alook(mydata, "var1", "var2")

# Visualize all suitable variables
alook(mydata)
```

**Visualizations:**
- Missing value bar charts
- Histograms for numeric variables
- Box plots with jitter for small datasets
- Bar charts for categorical variables

### 3. `avar()` - All Variables Analysis

Provides a comprehensive overview of all variables in the dataset.

```r
avar(mydata)
```

**Output includes:**
- Variable type classification
- Missing value summary
- Data quality score
- Single-value variable detection
- Data quality recommendations

## Survival Time Analysis Functions

The package includes multiple optimized versions of survival time calculation:

### 1. `a_survival_time_improved()` - Enhanced Base Version

The main survival time calculation function with comprehensive error handling.

```r
# Basic usage
result <- a_survival_time_improved(data, 
                                   id_var = "patient_id",
                                   time = "visit_time", 
                                   event = "event_occurred",
                                   check_order = TRUE,
                                   verbose = TRUE)
```

**Parameters:**
- `data`: Data frame containing the survival data
- `id_var`: Column name for individual/subject ID
- `time`: Column name for time variable
- `event`: Column name for event indicator (0/1)
- `check_order`: Check temporal ordering of observations
- `verbose`: Print warnings and messages
- `handle_negative_time`: Handle negative time values

### 2. `a_survival_time_dt()` - data.table Optimized Version

5-10x faster for large datasets using data.table.

```r
# Requires data.table package
library(data.table)
result <- a_survival_time_dt(data, 
                             id_var = "patient_id",
                             time = "visit_time", 
                             event = "event_occurred")
```

### 3. `a_survival_time_rcpp()` - C++ Optimized Version

10-20x faster using Rcpp for maximum performance.

```r
# Requires Rcpp package
library(Rcpp)
result <- a_survival_time_rcpp(data, 
                               id_var = "patient_id",
                               time = "visit_time", 
                               event = "event_occurred")
```

### 4. `a_survival_time_parallel()` - Parallel Processing Version

For very large datasets, uses multiple CPU cores.

```r
# Automatically detects cores
result <- a_survival_time_parallel(data, 
                                   id_var = "patient_id",
                                   time = "visit_time", 
                                   event = "event_occurred",
                                   n_cores = 4)  # Optional
```

### 5. `a_survival_time_memory()` - Memory Optimized Version

For memory-constrained environments, uses optimized data types.

```r
result <- a_survival_time_memory(data, 
                                 id_var = "patient_id",
                                 time = "visit_time", 
                                 event = "event_occurred")
```

## Usage Examples

### Example 1: Basic Data Analysis

```r
# Load sample data
data(iris)

# Basic analysis of specific variables
ana(iris, "Sepal.Length", "Species")

# Visual analysis
alook(iris, "Sepal.Length", "Species")

# Analyze all variables
avar(iris)
```

### Example 2: Survival Analysis

```r
# Create sample survival data
survival_data <- data.frame(
  patient_id = rep(1:100, each = 5),
  visit_time = rep(0:4, 100) + runif(500, -0.1, 0.1),
  event = rbinom(500, 1, 0.1)
)

# Calculate survival times
result <- a_survival_time_improved(survival_data,
                                   id_var = "patient_id",
                                   time = "visit_time",
                                   event = "event")

# For large datasets, use optimized versions
result_fast <- a_survival_time_dt(survival_data,
                                  id_var = "patient_id",
                                  time = "visit_time",
                                  event = "event")
```

## Troubleshooting

### Issue: Package not found after GitHub installation

**Solution 1:** Use source() instead of library()
```r
source("ana.R")
# Now functions are available directly
ana(mydata)
```

**Solution 2:** Create proper package structure (see Installation section)

### Issue: Dependencies not automatically installed

**Solution:** Manually install all dependencies
```r
# Check and install missing packages
required_packages <- c("haven", "ggplot2", "dplyr", "scales", 
                      "knitr", "rmarkdown", "data.table", "Rcpp")
missing_packages <- required_packages[!required_packages %in% installed.packages()[,"Package"]]
if(length(missing_packages) > 0) {
  install.packages(missing_packages)
}
```

### Issue: Rcpp functions not working

**Solution:** Ensure Rcpp is properly installed and configured
```r
# Test Rcpp
install.packages("Rcpp")
library(Rcpp)
evalCpp("2 + 2")  # Should return 4
```

### Issue: Parallel functions not working on Windows

**Solution:** Windows requires special handling for parallel processing
```r
# On Windows, use:
library(parallel)
cl <- makeCluster(detectCores() - 1)
# ... your code ...
stopCluster(cl)
```

## Performance Comparison

| Function | Relative Speed | Best Use Case |
|----------|---------------|---------------|
| `a_survival_time_improved` | 1x (baseline) | Small datasets, full features |
| `a_survival_time_dt` | 5-10x | Medium to large datasets |
| `a_survival_time_rcpp` | 10-20x | Large datasets, speed critical |
| `a_survival_time_parallel` | Varies | Very large datasets, multi-core systems |
| `a_survival_time_memory` | 0.8x | Memory-constrained environments |

## Contributing

Feel free to submit issues, fork the repository, and create pull requests for any improvements.

## License

GPL-3

## Notes

- The package automatically loads required dependencies on attach
- Chinese characters in function output may require proper encoding settings
- For best performance with large datasets, use the optimized survival time functions
- The visualization functions (alook) work best with datasets under 10,000 rows

## Citation

If you use this package in your research, please cite:

```
@Manual{,
  title = {ana: Data Analysis and Visualization Tools for R},
  author = {Author Name},
  year = {2024},
  note = {R package version 1.0.0},
  url = {https://github.com/username/ana},
}
```