import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root

    property alias leftPane: leftPane
    property alias rightPane: rightPane

    RowLayout {
        anchors.fill: parent
        spacing: 10

        // Left pane - JSON Tree
        ScrollView {
            id: leftPane
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width * 0.4
            Layout.minimumWidth: 200

            TreeView {
                id: treeView
                anchors.fill: parent
                model: jsonTreeModel
                
                delegate: TreeViewDelegate {
                    text: model.display || ""
                    indentation: model.depth * 20
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            treeView.currentIndex = index
                            // Emit signal to update right pane
                        }
                    }
                }
            }
        }

        // Splitter
        Rectangle {
            width: 2
            Layout.fillHeight: true
            color: "#cccccc"
        }

        // Right pane - JSON Text
        ScrollView {
            id: rightPane
            Layout.fillHeight: true
            Layout.fillWidth: true

            TextArea {
                id: textArea
                anchors.fill: parent
                text: ""
                font.family: "Monaco, Consolas, 'Courier New', monospace"
                font.pointSize: 12
                selectByMouse: true
                wrapMode: TextArea.Wrap
                
                onTextChanged: {
                    // Validate JSON as user types
                    if (text.length > 0) {
                        app.validateJSON(text)
                    }
                }
            }
        }
    }

    // Placeholder tree model
    ListModel {
        id: jsonTreeModel
        ListElement {
            display: "root"
            depth: 0
        }
    }

    Connections {
        target: app
        function onJsonLoaded(jsonText) {
            textArea.text = jsonText
            // Update tree model here
        }
    }
}
