import QtQuick 2.15
import QtQuick.Controls 2.15

Dialog {
    id: notificationDialog
    
    // Properties for customization
    property string notificationTitle: "Notification"
    property string notificationText: ""
    property color notificationColor: constants.colorAccent
    property color textColor: "white"
    property int dialogWidth: 300
    property int dialogHeight: 150
    property bool isError: false
    
    // Override default properties based on type
    title: notificationTitle
    modal: true
    anchors.centerIn: parent
    width: Math.min(dialogWidth, parent.width * 0.6)
    height: Math.min(dialogHeight, parent.height * 0.4)
    
    standardButtons: Dialog.Ok
    
    // Dynamic background color based on type
    property color backgroundColor: isError ? constants.colorError : notificationColor
    
    Rectangle {
        anchors.fill: parent
        color: backgroundColor
        radius: constants.radiusMedium
        
        Text {
            anchors.centerIn: parent
            text: notificationText
            color: textColor
            font.family: constants.fontFamily
            font.pixelSize: constants.fontSizeMedium
            font.weight: Font.Medium
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            width: parent.width - 20
        }
    }
    
    // Function to show success notification
    function showSuccess(title, message) {
        notificationTitle = title || "Success"
        notificationText = message || "Operation completed successfully"
        notificationColor = constants.colorSuccess
        textColor = "white"
        isError = false
        open()
    }
    
    // Function to show error notification
    function showError(title, message) {
        notificationTitle = title || "Error"
        notificationText = message || "An error occurred"
        notificationColor = constants.colorError
        textColor = "white"
        isError = true
        open()
    }
    
    // Function to show info notification
    function showInfo(title, message) {
        notificationTitle = title || "Information"
        notificationText = message || "Information"
        notificationColor = constants.colorAccent
        textColor = "white"
        isError = false
        open()
    }
    
    // Function to show warning notification
    function showWarning(title, message) {
        notificationTitle = title || "Warning"
        notificationText = message || "Warning"
        notificationColor = constants.colorWarning
        textColor = "white"
        isError = false
        open()
    }
}
