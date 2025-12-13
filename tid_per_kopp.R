#!/usr/bin/env Rscript

# ============================
# Kaffekok: datalogg + figurer + Bayes
# ============================

# ---- Inställningar ----
csv_path <- "kaffedata.csv"
fig_dir  <- "fig"
dir.create(fig_dir, showWarnings = FALSE)

# Om du vill lägga till nya mätningar:
# 1) öppna kaffedata.csv
# 2) lägg till rader med cups,sec
# 3) kör scriptet igen

# ---- Paket (installera vid behov) ----
need <- c("ggplot2", "dplyr", "readr", "tidyr")
bayes_need <- c("rstanarm", "loo")  # Bayes-del

install_if_missing <- function(pkgs) {
  miss <- pkgs[!vapply(pkgs, requireNamespace, logical(1), quietly = TRUE)]
  if (length(miss)) install.packages(miss, repos = "https://cloud.r-project.org")
}
install_if_missing(need)

suppressPackageStartupMessages({
  library(ggplot2)
  library(dplyr)
  library(readr)
  library(tidyr)
})

# ---- 1) Skapa eller läs data-CSV ----
if (!file.exists(csv_path)) {
  # Dina inmatade värden som sekunder (från tidigare körning)
  df_init <- tibble::tibble(
    cups = c(3,4,3,5,5,3,5,3,7),
    sec  = c(186,210,173,222,233,173,233,173,317)
  )
  write_csv(df_init, csv_path)
  message("Skapade ", csv_path, " (lägg till fler rader över tid).")
}

df <- read_csv(csv_path, show_col_types = FALSE) %>%
  mutate(
    cups = as.integer(cups),
    sec  = as.numeric(sec)
  ) %>%
  filter(!is.na(cups), !is.na(sec))

if (nrow(df) < 5) stop("För lite data i csv för att göra vettig modellering.")

# Hjälpfunktion
fmt_time <- function(sec) {
  sec <- round(sec)
  m <- floor(sec / 60)
  s <- sec %% 60
  sprintf("%d:%02d", m, s)
}

# Prognospunkter
new <- tibble::tibble(cups = 1:10)

# ============================
# A) Klassisk (frekventistisk) modell + AIC-vikter
# ============================
m_lin  <- lm(sec ~ cups, data = df)
m_quad <- lm(sec ~ poly(cups, 2, raw = TRUE), data = df)

AICs <- c(linear = AIC(m_lin), quadratic = AIC(m_quad))
dAIC <- AICs - min(AICs)
wAIC <- exp(-0.5 * dAIC) / sum(exp(-0.5 * dAIC))

model_classic <- if (wAIC["quadratic"] > wAIC["linear"]) m_quad else m_lin

ci95 <- predict(model_classic, newdata = new, interval = "confidence", level = 0.95)
pi95 <- predict(model_classic, newdata = new, interval = "prediction", level = 0.95)

pred_classic <- new %>%
  mutate(
    estimate = ci95[, "fit"],
    CI95_low = ci95[, "lwr"],
    CI95_high= ci95[, "upr"],
    PI95_low = pi95[, "lwr"],
    PI95_high= pi95[, "upr"]
  ) %>%
  mutate(across(where(is.numeric), ~ .x))

# Skriv tabell i terminalen (som tid)
cat("\n=== Klassisk modell ===\n")
cat("AIC:\n"); print(AICs)
cat("\nModellstöd (AIC-vikt):\n"); print(round(100 * wAIC, 1))
cat("\nVald klassisk modell:", if (identical(model_classic, m_lin)) "linjär" else "kvadratisk", "\n\n")

classic_print <- pred_classic %>%
  transmute(
    cups,
    estimate = fmt_time(estimate),
    CI95_low = fmt_time(CI95_low),
    CI95_high= fmt_time(CI95_high),
    PI95_low = fmt_time(PI95_low),
    PI95_high= fmt_time(PI95_high)
  )
print(classic_print, row.names = FALSE)

# ============================
# 1) Figurer (klassisk)
# ============================
# För en snygg kurva: tät grid
grid <- tibble::tibble(cups = seq(min(1, min(df$cups)), max(10, max(df$cups)), by = 0.05))
grid_ci <- predict(model_classic, newdata = grid, interval = "confidence", level = 0.95)
grid_pi <- predict(model_classic, newdata = grid, interval = "prediction", level = 0.95)

grid_plot <- grid %>%
  mutate(
    fit = grid_ci[, "fit"],
    ci_l = grid_ci[, "lwr"],
    ci_u = grid_ci[, "upr"],
    pi_l = grid_pi[, "lwr"],
    pi_u = grid_pi[, "upr"]
  )

p1 <- ggplot(df, aes(x = cups, y = sec)) +
  geom_point(size = 2) +
  geom_ribbon(
    data = grid_plot,
    aes(x = cups, ymin = pi_l, ymax = pi_u),
    alpha = 0.15,
    inherit.aes = FALSE
  ) +
  geom_ribbon(
    data = grid_plot,
    aes(x = cups, ymin = ci_l, ymax = ci_u),
    alpha = 0.25,
    inherit.aes = FALSE
  ) +
  geom_line(
    data = grid_plot,
    aes(x = cups, y = fit),
    linewidth = 1,
    inherit.aes = FALSE
  ) +
  labs(
    title = "Kaffekok: tid (sek) vs antal koppar",
    subtitle = "Mörkare band = 95% KI (medel). Ljusare band = 95% PI (ny mätning).",
    x = "Antal koppar", y = "Tid (sek)"
  )

ggsave(file.path(fig_dir, "klassisk_fit.png"), p1, width = 8, height = 5, dpi = 150)

# ============================
# B) Bayesiansk modell (rstanarm) + jämförelse via LOO
# ============================
bayes_available <- all(vapply(bayes_need, requireNamespace, logical(1), quietly = TRUE))
if (!bayes_available) {
  message("\n(Bayes-del hoppad: installera rstanarm + loo om du vill köra Bayes.)")
  quit(status = 0)
}

suppressPackageStartupMessages({
  library(rstanarm)
  library(loo)
})

# gör Bayes snabbare/robustare som default
options(mc.cores = max(1, parallel::detectCores() - 1))

# Svaga, rimliga priors (du kan ändra)
prior_beta  <- normal(location = 0, scale = 2.5, autoscale = TRUE)
prior_sigma <- exponential(rate = 1, autoscale = TRUE)

fit_b_lin <- stan_glm(
  sec ~ cups, data = df,
  family = gaussian(),
  prior = prior_beta, prior_intercept = prior_beta, prior_aux = prior_sigma,
  chains = 4, iter = 2000, refresh = 0
)

fit_b_quad <- stan_glm(
  sec ~ poly(cups, 2, raw = TRUE), data = df,
  family = gaussian(),
  prior = prior_beta, prior_intercept = prior_beta, prior_aux = prior_sigma,
  chains = 4, iter = 2000, refresh = 0
)

# LOO-jämförelse (modellstöd-ish, via elpd)
loo_lin  <- loo(fit_b_lin)
loo_quad <- loo(fit_b_quad)

cmp <- loo_compare(loo_lin, loo_quad)
cat("\n=== Bayes: LOO-jämförelse ===\n")
print(cmp)

# Konvertera LOO-resultat till ungefärliga vikter (pseudo-BMA)
w_loo <- loo_model_weights(list(lin = loo_lin, quad = loo_quad), method = "pseudobma")
cat("\nBayes modellvikter (pseudo-BMA, ungefärligt stöd inom kandidatsetet):\n")
print(round(100 * w_loo, 1))

fit_b <- if (w_loo["quad"] > w_loo["lin"]) fit_b_quad else fit_b_lin
cat("\nVald Bayes-modell:", if (identical(fit_b, fit_b_lin)) "linjär" else "kvadratisk", "\n")

# Posterior predictive för cups 1–10
# yrep = simulerade nya observationer (motsvarar PI)
yrep <- posterior_predict(fit_b, newdata = new)  # matrix: draws x 10
yhat <- posterior_linpred(fit_b, newdata = new, transform = TRUE) # medel (motsvarar KI/medel)

summ <- function(mat) {
  tibble::tibble(
    est = apply(mat, 2, median),
    lo  = apply(mat, 2, quantile, probs = 0.025),
    hi  = apply(mat, 2, quantile, probs = 0.975)
  )
}

summ_mean <- summ(yhat)  %>% rename(CI_est = est, CI_low = lo, CI_high = hi)
summ_pred <- summ(yrep)  %>% rename(PI_est = est, PI_low = lo, PI_high = hi)

pred_bayes <- bind_cols(new, summ_mean, summ_pred)

cat("\nBayes prognos (median + 95% intervall):\n")
bayes_print <- pred_bayes %>%
  transmute(
    cups,
    CI_med = fmt_time(CI_est),
    CI95_low = fmt_time(CI_low),
    CI95_high= fmt_time(CI_high),
    PI_med = fmt_time(PI_est),
    PI95_low = fmt_time(PI_low),
    PI95_high= fmt_time(PI_high)
  )
print(bayes_print, row.names = FALSE)

# Spara prognoser som CSV också (så du kan jämföra över tid)
write_csv(pred_classic, "pred_klassisk_1_10.csv")
write_csv(pred_bayes,   "pred_bayes_1_10.csv")

# ============================
# 1) Figurer (Bayes)
# ============================
# Rita median + 95% band för prediktiv (yrep)
bayes_plot_df <- pred_bayes %>%
  mutate(
    CI_est = CI_est, CI_low = CI_low, CI_high = CI_high,
    PI_low = PI_low, PI_high = PI_high
  )

p2 <- ggplot() +
  geom_point(data = df, aes(x = cups, y = sec), size = 2) +
  geom_ribbon(data = bayes_plot_df, aes(x = cups, ymin = PI_low, ymax = PI_high), alpha = 0.15) +
  geom_ribbon(data = bayes_plot_df, aes(x = cups, ymin = CI_low, ymax = CI_high), alpha = 0.25) +
  geom_line(data = bayes_plot_df, aes(x = cups, y = CI_est), linewidth = 1) +
  labs(
    title = "Bayes: tid (sek) vs koppar",
    subtitle = "Mörkare band = 95% osäkerhet för medel. Ljusare band = 95% prediktivt intervall.",
    x = "Antal koppar", y = "Tid (sek)"
  )

ggsave(file.path(fig_dir, "bayes_fit.png"), p2, width = 8, height = 5, dpi = 150)

cat("\nSparat:\n")
cat("- ", csv_path, "\n", sep = "")
cat("- ", file.path(fig_dir, "klassisk_fit.png"), "\n", sep = "")
cat("- ", file.path(fig_dir, "bayes_fit.png"), "\n", sep = "")
cat("- pred_klassisk_1_10.csv\n")
cat("- pred_bayes_1_10.csv\n")

