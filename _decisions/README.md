# Arkitekturbeslut (ADR)

Denna katalog innehåller Architecture Decision Records (ADR) för projektet.

## Format

Varje beslut dokumenteras i en fil med formatet `NNNN-kort-titel.md`:

- 0001-val-av-databas.md
- 0002-api-design-principer.md
- etc.

## Mall

```markdown
# [Nummer]. [Titel]

**Status:** [Förslag | Accepterat | Förkastat | Ersatt av NNNN]
**Datum:** [YYYY-MM-DD]

## Kontext

[Vilken situation/problem adresserar detta beslut?]

## Beslut

[Vad är beslutet?]

## Underlag

[OBLIGATORISKT - Referens till research i research/_analys/]

- Se `../research/_analys/[fil]__primer.md`

## Konsekvenser

[Positiva och negativa konsekvenser av beslutet]
```
