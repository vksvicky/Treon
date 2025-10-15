import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ColumnLayout {
    id: languageSelector
    
    property string currentLanguage: settingsManager ? settingsManager.language : ""
    
    signal languageChanged(string language)
    
    spacing: 20
        
    // Loading indicator when i18nManager is not available
    Text {
        visible: !i18nManager
        text: "Loading languages..."
        font.pointSize: 14
        color: "#666666"
        Layout.alignment: Qt.AlignHCenter
    }
    
    // Dynamic language selector using SVG flags
    ComboBox {
        id: languageComboBox
        Layout.fillWidth: true
        model: i18nManager ? i18nManager.availableLanguages : []
        visible: !!i18nManager && i18nManager.availableLanguages.length > 0
        
        delegate: ItemDelegate {
            width: languageComboBox.width
            height: 40
            
            Row {
                anchors.left: parent.left
                anchors.leftMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8
                
                Image {
                    width: 24
                    height: 18
                    source: i18nManager ? i18nManager.getLanguageFlagPath(modelData) : ""
                    fillMode: Image.PreserveAspectFit
                    anchors.verticalCenter: parent.verticalCenter
                }
                
                Text {
                    text: i18nManager ? i18nManager.getLanguageNativeName(modelData) : modelData
                    font.pointSize: 13
                    color: "#000000"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
        
        contentItem: Row {
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8
            
            Image {
                width: 24
                height: 18
                source: i18nManager ? i18nManager.getLanguageFlagPath(languageComboBox.currentValue) : ""
                fillMode: Image.PreserveAspectFit
                anchors.verticalCenter: parent.verticalCenter
            }
            
            Text {
                text: i18nManager ? i18nManager.getLanguageNativeName(languageComboBox.currentValue) : languageComboBox.currentValue
                font.pointSize: 13
                color: "#000000"
                anchors.verticalCenter: parent.verticalCenter
            }
        }
        
        onActivated: function(index) {
            currentLanguage = model[index]
            languageChanged(model[index])
        }
        
        Component.onCompleted: {
            // Set current selection
            if (i18nManager && i18nManager.availableLanguages.length > 0) {
                var currentIndex = model.indexOf(currentLanguage)
                if (currentIndex >= 0) {
                    currentIndex = currentIndex
                }
            }
        }
    }
    
    // Fallback for when no languages are available
    Text {
        visible: !i18nManager || i18nManager.availableLanguages.length === 0
        text: "No languages available"
        color: "#666666"
        font.italic: true
        Layout.alignment: Qt.AlignHCenter
    }
    
    // Update current language when settings change
    Connections {
        target: settingsManager
        enabled: !!settingsManager
        function onLanguageChanged() {
            if (settingsManager) {
                currentLanguage = settingsManager.language
            }
        }
    }
}