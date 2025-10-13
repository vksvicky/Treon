import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Treon 1.0

Item {
    id: prefs
    implicitWidth: 360
    implicitHeight: 160

    // Injected from caller
    property var settingsManager
    
    // Internal properties for custom controls
    property bool unlimited: false
    property int depthValue: 1
    property bool stepperEnabled: !unlimited
    
    // Signals
    signal preferencesSaved()
    signal closeRequested()

    Constants { id: constants }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: constants.marginMedium
        spacing: constants.spacingMedium


        // JSON Max Depth group
        RowLayout {
            spacing: constants.spacingMedium
            Layout.alignment: Qt.AlignLeft
            
            Text {
                text: "JSON Tree Max Depth"
                font.family: constants.fontFamily
                font.pixelSize: constants.fontSizeRegular
                color: constants.colorPrimary
                Layout.preferredWidth: 140
            }
            
            // Custom styled checkbox
            Rectangle {
                width: 16
                height: 16
                border.color: unlimited ? constants.colorSelectionText : constants.colorBorder
                border.width: constants.borderNormal
                radius: 3
                color: unlimited ? constants.colorSelectionText : "white"
                
                Text {
                    anchors.centerIn: parent
                    text: "✓"
                    color: "white"
                    font.pixelSize: 10
                    visible: unlimited
                }
                
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        unlimited = !unlimited
                        if (unlimited) {
                            settingsManager.jsonMaxDepth = undefined
                        } else {
                            settingsManager.jsonMaxDepth = depthValue
                        }
                    }
                }
            }
            
            Text {
                text: "Unlimited"
                font.family: constants.fontFamily
                font.pixelSize: constants.fontSizeRegular
                color: constants.colorPrimary
            }
            
            Item { Layout.fillWidth: true }
            
            // Custom styled stepper
            Row {
                spacing: 0
                
                // Minus button
                Rectangle {
                    width: 24
                    height: 24
                    color: stepperEnabled ? (minusMouseArea.pressed ? constants.colorPressed : constants.colorSurface) : constants.colorBackground
                    border.color: constants.colorBorder
                    border.width: constants.borderNormal
                    radius: 4
                    
                    Text {
                        anchors.centerIn: parent
                        text: "−"
                        font.pixelSize: 14
                        color: stepperEnabled ? constants.colorPrimary : constants.colorSecondary
                    }
                    
                    MouseArea {
                        id: minusMouseArea
                        anchors.fill: parent
                        enabled: stepperEnabled
                        onClicked: {
                            if (depthValue > 1) {
                                depthValue--
                                if (!unlimited) {
                                    settingsManager.jsonMaxDepth = depthValue
                                }
                            }
                        }
                    }
                }
                
                // Value display
                Rectangle {
                    width: 50
                    height: 24
                    color: "white"
                    border.color: constants.colorBorder
                    border.width: constants.borderNormal
                    
                    Text {
                        anchors.centerIn: parent
                        text: depthValue.toString()
                        font.family: constants.fontFamily
                        font.pixelSize: constants.fontSizeRegular
                        color: constants.colorPrimary
                    }
                }
                
                // Plus button
                Rectangle {
                    width: 24
                    height: 24
                    color: stepperEnabled ? (plusMouseArea.pressed ? constants.colorPressed : constants.colorSurface) : constants.colorBackground
                    border.color: constants.colorBorder
                    border.width: constants.borderNormal
                    radius: 4
                    
                    Text {
                        anchors.centerIn: parent
                        text: "+"
                        font.pixelSize: 14
                        color: stepperEnabled ? constants.colorPrimary : constants.colorSecondary
                    }
                    
                    MouseArea {
                        id: plusMouseArea
                        anchors.fill: parent
                        enabled: stepperEnabled
                        onClicked: {
                            if (depthValue < 99) {
                                depthValue++
                                if (!unlimited) {
                                    settingsManager.jsonMaxDepth = depthValue
                                }
                            }
                        }
                    }
                }
            }
        }

        Item { Layout.fillHeight: true }
        
        // Action buttons
        RowLayout {
            Layout.alignment: Qt.AlignRight
            spacing: constants.spacingMedium
            
            Button {
                text: "Restore Defaults"
                Layout.preferredWidth: 120
                Layout.preferredHeight: constants.buttonHeightSmall
                
                background: Rectangle {
                    color: parent.pressed ? constants.colorPressed : 
                           parent.hovered ? constants.colorHover : constants.colorSurface
                    border.color: parent.hovered ? constants.colorSelectionText : constants.colorBorder
                    border.width: constants.borderNormal
                    radius: constants.radiusSmall
                }
                
                contentItem: Text {
                    text: parent.text
                    font.family: constants.fontFamily
                    font.pixelSize: constants.fontSizeRegular
                    color: parent.hovered ? constants.colorSelectionText : constants.colorPrimary
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                
                onClicked: {
                    // Restore default values
                    unlimited = true
                    depthValue = 1
                    settingsManager.jsonMaxDepth = undefined
                }
            }
            
            Button {
                text: "Save"
                Layout.preferredWidth: 80
                Layout.preferredHeight: constants.buttonHeightSmall
                
                background: Rectangle {
                    color: parent.pressed ? constants.colorPressed : 
                           parent.hovered ? constants.colorHover : constants.colorSurface
                    border.color: parent.hovered ? constants.colorSelectionText : constants.colorBorder
                    border.width: constants.borderNormal
                    radius: constants.radiusSmall
                }
                
                contentItem: Text {
                    text: parent.text
                    font.family: constants.fontFamily
                    font.pixelSize: constants.fontSizeRegular
                    color: parent.hovered ? constants.colorSelectionText : constants.colorPrimary
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                
                onClicked: {
                    // Save current values
                    if (unlimited) {
                        settingsManager.jsonMaxDepth = undefined
                    } else {
                        settingsManager.jsonMaxDepth = depthValue
                    }
                    // Emit signal to notify that preferences were saved
                    preferencesSaved()                    
                }
            }
        }

        // Keep UI in sync with stored setting
        Component.onCompleted: {
            var d = settingsManager ? settingsManager.jsonMaxDepth : undefined
            unlimited = (d === undefined || d === null || d === "")
            if (!unlimited && d !== undefined && d !== null && d !== "") {
                depthValue = Number(d)
            }
        }
        Connections {
            target: settingsManager
            function onJsonMaxDepthChanged() {
                var d = settingsManager.jsonMaxDepth
                unlimited = (d === undefined || d === null || d === "")
                if (!unlimited && d !== undefined && d !== null && d !== "") {
                    depthValue = Number(d)
                }
            }
        }
        
    }
}


