<div align="center">
  <img src="img/moccamaster_logo-text.png" alt="Moccamaster" width="200"/>
  
  # Kaffekok: Tid per Kopp
  
  ### Analys av bryggtid för Moccamaster Classic
  
  <img src="img/moccamaster_classic.jpg" alt="Moccamaster Classic" width="400"/>
  
  *Analys av tid för kaffekokning baserat på antal koppar, med både ett kommandoradsskript och en interaktiv Shiny-app.*
</div>

---

## 📊 Funktioner

- **☕ Moccamaster Classic**: Specialanpassad för att analysera bryggtider för denna ikoniska kaffebryggare
- **📈 Dataanalys**: Kvadratisk regressionsmodell för tid vs antal koppar
- **🎯 Prediktioner**: 95% prediktionsintervall för 1-10 koppar
- **📉 Visualisering**: Plottar med data och prediktionsintervall
- **➕ Datainmatning**: Lägg till nya mätningar via Shiny-appen
- **♻️ Delade bibliotek**: En källkod för både scriptet och appen (DRY-princip)

## Struktur

```
.
├── R/                      # Delade bibliotek
│   ├── load_libs.R        # Laddar paket och sourcar övriga filer
│   ├── time_utils.R       # Tidsparsning och formatering
│   ├── data_utils.R       # CSV-hantering (läsa, skriva, validera)
│   ├── model_utils.R      # Modellering (linjär, kvadratisk)
│   └── plot_utils.R       # Plotting-funktioner
├── tid_per_kopp.R         # Kommandoradsskript
├── app.R                  # Shiny-app
└── kaffedata.csv          # Data (koppar, tid)
```

## Användning

### Kommandoradsskript

Kör analysen och generera rapporter/figurer:

```bash
Rscript tid_per_kopp.R
```

Detta skapar:
- `fig/klassisk_fit.png` - Visualisering av modellen
- `pred_klassisk_1_10.csv` - Prediktioner för 1-10 koppar

### 🌐 Shiny-app

Starta den interaktiva appen:

```bash
Rscript app.R
```

Appen kommer automatiskt att öppnas i din webbläsare (macOS: `open`, Linux: `xdg-open`).

**I appen kan du:**
1. 📋 Se alla befintliga mätningar från din Moccamaster Classic
2. ➕ Lägga till nya mätningar (antal koppar + tid)
3. 📊 Se uppdaterade prediktioner och plottar direkt
4. 💾 Ladda ner prediktioner som CSV

<div align="center">
  <em>Modern, retro-inspirerad design som kompletterar Moccamasters tidlösa estetik</em>
</div>

## Dataformat

CSV-filen (`kaffedata.csv`) har formatet:

```csv
cups,t
3,3:06
4,3:30
5,3:42
```

- `cups`: Antal koppar (heltal)
- `t`: Tid i format "m:ss" (minuter:sekunder)

Tidsformat accepterar flera varianter: `3:30`, `3'30`, `3'30`, `3m30s`, etc.

## Krav

### Nödvändiga R-paket:
- ggplot2
- dplyr
- readr
- tibble
- shiny (endast för appen)

### Valfria paket (för Bayesiansk analys):
- rstanarm
- loo

Paketen installeras automatiskt om de saknas.

## Delade bibliotek

Både scriptet och appen använder samma funktioner från `R/`-mappen:

- **time_utils.R**: `parse_time()`, `fmt_time()`
- **data_utils.R**: `load_coffee_data()`, `add_coffee_entry()`, `initialize_csv_if_missing()`
- **model_utils.R**: `fit_classical_models()`, `get_prediction_grid()`
- **plot_utils.R**: `create_classical_plot()`

Detta garanterar "one source of truth" - ingen kod dupliceras.

## Utveckling

För att lägga till ny funktionalitet:

1. Lägg till funktionen i lämplig fil under `R/`
2. Använd funktionen i både `tid_per_kopp.R` och `app.R`
3. Testa båda användningsområdena

## Licens

Se projektets licensfil.
