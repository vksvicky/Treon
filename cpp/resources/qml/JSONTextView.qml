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
    property color borderColor: constants.colorBorder
    property int cursorPosition: 0
    
    // Error highlighting properties
    property int errorLine: -1
    property int errorColumn: -1
    property string errorMessage: ""
    property bool hasError: false
    
    // Property change handlers for cursor position
    onCursorPositionChanged: {
        if (textArea.cursorPosition !== cursorPosition) {
            textArea.cursorPosition = cursorPosition
        }
    }
    
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
    
    // Helper function to convert character offset to line/column
    function offsetToLineColumn(offset) {
        if (offset < 0 || offset > content.length) {
            return { line: -1, column: -1 };
        }
        
        var lines = content.substring(0, offset).split('\n');
        var line = lines.length - 1;
        var column = lines[lines.length - 1].length;
        
        return { line: line, column: column };
    }
    
    // Function to set error highlighting
    function setError(line, column, message) {
        errorLine = line;
        errorColumn = column;
        errorMessage = message;
        hasError = true;
    }
    
    // Function to clear error highlighting
    function clearError() {
        errorLine = -1;
        errorColumn = -1;
        errorMessage = "";
        hasError = false;
    }
    
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
            
            // Background with error highlighting
            background: Rectangle {
                color: constants.colorBackground
                border.color: jsonTextView.borderColor
                border.width: constants.borderNormal
                radius: constants.radiusSmall
                
                // Error line highlighting overlay
                Rectangle {
                    id: errorLineHighlight
                    visible: jsonTextView.hasError && jsonTextView.errorLine >= 0
                    color: "#ff555520" // Semi-transparent red
                    border.color: "#ff5555"
                    border.width: 1
                    radius: 2
                    
                    // Position the highlight over the error line
                    x: 0
                    y: jsonTextView.errorLine * (textArea.font.pixelSize + 2) + 2
                    width: parent.width
                    height: textArea.font.pixelSize + 4
                    
                    // Error tooltip
                    Rectangle {
                        id: errorTooltip
                        visible: errorLineHighlight.visible
                        color: "#ff5555"
                        border.color: "#ff3333"
                        border.width: 1
                        radius: 4
                        width: errorText.width + 16
                        height: errorText.height + 8
                        x: Math.min(parent.width - width, Math.max(0, jsonTextView.errorColumn * 8))
                        y: -height - 4
                        
                        Text {
                            id: errorText
                            anchors.centerIn: parent
                            text: jsonTextView.errorMessage
                            color: "white"
                            font.pixelSize: 11
                            font.family: constants.fontFamily
                        }
                    }
                }
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
                if (jsonTextView.cursorPosition !== cursorPosition) {
                    jsonTextView.cursorPosition = cursorPosition
                }
                jsonTextView.selectionChanged()
            }
        }
    }
}