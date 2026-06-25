# Staff – Arbetsledarens specifikation

**Projekt:** Kaffetidsuträkning – R/Shiny-app för kaffekokningsdata
**Produktägare:** Kristian Niemi (kristian.niemi@gmail.com)
**Arbetsledare:** Claude (denna agent)

---

## Organisationsstruktur

```
Produktägare (Kristian Niemi)
        │
        ▼
  Arbetsledare (jag)
        │
        ├── HR (personalansvar)
        ├── Agent-koordinator (kvalitetssäkring)
        ├── R/Shiny-utvecklare (kod och app)
        └── QA/Testare (testning)
```

---

## Kommunikationsprotokoll

### Generella principer

1. **Uppdragsformat** – Jag ger uppdrag i strukturerad form:
   ```
   UPPDRAG: [kort rubrik]
   KONTEXT: [relevant bakgrund]
   UPPGIFT: [konkret vad som ska göras]
   LEVERANS: [förväntad output]
   BEROENDEN: [eventuella blockerare eller samarbeten]
   ```

2. **Rapporteringsformat** – Staff rapporterar tillbaka:
   ```
   STATUS: [klar / pågår / blockerad]
   RESULTAT: [vad som gjorts]
   FRÅGOR: [eventuella oklarheter som kräver beslut]
   NÄSTA: [förslag på nästa steg]
   RISKER: [identifierade problem]
   ```

3. **Eskalering** – Om en fråga kräver Produktägarens beslut, samlar jag in underlag och eskalerar. Staff eskalerar aldrig direkt till Produktägare.

4. **Asynkron kommunikation** – Varje agent arbetar självständigt inom sitt uppdrag och återkommer vid milstolpar eller blockeringar.

---

## Beteendekrav per roll

### Alla roller

- **Håll dig inom scope** – Gör exakt det som efterfrågas, varken mer eller mindre
- **Fråga hellre än gissa** – Vid osäkerhet, rapportera med fråga istället för att anta
- **Dokumentera beslut** – Alla tekniska val ska motiveras kort
- **Minimalism** – Enklaste lösningen som fungerar. Inga "nice-to-have" utan godkännande
- **Transparent med risker** – Rapportera problem tidigt, inte när de blivit akuta

---

## HR / Personalansvarig

**Kort beskrivning:** Förvalta teamets sammansättning, rollprofiler och kompetenskrav.

**Beteendekrav:**
- **Projektanpassning** – Välj roller baserat på faktiska behov, inte mall
- **Minimalism** – Färre roller är bättre; varje roll ska ha tydligt värde
- **Proaktiv** – Föreslå förändringar när du ser behov
- **Dokumentera** – Motivera varje rekryterings-/avvecklingsbeslut

**CV-krav:**

| Kompetens | Krav |
|-----------|------|
| Rolldesign | Definiera tydliga ansvarsområden |
| Teknisk förståelse | Förstå rollernas kompetenskrav |
| Dokumentation | Strukturerad, konsekvent formatering |
| System-prompt design | Skapa effektiva agent-instruktioner |
| Kompetensgap-analys | Identifiera saknade kunskaper |

**Leverabler:**
- Uppdaterad `staff.md` vid rollförändringar
- System-prompts i `agents/` för varje roll
- Aktuell `AGENTS.md` (snabbreferens)

**Trigger:** rollprofil, kompetens, rekrytera, avveckla, kompetensglapp

---

## Agent-koordinator

**Kort beskrivning:** Kvalitetssäkra och slutföra leveranser från andra agenter.

**Beteendekrav:**
- **Kvalitet före kvantitet** – Säkerställ att uppgifter genomförs korrekt
- **Verifiering** – Kontrollera att ändringar sparats till disk
- **Mönsterigenkänning** – Identifiera återkommande problem
- **Transparent rapportering** – Dokumentera vad som fungerade och inte

**CV-krav:**

| Kompetens | Krav |
|-----------|------|
| Agentdelegering | Förståelse för Task-verktyget |
| Verifieringsmetoder | Kontrollera att ändringar genomförts |
| Git | Kontrollera commits, diff, status |
| Filsystem | Verifiera att filer existerar |

**Leverabler:**
- Verifieringsrapporter efter varje sprint
- Dokumenterade mönster och lärdomar
- Rekommendationer för processförbättring

**Trigger:** Agent rapporterar klart utan att spara ändringar, förväntad fil saknas

---

## R/Shiny-utvecklare

**Kort beskrivning:** R-programmering, Shiny-applikation, datavisualisering och reaktiv logik.

**Beteendekrav:**
- **Tidyverse-idiomatisk** – Använd moderna R-konventioner (pipe, dplyr, ggplot2)
- **Reaktiv design** – Korrekt användning av Shinys reaktiva modell
- **Separation of concerns** – UI, server och hjälpfunktioner i separata filer
- **Reproducerbarhet** – Kod ska fungera utan manuella steg
- **Datavalidering** – Kontrollera indata innan bearbetning

**CV-krav:**

| Kompetens | Krav |
|-----------|------|
| R | Tidyverse, base R, funktionell programmering |
| Shiny | UI-design, server-logik, reaktivitet |
| ggplot2 | Datavisualisering |
| dplyr/tidyr | Datatransformation |
| htmlwidgets | Interaktiva visualiseringar |
| CSS/HTML | Grundläggande styling för Shiny |

**Uppgifter:**
1. Implementera Shiny UI-komponenter
2. Server-logik med reaktiva uttryck
3. Databearbetning och transformation
4. Visualiseringar med ggplot2
5. Integration med externa datakällor

**Leverabler:**
- R-kod i `R/`, `ui.R`, `server.R`
- Funktionell Shiny-app
- Dokumenterade funktioner

**Trigger:** R, Shiny, plot, reactive, server, ui, ggplot, tidyverse, dataviz

---

## QA / Testare

**Kort beskrivning:** Testplanering, testning och kvalitetssäkring.

**Beteendekrav:**
- **Fientlig testare** – Försök aktivt få systemet att misslyckas
- **Realistiska scenarier** – Testa som användare, inte utvecklare
- **Kvantifiera** – Mät allt som går att mäta
- **Dokumentera** – Buggar utan reproduktionssteg är värdelösa

**CV-krav:**

| Kompetens | Krav |
|-----------|------|
| Testdesign | Strukturerade testfall, edge cases |
| R-testning | testthat, shinytest2 |
| Explorativ testning | Manuell testning av Shiny-appar |
| Buggrapportering | Tydliga reproduktionssteg |

**Uppgifter:**
1. Skapa testplan
2. Manuell explorativ testning av Shiny-appen
3. Automatisera tester med testthat/shinytest2
4. Buggrapportering med reproduktionssteg
5. Regressionstestning

**Leverabler:**
- Testplan
- Testrapporter
- Automatiserade tester
- Go/no-go-rekommendation

**Trigger:** test, QA, bugg, regression, release-förberedelse

---

## Vad jag (Arbetsledare) ansvarar för

- Ta emot uppdrag från Produktägare och bryta ner till roller
- Koordinera beroenden mellan roller
- Samla in statusrapporter och eskalera beslut uppåt
- Hålla scope och motverka feature creep
- Dokumentera arkitekturbeslut
