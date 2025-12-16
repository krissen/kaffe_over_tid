# data_utils.R
# Shared functions for data loading and validation

#' Parse cups value with support for both "," and "." as decimal separator
#' @param x Value to parse (numeric or character)
#' @return Numeric value
parse_cups <- function(x) {
  if (is.numeric(x)) return(x)
  x <- as.character(x)
  # Replace comma with dot for decimal parsing
  x <- gsub(",", ".", x)
  as.numeric(x)
}

#' Load and validate coffee data from CSV
#' @param csv_path Path to CSV file
#' @return Tibble with columns: cups, t, sec
load_coffee_data <- function(csv_path) {
  if (!file.exists(csv_path)) {
    stop("CSV-filen finns inte: ", csv_path)
  }

  df0 <- readr::read_csv(csv_path, show_col_types = FALSE)
  names(df0) <- tolower(names(df0))

  if (!("cups" %in% names(df0))) stop("CSV måste ha kolumnen 'cups'.")

  # normalisera tidskolumn till "t"
  if ("t" %in% names(df0)) {
    # ok
  } else if ("tid" %in% names(df0)) {
    df0 <- dplyr::rename(df0, t = tid)
  } else if ("time" %in% names(df0)) {
    df0 <- dplyr::rename(df0, t = time)
  } else {
    stop("CSV måste ha tidskolumnen 't' (eller 'time'/'tid').")
  }

  df <- df0 %>%
    dplyr::mutate(
      cups = vapply(cups, parse_cups, numeric(1)),
      t    = as.character(t),
      sec  = vapply(t, parse_time, numeric(1))
    ) %>%
    dplyr::filter(!is.na(cups), !is.na(sec))

  if (nrow(df) < 5) stop("För lite data i ", csv_path, " för modellering.")

  df
}

#' Add new row to CSV file
#' @param csv_path Path to CSV file
#' @param cups Number of cups (supports both "," and "." as decimal separator)
#' @param time_str Time string in format "m:ss"
#' @return TRUE on success
add_coffee_entry <- function(csv_path, cups, time_str) {
  # Validate input - support decimal cups with both "," and "."
  cups <- parse_cups(cups)
  if (is.na(cups) || cups < 0.5) stop("Ogiltigt antal koppar")
  
  # Validate time format
  tryCatch(
    parse_time(time_str),
    error = function(e) stop("Ogiltigt tidsformat: ", time_str)
  )

  # Read existing data
  df <- readr::read_csv(csv_path, show_col_types = FALSE)

  # Normalize column names and types to avoid type-mismatch errors when binding
  names(df) <- tolower(names(df))

  if (!("cups" %in% names(df))) stop("CSV måste ha kolumnen 'cups'.")

  if ("t" %in% names(df)) {
    # ok
  } else if ("tid" %in% names(df)) {
    df <- dplyr::rename(df, t = tid)
  } else if ("time" %in% names(df)) {
    df <- dplyr::rename(df, t = time)
  } else {
    stop("CSV måste ha tidskolumnen 't' (eller 'time'/'tid').")
  }

  df <- df %>% dplyr::mutate(cups = vapply(cups, parse_cups, numeric(1)), t = as.character(t))

  # Normalisera tidssträngar till formatet m:ss för både befintliga och nya rader
  normalize_time <- function(x) fmt_time(parse_time(x))
  df <- df %>% dplyr::mutate(t = vapply(t, normalize_time, character(1)))
  time_str_norm <- normalize_time(time_str)

  # Add new row
  new_row <- tibble::tibble(cups = cups, t = time_str_norm)
  df <- dplyr::bind_rows(df, new_row)
  
  # Write back to CSV
  readr::write_csv(df, csv_path)
  
  TRUE
}

#' Initialize CSV file with example data if it doesn't exist
#' @param csv_path Path to CSV file
initialize_csv_if_missing <- function(csv_path) {
  if (!file.exists(csv_path)) {
    df_init <- tibble::tibble(
      cups = c(3,4,3,5,5,3,5,3,7),
      t    = c("3:06","3:30","2:53","3:42","3:53","2:53","3:53","2:53","5:17")
    )
    readr::write_csv(df_init, csv_path)
    message("Skapade ", csv_path, " (lägg till fler rader: cups,t).")
    message("Exempelrad: 4,3:28")
  }
}
