import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Treon 1.0

ScrollView {
    id: jsonTreeView
    
    Constants {
        id: constants
    }
    
    property alias model: treeModel
    property alias currentIndex: treeView.currentIndex
    
    // Signals
    signal itemSelected(var index)
    signal itemDoubleClicked(var index)
    
    // Filtering/search state
    property var _filterRegex: null
    property bool _filteringActive: false
    property var _searchMatches: []
    property int _searchCursor: -1
    
    // Tree model for proper hierarchical display
    ListModel {
        id: treeModel
    }
    
    // Function to populate tree model from flat JSON data
    function updateTreeModel(flatList) {
        // console.log("updateTreeModel called with", flatList.length, "items")
        treeModel.clear()
        
        // Convert flat list to hierarchical tree structure
        var stack = []
        var currentDepth = -1
        
        for (var i = 0; i < flatList.length; i++) {
            var item = flatList[i]
            var depth = item.depth || 0
            
            // Adjust stack based on depth
            while (stack.length > depth) {
                stack.pop()
            }
            
            // Add item to tree model
            var treeItem = {
                key: item.key,
                value: item.value,
                type: item.type,
                depth: depth,
                hasChildren: item.hasChildren,
                expanded: item.expanded,
                index: item.index,
                path: (stack.length > 0 ? stack.join('.') + '.' : '') + item.key,
                visible: true
            }
            
            treeModel.append(treeItem)
            // console.log("Added item:", item.key, "value:", item.value, "type:", item.type, "expanded:", item.expanded, "hasChildren:", item.hasChildren)
            
            // Update stack for next iteration
            if (item.hasChildren && item.expanded) {
                stack.push(item.key)
            }
        }
    }
    
    // json-viewer-like public API
    function expandAll() {
        if (app && app.expandAllNodes) { app.expandAllNodes(); return }
        for (var i = 0; i < treeModel.count; i++) {
            var it = treeModel.get(i)
            if (it.hasChildren && !it.expanded) app.setItemExpanded(it.index, true)
        }
    }

    function collapseAll() {
        if (app && app.collapseAllNodes) { app.collapseAllNodes(); return }
        for (var i = 0; i < treeModel.count; i++) {
            var it = treeModel.get(i)
            if (it.hasChildren && it.expanded) app.setItemExpanded(it.index, false)
        }
    }

    function _matches(item, regexOrPath) {
        if (!regexOrPath) return false
        if (regexOrPath instanceof RegExp) return regexOrPath.test(item.path)
        try { return new RegExp(regexOrPath).test(item.path) } catch(e) { return item.path.indexOf(regexOrPath) !== -1 }
    }

    function expand(regexOrPath) {
        for (var i = 0; i < treeModel.count; i++) {
            var it = treeModel.get(i)
            if (it.hasChildren && _matches(it, regexOrPath)) app.setItemExpanded(it.index, true)
        }
    }

    function collapse(regexOrPath) {
        for (var i = 0; i < treeModel.count; i++) {
            var it = treeModel.get(i)
            if (it.hasChildren && _matches(it, regexOrPath)) app.setItemExpanded(it.index, false)
        }
    }

    function filter(regexOrPath) {
        _filteringActive = true
        try { _filterRegex = (regexOrPath instanceof RegExp) ? regexOrPath : new RegExp(regexOrPath) } catch(e) { _filterRegex = null }
        for (var i = 0; i < treeModel.count; i++) {
            var it = treeModel.get(i)
            var match = _filterRegex ? _filterRegex.test(it.path) : false
            treeModel.setProperty(i, 'visible', match)
        }
    }

    function resetFilter() {
        _filteringActive = false
        _filterRegex = null
        for (var i = 0; i < treeModel.count; i++) treeModel.setProperty(i, 'visible', true)
    }

    function search(regexOrPath) {
        _searchMatches = []
        _searchCursor = -1
        var rx
        try { rx = (regexOrPath instanceof RegExp) ? regexOrPath : new RegExp(regexOrPath) } catch(e) { return 0 }
        for (var i = 0; i < treeModel.count; i++) {
            var it = treeModel.get(i)
            if (rx.test(it.path) || rx.test(it.value)) _searchMatches.push(i)
        }
        return _searchMatches.length
    }

    function searchNext() {
        if (_searchMatches.length === 0) return -1
        _searchCursor = (_searchCursor + 1) % _searchMatches.length
        treeView.currentIndex = _searchMatches[_searchCursor]
        return treeView.currentIndex
    }

    function searchPrev() {
        if (_searchMatches.length === 0) return -1
        _searchCursor = (_searchCursor - 1 + _searchMatches.length) % _searchMatches.length
        treeView.currentIndex = _searchMatches[_searchCursor]
        return treeView.currentIndex
    }

    // Tree view using ListView with Dadroit-style delegate
    ListView {
        id: treeView
        anchors.fill: parent
        model: treeModel
        clip: true
        focus: true
        cacheBuffer: 800
        
        delegate: Rectangle {
            id: treeDelegate
            width: treeView.width
            height: 20
            color: treeView.currentIndex === index ? "#44475a" : (hoverArea.containsMouse ? "#2f3241" : "transparent")
            clip: true
            
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 8 + (model.depth * 16) // Proper indentation
                anchors.rightMargin: 8
                spacing: 6
                
                // Indentation guides
                Repeater {
                    model: model.depth
                    delegate: Rectangle {
                        width: 16
                        height: parent.height
                        color: "transparent"
                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            x: 7
                            width: 1
                            height: parent.height
                            color: "#3a3d4a"
                        }
                    }
                }
                
                // Expand/collapse arrow - visible
                Text {
                    width: 16
                    height: 12
                    text: model.hasChildren ? (model.expanded ? "▼" : "▶") : ""
                    font.pixelSize: 10
                    color: "#8be9fd" // Cyan color for visibility
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: model.hasChildren ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onClicked: {
                            console.log("Arrow clicked for:", model.key, "index:", model.index)
                            app.setItemExpanded(model.index, !model.expanded)
                        }
                    }
                }
                
                // Type icon - visible
                Text {
                    text: model.key.startsWith("Array[") ? "≡" : getTypeIcon(model.type)
                    font.pixelSize: 10
                    color: model.key.startsWith("Array[") ? "#8be9fd" : getTypeIconColor(model.type)
                    width: 12
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                }
                
                // Key (compact width like OkJSON)
                Text {
                    Layout.preferredWidth: 120
                    Layout.maximumWidth: 150
                    text: model.key
                    font.family: constants.fontFamily
                    font.pixelSize: 13
                    color: model.key.startsWith("Array[") ? "#f8f8f2" : "#8be9fd" // White for root array, cyan for others
                    font.weight: model.key.startsWith("Array[") ? Font.Bold : Font.Normal // Bold for root
                    elide: Text.ElideRight
                    wrapMode: Text.NoWrap
                    maximumLineCount: 1
                }
                
                // Value (more space for data like OkJSON)
                Text {
                    Layout.preferredWidth: 200
                    Layout.fillWidth: true
                    text: model.key.startsWith("Array[") ? "" : (model.hasChildren && !model.expanded ? getCollapsedPreview(model.type) : getFormattedValue(model.type, model.value, model.hasChildren))
                    font.family: constants.fontFamily
                    font.pixelSize: 13
                    color: "#8be9fd" // Force cyan color for visibility
                    elide: Text.ElideRight
                    wrapMode: Text.NoWrap
                    maximumLineCount: 1
                }
                
                // Type info on the right (wider like OkJSON)
                Text {
                    Layout.preferredWidth: 120
                    text: model.key.startsWith("Array[") ? "" : getTypeInfo(model.type, model.hasChildren)
                    font.family: constants.fontFamily
                    font.pixelSize: 11
                    color: "#6272a4" // Visible comment color
                    horizontalAlignment: Text.AlignRight
                    elide: Text.ElideRight
                    wrapMode: Text.NoWrap
                    maximumLineCount: 1
                }
        }
        
            // Main click area (excluding arrow area)
            MouseArea {
                anchors.fill: parent
                anchors.leftMargin: 24 // Leave space for arrow and type icon
                hoverEnabled: true
                id: hoverArea
        onClicked: {
                    treeView.currentIndex = index
            jsonTreeView.itemSelected(index)
            if (model.hasChildren) {
                app.setItemExpanded(model.index, !model.expanded)
            }
        }
        
        onDoubleClicked: {
            if (model.hasChildren) {
                app.setItemExpanded(model.index, !model.expanded)
            }
            jsonTreeView.itemDoubleClicked(index)
        }
    }
        }
    }
    
    // Helper functions matching Dadroit's exact color scheme
    function getTypeIcon(type) {
        switch (type) {
        case 0: return "N" // Null
        case 1: return "✓" // Bool
        case 2: return "#" // Number
        case 3: return "\"" // String
        case 4: return "≡" // Object
        case 5: return "≡" // Array
        default: return "?"
        }
    }
    
    function getTypeIconColor(type) {
        switch (type) {
        case 0: return "#6272a4" // Null - comment color
        case 1: return "#8be9fd" // Bool - cyan (same as others)
        case 2: return "#8be9fd" // Number - cyan (same as others)
        case 3: return "#8be9fd" // String - cyan
        case 4: return "#8be9fd" // Object - cyan
        case 5: return "#8be9fd" // Array - cyan
        default: return "#6272a4"
        }
    }
    
    function getValueColor(type) {
        switch (type) {
        case 0: return "#6272a4" // Null - comment color
        case 1: return "#8be9fd" // Bool - cyan (same as strings)
        case 2: return "#8be9fd" // Number - cyan (same as strings)
        case 3: return "#8be9fd" // String - cyan
        case 4: return "#8be9fd" // Object - cyan
        case 5: return "#8be9fd" // Array - cyan
        default: return "#f8f8f2" // Default text color
        }
    }
    
    function getFormattedValue(type, value, hasChildren) {
        if (type === 0) { // Null
            return "null"
        } else if (type === 1) { // Boolean
            return value
        } else if (type === 2) { // Number
            return value
        } else if (type === 3) { // String
            return "\"" + value + "\""
        } else if (type === 4) { // Object
            return "Object{" + (hasChildren ? "..." : "0") + "}"
        } else if (type === 5) { // Array
            return "Array[" + (hasChildren ? "..." : "0") + "]"
        } else {
            return value
        }
    }

    function getCollapsedPreview(type) {
        if (type === 4) return "{…}"
        if (type === 5) return "[…]"
        return ""
    }
    
    function getTypeInfo(type, hasChildren) {
        switch (type) {
        case 0: return "Null"
        case 1: return "Boolean"
        case 2: return "Number"
        case 3: return "String"
        case 4: return hasChildren ? "Object{...}" : "Object{0}"
        case 5: return hasChildren ? "Array[...]" : "Array[0]"
        default: return "Unknown"
        }
    }
    
    // Scrollbars
    ScrollBar.vertical: ScrollBar {
        policy: ScrollBar.AsNeeded
        width: 8
    }
    
    ScrollBar.horizontal: ScrollBar {
        policy: ScrollBar.AsNeeded
        height: 8
    }
}