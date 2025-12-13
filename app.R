#!/usr/bin/env Rscript
# app.R
# Shiny app för kaffekok-analys med stöd för att lägga till ny data

# ============================
# Setup
# ============================
cat("Laddar bibliotek...\n")

app_dir <- getwd()

tryCatch({
  source("R/load_libs.R")
  cat("Delade bibliotek laddade.\n")
}, error = function(e) {
  cat("FEL vid laddning av delade bibliotek:\n")
  cat(e$message, "\n")
  quit(status = 1)
})

# Additional packages for Shiny
shiny_pkgs <- c("shiny")
install_if_missing(shiny_pkgs)

suppressPackageStartupMessages({
  library(shiny)
})
cat("Shiny laddat.\n")

csv_path <- "kaffedata.csv"

# Initialize CSV if missing
initialize_csv_if_missing(csv_path)
cat("Data initierad.\n")

# ============================
# Load UI and Server
# ============================
source("ui.R")
source("server.R")

# ============================
# Run app with auto-open browser
# ============================
# Function to open browser
open_browser <- function(url) {
  # URL validation pattern: only allow localhost addresses
  localhost_url_pattern <- "^https?://(127\\.0\\.0\\.1|localhost)(:[0-9]+)?(/.*)?$"
  
  if (!grepl(localhost_url_pattern, url)) {
    warning("Invalid URL format (must be localhost): ", url)
    return(FALSE)
  }
  
  tryCatch({
    if (Sys.info()["sysname"] == "Darwin") {
      # macOS: use 'open' command with system2 for better security
      system2("open", args = url, wait = FALSE, stdout = FALSE, stderr = FALSE)
    } else if (Sys.info()["sysname"] == "Linux") {
      # Linux: use 'xdg-open' command with system2 for better security
      system2("xdg-open", args = url, wait = FALSE, stdout = FALSE, stderr = FALSE)
    } else if (Sys.info()["sysname"] == "Windows") {
      # Windows: use shell.exec (already validated above)
      shell.exec(url)
    }
  }, error = function(e) {
    warning("Could not open browser: ", e$message)
  })
}

# Check if running from Rscript (non-interactive)
if (!interactive()) {
  # Get host and port
  port <- 3838
  host <- "127.0.0.1"
  
  cat("Startar Shiny-appen...\n")
  cat("URL: http://", host, ":", port, "\n", sep = "")
  
  # Set options for browser launch
  options(shiny.launch.browser = function(url) {
    cat("Öppnar webbläsare: ", url, "\n", sep = "")
    Sys.sleep(1)  # Give server a moment to start
    open_browser(url)
  })
  
  # Run the app
  runApp(
    appDir = ".",
    host = host,
    port = port,
    launch.browser = TRUE
  )
} else {
  # When sourced interactively, just return the app
  shinyApp(ui = ui, server = server)
}
