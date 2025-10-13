import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Treon 1.0

Item {
    id: root
    
    Constants {
        id: constants
    }
    
    property alias leftPane: leftPane
    property alias rightPane: rightPane
    
    // Navigator panel state (matching Swift implementation)
    property real navigatorWidth: constants.defaultNavigatorWidth
    property bool isNavigatorCollapsed: false
    property bool isNavigatorPinned: false
    property bool isDragging: false
    
    // Navigator panel constraints (matching Swift implementation)
    readonly property real minNavigatorWidth: constants.minNavigatorWidth
    readonly property real maxNavigatorWidth: constants.maxNavigatorWidth
    
    // Debug: Log navigator width changes
    onNavigatorWidthChanged: {
        console.log("Navigator width changed to:", navigatorWidth, "min:", minNavigatorWidth, "max:", maxNavigatorWidth)
    }
    
    Component.onCompleted: {
        console.log("TwoPaneLayout initialized with navigator width:", navigatorWidth, "min:", minNavigatorWidth, "max:", maxNavigatorWidth)
    }
    
    // Use global constants for consistent typography
    
    RowLayout {
        anchors.fill: parent
        spacing: 0
        
               // Left pane - JSON Tree Navigator (matching Swift implementation)
               Rectangle {
                   id: leftPane
                   Layout.fillHeight: true
                   Layout.preferredWidth: root.isNavigatorCollapsed ? constants.collapsedNavigatorWidth : Math.max(root.minNavigatorWidth, Math.min(root.maxNavigatorWidth, root.navigatorWidth))
                   Layout.minimumWidth: root.isNavigatorCollapsed ? constants.collapsedNavigatorWidth : root.minNavigatorWidth
                   Layout.maximumWidth: root.isNavigatorCollapsed ? constants.collapsedNavigatorWidth : root.maxNavigatorWidth
                   color: "#282a36" // Dadroit dark background
                   border.color: "#44475a" // Dadroit border color
                   border.width: constants.borderNormal
                   visible: !root.isNavigatorCollapsed
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 8
                
                // Tree header - using global constants
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 32
                    color: "#44475a" // Dadroit header background
                    border.color: "#6272a4" // Dadroit border
                    border.width: constants.borderNormal
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 8
                        
                        // Collapse/Expand button (matching Swift implementation)
                        Text {
                            text: root.isNavigatorCollapsed ? "▶" : "◀"
                            font.family: constants.fontFamily
                            font.pixelSize: 12
                            color: root.isNavigatorPinned ? "#6272a4" : "#8be9fd"
                            Layout.alignment: Qt.AlignVCenter
                            width: 16
                            horizontalAlignment: Text.AlignHCenter
                            
                            MouseArea {
                                anchors.fill: parent
                                enabled: !root.isNavigatorPinned
                                onClicked: {
                                    root.isNavigatorCollapsed = !root.isNavigatorCollapsed
                                }
                            }
                        }
                        
                        Text {
                            text: "Navigator"
                            font.family: constants.fontFamily
                            font.pixelSize: 14
                            font.weight: Font.Medium
                            color: "#f8f8f2" // Dadroit foreground
                            Layout.alignment: Qt.AlignVCenter
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        // Pin/Unpin button (matching Swift implementation)
                        Text {
                            text: root.isNavigatorPinned ? "🔒" : "🔓"
                            font.pixelSize: 12
                            color: root.isNavigatorPinned ? "#8be9fd" : "#6272a4"
                            Layout.alignment: Qt.AlignVCenter
                            width: 16
                            horizontalAlignment: Text.AlignHCenter
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    root.isNavigatorPinned = !root.isNavigatorPinned
                                }
                            }
                        }
                        
                        // Dadroit-style buttons
                        Text {
                            text: "Expand All"
                            font.family: constants.fontFamily
                            font.pixelSize: 12
                            color: "#8be9fd" // Dadroit cyan
                            Layout.alignment: Qt.AlignVCenter
                            
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: app.expandAllNodes()
                                
                                onEntered: parent.color = "#50fa7b" // Dadroit green
                                onExited: parent.color = "#8be9fd" // Dadroit cyan
                            }
                        }
                        
                        Text {
                            text: "Collapse All"
                            font.family: constants.fontFamily
                            font.pixelSize: 12
                            color: "#8be9fd" // Dadroit cyan
                            Layout.alignment: Qt.AlignVCenter
                            
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: app.collapseAllNodes()
                                
                                onEntered: parent.color = "#50fa7b" // Dadroit green
                                onExited: parent.color = "#8be9fd" // Dadroit cyan
                            }
                        }
                    }
                }
                
                // Tree view
                JSONTreeView {
                    id: treeView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    
                    onItemSelected: function(index) {
                        // Handle item selection
                        console.log("Item selected:", index)
                    }
                    
                    onItemDoubleClicked: function(index) {
                        // Handle item double click
                        console.log("Item double clicked:", index)
                    }
                }
            }
        }
        
        // Collapsed navigator indicator (matching Swift implementation)
        Rectangle {
            id: collapsedNavigatorIndicator
            Layout.fillHeight: true
            Layout.preferredWidth: constants.collapsedNavigatorWidth
            color: "#282a36"
            border.color: "#44475a"
            border.width: constants.borderNormal
            visible: root.isNavigatorCollapsed
            
            ColumnLayout {
                anchors.fill: parent
                spacing: 0
                
                Item { Layout.fillHeight: true }
                
                Text {
                    text: "▶"
                    font.family: constants.fontFamily
                    font.pixelSize: 10
                    color: root.isNavigatorPinned ? "#6272a4" : "#8be9fd"
                    Layout.alignment: Qt.AlignHCenter
                    horizontalAlignment: Text.AlignHCenter
                    
                    MouseArea {
                        anchors.fill: parent
                        enabled: !root.isNavigatorPinned
                        onClicked: {
                            root.isNavigatorCollapsed = false
                        }
                    }
                }
                
                Item { Layout.fillHeight: true }
            }
        }
        
        // Resize handle (matching Swift implementation)
        Rectangle {
            id: resizeHandle
            width: 1
            Layout.fillHeight: true
            color: "#6272a4"
            visible: !root.isNavigatorCollapsed && !root.isNavigatorPinned
            
            MouseArea {
                anchors.fill: parent
                anchors.margins: -4
                cursorShape: Qt.SplitHCursor
                hoverEnabled: true
                
                onPressed: {
                    root.isDragging = true
                }
                
                onReleased: {
                    root.isDragging = false
                }
                
                onMouseXChanged: {
                    if (root.isDragging) {
                        var newWidth = root.navigatorWidth + mouseX
                        var constrainedWidth = Math.max(root.minNavigatorWidth, Math.min(root.maxNavigatorWidth, newWidth))
                        console.log("Resizing navigator from", root.navigatorWidth, "to", constrainedWidth, "(requested:", newWidth, ")")
                        root.navigatorWidth = constrainedWidth
                    }
                }
            }
        }
        
        // Right pane - JSON Text Editor with Syntax Highlighting
        Rectangle {
            id: rightPane
            Layout.fillHeight: true
            Layout.fillWidth: true
                   color: "#282a36" // Dadroit dark background
                   border.color: "#44475a" // Dadroit border color
                   border.width: constants.borderNormal
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 8
                
                       // Editor header - Dadroit style
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 32
                           color: "#44475a" // Dadroit header background
                           border.color: "#6272a4" // Dadroit border
                           border.width: constants.borderNormal
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: constants.marginMedium
                        anchors.rightMargin: constants.marginMedium
                        anchors.topMargin: constants.paddingSmall
                        anchors.bottomMargin: constants.paddingSmall
                        spacing: constants.spacingLarge
                        
                        Text {
                            text: "JSON Editor"
                                   font.family: constants.fontFamily
                                   font.pixelSize: 14
                            font.weight: Font.Medium
                                   color: "#f8f8f2" // Dadroit foreground
                                   Layout.alignment: Qt.AlignVCenter
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        // Dadroit-style buttons
                        Text {
                            text: "Format"
                            font.family: constants.fontFamily
                            font.pixelSize: 12
                            color: "#8be9fd" // Dadroit cyan
                            Layout.alignment: Qt.AlignVCenter
                            
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: app.formatJSON(textArea.text)
                                
                                onEntered: parent.color = "#50fa7b" // Dadroit green
                                onExited: parent.color = "#8be9fd" // Dadroit cyan
                            }
                        }
                        
                        Text {
                            text: "Minify"
                            font.family: constants.fontFamily
                            font.pixelSize: 12
                            color: "#8be9fd" // Dadroit cyan
                            Layout.alignment: Qt.AlignVCenter
                            
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: app.minifyJSON(textArea.text)
                                
                                onEntered: parent.color = "#50fa7b" // Dadroit green
                                onExited: parent.color = "#8be9fd" // Dadroit cyan
                            }
                        }
                        
                        Text {
                            text: "Validate"
                            font.family: constants.fontFamily
                            font.pixelSize: 12
                            color: "#8be9fd" // Dadroit cyan
                            Layout.alignment: Qt.AlignVCenter
                            
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: app.validateJSON(textArea.text)
                                
                                onEntered: parent.color = "#50fa7b" // Dadroit green
                                onExited: parent.color = "#8be9fd" // Dadroit cyan
                            }
                        }
                    }
                }
                
                // Text editor with syntax highlighting
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    
                    JSONTextView {
                        id: textArea
                        anchors.fill: parent
                        content: app.jsonText
                        readOnly: false
                        
                        onTextChanged: {
                            // Update the JSON model when text changes
                            app.validateJSON(content)
                        }
                    }
                }
            }
        }
    }
    
    // Tree model is now handled inside JSONTreeView
    
    // Function to populate the ListModel from JSON data
    function updateJSONModel() {
        console.log("updateJSONModel called")
        // Use a timer to debounce rapid updates
        updateTimer.restart()
    }
    
    Timer {
        id: updateTimer
        interval: 50 // 50ms debounce
        repeat: false
        onTriggered: {
            console.log("Timer triggered, getting JSON flat list from app")
            var flatList = app.getJSONFlatList()
            console.log("Got flat list with", flatList.length, "items")
            if (flatList.length > 0) {
                console.log("First item:", JSON.stringify(flatList[0]))
            }
            treeView.updateTreeModel(flatList)
        }
    }
    
    Connections {
        target: app
        function onJsonLoaded(jsonText) {
            console.log("onJsonLoaded signal received, updating JSON model")
            textArea.content = jsonText
            updateJSONModel()
        }
        
        function onJsonModelChanged() {
            console.log("onJsonModelChanged signal received, updating JSON model")
            updateJSONModel()
        }
        
        function onJsonModelUpdated() {
            console.log("onJsonModelUpdated signal received from app, updating JSON model")
            updateJSONModel()
        }
    }
    
    Connections {
        target: app.jsonModel
        function onLayoutChanged() {
            console.log("Layout changed signal received from jsonModel, updating JSON model")
            updateJSONModel()
        }
    }
    
    // Alternative connection to app directly
    Connections {
        target: app
        function onJsonModelChanged() {
            console.log("JsonModel changed signal received from app, updating JSON model")
            updateJSONModel()
        }
    }
}