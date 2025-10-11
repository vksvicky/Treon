#include "test_helpers.hpp"
#include <QJsonParseError>
#include <QDateTime>
#include <QTextStream>
#include <QDebug>
#include <random>

namespace treon {
namespace test {

QString TestHelpers::createTempDirectory(const QString &prefix)
{
    QString tempPath = QStandardPaths::writableLocation(QStandardPaths::TempLocation);
    QString dirPath = QString("%1/%2_%3")
        .arg(tempPath)
        .arg(prefix)
        .arg(QDateTime::currentMSecsSinceEpoch());
    
    QDir().mkpath(dirPath);
    return dirPath;
}

QString TestHelpers::createTempFile(const QString &content, const QString &suffix)
{
    QString tempPath = QStandardPaths::writableLocation(QStandardPaths::TempLocation);
    QString filePath = QString("%1/treon_test_%2%3")
        .arg(tempPath)
        .arg(QDateTime::currentMSecsSinceEpoch())
        .arg(suffix);
    
    QFile file(filePath);
    if (file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        QTextStream out(&file);
        out << content;
        file.close();
        return filePath;
    }
    
    return QString();
}

bool TestHelpers::removeTempDirectory(const QString &path)
{
    return QDir(path).removeRecursively();
}

QString TestHelpers::getTestDataPath()
{
    QString testDataPath = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation) + "/TreonTestData";
    QDir().mkpath(testDataPath);
    return testDataPath;
}

QJsonDocument TestHelpers::createValidJsonDocument()
{
    QJsonObject root;
    root["version"] = "1.0";
    root["test"] = true;
    root["timestamp"] = QDateTime::currentDateTime().toString(Qt::ISODate);
    
    QJsonArray items;
    for (int i = 0; i < 5; ++i) {
        QJsonObject item;
        item["id"] = i;
        item["name"] = QString("Item %1").arg(i);
        item["value"] = i * 10;
        items.append(item);
    }
    root["items"] = items;
    
    return QJsonDocument(root);
}

QJsonDocument TestHelpers::createInvalidJsonDocument()
{
    // Return a document with invalid JSON
    return QJsonDocument();
}

bool TestHelpers::isValidJson(const QString &jsonString)
{
    QJsonParseError error;
    QJsonDocument::fromJson(jsonString.toUtf8(), &error);
    return error.error == QJsonParseError::NoError;
}

QString TestHelpers::formatJsonSize(qint64 bytes)
{
    if (bytes < 1024) {
        return QString("%1 B").arg(bytes);
    } else if (bytes < 1024 * 1024) {
        return QString("%1 KB").arg(bytes / 1024);
    } else if (bytes < 1024 * 1024 * 1024) {
        return QString("%1 MB").arg(bytes / (1024 * 1024));
    } else {
        return QString("%1 GB").arg(bytes / (1024 * 1024 * 1024));
    }
}

double TestHelpers::calculateThroughput(qint64 sizeBytes, qint64 timeMs)
{
    if (timeMs == 0) return 0.0;
    
    double sizeMB = sizeBytes / (1024.0 * 1024.0);
    double timeSeconds = timeMs / 1000.0;
    
    return sizeMB / timeSeconds;
}

QString TestHelpers::formatTime(qint64 timeMs)
{
    if (timeMs < 1000) {
        return QString("%1 ms").arg(timeMs);
    } else if (timeMs < 60000) {
        return QString("%1 s").arg(timeMs / 1000.0, 0, 'f', 2);
    } else {
        int minutes = timeMs / 60000;
        int seconds = (timeMs % 60000) / 1000;
        return QString("%1m %2s").arg(minutes).arg(seconds);
    }
}

QString TestHelpers::formatThroughput(double throughput)
{
    return QString("%1 MB/s").arg(throughput, 0, 'f', 2);
}

QString TestHelpers::generateTestJsonData(qint64 targetSize)
{
    QJsonObject root;
    QJsonArray items;
    
    qint64 currentSize = 0;
    int itemCount = 0;
    
    // Generate base structure
    root["version"] = "1.0";
    root["generator"] = "TestHelpers";
    root["timestamp"] = QDateTime::currentDateTime().toString(Qt::ISODate);
    
    std::random_device rd;
    std::mt19937 gen(rd());
    std::uniform_int_distribution<> dis(1, 1000);
    
    while (currentSize < targetSize) {
        QJsonObject item;
        item["id"] = itemCount;
        item["name"] = QString("Test Item %1").arg(itemCount);
        item["value"] = dis(gen);
        item["description"] = QString("This is a test description for item %1").arg(itemCount);
        
        QJsonArray tags;
        for (int i = 0; i < 3; ++i) {
            tags.append(QString("tag%1").arg(i));
        }
        item["tags"] = tags;
        
        items.append(item);
        
        // Update root and calculate size
        root["items"] = items;
        QJsonDocument doc(root);
        currentSize = doc.toJson().size();
        itemCount++;
        
        // Prevent infinite loop
        if (itemCount > 100000) break;
    }
    
    return QJsonDocument(root).toJson();
}

QJsonObject TestHelpers::createTestJsonObject(int itemCount)
{
    QJsonObject obj;
    obj["count"] = itemCount;
    obj["timestamp"] = QDateTime::currentDateTime().toString(Qt::ISODate);
    
    QJsonArray items;
    for (int i = 0; i < itemCount; ++i) {
        QJsonObject item;
        item["id"] = i;
        item["name"] = QString("Item %1").arg(i);
        item["value"] = i * 10;
        items.append(item);
    }
    obj["items"] = items;
    
    return obj;
}

QJsonArray TestHelpers::createTestJsonArray(int itemCount)
{
    QJsonArray array;
    for (int i = 0; i < itemCount; ++i) {
        QJsonObject item;
        item["id"] = i;
        item["name"] = QString("Array Item %1").arg(i);
        item["value"] = i * 5;
        array.append(item);
    }
    return array;
}

bool TestHelpers::compareJsonDocuments(const QJsonDocument &doc1, const QJsonDocument &doc2)
{
    return doc1.toJson() == doc2.toJson();
}

bool TestHelpers::compareJsonObjects(const QJsonObject &obj1, const QJsonObject &obj2)
{
    if (obj1.keys().size() != obj2.keys().size()) {
        return false;
    }
    
    for (auto it = obj1.begin(); it != obj1.end(); ++it) {
        if (!obj2.contains(it.key()) || obj2[it.key()] != it.value()) {
            return false;
        }
    }
    
    return true;
}

bool TestHelpers::compareJsonArrays(const QJsonArray &arr1, const QJsonArray &arr2)
{
    if (arr1.size() != arr2.size()) {
        return false;
    }
    
    for (int i = 0; i < arr1.size(); ++i) {
        if (arr1[i] != arr2[i]) {
            return false;
        }
    }
    
    return true;
}

void TestHelpers::logTestStart(const QString &testName)
{
    qDebug() << "=== Starting test:" << testName << "===";
}

void TestHelpers::logTestEnd(const QString &testName, bool success)
{
    qDebug() << "=== Test" << testName << (success ? "PASSED" : "FAILED") << "===";
}

void TestHelpers::logPerformanceResult(const QString &operation, qint64 timeMs, qint64 sizeBytes)
{
    double throughput = calculateThroughput(sizeBytes, timeMs);
    qDebug() << operation << ":" << formatTime(timeMs) << "(" << formatThroughput(throughput) << ")";
}

QString TestHelpers::getSystemInfo()
{
    return QString("Qt %1, %2, %3")
        .arg(QT_VERSION_STR)
        .arg(QSysInfo::prettyProductName())
        .arg(QSysInfo::currentCpuArchitecture());
}

QString TestHelpers::getQtVersion()
{
    return QString(QT_VERSION_STR);
}

QString TestHelpers::getCurrentTimestamp()
{
    return QDateTime::currentDateTime().toString("yyyy-MM-dd hh:mm:ss");
}

} // namespace test
} // namespace treon
