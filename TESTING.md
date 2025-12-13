# Testing Guide

## Implementation Summary

This implementation creates a complete Shiny app with shared libraries for the coffee brewing time analysis project.

## Changes Made

### 1. Shared Libraries (R/ directory)

Created 5 shared library files following DRY principles:

- **time_utils.R**: Time parsing and formatting functions
  - `parse_time(x)` - Parse time strings like "3:30" to seconds
  - `fmt_time(sec)` - Format seconds to "m:ss" format

- **data_utils.R**: Data management functions
  - `load_coffee_data(csv_path)` - Load and validate CSV data
  - `add_coffee_entry(csv_path, cups, time_str)` - Add new entry to CSV
  - `initialize_csv_if_missing(csv_path)` - Create initial CSV with sample data

- **model_utils.R**: Statistical modeling functions
  - `fit_classical_models(df, ...)` - Fit linear and quadratic models, return predictions
  - `get_prediction_grid(df, model)` - Generate grid for plotting

- **plot_utils.R**: Plotting functions
  - `create_classical_plot(df, grid_plot)` - Create ggplot with prediction intervals

- **load_libs.R**: Package management and library loading
  - `install_if_missing(pkgs)` - Install missing packages
  - Sources all utility files

### 2. Updated Script (tid_per_kopp.R)

- Refactored to use shared libraries instead of inline functions
- Reduced from ~298 lines to ~169 lines
- Maintains all original functionality
- Easier to maintain and extend

### 3. Shiny App (app.R)

Created a complete Shiny application with:

**UI Features:**
- Input form for adding new measurements (cups + time)
- Data table showing all current measurements
- Three tabs:
  - **Plot**: Interactive visualization with prediction intervals
  - **Prediktioner**: Formatted predictions table with download button
  - **Modellinfo**: Model comparison and statistics

**Server Features:**
- Reactive data loading (updates when new data is added)
- Automatic model refitting on data change
- CSV file updates with validation
- Error handling with user-friendly notifications
- Download handler for predictions

**Launch Features:**
- Auto-detects operating system (macOS, Linux, Windows)
- Automatically opens browser when started with `Rscript app.R`
- Uses `open` command on macOS as requested
- Can run on custom port (default 3838)

### 4. Documentation

- **README.md**: Complete usage guide with examples
- **TESTING.md**: This file - implementation details and testing instructions

### 5. Configuration

- Updated .gitignore to exclude:
  - Generated figures (`fig/`)
  - Prediction CSV files (`pred_*.csv`)
  - Old backup file (`tid_per_kopp_old.R`)
  - R session files (`.Rhistory`, `.RData`, `.Rproj.user`)

## How to Test

### Prerequisites

Install R and required packages:
```bash
# Install R (macOS)
brew install r

# Or on Linux
sudo apt-get install r-base

# Required packages will be auto-installed on first run
```

### Test 1: Original Script with Shared Libraries

```bash
cd /path/to/kaffe_over_tid
Rscript tid_per_kopp.R
```

**Expected Results:**
- Loads data from `kaffedata.csv`
- Prints model comparison and predictions
- Creates `fig/klassisk_fit.png`
- Creates `pred_klassisk_1_10.csv`
- (Optional) Bayesian analysis if rstanarm/loo are installed

### Test 2: Shiny App Launch

```bash
cd /path/to/kaffe_over_tid
Rscript app.R
```

**Expected Results:**
- Prints "Öppnar webbläsare: http://127.0.0.1:3838"
- Browser opens automatically (macOS uses `open` command)
- App loads and displays current data

### Test 3: Add New Data via Shiny App

In the Shiny app:
1. Enter number of cups (e.g., 4)
2. Enter time in format "m:ss" (e.g., "3:25")
3. Click "Lägg till" button

**Expected Results:**
- Success notification appears
- Data table updates with new entry
- Plot updates automatically
- Predictions recalculate
- New entry persists in `kaffedata.csv`

### Test 4: Data Validation

Try invalid inputs in the Shiny app:
- Invalid time format (e.g., "abc")
- Invalid cups number (e.g., -1)

**Expected Results:**
- Error notification with descriptive message
- Data not added to CSV
- App remains functional

### Test 5: Download Predictions

In the Shiny app:
1. Go to "Prediktioner" tab
2. Click "Ladda ner CSV" button

**Expected Results:**
- CSV file downloads with name like `kaffe_prediktioner_2024-12-13.csv`
- File contains predictions for 1-10 cups with intervals

### Test 6: Verify Shared Code (One Source of Truth)

Check that both the script and app use the same functions:

```bash
# Search for parse_time usage
grep -r "parse_time" tid_per_kopp.R app.R R/

# Should only be defined once (in R/time_utils.R)
# and used in other files
```

## Code Quality Checks

### No Code Duplication
- All time parsing logic in `R/time_utils.R`
- All data management in `R/data_utils.R`
- All modeling in `R/model_utils.R`
- All plotting in `R/plot_utils.R`

### Proper Error Handling
- Invalid time formats caught and reported
- Invalid cup numbers validated
- File I/O errors handled gracefully
- User-friendly error messages in Shiny app

### Maintainability
- Clear function names and parameters
- Logical separation of concerns
- Minimal code duplication
- Both script and app use same libraries

## Potential Issues and Solutions

### Issue: R not installed
**Solution:** Install R from CRAN or package manager

### Issue: Browser doesn't open automatically
**Solution:** 
- Check if running on macOS (uses `open` command)
- Manually open http://127.0.0.1:3838 in browser

### Issue: Port 3838 already in use
**Solution:** Edit `app.R` and change the `port` variable to another number

### Issue: Missing packages
**Solution:** Packages should auto-install, but can manually install:
```r
install.packages(c("ggplot2", "dplyr", "readr", "tibble", "shiny"))
```

## Success Criteria

✅ Shared libraries created in R/ directory
✅ Original script refactored to use shared libraries
✅ Shiny app created with all required features
✅ App can add new data to CSV
✅ Data updates trigger automatic recalculation
✅ App opens browser automatically on macOS
✅ No code duplication between script and app
✅ Documentation complete (README + this file)

## Next Steps (Optional Enhancements)

If you want to extend the functionality:

1. Add data editing/deletion in Shiny app
2. Add export functionality for plots
3. Add data validation rules (min/max time, etc.)
4. Add unit tests for shared functions
5. Add support for different models (polynomial degree selection)
6. Add data visualization in different formats
7. Add database support instead of CSV
