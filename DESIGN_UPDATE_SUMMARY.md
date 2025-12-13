# Design Update Summary - Addressing User Feedback

## Changes Made (Response to Feedback)

### 1. ✅ Swapped Favicon and Header Logo
- **Favicon**: Now created from `moccamaster_logo-text.png` (32x32)
- **Header logo**: Now uses `moccamaster_logo-bild.jpg` (60x60, reduced from 120px)
- **Rationale**: Better visual representation for each context

### 2. ✅ Reduced Header Height
- **Old**: 20px padding, 15px margin, 120px logo
- **New**: 10px padding, 15px margin, 60px logo
- **Result**: ~50% reduction in header height

### 3. ✅ Reduced Sidebar Text Size & Focus on Content
- **Sidebar now shows**: Only "Aktuell data" table (minimal text)
- **Text sizing**: 
  - Body: 0.9em (down from 1em)
  - Headings: 1.1em for h3/h4 (down from default)
  - Paragraphs: 0.85em
  - Info boxes: 0.8em
- **Layout**: Moved "Lägg till data" to separate tab to declutter sidebar

### 4. ✅ Restructured Layout - Predictions First
- **Tab order**:
  1. **Prediktioner** (first/default tab - the main content)
  2. **Plot** (visualization)
  3. **Lägg till data** (data input - now in its own tab)
  4. **Modellinfo** (model information)
- **Rationale**: Predictions are the primary content/goal

### 5. ✅ Enhanced Retro Feeling
- **Font**: Changed to `'Courier New', 'Monaco', monospace` (retro terminal style)
- **Buttons**: Gradient effects with subtle borders
- **Borders**: Simplified (1px instead of 2px)
- **Border radius**: Reduced to 2px (more angular, retro)
- **Model info**: Dark terminal-style display (black background, light text)
- **Input fields**: Terminal-style with monospace font

### 6. ✅ Coffee & Moccamaster Classic Color Scheme

#### New Color Palette
Based on coffee tones and Moccamaster Classic (silver + black):

| Color | Hex | Usage |
|-------|-----|-------|
| **Dark Roasted Coffee** | `#3e2723` | Primary color, headings |
| **Medium Coffee Brown** | `#6d4c41` | Secondary color, buttons |
| **Light Coffee/Latte** | `#8d6e63` | Accent color, highlights |
| **Silver** | `#c0c0c0` | Moccamaster Classic silver |
| **Dark Silver** | `#a0a0a0` | Borders, accents |
| **Coffee Black** | `#1a1a1a` | Text, terminal background |
| **Cream/Latte** | `#f5f1ed` | Page background |
| **Dark Coffee Text** | `#2c2013` | Body text |
| **Light Coffee Text** | `#6d5d4f` | Secondary text |
| **Cream Border** | `#d4cdc3` | Subtle borders |

#### Previous Color Scheme (Replaced)
- ~~Red `#c8102e` (Moccamaster red)~~
- ~~Blue-gray `#2c3e50`~~
- ~~Green `#27ae60`~~

## Visual Design Philosophy

### Coffee-Inspired Aesthetic
- **Background**: Cream/latte tones evoke coffee with milk
- **Primary colors**: Deep coffee browns from dark roasted beans
- **Accents**: Lighter browns like latte foam
- **Structure**: Silver and black from Moccamaster Classic appliance

### Retro Terminal Style
- Monospace fonts throughout
- Angular design (minimal border radius)
- Terminal-style model info display
- Gradient buttons reminiscent of classic UI elements
- Reduced padding/spacing for compact, efficient layout

## Technical Changes

### CSS Updates
- Complete color variable overhaul
- Font family changed to monospace
- Reduced padding throughout (20px → 12px, 15px → 10px, etc.)
- Simplified borders (2px → 1px)
- Terminal-style pre element (dark background)
- Gradient buttons and table headers
- Header with silver gradient background

### UI Structure Changes
- `ui.R`: Completely restructured
  - Sidebar: Minimal content (just data table)
  - Main panel: 4 tabs with Predictions first
  - Logo size: 120px → 60px
  - Column layout: 2-10 → 1-11 (narrower logo column)

### Asset Changes
- `www/favicon.ico`: Regenerated from logo-text
- `www/moccamaster_logo.png`: Replaced with logo-bild

## Before vs After

### Before
- **Colors**: Red and blue-gray brand colors
- **Layout**: Data input in sidebar (crowded)
- **Typography**: Sans-serif (Helvetica)
- **Header**: Tall with large logo
- **Style**: Modern, colorful

### After
- **Colors**: Coffee browns, silver, black
- **Layout**: Data input in separate tab (focused)
- **Typography**: Monospace (Courier)
- **Header**: Compact with small logo
- **Style**: Retro terminal, coffee-themed

## Result
A cohesive retro design that:
- Honors coffee culture with warm brown tones
- References Moccamaster Classic with silver and black
- Provides better focus on predictions (main content)
- Feels nostalgic with terminal-style elements
- Maintains full functionality while improving UX
