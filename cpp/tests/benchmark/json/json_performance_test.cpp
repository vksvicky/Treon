#include <QTest>
#include <QObject>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QFile>
#include <QDir>
#include <QStandardPaths>
#include <QElapsedTimer>
#include <QDebug>
#include <QCoreApplication>
#include <random>
#include <chrono>
#include "json_test_config.hpp"
#include "json_data_generator.hpp"

class JSONPerformanceTest : public QObject
{
    Q_OBJECT

private slots:
    void initTestCase();
    void cleanupTestCase();
    void init();
    void cleanup();

    // Dynamic test cases based on configuration
    void testJSONPerformance();

private:
    void runPerformanceTestForSize(const QString &sizeName);
    void measurePerformance(const QString &testName, std::function<void()> operation);
    bool checkPerformanceThreshold(const QString &operation, qint64 actualTime);
    
    JSONDataGenerator *m_dataGenerator;
    JSONTestConfig *m_config;
    QMap<QString, QMap<QString, qint64>> m_performanceResults;
};

void JSONPerformanceTest::initTestCase()
{
    m_config = &JSONTestConfig::instance();
    m_dataGenerator = new JSONDataGenerator();
    
    // Ensure test data directory exists
    QDir().mkpath(m_config->getTestDataDirectory());
    
    qDebug() << "JSON Performance Test Suite initialized";
    qDebug() << "Test data directory:" << m_config->getTestDataDirectory();
    qDebug() << "Enabled test sizes:" << m_config->getEnabledTestSizes();
}

void JSONPerformanceTest::cleanupTestCase()
{
    // Clean up test files
    QDir testDir(m_config->getTestDataDirectory());
    if (testDir.exists()) {
        testDir.removeRecursively();
    }
    
    delete m_dataGenerator;
    
    qDebug() << "JSON Performance Test Suite completed";
    
    // Print performance summary
    qDebug() << "\n=== PERFORMANCE SUMMARY ===";
    for (auto it = m_performanceResults.begin(); it != m_performanceResults.end(); ++it) {
        qDebug() << "\n" << it.key() << ":";
        for (auto metric = it.value().begin(); metric != it.value().end(); ++metric) {
            qDebug() << "  " << metric.key() << ":" << metric.value() << "ms";
        }
    }
}

void JSONPerformanceTest::init()
{
    // Setup for each test
}

void JSONPerformanceTest::cleanup()
{
    // Cleanup after each test
}

void JSONPerformanceTest::measurePerformance(const QString &testName, std::function<void()> operation)
{
    QElapsedTimer timer;
    timer.start();
    
    operation();
    
    qint64 elapsed = timer.elapsed();
    m_performanceResults[testName]["execution_time"] = elapsed;
    
    qDebug() << testName << "completed in" << elapsed << "ms";
}

void JSONPerformanceTest::testJSONPerformance()
{
    QStringList enabledSizes = m_config->getEnabledTestSizes();
    
    qDebug() << "Running JSON performance tests for" << enabledSizes.size() << "file sizes";
    
    for (const QString &sizeName : enabledSizes) {
        qDebug() << "\n=== Testing" << sizeName << "===";
        runPerformanceTestForSize(sizeName);
    }
    
    qDebug() << "\n=== All JSON performance tests completed ===";
}

void JSONPerformanceTest::runPerformanceTestForSize(const QString &sizeName)
{
    TestSizeConfig config = m_config->getTestSize(sizeName);
    if (!config.enabled) {
        qDebug() << "Skipping disabled test size:" << sizeName;
        return;
    }
    
    QString filePath = m_config->getTestFilePath(sizeName, m_config->getTestDataDirectory());
    QFile file(filePath);
    
    QString jsonData;
    
    // Generate JSON data
    measurePerformance(QString("%1_JSON_Generation").arg(config.label), [&]() {
        jsonData = m_dataGenerator->generateTestJSON(config.sizeBytes);
    });
    
    // File write benchmark
    measurePerformance(QString("%1_JSON_Write").arg(config.label), [&]() {
        if (file.open(QIODevice::WriteOnly)) {
            file.write(jsonData.toUtf8());
            file.close();
        }
    });
    
    // File read benchmark
    measurePerformance(QString("%1_JSON_Read").arg(config.label), [&]() {
        if (file.open(QIODevice::ReadOnly)) {
            QByteArray data = file.readAll();
            file.close();
        }
    });
    
    // JSON parsing benchmark
    measurePerformance(QString("%1_JSON_Parse").arg(config.label), [&]() {
        QJsonDocument::fromJson(jsonData.toUtf8());
    });
    
    // JSON validation benchmark
    measurePerformance(QString("%1_JSON_Validate").arg(config.label), [&]() {
        QJsonParseError error;
        QJsonDocument::fromJson(jsonData.toUtf8(), &error);
        QVERIFY(error.error == QJsonParseError::NoError);
    });
    
    qDebug() << config.label << "JSON test completed. File size:" << jsonData.size() << "bytes";
}

bool JSONPerformanceTest::checkPerformanceThreshold(const QString &operation, qint64 actualTime)
{
    qint64 threshold = m_config->getPerformanceThreshold(operation);
    if (threshold > 0 && actualTime > threshold) {
        qWarning() << "Performance threshold exceeded for" << operation 
                   << ":" << actualTime << "ms >" << threshold << "ms";
        return false;
    }
    return true;
}

#include "json_performance_test.moc"

