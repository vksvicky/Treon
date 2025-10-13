#ifndef JSON_FILE_MANAGER_HPP
#define JSON_FILE_MANAGER_HPP

#include <QObject>
#include <QString>
#include <QStringList>
#include <QJsonDocument>
#include <QJsonParseError>
#include <QFileInfo>
#include <QTextStream>
#include <QStandardPaths>
#include <QDir>

namespace treon {

class JSONFileManager : public QObject
{
    Q_OBJECT

public:
    explicit JSONFileManager(QObject *parent = nullptr);
    ~JSONFileManager();

    // File operations
    bool openFile(const QString &filePath);
    bool saveFile(const QString &filePath, const QJsonDocument &document);
    bool saveFile(const QString &filePath, const QString &jsonString);
    void closeFile();
    
    // File information
    QString getCurrentFilePath() const;
    QString getCurrentFileName() const;
    bool hasUnsavedChanges() const;
    void setUnsavedChanges(bool hasChanges);
    
    // JSON operations
    QJsonDocument getCurrentDocument() const;
    QString getCurrentJSONString() const;
    bool isValidJSON() const;
    QString getErrorMessage() const;
    
    // Recent files
    QStringList getRecentFiles() const;
    void addToRecentFiles(const QString &filePath);
    void clearRecentFiles();
    
    // File validation
    bool isJSONFile(const QString &filePath) const;
    QStringList getSupportedExtensions() const;
    
    // Utility
    QString getFileSizeString(const QString &filePath) const;
    QString getLastModifiedString(const QString &filePath) const;
    bool fileExists(const QString &filePath) const;

signals:
    void fileOpened(const QString &filePath);
    void fileSaved(const QString &filePath);
    void fileClosed();
    void errorOccurred(const QString &message);
    void unsavedChangesChanged(bool hasChanges);
    void recentFilesChanged();

private:
    void loadSettings();
    void saveSettings();
    QString getSettingsFilePath() const;
    void ensureRecentFilesLimit();
    
    QString m_currentFilePath;
    QJsonDocument m_currentDocument;
    QString m_currentJSONString;
    bool m_hasUnsavedChanges;
    bool m_isValid;
    QString m_errorMessage;
    QStringList m_recentFiles;
    static const int MAX_RECENT_FILES = 10;
};

} // namespace treon

#endif // JSON_FILE_MANAGER_HPP
