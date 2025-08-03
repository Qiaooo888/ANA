# Complete File List for ana Package

This document lists all files needed for the ana R package and their purposes.

## Essential Package Files

### Configuration Files (Root Directory)

| File | Purpose | Required |
|------|---------|----------|
| `DESCRIPTION` | Package metadata, dependencies, version info | ✓ |
| `NAMESPACE` | Function exports and imports | ✓ |
| `LICENSE` | GPL-3 license text | ✓ |
| `README.md` | Package documentation for GitHub | ✓ |
| `.Rbuildignore` | Files to exclude from package build | ✓ |
| `.gitignore` | Files to exclude from git | Recommended |
| `NEWS.md` | Version history and changes | Recommended |
| `Makefile` | Build automation | Optional |

### R Source Files (R/ Directory)

| File | Purpose | Functions |
|------|---------|-----------|
| `ana.R` | Main analysis functions | `ana()`, `alook()`, `avar()` |
| `a_survival_time.R` | Enhanced survival time calculation | `a_survival_time_improved()` |
| `a_survival_time_table.R` | data.table optimized version | `a_survival_time_dt()` |
| `a_survival_time_C++.R` | Rcpp optimized version | `a_survival_time_rcpp()` |
| `a_survival_time_large.R` | Parallel processing version | `a_survival_time_parallel()` |
| `a_survival_time_ram.R` | Memory optimized version | `a_survival_time_memory()` |

### Documentation Files

| File/Directory | Purpose | Location |
|----------------|---------|----------|
| `man/ana.Rd` | Documentation for ana function | man/ |
| `man/a_survival_time_improved.Rd` | Documentation for survival functions | man/ |
| `inst/CITATION` | Citation information | inst/ |
| `vignettes/introduction.Rmd` | Long-form documentation | vignettes/ |

### Testing Files

| File | Purpose | Location |
|------|---------|----------|
| `tests/testthat.R` | Test runner configuration | tests/ |
| `tests/testthat/test-ana.R` | Unit tests for main functions | tests/testthat/ |

### Setup and Installation Files

| File | Purpose | Usage |
|------|---------|-------|
| `setup.R` | R script to create package structure | `source("setup.R")` |
| `setup.sh` | Shell script for Unix/Linux/Mac | `./setup.sh` |
| `INSTALL.md` | Detailed installation instructions | Documentation |
| `FILE_LIST.md` | This file - lists all package files | Documentation |

## Directory Structure

```
ana/
├── DESCRIPTION              # Package metadata
├── NAMESPACE               # Exports and imports
├── LICENSE                 # GPL-3 license
├── README.md              # Package documentation
├── NEWS.md                # Version history
├── .Rbuildignore          # Build exclusions
├── .gitignore             # Git exclusions
├── Makefile               # Build automation
├── INSTALL.md             # Installation guide
├── FILE_LIST.md           # This file
├── setup.R                # Setup script (R)
├── setup.sh               # Setup script (shell)
│
├── R/                     # R source code
│   ├── ana.R
│   ├── a_survival_time.R
│   ├── a_survival_time_table.R
│   ├── a_survival_time_C++.R
│   ├── a_survival_time_large.R
│   └── a_survival_time_ram.R
│
├── man/                   # Documentation
│   ├── ana.Rd
│   └── a_survival_time_improved.Rd
│
├── inst/                  # Installed files
│   └── CITATION
│
├── tests/                 # Unit tests
│   ├── testthat.R
│   └── testthat/
│       └── test-ana.R
│
├── vignettes/            # Long-form docs
│   └── introduction.Rmd
│
└── data/                 # Example data (optional)
```

## File Creation Checklist

Use this checklist to ensure all files are properly created:

- [ ] Create main directory: `ana/`
- [ ] Create subdirectories: `R/`, `man/`, `inst/`, `tests/testthat/`, `vignettes/`
- [ ] Copy configuration files to root directory
- [ ] Move all `.R` files to `R/` directory
- [ ] Copy documentation files to `man/`
- [ ] Copy `CITATION` to `inst/`
- [ ] Copy test files to `tests/`
- [ ] Copy vignette to `vignettes/`

## Quick Commands

### Create all directories at once:
```bash
mkdir -p ana/{R,man,inst,tests/testthat,vignettes,data}
```

### Move all R files:
```bash
mv *.R ana/R/
```

### Copy configuration files:
```bash
cp DESCRIPTION NAMESPACE LICENSE README.md NEWS.md .Rbuildignore .gitignore ana/
```

## Verification

After setting up, verify the structure:

```r
# In R, check package structure
list.files("ana", recursive = TRUE)

# Check if package can be built
devtools::check("ana")
```

## Notes

1. All R source code MUST be in the `R/` directory
2. The `DESCRIPTION` and `NAMESPACE` files are essential
3. Documentation in `man/` can be auto-generated using roxygen2
4. Test files are optional but highly recommended
5. The setup scripts (`setup.R` and `setup.sh`) are helpers and should not be included in the final package