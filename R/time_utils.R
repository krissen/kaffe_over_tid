# time_utils.R
# Shared functions for time parsing and formatting

#' Parse time string to seconds
#' @param x Time string in format "m:ss" or variations
#' @return Numeric value in seconds
parse_time <- function(x) {
  x <- trimws(as.character(x))

  # normalisera separatorer: 3'06, 3'06, 3:06, 3 06, 3m06s, etc.
  # Ersätt olika apostrof- och accenttecken med kolon
  # ' (apostrophe), ′ (prime), ` (backtick), ´ (acute accent)
  x <- gsub("['′`´]", ":", x)
  x <- gsub("[^0-9:]", ":", x)
  x <- gsub(":+", ":", x)

  parts <- strsplit(x, ":")[[1]]
  if (length(parts) < 2) stop("Kan inte tolka tid: ", x)

  min <- suppressWarnings(as.numeric(parts[1]))
  sec <- suppressWarnings(as.numeric(parts[2]))

  if (is.na(min) || is.na(sec) || sec < 0 || sec >= 60) stop("Ogiltig tid: ", x)
  min * 60 + sec
}

#' Format seconds to time string
#' @param sec Numeric value in seconds
#' @return Time string in format "m:ss"
fmt_time <- function(sec) {
  sec <- round(sec)
  m <- floor(sec / 60)
  s <- sec %% 60
  sprintf("%d:%02d", m, s)
}
