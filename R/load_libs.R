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
script_dir <- if (exists("app_dir")) {
  app_dir
} else {
  dirname(sys.frame(1)$ofile)
}

if (is.null(script_dir) || script_dir == "") {
  script_dir <- getwd()
}

# Find R directory (could be in current dir or parent)
if (dir.exists(file.path(script_dir, "R"))) {
  r_dir <- file.path(script_dir, "R")
} else if (dir.exists("R")) {
  r_dir <- "R"
} else {
  stop("Cannot find R/ directory with shared libraries")
}

source(file.path(r_dir, "time_utils.R"))
source(file.path(r_dir, "data_utils.R"))
source(file.path(r_dir, "model_utils.R"))
source(file.path(r_dir, "plot_utils.R"))
