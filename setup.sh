#!/bin/bash
# setup.sh - Quick setup script for ana package (Unix/Linux/Mac)

echo "Setting up ana package structure..."

# Create directory structure
mkdir -p ana/{R,man,inst,tests/testthat,vignettes,data}

# Move R files
for file in ana.R a_survival_time*.R; do
    if [ -f "$file" ]; then
        cp "$file" ana/R/
        echo "Copied $file to ana/R/"
    fi
done

# Copy configuration files
for file in DESCRIPTION NAMESPACE LICENSE .Rbuildignore .gitignore README.md NEWS.md; do
    if [ -f "$file" ]; then
        cp "$file" ana/
        echo "Copied $file to ana/"
    fi
done

# Copy other files to appropriate locations
[ -f "CITATION" ] && cp CITATION ana/inst/ && echo "Copied CITATION to ana/inst/"
[ -f "Makefile" ] && cp Makefile ana/ && echo "Copied Makefile to ana/"
[ -f "tests/testthat.R" ] && cp tests/testthat.R ana/tests/ && echo "Copied testthat.R"
[ -f "tests/testthat/test-ana.R" ] && cp tests/testthat/test-ana.R ana/tests/testthat/
[ -f "vignettes/introduction.Rmd" ] && cp vignettes/introduction.Rmd ana/vignettes/

echo ""
echo "Package structure created successfully!"
echo ""
echo "Next steps:"
echo "1. cd ana"
echo "2. R CMD build ."
echo "3. R CMD INSTALL ana_1.0.0.tar.gz"
echo ""
echo "Or use R with devtools:"
echo "1. Open R in the ana directory"
echo "2. devtools::install()"

# Make the script executable
chmod +x setup.sh