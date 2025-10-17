import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import Treon 1.0

Window {
    id: prefsDialog
    title: qsTr("Preferences")
    width: 450
    height: 350
    minimumWidth: 450
    maximumWidth: 450
    minimumHeight: 350
    maximumHeight: 350
    modality: Qt.WindowModal
    flags: Qt.Window | Qt.WindowTitleHint | Qt.WindowStaysOnTopHint
    visible: false
    
    onClosing: {
        // Find the main window and call updateJSONModel
        var mainWindow = prefsDialog.parent
        while (mainWindow && !mainWindow.twoPane) {
            mainWindow = mainWindow.parent
        }
        if (mainWindow && mainWindow.twoPane) {
            mainWindow.twoPane.updateJSONModel()
        }
    }

    PreferencesView { 
        anchors.fill: parent
        onPreferencesSaved: {
            // Find the main window and call updateJSONModel
            var mainWindow = prefsDialog.parent
            while (mainWindow && !mainWindow.twoPane) {
                mainWindow = mainWindow.parent
            }
            if (mainWindow && mainWindow.twoPane) {
                mainWindow.twoPane.updateJSONModel()
            }
            prefsDialog.visible = false
        }
        onCloseRequested: {
            prefsDialog.visible = false
        }
    }
}
