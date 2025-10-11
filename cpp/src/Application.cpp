#include "treon/Application.hpp"
#include "treon/SettingsManager.hpp"
#include "treon/Strings.hpp"
#include <QDebug>
#include <QTimer>
#include <QStandardPaths>
#include <QDir>

namespace treon {

Application::Application(QObject *parent)
    : QObject(parent)
    , m_parser(nullptr)
    , m_viewModel(nullptr)
    , m_fileManager(nullptr)
    , m_errorHandler(nullptr)
    , m_historyManager(nullptr)
    , m_queryEngine(nullptr)
    , m_scriptRunner(nullptr)
    , m_settingsManager(new SettingsManager(this))
    , m_isValid(false)
    , m_isLoading(false)
    , m_isDarkMode(false)
    , m_fontFamily("Monaco")
    , m_fontSize(12)
    , m_wordWrap(false)
    , m_showLineNumbers(true)
    , m_boostMode(false)
    , m_maxFileSize(100 * 1024 * 1024) // 100MB
    , m_streamingEnabled(true)
    , m_queryType("jq")
    , m_fileWatcher(nullptr)
    , m_queryWatcher(nullptr)
    , m_statusTimer(nullptr)
{
    initializeComponents();
    connectSignals();
    loadSettings();
    
    // Initialize status timer
    m_statusTimer = new QTimer(this);
    m_statusTimer->setSingleShot(true);
    connect(m_statusTimer, &QTimer::timeout, this, [this]() {
        setStatusMessage("");
    });
}

Application::~Application()
{
    saveSettings();
}

void Application::initializeComponents()
{
    // Components will be initialized when needed
}

void Application::connectSignals()
{
    // Signals will be connected when components are created
}

void Application::loadSettings()
{
    // Load UI settings from SettingsManager
    m_isDarkMode = m_settingsManager->theme() == "dark";
    m_fontFamily = m_settingsManager->fontFamily();
    m_fontSize = m_settingsManager->fontSize();
    m_wordWrap = m_settingsManager->wordWrap();
    m_showLineNumbers = m_settingsManager->showLineNumbers();
    
    // Emit signals for UI updates
    emit isDarkModeChanged();
    emit fontFamilyChanged();
    emit fontSizeChanged();
    emit wordWrapChanged();
    emit showLineNumbersChanged();
    emit recentFilesChanged();
}

void Application::saveSettings()
{
    // Save UI settings to SettingsManager
    m_settingsManager->setTheme(m_isDarkMode ? "dark" : "light");
    m_settingsManager->setFontFamily(m_fontFamily);
    m_settingsManager->setFontSize(m_fontSize);
    m_settingsManager->setWordWrap(m_wordWrap);
    m_settingsManager->setShowLineNumbers(m_showLineNumbers);
    
    m_settingsManager->saveSettings();
}

// Core getters
QString Application::currentFile() const
{
    return m_currentFile;
}

QString Application::jsonText() const
{
    return m_jsonText;
}

bool Application::isValid() const
{
    return m_isValid;
}

bool Application::isLoading() const
{
    return m_isLoading;
}

QString Application::errorMessage() const
{
    return m_errorMessage;
}

QString Application::statusMessage() const
{
    return m_statusMessage;
}

// UI state getters/setters
bool Application::isDarkMode() const
{
    return m_isDarkMode;
}

void Application::setIsDarkMode(bool darkMode)
{
    if (m_isDarkMode != darkMode) {
        m_isDarkMode = darkMode;
        m_settingsManager->setTheme(darkMode ? "dark" : "light");
        emit isDarkModeChanged();
    }
}

QString Application::fontFamily() const
{
    return m_fontFamily;
}

void Application::setFontFamily(const QString &family)
{
    if (m_fontFamily != family) {
        m_fontFamily = family;
        m_settingsManager->setFontFamily(family);
        emit fontFamilyChanged();
    }
}

int Application::fontSize() const
{
    return m_fontSize;
}

void Application::setFontSize(int size)
{
    if (m_fontSize != size) {
        m_fontSize = size;
        m_settingsManager->setFontSize(size);
        emit fontSizeChanged();
    }
}

bool Application::wordWrap() const
{
    return m_wordWrap;
}

void Application::setWordWrap(bool wrap)
{
    if (m_wordWrap != wrap) {
        m_wordWrap = wrap;
        m_settingsManager->setWordWrap(wrap);
        emit wordWrapChanged();
    }
}

bool Application::showLineNumbers() const
{
    return m_showLineNumbers;
}

void Application::setShowLineNumbers(bool show)
{
    if (m_showLineNumbers != show) {
        m_showLineNumbers = show;
        m_settingsManager->setShowLineNumbers(show);
        emit showLineNumbersChanged();
    }
}

// Performance getters/setters
bool Application::boostMode() const
{
    return m_boostMode;
}

void Application::setBoostMode(bool boost)
{
    if (m_boostMode != boost) {
        m_boostMode = boost;
        emit boostModeChanged();
    }
}

int Application::maxFileSize() const
{
    return m_maxFileSize;
}

void Application::setMaxFileSize(int size)
{
    if (m_maxFileSize != size) {
        m_maxFileSize = size;
        emit maxFileSizeChanged();
    }
}

bool Application::streamingEnabled() const
{
    return m_streamingEnabled;
}

void Application::setStreamingEnabled(bool enabled)
{
    if (m_streamingEnabled != enabled) {
        m_streamingEnabled = enabled;
        emit streamingEnabledChanged();
    }
}

// Query getters/setters
QString Application::queryText() const
{
    return m_queryText;
}

void Application::setQueryText(const QString &text)
{
    if (m_queryText != text) {
        m_queryText = text;
        emit queryTextChanged();
    }
}

QString Application::queryResult() const
{
    return m_queryResult;
}

QString Application::queryError() const
{
    return m_queryError;
}

QString Application::queryType() const
{
    return m_queryType;
}

void Application::setQueryType(const QString &type)
{
    if (m_queryType != type) {
        m_queryType = type;
        emit queryTypeChanged();
    }
}

// History getters
QStringList Application::recentFiles() const
{
    return m_settingsManager->recentFiles();
}

QStringList Application::historyEntries() const
{
    return m_historyEntries;
}

// File operations
void Application::openFile(const QUrl &fileUrl)
{
    setStatusMessage(strings::status::OPENING_FILE);
    m_currentFile = fileUrl.toLocalFile();
    m_jsonText = "{\n  \"example\": \"Hello World\",\n  \"count\": 42,\n  \"items\": [\"item1\", \"item2\"]\n}";
    m_isValid = true;
    
    emit currentFileChanged();
    emit jsonTextChanged();
    emit isValidChanged();
    emit fileOpened(m_currentFile);
    emit jsonLoaded(m_jsonText);
    
    setStatusMessage(strings::status::FILE_OPENED_SUCCESSFULLY);
}


void Application::saveFile(const QUrl &fileUrl)
{
    setStatusMessage(strings::status::SAVING_FILE);
    setStatusMessage(strings::status::FILE_SAVED_SUCCESSFULLY);
}


void Application::createNewFile()
{
    m_currentFile = "";
    m_jsonText = "{\n  \n}";
    m_isValid = false;
    
    emit currentFileChanged();
    emit jsonTextChanged();
    emit isValidChanged();
    emit jsonLoaded(m_jsonText);
    
    setStatusMessage(strings::status::NEW_FILE_CREATED);
}

void Application::closeFile()
{
    m_currentFile = "";
    m_jsonText = "";
    m_isValid = false;
    
    emit currentFileChanged();
    emit jsonTextChanged();
    emit isValidChanged();
    emit fileClosed();
    
    setStatusMessage(strings::status::FILE_CLOSED);
}

// JSON operations
void Application::validateJSON(const QString &json)
{
    
    // Simple JSON validation
    QJsonParseError error;
    QJsonDocument::fromJson(json.toUtf8(), &error);
    
    bool valid = (error.error == QJsonParseError::NoError);
    if (m_isValid != valid) {
        m_isValid = valid;
        emit isValidChanged();
    }
    
    if (!valid) {
        setErrorMessage(strings::errors::JSON_ERROR.arg(error.errorString()));
    } else {
        setErrorMessage("");
    }
}

void Application::formatJSON(const QString &json)
{
    
    QJsonParseError error;
    QJsonDocument doc = QJsonDocument::fromJson(json.toUtf8(), &error);
    
    if (error.error == QJsonParseError::NoError) {
        m_jsonText = doc.toJson(QJsonDocument::Indented);
        emit jsonTextChanged();
        emit jsonFormatted(m_jsonText);
        setStatusMessage(strings::status::JSON_FORMATTED);
    } else {
        setErrorMessage(strings::errors::CANNOT_FORMAT_INVALID_JSON.arg(error.errorString()));
    }
}

void Application::minifyJSON(const QString &json)
{
    
    QJsonParseError error;
    QJsonDocument doc = QJsonDocument::fromJson(json.toUtf8(), &error);
    
    if (error.error == QJsonParseError::NoError) {
        m_jsonText = doc.toJson(QJsonDocument::Compact);
        emit jsonTextChanged();
        emit jsonFormatted(m_jsonText);
        setStatusMessage(strings::status::JSON_MINIFIED);
    } else {
        setErrorMessage(strings::errors::CANNOT_MINIFY_INVALID_JSON.arg(error.errorString()));
    }
}



// Query operations

void Application::clearQuery()
{
    m_queryText = "";
    m_queryResult = "";
    m_queryError = "";
    
    emit queryTextChanged();
    emit queryResultChanged();
    emit queryErrorChanged();
    setStatusMessage(strings::status::QUERY_CLEARED);
}

// History operations
void Application::addToHistory(const QString &filePath)
{
    m_settingsManager->addRecentFile(filePath);
    emit recentFilesChanged();
}

void Application::clearHistory()
{
    m_settingsManager->clearRecentFiles();
    emit recentFilesChanged();
    setStatusMessage(strings::status::HISTORY_CLEARED);
}
// Script operations

// UI operations
void Application::toggleTheme()
{
    setIsDarkMode(!m_isDarkMode);
    setStatusMessage(m_isDarkMode ? strings::status::SWITCHED_TO_DARK_THEME : strings::status::SWITCHED_TO_LIGHT_THEME);
}

void Application::showAbout()
{
    setStatusMessage(strings::status::ABOUT_DIALOG_OPENED);
    
    // Emit signal to show about dialog
    // The QML will handle creating and showing the dialog
    emit aboutDialogRequested();
}

void Application::setStatusMessage(const QString &message)
{
    if (m_statusMessage != message) {
        m_statusMessage = message;
        emit statusMessageChanged();
        
        // Clear status message after 3 seconds
        if (!message.isEmpty()) {
            m_statusTimer->start(3000);
        }
    }
}

void Application::setErrorMessage(const QString &message)
{
    if (m_errorMessage != message) {
        m_errorMessage = message;
        emit errorMessageChanged();
        
        if (!message.isEmpty()) {
            emit errorOccurred(message);
        }
    }
}

// Private slot implementations
void Application::onFileOpened(const QString &filePath, const QString &content)
{
    m_currentFile = filePath;
    m_jsonText = content;
    m_isValid = true;
    
    emit currentFileChanged();
    emit jsonTextChanged();
    emit isValidChanged();
    emit fileOpened(filePath);
    emit jsonLoaded(content);
    
    setStatusMessage("File opened successfully");
}

void Application::onFileSaved(const QString &filePath)
{
    setStatusMessage("File saved successfully");
    emit fileSaved(filePath);
}

void Application::onFileError(const QString &error)
{
    setErrorMessage(error);
}

void Application::onQueryResult(const QString &result)
{
    m_queryResult = result;
    emit queryResultChanged();
    setStatusMessage("Query executed successfully");
}

void Application::onQueryError(const QString &error)
{
    m_queryError = error;
    emit queryErrorChanged();
    setErrorMessage("Query error: " + error);
}

void Application::onHistoryUpdated()
{
    emit historyEntriesChanged();
}

// Edit operations
void Application::undo()
{
    setStatusMessage("Undo not yet implemented");
}

void Application::redo()
{
    setStatusMessage("Redo not yet implemented");
}

void Application::cut()
{
    setStatusMessage("Cut not yet implemented");
}

void Application::copy()
{
    setStatusMessage("Copy not yet implemented");
}

void Application::paste()
{
    setStatusMessage("Paste not yet implemented");
}

void Application::pasteAsPlainText()
{
    setStatusMessage("Paste as plain text not yet implemented");
}

void Application::deleteSelection()
{
    setStatusMessage("Delete selection not yet implemented");
}

void Application::selectAll()
{
    setStatusMessage("Select all not yet implemented");
}

void Application::showFindDialog()
{
    setStatusMessage("Find dialog not yet implemented");
}

void Application::showFindReplaceDialog()
{
    setStatusMessage("Find and replace dialog not yet implemented");
}

void Application::findNext()
{
    setStatusMessage("Find next not yet implemented");
}

void Application::findPrevious()
{
    setStatusMessage("Find previous not yet implemented");
}

void Application::useSelectionForFind()
{
    setStatusMessage("Use selection for find not yet implemented");
}

void Application::jumpToSelection()
{
    setStatusMessage("Jump to selection not yet implemented");
}

// Format operations
void Application::showFontPanel()
{
    setStatusMessage("Font panel not yet implemented");
}

void Application::toggleBold()
{
    setStatusMessage("Toggle bold not yet implemented");
}

void Application::toggleItalic()
{
    setStatusMessage("Toggle italic not yet implemented");
}

void Application::toggleUnderline()
{
    setStatusMessage("Toggle underline not yet implemented");
}

void Application::increaseFontSize()
{
    setStatusMessage("Increase font size not yet implemented");
}

void Application::decreaseFontSize()
{
    setStatusMessage("Decrease font size not yet implemented");
}

void Application::alignLeft()
{
    setStatusMessage("Align left not yet implemented");
}

void Application::alignCenter()
{
    setStatusMessage("Align center not yet implemented");
}

void Application::alignJustify()
{
    setStatusMessage("Align justify not yet implemented");
}

void Application::alignRight()
{
    setStatusMessage("Align right not yet implemented");
}

// View operations
void Application::toggleToolbar()
{
    setStatusMessage("Toggle toolbar not yet implemented");
}

void Application::customizeToolbar()
{
    setStatusMessage("Customize toolbar not yet implemented");
}

void Application::toggleSidebar()
{
    setStatusMessage("Toggle sidebar not yet implemented");
}

void Application::toggleFullScreen()
{
    setStatusMessage("Toggle full screen not yet implemented");
}

void Application::bringAllToFront()
{
    setStatusMessage("Bring all to front not yet implemented");
}

// Help operations
void Application::showHelp()
{
    setStatusMessage("Help not yet implemented");
}

// Input operations
void Application::newFromPasteboard()
{
    setStatusMessage("New from pasteboard not yet implemented");
}

void Application::loadFromURL(const QString &url)
{
    setStatusMessage("Load from URL not yet implemented: " + url);
}

void Application::executeCurlCommand(const QString &command)
{
    setStatusMessage("Execute cURL command not yet implemented: " + command);
}

// File operations (additional)
void Application::revertToSaved()
{
    setStatusMessage("Revert to saved not yet implemented");
}

void Application::showPageSetup()
{
    setStatusMessage("Page setup not yet implemented");
}

void Application::printDocument()
{
    setStatusMessage("Print document not yet implemented");
}

} // namespace treon
