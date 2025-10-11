#ifndef JSON_PERFORMANCE_TEST_HPP
#define JSON_PERFORMANCE_TEST_HPP

#include <QObject>
#include <QString>
#include <QMap>
#include <functional>

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
    
    class JSONDataGenerator *m_dataGenerator;
    class JSONTestConfig *m_config;
    QMap<QString, QMap<QString, qint64>> m_performanceResults;
};

#endif // JSON_PERFORMANCE_TEST_HPP
