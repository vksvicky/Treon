import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Treon 1.0

ApplicationWindow {
    id: window
    width: 1200
    height: 800
    visible: true
    title: "Treon JSON Viewer"

    Application {
        id: app
    }

    menuBar: MenuBar {
        Menu {
            title: "File"
            Action {
                text: "Open..."
                shortcut: "Ctrl+O"
                onTriggered: fileDialog.open()
            }
            Action {
                text: "Exit"
                shortcut: "Ctrl+Q"
                onTriggered: Qt.quit()
            }
        }
        Menu {
            title: "View"
            Action {
                text: "Format JSON"
                onTriggered: app.formatJSON(textArea.text)
            }
            Action {
                text: "Validate JSON"
                onTriggered: app.validateJSON(textArea.text)
            }
        }
    }

    FileDialog {
        id: fileDialog
        title: "Open JSON File"
        nameFilters: ["JSON files (*.json)", "All files (*)"]
        onAccepted: app.openFile(fileUrl)
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10

        // Status bar
        RowLayout {
            Layout.fillWidth: true
            Text {
                text: app.currentFile || "No file loaded"
                font.italic: true
            }
            Item { Layout.fillWidth: true }
            Text {
                text: app.isLoading ? "Loading..." : ""
                color: "blue"
            }
            Text {
                text: app.errorMessage
                color: "red"
                visible: app.errorMessage.length > 0
            }
        }

        // Main content area
        TwoPaneLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }
}
