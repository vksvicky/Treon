#pragma once

#include <QString>

namespace treon {
namespace strings {

// Application
extern const QString APP_NAME;
extern const QString APP_VERSION;
extern const QString APP_DESCRIPTION;
extern const QString ORGANIZATION_NAME;
extern const QString ORGANIZATION_DOMAIN;

// Menu items
namespace menu {
    extern const QString TREON;
    extern const QString FILE;
    extern const QString EDIT;
    extern const QString FORMAT;
    extern const QString VIEW;
    extern const QString WINDOW;
    extern const QString HELP;
    
    // Treon menu
    extern const QString ABOUT_TREON;
    extern const QString PREFERENCES;
    extern const QString HIDE_TREON;
    extern const QString HIDE_OTHERS;
    extern const QString SHOW_ALL;
    extern const QString QUIT_TREON;
    
    // File menu
    extern const QString NEW;
    extern const QString OPEN;
    extern const QString OPEN_RECENT;
    extern const QString CLOSE;
    extern const QString SAVE;
    extern const QString SAVE_AS;
    extern const QString REVERT_TO_SAVED;
    extern const QString PAGE_SETUP;
    extern const QString PRINT;
    
    // Edit menu
    extern const QString UNDO;
    extern const QString REDO;
    extern const QString CUT;
    extern const QString COPY;
    extern const QString PASTE;
    extern const QString PASTE_AND_MATCH_STYLE;
    extern const QString DELETE;
    extern const QString SELECT_ALL;
    extern const QString FIND;
    extern const QString FIND_AND_REPLACE;
    extern const QString FIND_NEXT;
    extern const QString FIND_PREVIOUS;
    extern const QString USE_SELECTION_FOR_FIND;
    extern const QString JUMP_TO_SELECTION;
    
    // Format menu
    extern const QString FONT;
    extern const QString SHOW_FONTS;
    extern const QString BOLD;
    extern const QString ITALIC;
    extern const QString UNDERLINE;
    extern const QString BIGGER;
    extern const QString SMALLER;
    extern const QString TEXT;
    extern const QString ALIGN_LEFT;
    extern const QString CENTER;
    extern const QString JUSTIFY;
    extern const QString ALIGN_RIGHT;
    
    // View menu
    extern const QString SHOW_TOOLBAR;
    extern const QString CUSTOMIZE_TOOLBAR;
    extern const QString SHOW_SIDEBAR;
    extern const QString ENTER_FULL_SCREEN;
    extern const QString TOGGLE_THEME;
    extern const QString EXPAND_ALL;
    extern const QString COLLAPSE_ALL;
    
    // Window menu
    extern const QString MINIMIZE;
    extern const QString ZOOM;
    extern const QString BRING_ALL_TO_FRONT;
    
    // Help menu
    extern const QString TREON_HELP;
}

// Landing screen
namespace landing {
    extern const QString TITLE;
    extern const QString SUBTITLE;
    extern const QString OPEN_FILE;
    extern const QString NEW_FILE;
    extern const QString FROM_PASTEBOARD;
    extern const QString FROM_URL;
    extern const QString FROM_CURL;
    extern const QString RECENT_FILES;
    extern const QString NO_RECENT_FILES;
    extern const QString DRAG_AND_DROP_HINT;
}

// About window
namespace about {
    extern const QString TITLE;
    extern const QString DESCRIPTION;
    extern const QString WEBSITE;
    extern const QString DOCUMENTATION;
    extern const QString SUPPORT;
    extern const QString VIEW_LICENSE;
    extern const QString TECHNICAL_INFORMATION;
    extern const QString VERSION;
    extern const QString BUILD;
    extern const QString QT_VERSION_LABEL;
    extern const QString PLATFORM;
    extern const QString COMPILER;
    extern const QString COPY;
    extern const QString THIRD_PARTY_LIBRARIES;
    extern const QString CREDITS;
    extern const QString LICENSE;
    extern const QString DEVELOPMENT_TEAM;
    extern const QString CONTRIBUTORS;
    extern const QString OPEN_SOURCE_COMMUNITY;
}

// Dialogs
namespace dialogs {
    extern const QString OPEN_JSON_FILE;
    extern const QString SAVE_JSON_FILE;
    extern const QString LOAD_FROM_URL;
    extern const QString EXECUTE_CURL_COMMAND;
    extern const QString ENTER_URL;
    extern const QString ENTER_CURL_COMMAND;
    extern const QString CANCEL;
    extern const QString LOAD;
    extern const QString EXECUTE;
    extern const QString ERROR;
}

// File filters
namespace filters {
    extern const QString JSON_FILES;
    extern const QString ALL_FILES;
}

// Status messages
namespace status {
    extern const QString OPENING_FILE;
    extern const QString FILE_OPENED_SUCCESSFULLY;
    extern const QString SAVING_FILE;
    extern const QString FILE_SAVED_SUCCESSFULLY;
    extern const QString NEW_FILE_CREATED;
    extern const QString FILE_CLOSED;
    extern const QString JSON_FORMATTED;
    extern const QString JSON_MINIFIED;
    extern const QString JSON_SORTING_NOT_IMPLEMENTED;
    extern const QString ALL_NODES_EXPANDED;
    extern const QString ALL_NODES_COLLAPSED;
    extern const QString QUERY_EXECUTED;
    extern const QString QUERY_CLEARED;
    extern const QString HISTORY_CLEARED;
    extern const QString SCRIPT_EXECUTION_NOT_IMPLEMENTED;
    extern const QString PRESET_SCRIPT_EXECUTION_NOT_IMPLEMENTED;
    extern const QString SWITCHED_TO_DARK_THEME;
    extern const QString SWITCHED_TO_LIGHT_THEME;
    extern const QString PREFERENCES_NOT_IMPLEMENTED;
    extern const QString ABOUT_DIALOG_OPENED;
    extern const QString HELP_NOT_IMPLEMENTED;
    extern const QString NEW_FROM_PASTEBOARD_NOT_IMPLEMENTED;
    extern const QString LOAD_FROM_URL_NOT_IMPLEMENTED;
    extern const QString EXECUTE_CURL_COMMAND_NOT_IMPLEMENTED;
    extern const QString REVERT_TO_SAVED_NOT_IMPLEMENTED;
    extern const QString PAGE_SETUP_NOT_IMPLEMENTED;
    extern const QString PRINT_DOCUMENT_NOT_IMPLEMENTED;
}

// Error messages
namespace errors {
    extern const QString JSON_ERROR;
    extern const QString CANNOT_FORMAT_INVALID_JSON;
    extern const QString CANNOT_MINIFY_INVALID_JSON;
    extern const QString QUERY_ERROR;
    extern const QString FILE_ERROR;
    extern const QString NETWORK_ERROR;
    extern const QString PERMISSION_ERROR;
}

// Settings
namespace settings {
    extern const QString LANGUAGE;
    extern const QString THEME;
    extern const QString FONT_FAMILY;
    extern const QString FONT_SIZE;
    extern const QString WORD_WRAP;
    extern const QString SHOW_LINE_NUMBERS;
    extern const QString AUTO_SAVE;
    extern const QString AUTO_SAVE_INTERVAL;
    extern const QString CHECK_FOR_UPDATES;
    extern const QString MAX_RECENT_FILES;
    extern const QString LAST_DIRECTORY;
    extern const QString REMEMBER_WINDOW_GEOMETRY;
    extern const QString WINDOW_GEOMETRY;
    extern const QString WINDOW_STATE;
}

// Third-party libraries
namespace libraries {
    extern const QString QT_FRAMEWORK;
    extern const QString CMAKE_BUILD_SYSTEM;
    extern const QString JSON_LIBRARY;
    extern const QString CATCH2_TESTING;
    extern const QString GHERKIN_BDD;
}

} // namespace strings
} // namespace treon
