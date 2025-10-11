#ifndef JSON_DATA_GENERATOR_HPP
#define JSON_DATA_GENERATOR_HPP

#include <QJsonObject>
#include <QJsonArray>
#include <QString>
#include <QMap>
#include <random>
#include <chrono>

class JSONDataGenerator
{
public:
    JSONDataGenerator();
    
    // Generate JSON data of specified size
    QString generateTestJSON(qint64 targetSize, const QString &outputPath = QString());
    
    // Generate all test files for performance testing
    void generateAllTestFiles();
    
    // Utility methods
    QString createTestDataDirectory();

private:
    // JSON structure generation
    QJsonObject createBaseStructure();
    QJsonObject generateRandomItem(int index);
    QString generateRandomDescription();
    QJsonArray generateRandomTags();
    QJsonArray generateRandomSubItems();
    QJsonObject generateRandomData();
    
    // Random number generator
    std::mt19937 m_randomGenerator;
};

#endif // JSON_DATA_GENERATOR_HPP
