#include "Strings.hpp"
#include <QObject>

namespace treon {
namespace strings {

// Application
const QString APP_NAME = QObject::tr("Treon");
const QString APP_VERSION = QObject::tr("1.0.0");
const QString APP_DESCRIPTION = QObject::tr("JSON Formatter & Viewer");
const QString ORGANIZATION_NAME = QObject::tr("CycleRunCode Club");
const QString ORGANIZATION_DOMAIN = QObject::tr("cycleruncode.club");

// Menu items
namespace menu {
    const QString TREON = QObject::tr("Treon");
    const QString FILE = QObject::tr("File");
    const QString EDIT = QObject::tr("Edit");
    const QString FORMAT = QObject::tr("Format");
    const QString VIEW = QObject::tr("View");
    const QString WINDOW = QObject::tr("Window");
    const QString HELP = QObject::tr("Help");
    
    // Treon menu
    const QString ABOUT_TREON = QObject::tr("About Treon");
    const QString PREFERENCES = QObject::tr("Preferences...");
    const QString HIDE_TREON = QObject::tr("Hide Treon");
    const QString HIDE_OTHERS = QObject::tr("Hide Others");
    const QString SHOW_ALL = QObject::tr("Show All");
    const QString QUIT_TREON = QObject::tr("Quit Treon");
    
    // File menu
    const QString NEW = QObject::tr("New");
    const QString OPEN = QObject::tr("Open...");
    const QString OPEN_RECENT = QObject::tr("Open Recent");
    const QString CLOSE = QObject::tr("Close");
    const QString SAVE = QObject::tr("Save");
    const QString SAVE_AS = QObject::tr("Save As...");
    const QString REVERT_TO_SAVED = QObject::tr("Revert to Saved");
    const QString PAGE_SETUP = QObject::tr("Page Setup...");
    const QString PRINT = QObject::tr("Print...");
    
    // Edit menu
    const QString UNDO = QObject::tr("Undo");
    const QString REDO = QObject::tr("Redo");
    const QString CUT = QObject::tr("Cut");
    const QString COPY = QObject::tr("Copy");
    const QString PASTE = QObject::tr("Paste");
    const QString PASTE_AND_MATCH_STYLE = QObject::tr("Paste and Match Style");
    const QString DELETE = QObject::tr("Delete");
    const QString SELECT_ALL = QObject::tr("Select All");
    const QString FIND = QObject::tr("Find");
    const QString FIND_AND_REPLACE = QObject::tr("Find and Replace...");
    const QString FIND_NEXT = QObject::tr("Find Next");
    const QString FIND_PREVIOUS = QObject::tr("Find Previous");
    const QString USE_SELECTION_FOR_FIND = QObject::tr("Use Selection for Find");
    const QString JUMP_TO_SELECTION = QObject::tr("Jump to Selection");
    
    // Format menu
    const QString FONT = QObject::tr("Font");
    const QString SHOW_FONTS = QObject::tr("Show Fonts");
    const QString BOLD = QObject::tr("Bold");
    const QString ITALIC = QObject::tr("Italic");
    const QString UNDERLINE = QObject::tr("Underline");
    const QString BIGGER = QObject::tr("Bigger");
    const QString SMALLER = QObject::tr("Smaller");
    const QString TEXT = QObject::tr("Text");
    const QString ALIGN_LEFT = QObject::tr("Align Left");
    const QString CENTER = QObject::tr("Center");
    const QString JUSTIFY = QObject::tr("Justify");
    const QString ALIGN_RIGHT = QObject::tr("Align Right");
    
    // View menu
    const QString SHOW_TOOLBAR = QObject::tr("Show Toolbar");
    const QString CUSTOMIZE_TOOLBAR = QObject::tr("Customize Toolbar...");
    const QString SHOW_SIDEBAR = QObject::tr("Show Sidebar");
    const QString ENTER_FULL_SCREEN = QObject::tr("Enter Full Screen");
    const QString TOGGLE_THEME = QObject::tr("Toggle Theme");
    const QString EXPAND_ALL = QObject::tr("Expand All");
    const QString COLLAPSE_ALL = QObject::tr("Collapse All");
    
    // Window menu
    const QString MINIMIZE = QObject::tr("Minimize");
    const QString ZOOM = QObject::tr("Zoom");
    const QString BRING_ALL_TO_FRONT = QObject::tr("Bring All to Front");
    
    // Help menu
    const QString TREON_HELP = QObject::tr("Treon Help");
}

// Landing screen
namespace landing {
    const QString TITLE = QObject::tr("Treon");
    const QString SUBTITLE = QObject::tr("JSON Formatter & Viewer");
    const QString OPEN_FILE = QObject::tr("Open File");
    const QString NEW_FILE = QObject::tr("New File");
    const QString FROM_PASTEBOARD = QObject::tr("From Pasteboard");
    const QString FROM_URL = QObject::tr("From URL");
    const QString FROM_CURL = QObject::tr("From cURL");
    const QString RECENT_FILES = QObject::tr("Recent Files");
    const QString NO_RECENT_FILES = QObject::tr("No recent files");
    const QString DRAG_AND_DROP_HINT = QObject::tr("Drag and drop a JSON file here");
}

// About window
namespace about {
    const QString TITLE = QObject::tr("About %1").arg(APP_NAME);
    const QString DESCRIPTION = QObject::tr("A powerful JSON viewer, editor, and formatter built with Qt and C++. "
                                           "Treon provides a modern, native experience for working with JSON data "
                                           "on macOS with advanced features like syntax highlighting, validation, "
                                           "and querying capabilities.");
    const QString WEBSITE = QObject::tr("Website");
    const QString DOCUMENTATION = QObject::tr("Documentation");
    const QString SUPPORT = QObject::tr("Support");
    const QString VIEW_LICENSE = QObject::tr("View License");
    const QString TECHNICAL_INFORMATION = QObject::tr("Technical Information");
    const QString VERSION = QObject::tr("Version:");
    const QString BUILD = QObject::tr("Build:");
    const QString QT_VERSION_LABEL = QObject::tr("Qt Version:");
    const QString PLATFORM = QObject::tr("Platform:");
    const QString COMPILER = QObject::tr("Compiler:");
    const QString COPY = QObject::tr("Copy");
    const QString THIRD_PARTY_LIBRARIES = QObject::tr("Third-Party Libraries");
    const QString CREDITS = QObject::tr("Credits");
    const QString LICENSE = QObject::tr("License");
    const QString DEVELOPMENT_TEAM = QObject::tr("Development Team");
    const QString CONTRIBUTORS = QObject::tr("Contributors");
    const QString OPEN_SOURCE_COMMUNITY = QObject::tr("Open Source Community");
}

// Dialogs
namespace dialogs {
    const QString OPEN_JSON_FILE = QObject::tr("Open JSON File");
    const QString SAVE_JSON_FILE = QObject::tr("Save JSON File");
    const QString LOAD_FROM_URL = QObject::tr("Load from URL");
    const QString EXECUTE_CURL_COMMAND = QObject::tr("Execute cURL Command");
    const QString ENTER_URL = QObject::tr("Enter URL:");
    const QString ENTER_CURL_COMMAND = QObject::tr("Enter cURL command:");
    const QString CANCEL = QObject::tr("Cancel");
    const QString LOAD = QObject::tr("Load");
    const QString EXECUTE = QObject::tr("Execute");
    const QString ERROR = QObject::tr("Error");
}

// File filters
namespace filters {
    const QString JSON_FILES = QObject::tr("JSON files (*.json)");
    const QString ALL_FILES = QObject::tr("All files (*)");
}

// Status messages
namespace status {
    const QString OPENING_FILE = QObject::tr("Opening file...");
    const QString FILE_OPENED_SUCCESSFULLY = QObject::tr("File opened successfully");
    const QString SAVING_FILE = QObject::tr("Saving file...");
    const QString FILE_SAVED_SUCCESSFULLY = QObject::tr("File saved successfully");
    const QString NEW_FILE_CREATED = QObject::tr("New file created");
    const QString FILE_CLOSED = QObject::tr("File closed");
    const QString JSON_FORMATTED = QObject::tr("JSON formatted");
    const QString JSON_MINIFIED = QObject::tr("JSON minified");
    const QString JSON_SORTING_NOT_IMPLEMENTED = QObject::tr("JSON sorting not yet implemented");
    const QString ALL_NODES_EXPANDED = QObject::tr("All nodes expanded");
    const QString ALL_NODES_COLLAPSED = QObject::tr("All nodes collapsed");
    const QString QUERY_EXECUTED = QObject::tr("Query executed (not yet implemented)");
    const QString QUERY_CLEARED = QObject::tr("Query cleared");
    const QString HISTORY_CLEARED = QObject::tr("History cleared");
    const QString SCRIPT_EXECUTION_NOT_IMPLEMENTED = QObject::tr("Script execution not yet implemented");
    const QString PRESET_SCRIPT_EXECUTION_NOT_IMPLEMENTED = QObject::tr("Preset script execution not yet implemented");
    const QString SWITCHED_TO_DARK_THEME = QObject::tr("Switched to dark theme");
    const QString SWITCHED_TO_LIGHT_THEME = QObject::tr("Switched to light theme");
    const QString PREFERENCES_NOT_IMPLEMENTED = QObject::tr("Preferences not yet implemented");
    const QString ABOUT_DIALOG_OPENED = QObject::tr("About dialog opened");
    const QString HELP_NOT_IMPLEMENTED = QObject::tr("Help not yet implemented");
    const QString NEW_FROM_PASTEBOARD_NOT_IMPLEMENTED = QObject::tr("New from pasteboard not yet implemented");
    const QString LOAD_FROM_URL_NOT_IMPLEMENTED = QObject::tr("Load from URL not yet implemented: %1");
    const QString EXECUTE_CURL_COMMAND_NOT_IMPLEMENTED = QObject::tr("Execute cURL command not yet implemented: %1");
    const QString REVERT_TO_SAVED_NOT_IMPLEMENTED = QObject::tr("Revert to saved not yet implemented");
    const QString PAGE_SETUP_NOT_IMPLEMENTED = QObject::tr("Page setup not yet implemented");
    const QString PRINT_DOCUMENT_NOT_IMPLEMENTED = QObject::tr("Print document not yet implemented");
}

// Error messages
namespace errors {
    const QString JSON_ERROR = QObject::tr("JSON Error: %1");
    const QString CANNOT_FORMAT_INVALID_JSON = QObject::tr("Cannot format invalid JSON: %1");
    const QString CANNOT_MINIFY_INVALID_JSON = QObject::tr("Cannot minify invalid JSON: %1");
    const QString QUERY_ERROR = QObject::tr("Query error: %1");
    const QString FILE_ERROR = QObject::tr("File error: %1");
    const QString NETWORK_ERROR = QObject::tr("Network error: %1");
    const QString PERMISSION_ERROR = QObject::tr("Permission error: %1");
}

// Settings
namespace settings {
    const QString LANGUAGE = QObject::tr("Language");
    const QString THEME = QObject::tr("Theme");
    const QString FONT_FAMILY = QObject::tr("Font Family");
    const QString FONT_SIZE = QObject::tr("Font Size");
    const QString WORD_WRAP = QObject::tr("Word Wrap");
    const QString SHOW_LINE_NUMBERS = QObject::tr("Show Line Numbers");
    const QString AUTO_SAVE = QObject::tr("Auto Save");
    const QString AUTO_SAVE_INTERVAL = QObject::tr("Auto Save Interval");
    const QString CHECK_FOR_UPDATES = QObject::tr("Check for Updates");
    const QString MAX_RECENT_FILES = QObject::tr("Max Recent Files");
    const QString LAST_DIRECTORY = QObject::tr("Last Directory");
    const QString REMEMBER_WINDOW_GEOMETRY = QObject::tr("Remember Window Geometry");
    const QString WINDOW_GEOMETRY = QObject::tr("Window Geometry");
    const QString WINDOW_STATE = QObject::tr("Window State");
}

// Third-party libraries
namespace libraries {
    const QString QT_FRAMEWORK = QObject::tr("Qt %1 - Cross-platform application framework");
    const QString CMAKE_BUILD_SYSTEM = QObject::tr("CMake - Build system");
    const QString JSON_LIBRARY = QObject::tr("JSON for Modern C++ - JSON library");
    const QString CATCH2_TESTING = QObject::tr("Catch2 - Testing framework");
    const QString GHERKIN_BDD = QObject::tr("Gherkin - BDD testing");
}

} // namespace strings
} // namespace treon
