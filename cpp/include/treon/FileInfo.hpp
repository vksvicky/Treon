#pragma once

#include <QObject>
#include <QUrl>
#include <QString>
#include <QDateTime>
#include <QMetaType>

namespace treon {

class FileInfo : public QObject {
    Q_OBJECT
    Q_PROPERTY(QUrl url READ url CONSTANT)
    Q_PROPERTY(QString name READ name CONSTANT)
    Q_PROPERTY(qint64 size READ size CONSTANT)
    Q_PROPERTY(QDateTime modifiedDate READ modifiedDate CONSTANT)
    Q_PROPERTY(bool isValidJSON READ isValidJSON CONSTANT)
    Q_PROPERTY(QString errorMessage READ errorMessage CONSTANT)
    Q_PROPERTY(QString content READ content CONSTANT)
    Q_PROPERTY(QString formattedSize READ formattedSize CONSTANT)
    Q_PROPERTY(QString formattedModifiedDate READ formattedModifiedDate CONSTANT)

public:
    explicit FileInfo(QObject* parent = nullptr);
    FileInfo(const QUrl& url, const QString& name, qint64 size, 
             const QDateTime& modifiedDate, bool isValidJSON, 
             const QString& errorMessage = QString(), 
             const QString& content = QString(), 
             QObject* parent = nullptr);
    
    QUrl url() const { return m_url; }
    QString name() const { return m_name; }
    qint64 size() const { return m_size; }
    QDateTime modifiedDate() const { return m_modifiedDate; }
    bool isValidJSON() const { return m_isValidJSON; }
    QString errorMessage() const { return m_errorMessage; }
    QString content() const { return m_content; }
    
    QString formattedSize() const;
    QString formattedModifiedDate() const;

private:
    QUrl m_url;
    QString m_name;
    qint64 m_size;
    QDateTime m_modifiedDate;
    bool m_isValidJSON;
    QString m_errorMessage;
    QString m_content;
};

// Recent File class
class RecentFile : public QObject {
    Q_OBJECT
    Q_PROPERTY(QUrl url READ url CONSTANT)
    Q_PROPERTY(QString name READ name CONSTANT)
    Q_PROPERTY(QDateTime lastOpened READ lastOpened CONSTANT)
    Q_PROPERTY(qint64 size READ size CONSTANT)
    Q_PROPERTY(bool isValidJSON READ isValidJSON CONSTANT)
    Q_PROPERTY(QString formattedSize READ formattedSize CONSTANT)

public:
    explicit RecentFile(QObject* parent = nullptr);
    RecentFile(const QUrl& url, const QString& name, const QDateTime& lastOpened,
               qint64 size, bool isValidJSON, QObject* parent = nullptr);
    
    QUrl url() const { return m_url; }
    QString name() const { return m_name; }
    QDateTime lastOpened() const { return m_lastOpened; }
    qint64 size() const { return m_size; }
    bool isValidJSON() const { return m_isValidJSON; }
    
    QString formattedSize() const;

private:
    QUrl m_url;
    QString m_name;
    QDateTime m_lastOpened;
    qint64 m_size;
    bool m_isValidJSON;
};

} // namespace treon

Q_DECLARE_METATYPE(treon::FileInfo*)
Q_DECLARE_METATYPE(treon::RecentFile*)
