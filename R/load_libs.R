# load_libs.R
# Load all shared libraries and required packages

#' Install packages if missing
#' @param pkgs Character vector of package names
install_if_missing <- function(pkgs) {
  miss <- pkgs[!vapply(pkgs, requireNamespace, logical(1), quietly = TRUE)]
  if (length(miss)) install.packages(miss, repos = "https://cloud.r-project.org")
}

# Install and load required packages
need <- c("ggplot2", "dplyr", "readr", "tibble")
install_if_missing(need)

suppressPackageStartupMessages({
  library(ggplot2)
  library(dplyr)
  library(readr)
  library(tibble)
})

# Source all utility files
# Find R directory relative to current working directory
if (dir.exists("R")) {
  r_dir <- "R"
} else if (exists("app_dir") && dir.exists(file.path(app_dir, "R"))) {
  # Try to use app_dir if it was set before sourcing
  r_dir <- file.path(app_dir, "R")
} else {
  stop("Cannot find R/ directory with shared libraries. Make sure to run from the project root directory.")
}

source(file.path(r_dir, "time_utils.R"))
source(file.path(r_dir, "data_utils.R"))
source(file.path(r_dir, "model_utils.R"))
source(file.path(r_dir, "plot_utils.R"))
