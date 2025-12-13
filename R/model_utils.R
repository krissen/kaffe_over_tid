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
      estimate = fmt_time(estimate),
      PI95_low = fmt_time(PI95_low),
      PI95_high= fmt_time(PI95_high)
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
