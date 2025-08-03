#!/usr/bin/env Rscript
# setup.R - Quick setup script for ana package
# Run this script to set up the proper package structure

cat("Setting up ana package structure...\n")

# Create directory structure
dirs <- c("ana", "ana/R", "ana/man", "ana/inst", 
          "ana/tests/testthat", "ana/vignettes", "ana/data")

for (dir in dirs) {
  if (!dir.exists(dir)) {
    dir.create(dir, recursive = TRUE)
    cat("Created directory:", dir, "\n")
  }
}

# List of R source files to move
r_files <- c(
  "ana.R",
  "a_survival_time.R",
  "a_survival_time_table.R",
  "a_survival_time_C++.R",
  "a_survival_time_large.R",
  "a_survival_time_ram.R"
)

# Move R files to R directory
for (file in r_files) {
  if (file.exists(file)) {
    file.copy(file, file.path("ana/R", file), overwrite = TRUE)
    cat("Copied", file, "to ana/R/\n")
  } else {
    cat("Warning:", file, "not found\n")
  }
}

# Copy configuration files
config_files <- list(
  "DESCRIPTION" = "ana/DESCRIPTION",
  "NAMESPACE" = "ana/NAMESPACE",
  "LICENSE" = "ana/LICENSE",
  ".Rbuildignore" = "ana/.Rbuildignore",
  ".gitignore" = "ana/.gitignore",
  "README.md" = "ana/README.md",
  "NEWS.md" = "ana/NEWS.md"
)

for (src in names(config_files)) {
  dest <- config_files[[src]]
  if (file.exists(src)) {
    file.copy(src, dest, overwrite = TRUE)
    cat("Copied", src, "to", dest, "\n")
  } else {
    cat("Warning:", src, "not found\n")
  }
}

# Create inst/CITATION if CITATION file exists
if (file.exists("CITATION")) {
  file.copy("CITATION", "ana/inst/CITATION", overwrite = TRUE)
  cat("Copied CITATION to ana/inst/\n")
}

# Copy test files if they exist
if (file.exists("tests/testthat.R")) {
  file.copy("tests/testthat.R", "ana/tests/testthat.R", overwrite = TRUE)
}
if (file.exists("tests/testthat/test-ana.R")) {
  file.copy("tests/testthat/test-ana.R", "ana/tests/testthat/test-ana.R", overwrite = TRUE)
}

# Copy vignette if it exists
if (file.exists("vignettes/introduction.Rmd")) {
  file.copy("vignettes/introduction.Rmd", "ana/vignettes/introduction.Rmd", overwrite = TRUE)
}

# Copy Makefile if it exists
if (file.exists("Makefile")) {
  file.copy("Makefile", "ana/Makefile", overwrite = TRUE)
}

cat("\nPackage structure created successfully!\n")
cat("\nNext steps:\n")
cat("1. Change to the ana directory: setwd('ana')\n")
cat("2. Install dependencies:\n")
cat("   install.packages(c('devtools', 'roxygen2', 'testthat'))\n")
cat("3. Build and install the package:\n")
cat("   devtools::install()\n")
cat("   # OR\n")
cat("   R CMD build .\n")
cat("   R CMD INSTALL ana_1.0.0.tar.gz\n")
cat("\nFor quick testing without installation:\n")
cat("   devtools::load_all()\n")

# Check for missing dependencies
cat("\nChecking dependencies...\n")
required_pkgs <- c("haven", "ggplot2", "dplyr", "scales", 
                   "knitr", "rmarkdown", "devtools")
missing_pkgs <- required_pkgs[!required_pkgs %in% installed.packages()[,"Package"]]

if (length(missing_pkgs) > 0) {
  cat("Missing required packages:", paste(missing_pkgs, collapse = ", "), "\n")
  cat("Install them with:\n")
  cat("install.packages(c(", paste0('"', missing_pkgs, '"', collapse = ", "), "))\n")
} else {
  cat("All required dependencies are installed.\n")
}

cat("\nSetup complete!\n")