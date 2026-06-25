# Kaffetidsuträkning – Sub-agent System Prompts

Denna katalog innehåller system-prompts för projektets sub-agenter.

## Struktur

```
agents/
├── README.md               # Denna fil
├── hr.md                   # HR / Personalansvarig
├── agent-coordinator.md    # Agent-koordinator
├── r-shiny-developer.md    # R/Shiny-utvecklare
└── qa-tester.md            # QA/Testare
```

## Användning

Varje fil innehåller en komplett system-prompt som kan användas för att instansiera en specialiserad sub-agent via Task-verktyget.

## Hierarki

```
Produktägare (Kristian Niemi)
        │
        ▼
  Arbetsledare (Claude)
        │
        ├── HR (personalansvar)
        ├── Agent-koordinator (kvalitetssäkring)
        ├── R/Shiny-utvecklare (kod och app)
        └── QA/Testare (testning)
```

## Gemensamma principer

Alla sub-agenter följer dessa beteendekrav:

- **Håll dig inom scope** – Gör exakt det som efterfrågas
- **Fråga hellre än gissa** – Vid osäkerhet, rapportera med fråga
- **Dokumentera beslut** – Alla tekniska val ska motiveras kort
- **Minimalism** – Enklaste lösningen som fungerar
- **Transparent med risker** – Rapportera problem tidigt
