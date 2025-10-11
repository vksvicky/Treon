#ifndef JSON_BENCHMARK_SUITE_HPP
#define JSON_BENCHMARK_SUITE_HPP

#include <QObject>
#include <QString>
#include <QMap>
#include <QElapsedTimer>
#include <QJsonDocument>
#include <QJsonParseError>

struct BenchmarkResult
{
    QString sizeLabel;
    qint64 targetSize;
    qint64 actualSize;
    qint64 generationTime;
    qint64 writeTime;
    qint64 readTime;
    qint64 parseTime;
    qint64 validationTime;
    bool isValid;
    double writeThroughput;
    double readThroughput;
    double parseThroughput;
    
    BenchmarkResult()
        : targetSize(0)
        , actualSize(0)
        , generationTime(0)
        , writeTime(0)
        , readTime(0)
        , parseTime(0)
        , validationTime(0)
        , isValid(false)
        , writeThroughput(0.0)
        , readThroughput(0.0)
        , parseThroughput(0.0)
    {}
};

typedef QMap<QString, BenchmarkResult> BenchmarkResults;

class JSONDataGenerator;

class JSONBenchmarkSuite : public QObject
{
    Q_OBJECT

public:
    explicit JSONBenchmarkSuite(QObject *parent = nullptr);
    ~JSONBenchmarkSuite();
    
    // Run the complete benchmark suite
    void runFullBenchmark();

private:
    // Run benchmark for a specific file size
    BenchmarkResult runBenchmarkForSize(const QString &sizeLabel, qint64 targetSize, const QString &testDir);
    
    // Utility methods
    double calculateThroughput(qint64 sizeBytes, qint64 timeMs);
    QString getSystemInfo();
    QString getReportPath();
    void generateReport(const BenchmarkResults &results);
    QString formatBytes(qint64 bytes);
    
    JSONDataGenerator *m_dataGenerator;
};

#endif // JSON_BENCHMARK_SUITE_HPP
