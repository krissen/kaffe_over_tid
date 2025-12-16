#!/usr/bin/env Rscript
# tid_per_kopp.R
# Kaffekok: logga i CSV (m:ss) + rapportera kvadratisk modell + PI + (Bayes i bakgrunden)

# ============================
# 0) Inställningar
# ============================
csv_path   <- "kaffedata.csv"
output_dir <- "output"
invisible(dir.create(output_dir, showWarnings = FALSE))

# Skriv jämförelser bara om modellerna är nära
report_model_comparison_if_close <- TRUE
close_threshold_aic  <- 2.0   # ΔAIC < 2 => "nära"
close_threshold_loo  <- 1.0   # |elpd_diff| < 1 => "nära" (grovt)

# ============================
# 1) Ladda delade bibliotek
# ============================
source("R/load_libs.R")

# ============================
# 2) Skapa ny CSV om den saknas
# ============================
initialize_csv_if_missing(csv_path)

# ============================
# 3) Läs CSV
# ============================
df <- load_coffee_data(csv_path)

# ============================
# 4) Klassisk modell: jämför linjär vs kvadratisk (rapportera bara kvadratisk)
# ============================
results <- fit_classical_models(df, report_model_comparison_if_close, close_threshold_aic)

cat("\n=== Klassisk modell (rapport) ===\n")
cat("Modell: kvadratisk (sek ~ koppar + koppar^2)\n")

if (results$report_comparison) {
  cat("Obs: modellerna är nära (ΔAIC < ", close_threshold_aic, "). Jämförelse:\n", sep = "")
  cat("AIC:\n"); print(results$AICs)
  cat("Modellstöd (AIC-vikt %):\n"); print(round(100 * results$wAIC, 1))
}

cat("\nPrognos 1–10 koppar (95% prediktionsintervall):\n")
print(as.data.frame(results$predictions_formatted), row.names = FALSE)

# Kolla monotonitet
pred_sec <- results$predictions$estimate
if (any(diff(pred_sec) < 0)) {
  cat("\n⚠ VARNING: Klassisk modell ger icke-monotona prediktioner\n")
  cat("  (fler koppar kan ge kortare tid - fysiskt orimligt)\n")
}

# ============================
# 5) Klassisk figur: punkter + PI-band + kurva
# ============================
grid_plot <- get_prediction_grid(df, results$model)
p1 <- create_classical_plot(df, grid_plot)
ggsave(file.path(output_dir, "klassisk_fit.png"), p1, width = 8, height = 5, dpi = 150)

# ============================
# 6) Bayes (bakgrund): LOO + PI (utan CI i vardagsoutput)
# ============================
bayes_predictions <- NULL
if (bayes_available()) {
  bayes_fit <- fit_bayes_models(df)
  bayes_predictions <- get_bayes_predictions(bayes_fit)

  cat("\n=== Bayes (bakgrund) ===\n")
  cat("Modell: kvadratisk (posterior)\n")

  if (report_model_comparison_if_close) {
    cmp <- bayes_fit$loo_compare
    if ("fit_lin" %in% rownames(cmp)) {
      elpd_diff_lin <- as.numeric(cmp["fit_lin", "elpd_diff"])
      if (is.finite(elpd_diff_lin) && abs(elpd_diff_lin) < close_threshold_loo) {
        cat("Obs: modellerna är nära i LOO (|elpd_diff| < ", close_threshold_loo, ").\n", sep = "")
        print(cmp)
        cat("Bayes modellvikter (%):\n")
        print(round(100 * bayes_fit$loo_weights, 1))
      }
    }
  }

  cat("\nBayes prognos 1–10 koppar (95% prediktivt intervall):\n")
  print(as.data.frame(bayes_predictions$predictions), row.names = FALSE)

  # Kolla monotonitet
  bayes_pred_sec <- bayes_predictions$predictions_sec$estimate
  if (all(diff(bayes_pred_sec) >= 0)) {
    cat("\n✓ Bayes-modellen ger monotona prediktioner\n")
  }

  # Bayes-figur
  bayes_plot_df <- get_bayes_plot_data(bayes_predictions)
  p2 <- create_bayes_plot(df, bayes_plot_df)
  ggsave(file.path(output_dir, "bayes_fit.png"), p2, width = 8, height = 5, dpi = 150)

  bayes_done <- TRUE
} else {
  message("\n(Bayes-del hoppad: installera rstanarm + loo för Bayes.)")
  bayes_done <- FALSE
}

# ============================
# 6b) Spara kombinerad prognos-CSV (samma format som appen)
# ============================
combined <- create_combined_predictions(results, bayes_predictions)
write_csv(combined, file.path(output_dir, "kaffe_prediktioner.csv"))

# ============================
# 7) Summering
# ============================
cat("\nSparat:\n")
cat("- ", csv_path, "\n", sep = "")
cat("- ", file.path(output_dir, "klassisk_fit.png"), "\n", sep = "")
cat("- ", file.path(output_dir, "kaffe_prediktioner.csv"), " (kombinerad export)\n", sep = "")
if (bayes_done) {
  cat("- ", file.path(output_dir, "bayes_fit.png"), "\n", sep = "")
}
