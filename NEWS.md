# ana 1.0.0

## Initial Release

This is the first release of the ana package, providing comprehensive data analysis and visualization tools for R.

### Main Features

* **Core Analysis Functions**
  - `ana()`: Basic statistical analysis with automatic variable type detection
  - `alook()`: Automated visualization based on variable types
  - `avar()`: Comprehensive overview of all variables in a dataset

* **Survival Time Calculation Functions**
  - `a_survival_time_improved()`: Enhanced base implementation with comprehensive error handling
  - `a_survival_time_dt()`: data.table optimized version (5-10x faster)
  - `a_survival_time_rcpp()`: C++ optimized version (10-20x faster)
  - `a_survival_time_parallel()`: Parallel processing for very large datasets
  - `a_survival_time_memory()`: Memory-efficient implementation

### Key Capabilities

* Automatic handling of various data types (numeric, factor, character, logical, date)
* Missing value analysis and visualization
* Special value detection (Inf, NaN)
* Haven labeled variable support
* Bilingual support (English/Chinese)

### Dependencies

* Core: haven, ggplot2, dplyr, scales, knitr, rmarkdown
* Optional: data.table, Rcpp, parallel, foreach, doParallel

### Known Issues

* Visualization functions may have encoding issues with Chinese characters on some systems
* Parallel functions require special configuration on Windows

### Future Plans

* Add support for more statistical tests
* Implement interactive visualizations
* Add more survival analysis features
* Improve memory efficiency for very large datasets