import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15

Item {
    id: root
    
    property alias leftPane: leftPane
    property alias rightPane: rightPane
    
    // Font constants for consistent typography
    readonly property int fontSizeRegular: 12    // Body text, labels, values
    readonly property int fontSizeSmall: 11      // Small text
    readonly property int fontSizeXSmall: 10     // Very small text
    readonly property string fontFamily: "Helvetica"
    
    RowLayout {
        anchors.fill: parent
        spacing: 0
        
        // Left pane - JSON Tree Navigator
        Rectangle {
            id: leftPane
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width * 0.35
            Layout.minimumWidth: 250
            color: "#ffffff"
            border.color: "#d1d1d6"
            border.width: 1
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 8
                
                // Tree header
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 32
                    color: "#f8f9fa"
                    border.color: "#e9ecef"
                    border.width: 1
                    radius: 4
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 8
                        
                        Text {
                            text: "JSON Structure"
                            font.pointSize: fontSizeRegular
                            font.weight: Font.Medium
                            color: "#495057"
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        Button {
                            text: "Expand All"
                            font.pointSize: fontSizeXSmall
                            onClicked: app.expandAllNodes()
                            
                            background: Rectangle {
                                color: parent.pressed ? "#e9ecef" : "transparent"
                                radius: 4
                            }
                        }
                        
                        Button {
                            text: "Collapse All"
                            font.pointSize: fontSizeXSmall
                            onClicked: app.collapseAllNodes()
                            
                            background: Rectangle {
                                color: parent.pressed ? "#e9ecef" : "transparent"
                                radius: 4
                            }
                        }
                    }
                }
                
                // Tree view
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    
                    ListView {
                        id: treeView
                        anchors.fill: parent
                        model: jsonTreeModel
                        
                        delegate: Rectangle {
                            width: treeView.width
                            height: 28
                            color: treeView.currentIndex === index ? "#e3f2fd" : "transparent"
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 4
                                spacing: 8
                                
                                // Expand/collapse button
                                Button {
                                    width: 16
                                    height: 16
                                    text: model.expanded ? "−" : "+"
                                    font.pointSize: fontSizeXSmall
                                    visible: model.hasChildren
                                    onClicked: {
                                        // TODO: Implement expand/collapse
                                    }
                                    
                                    background: Rectangle {
                                        color: parent.pressed ? "#e9ecef" : "transparent"
                                        radius: 2
                                    }
                                }
                                
                                // Node icon
                                Text {
                                    text: {
                                        if (model.type === "object") return "{}"
                                        if (model.type === "array") return "[]"
                                        if (model.type === "string") return "\""
                                        if (model.type === "number") return "#"
                                        if (model.type === "boolean") return "✓"
                                        if (model.type === "null") return "∅"
                                        return "?"
                                    }
                                    font.family: fontFamily
                                    font.pointSize: fontSizeRegular
                                    color: {
                                        if (model.type === "object") return "#007AFF"
                                        if (model.type === "array") return "#34C759"
                                        if (model.type === "string") return "#FF9500"
                                        if (model.type === "number") return "#AF52DE"
                                        if (model.type === "boolean") return "#FF2D92"
                                        if (model.type === "null") return "#8E8E93"
                                        return "#8E8E93"
                                    }
                                }
                                
                                // Node key/name
                                Text {
                                    text: model.key || ""
                                    font.pointSize: fontSizeRegular
                                    color: "#1a1a1a"
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                }
                                
                                // Node value (for primitives)
                                Text {
                                    text: model.value || ""
                                    font.pointSize: fontSizeSmall
                                    font.family: fontFamily
                                    color: "#666666"
                                    visible: model.value !== undefined && model.value !== ""
                                    Layout.maximumWidth: 100
                                    elide: Text.ElideRight
                                }
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    treeView.currentIndex = index
                                    // TODO: Implement navigation to specific JSON path
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // Splitter
        Rectangle {
            width: 2
            Layout.fillHeight: true
            color: "#d1d1d6"
        }
        
        // Right pane - JSON Text Editor with Syntax Highlighting
        Rectangle {
            id: rightPane
            Layout.fillHeight: true
            Layout.fillWidth: true
            color: "#ffffff"
            border.color: "#d1d1d6"
            border.width: 1
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 8
                
                // Editor header
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 32
                    color: "#f8f9fa"
                    border.color: "#e9ecef"
                    border.width: 1
                    radius: 4
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 8
                        
                        Text {
                            text: "JSON Editor"
                            font.pointSize: fontSizeRegular
                            font.weight: Font.Medium
                            color: "#495057"
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        // Format buttons
                        Button {
                            text: "Format"
                            font.pointSize: fontSizeXSmall
                            onClicked: app.formatJSON(textArea.text)
                            
                            background: Rectangle {
                                color: parent.pressed ? "#e9ecef" : "transparent"
                                radius: 4
                            }
                        }
                        
                        Button {
                            text: "Minify"
                            font.pointSize: fontSizeXSmall
                            onClicked: app.minifyJSON(textArea.text)
                            
                            background: Rectangle {
                                color: parent.pressed ? "#e9ecef" : "transparent"
                                radius: 4
                            }
                        }
                        
                        Button {
                            text: "Validate"
                            font.pointSize: fontSizeXSmall
                            onClicked: app.validateJSON(textArea.text)
                            
                            background: Rectangle {
                                color: parent.pressed ? "#e9ecef" : "transparent"
                                radius: 4
                            }
                        }
                    }
                }
                
                // Text editor with syntax highlighting
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    
                    TextArea {
                        id: textArea
                        text: app.jsonText
                        font.family: fontFamily
                                    font.pointSize: fontSizeRegular
                        selectByMouse: true
                        wrapMode: app.wordWrap ? TextArea.Wrap : TextArea.NoWrap
                        color: "#1a1a1a"
                        background: Rectangle {
                            color: "#ffffff"
                        }
                        
                        onTextChanged: {
                            // Validate JSON as user types
                            if (text.length > 0) {
                                app.validateJSON(text)
                            }
                            // TODO: Implement proper JSON syntax highlighting
                            // This would require a custom TextEdit with syntax highlighting
                        }
                    }
                }
            }
        }
    }
    
    // Placeholder tree model
    ListModel {
        id: jsonTreeModel
        ListElement {
            key: "root"
            type: "object"
            hasChildren: true
            expanded: true
            value: ""
        }
        ListElement {
            key: "example"
            type: "string"
            hasChildren: false
            expanded: false
            value: "Hello World"
        }
        ListElement {
            key: "count"
            type: "number"
            hasChildren: false
            expanded: false
            value: "42"
        }
        ListElement {
            key: "items"
            type: "array"
            hasChildren: true
            expanded: false
            value: ""
        }
    }
    
    Connections {
        target: app
        function onJsonLoaded(jsonText) {
            textArea.text = jsonText
            // TODO: Update tree model with parsed JSON structure
        }
    }
}
