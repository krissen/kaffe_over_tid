# Estetiska förbättringar för Kaffe över Tid

## Översikt

Detta projekt har genomgått en omfattande estetisk översyn för att ge Shiny-appen och dokumentationen en mer tilltalande och professionell look, inspirerad av Moccamasters tidlösa design och en modern retro-estetik.

## Genomförda ändringar

### 1. Strukturella förändringar

**Uppdelning av app.R**
- **app.R**: Nu endast bootstrapping och konfiguration
- **ui.R**: Separat fil för användargränssnittet
- **server.R**: Separat fil för server-logiken

Detta följer Shiny best practices och gör koden mer underhållbar.

### 2. Visuella förbättringar

#### Färgpalett
Baserad på kaffe och Moccamaster Classic (silver + svart):
- **Primärfärg**: `#3e2723` (Kaffebrun, mörk)
- **Sekundärfärg**: `#6d4c41` (Kaffebrun, mellan)
- **Accentfärg**: `#8d6e63` (Ljus kaffe/latte)
- **Silver**: `#c0c0c0` (Moccamaster Classic)
- **Bakgrund**: `#f5f1ed` (Gräddig/latte-ton)
- **Text**: `#2c2013` (Mörk kaffebrun)

#### Stiländringar (www/styles.css)
- Retro terminal-typografi med Courier New, Monaco, monospace
- Retro-inspirerad design med subtila skuggor och angular design (2px border-radius)
- Responsiv design för olika skärmstorlekar
- Smooth transitions (0.2s) och hover-effekter
- Custom-stilade tabeller, knappar och formulärelement med kaffegradient
- Info-boxar med kaffe-toner
- Fade-in animation vid sidladdning

#### Grafiska element
- **Logotyp**: Moccamaster-logotypen visas i headern
- **Favicon**: Custom favicon skapad från Moccamaster-logon för webbläsarflikar
- **Bilder**: Logo och produktbilder integrerade i README

### 3. Varumärkesintegration

**Moccamaster Classic-märkning**
- Tydligt omnämnande i titeln: "Analys av bryggtid för Moccamaster Classic"
- I plottexten: "Punkterna visar faktiska mätningar från **Moccamaster Classic**"
- I README med produktbilder

### 4. README-förbättringar

- Centerat header-område med logotyp och produktbild
- Emoji-ikoner för bättre visuell struktur
- Tydligare sektionsindelning
- Bättre formaterad information
- Professionell presentation

### 5. Användargränssnitt-förbättringar

#### Header-sektion
- Ny title-panel med logotyp och subtitle
- Modern layout med flexbox
- Moccamaster-branding framträdande

#### Formulär och inputs
- Modernare input-fält med fokus-effekter
- Info-text i stilade boxar
- Tydligare visuell hierarki

#### Tabeller
- Custom-stilade headers med Moccamaster-färger
- Hover-effekter på rader
- Bättre läsbarhet

#### Knappar
- Primära knappar med kaffe-brun gradient (från #6d4c41 till #3e2723)
- Hover-effekter med mörkare gradient och skugga
- Sekundära knappar (nedladdning) med kaffe-brun gradient

#### Flikar (Tabs)
- Retro tab-design med angular form
- Aktiv tab i kaffe-brun färg (`var(--primary-color)`, #3e2723)
- Smooth transitions (0.2s)

## Tekniska detaljer

### Filstruktur
```
www/
├── favicon.ico          # 32x32 favicon från Moccamaster logo-text
├── moccamaster_logo.png # Logotyp för header (max 60px)
└── styles.css           # Custom CSS (~5.4KB)
```

### CSS-funktioner
- CSS Custom Properties (variabler) för enkel färganpassning
- Media queries för responsivitet
- Flexbox för layout
- Keyframe-animationer för subtila effekter

### Kompatibilitet
- Fungerar med alla moderna webbläsare
- Responsiv design för mobil och desktop
- Backward-kompatibel med befintlig funktionalitet

## Design-filosofi

Designen kombinerar:
1. **Retro-estetik**: Enkel, ren design som påminner om klassiska användargränssnitt
2. **Modern användbarhet**: Touch-friendly, responsiv och tillgänglig
3. **Varumärkeskonsistens**: Färger och stil som matchar Moccamaster Classic
4. **Funktionell elegans**: Estetiken stör aldrig funktionaliteten

## Resultat

Den uppdaterade appen är:
- ✅ Mer professionell och tilltalande
- ✅ Tydligare kopplad till Moccamaster-varumärket
- ✅ Lättare att navigera och använda
- ✅ Visuellt konsistent genom hela gränssnittet
- ✅ Fortfarande fullt funktionell med alla befintliga features

## Användning

Starta appen som vanligt:
```bash
Rscript app.R
```

Alla estetiska förändringar laddas automatiskt från `www/`-katalogen.
