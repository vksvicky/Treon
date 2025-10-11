#include "treon/SettingsManager.hpp"
#include <QDebug>
#include <QApplication>
#include <QFontDatabase>
#include <QJsonDocument>
#include <QJsonObject>
#include <QFile>
#include <QDir>

namespace treon {

// Default values
const QString SettingsManager::DEFAULT_LANGUAGE = "en";
const QString SettingsManager::DEFAULT_THEME = "light";
const QString SettingsManager::DEFAULT_FONT_FAMILY = "Monaco";
const int SettingsManager::DEFAULT_FONT_SIZE = 12;
const bool SettingsManager::DEFAULT_WORD_WRAP = false;
const bool SettingsManager::DEFAULT_SHOW_LINE_NUMBERS = true;
const bool SettingsManager::DEFAULT_AUTO_SAVE = false;
const int SettingsManager::DEFAULT_AUTO_SAVE_INTERVAL = 300; // 5 minutes
const bool SettingsManager::DEFAULT_CHECK_FOR_UPDATES = true;
const int SettingsManager::DEFAULT_MAX_RECENT_FILES = 10;
const bool SettingsManager::DEFAULT_REMEMBER_WINDOW_GEOMETRY = true;

SettingsManager::SettingsManager(QObject *parent)
    : QObject(parent)
    , m_settings(nullptr)
{
    setupSettings();
    initializeDefaults();
    loadSettings();
}

SettingsManager::~SettingsManager()
{
    saveSettings();
    delete m_settings;
}

void SettingsManager::setupSettings()
{
    QString settingsPath = getSettingsFilePath();
    m_settings = new QSettings(settingsPath, QSettings::IniFormat, this);
}

QString SettingsManager::getSettingsFilePath() const
{
    QString appDataPath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir().mkpath(appDataPath);
    return QDir(appDataPath).filePath("treon.ini");
}

void SettingsManager::initializeDefaults()
{
    // Set default values if they don't exist
    if (!m_settings->contains("language")) {
        m_settings->setValue("language", DEFAULT_LANGUAGE);
    }
    if (!m_settings->contains("theme")) {
        m_settings->setValue("theme", DEFAULT_THEME);
    }
    if (!m_settings->contains("fontFamily")) {
        m_settings->setValue("fontFamily", DEFAULT_FONT_FAMILY);
    }
    if (!m_settings->contains("fontSize")) {
        m_settings->setValue("fontSize", DEFAULT_FONT_SIZE);
    }
    if (!m_settings->contains("wordWrap")) {
        m_settings->setValue("wordWrap", DEFAULT_WORD_WRAP);
    }
    if (!m_settings->contains("showLineNumbers")) {
        m_settings->setValue("showLineNumbers", DEFAULT_SHOW_LINE_NUMBERS);
    }
    if (!m_settings->contains("autoSave")) {
        m_settings->setValue("autoSave", DEFAULT_AUTO_SAVE);
    }
    if (!m_settings->contains("autoSaveInterval")) {
        m_settings->setValue("autoSaveInterval", DEFAULT_AUTO_SAVE_INTERVAL);
    }
    if (!m_settings->contains("checkForUpdates")) {
        m_settings->setValue("checkForUpdates", DEFAULT_CHECK_FOR_UPDATES);
    }
    if (!m_settings->contains("maxRecentFiles")) {
        m_settings->setValue("maxRecentFiles", DEFAULT_MAX_RECENT_FILES);
    }
    if (!m_settings->contains("rememberWindowGeometry")) {
        m_settings->setValue("rememberWindowGeometry", DEFAULT_REMEMBER_WINDOW_GEOMETRY);
    }
}

// Getters
QString SettingsManager::language() const
{
    return m_settings->value("language", DEFAULT_LANGUAGE).toString();
}

QString SettingsManager::theme() const
{
    return m_settings->value("theme", DEFAULT_THEME).toString();
}

QString SettingsManager::fontFamily() const
{
    return m_settings->value("fontFamily", DEFAULT_FONT_FAMILY).toString();
}

int SettingsManager::fontSize() const
{
    return m_settings->value("fontSize", DEFAULT_FONT_SIZE).toInt();
}

bool SettingsManager::wordWrap() const
{
    return m_settings->value("wordWrap", DEFAULT_WORD_WRAP).toBool();
}

bool SettingsManager::showLineNumbers() const
{
    return m_settings->value("showLineNumbers", DEFAULT_SHOW_LINE_NUMBERS).toBool();
}

bool SettingsManager::autoSave() const
{
    return m_settings->value("autoSave", DEFAULT_AUTO_SAVE).toBool();
}

int SettingsManager::autoSaveInterval() const
{
    return m_settings->value("autoSaveInterval", DEFAULT_AUTO_SAVE_INTERVAL).toInt();
}

bool SettingsManager::checkForUpdates() const
{
    return m_settings->value("checkForUpdates", DEFAULT_CHECK_FOR_UPDATES).toBool();
}

QStringList SettingsManager::recentFiles() const
{
    return m_settings->value("recentFiles", QStringList()).toStringList();
}

int SettingsManager::maxRecentFiles() const
{
    return m_settings->value("maxRecentFiles", DEFAULT_MAX_RECENT_FILES).toInt();
}

QString SettingsManager::lastDirectory() const
{
    return m_settings->value("lastDirectory", QDir::homePath()).toString();
}

bool SettingsManager::rememberWindowGeometry() const
{
    return m_settings->value("rememberWindowGeometry", DEFAULT_REMEMBER_WINDOW_GEOMETRY).toBool();
}

QByteArray SettingsManager::windowGeometry() const
{
    return m_settings->value("windowGeometry", QByteArray()).toByteArray();
}

QByteArray SettingsManager::windowState() const
{
    return m_settings->value("windowState", QByteArray()).toByteArray();
}

// Setters
void SettingsManager::setLanguage(const QString &language)
{
    if (this->language() != language) {
        m_settings->setValue("language", language);
        emit languageChanged();
    }
}

void SettingsManager::setTheme(const QString &theme)
{
    if (this->theme() != theme) {
        m_settings->setValue("theme", theme);
        emit themeChanged();
    }
}

void SettingsManager::setFontFamily(const QString &fontFamily)
{
    if (this->fontFamily() != fontFamily) {
        m_settings->setValue("fontFamily", fontFamily);
        emit fontFamilyChanged();
    }
}

void SettingsManager::setFontSize(int fontSize)
{
    if (this->fontSize() != fontSize) {
        m_settings->setValue("fontSize", fontSize);
        emit fontSizeChanged();
    }
}

void SettingsManager::setWordWrap(bool wordWrap)
{
    if (this->wordWrap() != wordWrap) {
        m_settings->setValue("wordWrap", wordWrap);
        emit wordWrapChanged();
    }
}

void SettingsManager::setShowLineNumbers(bool showLineNumbers)
{
    if (this->showLineNumbers() != showLineNumbers) {
        m_settings->setValue("showLineNumbers", showLineNumbers);
        emit showLineNumbersChanged();
    }
}

void SettingsManager::setAutoSave(bool autoSave)
{
    if (this->autoSave() != autoSave) {
        m_settings->setValue("autoSave", autoSave);
        emit autoSaveChanged();
    }
}

void SettingsManager::setAutoSaveInterval(int interval)
{
    if (this->autoSaveInterval() != interval) {
        m_settings->setValue("autoSaveInterval", interval);
        emit autoSaveIntervalChanged();
    }
}

void SettingsManager::setCheckForUpdates(bool checkForUpdates)
{
    if (this->checkForUpdates() != checkForUpdates) {
        m_settings->setValue("checkForUpdates", checkForUpdates);
        emit checkForUpdatesChanged();
    }
}

void SettingsManager::setRecentFiles(const QStringList &files)
{
    if (this->recentFiles() != files) {
        m_settings->setValue("recentFiles", files);
        emit recentFilesChanged();
    }
}

void SettingsManager::setMaxRecentFiles(int maxFiles)
{
    if (this->maxRecentFiles() != maxFiles) {
        m_settings->setValue("maxRecentFiles", maxFiles);
        emit maxRecentFilesChanged();
    }
}

void SettingsManager::setLastDirectory(const QString &directory)
{
    if (this->lastDirectory() != directory) {
        m_settings->setValue("lastDirectory", directory);
        emit lastDirectoryChanged();
    }
}

void SettingsManager::setRememberWindowGeometry(bool remember)
{
    if (this->rememberWindowGeometry() != remember) {
        m_settings->setValue("rememberWindowGeometry", remember);
        emit rememberWindowGeometryChanged();
    }
}

void SettingsManager::setWindowGeometry(const QByteArray &geometry)
{
    if (this->windowGeometry() != geometry) {
        m_settings->setValue("windowGeometry", geometry);
        emit windowGeometryChanged();
    }
}

void SettingsManager::setWindowState(const QByteArray &state)
{
    if (this->windowState() != state) {
        m_settings->setValue("windowState", state);
        emit windowStateChanged();
    }
}

// Utility methods
void SettingsManager::addRecentFile(const QString &filePath)
{
    QStringList files = recentFiles();
    files.removeAll(filePath); // Remove if already exists
    files.prepend(filePath);   // Add to beginning
    
    // Limit to maxRecentFiles
    while (files.size() > maxRecentFiles()) {
        files.removeLast();
    }
    
    setRecentFiles(files);
}

void SettingsManager::clearRecentFiles()
{
    setRecentFiles(QStringList());
}

void SettingsManager::resetToDefaults()
{
    m_settings->clear();
    initializeDefaults();
    emit settingsReset();
}

void SettingsManager::exportSettings(const QString &filePath)
{
    QJsonObject settingsObject;
    
    // Export all settings
    QStringList keys = m_settings->allKeys();
    for (const QString &key : keys) {
        settingsObject[key] = QJsonValue::fromVariant(m_settings->value(key));
    }
    
    QJsonDocument doc(settingsObject);
    QFile file(filePath);
    if (file.open(QIODevice::WriteOnly)) {
        file.write(doc.toJson());
        file.close();
    }
}

void SettingsManager::importSettings(const QString &filePath)
{
    QFile file(filePath);
    if (!file.open(QIODevice::ReadOnly)) {
        return;
    }
    
    QJsonDocument doc = QJsonDocument::fromJson(file.readAll());
    QJsonObject settingsObject = doc.object();
    
    // Import all settings
    for (auto it = settingsObject.begin(); it != settingsObject.end(); ++it) {
        m_settings->setValue(it.key(), it.value().toVariant());
    }
    
    file.close();
    emit settingsLoaded();
}

QStringList SettingsManager::availableLanguages() const
{
    return QStringList() << "en" << "es" << "fr" << "de" << "it" << "pt" << "ru" << "ja" << "ko" << "zh";
}

QStringList SettingsManager::availableThemes() const
{
    return QStringList() << "light" << "dark" << "auto";
}

QStringList SettingsManager::availableFontFamilies() const
{
    QStringList families = QFontDatabase::families();
    families.sort();
    return families;
}

void SettingsManager::loadSettings()
{
    // Settings are automatically loaded by QSettings
    emit settingsLoaded();
}

void SettingsManager::saveSettings()
{
    m_settings->sync();
    emit settingsSaved();
}

void SettingsManager::resetSettings()
{
    resetToDefaults();
}

} // namespace treon
