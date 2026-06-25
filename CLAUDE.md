# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Projekt: Kaffetidsuträkning

R/Shiny-applikation för att spåra och visualisera kaffekokningsdata.

**Produktägare:** Kristian Niemi (kristian.niemi@gmail.com)
**Arbetsledare:** Claude (denna agent)
**Språk:** Svenska i dokumentation, R i kod

---

## Byggkommandon

```bash
Rscript -e "shiny::runApp('.')"
```

---

## Arkitektur

R/Shiny-app med uppdelad struktur:

### Kodstruktur

```
kaffetidsutrakning/
├── app.R              # App-entrypoint
├── ui.R               # Shiny UI
├── server.R           # Shiny server-logik
├── R/                 # Hjälpfunktioner
├── www/               # Statiska filer (CSS, bilder)
├── img/               # Bilder
├── kaffedata.csv      # Data
├── tid_per_kopp.R     # Beräkningsscript
└── output/            # Genererade filer
```

---

## Kodkonventioner

- **R** med tidyverse-idiom
- Dokumentera funktioner med roxygen2-stil
- Inga tredjepartspaket utan godkännande

---

## Subagenter

Projektet har specialiserade subagenter i `.claude/agents/` som upptäcks automatiskt.

| Agent | Expertis |
|-------|----------|
| HR | Rollprofiler, rekrytering |
| R/Shiny-utvecklare | R-kod, Shiny UI/server |
| QA/Testare | Testning, kvalitetssäkring |

---

## Acceptanskriterier

| Krav | Mål | Mätmetod |
|------|-----|----------|
| Appen startar utan fel | 100% | `shiny::runApp()` |
| Data laddas korrekt | Alla rader i CSV | Visuell kontroll |
| Visualiseringar renderas | Alla plots synliga | Manuell testning |
