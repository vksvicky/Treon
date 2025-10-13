import QtQuick 2.15

QtObject {
    // Font constants for consistent typography across the app
    readonly property int fontSizeXLarge: 48     // Large headers
    readonly property int fontSizeLarge: 24      // App name, main titles
    readonly property int fontSizeMedium: 14     // Version, section titles, headers
    readonly property int fontSizeRegular: 12    // Body text, labels, values
    readonly property int fontSizeSmall: 11      // Small text
    readonly property int fontSizeXSmall: 10     // Very small text
    readonly property string fontFamily: "Helvetica"
    
    // Font weights
    readonly property int fontWeightLight: Font.Light
    readonly property int fontWeightNormal: Font.Normal
    readonly property int fontWeightMedium: Font.Medium
    readonly property int fontWeightDemiBold: Font.DemiBold
    readonly property int fontWeightBold: Font.Bold
    
    // Spacing system for visual consistency
    readonly property int spacingXLarge: 24      // Major section spacing
    readonly property int spacingLarge: 16       // Section spacing
    readonly property int spacingMedium: 12      // Standard spacing for most elements
    readonly property int spacingSmall: 8        // Tight spacing for related items
    readonly property int spacingTight: 4        // Very tight spacing
    readonly property int spacingNone: 0         // No spacing
    
    // Margin constants
    readonly property int marginXLarge: 24       // Large window margins
    readonly property int marginLarge: 20        // Window margins
    readonly property int marginMedium: 16       // Standard margins
    readonly property int marginSmall: 12        // Small margins
    readonly property int marginTight: 8         // Very tight margins
    
    // Padding constants
    readonly property int paddingLarge: 16       // Large padding
    readonly property int paddingMedium: 12      // Standard padding
    readonly property int paddingSmall: 8        // Small padding
    readonly property int paddingTight: 4        // Very tight padding
    
    // Border radius constants
    readonly property int radiusLarge: 8         // Large rounded corners
    readonly property int radiusMedium: 6        // Standard rounded corners
    readonly property int radiusSmall: 4         // Small rounded corners
    readonly property int radiusTight: 3         // Very small rounded corners
    
    // Border width constants
    readonly property int borderThick: 2         // Thick borders
    readonly property int borderNormal: 1        // Standard borders
    readonly property real borderThin: 0.5       // Thin borders
    
    // Color constants for consistent theming
    readonly property color colorPrimary: "#1d1d1f"        // Primary text
    readonly property color colorSecondary: "#86868b"       // Secondary text
    readonly property color colorTertiary: "#d1d1d6"        // Tertiary text/borders
    readonly property color colorBackground: "#ffffff"      // Background
    readonly property color colorSurface: "#f5f5f7"         // Surface color
    readonly property color colorBorder: "#e1e5e9"          // Border color
    readonly property color colorHover: "#f5f5f7"           // Hover state
    readonly property color colorPressed: "#e9ecef"         // Pressed state
    readonly property color colorSelection: "#e3f2fd"       // Selection background (light blue)
    readonly property color colorSelectionText: "#1976d2"   // Selection text (blue)
    
    // Button dimensions
    readonly property int buttonHeightLarge: 36  // Large buttons
    readonly property int buttonHeightMedium: 32 // Standard buttons
    readonly property int buttonHeightSmall: 28  // Small buttons
    readonly property int buttonHeightTiny: 24   // Tiny buttons
    
    // Header dimensions
    readonly property int headerHeightLarge: 48  // Large headers
    readonly property int headerHeightMedium: 44 // Standard headers
    readonly property int headerHeightSmall: 36  // Small headers
    
    // Window dimensions (matching Swift implementation)
    readonly property int defaultWindowWidth: 1200   // Default window width
    readonly property int defaultWindowHeight: 800   // Default window height
    readonly property int minimumWindowWidth: 800    // Minimum window width
    readonly property int minimumWindowHeight: 600   // Minimum window height
    readonly property int maximumWindowWidth: 2000   // Maximum window width
    readonly property int maximumWindowHeight: 1500  // Maximum window height
    
    // Navigator panel dimensions (matching Swift implementation)
    readonly property int defaultNavigatorWidth: 400  // Default navigator width
    readonly property int minNavigatorWidth: 300      // Minimum navigator width (enough for "Collapse All" button)
    readonly property int maxNavigatorWidth: 600      // Maximum navigator width
    readonly property int collapsedNavigatorWidth: 20 // Collapsed navigator width
}
