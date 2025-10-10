#include "treon/FileManager.h"
#include "treon/JSONParser.h"
#include "treon/Constants.h"

#include <QFileDialog>
#include <QFile>
#include <QFileInfo>
#include <QTextStream>
#include <QStandardPaths>
#include <QJsonDocument>
#include <QJsonParseError>
#include <QDebug>
#include <QDateTime>

using namespace treon;

FileManager& FileManager::instance() {
    static FileManager instance;
    return instance;
}

FileManager::FileManager(QObject* parent)
    : QObject(parent)
    , m_settings(new QSettings(this))
    , m_errorHandler(new ErrorHandler(this))
    , m_directoryManager(&DirectoryManager::instance())
{
    qDebug() << "Initializing FileManager";
    loadRecentFiles();
}

void FileManager::openFile() {
    setLoading(true);
    setErrorMessage("");
    
    const QUrl lastDir = m_directoryManager->getLastOpenedDirectory();
    const QString fileName = QFileDialog::getOpenFileName(
        nullptr,
        "Open JSON File",
        lastDir.toLocalFile(),
        "JSON files (*.json);;All files (*.*)"
    );
    
    if (!fileName.isEmpty()) {
        const QUrl fileUrl = QUrl::fromLocalFile(fileName);
        openFile(fileUrl);
    } else {
        setLoading(false);
    }
}

void FileManager::openFile(const QUrl& url) {
    setLoading(true);
    setErrorMessage("");
    
    try {
        FileInfo* fileInfo = validateAndLoadFile(url);
        if (fileInfo) {
            m_directoryManager->saveLastOpenedDirectory(url);
            addToRecentFiles(fileInfo);
            emit fileOpened(fileInfo);
        }
    } catch (const TreonException& e) {
        m_errorHandler->handleError(e);
        setErrorMessage(e.message());
    }
    
    setLoading(false);
}

void FileManager::createNewFile() {
    const QString tempPath = QStandardPaths::writableLocation(QStandardPaths::TempLocation);
    const QString fileName = QString("%1/Untitled.json").arg(tempPath);
    const QUrl fileUrl = QUrl::fromLocalFile(fileName);
    
    const QString initialContent = "{\n  \"example\": \"This is a new JSON file\"\n}";
    
    QFile file(fileName);
    if (file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        QTextStream out(&file);
        out << initialContent;
        file.close();
        
        FileInfo* fileInfo = new FileInfo(
            fileUrl,
            "Untitled.json",
            initialContent.size(),
            QDateTime::currentDateTime(),
            true,
            QString(),
            initialContent,
            this
        );
        
        emit fileCreated(fileInfo);
    } else {
        m_errorHandler->handleError(ErrorType::LoadingFailed, "Failed to create new file");
    }
}

void FileManager::saveFile(const QUrl& url, const QString& content) {
    QFile file(url.toLocalFile());
    if (file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        QTextStream out(&file);
        out << content;
        file.close();
        emit fileSaved(url);
    } else {
        m_errorHandler->handleError(ErrorType::PermissionDenied, "Failed to save file");
    }
}

void FileManager::removeRecentFile(RecentFile* recentFile) {
    if (recentFile) {
        m_recentFiles.removeAll(recentFile);
        recentFile->deleteLater();
        saveRecentFiles();
        emit recentFilesChanged();
    }
}

void FileManager::clearRecentFiles() {
    qDeleteAll(m_recentFiles);
    m_recentFiles.clear();
    saveRecentFiles();
    emit recentFilesChanged();
}

void FileManager::clearError() {
    setErrorMessage("");
}

void FileManager::setLoading(bool loading) {
    if (m_isLoading != loading) {
        m_isLoading = loading;
        emit isLoadingChanged();
    }
}

void FileManager::setErrorMessage(const QString& message) {
    if (m_errorMessage != message) {
        m_errorMessage = message;
        emit errorMessageChanged();
    }
}

void FileManager::addToRecentFiles(FileInfo* fileInfo) {
    if (!fileInfo || !fileInfo->url().isLocalFile() || !fileInfo->isValidJSON()) {
        return;
    }
    
    // Check if file is already in recent files
    for (QObject* obj : m_recentFiles) {
        RecentFile* recentFile = qobject_cast<RecentFile*>(obj);
        if (recentFile && recentFile->url() == fileInfo->url()) {
            // Update the last opened time
            recentFile->setProperty("lastOpened", QDateTime::currentDateTime());
            saveRecentFiles();
            return;
        }
    }
    
    // Add new recent file
    RecentFile* recentFile = new RecentFile(
        fileInfo->url(),
        fileInfo->name(),
        QDateTime::currentDateTime(),
        fileInfo->size(),
        fileInfo->isValidJSON(),
        this
    );
    
    m_recentFiles.prepend(recentFile);
    
    // Limit to max recent files
    if (m_recentFiles.size() > FileConstants::maxRecentFiles) {
        QObject* oldFile = m_recentFiles.takeLast();
        oldFile->deleteLater();
    }
    
    saveRecentFiles();
    emit recentFilesChanged();
}

void FileManager::loadRecentFiles() {
    const QByteArray data = m_settings->value(UserDefaultsKeys::recentFiles).toByteArray();
    if (!data.isEmpty()) {
        QJsonDocument doc = QJsonDocument::fromJson(data);
        if (doc.isArray()) {
            const QJsonArray array = doc.array();
            for (const QJsonValue& value : array) {
                if (value.isObject()) {
                    const QJsonObject obj = value.toObject();
                    const QUrl url = QUrl::fromLocalFile(obj["url"].toString());
                    const QString name = obj["name"].toString();
                    const QDateTime lastOpened = QDateTime::fromString(obj["lastOpened"].toString(), Qt::ISODate);
                    const qint64 size = obj["size"].toVariant().toLongLong();
                    const bool isValidJSON = obj["isValidJSON"].toBool();
                    
                    RecentFile* recentFile = new RecentFile(url, name, lastOpened, size, isValidJSON, this);
                    m_recentFiles.append(recentFile);
                }
            }
        }
    }
}

void FileManager::saveRecentFiles() {
    QJsonArray array;
    for (QObject* obj : m_recentFiles) {
        RecentFile* recentFile = qobject_cast<RecentFile*>(obj);
        if (recentFile) {
            QJsonObject obj;
            obj["url"] = recentFile->url().toLocalFile();
            obj["name"] = recentFile->name();
            obj["lastOpened"] = recentFile->lastOpened().toString(Qt::ISODate);
            obj["size"] = recentFile->size();
            obj["isValidJSON"] = recentFile->isValidJSON();
            array.append(obj);
        }
    }
    
    QJsonDocument doc(array);
    m_settings->setValue(UserDefaultsKeys::recentFiles, doc.toJson());
}

FileInfo* FileManager::validateAndLoadFile(const QUrl& url) {
    if (!url.isLocalFile()) {
        throw TreonException(ErrorType::InvalidURL, "Only local files are supported");
    }
    
    const QString filePath = url.toLocalFile();
    QFileInfo fileInfo(filePath);
    
    if (!fileInfo.exists()) {
        throw TreonException(ErrorType::FileNotFound, "File does not exist");
    }
    
    if (!fileInfo.isFile()) {
        throw TreonException(ErrorType::UnsupportedFileType, "Path is not a file");
    }
    
    const qint64 fileSize = fileInfo.size();
    if (fileSize > FileConstants::maxFileSize) {
        throw TreonException(ErrorType::FileTooLarge, 
            QString("File size (%1 bytes) exceeds maximum limit (%2 bytes)")
            .arg(fileSize).arg(FileConstants::maxFileSize));
    }
    
    const QString content = readFileContent(url);
    const bool isValidJSON = validateJSONContent(content);
    
    return new FileInfo(
        url,
        fileInfo.fileName(),
        fileSize,
        fileInfo.lastModified(),
        isValidJSON,
        isValidJSON ? QString() : "Invalid JSON format",
        content,
        this
    );
}

QString FileManager::readFileContent(const QUrl& url) {
    QFile file(url.toLocalFile());
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        throw TreonException(ErrorType::PermissionDenied, "Cannot read file");
    }
    
    QTextStream in(&file);
    const QString content = in.readAll();
    file.close();
    
    if (content.isEmpty()) {
        throw TreonException(ErrorType::LoadingFailed, "File is empty");
    }
    
    return content;
}

bool FileManager::validateJSONContent(const QString& content) {
    const std::string jsonStd = content.toStdString();
    return JSONParser::validate(jsonStd);
}
