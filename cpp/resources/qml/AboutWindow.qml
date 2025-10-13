import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import Treon 1.0

Window {
    id: aboutDialog
    title: qsTr("About %1").arg(aboutWindow.applicationName)
    width: 500
    height: 675
    minimumWidth: 500
    maximumWidth: 500
    minimumHeight: 675
    maximumHeight: 675
    modality: Qt.WindowModal
    flags: Qt.Window | Qt.WindowTitleHint | Qt.WindowStaysOnTopHint
    
    Constants {
        id: constants
    }
    
    // Force light theme
    color: constants.colorBackground
    
    // Using global constants for consistent typography and spacing
    
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
                anchors.margins: constants.marginLarge
        anchors.rightMargin: constants.marginMedium  // Reduce right margin to give more space for content
        contentWidth: width - 20  // Account for scrollbar width
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: ScrollBar.AsNeeded
        
        ColumnLayout {
            width: parent.width
            spacing: constants.spacingLarge
            
            // Header with app icon and name
            RowLayout {
                Layout.fillWidth: true
                spacing: constants.spacingMedium
                
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
                    spacing: constants.spacingSmall
                    
                    Text {
                        text: aboutWindow.applicationName
                        font.family: constants.fontFamily
                        font.pointSize: constants.fontSizeLarge
                        font.weight: Font.Light
                        color: constants.colorPrimary
                        Layout.alignment: Qt.AlignHCenter
                    }
                                        
                    Text {
                        text: aboutWindow.copyright
                        font.family: constants.fontFamily
                        font.pointSize: constants.fontSizeRegular
                        color: constants.colorSecondary
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
                font.family: constants.fontFamily
                font.pointSize: 12
                color: constants.colorPrimary
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignJustify
            }
            
            // Action buttons
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: constants.spacingMedium
                spacing: constants.spacingMedium
                
                Button {
                    text: qsTr("Website")
                    onClicked: aboutWindow.openWebsite()
                    Layout.preferredWidth: 100
                    Layout.preferredHeight: 32
                    
                    background: Rectangle {
                        color: parent.pressed ? constants.colorPressed : constants.colorBackground
                        radius: 8
                        border.color: constants.colorTertiary
                        border.width: 1
                    }
                    
                    contentItem: Text {
                        text: parent.text
                        font.family: constants.fontFamily
                        font.pointSize: constants.fontSizeRegular
                        font.weight: Font.Medium
                        color: constants.colorPrimary
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
                        color: parent.enabled ? (parent.pressed ? constants.colorPressed : constants.colorBackground) : constants.colorSurface
                        radius: 8
                        border.color: parent.enabled ? constants.colorTertiary : constants.colorPressed
                        border.width: 1
                    }
                    
                    contentItem: Text {
                        text: parent.text
                        font.family: constants.fontFamily
                        font.pointSize: constants.fontSizeRegular
                        font.weight: Font.Medium
                        color: parent.enabled ? constants.colorPrimary : constants.colorSecondary
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
                        color: parent.pressed ? constants.colorPressed : constants.colorBackground
                        radius: 8
                        border.color: constants.colorTertiary
                        border.width: 1
                    }
                    
                    contentItem: Text {
                        text: parent.text
                        font.family: constants.fontFamily
                        font.pointSize: constants.fontSizeRegular
                        font.weight: Font.Medium
                        color: constants.colorPrimary
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
                    color: constants.colorSurface
                    border.color: constants.colorBorder
                    border.width: 1
                    radius: 12
                }
                
                label: Text {
                    text: parent.title
                    color: constants.colorPrimary
                    font.family: constants.fontFamily
                    font.pointSize: constants.fontSizeMedium
                    font.weight: Font.DemiBold
                    topPadding: constants.marginMedium
                    leftPadding: constants.marginMedium
                }
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.topMargin: constants.spacingTight // Account for GroupBox title space
                    spacing: constants.spacingMedium
                    
                    // Version info
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Text {
                            text: qsTr("Version:")
                            font.pointSize: constants.fontSizeRegular
                            color: constants.colorSecondary
                            Layout.minimumWidth: 120
                        }
                        
                        Text {
                            text: aboutWindow.applicationVersion
                            font.pointSize: constants.fontSizeRegular
                            color: constants.colorPrimary
                            Layout.fillWidth: true
                        }
                    }
                    
                    // Build info
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Text {
                            text: qsTr("Build:")
                            font.pointSize: constants.fontSizeRegular
                            color: constants.colorSecondary
                            Layout.minimumWidth: 120
                        }
                        
                        Text {
                            text: aboutWindow.applicationBuild
                            font.pointSize: constants.fontSizeRegular
                            color: constants.colorPrimary
                            Layout.fillWidth: true
                        }
                        
                    }                    
                    
                    // Platform info
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Text {
                            text: qsTr("Platform:")
                            font.pointSize: constants.fontSizeRegular
                            color: constants.colorSecondary
                            Layout.minimumWidth: 120
                        }
                        
                        Text {
                            text: aboutWindow.platformInfo
                            font.pointSize: constants.fontSizeRegular
                            color: constants.colorPrimary
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
                    color: constants.colorSurface
                    border.color: constants.colorBorder
                    border.width: 1
                    radius: 12
                }
                
                label: Text {
                    text: parent.title
                    color: constants.colorPrimary
                    font.family: constants.fontFamily
                    font.pointSize: constants.fontSizeMedium
                    font.weight: Font.DemiBold
                    topPadding: constants.marginMedium
                    leftPadding: constants.marginMedium
                }
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.topMargin: constants.spacingTight  // Account for GroupBox title space
                    spacing: constants.spacingMedium
                    
                    // Qt
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Text {
                            text: qsTr("Qt Framework:")
                            font.family: constants.fontFamily
                            font.pointSize: constants.fontSizeRegular
                            color: constants.colorSecondary
                            Layout.minimumWidth: 120
                        }
                        
                        Text {
                            text: qsTr("6.9.2 - Cross-platform application framework")
                            font.family: constants.fontFamily
                            font.pointSize: constants.fontSizeRegular
                            color: constants.colorPrimary
                            Layout.fillWidth: true
                        }
                    }
                    
                    // CMake
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Text {
                            text: qsTr("CMake:")
                            font.family: constants.fontFamily
                            font.pointSize: constants.fontSizeRegular
                            color: constants.colorSecondary
                            Layout.minimumWidth: 120
                        }
                        
                        Text {
                            text: qsTr("Build system")
                            font.family: constants.fontFamily
                            font.pointSize: constants.fontSizeRegular
                            color: constants.colorPrimary
                            Layout.fillWidth: true
                        }
                    }
                    
                    // Compiler
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Text {
                            text: qsTr("Compiler:")
                            font.family: constants.fontFamily
                            font.pointSize: constants.fontSizeRegular
                            color: constants.colorSecondary
                            Layout.minimumWidth: 120
                        }
                        
                        Text {
                            text: aboutWindow.compilerInfo
                            font.family: constants.fontFamily
                            font.pointSize: constants.fontSizeRegular
                            color: constants.colorPrimary
                            Layout.fillWidth: true
                        }
                    }
                    
                    // JSON for Modern C++
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Text {
                            text: qsTr("JSON Library:")
                            font.family: constants.fontFamily
                            font.pointSize: constants.fontSizeRegular
                            color: constants.colorSecondary
                            Layout.minimumWidth: 120
                        }
                        
                        Text {
                            text: qsTr("JSON for Modern C++ - JSON library")
                            font.family: constants.fontFamily
                            font.pointSize: constants.fontSizeRegular
                            color: constants.colorPrimary
                            Layout.fillWidth: true
                        }
                    }
                    
                    // Catch2
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Text {
                            text: qsTr("Catch2:")
                            font.family: constants.fontFamily
                            font.pointSize: constants.fontSizeRegular
                            color: constants.colorSecondary
                            Layout.minimumWidth: 120
                        }
                        
                        Text {
                            text: qsTr("Testing framework")
                            font.family: constants.fontFamily
                            font.pointSize: constants.fontSizeRegular
                            color: constants.colorPrimary
                            Layout.fillWidth: true
                        }
                    }
                    
                    // Gherkin
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Text {
                            text: qsTr("Gherkin:")
                            font.family: constants.fontFamily
                            font.pointSize: constants.fontSizeRegular
                            color: constants.colorSecondary
                            Layout.minimumWidth: 120
                        }
                        
                        Text {
                            text: qsTr("BDD testing")
                            font.family: constants.fontFamily
                            font.pointSize: constants.fontSizeRegular
                            color: constants.colorPrimary
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
                    color: constants.colorSurface
                    border.color: constants.colorBorder
                    border.width: 1
                    radius: 8
                }
                
                label: Text {
                    text: parent.title
                    color: constants.colorPrimary
                    font.pointSize: 12
                    font.bold: true
                    topPadding: constants.marginMedium
                    leftPadding: constants.marginMedium
                }
                
                Text {
                    text: '<a href="file://' + aboutWindow.licenseFilePath + '">' + aboutWindow.license + '</a>'
                    font.pointSize: 12
                    color: constants.colorPrimary
                    linkColor: constants.colorPrimary
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
