import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Treon 1.0

Item {
    id: jsonTextView
    
    Constants {
        id: constants
    }
    
    property string content: ""
    property bool readOnly: true
    property font font: Qt.font({family: constants.fontFamily, pointSize: constants.fontSizeRegular})
    
    // Property change handlers
    onContentChanged: {
        if (textArea.text !== content) {
            textArea.text = content
        }
    }
    
    onReadOnlyChanged: {
        if (textArea.readOnly !== readOnly) {
            textArea.readOnly = readOnly
        }
    }
    
    onFontChanged: {
        if (textArea.font !== font) {
            textArea.font = font
        }
    }
    
    // Signals
    signal textChanged()
    signal selectionChanged()
    
    ScrollView {
        id: scrollView
        anchors.fill: parent
        
        // Text area
        TextArea {
            id: textArea
            
            // Configuration
            selectByMouse: true
            wrapMode: TextArea.Wrap
            readOnly: jsonTextView.readOnly
            font.family: constants.fontFamily
            font.pixelSize: constants.fontSizeRegular
            font.pointSize: constants.fontSizeRegular
            
            // Styling
            color: constants.colorPrimary
            selectionColor: constants.colorPrimary
            selectedTextColor: "white"
            
            // Background
            background: Rectangle {
                color: constants.colorBackground
                border.color: constants.colorBorder
                border.width: constants.borderNormal
                radius: constants.radiusSmall
            }
            
            // Text formatting
            textFormat: TextArea.PlainText
            
            // Event handlers
            onTextChanged: {
                if (jsonTextView.content !== text) {
                    jsonTextView.content = text
                    jsonTextView.textChanged()
                }
            }
            
            onCursorPositionChanged: {
                jsonTextView.selectionChanged()
            }
        }
    }
}