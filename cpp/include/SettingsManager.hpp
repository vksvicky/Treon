#pragma once

#include <QObject>
#include <QString>
#include <QStringList>
#include <QVariant>
#include <QSettings>
#include <QDir>
#include <QStandardPaths>

namespace treon {

class SettingsManager : public QObject
{
    Q_OBJECT
    
    // Settings properties
    Q_PROPERTY(QString language READ language WRITE setLanguage NOTIFY languageChanged)
    Q_PROPERTY(QString theme READ theme WRITE setTheme NOTIFY themeChanged)
    Q_PROPERTY(QString fontFamily READ fontFamily WRITE setFontFamily NOTIFY fontFamilyChanged)
    Q_PROPERTY(int fontSize READ fontSize WRITE setFontSize NOTIFY fontSizeChanged)
    Q_PROPERTY(bool wordWrap READ wordWrap WRITE setWordWrap NOTIFY wordWrapChanged)
    Q_PROPERTY(bool showLineNumbers READ showLineNumbers WRITE setShowLineNumbers NOTIFY showLineNumbersChanged)
    Q_PROPERTY(bool autoSave READ autoSave WRITE setAutoSave NOTIFY autoSaveChanged)
    Q_PROPERTY(int autoSaveInterval READ autoSaveInterval WRITE setAutoSaveInterval NOTIFY autoSaveIntervalChanged)
    Q_PROPERTY(bool checkForUpdates READ checkForUpdates WRITE setCheckForUpdates NOTIFY checkForUpdatesChanged)
    Q_PROPERTY(QStringList recentFiles READ recentFiles WRITE setRecentFiles NOTIFY recentFilesChanged)
    Q_PROPERTY(int maxRecentFiles READ maxRecentFiles WRITE setMaxRecentFiles NOTIFY maxRecentFilesChanged)
    Q_PROPERTY(QString lastDirectory READ lastDirectory WRITE setLastDirectory NOTIFY lastDirectoryChanged)
    Q_PROPERTY(bool rememberWindowGeometry READ rememberWindowGeometry WRITE setRememberWindowGeometry NOTIFY rememberWindowGeometryChanged)
    Q_PROPERTY(QByteArray windowGeometry READ windowGeometry WRITE setWindowGeometry NOTIFY windowGeometryChanged)
    Q_PROPERTY(QByteArray windowState READ windowState WRITE setWindowState NOTIFY windowStateChanged)
    // JSON viewer preferences
    // null (QVariant::Invalid) means unlimited depth
    Q_PROPERTY(QVariant jsonMaxDepth READ jsonMaxDepth WRITE setJsonMaxDepth NOTIFY jsonMaxDepthChanged)

public:
    explicit SettingsManager(QObject *parent = nullptr);
    ~SettingsManager();

    // Getters
    QString language() const;
    QString theme() const;
    QString fontFamily() const;
    int fontSize() const;
    bool wordWrap() const;
    bool showLineNumbers() const;
    bool autoSave() const;
    int autoSaveInterval() const;
    bool checkForUpdates() const;
    QStringList recentFiles() const;
    int maxRecentFiles() const;
    QString lastDirectory() const;
    bool rememberWindowGeometry() const;
    QByteArray windowGeometry() const;
    QByteArray windowState() const;
    QVariant jsonMaxDepth() const; // null => unlimited

    // Setters
    void setLanguage(const QString &language);
    void setTheme(const QString &theme);
    void setFontFamily(const QString &fontFamily);
    void setFontSize(int fontSize);
    void setWordWrap(bool wordWrap);
    void setShowLineNumbers(bool showLineNumbers);
    void setAutoSave(bool autoSave);
    void setAutoSaveInterval(int interval);
    void setCheckForUpdates(bool checkForUpdates);
    void setRecentFiles(const QStringList &files);
    void setMaxRecentFiles(int maxFiles);
    void setLastDirectory(const QString &directory);
    void setRememberWindowGeometry(bool remember);
    void setWindowGeometry(const QByteArray &geometry);
    void setWindowState(const QByteArray &state);
    void setJsonMaxDepth(const QVariant &depth); // set invalid QVariant for unlimited

    // Utility methods
    void addRecentFile(const QString &filePath);
    void clearRecentFiles();
    void resetToDefaults();
    void exportSettings(const QString &filePath);
    void importSettings(const QString &filePath);
    
    // Available options
    QStringList availableLanguages() const;
    QStringList availableThemes() const;
    QStringList availableFontFamilies() const;

public slots:
    void loadSettings();
    void saveSettings();
    void resetSettings();

signals:
    void languageChanged();
    void themeChanged();
    void fontFamilyChanged();
    void fontSizeChanged();
    void wordWrapChanged();
    void showLineNumbersChanged();
    void autoSaveChanged();
    void autoSaveIntervalChanged();
    void checkForUpdatesChanged();
    void recentFilesChanged();
    void maxRecentFilesChanged();
    void lastDirectoryChanged();
    void rememberWindowGeometryChanged();
    void windowGeometryChanged();
    void windowStateChanged();
    void jsonMaxDepthChanged();
    void settingsLoaded();
    void settingsSaved();
    void settingsReset();

private:
    void initializeDefaults();
    void setupSettings();
    QString getSettingsFilePath() const;
    QVariant getValue(const QString &key, const QVariant &defaultValue = QVariant()) const;
    void setValue(const QString &key, const QVariant &value);
    
    QSettings *m_settings;
    
    // Default values
    static const QString DEFAULT_LANGUAGE;
    static const QString DEFAULT_THEME;
    static const QString DEFAULT_FONT_FAMILY;
    static const int DEFAULT_FONT_SIZE;
    static const bool DEFAULT_WORD_WRAP;
    static const bool DEFAULT_SHOW_LINE_NUMBERS;
    static const bool DEFAULT_AUTO_SAVE;
    static const int DEFAULT_AUTO_SAVE_INTERVAL;
    static const bool DEFAULT_CHECK_FOR_UPDATES;
    static const int DEFAULT_MAX_RECENT_FILES;
    static const bool DEFAULT_REMEMBER_WINDOW_GEOMETRY;
};

} // namespace treon
