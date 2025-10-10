#include "treon/DirectoryManager.h"
#include "treon/Constants.h"

#include <QStandardPaths>
#include <QDir>
#include <QDebug>

using namespace treon;

DirectoryManager& DirectoryManager::instance() {
    static DirectoryManager instance;
    return instance;
}

DirectoryManager::DirectoryManager(QObject* parent)
    : QObject(parent)
    , m_settings(new QSettings(this))
{
    qDebug() << "Initializing DirectoryManager";
}

QUrl DirectoryManager::getLastOpenedDirectory() const {
    const QString lastDir = m_settings->value(UserDefaultsKeys::lastOpenedDirectory).toString();
    
    if (!lastDir.isEmpty()) {
        QDir dir(lastDir);
        if (dir.exists()) {
            qDebug() << "Using last opened directory:" << lastDir;
            return QUrl::fromLocalFile(lastDir);
        } else {
            qDebug() << "Last opened directory no longer exists, falling back to Documents";
            m_settings->remove(UserDefaultsKeys::lastOpenedDirectory);
        }
    }
    
    // Fall back to Documents directory
    const QString documentsPath = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
    const QUrl documentsUrl = QUrl::fromLocalFile(documentsPath);
    qDebug() << "Using fallback directory:" << documentsPath;
    return documentsUrl;
}

void DirectoryManager::saveLastOpenedDirectory(const QUrl& fileUrl) {
    const QUrl directoryUrl = QUrl::fromLocalFile(QFileInfo(fileUrl.toLocalFile()).absolutePath());
    const QString directoryPath = directoryUrl.toLocalFile();
    
    m_settings->setValue(UserDefaultsKeys::lastOpenedDirectory, directoryPath);
    qDebug() << "Saved last opened directory:" << directoryPath;
}

void DirectoryManager::clearLastOpenedDirectory() {
    m_settings->remove(UserDefaultsKeys::lastOpenedDirectory);
    qDebug() << "Cleared last opened directory";
}
