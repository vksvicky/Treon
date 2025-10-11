import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import Treon 1.0

Window {
    id: aboutDialog
    title: qsTr("About %1").arg(aboutWindow.applicationName)
    width: 500
    height: 650
    minimumWidth: 500
    maximumWidth: 500
    minimumHeight: 650
    maximumHeight: 650
    modality: Qt.WindowModal
    flags: Qt.Window | Qt.WindowTitleHint | Qt.WindowStaysOnTopHint
    
    // Force light theme
    color: "#ffffff"
    
    // Font constants for consistent typography
    readonly property int fontSizeLarge: 24      // App name
    readonly property int fontSizeMedium: 14     // Version, section titles
    readonly property int fontSizeRegular: 12    // Body text, labels, values
    readonly property int fontSizeSmall: 11      // Small text
    readonly property string fontFamily: "Helvetica"
    
    // Simplified spacing system for visual consistency
    readonly property int spacingLarge: 16       // Major section spacing
    readonly property int spacingMedium: 12      // Standard spacing for most elements
    readonly property int spacingSmall: 8        // Tight spacing for related items
    readonly property int spacingTight: 0        // Very tight spacing (title to content)
    
    // Margin constants
    readonly property int marginLarge: 20        // Window margins
    readonly property int marginMedium: 12       // GroupBox title padding
    
    property alias aboutWindow: aboutWindowInstance
    
    AboutWindow {
        id: aboutWindowInstance
        onWebsiteRequested: function(url) {
            console.log("Website requested:", url)
        }
        onDocumentationRequested: function(url) {
            console.log("Documentation requested:", url)
        }
        onSupportRequested: function(url) {
            console.log("Support requested:", url)
        }
        onLicenseRequested: function(url) {
            console.log("License requested:", url)
        }
        onVersionInfoCopied: function(info) {
            console.log("Version info copied:", info)
        }
        onSystemInfoCopied: function(info) {
            console.log("System info copied:", info)
        }
    }
    
    ScrollView {
        anchors.fill: parent
        anchors.margins: marginLarge
        anchors.rightMargin: marginMedium  // Reduce right margin to give more space for content
        contentWidth: width - 20  // Account for scrollbar width
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: ScrollBar.AsNeeded
        
        ColumnLayout {
            width: parent.width
            spacing: spacingLarge
            
            // Header with app icon and name
            RowLayout {
                Layout.fillWidth: true
                spacing: spacingMedium
                
                // App icon
                Image {
                    source: "qrc:/icon.png"
                    width: 64
                    height: 64
                    smooth: true
                    fillMode: Image.PreserveAspectFit
                    
                    // Debug: Add a border to see if the image area is there
                    Rectangle {
                        anchors.fill: parent
                        color: "transparent"
                        border.color: "red"
                        border.width: 1
                        visible: parent.status !== Image.Ready
                    }
                }
                
                // App name and version
                ColumnLayout {
                    spacing: spacingSmall
                    
                    Text {
                        text: aboutWindow.applicationName
                        font.family: fontFamily
                        font.pointSize: fontSizeLarge
                        font.weight: Font.Light
                        color: "#1a1a1a"
                        Layout.alignment: Qt.AlignHCenter
                    }
                                        
                    Text {
                        text: aboutWindow.copyright
                        font.family: fontFamily
                        font.pointSize: fontSizeRegular
                        color: "#999999"
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }
            
            // Description
            Text {
                text: qsTr("A powerful JSON viewer, editor, and formatter built with Qt and C++. " +
                          "Treon provides a modern, native experience for working with JSON data " +
                          "on macOS with advanced features like syntax highlighting, validation, " +
                          "and querying capabilities.")
                font.family: fontFamily
                font.pointSize: 12
                color: "#333333"
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignJustify
            }
            
            // Action buttons
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: spacingMedium
                spacing: spacingMedium
                
                Button {
                    text: qsTr("Website")
                    onClicked: aboutWindow.openWebsite()
                    Layout.preferredWidth: 100
                    Layout.preferredHeight: 32
                    
                    background: Rectangle {
                        color: parent.pressed ? "#e0e0e0" : "#ffffff"
                        radius: 8
                        border.color: "#d1d1d6"
                        border.width: 1
                    }
                    
                    contentItem: Text {
                        text: parent.text
                        font.family: fontFamily
                        font.pointSize: fontSizeRegular
                        font.weight: Font.Medium
                        color: "#007AFF"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                
                Button {
                    text: qsTr("Documentation")
                    onClicked: aboutWindow.openDocumentation()
                    enabled: false
                    Layout.preferredWidth: 100
                    Layout.preferredHeight: 32
                    
                    background: Rectangle {
                        color: parent.enabled ? (parent.pressed ? "#e0e0e0" : "#ffffff") : "#f5f5f5"
                        radius: 8
                        border.color: parent.enabled ? "#d1d1d6" : "#e0e0e0"
                        border.width: 1
                    }
                    
                    contentItem: Text {
                        text: parent.text
                        font.family: fontFamily
                        font.pointSize: fontSizeRegular
                        font.weight: Font.Medium
                        color: parent.enabled ? "#007AFF" : "#999999"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                
                Button {
                    text: qsTr("Support")
                    onClicked: Qt.openUrlExternally("mailto:support@cycleruncode.club")
                    Layout.preferredWidth: 100
                    Layout.preferredHeight: 32
                    
                    background: Rectangle {
                        color: parent.pressed ? "#e0e0e0" : "#ffffff"
                        radius: 8
                        border.color: "#d1d1d6"
                        border.width: 1
                    }
                    
                    contentItem: Text {
                        text: parent.text
                        font.family: fontFamily
                        font.pointSize: fontSizeRegular
                        font.weight: Font.Medium
                        color: "#007AFF"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
            
            // Technical information section
            GroupBox {
                title: qsTr("Technical Information")
                Layout.fillWidth: true
                Layout.topMargin: 8
                
                background: Rectangle {
                    color: "#f8f9fa"
                    border.color: "#e9ecef"
                    border.width: 1
                    radius: 12
                }
                
                label: Text {
                    text: parent.title
                    color: "#1a1a1a"
                    font.family: fontFamily
                    font.pointSize: fontSizeMedium
                    font.weight: Font.DemiBold
                    topPadding: marginMedium
                    leftPadding: marginMedium
                }
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.topMargin: spacingTight // Account for GroupBox title space
                    spacing: spacingMedium
                    
                    // Version info
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Text {
                            text: qsTr("Version:")
                            font.pointSize: fontSizeRegular
                            color: "#666666"
                            Layout.minimumWidth: 120
                        }
                        
                        Text {
                            text: aboutWindow.applicationVersion
                            font.pointSize: fontSizeRegular
                            color: "#1a1a1a"
                            Layout.fillWidth: true
                        }
                    }
                    
                    // Build info
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Text {
                            text: qsTr("Build:")
                            font.pointSize: fontSizeRegular
                            color: "#666666"
                            Layout.minimumWidth: 120
                        }
                        
                        Text {
                            text: aboutWindow.applicationBuild
                            font.pointSize: fontSizeRegular
                            color: "#1a1a1a"
                            Layout.fillWidth: true
                        }
                        
                    }                    
                    
                    // Platform info
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Text {
                            text: qsTr("Platform:")
                            font.pointSize: fontSizeRegular
                            color: "#666666"
                            Layout.minimumWidth: 120
                        }
                        
                        Text {
                            text: aboutWindow.platformInfo
                            font.pointSize: fontSizeRegular
                            color: "#1a1a1a"
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                        }
                    }
                    
                }
            }
            
            // Third-party libraries section
            GroupBox {
                title: qsTr("Build Tools & Libraries")
                Layout.fillWidth: true
                Layout.topMargin: 12
                
                background: Rectangle {
                    color: "#f8f9fa"
                    border.color: "#e9ecef"
                    border.width: 1
                    radius: 12
                }
                
                label: Text {
                    text: parent.title
                    color: "#1a1a1a"
                    font.family: fontFamily
                    font.pointSize: fontSizeMedium
                    font.weight: Font.DemiBold
                    topPadding: marginMedium
                    leftPadding: marginMedium
                }
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.topMargin: spacingTight  // Account for GroupBox title space
                    spacing: spacingMedium
                    
                    // Qt
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Text {
                            text: qsTr("Qt Framework:")
                            font.family: fontFamily
                            font.pointSize: fontSizeRegular
                            color: "#666666"
                            Layout.minimumWidth: 120
                        }
                        
                        Text {
                            text: qsTr("6.9.2 - Cross-platform application framework")
                            font.family: fontFamily
                            font.pointSize: fontSizeRegular
                            color: "#1a1a1a"
                            Layout.fillWidth: true
                        }
                    }
                    
                    // CMake
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Text {
                            text: qsTr("CMake:")
                            font.family: fontFamily
                            font.pointSize: fontSizeRegular
                            color: "#666666"
                            Layout.minimumWidth: 120
                        }
                        
                        Text {
                            text: qsTr("Build system")
                            font.family: fontFamily
                            font.pointSize: fontSizeRegular
                            color: "#1a1a1a"
                            Layout.fillWidth: true
                        }
                    }
                    
                    // Compiler
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Text {
                            text: qsTr("Compiler:")
                            font.family: fontFamily
                            font.pointSize: fontSizeRegular
                            color: "#666666"
                            Layout.minimumWidth: 120
                        }
                        
                        Text {
                            text: aboutWindow.compilerInfo
                            font.family: fontFamily
                            font.pointSize: fontSizeRegular
                            color: "#1a1a1a"
                            Layout.fillWidth: true
                        }
                    }
                    
                    // JSON for Modern C++
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Text {
                            text: qsTr("JSON Library:")
                            font.family: fontFamily
                            font.pointSize: fontSizeRegular
                            color: "#666666"
                            Layout.minimumWidth: 120
                        }
                        
                        Text {
                            text: qsTr("JSON for Modern C++ - JSON library")
                            font.family: fontFamily
                            font.pointSize: fontSizeRegular
                            color: "#1a1a1a"
                            Layout.fillWidth: true
                        }
                    }
                    
                    // Catch2
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Text {
                            text: qsTr("Catch2:")
                            font.family: fontFamily
                            font.pointSize: fontSizeRegular
                            color: "#666666"
                            Layout.minimumWidth: 120
                        }
                        
                        Text {
                            text: qsTr("Testing framework")
                            font.family: fontFamily
                            font.pointSize: fontSizeRegular
                            color: "#1a1a1a"
                            Layout.fillWidth: true
                        }
                    }
                    
                    // Gherkin
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Text {
                            text: qsTr("Gherkin:")
                            font.family: fontFamily
                            font.pointSize: fontSizeRegular
                            color: "#666666"
                            Layout.minimumWidth: 120
                        }
                        
                        Text {
                            text: qsTr("BDD testing")
                            font.family: fontFamily
                            font.pointSize: fontSizeRegular
                            color: "#1a1a1a"
                            Layout.fillWidth: true
                        }
                    }
                }
            }
            
            // License section
            GroupBox {
                title: qsTr("License")
                Layout.fillWidth: true
                Layout.topMargin: 12
                
                background: Rectangle {
                    color: "#f8f9fa"
                    border.color: "#e9ecef"
                    border.width: 1
                    radius: 8
                }
                
                label: Text {
                    text: parent.title
                    color: "#1a1a1a"
                    font.pointSize: 12
                    font.bold: true
                    topPadding: marginMedium
                    leftPadding: marginMedium
                }
                
                Text {
                    text: '<a href="file://' + aboutWindow.licenseFilePath + '">' + aboutWindow.license + '</a>'
                    font.pointSize: 12
                    color: "#007AFF"
                    linkColor: "#007AFF"
                    onLinkActivated: function(link) {
                        Qt.openUrlExternally(link)
                    }
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                }
            }
        }
    }
    
    // Custom close button in top-left corner (current macOS style)
    Button {
        id: closeButton
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: 8
        width: 20
        height: 20
        
        background: Rectangle {
            color: parent.hovered ? "#ff5f57" : "#ff5f57"
            radius: 10
            border.color: parent.hovered ? "#e0443e" : "#ff5f57"
            border.width: 1
        }
        
        contentItem: Text {
            text: "×"
            color: "white"
            font.pointSize: 12
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        
        onClicked: aboutDialog.close()
        
        // Hover effect
        hoverEnabled: true
    }
    
}
