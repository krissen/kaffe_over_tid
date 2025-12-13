# Latest Layout Changes (Commit e76e547)

## Summary of Changes

Addressing user feedback to optimize the layout for better content hierarchy and usability.

## Changes Implemented

### 1. ✅ Favicon Verification
- **Action**: Regenerated favicon from `img/moccamaster_logo-text.png`
- **Result**: Favicon now correctly uses the text logo (not the image logo)

### 2. ✅ Header Text Alignment
- **Problem**: Text not aligned with logo edges
- **Solution**: Added flexbox layout to header
  ```css
  .title-panel .text-content {
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    padding: 2px 0;
  }
  ```
- **Result**: Title and subtitle now align perfectly with logo top and bottom edges

### 3. ✅ Plot Tab First
- **Change**: Reordered tabs - Plot is now the default/first tab
- **Tab Order**:
  1. **Plot** (default) - Main visualization
  2. **Data** - Dataset and input form
  3. **Modellinfo** - Model information
- **Rationale**: Plot is the primary visual content

### 4. ✅ Predictions in Sidebar
- **Previous**: Sidebar showed "Aktuell data" (raw data table)
- **New**: Sidebar shows "Prediktioner" 
  - Predictions table (1-10 cups)
  - Download CSV button
- **Rationale**: Predictions are more immediately useful than raw data

### 5. ✅ Data Tab Restructure
- **Previous**: "Lägg till data" tab with only input form
- **New**: "Data" tab includes:
  - **Top section**: "Lägg till ny mätning" (input form)
  - **Bottom section**: "Aktuellt dataset" (raw data table)
- **Rationale**: Combines data viewing and data entry in one place

## UI Structure

```
┌─────────────────────────────────────────────────────────────┐
│ [Logo] Kaffekok: Tid per Kopp                               │
│        Analys av bryggtid för Moccamaster Classic           │
└─────────────────────────────────────────────────────────────┘

┌──────────────────┬──────────────────────────────────────────┐
│ SIDEBAR          │ MAIN CONTENT                             │
├──────────────────┼──────────────────────────────────────────┤
│ Prediktioner     │ [Plot*] [Data] [Modellinfo]              │
│                  │ ─────────────────────────────────────────│
│ Prognoser 1-10   │                                          │
│ koppar           │  [Visualization plot showing data]       │
│                  │                                          │
│ [Table]          │  Tolkning:                               │
│ 1 | 2:31         │  - Points show measurements              │
│ 2 | 2:40         │  - Line shows model                      │
│ ...              │  - Shaded area shows 95% interval        │
│                  │                                          │
│ [Download CSV]   │                                          │
└──────────────────┴──────────────────────────────────────────┘
```

## Benefits

1. **Better Content Hierarchy**: Plot (visual) gets primary position
2. **Quick Access to Predictions**: Available in sidebar without tab switching
3. **Organized Data Management**: All data-related operations in one tab
4. **Visual Balance**: Header text properly aligned with logo
5. **Correct Branding**: Favicon uses appropriate logo variant

## Technical Details

### CSS Changes
- Added `.title-panel .text-content` flexbox container
- Adjusted margins to 0 for precise alignment
- Added `padding: 2px 0` for fine-tuned vertical spacing

### UI Changes (ui.R)
- Wrapped title and subtitle in `.text-content` div
- Moved predictions table to sidebar
- Reordered tabPanel() calls (Plot first)
- Combined "Lägg till data" form with dataset view in "Data" tab
- Renamed tab from "Lägg till data" to "Data"

### Assets
- Favicon regenerated from correct source file

## Result

The interface now provides:
- Immediate access to main visualization (Plot)
- Quick reference to predictions (sidebar)
- Consolidated data operations (Data tab)
- Professional header alignment
- Correct branding throughout
