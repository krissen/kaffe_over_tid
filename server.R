# server.R
# Server logic för Kaffekok-analys

server <- function(input, output, session) {

  # csv_path is defined in app.R before this file is sourced
  # This ensures consistency and follows DRY principle

  # Cache bayes_available() result (expensive requireNamespace calls)
  bayes_is_available <- bayes_available()

  # Reactive value to trigger data reload
  data_version <- reactiveVal(0)

  # Reactive value to store Bayes results
  bayes_result_val <- reactiveVal(NULL)

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

  # Fit classical model reactively (fast, runs synchronously)
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

  # ExtendedTask for async Bayes computation
  bayes_task <- ExtendedTask$new(function(df) {
    # Only pass the data frame - source functions in the worker
    future::future({
      # Load everything fresh in the worker process
      suppressPackageStartupMessages({
        library(rstanarm)
        library(loo)
        library(dplyr)
      })

      # Source utility functions in the worker
      source("R/time_utils.R")
      source("R/model_utils.R")

      bayes_fit <- fit_bayes_models(df)
      bayes_pred <- get_bayes_predictions(bayes_fit)
      list(
        fit = bayes_fit,
        predictions = bayes_pred
      )
    }, seed = TRUE, globals = list(df = df))
  })

  # Start Bayes computation when data is ready
  observe({
    df <- coffee_data()
    if (!is.null(df) && nrow(df) >= 5 && bayes_is_available) {
      # Only start if not already running
      if (bayes_task$status() %in% c("initial", "error")) {
        bayes_task$invoke(df)
      }
    }
  })

  # Store result when task completes
  observe({
    result <- bayes_task$result()
    if (!is.null(result)) {
      bayes_result_val(result)
      # Switch to Kombinerad tab
      updateTabsetPanel(session, "main_tabs", selected = "Kombinerad")
    }
  })

  # Reactive accessor for Bayes results
  bayes_results <- reactive({
    bayes_result_val()
  })

  # Handle add button click
  observeEvent(input$add_button, {
    tryCatch({
      # Validate and add entry
      add_coffee_entry(csv_path, input$cups_input, input$time_input)

      # Reset Bayes results and restart computation
      bayes_result_val(NULL)

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

  # Render Bayes plot
  output$bayes_plot <- renderPlot({
    df <- coffee_data()
    bayes <- bayes_results()

    if (is.null(df) || is.null(bayes)) return(NULL)

    bayes_plot_df <- get_bayes_plot_data(bayes$predictions)
    create_bayes_plot(df, bayes_plot_df)
  })

  # Render combined plot (classical + Bayes)
  output$combined_plot <- renderPlot({
    df <- coffee_data()
    results <- model_results()

    if (is.null(df) || is.null(results)) return(NULL)

    grid_plot <- get_prediction_grid(df, results$model)
    bayes <- bayes_results()
    bayes_plot_df <- if (!is.null(bayes)) get_bayes_plot_data(bayes$predictions) else NULL

    create_combined_plot(df, grid_plot, bayes_plot_df)
  })

  # Render classical predictions table
  output$predictions_table_klassisk <- renderTable({
    results <- model_results()
    if (is.null(results)) return(NULL)

    results$predictions_formatted %>%
      dplyr::rename(
        Koppar = cups,
        Estimat = estimate,
        `PI95 nedre` = PI95_low,
        `PI95 övre` = PI95_high
      )
  }, striped = TRUE, hover = TRUE)

  # Render Bayes predictions table
  output$predictions_table_bayes <- renderTable({
    bayes <- bayes_results()
    if (is.null(bayes)) return(NULL)

    bayes$predictions$predictions %>%
      dplyr::rename(
        Koppar = cups,
        Estimat = estimate,
        `PI95 nedre` = PI95_low,
        `PI95 övre` = PI95_high
      )
  }, striped = TRUE, hover = TRUE)

  # Check if Bayes is available and completed
  output$bayes_available <- reactive({
    bayes_is_available && !is.null(bayes_results())
  })
  outputOptions(output, "bayes_available", suspendWhenHidden = FALSE)

  # Check if Bayes is currently loading (or about to start)
  output$bayes_loading <- reactive({
    df <- coffee_data()
    has_data <- !is.null(df) && nrow(df) >= 5
    not_done <- is.null(bayes_results())
    status <- bayes_task$status()
    is_loading <- status %in% c("initial", "running")
    bayes_is_available && has_data && not_done && is_loading
  })
  outputOptions(output, "bayes_loading", suspendWhenHidden = FALSE)

  # Render model info
  output$model_info <- renderText({
    results <- model_results()
    bayes <- bayes_results()
    if (is.null(results)) return("Ingen modell tillgänglig")

    info <- paste0(
      "=== KLASSISK MODELL ===\n",
      "Modell: Kvadratisk regression (sek ~ koppar + koppar^2)\n\n",
      "AIC-värden:\n",
      "  Linjär: ", round(results$AICs["linear"], 2), "\n",
      "  Kvadratisk: ", round(results$AICs["quadratic"], 2), "\n\n",
      "ΔAIC (från bäst):\n",
      "  Linjär: ", round(results$dAIC["linear"], 2), "\n",
      "  Kvadratisk: ", round(results$dAIC["quadratic"], 2), "\n\n",
      "Modellvikter (AIC):\n",
      "  Linjär: ", round(100 * results$wAIC["linear"], 1), "%\n",
      "  Kvadratisk: ", round(100 * results$wAIC["quadratic"], 1), "%\n"
    )

    if (results$report_comparison) {
      info <- paste0(info, "\nOBS: Modellerna är nära varandra (ΔAIC < 2.0)\n")
    }

    # Check for non-monotonicity in classical model
    pred_sec <- results$predictions$estimate
    if (any(diff(pred_sec) < 0)) {
      info <- paste0(info, "\n⚠ VARNING: Klassisk modell ger icke-monotona prediktioner\n",
                     "  (fler koppar kan ge kortare tid - fysiskt orimligt)\n")
    }

    # Add Bayes info if available
    if (!is.null(bayes)) {
      info <- paste0(info, "\n\n=== BAYES-MODELL ===\n",
                     "Modell: Kvadratisk Bayesiansk regression (stan_glm)\n\n")

      cmp <- bayes$fit$loo_compare
      if ("fit_lin" %in% rownames(cmp)) {
        elpd_diff <- as.numeric(cmp["fit_lin", "elpd_diff"])
        info <- paste0(info, "LOO-jämförelse:\n",
                       "  elpd_diff (linjär vs kvadratisk): ", round(elpd_diff, 2), "\n\n")
      }

      info <- paste0(info, "Bayes modellvikter:\n",
                     "  Linjär: ", round(100 * bayes$fit$loo_weights["lin"], 1), "%\n",
                     "  Kvadratisk: ", round(100 * bayes$fit$loo_weights["quad"], 1), "%\n")

      # Check monotonicity
      bayes_pred_sec <- bayes$predictions$predictions_sec$estimate
      if (all(diff(bayes_pred_sec) >= 0)) {
        info <- paste0(info, "\n✓ Bayes-modellen ger monotona prediktioner\n")
      }
    } else if (bayes_is_available && bayes_task$status() %in% c("initial", "running")) {
      info <- paste0(info, "\n\n(Bayes-modell beräknas i bakgrunden...)\n")
    } else if (!bayes_is_available) {
      info <- paste0(info, "\n\n(Bayes ej tillgängligt - installera rstanarm + loo)\n")
    }

    info
  })

  # Download handler for combined predictions
  output$download_predictions <- downloadHandler(
    filename = function() {
      paste0("kaffe_prediktioner_", Sys.Date(), ".csv")
    },
    content = function(file) {
      results <- model_results()
      bayes <- bayes_results()

      if (!is.null(results)) {
        bayes_pred <- if (!is.null(bayes)) bayes$predictions else NULL
        combined <- create_combined_predictions(results, bayes_pred)
        readr::write_csv(combined, file)
      }
    }
  )
}
