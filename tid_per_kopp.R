# Kaffekok: antal koppar -> tid (sekunder)
# Output:
# - Prognos för 1–10 koppar
# - 95% KI (för medel/förväntad tid)
# - 95% PI (för en ny faktisk mätning)
# - Modellstöd i % via AIC-vikter (linjär vs kvadratisk)

df <- data.frame(
  cups = c(3,4,3,5,5,3,5,3,7),
  sec  = c(186,210,173,222,233,173,233,173,317)
)

# --- Kandidatmodeller ---
m_lin  <- lm(sec ~ cups, data = df)
m_quad <- lm(sec ~ poly(cups, 2, raw = TRUE), data = df)

# --- AIC-vikter (modellstöd inom kandidatsetet) ---
AICs <- c(linear = AIC(m_lin), quadratic = AIC(m_quad))
dAIC <- AICs - min(AICs)
w    <- exp(-0.5 * dAIC) / sum(exp(-0.5 * dAIC))

cat("AIC (lägre är bättre):\n"); print(AICs)
cat("\nModellstöd (AIC-vikt):\n"); print(round(100 * w, 1))

# Välj modellen med högst AIC-vikt
model <- if (w["quadratic"] > w["linear"]) m_quad else m_lin

# --- Prediktioner 1–10 koppar ---
new <- data.frame(cups = 1:10)

# 95% KI för medel: predict(..., interval="confidence")
ci95 <- predict(model, newdata = new, interval = "confidence", level = 0.95)

# 95% PI för ny observation: predict(..., interval="prediction")
pi95 <- predict(model, newdata = new, interval = "prediction", level = 0.95)

fmt_time <- function(sec) {
  sec <- round(sec)
  m <- floor(sec / 60)
  s <- sec %% 60
  sprintf("%d:%02d", m, s)
}

out <- data.frame(
  cups = new$cups,
  estimate = fmt_time(ci95[, "fit"]),
  CI95_low = fmt_time(ci95[, "lwr"]),
  CI95_high = fmt_time(ci95[, "upr"]),
  PI95_low = fmt_time(pi95[, "lwr"]),
  PI95_high = fmt_time(pi95[, "upr"])
)

cat("\nVald modell:", if (identical(model, m_lin)) "linjär" else "kvadratisk", "\n")
cat("Tolkning:\n")
cat("- CI95: osäkerhet för förväntad/medel-tid vid X koppar.\n")
cat("- PI95: osäkerhet för en ny enskild mätning vid X koppar.\n\n")

print(out, row.names = FALSE)

