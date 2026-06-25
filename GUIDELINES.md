# Kaffetidsuträkning – Allmänna anvisningar

Detta dokument gäller för Arbetsledare och samtliga sub-agenter.

---

## Befogenheter

### Arbetsledare har mandat att:

- **Godkänna all läsning och hämtning** – Inklusive webbdata, dokumentation, API-referens
- **Delegera uppgifter** till sub-agenter utan att fråga Produktägare
- **Fatta tekniska beslut** inom projektets scope
- **Prioritera om** vid behov baserat på blockeringar

### Sub-agenter får utan att fråga:

- Läsa all dokumentation
- Hämta webbdata för research
- Skapa prototyper och testkod
- Dokumentera sina fynd

### Kräver Produktägarens godkännande:

- Scope-ändringar (nya features utanför plan)
- Arkitekturella beslut som påverkar användarupplevelsen
- Release/distribution

---

## Dokumentation och källor

### Principer

1. **Spara dokumentation för återanvändning**
   - All inläst dokumentation ska sammanfattas och sparas i `research/`
   - Undvik att hämta samma källa flera gånger

2. **Referenshantering**
   - Varje källa ska loggas med URL, datum och sammanfattning
   - Lagras i `research/references.md`

3. **Aktualitet**
   - Verifiera att information gäller aktuella versioner

### Katalogstruktur för dokumentation

```
research/
├── references.md          # Källförteckning
├── _txt/                  # Textextrakt från PDF
└── _analys/               # Primers och sammanställningar

_decisions/                # Arkitekturbeslut (ADR)
```

### Referensformat

```markdown
## [Kort titel]

- **URL:** https://...
- **Hämtad:** YYYY-MM-DD
- **Sammanfattning:**
  Kort beskrivning av innehållet och relevans för projektet.
```

---

## Kommunikation

### Uppdragsformat (Arbetsledare → Sub-agent)

```
UPPDRAG: [kort rubrik]
KONTEXT: [relevant bakgrund]
UPPGIFT: [konkret vad som ska göras]
LEVERANS: [förväntad output]
BEROENDEN: [eventuella blockerare eller samarbeten]
```

### Rapportformat (Sub-agent → Arbetsledare)

```
STATUS: [klar / pågår / blockerad]
RESULTAT: [vad som gjorts]
FRÅGOR: [eventuella oklarheter som kräver beslut]
NÄSTA: [förslag på nästa steg]
RISKER: [identifierade problem]
```

---

## Kodstandarder

- **R** med tidyverse-konventioner
- Pipe-operatorn `|>` (base R) eller `%>%` (magrittr)
- snake_case för variabel- och funktionsnamn
- ggplot2 för visualiseringar
- Dokumentera funktioner med roxygen2-stil kommentarer
- Inga nya paket utan godkännande

---

## Projektprinciper

1. **Minimalism** – Enklaste lösningen som fungerar
2. **Dokumentera beslut** – Alla val ska motiveras
3. **Fråga hellre än gissa** – Vid osäkerhet, eskalera
