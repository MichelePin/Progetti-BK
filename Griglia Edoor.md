

## Comprehensive Grid System Overview

### **Core Files Involved in Grid Creation**

#### **1. Model Classes**
- **`Field.ts`** - Defines the main field configuration with 50+ properties for customization
- **`FieldOption.ts`** - Options for select/assist-edit fields
- **`EditableGridModel.ts`** - Core grid model managing rows, columns, selection, and behavior
- **`PageModel.ts`** - Page-level model containing grid references and selection state

#### **2. Configuration Classes**
- **`GridModelConfig.ts`** - Main grid configuration parser (from JSON)
- **`TableJsonConfig.ts`** - Type-safe JSON configuration structure
- **`GridModelParams.ts`** - Parameters for grid creation
- **`GridBuilderParams.ts`** - Builder parameters for component creation

#### **3. Template Classes**
- **`GridModelTemplate.ts`** - Template data for rendering (column counts, visibility flags)
- **`LoadTemplate.ts`** - Template for pagination/loading controls

#### **4. Component Classes**
- **`EditableGridTableComponent.ts`** - Main grid component
- **`SectionGridTableComponent.ts`** - Wrapper component with section styling
- **`DualTableTemplateComponent.ts`** - For dual-grid pages

#### **5. Styling Classes**
- **`FieldStyle.ts`** - Base styling properties
- **`ConditionalFieldStyle.ts`** - Conditional styling based on data
- **`GridUtils.ts`** - Utility functions for style application

#### **6. Page Data Classes**
- **`TablePageData.ts`** - Base table page functionality
- **`FilterTablePageData.ts`** - Extended with filtering capabilities
- **`DualTablePageData.ts`** - For pages with two grids

### **Field Configuration Properties**

The `Field` class contains extensive customization options:

#### **Basic Properties**
- `name` - Field identifier
- `caption` - Display header
- `type` - Field type (text, checkbox, image, progressBar, assistEdit, etc.)
- `align` - Text alignment
- `editable` - Whether field is editable

#### **Display & Formatting**
- `format` - Date/number formatting
- `hideCaption` - Hide column header
- `hideIfNull`, `hideIfNegative` - Conditional visibility
- `hideIf`, `hideIfNot` - Hide based on value arrays
- `transform` - CSS transform
- `innerHtml` - Allow HTML content
- `replaceNewLines` - Handle line breaks

#### **Styling Properties**
- `style` - Base FieldStyle object
- `styleIf` - Array of ConditionalFieldStyle for conditional formatting
- `styleFontSize`, `styleHeaderFontSize` - Font sizes
- `class` - CSS class
- `cellWidth`, `headerWidth` - Column dimensions
- `borderRadius`, `marginLeft` - CSS properties

#### **Advanced Features**
- `formula` - Mathematical calculations between fields
- `convertValueIf` - Conditional value conversion
- `valueIf`, `valueIfNot` - Display different values based on conditions
- `fieldArray` - Concatenate multiple field values
- `modalList`, `modalPage` - Modal interactions
- `assistEditConfig`, `assistEditEnable` - Assist-edit functionality
- `options` - Select field options

### **Styling System**

#### **FieldStyle Properties**
```typescript
export class FieldStyle {
    background?: string;           // Cell background color
    color?: string;               // Text color
    isBold?: boolean;             // Bold text
    animationDuration?: number;   // Animation effects
    ignoreSelection?: boolean;    // Don't apply selection styling
    progressBarBackground?: string; // Progress bar styling
    showProgressBarValue?: boolean; // Show value in progress bar
    description?: {               // Dynamic description
        fieldName: string;
        text: string;
    };
}
```

#### **ConditionalFieldStyle System**
```typescript
export class ConditionalFieldStyle extends FieldStyle {
    condition?: IfCondition;      // Single condition
    conditionList?: IfCondition[]; // Multiple conditions (AND logic)
}
```

#### **Condition Types**
```

- `=`, `==`, `!=`, `<>` - Equality comparisons
- `<`, `>`, `<=`, `>=` - Numeric comparisons  
- `IN` - Value in array
- `ISNULL` - Null checking

```
### **Grid Creation Process**

#### **1. JSON Configuration**
```typescript
const tableConfig = {
    Fields: [
        {
            name: "ProductName",
            caption: "Product",
            type: "text",
            styleIf: [{
                condition: { sourceField: "Status", compareType: "=", value: "Active" },
                background: "#90EE90",
                isBold: true
            }]
        }
    ],
    Style: { fontSize: 14, headerFontSize: 16 },
    HideHeader: false,
    MaxRecords: 50
};
```

#### **2. Grid Model Creation**
```typescript
// In TablePageData.createGridModel()
const config = new GridModelConfig(this.pageConfig.Table);
const gridModel = new EditableGridModel(rows, config, params);
this.pageModel.gridModel = gridModel;
```

#### **3. Component Binding**
```html
<editable-grid-table 
    [gridModel]="pageModel.gridModel"
    [pageData]="pageData">
</editable-grid-table>
```

### **Key Customization Features**

#### **1. Conditional Formatting**
- Cell background colors based on data values
- Text color and bold formatting
- Show/hide fields dynamically
- Progress bars with custom styling
- Animated cells (blinking effects)

#### **2. Interactive Elements**
- Checkbox columns for selection
- Modal dialogs for field editing
- Assist-edit fields with search capabilities
- First/last action buttons per row
- Manual row sorting

#### **3. Search & Filtering**
- Real-time search across multiple fields
- Auto-selection based on search results
- Custom search field configuration
- Filter persistence

#### **4. Column Management**
- User-configurable column visibility
- Column reordering via drag-and-drop
- Column width customization
- Header styling options

#### **5. Pagination & Loading**
- Block-based pagination
- Infinite scroll support
- Loading indicators
- Record count display

### **Advanced Configuration Options**

#### **Grid-Level Settings**
- `alwaysActive` - Keep grid always selectable
- `multipleSelection` - Enable row selection checkboxes
- `manualSorting` - Allow drag-to-reorder rows
- `hideHeader`, `hideSearchbar` - UI visibility
- `autoFocusSearchbar` - Automatic search focus
- `enterAction` - Define Enter key behavior

#### **Field-Level Validations**
- `validateMaxLength` - Character limits
- `allowNegative` - Numeric constraints
- `resetOnFocus` - Clear field on focus

#### **Image & Media Support**
- `imageFieldName` - Display images in cells
- `imgWidth` - Image sizing
- Image mapping for different values

### **Integration Points**

The grid system integrates with:
- **Factbox system** - For detail panels
- **Calculator sidebar** - For data entry
- **Modal dialogs** - For complex editing
- **Action framework** - For button interactions
- **Page navigation** - For multi-table scenarios

This grid system provides exceptional flexibility for creating data tables with rich formatting, interactive features, and dynamic behavior based on data conditions.