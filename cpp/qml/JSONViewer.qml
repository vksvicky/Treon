import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: root
    
    property string jsonText: ""
    property bool isValid: false
    property string errorMessage: ""

    Column {
        anchors.fill: parent
        spacing: 10

        // Validation status
        Rectangle {
            width: parent.width
            height: 30
            color: root.isValid ? "#d4edda" : "#f8d7da"
            border.color: root.isValid ? "#c3e6cb" : "#f5c6cb"
            radius: 4

            Text {
                anchors.centerIn: parent
                text: root.isValid ? "✓ Valid JSON" : "✗ Invalid JSON"
                color: root.isValid ? "#155724" : "#721c24"
                font.bold: true
            }
        }

        // Error message
        Text {
            visible: root.errorMessage.length > 0
            text: root.errorMessage
            color: "#721c24"
            wrapMode: Text.WordWrap
            width: parent.width
        }

        // JSON content
        ScrollView {
            width: parent.width
            height: parent.height - (parent.children.length - 1) * 10 - 30

            TextArea {
                text: root.jsonText
                font.family: "Monaco, Consolas, 'Courier New', monospace"
                font.pointSize: 12
                selectByMouse: true
                wrapMode: TextArea.Wrap
                readOnly: true
            }
        }
    }
}
