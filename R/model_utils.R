# model_utils.R
# Shared functions for modeling

#' Fit classical models (linear and quadratic) and return predictions
#' @param df Data frame with cups and sec columns
#' @param report_model_comparison_if_close Whether to report model comparison
#' @param close_threshold_aic AIC threshold for "close" models
#' @return List with model, predictions, and comparison info
fit_classical_models <- function(df, report_model_comparison_if_close = TRUE, close_threshold_aic = 2.0) {
  # Fit models
  m_lin  <- lm(sec ~ cups, data = df)
  m_quad <- lm(sec ~ poly(cups, 2, raw = TRUE), data = df)

  # Model comparison
  AICs <- c(linear = AIC(m_lin), quadratic = AIC(m_quad))
  dAIC <- AICs - min(AICs)
  wAIC <- exp(-0.5 * dAIC) / sum(exp(-0.5 * dAIC))
  delta_best <- sort(dAIC)[2]  # näst-bäst mot bäst

  # Use quadratic model
  model_classic <- m_quad

  # Predictions for 1-10 cups
  new <- tibble::tibble(cups = 1:10)
  pi95 <- predict(model_classic, newdata = new, interval = "prediction", level = 0.95)

  pred_classic <- new %>%
    dplyr::mutate(
      estimate = pi95[, "fit"],
      PI95_low = pi95[, "lwr"],
      PI95_high= pi95[, "upr"]
    )

  classic_print <- pred_classic %>%
    dplyr::transmute(
      cups,
      estimate = fmt_time_safe(estimate),
      PI95_low = fmt_time_safe(PI95_low),
      PI95_high= fmt_time_safe(PI95_high)
    )

  list(
    model = model_classic,
    predictions = pred_classic,
    predictions_formatted = classic_print,
    AICs = AICs,
    dAIC = dAIC,
    wAIC = wAIC,
    delta_best = delta_best,
    report_comparison = report_model_comparison_if_close && is.finite(delta_best) && delta_best < close_threshold_aic
  )
}

#' Get grid data for plotting with prediction intervals
#' @param df Data frame with cups and sec columns
#' @param model Fitted model
#' @return Data frame with grid points and prediction intervals
get_prediction_grid <- function(df, model) {
  grid <- tibble::tibble(cups = seq(min(1, min(df$cups)), max(10, max(df$cups)), by = 0.05))
  grid_pi <- predict(model, newdata = grid, interval = "prediction", level = 0.95)

  grid %>%
    dplyr::mutate(
      fit  = grid_pi[, "fit"],
      pi_l = grid_pi[, "lwr"],
      pi_u = grid_pi[, "upr"]
    )
}

# ============================================================================
# Bayesian model utilities
# ============================================================================

#' Check if Bayesian packages are available
#' @return TRUE if rstanarm and loo are available
bayes_available <- function() {
  bayes_need <- c("rstanarm", "loo")
  all(vapply(bayes_need, requireNamespace, logical(1), quietly = TRUE))
}

#' Fit Bayesian models (linear and quadratic)
#' @param df Data frame with cups and sec columns
#' @return List with fit_lin, fit_quad, loo_lin, loo_quad, loo_compare, loo_weights
fit_bayes_models <- function(df) {
  if (!bayes_available()) {
    stop("Bayes-paket saknas: installera rstanarm och loo")
  }

  suppressPackageStartupMessages({
    library(rstanarm)
    library(loo)
  })

  options(mc.cores = max(1, parallel::detectCores() - 1))

  # Inline priors to avoid scoping issues with loo refit
  fit_lin <- rstanarm::stan_glm(
    sec ~ cups, data = df, family = gaussian(),
    prior = rstanarm::normal(location = 0, scale = 2.5, autoscale = TRUE),
    prior_intercept = rstanarm::normal(location = 0, scale = 2.5, autoscale = TRUE),
    prior_aux = rstanarm::exponential(rate = 1, autoscale = TRUE),
    chains = 4, iter = 2000, refresh = 0
  )

  fit_quad <- rstanarm::stan_glm(
    sec ~ poly(cups, 2, raw = TRUE), data = df, family = gaussian(),
    prior = rstanarm::normal(location = 0, scale = 2.5, autoscale = TRUE),
    prior_intercept = rstanarm::normal(location = 0, scale = 2.5, autoscale = TRUE),
    prior_aux = rstanarm::exponential(rate = 1, autoscale = TRUE),
    chains = 4, iter = 2000, refresh = 0
  )

  loo_lin  <- loo::loo(fit_lin,  k_threshold = 0.7)
  loo_quad <- loo::loo(fit_quad, k_threshold = 0.7)

  cmp <- loo::loo_compare(loo_lin, loo_quad)
  w_loo <- loo::loo_model_weights(list(lin = loo_lin, quad = loo_quad), method = "pseudobma")

  list(
    fit_lin = fit_lin,
    fit_quad = fit_quad,
    loo_lin = loo_lin,
    loo_quad = loo_quad,
    loo_compare = cmp,
    loo_weights = w_loo
  )
}

#' Get Bayesian predictions for 1-10 cups
#' @param bayes_fit List returned by fit_bayes_models
#' @param cups_range Integer vector of cups to predict (default 1:10)
#' @return List with predictions tibble (formatted), predictions_sec tibble (numeric), and yrep matrix
get_bayes_predictions <- function(bayes_fit, cups_range = 1:10) {
  new_data <- tibble::tibble(cups = cups_range)
  yrep <- rstanarm::posterior_predict(bayes_fit$fit_quad, newdata = new_data)

  predictions_sec <- tibble::tibble(
    cups = cups_range,
    estimate  = apply(yrep, 2, median),
    PI95_low  = apply(yrep, 2, quantile, probs = 0.025),
    PI95_high = apply(yrep, 2, quantile, probs = 0.975)
  )

  predictions_formatted <- predictions_sec %>%
    dplyr::mutate(
      estimate  = fmt_time_safe(estimate),
      PI95_low  = fmt_time_safe(PI95_low),
      PI95_high = fmt_time_safe(PI95_high)
    )

  list(
    predictions = predictions_formatted,
    predictions_sec = predictions_sec,
    yrep = yrep
  )
}

#' Get Bayesian grid data for plotting
#' @param bayes_predictions List returned by get_bayes_predictions
#' @return Data frame with cups, estimate_sec, PI_low_sec, PI_high_sec
get_bayes_plot_data <- function(bayes_predictions) {
  bayes_predictions$predictions_sec %>%
    dplyr::mutate(
      estimate_sec = pmax(0, estimate),
      PI_low_sec   = pmax(0, PI95_low),
      PI_high_sec  = pmax(0, PI95_high)
    )
}

#' Create combined predictions data frame for export
#' @param classical_results Results from fit_classical_models
#' @param bayes_predictions Predictions from get_bayes_predictions (or NULL)
#' @return Data frame with both models' predictions
create_combined_predictions <- function(classical_results, bayes_predictions = NULL) {
  klassisk <- classical_results$predictions_formatted %>%
    dplyr::rename(
      klassisk_estimate = estimate,
      klassisk_PI95_low = PI95_low,
      klassisk_PI95_high = PI95_high
    )

  if (is.null(bayes_predictions)) {
    return(klassisk %>% dplyr::mutate(
      bayes_estimate = NA_character_,
      bayes_PI95_low = NA_character_,
      bayes_PI95_high = NA_character_
    ))
  }

  bayes <- bayes_predictions$predictions %>%
    dplyr::select(-cups) %>%
    dplyr::rename(
      bayes_estimate = estimate,
      bayes_PI95_low = PI95_low,
      bayes_PI95_high = PI95_high
    )

  dplyr::bind_cols(klassisk, bayes)
}
