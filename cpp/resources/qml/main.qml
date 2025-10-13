import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Dialogs
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
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
        onErrorOccurred: {
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

    // Shared SettingsManager for PreferencesView
    SettingsManager { id: settingsManager }

    // Preferences dialog (centralized)
    Window {
        id: prefsDialog
        modality: Qt.ApplicationModal
        title: qsTr("Preferences")
        flags: Qt.Window | Qt.WindowTitleHint | Qt.WindowCloseButtonHint | Qt.CustomizeWindowHint
        width: 420
        height: 220
        visible: false
        onClosing: twoPane.updateJSONModel()

        PreferencesView { 
            anchors.fill: parent
            settingsManager: settingsManager
            onPreferencesSaved: {
                twoPane.updateJSONModel()
            }
            onCloseRequested: {
                prefsDialog.visible = false
            }
        }
    }
    
    // Menu Bar - matches original Swift app structure
    menuBar: MenuBar {
        Menu {
            Action {
                text: qsTr("About Treon")
                onTriggered: app.showAbout()
            }
            MenuSeparator {}
            Action {
                text: qsTr("Preferences...")
                shortcut: "Ctrl+,"
                onTriggered: prefsDialog.visible = true
            }
            MenuSeparator {}
            Action {
                text: qsTr("Hide Treon")
                shortcut: "Ctrl+H"
                onTriggered: window.hide()
            }
            Action {
                text: qsTr("Hide Others")
                shortcut: "Ctrl+Alt+H"
                onTriggered: window.hide()
            }
            Action {
                text: qsTr("Show All")
                onTriggered: window.show()
            }
            MenuSeparator {}
            Action {
                text: qsTr("Quit Treon")
                shortcut: "Ctrl+Q"
                onTriggered: Qt.quit()
            }
        }
        Menu {
            title: qsTr("File")
            Action {
                text: qsTr("New")
                shortcut: "Ctrl+N"
                onTriggered: app.createNewFile()
            }
            Action {
                text: qsTr("Open...")
                shortcut: "Ctrl+O"
                onTriggered: fileDialog.open()
            }
            Menu {
                title: qsTr("Open Recent")
                id: recentMenu
                // TODO: Populate with recent files
            }
            MenuSeparator {}
            Action {
                text: qsTr("Close")
                shortcut: "Ctrl+W"
                onTriggered: app.closeFile()
                enabled: app.currentFile.length > 0
            }
            Action {
                text: qsTr("Save")
                shortcut: "Ctrl+S"
                onTriggered: app.saveFile()
                enabled: app.currentFile.length > 0
            }
            Action {
                text: qsTr("Save As...")
                shortcut: "Ctrl+Shift+S"
                onTriggered: saveDialog.open()
                enabled: app.currentFile.length > 0
            }
            Action {
                text: qsTr("Revert to Saved")
                shortcut: "Ctrl+R"
                onTriggered: app.revertToSaved()
                enabled: app.currentFile.length > 0
            }
            MenuSeparator {}
            Action {
                text: qsTr("Page Setup...")
                shortcut: "Ctrl+Shift+P"
                onTriggered: app.showPageSetup()
            }
            Action {
                text: qsTr("Print...")
                shortcut: "Ctrl+P"
                onTriggered: app.printDocument()
            }
        }
        Menu {
            title: qsTr("Edit")
            Action {
                text: qsTr("Undo")
                shortcut: "Ctrl+Z"
                onTriggered: app.undo()
            }
            Action {
                text: qsTr("Redo")
                shortcut: "Ctrl+Y"
                onTriggered: app.redo()
            }
            MenuSeparator {}
            Action {
                text: qsTr("Cut")
                shortcut: "Ctrl+X"
                onTriggered: app.cut()
            }
            Action {
                text: qsTr("Copy")
                shortcut: "Ctrl+C"
                onTriggered: app.copy()
            }
            Action {
                text: qsTr("Paste")
                shortcut: "Ctrl+V"
                onTriggered: app.paste()
            }
            Action {
                text: qsTr("Paste and Match Style")
                shortcut: "Ctrl+Alt+V"
                onTriggered: app.pasteAsPlainText()
            }
            Action {
                text: qsTr("Delete")
                onTriggered: app.deleteSelection()
            }
            Action {
                text: qsTr("Select All")
                shortcut: "Ctrl+A"
                onTriggered: app.selectAll()
            }
            MenuSeparator {}
            Menu {
                title: qsTr("Find")
                    Action {
                        text: qsTr("Find...")
                        shortcut: "Ctrl+F"
                        onTriggered: app.showFindDialog()
                    }
                    Action {
                        text: qsTr("Find and Replace...")
                        shortcut: "Ctrl+Alt+F"
                        onTriggered: app.showFindReplaceDialog()
                    }
                    Action {
                        text: qsTr("Find Next")
                        shortcut: "Ctrl+G"
                        onTriggered: app.findNext()
                    }
                    Action {
                        text: qsTr("Find Previous")
                        shortcut: "Ctrl+Shift+G"
                        onTriggered: app.findPrevious()
                    }
                    Action {
                        text: qsTr("Use Selection for Find")
                        shortcut: "Ctrl+E"
                        onTriggered: app.useSelectionForFind()
                    }
                    Action {
                        text: qsTr("Jump to Selection")
                        shortcut: "Ctrl+J"
                        onTriggered: app.jumpToSelection()
                    }
            }
        }
        Menu {
            title: qsTr("Format")
            Menu {
                title: qsTr("Font")
                    Action {
                        text: qsTr("Show Fonts")
                        shortcut: "Ctrl+T"
                        onTriggered: app.showFontPanel()
                    }
                    Action {
                        text: qsTr("Bold")
                        shortcut: "Ctrl+B"
                        onTriggered: app.toggleBold()
                    }
                    Action {
                        text: qsTr("Italic")
                        shortcut: "Ctrl+I"
                        onTriggered: app.toggleItalic()
                    }
                    Action {
                        text: qsTr("Underline")
                        shortcut: "Ctrl+U"
                        onTriggered: app.toggleUnderline()
                    }
                MenuSeparator {}
                    Action {
                        text: qsTr("Bigger")
                        shortcut: "Ctrl+Plus"
                        onTriggered: app.increaseFontSize()
                    }
                    Action {
                        text: qsTr("Smaller")
                        shortcut: "Ctrl+Minus"
                        onTriggered: app.decreaseFontSize()
                    }
            }
            Menu {
                title: qsTr("Text")
                    Action {
                        text: qsTr("Align Left")
                        shortcut: "Ctrl+{"
                        onTriggered: app.alignLeft()
                    }
                    Action {
                        text: qsTr("Center")
                        shortcut: "Ctrl+|"
                        onTriggered: app.alignCenter()
                    }
                    Action {
                        text: qsTr("Justify")
                        onTriggered: app.alignJustify()
                    }
                    Action {
                        text: qsTr("Align Right")
                        shortcut: "Ctrl+}"
                        onTriggered: app.alignRight()
                    }
            }
        }
        Menu {
            title: qsTr("View")
            Action {
                text: qsTr("Show Toolbar")
                shortcut: "Ctrl+Alt+T"
                onTriggered: app.toggleToolbar()
            }
            Action {
                text: qsTr("Customize Toolbar...")
                onTriggered: app.customizeToolbar()
            }
            MenuSeparator {}
            Action {
                text: qsTr("Show Sidebar")
                shortcut: "Ctrl+Alt+S"
                onTriggered: app.toggleSidebar()
            }
            Action {
                text: qsTr("Enter Full Screen")
                shortcut: "Ctrl+Alt+F"
                onTriggered: app.toggleFullScreen()
            }
            MenuSeparator {}
            Action {
                text: qsTr("Toggle Theme")
                shortcut: "Ctrl+T"
                onTriggered: app.toggleTheme()
            }
            Action {
                text: qsTr("Expand All")
                shortcut: "Ctrl+E"
                onTriggered: app.expandAllNodes()
            }
            Action {
                text: qsTr("Collapse All")
                shortcut: "Ctrl+Shift+E"
                onTriggered: app.collapseAllNodes()
            }
        }
        Menu {
            title: qsTr("Window")
            Action {
                text: qsTr("Minimize")
                shortcut: "Ctrl+M"
                onTriggered: window.showMinimized()
            }
            Action {
                text: qsTr("Zoom")
                onTriggered: window.showMaximized()
            }
            MenuSeparator {}
            Action {
                text: qsTr("Bring All to Front")
                onTriggered: app.bringAllToFront()
            }
        }
        Menu {
            title: qsTr("Help")
            Action {
                text: qsTr("Treon Help")
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
        
        // Drag and drop support removed from global area - now only in designated area
        
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
    
    // Error dialog
    Popup {
        id: errorDialog
        modal: true
        focus: true
        property alias text: errorText.text
        
        Text {
            id: errorText
            wrapMode: Text.WordWrap
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