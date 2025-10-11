#ifndef JSON_TEST_CONFIG_HPP
#define JSON_TEST_CONFIG_HPP

#include <QString>
#include <QMap>
#include <QStringList>

struct TestSizeConfig
{
    QString name;
    QString label;
    qint64 sizeBytes;
    bool enabled;
    
    // Default constructor for QMap compatibility
    TestSizeConfig() : name(""), label(""), sizeBytes(0), enabled(false) {}
    
    TestSizeConfig(const QString &name, const QString &label, qint64 sizeBytes, bool enabled = true)
        : name(name), label(label), sizeBytes(sizeBytes), enabled(enabled) {}
};

class JSONTestConfig
{
public:
    static JSONTestConfig& instance();
    
    // Test size configurations
    QMap<QString, TestSizeConfig> getTestSizes() const { return m_testSizes; }
    QStringList getEnabledTestSizes() const;
    TestSizeConfig getTestSize(const QString &name) const;
    
    // File naming
    QString getTestFileName(const QString &sizeName) const;
    QString getTestFilePath(const QString &sizeName, const QString &baseDir) const;
    
    // Configuration
    void setTestDataDirectory(const QString &dir) { m_testDataDir = dir; }
    QString getTestDataDirectory() const { return m_testDataDir; }
    
    void enableTestSize(const QString &name, bool enabled = true);
    void disableTestSize(const QString &name) { enableTestSize(name, false); }
    
    // Custom test sizes
    void addCustomTestSize(const QString &name, const QString &label, qint64 sizeBytes);
    
    // Performance thresholds
    void setPerformanceThreshold(const QString &operation, qint64 maxTimeMs);
    qint64 getPerformanceThreshold(const QString &operation) const;
    
private:
    JSONTestConfig();
    void initializeDefaultTestSizes();
    void initializeDefaultThresholds();
    
    QMap<QString, TestSizeConfig> m_testSizes;
    QMap<QString, qint64> m_performanceThresholds;
    QString m_testDataDir;
};

#endif // JSON_TEST_CONFIG_HPP
