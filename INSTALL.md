# Installation Guide for ana Package

## Quick Start (Easiest Method)

If you just want to use the functions without building a proper package:

```r
# Simply source the main file
source("ana.R")

# Source additional files as needed
source("a_survival_time.R")
source("a_survival_time_table.R")
# etc.

# Now use the functions directly
ana(mydata)
```

## Proper Package Installation

### Step 1: Create Package Structure

#### Option A: Use the setup script (Recommended)

```r
# Run the R setup script
source("setup.R")
```

Or use the shell script (Unix/Linux/Mac):

```bash
chmod +x setup.sh
./setup.sh
```

#### Option B: Manual setup

1. Create the following directory structure:
```
ana/
├── DESCRIPTION
├── NAMESPACE
├── LICENSE
├── R/
│   ├── ana.R
│   ├── a_survival_time.R
│   ├── a_survival_time_table.R
│   ├── a_survival_time_C++.R
│   ├── a_survival_time_large.R
│   └── a_survival_time_ram.R
├── man/
├── inst/
│   └── CITATION
└── tests/
    └── testthat/
```

2. Copy all provided files to their respective locations

### Step 2: Install Dependencies

```r
# Core dependencies
install.packages(c("haven", "ggplot2", "dplyr", "scales", 
                   "knitr", "rmarkdown"))

# Optional dependencies for survival functions
install.packages(c("data.table", "Rcpp", "parallel", 
                   "foreach", "doParallel"))

# Development dependencies
install.packages(c("devtools", "roxygen2", "testthat"))
```

### Step 3: Build and Install

#### Option A: Using devtools (Easiest)

```r
# Navigate to the package directory
setwd("ana")

# Install using devtools
devtools::install()

# Or for development (no installation needed)
devtools::load_all()
```

#### Option B: Using R CMD (Traditional)

```bash
# Build the package
R CMD build ana

# Check the package (optional but recommended)
R CMD check ana_1.0.0.tar.gz

# Install the package
R CMD INSTALL ana_1.0.0.tar.gz
```

#### Option C: Using Make (if Makefile is available)

```bash
cd ana
make all
```

## Troubleshooting

### Problem: "there is no package called 'ana'"

**Cause**: The package structure is incorrect or missing files.

**Solutions**:
1. Use the quick start method (source files directly)
2. Ensure DESCRIPTION and NAMESPACE files are present
3. Check that all R files are in the R/ subdirectory

### Problem: Dependencies not found

**Solution**: Install all dependencies manually:
```r
# Check which packages are missing
required <- c("haven", "ggplot2", "dplyr", "scales", 
              "knitr", "rmarkdown")
missing <- required[!required %in% installed.packages()[,"Package"]]
if(length(missing) > 0) install.packages(missing)
```

### Problem: Rcpp functions not working

**Solution**: Ensure Rcpp is properly installed:
```r
install.packages("Rcpp")
library(Rcpp)
# Test Rcpp
evalCpp("2 + 2")  # Should return 4
```

### Problem: Cannot find R files

**Solution**: Ensure you're in the correct directory:
```r
# Check current directory
getwd()

# List files
list.files()

# Set correct directory
setwd("path/to/ana/package")
```

## Installation from GitHub

If the package is hosted on GitHub with proper structure:

```r
# Using devtools
devtools::install_github("username/ana")

# Using remotes
remotes::install_github("username/ana")
```

## Verification

After installation, test that the package works:

```r
# Load the package
library(ana)

# Test basic function
data(iris)
ana(iris, "Sepal.Length")

# Check package version
packageVersion("ana")

# View help
?ana
```

## Uninstallation

To remove the package:

```r
remove.packages("ana")
```

## For Package Developers

### Adding the package to GitHub

1. Create proper package structure using this guide
2. Initialize git repository:
```bash
cd ana
git init
git add .
git commit -m "Initial commit"
```

3. Push to GitHub:
```bash
git remote add origin https://github.com/username/ana.git
git push -u origin main
```

### Continuous Integration

Add `.github/workflows/R-CMD-check.yaml` for automatic checking:

```yaml
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

name: R-CMD-check

jobs:
  R-CMD-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: r-lib/actions/setup-r@v1
      - name: Install dependencies
        run: |
          install.packages(c("remotes", "rcmdcheck"))
          remotes::install_deps(dependencies = TRUE)
        shell: Rscript {0}
      - name: Check
        run: rcmdcheck::rcmdcheck(args = "--no-manual", error_on = "error")
        shell: Rscript {0}
```

## Support

For issues or questions:
- Open an issue on GitHub
- Check the package documentation: `help(package = "ana")`
- Email: your.email@example.com