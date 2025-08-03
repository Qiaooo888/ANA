\name{a_survival_time_improved}
\alias{a_survival_time_improved}
\alias{a_survival_time_dt}
\alias{a_survival_time_rcpp}
\alias{a_survival_time_parallel}
\alias{a_survival_time_memory}
\title{Calculate Survival Time from Longitudinal Data}
\description{
  Family of functions to calculate survival time from longitudinal data with multiple
  observations per individual. Multiple optimized implementations are provided for
  different use cases and performance requirements.
}
\usage{
a_survival_time_improved(data, id_var, time = "", event = "", 
                        check_order = TRUE, verbose = TRUE,
                        handle_negative_time = TRUE)

a_survival_time_dt(data, id_var, time = "", event = "", verbose = FALSE)

a_survival_time_rcpp(data, id_var, time = "", event = "")

a_survival_time_parallel(data, id_var, time = "", event = "", n_cores = NULL)

a_survival_time_memory(data, id_var, time = "", event = "")
}
\arguments{
  \item{data}{
    Data frame containing longitudinal data with multiple observations per individual.
  }
  \item{id_var}{
    Character string specifying the column name for individual/subject identifier.
  }
  \item{time}{
    Character string specifying the column name for time variable.
  }
  \item{event}{
    Character string specifying the column name for event indicator (0 = no event, 1 = event).
  }
  \item{check_order}{
    Logical. If TRUE, checks temporal ordering of observations (improved version only).
  }
  \item{verbose}{
    Logical. If TRUE, prints warnings and progress messages.
  }
  \item{handle_negative_time}{
    Logical. If TRUE, handles negative time values appropriately (improved version only).
  }
  \item{n_cores}{
    Integer. Number of CPU cores to use for parallel processing. If NULL, 
    automatically detects available cores (parallel version only).
  }
}
\details{
  The functions calculate survival time as follows:
  \itemize{
    \item For each individual, identifies the first observation time
    \item If an event occurs, calculates time from first observation to event
    \item All observations after the event receive the same survival time
    \item For censored individuals (no event), calculates time from first to current observation
  }
  
  \strong{Performance characteristics:}
  \itemize{
    \item \code{a_survival_time_improved}: Base implementation with full error checking
    \item \code{a_survival_time_dt}: 5-10x faster using data.table
    \item \code{a_survival_time_rcpp}: 10-20x faster using C++
    \item \code{a_survival_time_parallel}: Best for very large datasets with many individuals
    \item \code{a_survival_time_memory}: Optimized for memory-constrained environments
  }
}
\value{
  Returns the input data frame with an additional column:
  \item{Survival_time}{Calculated survival time for each observation}
}
\examples{
# Create example longitudinal data
set.seed(123)
survival_data <- data.frame(
  patient_id = rep(1:100, each = 5),
  visit_time = rep(0:4, 100) + runif(500, -0.1, 0.1),
  event = rbinom(500, 1, 0.1)
)

# Basic usage
result <- a_survival_time_improved(survival_data,
                                  id_var = "patient_id",
                                  time = "visit_time",
                                  event = "event")

# View results for first patient
subset(result, patient_id == 1)

\dontrun{
# Use faster implementations for large datasets
# data.table version (requires data.table package)
result_dt <- a_survival_time_dt(survival_data,
                               id_var = "patient_id",
                               time = "visit_time",
                               event = "event")

# C++ version (requires Rcpp package)
result_rcpp <- a_survival_time_rcpp(survival_data,
                                   id_var = "patient_id",
                                   time = "visit_time",
                                   event = "event")

# Parallel version for very large datasets
large_data <- data.frame(
  id = rep(1:10000, each = 10),
  time = rep(0:9, 10000) + runif(100000, -0.1, 0.1),
  event = rbinom(100000, 1, 0.05)
)

result_parallel <- a_survival_time_parallel(large_data,
                                           id_var = "id",
                                           time = "time",
                                           event = "event",
                                           n_cores = 4)
}
}
\note{
  \itemize{
    \item Missing values in time or event variables are handled appropriately
    \item The functions expect event to be coded as 0/1, but will issue warnings for other values
    \item For best performance with large datasets (>100,000 rows), use the Rcpp or data.table versions
    \item The parallel version is most beneficial when you have many individuals (>1000)
  }
}
\author{
  Package maintainer: Your Name <your.email@example.com>
}
\seealso{
  \code{\link{survival}} package for traditional survival analysis,
  \code{\link{ana}} for general data analysis
}
\keyword{survival}
\keyword{longitudinal}