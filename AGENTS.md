# Agent Instructions for kaffe_over_tid

This file is the single source of truth for repository guidance used by both ChatGPT and GitHub Copilot. All automation tools should read these instructions instead of maintaining parallel copies elsewhere. The previous `.github/copilot-instructions.md` now only links here.

## Repository Overview

**Purpose**: Coffee brewing time analysis for Moccamaster Classic. Analyzes cups vs. brewing time using classical and Bayesian regression.

**Type**: R data analysis project (4.3.3+) with CLI script and Shiny web app

**Size**: Small (~10 files, ~560 LOC). Languages: R, Swedish UI/comments, shared library architecture (DRY)

**Frameworks**: Shiny, ggplot2, dplyr, readr, tibble

## Project Structure

```
.
├── R/                          # Shared library modules (130 lines)
│   ├── load_libs.R            # Package management & centralized loading
│   ├── time_utils.R           # Time parsing/formatting utilities
│   ├── data_utils.R           # CSV data management functions
│   ├── model_utils.R          # Statistical modeling (linear/quadratic)
│   └── plot_utils.R           # ggplot2 visualization functions
├── tid_per_kopp.R             # Command-line script (169 lines, executable)
├── app.R                      # Shiny web application (260 lines, executable)
├── kaffedata.csv              # Data file (cups, time in m:ss format)
├── README.md                  # User documentation (Swedish)
├── TESTING.md                 # Testing guide and implementation details
├── IMPLEMENTATION_SUMMARY.md  # Detailed project summary
└── .gitignore                 # Excludes fig/, pred_*.csv, .Rhistory, etc.
```

**Generated Files** (in .gitignore): `fig/*.png`, `pred_*.csv`

## Dependencies

**Required**: `ggplot2`, `dplyr`, `readr`, `tibble`, `shiny` (app.R only)
**Optional**: `rstanarm`, `loo` (Bayesian analysis)

**Installation** (CI/restricted environments MUST use this method):
```bash
sudo apt-get install -y r-base r-cran-{ggplot2,dplyr,readr,tibble,shiny}
```

**Auto-install**: Scripts auto-install missing packages via `install_if_missing()` if permissions allow. In CI/restricted environments, this fails with "lib is not writable" - use apt-get installation above instead.

## Build & Run Instructions

**Critical**: Always run from project root (scripts depend on `R/` directory relative path)

### Command-Line Script: `tid_per_kopp.R`

```bash
Rscript tid_per_kopp.R
```

**Output**: Console stats + `fig/klassisk_fit.png` + `pred_klassisk_1_10.csv` (+ Bayesian outputs if rstanarm/loo installed)
**Runtime**: 5-15s (classical), 30-60s (with Bayesian)
**Expected warnings**: "problematic observation(s)" is NORMAL (LOO analysis)

### Shiny App: `app.R`

```bash
Rscript app.R  # Runs on http://127.0.0.1:3838
```

**Runtime**: 3-5s to start, runs until Ctrl+C. Port 3838 (edit `port` variable to change)
**Browser**: Auto-opens (macOS: `open`, Linux: `xdg-open`). Headless/CI: Browser errors EXPECTED, app still runs.

**CI validation**:
```bash
timeout 10 Rscript app.R 2>&1 | grep "Listening on"  # Should output: Listening on http://127.0.0.1:3838
```

## Data Format: `kaffedata.csv`

```csv
cups,t
3,3:06
4,3:30
```

**Columns**: `cups` (integer 1-20), `t` (time string "m:ss")
**Time formats**: Accepts `3:30`, `3'30` (various apostrophes), `3m30s`, `3 30` - all parsed to seconds
**Minimum**: ≥5 rows required for modeling

## Architecture: Shared Library Pattern

Both script and app use identical functions from `R/`. **NEVER duplicate code** between them.

**Load order** (dependencies, DO NOT reorder):
1. `time_utils.R` → `parse_time()`, `fmt_time()`
2. `data_utils.R` → `load_coffee_data()`, `add_coffee_entry()`, `initialize_csv_if_missing()`
3. `model_utils.R` → `fit_classical_models()`, `get_prediction_grid()`
4. `plot_utils.R` → `create_classical_plot()`

**Adding features**: Add function to appropriate `R/*.R` module, use in both script and app, test both.

## Common Issues & Solutions

| Issue | Cause/Status | Solution |
|-------|--------------|----------|
| "Cannot find R/ directory" | Wrong directory | Run from project root |
| Package install fails "lib not writable" | No permissions (CI) | Use `apt-get install r-cran-*` |
| Browser doesn't open | Headless (EXPECTED) | Ignore or access http://127.0.0.1:3838 manually |
| Port 3838 in use | Process running | Kill process or edit `port` in app.R |
| "För lite data" error | CSV <5 rows | Add more data to kaffedata.csv |
| LOO "problematic observation" | EXPECTED behavior | Not an error, model auto-refits |

## Testing & Validation

**Quick validation**:
```bash
Rscript tid_per_kopp.R && ls fig/klassisk_fit.png pred_klassisk_1_10.csv
timeout 10 Rscript app.R 2>&1 | grep "Listening on"
```

**Expected warnings (SAFE TO IGNORE)**:
- "problematic observation(s)" - Normal LOO behavior
- "xdg-open: no method available" - Expected in headless
- Package version messages - Normal R startup

## CI/Build Notes

**No CI configured** (no `.github/workflows/`). If adding:
- Install via apt-get (not CRAN): `r-base r-cran-{ggplot2,dplyr,readr,tibble,shiny}`
- Use `timeout` for Shiny tests
- Ignore browser errors
- Runtime: ~60s with Bayesian analysis

**Sample CI**:
```bash
set -e
sudo apt-get update && sudo apt-get install -y r-base r-cran-{ggplot2,dplyr,readr,tibble,shiny}
Rscript tid_per_kopp.R && test -f fig/klassisk_fit.png
timeout 10 Rscript app.R 2>&1 | grep -q "Listening on"
```

## Working with This Repository

**Trust these instructions** - all commands validated. Only search codebase if instructions incomplete or incorrect.

**Common tasks**:
- Add data: Edit `kaffedata.csv` or use Shiny "Lägg till" form
- Change model: Edit `fit_classical_models()` in `model_utils.R` (auto-applies to both interfaces)
- Add visualization: Add to `plot_utils.R`, call from both script and app
- Modify time parsing: Edit `parse_time()` in `time_utils.R` (auto-applies everywhere)

**Modification impact**:
- `R/*.R` → Test BOTH script and app
- `tid_per_kopp.R` → Test script only
- `app.R` → Test app only
- `kaffedata.csv` → Test both

**Language**: Swedish UI/comments/errors, English variable/function names. Preserve this.

## Maintenance Note

- Update this AGENTS.md file when repository guidance changes. Other instruction files (e.g., `.github/copilot-instructions.md`) should only redirect here to avoid divergence.
