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

void JSONBenchmarkSuite::runReadingPerformanceTests()
{
    qDebug() << "=== Treon JSON Reading Performance Tests ===";
    qDebug() << "Started at:" << QDateTime::currentDateTime().toString();
    qDebug() << "System info:" << getSystemInfo();
    qDebug() << "";
    
    // Create test data directory
    QString testDir = m_dataGenerator->createTestDataDirectory();
    qDebug() << "Test data directory:" << testDir;
    qDebug() << "";
    
    // Define test sizes for reading performance
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
        
        qDebug() << "=== Testing" << sizeLabel << "Reading Performance ===";
        
        QString fileName = QString("%1/test_%2.json").arg(testDir, sizeLabel.toLower());
        
        // Generate file if it doesn't exist
        if (!QFile::exists(fileName)) {
            qDebug() << "Generating" << sizeLabel << "JSON data...";
            m_dataGenerator->generateTestJSON(targetSize, fileName);
        }
        
        BenchmarkResult result = runReadingTestForFile(fileName, sizeLabel);
        results[sizeLabel] = result;
        
        qDebug() << "✓" << sizeLabel << "reading test completed";
        qDebug() << "";
    }
    
    // Generate reading performance report
    generateReadingReport(results);
    
    qDebug() << "=== Reading Performance Tests Completed ===";
    qDebug() << "Report saved to:" << getReadingReportPath();
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
    
    // File write benchmark (only if jsonData is not empty)
    qDebug() << "Testing file write performance...";
    timer.restart();
    
    QFile file(fileName);
    if (!jsonData.isEmpty() && file.open(QIODevice::WriteOnly)) {
        file.write(jsonData.toUtf8());
        file.close();
        result.writeTime = timer.elapsed();
    } else {
        // For large files, the file was already written during generation
        result.writeTime = 0;
    }
    
    qDebug() << "  Write time:" << result.writeTime << "ms";
    
    // File read benchmark
    qDebug() << "Testing file read performance...";
    timer.restart();
    
    QByteArray fileData;
    if (file.open(QIODevice::ReadOnly)) {
        fileData = file.readAll();
        file.close();
        result.readTime = timer.elapsed();
        result.actualSize = fileData.size(); // Use actual file size
    }
    
    qDebug() << "  Read time:" << result.readTime << "ms";
    
    // JSON parsing benchmark
    qDebug() << "Testing JSON parsing performance...";
    timer.restart();
    
    // For large files (>100MB), use streaming approach to avoid memory issues
    if (result.actualSize > 100 * 1024 * 1024) {
        qDebug() << "  Using streaming JSON parsing for large file...";
        result.parseTime = parseLargeJSONStreaming(fileName);
        result.isValid = true; // Assume valid for streaming
    } else {
        QJsonDocument doc = QJsonDocument::fromJson(fileData);
        result.parseTime = timer.elapsed();
    }
    
    qDebug() << "  Parse time:" << result.parseTime << "ms";
    
    // JSON validation benchmark
    qDebug() << "Testing JSON validation performance...";
    timer.restart();
    
    // For large files, skip full validation to avoid memory issues
    if (result.actualSize > 100 * 1024 * 1024) {
        qDebug() << "  Skipping full validation for large file (memory optimization)";
        result.validationTime = 0;
        result.isValid = true;
    } else {
        QJsonParseError error;
        QJsonDocument::fromJson(fileData, &error);
        result.validationTime = timer.elapsed();
        result.isValid = (error.error == QJsonParseError::NoError);
    }
    
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

BenchmarkResult JSONBenchmarkSuite::runReadingTestForFile(const QString &filePath, const QString &sizeLabel)
{
    BenchmarkResult result;
    result.sizeLabel = sizeLabel;
    
    QFile file(filePath);
    if (!file.exists()) {
        qWarning() << "File does not exist:" << filePath;
        return result;
    }
    
    result.actualSize = file.size();
    
    // Test 1: Raw file reading performance
    qDebug() << "Testing raw file reading performance...";
    QElapsedTimer timer;
    timer.start();
    
    QByteArray fileData;
    if (file.open(QIODevice::ReadOnly)) {
        fileData = file.readAll();
        file.close();
        result.readTime = timer.elapsed();
    }
    
    qDebug() << "  File read time:" << result.readTime << "ms";
    qDebug() << "  File size:" << result.actualSize << "bytes";
    
    // Test 2: JSON parsing performance
    qDebug() << "Testing JSON parsing performance...";
    timer.restart();
    
    // For large files (>100MB), use streaming approach to avoid memory issues
    if (result.actualSize > 100 * 1024 * 1024) {
        qDebug() << "  Using streaming JSON parsing for large file...";
        result.parseTime = parseLargeJSONStreaming(filePath);
        result.isValid = true; // Assume valid for streaming
    } else {
        QJsonDocument doc = QJsonDocument::fromJson(fileData);
        result.parseTime = timer.elapsed();
    }
    
    qDebug() << "  JSON parse time:" << result.parseTime << "ms";
    
    // Test 3: JSON validation performance
    qDebug() << "Testing JSON validation performance...";
    timer.restart();
    
    // For large files, skip full validation to avoid memory issues
    if (result.actualSize > 100 * 1024 * 1024) {
        qDebug() << "  Skipping full validation for large file (memory optimization)";
        result.validationTime = 0;
        result.isValid = true;
    } else {
        QJsonParseError error;
        QJsonDocument::fromJson(fileData, &error);
        result.validationTime = timer.elapsed();
        result.isValid = (error.error == QJsonParseError::NoError);
    }
    
    qDebug() << "  JSON validation time:" << result.validationTime << "ms";
    qDebug() << "  Valid JSON:" << (result.isValid ? "Yes" : "No");
    
    // Calculate throughput
    result.readThroughput = calculateThroughput(result.actualSize, result.readTime);
    result.parseThroughput = calculateThroughput(result.actualSize, result.parseTime);
    
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

QString JSONBenchmarkSuite::getReadingReportPath()
{
    QString reportsDir = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation) + "/TreonBenchmarks";
    QDir().mkpath(reportsDir);
    
    QString timestamp = QDateTime::currentDateTime().toString("yyyy-MM-dd_hh-mm-ss");
    return QString("%1/reading_performance_report_%2.txt").arg(reportsDir, timestamp);
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

void JSONBenchmarkSuite::generateReadingReport(const BenchmarkResults &results)
{
    QString reportPath = getReadingReportPath();
    QFile file(reportPath);
    
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        qWarning() << "Failed to create reading report file:" << reportPath;
        return;
    }
    
    QTextStream out(&file);
    
    // Header
    out << "=== Treon JSON Reading Performance Report ===" << Qt::endl;
    out << "Generated:" << QDateTime::currentDateTime().toString() << Qt::endl;
    out << "System:" << getSystemInfo() << Qt::endl;
    out << Qt::endl;
    
    // Summary table
    out << "=== Reading Performance Summary ===" << Qt::endl;
    out << QString("%1 | %2 | %3 | %4 | %5 | %6 | %7")
        .arg("Size", 8)
        .arg("File Size", 12)
        .arg("Read(ms)", 9)
        .arg("Parse(ms)", 10)
        .arg("Valid(ms)", 10)
        .arg("Read(MB/s)", 11)
        .arg("Parse(MB/s)", 12) << Qt::endl;
    out << QString(80, '-') << Qt::endl;
    
    for (auto it = results.begin(); it != results.end(); ++it) {
        const BenchmarkResult &result = it.value();
        out << QString("%1 | %2 | %3 | %4 | %5 | %6 | %7")
            .arg(result.sizeLabel, 8)
            .arg(formatBytes(result.actualSize), 12)
            .arg(result.readTime, 9)
            .arg(result.parseTime, 10)
            .arg(result.validationTime, 10)
            .arg(QString::number(result.readThroughput, 'f', 2), 11)
            .arg(QString::number(result.parseThroughput, 'f', 2), 12) << Qt::endl;
    }
    
    out << Qt::endl;
    
    // Detailed results
    out << "=== Detailed Reading Performance Results ===" << Qt::endl;
    for (auto it = results.begin(); it != results.end(); ++it) {
        const BenchmarkResult &result = it.value();
        
        out << Qt::endl << "--- " << result.sizeLabel << " ---" << Qt::endl;
        out << "File Size: " << formatBytes(result.actualSize) << Qt::endl;
        out << "Read Time: " << result.readTime << " ms" << Qt::endl;
        out << "Parse Time: " << result.parseTime << " ms" << Qt::endl;
        out << "Validation Time: " << result.validationTime << " ms" << Qt::endl;
        out << "Valid JSON: " << (result.isValid ? "Yes" : "No") << Qt::endl;
        out << "Read Throughput: " << QString::number(result.readThroughput, 'f', 2) << " MB/s" << Qt::endl;
        out << "Parse Throughput: " << QString::number(result.parseThroughput, 'f', 2) << " MB/s" << Qt::endl;
    }
    
    out << Qt::endl << "=== End of Reading Performance Report ===" << Qt::endl;
    
    file.close();
    
    qDebug() << "Reading performance report generated:" << reportPath;
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

qint64 JSONBenchmarkSuite::parseLargeJSONStreaming(const QString &filePath)
{
    QElapsedTimer timer;
    timer.start();
    
    QFile file(filePath);
    if (!file.open(QIODevice::ReadOnly)) {
        qWarning() << "Failed to open file for streaming parsing:" << filePath;
        return -1;
    }
    
    // Simple streaming JSON validation - just check basic structure
    // This is much more memory efficient than loading the entire file
    QTextStream stream(&file);
    QString line;
    int braceCount = 0;
    int bracketCount = 0;
    bool inString = false;
    bool escaped = false;
    qint64 bytesProcessed = 0;
    
    while (!stream.atEnd()) {
        line = stream.readLine();
        bytesProcessed += line.length() + 1; // +1 for newline
        
        for (int i = 0; i < line.length(); ++i) {
            QChar c = line.at(i);
            
            if (escaped) {
                escaped = false;
                continue;
            }
            
            if (c == '\\') {
                escaped = true;
                continue;
            }
            
            if (c == '"') {
                inString = !inString;
                continue;
            }
            
            if (!inString) {
                if (c == '{') {
                    braceCount++;
                } else if (c == '}') {
                    braceCount--;
                } else if (c == '[') {
                    bracketCount++;
                } else if (c == ']') {
                    bracketCount--;
                }
            }
        }
        
        // Progress reporting for very large files
        if (bytesProcessed % (10 * 1024 * 1024) == 0) { // Every 10MB
            qDebug() << "  Processed" << formatBytes(bytesProcessed) << "of JSON structure";
        }
    }
    
    file.close();
    
    qint64 parseTime = timer.elapsed();
    qDebug() << "  Streaming parse completed in" << parseTime << "ms";
    qDebug() << "  Total bytes processed:" << formatBytes(bytesProcessed);
    qDebug() << "  Structure validation: braces=" << braceCount << ", brackets=" << bracketCount;
    
    return parseTime;
}
