import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Dialogs
import QtQuick.Layouts 1.15
import Treon 1.0

Item {
    id: root
    width: 1200
    height: 800
    
    Constants {
        id: constants
    }
    
    Application {
        id: app
        onErrorOccurred: function(error) {
            errorDialog.text = error
            errorDialog.open()
        }
        onAboutDialogRequested: {
            console.log("About dialog requested")
            if (aboutDialogLoader.item) {
                aboutDialogLoader.item.show()
            } else {
                console.log("AboutWindow not loaded yet")
            }
        }
    }

    // Preferences dialog (centralized)
    Window {
        id: prefsDialog
        modality: Qt.ApplicationModal
        title: qsTr("Preferences")
        flags: Qt.Window | Qt.WindowTitleHint | Qt.WindowCloseButtonHint | Qt.CustomizeWindowHint
        width: 450
        height: 350
        visible: false
        onClosing: twoPane.updateJSONModel()

        PreferencesView { 
            anchors.fill: parent
            onPreferencesSaved: {
                twoPane.updateJSONModel()
                prefsDialog.visible = false
            }
            onCloseRequested: {
                prefsDialog.visible = false
            }
        }
    }
    
    // Landing screen when no file is loaded - matches original Swift app
    Rectangle {
        id: landingScreen
        anchors.fill: parent
        color: constants.colorSurface
        visible: !app.currentFile
        
        ColumnLayout {
            anchors.centerIn: parent
            spacing: 80
            
            // Header with icon and title
            ColumnLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 20
                
                // App icon with base64 embedded image
                Item {
                    width: 80
                    height: 80
                    Layout.alignment: Qt.AlignHCenter
                    
                    // App icon from resources
                    Image {
                        id: appIcon
                        anchors.fill: parent
                        source: "qrc:/icon.png"
                        smooth: true
                        fillMode: Image.PreserveAspectFit

                        Component.onCompleted: {
                            console.log("Image source:", source)
                            console.log("Image status:", status)
                        }
                        visible: status === Image.Ready
                        onStatusChanged: {
                            console.log("Icon status changed to:", status)
                            if (status === Image.Error) {
                                console.log("Icon failed to load. Error:", errorString)
                            } else if (status === Image.Ready) {
                                console.log("Icon loaded successfully")
                                console.log("Icon size:", sourceSize.width, "x", sourceSize.height)
                            } else if (status === Image.Loading) {
                                console.log("Icon loading...")
                            }
                        }
                    }
                }
                
                Text {
                    text: qsTr("Treon")
                    font.family: "Helvetica"
                    font.pointSize: 36
                    font.weight: Font.Light
                    color: constants.colorPrimary
                    Layout.alignment: Qt.AlignHCenter
                }
                
                Text {
                    text: qsTr("JSON Viewer & Editor")
                    font.family: "Helvetica"
                    font.pointSize: 16
                    font.weight: Font.Normal
                    color: constants.colorSecondary
                    Layout.alignment: Qt.AlignHCenter
                }
            }
            
            // Action buttons
            ColumnLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 20
                
                Button {
                    text: qsTr("Open JSON File")
                    Layout.alignment: Qt.AlignHCenter
                    onClicked: openDialog.open()
                    
                    background: Rectangle {
                        color: constants.colorPrimary
                        radius: 8
                        border.color: constants.colorPrimary
                        border.width: 1
                    }
                    
                    contentItem: Text {
                        text: parent.text
                        font.family: "Helvetica"
                        font.pointSize: 14
                        font.weight: Font.Medium
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                
                Button {
                    text: qsTr("Create New JSON")
                    Layout.alignment: Qt.AlignHCenter
                    onClicked: app.newFile()
                    
                    background: Rectangle {
                        color: "transparent"
                        radius: 8
                        border.color: constants.colorPrimary
                        border.width: 1
                    }
                    
                    contentItem: Text {
                        text: parent.text
                        font.family: "Helvetica"
                        font.pointSize: 14
                        font.weight: Font.Medium
                        color: constants.colorPrimary
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }
    }
    
    // Main content area when file is loaded
    TwoPaneLayout {
        id: twoPane
        anchors.fill: parent
        visible: app.currentFile.length > 0
    }
    
    // File dialogs
    FileDialog {
        id: openDialog
        title: qsTr("Open JSON File")
        nameFilters: ["JSON files (*.json)", "All files (*)"]
        onAccepted: {
            console.log("File selected:", selectedFile)
            app.openFile(selectedFile)
        }
    }
    
    FileDialog {
        id: saveDialog
        title: qsTr("Save JSON File")
        nameFilters: ["JSON files (*.json)", "All files (*)"]
        fileMode: FileDialog.SaveFile
        onAccepted: {
            console.log("Save file selected:", selectedFile)
            app.saveFileAs(selectedFile)
        }
    }
    
    // Error dialog
    Dialog {
        id: errorDialog
        title: qsTr("Error")
        property string text: ""
        standardButtons: Dialog.Ok
        
        Label {
            text: errorDialog.text
            wrapMode: Text.WordWrap
        }
    }
    
    // About dialog loader
    Loader {
        id: aboutDialogLoader
        source: "AboutWindow.qml"
        onLoaded: {
            console.log("AboutWindow loaded")
        }
    }
}
