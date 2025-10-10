#pragma once

#include <QObject>
#include <QUrl>
#include <QString>
#include <QSettings>

namespace treon {

class DirectoryManager : public QObject {
    Q_OBJECT

public:
    static DirectoryManager& instance();
    
    QUrl getLastOpenedDirectory() const;
    void saveLastOpenedDirectory(const QUrl& fileUrl);
    void clearLastOpenedDirectory();

private:
    explicit DirectoryManager(QObject* parent = nullptr);
    ~DirectoryManager() override = default;
    
    // Disable copy constructor and assignment operator
    DirectoryManager(const DirectoryManager&) = delete;
    DirectoryManager& operator=(const DirectoryManager&) = delete;
    
    QSettings* m_settings;
};

} // namespace treon
