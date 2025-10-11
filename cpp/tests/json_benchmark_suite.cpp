#include "json_benchmark_suite.hpp"
#include "json_data_generator.hpp"
#include <QCoreApplication>
#include <QElapsedTimer>
#include <QFile>
#include <QJsonDocument>
#include <QJsonParseError>
#include <QDebug>
#include <QTextStream>
#include <QDateTime>
#include <QStandardPaths>
#include <QDir>

JSONBenchmarkSuite::JSONBenchmarkSuite(QObject *parent)
    : QObject(parent)
    , m_dataGenerator(new JSONDataGenerator())
{
}

JSONBenchmarkSuite::~JSONBenchmarkSuite()
{
    delete m_dataGenerator;
}

void JSONBenchmarkSuite::runFullBenchmark()
{
    qDebug() << "=== Treon JSON Performance Benchmark Suite ===";
    qDebug() << "Started at:" << QDateTime::currentDateTime().toString();
    qDebug() << "System info:" << getSystemInfo();
    qDebug() << "";
    
    // Create test data directory
    QString testDir = m_dataGenerator->createTestDataDirectory();
    qDebug() << "Test data directory:" << testDir;
    qDebug() << "";
    
    // Define test sizes
    QMap<QString, qint64> testSizes = {
        {"10KB", 10 * 1024},
        {"35KB", 35 * 1024},
        {"50KB", 50 * 1024},
        {"1MB", 1024 * 1024},
        {"5MB", 5 * 1024 * 1024},
        {"25MB", 25 * 1024 * 1024},
        {"50MB", 50 * 1024 * 1024},
        {"100MB", 100 * 1024 * 1024},
        {"500MB", 500 * 1024 * 1024},
        {"1GB", 1024 * 1024 * 1024}
    };
    
    BenchmarkResults results;
    
    for (auto it = testSizes.begin(); it != testSizes.end(); ++it) {
        QString sizeLabel = it.key();
        qint64 targetSize = it.value();
        
        qDebug() << "=== Testing" << sizeLabel << "===";
        
        BenchmarkResult result = runBenchmarkForSize(sizeLabel, targetSize, testDir);
        results[sizeLabel] = result;
        
        qDebug() << "✓" << sizeLabel << "benchmark completed";
        qDebug() << "";
    }
    
    // Generate report
    generateReport(results);
    
    qDebug() << "=== Benchmark Suite Completed ===";
    qDebug() << "Report saved to:" << getReportPath();
}

BenchmarkResult JSONBenchmarkSuite::runBenchmarkForSize(const QString &sizeLabel, qint64 targetSize, const QString &testDir)
{
    BenchmarkResult result;
    result.sizeLabel = sizeLabel;
    result.targetSize = targetSize;
    
    QString fileName = QString("%1/test_%2.json").arg(testDir, sizeLabel.toLower());
    
    // Generate JSON data
    qDebug() << "Generating" << sizeLabel << "JSON data...";
    QElapsedTimer timer;
    timer.start();
    
    QString jsonData = m_dataGenerator->generateTestJSON(targetSize, fileName);
    result.generationTime = timer.elapsed();
    result.actualSize = jsonData.size();
    
    qDebug() << "  Generation time:" << result.generationTime << "ms";
    qDebug() << "  Actual size:" << result.actualSize << "bytes";
    
    // File write benchmark
    qDebug() << "Testing file write performance...";
    timer.restart();
    
    QFile file(fileName);
    if (file.open(QIODevice::WriteOnly)) {
        file.write(jsonData.toUtf8());
        file.close();
        result.writeTime = timer.elapsed();
    }
    
    qDebug() << "  Write time:" << result.writeTime << "ms";
    
    // File read benchmark
    qDebug() << "Testing file read performance...";
    timer.restart();
    
    if (file.open(QIODevice::ReadOnly)) {
        QByteArray data = file.readAll();
        file.close();
        result.readTime = timer.elapsed();
    }
    
    qDebug() << "  Read time:" << result.readTime << "ms";
    
    // JSON parsing benchmark
    qDebug() << "Testing JSON parsing performance...";
    timer.restart();
    
    QJsonDocument doc = QJsonDocument::fromJson(jsonData.toUtf8());
    result.parseTime = timer.elapsed();
    
    qDebug() << "  Parse time:" << result.parseTime << "ms";
    
    // JSON validation benchmark
    qDebug() << "Testing JSON validation performance...";
    timer.restart();
    
    QJsonParseError error;
    QJsonDocument::fromJson(jsonData.toUtf8(), &error);
    result.validationTime = timer.elapsed();
    result.isValid = (error.error == QJsonParseError::NoError);
    
    qDebug() << "  Validation time:" << result.validationTime << "ms";
    qDebug() << "  Valid JSON:" << (result.isValid ? "Yes" : "No");
    
    // Calculate throughput
    result.writeThroughput = calculateThroughput(result.actualSize, result.writeTime);
    result.readThroughput = calculateThroughput(result.actualSize, result.readTime);
    result.parseThroughput = calculateThroughput(result.actualSize, result.parseTime);
    
    qDebug() << "  Write throughput:" << result.writeThroughput << "MB/s";
    qDebug() << "  Read throughput:" << result.readThroughput << "MB/s";
    qDebug() << "  Parse throughput:" << result.parseThroughput << "MB/s";
    
    return result;
}

double JSONBenchmarkSuite::calculateThroughput(qint64 sizeBytes, qint64 timeMs)
{
    if (timeMs == 0) return 0.0;
    
    double sizeMB = sizeBytes / (1024.0 * 1024.0);
    double timeSeconds = timeMs / 1000.0;
    
    return sizeMB / timeSeconds;
}

QString JSONBenchmarkSuite::getSystemInfo()
{
    return QString("Qt %1, %2, %3")
        .arg(QT_VERSION_STR)
        .arg(QSysInfo::prettyProductName())
        .arg(QSysInfo::currentCpuArchitecture());
}

QString JSONBenchmarkSuite::getReportPath()
{
    QString reportsDir = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation) + "/TreonBenchmarks";
    QDir().mkpath(reportsDir);
    
    QString timestamp = QDateTime::currentDateTime().toString("yyyy-MM-dd_hh-mm-ss");
    return QString("%1/benchmark_report_%2.txt").arg(reportsDir, timestamp);
}

void JSONBenchmarkSuite::generateReport(const BenchmarkResults &results)
{
    QString reportPath = getReportPath();
    QFile file(reportPath);
    
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        qWarning() << "Failed to create report file:" << reportPath;
        return;
    }
    
    QTextStream out(&file);
    
    // Header
    out << "=== Treon JSON Performance Benchmark Report ===" << Qt::endl;
    out << "Generated:" << QDateTime::currentDateTime().toString() << Qt::endl;
    out << "System:" << getSystemInfo() << Qt::endl;
    out << Qt::endl;
    
    // Summary table
    out << "=== Performance Summary ===" << Qt::endl;
    out << QString("%1 | %2 | %3 | %4 | %5 | %6 | %7 | %8")
        .arg("Size", 8)
        .arg("Actual", 10)
        .arg("Gen(ms)", 8)
        .arg("Write(ms)", 10)
        .arg("Read(ms)", 9)
        .arg("Parse(ms)", 10)
        .arg("Valid", 6)
        .arg("Valid", 6) << Qt::endl;
    out << QString(80, '-') << Qt::endl;
    
    for (auto it = results.begin(); it != results.end(); ++it) {
        const BenchmarkResult &result = it.value();
        out << QString("%1 | %2 | %3 | %4 | %5 | %6 | %7 | %8")
            .arg(result.sizeLabel, 8)
            .arg(formatBytes(result.actualSize), 10)
            .arg(result.generationTime, 8)
            .arg(result.writeTime, 10)
            .arg(result.readTime, 9)
            .arg(result.parseTime, 10)
            .arg(result.validationTime, 6)
            .arg(result.isValid ? "Yes" : "No", 6) << Qt::endl;
    }
    
    out << Qt::endl;
    
    // Throughput table
    out << "=== Throughput Analysis ===" << Qt::endl;
    out << QString("%1 | %2 | %3 | %4")
        .arg("Size", 8)
        .arg("Write(MB/s)", 12)
        .arg("Read(MB/s)", 11)
        .arg("Parse(MB/s)", 12) << Qt::endl;
    out << QString(50, '-') << Qt::endl;
    
    for (auto it = results.begin(); it != results.end(); ++it) {
        const BenchmarkResult &result = it.value();
        out << QString("%1 | %2 | %3 | %4")
            .arg(result.sizeLabel, 8)
            .arg(QString::number(result.writeThroughput, 'f', 2), 12)
            .arg(QString::number(result.readThroughput, 'f', 2), 11)
            .arg(QString::number(result.parseThroughput, 'f', 2), 12) << Qt::endl;
    }
    
    out << Qt::endl;
    
    // Detailed results
    out << "=== Detailed Results ===" << Qt::endl;
    for (auto it = results.begin(); it != results.end(); ++it) {
        const BenchmarkResult &result = it.value();
        
        out << Qt::endl << "--- " << result.sizeLabel << " ---" << Qt::endl;
        out << "Target Size: " << formatBytes(result.targetSize) << Qt::endl;
        out << "Actual Size: " << formatBytes(result.actualSize) << Qt::endl;
        out << "Generation Time: " << result.generationTime << " ms" << Qt::endl;
        out << "Write Time: " << result.writeTime << " ms" << Qt::endl;
        out << "Read Time: " << result.readTime << " ms" << Qt::endl;
        out << "Parse Time: " << result.parseTime << " ms" << Qt::endl;
        out << "Validation Time: " << result.validationTime << " ms" << Qt::endl;
        out << "Valid JSON: " << (result.isValid ? "Yes" : "No") << Qt::endl;
        out << "Write Throughput: " << QString::number(result.writeThroughput, 'f', 2) << " MB/s" << Qt::endl;
        out << "Read Throughput: " << QString::number(result.readThroughput, 'f', 2) << " MB/s" << Qt::endl;
        out << "Parse Throughput: " << QString::number(result.parseThroughput, 'f', 2) << " MB/s" << Qt::endl;
    }
    
    out << Qt::endl << "=== End of Report ===" << Qt::endl;
    
    file.close();
    
    qDebug() << "Benchmark report generated:" << reportPath;
}

QString JSONBenchmarkSuite::formatBytes(qint64 bytes)
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
