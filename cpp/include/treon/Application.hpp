#pragma once

#include <QObject>
#include <QString>
#include <QUrl>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QTimer>
#include <QThread>
#include <QFuture>
#include <QFutureWatcher>

namespace treon {

class JSONParser;
class JSONViewModel;
class FileManager;
class ErrorHandler;
class HistoryManager;
class QueryEngine;
class ScriptRunner;
class SettingsManager;

class Application : public QObject
{
    Q_OBJECT
    
    // Core properties
    Q_PROPERTY(QString currentFile READ currentFile NOTIFY currentFileChanged)
    Q_PROPERTY(QString jsonText READ jsonText NOTIFY jsonTextChanged)
    Q_PROPERTY(bool isValid READ isValid NOTIFY isValidChanged)
    Q_PROPERTY(bool isLoading READ isLoading NOTIFY isLoadingChanged)
    Q_PROPERTY(QString errorMessage READ errorMessage NOTIFY errorMessageChanged)
    Q_PROPERTY(QString statusMessage READ statusMessage NOTIFY statusMessageChanged)
    
    // UI state properties
    Q_PROPERTY(bool isDarkMode READ isDarkMode WRITE setIsDarkMode NOTIFY isDarkModeChanged)
    Q_PROPERTY(QString fontFamily READ fontFamily WRITE setFontFamily NOTIFY fontFamilyChanged)
    Q_PROPERTY(int fontSize READ fontSize WRITE setFontSize NOTIFY fontSizeChanged)
    Q_PROPERTY(bool wordWrap READ wordWrap WRITE setWordWrap NOTIFY wordWrapChanged)
    Q_PROPERTY(bool showLineNumbers READ showLineNumbers WRITE setShowLineNumbers NOTIFY showLineNumbersChanged)
    
    // Performance properties
    Q_PROPERTY(bool boostMode READ boostMode WRITE setBoostMode NOTIFY boostModeChanged)
    Q_PROPERTY(int maxFileSize READ maxFileSize WRITE setMaxFileSize NOTIFY maxFileSizeChanged)
    Q_PROPERTY(bool streamingEnabled READ streamingEnabled WRITE setStreamingEnabled NOTIFY streamingEnabledChanged)
    
    // Query properties
    Q_PROPERTY(QString queryText READ queryText WRITE setQueryText NOTIFY queryTextChanged)
    Q_PROPERTY(QString queryResult READ queryResult NOTIFY queryResultChanged)
    Q_PROPERTY(QString queryError READ queryError NOTIFY queryErrorChanged)
    Q_PROPERTY(QString queryType READ queryType WRITE setQueryType NOTIFY queryTypeChanged)
    
    // History properties
    Q_PROPERTY(QStringList recentFiles READ recentFiles NOTIFY recentFilesChanged)
    Q_PROPERTY(QStringList historyEntries READ historyEntries NOTIFY historyEntriesChanged)

public:
    explicit Application(QObject *parent = nullptr);
    ~Application();

    // Core getters
    QString currentFile() const;
    QString jsonText() const;
    bool isValid() const;
    bool isLoading() const;
    QString errorMessage() const;
    QString statusMessage() const;
    
    // UI state getters/setters
    bool isDarkMode() const;
    void setIsDarkMode(bool darkMode);
    QString fontFamily() const;
    void setFontFamily(const QString &family);
    int fontSize() const;
    void setFontSize(int size);
    bool wordWrap() const;
    void setWordWrap(bool wrap);
    bool showLineNumbers() const;
    void setShowLineNumbers(bool show);
    
    // Performance getters/setters
    bool boostMode() const;
    void setBoostMode(bool boost);
    int maxFileSize() const;
    void setMaxFileSize(int size);
    bool streamingEnabled() const;
    void setStreamingEnabled(bool enabled);
    
    // Query getters/setters
    QString queryText() const;
    void setQueryText(const QString &text);
    QString queryResult() const;
    QString queryError() const;
    QString queryType() const;
    void setQueryType(const QString &type);
    
    // History getters
    QStringList recentFiles() const;
    QStringList historyEntries() const;

public slots:
    // File operations
    void openFile(const QUrl &fileUrl);
    void saveFile(const QUrl &fileUrl = QUrl());
    void createNewFile();
    void closeFile();
    
    // JSON operations
    void validateJSON(const QString &json);
    void formatJSON(const QString &json);
    void minifyJSON(const QString &json);
    
    // Query operations
    void clearQuery();
    
    // History operations
    void addToHistory(const QString &filePath);
    void clearHistory();
    
    // Script operations
    
    // Edit operations
    void undo();
    void redo();
    void cut();
    void copy();
    void paste();
    void pasteAsPlainText();
    void deleteSelection();
    void selectAll();
    void showFindDialog();
    void showFindReplaceDialog();
    void findNext();
    void findPrevious();
    void useSelectionForFind();
    void jumpToSelection();

    // Format operations
    void showFontPanel();
    void toggleBold();
    void toggleItalic();
    void toggleUnderline();
    void increaseFontSize();
    void decreaseFontSize();
    void alignLeft();
    void alignCenter();
    void alignJustify();
    void alignRight();

    // View operations
    void toggleToolbar();
    void customizeToolbar();
    void toggleSidebar();
    void toggleFullScreen();
    void bringAllToFront();

    // Help operations
    void showHelp();

    // Input operations
    void newFromPasteboard();
    void loadFromURL(const QString &url);
    void executeCurlCommand(const QString &command);

    // File operations (additional)
    void revertToSaved();
    void showPageSetup();
    void printDocument();

    // UI operations
    void toggleTheme();
    void showAbout();
    void setStatusMessage(const QString &message);
    void setErrorMessage(const QString &message);

signals:
    // Core signals
    void currentFileChanged();
    void jsonTextChanged();
    void isValidChanged();
    void isLoadingChanged();
    void errorMessageChanged();
    void statusMessageChanged();
    
    // UI state signals
    void isDarkModeChanged();
    void fontFamilyChanged();
    void fontSizeChanged();
    void wordWrapChanged();
    void showLineNumbersChanged();
    
    // Performance signals
    void boostModeChanged();
    void maxFileSizeChanged();
    void streamingEnabledChanged();
    
    // Query signals
    void queryTextChanged();
    void queryResultChanged();
    void queryErrorChanged();
    void queryTypeChanged();
    
    // History signals
    void recentFilesChanged();
    void historyEntriesChanged();
    
    // File operation signals
    void fileOpened(const QString &filePath);
    void fileSaved(const QString &filePath);
    void fileClosed();
    void jsonLoaded(const QString &json);
    void jsonFormatted(const QString &json);
    void queryExecuted(const QString &result);
    void errorOccurred(const QString &error);
    void aboutDialogRequested();

private slots:
    void onFileOpened(const QString &filePath, const QString &content);
    void onFileSaved(const QString &filePath);
    void onFileError(const QString &error);
    void onQueryResult(const QString &result);
    void onQueryError(const QString &error);
    void onHistoryUpdated();

private:
    void initializeComponents();
    void connectSignals();
    void loadSettings();
    void saveSettings();
    void updateStatusMessage(const QString &message);
    
    // Core components
    JSONParser *m_parser;
    JSONViewModel *m_viewModel;
    FileManager *m_fileManager;
    ErrorHandler *m_errorHandler;
    HistoryManager *m_historyManager;
    QueryEngine *m_queryEngine;
    ScriptRunner *m_scriptRunner;
    SettingsManager *m_settingsManager;
    
    // State
    QString m_currentFile;
    QString m_jsonText;
    bool m_isValid;
    bool m_isLoading;
    QString m_errorMessage;
    QString m_statusMessage;
    
    // UI state
    bool m_isDarkMode;
    QString m_fontFamily;
    int m_fontSize;
    bool m_wordWrap;
    bool m_showLineNumbers;
    
    // Performance state
    bool m_boostMode;
    int m_maxFileSize;
    bool m_streamingEnabled;
    
    // Query state
    QString m_queryText;
    QString m_queryResult;
    QString m_queryError;
    QString m_queryType;
    
    // History state
    QStringList m_historyEntries;
    
    // Async operations
    QFutureWatcher<QString> *m_fileWatcher;
    QFutureWatcher<QString> *m_queryWatcher;
    QTimer *m_statusTimer;
};

} // namespace treon
