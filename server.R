# server.R
# Server logic för Kaffekok-analys

server <- function(input, output, session) {
  
  csv_path <- "kaffedata.csv"
  
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
        readr::write_csv(results$predictions_formatted, file)
      }
    }
  )
}
