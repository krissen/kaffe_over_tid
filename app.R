#!/usr/bin/env Rscript
# app.R
# Shiny app för kaffekok-analys med stöd för att lägga till ny data

# ============================
# Setup
# ============================
app_dir <- getwd()
source("R/load_libs.R")

# Additional packages for Shiny
shiny_pkgs <- c("shiny")
install_if_missing(shiny_pkgs)
library(shiny)

csv_path <- "kaffedata.csv"

# Initialize CSV if missing
initialize_csv_if_missing(csv_path)

# ============================
# UI
# ============================
ui <- fluidPage(
  titlePanel("Kaffekok: Tid per Kopp"),
  
  sidebarLayout(
    sidebarPanel(
      h3("Lägg till ny data"),
      numericInput("cups_input", "Antal koppar:", value = 3, min = 1, max = 20),
      textInput("time_input", "Tid (m:ss):", value = "3:00", placeholder = "Ex: 3:30"),
      actionButton("add_button", "Lägg till", class = "btn-primary"),
      hr(),
      p("Tidsformat: minuter:sekunder (ex: 3:30 för 3 min 30 sek)"),
      p("Accepterar också format som 3'30, 3:30, etc."),
      hr(),
      h4("Datatabell"),
      tableOutput("data_table")
    ),
    
    mainPanel(
      tabsetPanel(
        tabPanel("Plot", 
                 plotOutput("classical_plot", height = "500px"),
                 hr(),
                 h4("Tolkning:"),
                 p("Punkterna visar faktiska mätningar."),
                 p("Linjen visar modellens prediktion (kvadratisk modell)."),
                 p("Det skuggade området visar 95% prediktionsintervall - där nästa mätning förväntas ligga.")
        ),
        tabPanel("Prediktioner",
                 h3("Prognoser 1-10 koppar"),
                 tableOutput("predictions_table"),
                 hr(),
                 downloadButton("download_predictions", "Ladda ner CSV")
        ),
        tabPanel("Modellinfo",
                 h3("Modellinformation"),
                 verbatimTextOutput("model_info")
        )
      )
    )
  )
)

# ============================
# Server
# ============================
server <- function(input, output, session) {
  
  # Reactive value to trigger data reload
  data_version <- reactiveVal(0)
  
  # Load data reactively
  coffee_data <- reactive({
    data_version()  # Depend on this to trigger reload
    tryCatch({
      load_coffee_data(csv_path)
    }, error = function(e) {
      showNotification(paste("Fel vid laddning av data:", e$message), type = "error")
      NULL
    })
  })
  
  # Fit model reactively
  model_results <- reactive({
    df <- coffee_data()
    if (is.null(df) || nrow(df) < 5) return(NULL)
    
    tryCatch({
      fit_classical_models(df, report_model_comparison_if_close = TRUE, close_threshold_aic = 2.0)
    }, error = function(e) {
      showNotification(paste("Fel vid modellering:", e$message), type = "error")
      NULL
    })
  })
  
  # Handle add button click
  observeEvent(input$add_button, {
    tryCatch({
      # Validate and add entry
      add_coffee_entry(csv_path, input$cups_input, input$time_input)
      
      # Increment version to trigger reload
      data_version(data_version() + 1)
      
      # Show success message
      showNotification(
        paste("Tillagt:", input$cups_input, "koppar,", input$time_input),
        type = "message"
      )
      
      # Clear input (optional)
      updateTextInput(session, "time_input", value = "")
      
    }, error = function(e) {
      showNotification(paste("Fel:", e$message), type = "error")
    })
  })
  
  # Render data table
  output$data_table <- renderTable({
    df <- coffee_data()
    if (is.null(df)) return(NULL)
    
    df %>%
      select(cups, t) %>%
      rename(Koppar = cups, Tid = t)
  }, striped = TRUE, hover = TRUE)
  
  # Render classical plot
  output$classical_plot <- renderPlot({
    df <- coffee_data()
    results <- model_results()
    
    if (is.null(df) || is.null(results)) return(NULL)
    
    grid_plot <- get_prediction_grid(df, results$model)
    create_classical_plot(df, grid_plot)
  })
  
  # Render predictions table
  output$predictions_table <- renderTable({
    results <- model_results()
    if (is.null(results)) return(NULL)
    
    results$predictions_formatted %>%
      rename(
        Koppar = cups,
        Estimat = estimate,
        `PI95 nedre` = PI95_low,
        `PI95 övre` = PI95_high
      )
  }, striped = TRUE, hover = TRUE)
  
  # Render model info
  output$model_info <- renderText({
    results <- model_results()
    if (is.null(results)) return("Ingen modell tillgänglig")
    
    info <- paste0(
      "Modell: Kvadratisk regression (sek ~ koppar + koppar^2)\n\n",
      "AIC-värden:\n",
      "  Linjär: ", round(results$AICs["linear"], 2), "\n",
      "  Kvadratisk: ", round(results$AICs["quadratic"], 2), "\n\n",
      "ΔAIC (från bäst):\n",
      "  Linjär: ", round(results$dAIC["linear"], 2), "\n",
      "  Kvadratisk: ", round(results$dAIC["quadratic"], 2), "\n\n",
      "Modellvikter (AIC):\n",
      "  Linjär: ", round(100 * results$wAIC["linear"], 1), "%\n",
      "  Kvadratisk: ", round(100 * results$wAIC["quadratic"], 1), "%\n\n"
    )
    
    if (results$report_comparison) {
      info <- paste0(info, "OBS: Modellerna är nära varandra (ΔAIC < 2.0)\n")
    }
    
    info
  })
  
  # Download handler for predictions
  output$download_predictions <- downloadHandler(
    filename = function() {
      paste0("kaffe_prediktioner_", Sys.Date(), ".csv")
    },
    content = function(file) {
      results <- model_results()
      if (!is.null(results)) {
        write_csv(results$predictions_formatted, file)
      }
    }
  )
}

# ============================
# Run app with auto-open browser
# ============================
# Function to open browser on macOS
open_browser <- function(url) {
  # Validate URL is properly formatted (localhost/IP with port)
  if (!grepl("^https?://[a-zA-Z0-9\\.:-]+(/.*)?$", url)) {
    warning("Invalid URL format: ", url)
    return(FALSE)
  }
  
  tryCatch({
    if (Sys.info()["sysname"] == "Darwin") {
      # macOS: use 'open' command
      system(paste("open", shQuote(url)), wait = FALSE)
    } else if (Sys.info()["sysname"] == "Linux") {
      # Linux: use 'xdg-open' command
      system(paste("xdg-open", shQuote(url)), wait = FALSE)
    } else if (Sys.info()["sysname"] == "Windows") {
      # Windows: use shell.exec (validate first)
      if (grepl("^https?://127\\.0\\.0\\.1:[0-9]+$", url)) {
        shell.exec(url)
      }
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
    list(ui = ui, server = server),
    host = host,
    port = port,
    launch.browser = TRUE
  )
} else {
  # When sourced interactively, just return the app
  shinyApp(ui = ui, server = server)
}
