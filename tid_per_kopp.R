#!/usr/bin/env Rscript
# tid_per_kopp.R
# Kaffekok: logga i CSV (m:ss) + rapportera kvadratisk modell + PI + (Bayes i bakgrunden)

# ============================
# 0) Inställningar
# ============================
csv_path <- "kaffedata.csv"
fig_dir  <- "fig"
invisible(dir.create(fig_dir, showWarnings = FALSE))

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

# Spara prognos-CSV
write_csv(results$predictions_formatted, "pred_klassisk_1_10.csv")

# ============================
# 5) Klassisk figur: punkter + PI-band + kurva
# ============================
grid_plot <- get_prediction_grid(df, results$model)
p1 <- create_classical_plot(df, grid_plot)
ggsave(file.path(fig_dir, "klassisk_fit.png"), p1, width = 8, height = 5, dpi = 150)

# ============================
# 6) Bayes (bakgrund): LOO + PI (utan CI i vardagsoutput)
# ============================
# Bayes (valfritt)
bayes_need <- c("rstanarm", "loo")
bayes_available <- all(vapply(bayes_need, requireNamespace, logical(1), quietly = TRUE))

if (bayes_available) {
  suppressPackageStartupMessages({
    library(rstanarm)
    library(loo)
  })

  options(mc.cores = max(1, parallel::detectCores() - 1))

  prior_beta  <- rstanarm::normal(location = 0, scale = 2.5, autoscale = TRUE)
  prior_sigma <- rstanarm::exponential(rate = 1, autoscale = TRUE)

  fit_b_lin <- stan_glm(
    sec ~ cups, data = df, family = gaussian(),
    prior = prior_beta, prior_intercept = prior_beta, prior_aux = prior_sigma,
    chains = 4, iter = 2000, refresh = 0
  )

  fit_b_quad <- stan_glm(
    sec ~ poly(cups, 2, raw = TRUE), data = df, family = gaussian(),
    prior = prior_beta, prior_intercept = prior_beta, prior_aux = prior_sigma,
    chains = 4, iter = 2000, refresh = 0
  )

  loo_lin  <- loo(fit_b_lin,  k_threshold = 0.7)
  loo_quad <- loo(fit_b_quad, k_threshold = 0.7)

  cmp <- loo_compare(loo_lin, loo_quad)
  w_loo <- loo_model_weights(list(lin = loo_lin, quad = loo_quad), method = "pseudobma")

  # Prediktivt intervall för nästa mätning
  new <- tibble(cups = 1:10)
  yrep <- posterior_predict(fit_b_quad, newdata = new)

  bayes_PI <- tibble(
    cups = new$cups,
    PI_med  = apply(yrep, 2, median),
    PI95_low = apply(yrep, 2, quantile, probs = 0.025),
    PI95_high= apply(yrep, 2, quantile, probs = 0.975)
  ) %>%
    mutate(
      PI_med   = fmt_time(PI_med),
      PI95_low = fmt_time(PI95_low),
      PI95_high= fmt_time(PI95_high)
    )

  write_csv(bayes_PI, "pred_bayes_1_10.csv")

  cat("\n=== Bayes (bakgrund) ===\n")
  cat("Modell: kvadratisk (posterior)\n")

  if (report_model_comparison_if_close) {
    # om linjär är "nära" enligt elpd_diff (grovt)
    # cmp: bäst har elpd_diff = 0; andra negativ
    # vi hittar "fit_b_lin" om den finns
    if ("fit_b_lin" %in% rownames(cmp)) {
      elpd_diff_lin <- as.numeric(cmp["fit_b_lin", "elpd_diff"])
      if (is.finite(elpd_diff_lin) && abs(elpd_diff_lin) < close_threshold_loo) {
        cat("Obs: modellerna är nära i LOO (|elpd_diff| < ", close_threshold_loo, ").\n", sep = "")
        print(cmp)
        cat("Bayes modellvikter (%):\n")
        print(round(100 * w_loo, 1))
      }
    }
  }

  cat("\nBayes prognos 1–10 koppar (95% prediktivt intervall):\n")
  print(as.data.frame(bayes_PI), row.names = FALSE)

  # Bayes-figur: PI-band + medianlinje
  bayes_plot_df <- bayes_PI %>%
    mutate(
      PI_med_sec  = vapply(PI_med, parse_time, numeric(1)),
      PI_low_sec  = vapply(PI95_low, parse_time, numeric(1)),
      PI_high_sec = vapply(PI95_high, parse_time, numeric(1))
    )

  p2 <- ggplot() +
    geom_point(data = df, aes(x = cups, y = sec), size = 2) +
    geom_ribbon(data = bayes_plot_df, aes(x = cups, ymin = PI_low_sec, ymax = PI_high_sec), alpha = 0.20) +
    geom_line(data = bayes_plot_df, aes(x = cups, y = PI_med_sec), linewidth = 1) +
    labs(
      title = "Bayes: tid vs koppar",
      subtitle = "95% prediktivt intervall (posterior predictive).",
      x = "Antal koppar", y = "Tid (sek)"
    )

  ggsave(file.path(fig_dir, "bayes_fit.png"), p2, width = 8, height = 5, dpi = 150)
} else {
  message("\n(Bayes-del hoppad: installera rstanarm + loo för Bayes.)")
}

# ============================
# 7) Summering
# ============================
cat("\nSparat:\n")
cat("- ", csv_path, "\n", sep = "")
cat("- ", file.path(fig_dir, "klassisk_fit.png"), "\n", sep = "")
if (bayes_available) cat("- ", file.path(fig_dir, "bayes_fit.png"), "\n", sep = "")
cat("- pred_klassisk_1_10.csv\n")
if (bayes_available) cat("- pred_bayes_1_10.csv\n")
