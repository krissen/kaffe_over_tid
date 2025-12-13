# Visual Changes - Before and After

## UI Screenshot Description

### Updated Interface (Current)

#### Header Section
```
┌─────────────────────────────────────────────────────────────────┐
│ [Small     │ Kaffekok: Tid per Kopp                             │
│  Coffee    │ Analys av bryggtid för Moccamaster Classic         │
│  Maker     │                                                     │
│  Logo]     │                                                     │
└─────────────────────────────────────────────────────────────────┘
```
- **Background**: Silver gradient (reminiscent of Moccamaster appliance)
- **Height**: Compact (10px padding, small logo ~60px)
- **Logo**: Coffee maker image (moccamaster_logo-bild.jpg)
- **Text**: Dark coffee brown, monospace font
- **Border**: Dark coffee brown bottom border

#### Layout Structure
```
┌─────────────────┬───────────────────────────────────────────────┐
│ SIDEBAR (30%)   │ MAIN CONTENT (70%)                            │
├─────────────────┼───────────────────────────────────────────────┤
│                 │ [Prediktioner] [Plot] [Lägg till] [Info]     │
│ Aktuell data    │ ─────────────────────────────────────────────│
│ ┌─────────────┐ │                                               │
│ │ Koppar | Tid│ │  Prognoser 1-10 koppar                       │
│ │ ──────┼────│ │  Baserat på mätningar från Moccamaster       │
│ │   3   │3:06│ │                                               │
│ │   4   │3:30│ │  [Data table showing predictions]            │
│ │   5   │3:42│ │                                               │
│ │   ... │... │ │  [Download CSV button]                       │
│ └─────────────┘ │                                               │
│                 │                                               │
└─────────────────┴───────────────────────────────────────────────┘
```

#### Color Scheme
- **Page Background**: `#f5f1ed` (cream/latte)
- **Header**: Silver gradient to light gray
- **Text**: Dark coffee brown (`#3e2723`)
- **Accents**: Medium coffee brown (`#6d4c41`)
- **Borders**: Subtle cream (`#d4cdc3`)
- **Buttons**: Coffee brown gradients with subtle text shadow

#### Typography
- **Font**: `Courier New, Monaco, monospace` (retro terminal style)
- **Sizes**: 
  - Body: 0.9em
  - Headings: Reduced sizes (h3: 1.1em, h4: 1.1em)
  - Info text: 0.8em
  - Table text: 0.9em

### Tab Structure (New Order)

1. **Prediktioner** (Default/First Tab) ⭐
   - Main content - predictions table
   - Download button
   - Text: "Baserat på mätningar från Moccamaster Classic"

2. **Plot**
   - Visualization with plot container
   - Interpretation section (reduced text size)

3. **Lägg till data** (Moved from sidebar)
   - Input fields for cups and time
   - Add button
   - Info box with format instructions

4. **Modellinfo**
   - Terminal-style display (dark background)
   - Monospace font on black
   - Light text on dark background

## Key Visual Differences

### Before → After

#### Header
- **Before**: 
  - Large logo (120px)
  - White background with red accent border
  - 20px padding
  - Sans-serif font
  
- **After**:
  - Small logo (60px)
  - Silver gradient background
  - 10px padding
  - Monospace font
  - ~50% height reduction

#### Sidebar
- **Before**:
  - Large heading "Lägg till ny data"
  - Input fields taking up space
  - Multiple info paragraphs
  - Data table below
  
- **After**:
  - Simple heading "Aktuell data"
  - Only data table
  - Much more compact
  - Focus on main content

#### Color Palette
- **Before**: 
  - Red (`#c8102e`) - Moccamaster brand red
  - Blue-gray (`#2c3e50`)
  - Green (`#27ae60`) for success
  - Off-white background
  
- **After**:
  - Dark coffee brown (`#3e2723`)
  - Medium coffee brown (`#6d4c41`)
  - Light coffee/latte (`#8d6e63`)
  - Silver (`#c0c0c0`) - Moccamaster appliance
  - Black (`#1a1a1a`) - coffee black
  - Cream background (`#f5f1ed`)

#### Buttons
- **Before**:
  - Solid red background
  - White text
  - 4px border radius
  - Drop shadow on hover
  
- **After**:
  - Coffee brown gradient
  - White text with text-shadow
  - 2px border radius (more angular)
  - Subtle border

#### Tables
- **Before**:
  - Blue-gray header
  - White background
  - Red hover effect
  - 6px border radius
  
- **After**:
  - Coffee gradient header (light to dark)
  - Cream background
  - Light coffee hover effect
  - Minimal border radius
  - Smaller padding

#### Tabs
- **Before**:
  - [Plot] [Prediktioner] [Modellinfo]
  - Modern rounded tabs
  - Red accent on active
  
- **After**:
  - [Prediktioner] [Plot] [Lägg till data] [Modellinfo]
  - Angular tabs (2px radius)
  - Coffee brown accent on active
  - Gradient background on active

#### Font Style
- **Before**:
  - Helvetica Neue, Helvetica, Arial
  - Modern sans-serif
  - Clean and contemporary
  
- **After**:
  - Courier New, Monaco, monospace
  - Retro terminal/typewriter style
  - Fixed-width characters

## Retro Elements

1. **Monospace Font**: Throughout the entire interface
2. **Angular Design**: Minimal border radius (2px instead of 4-6px)
3. **Terminal Display**: Model info with black background and light text
4. **Gradients**: Subtle gradients on buttons and headers (90s-style)
5. **Compact Spacing**: Tighter padding mimics old terminals
6. **Simple Borders**: 1px borders instead of 2px
7. **Coffee Theme**: Warm browns evoke nostalgic coffee shop feeling

## Coffee & Moccamaster Classic Theme

### Coffee Elements
- **Dark roasted**: Deep browns for primary elements
- **Medium roast**: Warm browns for secondary elements
- **Latte/cream**: Light backgrounds and accents
- **Coffee black**: Text and terminal displays

### Moccamaster Classic Elements
- **Silver**: Metallic gradient in header (appliance body)
- **Black**: Dark accents (appliance base/trim)
- **Compact design**: Efficient use of space (like the appliance)
- **Professional**: Clean, purposeful aesthetic

## Result

The new design successfully combines:
- ✅ Coffee culture aesthetics (browns, cream, latte tones)
- ✅ Moccamaster Classic references (silver, black, compact)
- ✅ Retro computing style (monospace, terminal, angular)
- ✅ Better content hierarchy (predictions first)
- ✅ Reduced visual clutter (compact sidebar)
- ✅ Nostalgic yet functional design
