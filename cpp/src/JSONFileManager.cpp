#include "JSONFileManager.hpp"
#include <QSettings>
#include <QDebug>
#include <QDateTime>
#include <QFile>
#include <QTextStream>
#include <QJsonParseError>

namespace treon {

JSONFileManager::JSONFileManager(QObject *parent)
    : QObject(parent)
    , m_hasUnsavedChanges(false)
    , m_isValid(false)
{
    loadSettings();
}

JSONFileManager::~JSONFileManager()
{
    saveSettings();
}

bool JSONFileManager::openFile(const QString &filePath)
{
    if (!fileExists(filePath)) {
        emit errorOccurred(tr("File does not exist: %1").arg(filePath));
        return false;
    }
    
    if (!isJSONFile(filePath)) {
        emit errorOccurred(tr("File is not a valid JSON file: %1").arg(filePath));
        return false;
    }
    
    QFile file(filePath);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        emit errorOccurred(tr("Cannot open file for reading: %1").arg(filePath));
        return false;
    }
    
    QTextStream in(&file);
    in.setEncoding(QStringConverter::Utf8);
    QString jsonString = in.readAll();
    file.close();
    
    // Parse JSON
    QJsonParseError error;
    QJsonDocument document = QJsonDocument::fromJson(jsonString.toUtf8(), &error);
    
    if (error.error != QJsonParseError::NoError) {
        m_isValid = false;
        m_errorMessage = tr("JSON Parse Error: %1").arg(error.errorString());
        emit errorOccurred(m_errorMessage);
        return false;
    }
    
    // Successfully loaded
    m_currentFilePath = filePath;
    m_currentDocument = document;
    m_currentJSONString = jsonString;
    m_isValid = true;
    m_errorMessage.clear();
    m_hasUnsavedChanges = false;
    
    addToRecentFiles(filePath);
    emit fileOpened(filePath);
    emit unsavedChangesChanged(false);
    
    return true;
}

bool JSONFileManager::saveFile(const QString &filePath, const QJsonDocument &document)
{
    QFile file(filePath);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        emit errorOccurred(tr("Cannot open file for writing: %1").arg(filePath));
        return false;
    }
    
    QTextStream out(&file);
    out.setEncoding(QStringConverter::Utf8);
    out << document.toJson(QJsonDocument::Indented);
    file.close();
    
    m_currentFilePath = filePath;
    m_currentDocument = document;
    m_currentJSONString = document.toJson(QJsonDocument::Indented);
    m_hasUnsavedChanges = false;
    
    addToRecentFiles(filePath);
    emit fileSaved(filePath);
    emit unsavedChangesChanged(false);
    
    return true;
}

bool JSONFileManager::saveFile(const QString &filePath, const QString &jsonString)
{
    // Validate JSON before saving
    QJsonParseError error;
    QJsonDocument document = QJsonDocument::fromJson(jsonString.toUtf8(), &error);
    
    if (error.error != QJsonParseError::NoError) {
        emit errorOccurred(tr("Invalid JSON: %1").arg(error.errorString()));
        return false;
    }
    
    return saveFile(filePath, document);
}

void JSONFileManager::closeFile()
{
    m_currentFilePath.clear();
    m_currentDocument = QJsonDocument();
    m_currentJSONString.clear();
    m_hasUnsavedChanges = false;
    m_isValid = false;
    m_errorMessage.clear();
    
    emit fileClosed();
    emit unsavedChangesChanged(false);
}

QString JSONFileManager::getCurrentFilePath() const
{
    return m_currentFilePath;
}

QString JSONFileManager::getCurrentFileName() const
{
    if (m_currentFilePath.isEmpty())
        return QString();
    
    return QFileInfo(m_currentFilePath).fileName();
}

bool JSONFileManager::hasUnsavedChanges() const
{
    return m_hasUnsavedChanges;
}

void JSONFileManager::setUnsavedChanges(bool hasChanges)
{
    if (m_hasUnsavedChanges != hasChanges) {
        m_hasUnsavedChanges = hasChanges;
        emit unsavedChangesChanged(hasChanges);
    }
}

QJsonDocument JSONFileManager::getCurrentDocument() const
{
    return m_currentDocument;
}

QString JSONFileManager::getCurrentJSONString() const
{
    return m_currentJSONString;
}

bool JSONFileManager::isValidJSON() const
{
    return m_isValid;
}

QString JSONFileManager::getErrorMessage() const
{
    return m_errorMessage;
}

QStringList JSONFileManager::getRecentFiles() const
{
    return m_recentFiles;
}

void JSONFileManager::addToRecentFiles(const QString &filePath)
{
    if (filePath.isEmpty())
        return;
    
    // Remove if already exists
    m_recentFiles.removeAll(filePath);
    
    // Add to beginning
    m_recentFiles.prepend(filePath);
    
    // Ensure limit
    ensureRecentFilesLimit();
    
    emit recentFilesChanged();
}

void JSONFileManager::clearRecentFiles()
{
    m_recentFiles.clear();
    emit recentFilesChanged();
}

bool JSONFileManager::isJSONFile(const QString &filePath) const
{
    QStringList extensions = getSupportedExtensions();
    QFileInfo fileInfo(filePath);
    QString suffix = fileInfo.suffix().toLower();
    
    return extensions.contains(suffix);
}

QStringList JSONFileManager::getSupportedExtensions() const
{
    return QStringList() << "json" << "jsonc" << "jsonl";
}

QString JSONFileManager::getFileSizeString(const QString &filePath) const
{
    QFileInfo fileInfo(filePath);
    if (!fileInfo.exists())
        return QString();
    
    qint64 size = fileInfo.size();
    if (size < 1024) {
        return tr("%1 B").arg(size);
    } else if (size < 1024 * 1024) {
        return tr("%1 KB").arg(size / 1024);
    } else if (size < 1024 * 1024 * 1024) {
        return tr("%1 MB").arg(size / (1024 * 1024));
    } else {
        return tr("%1 GB").arg(size / (1024 * 1024 * 1024));
    }
}

QString JSONFileManager::getLastModifiedString(const QString &filePath) const
{
    QFileInfo fileInfo(filePath);
    if (!fileInfo.exists())
        return QString();
    
    return fileInfo.lastModified().toString();
}

bool JSONFileManager::fileExists(const QString &filePath) const
{
    return QFileInfo(filePath).exists();
}

void JSONFileManager::loadSettings()
{
    QSettings settings(getSettingsFilePath(), QSettings::IniFormat);
    m_recentFiles = settings.value("recentFiles", QStringList()).toStringList();
    
    // Filter out non-existent files
    m_recentFiles.erase(
        std::remove_if(m_recentFiles.begin(), m_recentFiles.end(),
                      [this](const QString &filePath) {
                          return !fileExists(filePath);
                      }),
        m_recentFiles.end()
    );
    
    ensureRecentFilesLimit();
}

void JSONFileManager::saveSettings()
{
    QSettings settings(getSettingsFilePath(), QSettings::IniFormat);
    settings.setValue("recentFiles", m_recentFiles);
}

QString JSONFileManager::getSettingsFilePath() const
{
    QString configDir = QStandardPaths::writableLocation(QStandardPaths::AppConfigLocation);
    QDir().mkpath(configDir);
    return configDir + "/treon_settings.ini";
}

void JSONFileManager::ensureRecentFilesLimit()
{
    while (m_recentFiles.size() > MAX_RECENT_FILES) {
        m_recentFiles.removeLast();
    }
}

} // namespace treon
