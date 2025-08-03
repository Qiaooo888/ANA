\name{ana}
\alias{ana}
\title{Basic Data Analysis Function}
\description{
  Performs comprehensive descriptive statistics and basic analysis on specified variables
  in a data frame. Automatically detects variable types and provides appropriate
  summary statistics.
}
\usage{
ana(data_name, ...)
}
\arguments{
  \item{data_name}{
    A data frame containing the variables to analyze.
  }
  \item{...}{
    Character strings specifying variable names to analyze. If omitted,
    automatically selects up to 10 suitable variables.
  }
}
\details{
  The function performs the following analyses:
  \itemize{
    \item Variable type detection (numeric, factor, character, logical, date)
    \item Missing value analysis with counts and percentages
    \item Descriptive statistics for numeric variables (mean, median, SD, min, max)
    \item Frequency tables for categorical variables
    \item Special value detection (Inf, NaN) for numeric variables
  }
  
  The function automatically handles haven labeled variables by converting them
  to standard R types.
}
\value{
  Invisibly returns a list containing:
  \item{基本信息}{Data frame with basic information about analyzed variables}
  \item{数据集}{Name of the input dataset}
  \item{变量数}{Number of variables analyzed}
  \item{状态}{Analysis status}
}
\examples{
# Basic usage with iris dataset
data(iris)

# Analyze specific variables
ana(iris, "Sepal.Length", "Species")

# Analyze all suitable variables (auto-select)
ana(iris)

# Create sample data with missing values
test_data <- data.frame(
  numeric_var = c(1.5, 2.3, NA, 4.1, 5.0),
  factor_var = factor(c("A", "B", "A", NA, "B")),
  char_var = c("hello", "world", NA, "test", "data")
)

# Analyze the test data
ana(test_data)
}
\author{
  Package maintainer: Your Name <your.email@example.com>
}
\seealso{
  \code{\link{alook}} for visualization analysis,
  \code{\link{avar}} for all variables overview
}
\keyword{univar}
\keyword{analysis}