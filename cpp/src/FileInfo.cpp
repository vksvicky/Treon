#include "treon/FileInfo.hpp"

#include <QFileInfo>
#include <QTextStream>
#include <QLocale>

using namespace treon;

// MARK: - FileInfo Implementation

FileInfo::FileInfo(QObject* parent)
    : QObject(parent)
    , m_size(0)
    , m_isValidJSON(false)
{
}

FileInfo::FileInfo(const QUrl& url, const QString& name, qint64 size,
                   const QDateTime& modifiedDate, bool isValidJSON,
                   const QString& errorMessage, const QString& content, QObject* parent)
    : QObject(parent)
    , m_url(url)
    , m_name(name)
    , m_size(size)
    , m_modifiedDate(modifiedDate)
    , m_isValidJSON(isValidJSON)
    , m_errorMessage(errorMessage)
    , m_content(content)
{
}

QString FileInfo::formattedSize() const {
    if (m_size < 1024) {
        return QString::number(m_size) + " B";
    } else if (m_size < 1024 * 1024) {
        return QString::number(m_size / 1024.0, 'f', 1) + " KB";
    } else if (m_size < 1024 * 1024 * 1024) {
        return QString::number(m_size / (1024.0 * 1024.0), 'f', 1) + " MB";
    } else {
        return QString::number(m_size / (1024.0 * 1024.0 * 1024.0), 'f', 1) + " GB";
    }
}

QString FileInfo::formattedModifiedDate() const {
    return QLocale().toString(m_modifiedDate, QLocale::ShortFormat);
}

// MARK: - RecentFile Implementation

RecentFile::RecentFile(QObject* parent)
    : QObject(parent)
    , m_size(0)
    , m_isValidJSON(false)
{
}

RecentFile::RecentFile(const QUrl& url, const QString& name, const QDateTime& lastOpened,
                       qint64 size, bool isValidJSON, QObject* parent)
    : QObject(parent)
    , m_url(url)
    , m_name(name)
    , m_lastOpened(lastOpened)
    , m_size(size)
    , m_isValidJSON(isValidJSON)
{
}

QString RecentFile::formattedSize() const {
    if (m_size < 1024) {
        return QString::number(m_size) + " B";
    } else if (m_size < 1024 * 1024) {
        return QString::number(m_size / 1024.0, 'f', 1) + " KB";
    } else if (m_size < 1024 * 1024 * 1024) {
        return QString::number(m_size / (1024.0 * 1024.0), 'f', 1) + " MB";
    } else {
        return QString::number(m_size / (1024.0 * 1024.0 * 1024.0), 'f', 1) + " GB";
    }
}
