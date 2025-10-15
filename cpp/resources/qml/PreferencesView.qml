import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Treon 1.0

Item {
    id: prefs
    implicitWidth: 400
    implicitHeight: 300
    
    // Internal properties for custom controls
    property bool unlimited: false
    property int depthValue: 1
    property bool stepperEnabled: !unlimited
    
    // Signals
    signal preferencesSaved()
    signal closeRequested()

    Constants { id: constants }

    ScrollView {
        anchors.fill: parent
        anchors.margins: constants.marginMedium
        
        ColumnLayout {
            width: prefs.width - 2 * constants.marginMedium
            spacing: constants.spacingLarge
            
            // Language Selection Section
            ColumnLayout {
                Layout.fillWidth: true
                spacing: constants.spacingSmall
                
                Text {
                    text: i18nManager ? i18nManager.tr("Language", "Preferences") : "Language"
                    font.pointSize: constants.fontSizeMedium
                    font.weight: Font.Medium
                    color: "#333333"
                }
                
                LanguageSelector {
                    Layout.fillWidth: true
                    onLanguageChanged: function(language) {
                        if (settingsManager) {
                            settingsManager.language = language
                        }
                        if (i18nManager) {
                            i18nManager.switchLanguage(language)
                        }
                    }
                }
            }
            
            // JSON Max Depth Section
            GroupBox {
                title: i18nManager ? i18nManager.tr("JSON Tree Settings", "Preferences") : "JSON Tree Settings"
                font.pointSize: constants.fontSizeMedium
                font.weight: Font.Medium
                Layout.fillWidth: true
                
                ColumnLayout {
                    spacing: constants.spacingMedium
                    
                    RowLayout {
                        spacing: constants.spacingMedium
                        Layout.alignment: Qt.AlignLeft
                        
                        Text {
                            text: i18nManager ? i18nManager.tr("Max Depth", "Preferences") : "Max Depth"
                            font.family: constants.fontFamily
                            font.pointSize: constants.fontSizeRegular
                            color: constants.colorPrimary
                            Layout.preferredWidth: 100
                        }
                        
                        // Custom styled checkbox
                        Rectangle {
                            width: 16
                            height: 16
                            border.color: unlimited ? constants.colorSelectionText : constants.colorBorder
                            border.width: constants.borderNormal
                            radius: 3
                            color: unlimited ? constants.colorSelectionText : "transparent"
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    unlimited = !unlimited
                                    stepperEnabled = !unlimited
                                    if (unlimited) {
                                        depthValue = 999
                                    } else {
                                        depthValue = 1
                                    }
                                }
                            }
                            
                            Text {
                                text: "✓"
                                color: "white"
                                font.pointSize: 10
                                font.weight: Font.Bold
                                anchors.centerIn: parent
                                visible: unlimited
                            }
                        }
                        
                        Text {
                            text: i18nManager ? i18nManager.tr("Unlimited", "Preferences") : "Unlimited"
                            font.family: constants.fontFamily
                            font.pointSize: constants.fontSizeRegular
                            color: constants.colorPrimary
                        }
                    }
                    
                    RowLayout {
                        spacing: constants.spacingMedium
                        Layout.alignment: Qt.AlignLeft
                        visible: !unlimited
                        
                        Text {
                            text: i18nManager ? i18nManager.tr("Depth", "Preferences") : "Depth"
                            font.family: constants.fontFamily
                            font.pointSize: constants.fontSizeRegular
                            color: constants.colorPrimary
                            Layout.preferredWidth: 100
                        }
                        
                        SpinBox {
                            id: depthSpinBox
                            from: 1
                            to: 20
                            value: depthValue
                            enabled: stepperEnabled
                            
                            onValueChanged: {
                                depthValue = value
                            }
                            
                            // Custom styling
                            background: Rectangle {
                                border.color: constants.colorBorder
                                border.width: constants.borderNormal
                                radius: 4
                                color: "white"
                            }
                            
                            textFromValue: function(value, locale) {
                                return value.toString()
                            }
                            
                            valueFromText: function(text, locale) {
                                return parseInt(text) || 1
                            }
                        }
                    }
                }
            }
            
            // Buttons Section
            RowLayout {
                Layout.alignment: Qt.AlignRight
                spacing: constants.spacingMedium
                
                Button {
                    text: i18nManager ? i18nManager.tr("Restore Defaults", "Preferences") : "Restore Defaults"
                    onClicked: {
                        unlimited = false
                        depthValue = 1
                        stepperEnabled = true
                        if (settingsManager) {
                            settingsManager.language = "en_GB"
                        }
                        if (i18nManager) {
                            i18nManager.switchLanguage("en_GB")
                        }
                    }
                    
                    background: Rectangle {
                        border.color: constants.colorBorder
                        border.width: constants.borderNormal
                        radius: 4
                        color: parent.pressed ? constants.colorSurface : "white"
                    }
                }
                
                Button {
                    text: i18nManager ? i18nManager.tr("Save", "Preferences") : "Save"
                    onClicked: {
                        if (settingsManager) {
                            settingsManager.jsonMaxDepth = unlimited ? -1 : depthValue
                            settingsManager.saveSettings()
                        }
                        preferencesSaved()
                    }
                    
                    background: Rectangle {
                        border.color: constants.colorSelectionText
                        border.width: constants.borderNormal
                        radius: 4
                        color: parent.pressed ? constants.colorSelectionText : "white"
                    }
                    
                    contentItem: Text {
                        text: parent.text
                        color: constants.colorSelectionText
                        font.pointSize: constants.fontSizeRegular
                        font.weight: Font.Medium
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }
    }
    
    // Initialize values from settings
    Component.onCompleted: {
        if (settingsManager) {
            var maxDepth = settingsManager.jsonMaxDepth
            unlimited = (maxDepth === -1 || maxDepth === undefined || maxDepth === null)
            depthValue = unlimited ? 1 : maxDepth
            stepperEnabled = !unlimited
        }
    }
    
    // Update when settings change
    Connections {
        target: settingsManager
        enabled: !!settingsManager
        function onJsonMaxDepthChanged() {
            if (settingsManager) {
                var maxDepth = settingsManager.jsonMaxDepth
                unlimited = (maxDepth === -1 || maxDepth === undefined || maxDepth === null)
                depthValue = unlimited ? 1 : maxDepth
                stepperEnabled = !unlimited
            }
        }
    }
}