#include "json_test_config.hpp"
#include <QStandardPaths>
#include <QDir>
#include <QDebug>

JSONTestConfig& JSONTestConfig::instance()
{
    static JSONTestConfig instance;
    return instance;
}

JSONTestConfig::JSONTestConfig()
{
    initializeDefaultTestSizes();
    initializeDefaultThresholds();
    m_testDataDir = QStandardPaths::writableLocation(QStandardPaths::TempLocation) + "/treon_json_tests";
}

void JSONTestConfig::initializeDefaultTestSizes()
{
    // Define test sizes in a more flexible way
    m_testSizes["10kb"] = TestSizeConfig("10kb", "10KB", 10 * 1024);
    m_testSizes["35kb"] = TestSizeConfig("35kb", "35KB", 35 * 1024);
    m_testSizes["50kb"] = TestSizeConfig("50kb", "50KB", 50 * 1024);
    m_testSizes["1mb"] = TestSizeConfig("1mb", "1MB", 1024 * 1024);
    m_testSizes["5mb"] = TestSizeConfig("5mb", "5MB", 5 * 1024 * 1024);
    m_testSizes["25mb"] = TestSizeConfig("25mb", "25MB", 25 * 1024 * 1024);
    m_testSizes["50mb"] = TestSizeConfig("50mb", "50MB", 50 * 1024 * 1024);
    m_testSizes["100mb"] = TestSizeConfig("100mb", "100MB", 100 * 1024 * 1024);
    m_testSizes["500mb"] = TestSizeConfig("500mb", "500MB", 500 * 1024 * 1024);
    m_testSizes["1gb"] = TestSizeConfig("1gb", "1GB", 1024 * 1024 * 1024);
    
    // Disable very large tests by default to avoid long execution times
    m_testSizes["500mb"].enabled = false;
    m_testSizes["1gb"].enabled = false;
}

void JSONTestConfig::initializeDefaultThresholds()
{
    // Set performance thresholds for different operations (in milliseconds)
    m_performanceThresholds["generation"] = 10000;  // 10 seconds
    m_performanceThresholds["write"] = 5000;        // 5 seconds
    m_performanceThresholds["read"] = 2000;         // 2 seconds
    m_performanceThresholds["parse"] = 10000;       // 10 seconds
    m_performanceThresholds["validation"] = 5000;   // 5 seconds
}

QStringList JSONTestConfig::getEnabledTestSizes() const
{
    QStringList enabled;
    for (auto it = m_testSizes.begin(); it != m_testSizes.end(); ++it) {
        if (it.value().enabled) {
            enabled.append(it.key());
        }
    }
    return enabled;
}

TestSizeConfig JSONTestConfig::getTestSize(const QString &name) const
{
    auto it = m_testSizes.find(name);
    if (it != m_testSizes.end()) {
        return it.value();
    }
    
    // Return a default config if not found
    qWarning() << "Test size not found:" << name;
    return TestSizeConfig("unknown", "Unknown", 0, false);
}

QString JSONTestConfig::getTestFileName(const QString &sizeName) const
{
    return QString("test_%1.json").arg(sizeName);
}

QString JSONTestConfig::getTestFilePath(const QString &sizeName, const QString &baseDir) const
{
    QString fileName = getTestFileName(sizeName);
    return QDir(baseDir).filePath(fileName);
}

void JSONTestConfig::enableTestSize(const QString &name, bool enabled)
{
    auto it = m_testSizes.find(name);
    if (it != m_testSizes.end()) {
        it.value().enabled = enabled;
        qDebug() << "Test size" << name << (enabled ? "enabled" : "disabled");
    } else {
        qWarning() << "Cannot enable/disable unknown test size:" << name;
    }
}

void JSONTestConfig::addCustomTestSize(const QString &name, const QString &label, qint64 sizeBytes)
{
    m_testSizes[name] = TestSizeConfig(name, label, sizeBytes, true);
    qDebug() << "Added custom test size:" << name << "(" << label << "," << sizeBytes << "bytes)";
}

void JSONTestConfig::setPerformanceThreshold(const QString &operation, qint64 maxTimeMs)
{
    m_performanceThresholds[operation] = maxTimeMs;
    qDebug() << "Set performance threshold for" << operation << "to" << maxTimeMs << "ms";
}

qint64 JSONTestConfig::getPerformanceThreshold(const QString &operation) const
{
    auto it = m_performanceThresholds.find(operation);
    if (it != m_performanceThresholds.end()) {
        return it.value();
    }
    return 0; // No threshold set
}
