#pragma once

#include <QObject>
#include <QUrl>
#include <QString>
#include <QStringList>
#include <QList>
#include <QSettings>
#include <memory>

#include "treon/FileInfo.h"
#include "treon/ErrorHandler.h"
#include "treon/DirectoryManager.h"

namespace treon {

class FileManager : public QObject {
    Q_OBJECT
    Q_PROPERTY(QList<QObject*> recentFiles READ recentFiles NOTIFY recentFilesChanged)
    Q_PROPERTY(bool isLoading READ isLoading NOTIFY isLoadingChanged)
    Q_PROPERTY(QString errorMessage READ errorMessage NOTIFY errorMessageChanged)

public:
    static FileManager& instance();
    
    QList<QObject*> recentFiles() const { return m_recentFiles; }
    bool isLoading() const { return m_isLoading; }
    QString errorMessage() const { return m_errorMessage; }

public slots:
    void openFile();
    void openFile(const QUrl& url);
    void createNewFile();
    void saveFile(const QUrl& url, const QString& content);
    void removeRecentFile(RecentFile* recentFile);
    void clearRecentFiles();
    void clearError();

signals:
    void recentFilesChanged();
    void isLoadingChanged();
    void errorMessageChanged();
    void fileOpened(FileInfo* fileInfo);
    void fileCreated(FileInfo* fileInfo);
    void fileSaved(const QUrl& url);

private:
    explicit FileManager(QObject* parent = nullptr);
    ~FileManager() override = default;
    
    // Disable copy constructor and assignment operator
    FileManager(const FileManager&) = delete;
    FileManager& operator=(const FileManager&) = delete;
    
    void setLoading(bool loading);
    void setErrorMessage(const QString& message);
    void addToRecentFiles(FileInfo* fileInfo);
    void loadRecentFiles();
    void saveRecentFiles();
    
    FileInfo* validateAndLoadFile(const QUrl& url);
    QString readFileContent(const QUrl& url);
    bool validateJSONContent(const QString& content);
    QString formatFileSize(qint64 bytes);
    
    QList<QObject*> m_recentFiles;
    bool m_isLoading = false;
    QString m_errorMessage;
    QSettings* m_settings;
    ErrorHandler* m_errorHandler;
    DirectoryManager* m_directoryManager;
};

} // namespace treon
