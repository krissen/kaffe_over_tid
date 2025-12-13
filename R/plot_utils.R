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
