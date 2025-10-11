#include "json_data_generator.hpp"
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QFile>
#include <QDir>
#include <QStandardPaths>
#include <QDebug>
#include <QDateTime>
#include <random>

JSONDataGenerator::JSONDataGenerator()
{
    // Initialize random number generator
    m_randomGenerator.seed(std::chrono::steady_clock::now().time_since_epoch().count());
}

QString JSONDataGenerator::generateTestJSON(qint64 targetSize, const QString &outputPath)
{
    qDebug() << "Generating JSON file of target size:" << targetSize << "bytes";
    
    // For large files (>5MB), use the efficient streaming approach
    if (targetSize > 5 * 1024 * 1024) {
        return generateLargeJSON(targetSize, outputPath);
    }
    
    // For smaller files, use the original approach
    QJsonObject root;
    QJsonArray items;
    
    qint64 currentSize = 0;
    int itemCount = 0;
    
    // Generate base structure size
    QJsonObject baseStructure = createBaseStructure();
    QJsonDocument baseDoc(baseStructure);
    qint64 baseSize = baseDoc.toJson().size();
    
    qDebug() << "Base structure size:" << baseSize << "bytes";
    
    while (currentSize < targetSize) {
        QJsonObject item = generateRandomItem(itemCount);
        items.append(item);
        
        // Update root object
        root["items"] = items;
        root["metadata"] = QJsonObject{
            {"totalItems", itemCount + 1},
            {"generatedAt", QDateTime::currentDateTime().toString(Qt::ISODate)},
            {"targetSize", targetSize},
            {"currentSize", currentSize}
        };
        
        // Calculate current size
        QJsonDocument doc(root);
        currentSize = doc.toJson().size();
        itemCount++;
        
        // Progress reporting for large files
        if (itemCount % 10000 == 0) {
            qDebug() << "Generated" << itemCount << "items, current size:" << currentSize << "bytes";
        }
        
        // Prevent infinite loop
        if (itemCount > 10000000) { // 10 million items max
            qWarning() << "Reached maximum item count limit";
            break;
        }
    }
    
    QString jsonString = QJsonDocument(root).toJson();
    
    // Write to file if output path is provided
    if (!outputPath.isEmpty()) {
        QFile file(outputPath);
        if (file.open(QIODevice::WriteOnly)) {
            file.write(jsonString.toUtf8());
            file.close();
            qDebug() << "JSON file written to:" << outputPath;
            qDebug() << "Final file size:" << file.size() << "bytes";
            qDebug() << "Total items generated:" << itemCount;
        } else {
            qWarning() << "Failed to write JSON file to:" << outputPath;
        }
    }
    
    return jsonString;
}

QString JSONDataGenerator::generateLargeJSON(qint64 targetSize, const QString &outputPath)
{
    qDebug() << "Using efficient streaming approach for large JSON file";
    
    QFile file(outputPath);
    if (!file.open(QIODevice::WriteOnly)) {
        qWarning() << "Failed to open file for writing:" << outputPath;
        return QString();
    }
    
    // Write JSON header
    file.write("{\n");
    file.write("  \"metadata\": {\n");
    file.write("    \"generatedAt\": \"" + QDateTime::currentDateTime().toString(Qt::ISODate).toUtf8() + "\",\n");
    file.write("    \"targetSize\": " + QByteArray::number(targetSize) + ",\n");
    file.write("    \"description\": \"Large JSON test file\"\n");
    file.write("  },\n");
    file.write("  \"items\": [\n");
    
    qint64 currentSize = file.size();
    int itemCount = 0;
    
    // Estimate item size for better progress tracking
    QJsonObject sampleItem = generateRandomItem(0);
    QJsonDocument sampleDoc(sampleItem);
    qint64 estimatedItemSize = sampleDoc.toJson().size() + 2; // +2 for comma and newline
    
    qint64 targetItems = (targetSize - currentSize) / estimatedItemSize;
    
    qDebug() << "Estimated items needed:" << targetItems;
    
    while (currentSize < targetSize && itemCount < targetItems * 1.2) { // 20% buffer
        QJsonObject item = generateRandomItem(itemCount);
        QJsonDocument itemDoc(item);
        QByteArray itemJson = itemDoc.toJson();
        
        if (itemCount > 0) {
            file.write(",\n");
        }
        file.write("    " + itemJson);
        
        currentSize = file.size();
        itemCount++;
        
        // Progress reporting
        if (itemCount % 10000 == 0) {
            qDebug() << "Generated" << itemCount << "items, current size:" << currentSize << "bytes";
        }
    }
    
    // Write JSON footer
    file.write("\n  ]\n");
    file.write("}\n");
    file.close();
    
    qDebug() << "Large JSON file generated successfully:" << outputPath;
    qDebug() << "Final size:" << file.size() << "bytes";
    qDebug() << "Total items:" << itemCount;
    
    return QString(); // For large files, we don't return the content
}

QJsonObject JSONDataGenerator::createBaseStructure()
{
    return QJsonObject{
        {"version", "1.0"},
        {"generator", "Treon JSON Performance Test"},
        {"items", QJsonArray()},
        {"metadata", QJsonObject()}
    };
}

QJsonObject JSONDataGenerator::generateRandomItem(int index)
{
    QJsonObject item;
    
    // Basic fields
    item["id"] = index;
    item["name"] = QString("Item_%1").arg(index);
    item["value"] = static_cast<int>(m_randomGenerator() % 10000);
    item["timestamp"] = QDateTime::currentDateTime().toString(Qt::ISODate);
    
    // Variable length description
    QString description = generateRandomDescription();
    item["description"] = description;
    
    // Nested object
    item["metadata"] = QJsonObject{
        {"category", QString("category_%1").arg(index % 20)},
        {"priority", index % 10},
        {"active", index % 2 == 0},
        {"score", static_cast<int>(m_randomGenerator() % 1000)},
        {"tags", generateRandomTags()}
    };
    
    // Array of sub-items
    item["subItems"] = generateRandomSubItems();
    
    // Additional data to increase size
    item["data"] = generateRandomData();
    
    return item;
}

QString JSONDataGenerator::generateRandomDescription()
{
    static const QStringList words = {
        "lorem", "ipsum", "dolor", "sit", "amet", "consectetur", "adipiscing", "elit",
        "sed", "do", "eiusmod", "tempor", "incididunt", "ut", "labore", "et", "dolore",
        "magna", "aliqua", "enim", "ad", "minim", "veniam", "quis", "nostrud",
        "exercitation", "ullamco", "laboris", "nisi", "aliquip", "ex", "ea", "commodo",
        "consequat", "duis", "aute", "irure", "in", "reprehenderit", "voluptate",
        "velit", "esse", "cillum", "fugiat", "nulla", "pariatur", "excepteur", "sint",
        "occaecat", "cupidatat", "non", "proident", "sunt", "culpa", "qui", "officia",
        "deserunt", "mollit", "anim", "id", "est", "laborum"
    };
    
    int wordCount = 10 + (m_randomGenerator() % 20); // 10-30 words
    QString description;
    
    for (int i = 0; i < wordCount; ++i) {
        if (i > 0) description += " ";
        description += words[m_randomGenerator() % words.size()];
    }
    
    return description;
}

QJsonArray JSONDataGenerator::generateRandomTags()
{
    QJsonArray tags;
    int tagCount = 2 + (m_randomGenerator() % 5); // 2-6 tags
    
    for (int i = 0; i < tagCount; ++i) {
        tags.append(QString("tag_%1").arg(m_randomGenerator() % 100));
    }
    
    return tags;
}

QJsonArray JSONDataGenerator::generateRandomSubItems()
{
    QJsonArray subItems;
    int subItemCount = 1 + (m_randomGenerator() % 3); // 1-3 sub-items
    
    for (int i = 0; i < subItemCount; ++i) {
        QJsonObject subItem;
        subItem["id"] = i;
        subItem["name"] = QString("SubItem_%1").arg(i);
        subItem["value"] = static_cast<int>(m_randomGenerator() % 1000);
        subItems.append(subItem);
    }
    
    return subItems;
}

QJsonObject JSONDataGenerator::generateRandomData()
{
    QJsonObject data;
    
    // Add various data types
    data["boolean"] = m_randomGenerator() % 2 == 0;
    data["number"] = static_cast<int>(m_randomGenerator() % 1000000);
    data["float"] = (m_randomGenerator() % 10000) / 100.0;
    data["string"] = QString("random_string_%1").arg(m_randomGenerator() % 1000);
    
    // Add nested object
    data["nested"] = QJsonObject{
        {"level1", QJsonObject{
            {"level2", QJsonObject{
                {"value", static_cast<int>(m_randomGenerator() % 100)}
            }}
        }}
    };
    
    return data;
}

QString JSONDataGenerator::createTestDataDirectory()
{
    QString tempDir = QStandardPaths::writableLocation(QStandardPaths::TempLocation) + "/treon_json_tests";
    QDir().mkpath(tempDir);
    return tempDir;
}

void JSONDataGenerator::generateAllTestFiles()
{
    QString testDir = createTestDataDirectory();
    qDebug() << "Creating test files in:" << testDir;
    
    // Generate test files of various sizes
    QMap<QString, qint64> testSizes = {
        {"10kb", 10 * 1024},
        {"35kb", 35 * 1024},
        {"50kb", 50 * 1024},
        {"1mb", 1024 * 1024},
        {"5mb", 5 * 1024 * 1024},
        {"25mb", 25 * 1024 * 1024},
        {"50mb", 50 * 1024 * 1024},
        {"100mb", 100 * 1024 * 1024},
        {"500mb", 500 * 1024 * 1024},
        {"1gb", 1024 * 1024 * 1024}
    };
    
    for (auto it = testSizes.begin(); it != testSizes.end(); ++it) {
        QString fileName = QString("%1/test_%2.json").arg(testDir, it.key());
        qDebug() << "Generating" << it.key() << "test file...";
        
        generateTestJSON(it.value(), fileName);
        
        // Verify file was created
        QFile file(fileName);
        if (file.exists()) {
            qDebug() << "✓ Generated" << it.key() << "file:" << file.size() << "bytes";
        } else {
            qWarning() << "✗ Failed to generate" << it.key() << "file";
        }
    }
    
    qDebug() << "All test files generated in:" << testDir;
}
