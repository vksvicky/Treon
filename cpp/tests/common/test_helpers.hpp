#ifndef TEST_HELPERS_HPP
#define TEST_HELPERS_HPP

#include <QString>
#include <QByteArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QFile>
#include <QDir>
#include <QStandardPaths>
#include <QElapsedTimer>
#include <QDebug>

namespace treon {
namespace test {

/**
 * @brief Common test utilities and helpers for Treon tests
 */
class TestHelpers
{
public:
    // File system utilities
    static QString createTempDirectory(const QString &prefix = "treon_test");
    static QString createTempFile(const QString &content, const QString &suffix = ".tmp");
    static bool removeTempDirectory(const QString &path);
    static QString getTestDataPath();
    
    // JSON utilities
    static QJsonDocument createValidJsonDocument();
    static QJsonDocument createInvalidJsonDocument();
    static bool isValidJson(const QString &jsonString);
    static QString formatJsonSize(qint64 bytes);
    
    // Performance utilities
    static double calculateThroughput(qint64 sizeBytes, qint64 timeMs);
    static QString formatTime(qint64 timeMs);
    static QString formatThroughput(double throughput);
    
    // Test data generation
    static QString generateTestJsonData(qint64 targetSize);
    static QJsonObject createTestJsonObject(int itemCount = 10);
    static QJsonArray createTestJsonArray(int itemCount = 10);
    
    // Assertion helpers
    static bool compareJsonDocuments(const QJsonDocument &doc1, const QJsonDocument &doc2);
    static bool compareJsonObjects(const QJsonObject &obj1, const QJsonObject &obj2);
    static bool compareJsonArrays(const QJsonArray &arr1, const QJsonArray &arr2);
    
    // Logging utilities
    static void logTestStart(const QString &testName);
    static void logTestEnd(const QString &testName, bool success);
    static void logPerformanceResult(const QString &operation, qint64 timeMs, qint64 sizeBytes);
    
    // System information
    static QString getSystemInfo();
    static QString getQtVersion();
    static QString getCurrentTimestamp();
};

} // namespace test
} // namespace treon

#endif // TEST_HELPERS_HPP
