import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Dialogs
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
// import Qt.labs.platform 1.1
import Treon 1.0

ApplicationWindow {
    id: window
    width: constants.defaultWindowWidth
    height: constants.defaultWindowHeight
    minimumWidth: constants.minimumWindowWidth
    minimumHeight: constants.minimumWindowHeight
    maximumWidth: constants.maximumWindowWidth
    maximumHeight: constants.maximumWindowHeight
    visible: true
    title: qsTr("Treon")
    
    // Assign the menu bar
    menuBar: mainMenuBar
                
    Constants {
        id: constants
    }
    
    // Using global constants for consistent typography
    
    // Proper macOS window properties
    flags: Qt.Window | Qt.WindowTitleHint | Qt.WindowSystemMenuHint | 
           Qt.WindowMinMaxButtonsHint | Qt.WindowCloseButtonHint | Qt.WindowFullscreenButtonHint
    
    // Force light theme initially
    color: constants.colorSurface
    
    Component.onCompleted: {
        console.log("ApplicationWindow initialized with dimensions:", width, "x", height, "min:", minimumWidth, "x", minimumHeight)
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
    
    // Menu Bar - matches original Swift app structure
    MenuBar {
        id: mainMenuBar
        Menu {
            Action {
                text: i18nManager ? i18nManager.tr("About Treon", "QObject") : "About Treon"
                onTriggered: app.showAbout()
            }
            MenuSeparator {}
            Action {
                text: i18nManager ? i18nManager.tr("Preferences...", "QObject") : "Preferences..."
                shortcut: StandardKey.Preferences
                onTriggered: prefsDialog.visible = true
            }
            MenuSeparator {}
            Action {
                text: i18nManager ? i18nManager.tr("Hide Treon", "QObject") : "Hide Treon"
                shortcut: StandardKey.Hide
                onTriggered: window.hide()
            }
            Action {
                text: i18nManager ? i18nManager.tr("Hide Others", "QObject") : "Hide Others"
                shortcut: StandardKey.HideOthers
                onTriggered: window.hide()
            }
            Action {
                text: i18nManager ? i18nManager.tr("Show All", "QObject") : "Show All"
                onTriggered: window.show()
            }
            MenuSeparator {}
            Action {
                text: i18nManager ? i18nManager.tr("Quit Treon", "QObject") : "Quit Treon"
                shortcut: StandardKey.Quit
                onTriggered: Qt.quit()
            }
        }
        Menu {
            title: i18nManager ? i18nManager.tr("File", "QObject") : "File"
            Action {
                text: i18nManager ? i18nManager.tr("New", "QObject") : "New"
                shortcut: StandardKey.New
                onTriggered: app.createNewFile()
            }
            Action {
                text: i18nManager ? i18nManager.tr("Open...", "QObject") : "Open..."
                shortcut: StandardKey.Open
                onTriggered: fileDialog.open()
            }           
            Menu {
                title: i18nManager ? i18nManager.tr("Open Recent", "QObject") : "Open Recent"
                id: recentMenu
                
                // Populate with recent files
                Repeater {
                    model: app.settingsManager ? app.settingsManager.recentFiles : []
                    Action {
                        text: {
                            var fileName = modelData.split('/').pop()
                            return fileName.length > 30 ? fileName.substring(0, 30) + "..." : fileName
                        }
                        onTriggered: app.openFile(modelData)
                    }
                }
                
                // Show "No recent files" if empty
                Action {
                    text: i18nManager ? i18nManager.tr("No recent files", "QObject") : "No recent files"
                    enabled: false
                }
                
                // Clear recent files option
                MenuSeparator {}
                Action {
                    text: i18nManager ? i18nManager.tr("Clear Recent Files", "QObject") : "Clear Recent Files"
                    onTriggered: app.clearHistory()
                }
            }
            MenuSeparator {}
            Action {
                text: i18nManager ? i18nManager.tr("Close", "QObject") : "Close"
                shortcut: StandardKey.Close
                onTriggered: app.closeFile()
                enabled: app.currentFile.length > 0
            }
            Action {
                text: i18nManager ? i18nManager.tr("Save", "QObject") : "Save"
                shortcut: StandardKey.Save
                onTriggered: app.saveFile()
                enabled: app.currentFile.length > 0
            }
            Menu {
                title: i18nManager ? i18nManager.tr("Save As", "QObject") : "Save As"
                Action {
                    text: i18nManager ? i18nManager.tr("Save As JSON...", "QObject") : "Save As JSON..."
                    shortcut: StandardKey.SaveAs
                    onTriggered: saveDialog.open()
                    enabled: app.currentFile.length > 0
                }
            }
            MenuSeparator {}
            Action {
                text: i18nManager ? i18nManager.tr("Page Setup...", "QObject") : "Page Setup..."
                shortcut: "Ctrl+Shift+P"
                onTriggered: app.showPageSetup()
            }
            Action {
                text: i18nManager ? i18nManager.tr("Print...", "QObject") : "Print..."
                shortcut: StandardKey.Print
                onTriggered: app.printDocument()
            }
        }
        Menu {
            title: i18nManager ? i18nManager.tr("Help", "QObject") : "Help"
            Action {
                text: i18nManager ? i18nManager.tr("Treon Help", "QObject") : "Treon Help"
                shortcut: "F1"
                onTriggered: app.showHelp()
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
                    
                    // Fallback text if image doesn't load
                    Text {
                        text: "📄"
                        font.pointSize: 48
                        color: constants.colorSecondary
                        anchors.centerIn: parent
                        visible: appIcon.status !== Image.Ready
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
                        text: qsTr("JSON Formatter & Viewer")
                        font.family: "Helvetica"
                        font.pointSize: 16
                        color: constants.colorSecondary
                        Layout.alignment: Qt.AlignHCenter
                    }
            }
            
            // Two-column layout: Actions on left, Recent Files on right
            RowLayout {
                id: middleSection
                Layout.alignment: Qt.AlignHCenter
                spacing: 84
                Layout.preferredWidth: 720
                Layout.maximumWidth: 720
                
                // Left column - Action buttons
                ColumnLayout {
                    Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                    Layout.preferredWidth: 340
                    Layout.maximumWidth: 340
                    spacing: 20
                    
                    // Primary actions
                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 16
                        
                            Button {
                                text: qsTr("Open File")
                                font.pointSize: 14
                                font.weight: Font.Medium
                                Layout.preferredWidth: 140
                                Layout.preferredHeight: 36
                                onClicked: fileDialog.open()
                            
                            background: Rectangle {
                                color: parent.pressed ? "#0056CC" : constants.colorPrimary
                                radius: 8
                                border.color: "#0056CC"
                                border.width: 1
                            }
                            
                            contentItem: Text {
                                text: parent.text
                                font: parent.font
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                        
                            Button {
                                text: qsTr("New File")
                                font.pointSize: 14
                                font.weight: Font.Medium
                                Layout.preferredWidth: 140
                                Layout.preferredHeight: 36
                                onClicked: app.createNewFile()
                            
                            background: Rectangle {
                                color: parent.pressed ? constants.colorPressed : constants.colorBackground
                                radius: 8
                                border.color: constants.colorTertiary
                                border.width: 1
                            }
                            
                            contentItem: Text {
                                text: parent.text
                                font: parent.font
                                color: constants.colorPrimary
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                    
                    // Secondary actions
                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 16
                        
                            Button {
                                text: qsTr("From Pasteboard")
                                font.pointSize: 12
                                Layout.preferredWidth: 140
                                Layout.preferredHeight: 32
                                onClicked: app.newFromPasteboard()
                            
                            background: Rectangle {
                                color: parent.pressed ? constants.colorPressed : constants.colorBackground
                                radius: 6
                                border.color: "#34C759"
                                border.width: 1
                            }
                            
                            contentItem: Text {
                                text: parent.text
                                font: parent.font
                                color: "#34C759"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                        
                            Button {
                                text: qsTr("From URL")
                                font.pointSize: 12
                                Layout.preferredWidth: 140
                                Layout.preferredHeight: 32
                                onClicked: urlInputDialog.open()
                            
                            background: Rectangle {
                                color: parent.pressed ? constants.colorPressed : constants.colorBackground
                                radius: 6
                                border.color: "#FF9500"
                                border.width: 1
                            }
                            
                            contentItem: Text {
                                text: parent.text
                                font: parent.font
                                color: "#FF9500"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                    
                    // Tertiary actions
                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 12
                        
                            Button {
                                text: qsTr("From cURL")
                                font.pointSize: 12
                                Layout.preferredWidth: 140
                                Layout.preferredHeight: 32
                                onClicked: curlInputDialog.open()
                            
                            background: Rectangle {
                                color: parent.pressed ? constants.colorPressed : constants.colorBackground
                                radius: 6
                                border.color: "#AF52DE"
                                border.width: 1
                            }
                            
                            contentItem: Text {
                                text: parent.text
                                font: parent.font
                                color: "#AF52DE"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                        
                        Item {
                            Layout.preferredWidth: 140
                            Layout.preferredHeight: 32
                        }
                    }
                }
                
                // Spacer to push recent files to the right edge
                Item { Layout.fillWidth: true }

                // Right column - Recent files
                ColumnLayout {
                    Layout.alignment: Qt.AlignTop | Qt.AlignRight
                    Layout.preferredWidth: 340
                    Layout.maximumWidth: 340
                    spacing: 16
                    
                    // Recent Files header
                    RowLayout {
                        Layout.alignment: Qt.AlignLeft
                        spacing: 8
                        
                        Text {
                            text: qsTr("Recent Files")
                            font.pointSize: 14
                            font.weight: Font.Medium
                            color: constants.colorPrimary
                        }
                        
                        Text {
                            text: recentFilesExpanded ? "▲" : "▼"
                            font.pointSize: 10
                            color: constants.colorPrimary
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: recentFilesExpanded = !recentFilesExpanded
                            }
                        }
                    }
                    
                    // Recent Files tree structure
                    ColumnLayout {
                        Layout.alignment: Qt.AlignLeft
                        Layout.leftMargin: 20
                        spacing: 4
                        visible: recentFilesExpanded
                        
                        Repeater {
                            model: app.recentFiles
                            delegate: RowLayout {
                                Layout.alignment: Qt.AlignLeft
                                spacing: 8
                                
                                // Tree connector
                                Text {
                                    text: "├─"
                                    font.pointSize: 10
                                    color: constants.colorSecondary
                                    Layout.preferredWidth: 20
                                }
                                
                                // File button
                                Button {
                                    text: modelData.split('/').pop()
                                    font.pointSize: 12
                                    Layout.fillWidth: true
                                    onClicked: app.openFile(Qt.resolvedUrl("file://" + modelData))
                                    
                                    background: Rectangle {
                                        color: parent.pressed ? "#f0f0f0" : "transparent"
                                        radius: 4
                                    }
                                    
                                    contentItem: Text {
                                        text: parent.text
                                        font: parent.font
                                        color: constants.colorPrimary
                                        horizontalAlignment: Text.AlignLeft
                                        verticalAlignment: Text.AlignVCenter
                                        elide: Text.ElideRight
                                    }
                                }
                            }
                        }
                        
                        // No recent files message
                        RowLayout {
                            Layout.alignment: Qt.AlignLeft
                            spacing: 8
                            visible: app.recentFiles.length === 0
                            
                            Text {
                                text: "├─"
                                font.pointSize: 10
                                color: constants.colorSecondary
                                Layout.preferredWidth: 20
                            }
                            
                            Text {
                                text: qsTr("No recent files")
                                font.pointSize: 12
                                color: constants.colorSecondary
                            }
                        }
                    }
                }
            }
            
            // Drag and drop hint
            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: middleSection.width
                Layout.preferredHeight: 150
                color: "transparent"
                border.color: constants.colorTertiary
                border.width: 2
                radius: 12
                
                // Drag and drop support only in this designated area
                DropArea {
                    anchors.fill: parent
                    onDropped: function(drop) {
                        if (drop.hasUrls) {
                            app.openFile(drop.urls[0])
                        }
                    }
                    onEntered: function(drag) {
                        parent.color = "#f0f8ff"
                        parent.border.color = constants.colorPrimary
                    }
                    onExited: function(drag) {
                        parent.color = "transparent"
                        parent.border.color = constants.colorTertiary
                    }
                }
                
                RowLayout {
                    anchors.centerIn: parent
                    spacing: 8
                    
                    Text {
                        text: "↓"
                        font.pointSize: 16
                        color: constants.colorSecondary
                    }
                    
                        Text {
                            text: qsTr("Drag and drop a JSON file here")
                            font.pointSize: 16
                            font.weight: Font.Medium
                            color: constants.colorSecondary
                        }
                }
            }
        }
    }
    
    // Main application interface when file is loaded
    Rectangle {
        id: mainInterface
        anchors.fill: parent
        color: constants.colorSurface
        visible: app.currentFile
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 0
            spacing: 0
            
            // Main content area
            TwoPaneLayout {
                id: twoPane
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
            
            // Status bar
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 30
                color: "#e9ecef"
                border.color: constants.colorTertiary
                border.width: 1
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 10
                    
                        Text {
                            text: app.currentFile || qsTr("No file loaded")
                            font.italic: true
                            color: constants.colorPrimary
                            Layout.fillWidth: true
                            elide: Text.ElideLeft
                        }
                    
                    Text {
                        text: app.statusMessage
                        color: constants.colorPrimary
                        visible: app.statusMessage.length > 0
                    }
                    
                    Text {
                        text: app.errorMessage
                        color: "#FF3B30"
                        visible: app.errorMessage.length > 0
                    }
                }
            }
        }
    }
    
    // File dialogs
        FileDialog {
            id: fileDialog
            title: qsTr("Open JSON File")
            nameFilters: [qsTr("JSON files (*.json)"), qsTr("All files (*)")]
            onAccepted: {
                console.log("File selected:", selectedFile)
                app.openFile(selectedFile)
            }
        }
    
        FileDialog {
            id: saveDialog
            title: qsTr("Save JSON File")
            nameFilters: [qsTr("JSON files (*.json)"), qsTr("All files (*)")]
            onAccepted: {
                console.log("Save file selected:", selectedFile)
                app.saveFile(selectedFile, app.jsonText)
            }
        }
    
    // URL input dialog
        Popup {
            id: urlInputDialog
            width: 400
            height: 200
            modal: true
            focus: true
        
        property alias urlText: urlInput.text
        
        ColumnLayout {
            anchors.fill: parent
            spacing: 16
            
                Text {
                    text: qsTr("Enter URL:")
                    font.pointSize: 14
                }
            
                TextField {
                    id: urlInput
                    Layout.fillWidth: true
                    placeholderText: qsTr("https://api.example.com/data.json")
                }
            
            RowLayout {
                Layout.alignment: Qt.AlignRight
                spacing: 8
                
                    Button {
                        text: qsTr("Cancel")
                        onClicked: urlInputDialog.close()
                    }
                
                    Button {
                        text: qsTr("Load")
                        enabled: urlInput.text.length > 0
                        onClicked: {
                            app.loadFromURL(urlInput.text)
                            urlInputDialog.close()
                        }
                    }
            }
        }
    }
    
    // cURL input dialog
        Popup {
            id: curlInputDialog
            width: 500
            height: 300
            modal: true
            focus: true
        
        property alias curlText: curlInput.text
        
        ColumnLayout {
            anchors.fill: parent
            spacing: 16
            
                Text {
                    text: qsTr("Enter cURL command:")
                    font.pointSize: 14
                }
            
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                
                    TextArea {
                        id: curlInput
                        placeholderText: qsTr("curl -X GET https://api.example.com/data")
                        wrapMode: TextArea.Wrap
                    }
            }
            
            RowLayout {
                Layout.alignment: Qt.AlignRight
                spacing: 8
                
                    Button {
                        text: qsTr("Cancel")
                        onClicked: curlInputDialog.close()
                    }
                
                    Button {
                        text: qsTr("Execute")
                        enabled: curlInput.text.length > 0
                        onClicked: {
                            app.executeCurlCommand(curlInput.text)
                            curlInputDialog.close()
                        }
                    }
            }
        }
    }
    
    // Error dialog - proper modal alert
    Window {
        id: errorDialog
        title: "JSON Error"
        modality: Qt.ApplicationModal
        flags: Qt.Window | Qt.WindowTitleHint | Qt.WindowCloseButtonHint
        width: Math.min(400, 400)
        height: Math.min(200, 200)
        visible: false
        
        property alias text: errorText.text
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 20
            
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Text {
                    id: errorText
                    wrapMode: Text.WordWrap
                    font.family: constants.fontFamily
                    font.pixelSize: 12
                    color: constants.colorPrimary
                }
            }
            
            RowLayout {
                Layout.alignment: Qt.AlignRight
                spacing: 10
                
                Button {
                    text: "OK"
                    onClicked: errorDialog.visible = false
                }
            }
        }
    }
    
    // About dialog - using the full AboutWindow component
    Loader {
        id: aboutDialogLoader
        source: "AboutWindow.qml"
        onLoaded: {
            console.log("AboutWindow.qml loaded successfully")
        }
    }
    
    // State variables
    property bool recentFilesExpanded: false
}