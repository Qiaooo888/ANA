# Makefile for ana R package

.PHONY: all clean install check build test document

# Default target
all: document build check install

# Clean previous builds
clean:
	rm -f ana_*.tar.gz
	rm -rf ana.Rcheck
	rm -rf man/*.Rd

# Generate documentation with roxygen2 (if using roxygen2 comments)
document:
	Rscript -e "devtools::document()"

# Build the package
build: clean
	R CMD build .

# Check the package
check: build
	R CMD check ana_*.tar.gz

# Install the package
install:
	R CMD INSTALL ana_*.tar.gz

# Run tests
test:
	Rscript -e "devtools::test()"

# Quick install for development (without full check)
quick-install:
	R CMD INSTALL .

# Create package structure
setup:
	mkdir -p R man inst tests/testthat vignettes data
	@echo "Package structure created"

# Install dependencies
deps:
	Rscript -e "install.packages(c('haven', 'ggplot2', 'dplyr', 'scales', 'knitr', 'rmarkdown', 'data.table', 'Rcpp', 'parallel', 'foreach', 'doParallel', 'testthat', 'devtools', 'roxygen2'))"

# Development install with devtools
dev-install:
	Rscript -e "devtools::install()"

# Load package for interactive development
dev-load:
	Rscript -e "devtools::load_all()"

# Run CRAN checks
cran-check:
	Rscript -e "devtools::check(cran = TRUE)"

# Build vignettes
vignettes:
	Rscript -e "devtools::build_vignettes()"

# Generate README from README.Rmd (if exists)
readme:
	Rscript -e "if(file.exists('README.Rmd')) rmarkdown::render('README.Rmd')"

# Submit to CRAN (dry run)
submit-cran:
	Rscript -e "devtools::submit_cran()"

# Help target
help:
	@echo "Available targets:"
	@echo "  all          - Document, build, check and install (default)"
	@echo "  clean        - Remove built files"
	@echo "  document     - Generate documentation"
	@echo "  build        - Build package"
	@echo "  check        - Check package"
	@echo "  install      - Install package"
	@echo "  test         - Run tests"
	@echo "  quick-install - Quick install without checks"
	@echo "  setup        - Create package directory structure"
	@echo "  deps         - Install all dependencies"
	@echo "  dev-install  - Development install with devtools"
	@echo "  dev-load     - Load package for development"
	@echo "  cran-check   - Run CRAN checks"
	@echo "  vignettes    - Build vignettes"
	@echo "  help         - Show this help message"