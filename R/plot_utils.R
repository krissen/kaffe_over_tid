# plot_utils.R
# Shared functions for plotting

#' Create classical model plot with prediction intervals
#' @param df Data frame with cups and sec columns
#' @param grid_plot Grid data with fit and prediction intervals
#' @return ggplot object
create_classical_plot <- function(df, grid_plot) {
  ggplot2::ggplot(df, ggplot2::aes(x = cups, y = sec)) +
    ggplot2::geom_point(size = 2) +
    ggplot2::geom_ribbon(
      data = grid_plot,
      ggplot2::aes(x = cups, ymin = pi_l, ymax = pi_u),
      alpha = 0.20,
      inherit.aes = FALSE
    ) +
    ggplot2::geom_line(
      data = grid_plot,
      ggplot2::aes(x = cups, y = fit),
      linewidth = 1,
      inherit.aes = FALSE
    ) +
    ggplot2::labs(
      title = "Kaffekok: tid vs koppar",
      subtitle = "Kurva + 95% prediktionsintervall (praktiskt spann för nästa kok).",
      x = "Antal koppar", y = "Tid (sek)"
    )
}

#' Create Bayesian model plot with prediction intervals
#' @param df Data frame with cups and sec columns (original data)
#' @param bayes_plot_df Data frame from get_bayes_plot_data()
#' @return ggplot object
create_bayes_plot <- function(df, bayes_plot_df) {
  ggplot2::ggplot() +
    ggplot2::geom_point(data = df, ggplot2::aes(x = cups, y = sec), size = 2) +
    ggplot2::geom_ribbon(
      data = bayes_plot_df,
      ggplot2::aes(x = cups, ymin = PI_low_sec, ymax = PI_high_sec),
      alpha = 0.20
    ) +
    ggplot2::geom_line(
      data = bayes_plot_df,
      ggplot2::aes(x = cups, y = estimate_sec),
      linewidth = 1
    ) +
    ggplot2::labs(
      title = "Bayes: tid vs koppar",
      subtitle = "95% prediktivt intervall (posterior predictive).",
      x = "Antal koppar", y = "Tid (sek)"
    )
}

#' Create combined plot with both classical and Bayesian models
#' @param df Data frame with cups and sec columns (original data)
#' @param grid_plot Grid data from classical model (fit, pi_l, pi_u)
#' @param bayes_plot_df Data frame from get_bayes_plot_data() (can be NULL)
#' @return ggplot object
create_combined_plot <- function(df, grid_plot, bayes_plot_df = NULL) {
  # Färgpaletter
  col_klassisk <- "#2166AC"  # Blå
  col_bayes    <- "#B2182B"  # Röd

  p <- ggplot2::ggplot() +
    # Klassiskt PI-band
    ggplot2::geom_ribbon(
      data = grid_plot,
      ggplot2::aes(x = cups, ymin = pi_l, ymax = pi_u, fill = "Klassisk"),
      alpha = 0.20
    ) +
    # Klassisk kurva
    ggplot2::geom_line(
      data = grid_plot,
      ggplot2::aes(x = cups, y = fit, color = "Klassisk"),
      linewidth = 1
    )

  # Lägg till Bayes om tillgängligt
 if (!is.null(bayes_plot_df)) {
    p <- p +
      # Bayes PI-band
      ggplot2::geom_ribbon(
        data = bayes_plot_df,
        ggplot2::aes(x = cups, ymin = PI_low_sec, ymax = PI_high_sec, fill = "Bayes"),
        alpha = 0.20
      ) +
      # Bayes kurva
      ggplot2::geom_line(
        data = bayes_plot_df,
        ggplot2::aes(x = cups, y = estimate_sec, color = "Bayes"),
        linewidth = 1
      )
  }

  # Datapunkter överst
  p <- p +
    ggplot2::geom_point(data = df, ggplot2::aes(x = cups, y = sec), size = 2) +
    # Manuella färgskalor
    ggplot2::scale_color_manual(
      name = "Modell",
      values = c("Klassisk" = col_klassisk, "Bayes" = col_bayes)
    ) +
    ggplot2::scale_fill_manual(
      name = "Modell",
      values = c("Klassisk" = col_klassisk, "Bayes" = col_bayes)
    ) +
    ggplot2::labs(
      title = "Kaffekok: tid vs koppar",
      subtitle = "95% prediktionsintervall (klassisk) och prediktivt intervall (Bayes).",
      x = "Antal koppar", y = "Tid (sek)"
    ) +
    ggplot2::theme(legend.position = "bottom")

  p
}
