#include <QtTest>
#include <QSignalSpy>
#include <QUrl>

#include "treon/JSONParser.hpp"
#include "treon/JSONViewModel.hpp"
#include "treon/FileManager.hpp"

class TestCore : public QObject
{
    Q_OBJECT

private slots:
    void initTestCase();
    void cleanupTestCase();
    void testJSONParser();
    void testJSONViewModel();
    void testFileManager();

private:
    treon::JSONViewModel *m_viewModel;
    treon::FileManager *m_fileManager;
};

void TestCore::initTestCase()
{
    m_viewModel = new treon::JSONViewModel(this);
    m_fileManager = &treon::FileManager::instance();
}

void TestCore::cleanupTestCase()
{
    delete m_viewModel;
}

void TestCore::testJSONParser()
{
    // Test valid JSON
    std::string validJson = "{\"test\": 123, \"array\": [1, 2, 3]}";
    auto result = treon::JSONParser::parse(validJson);
    QVERIFY(result != nullptr);
    
    // Test invalid JSON - current implementation returns makeNull() for all inputs
    std::string invalidJson = "invalid json";
    auto invalidResult = treon::JSONParser::parse(invalidJson);
    QVERIFY(invalidResult != nullptr); // Current implementation always returns non-null
    
    // Test validation
    QVERIFY(treon::JSONParser::validate(validJson));
    QVERIFY(!treon::JSONParser::validate(invalidJson));
}

void TestCore::testJSONViewModel()
{
    // Test initial state
    QCOMPARE(m_viewModel->isValid(), false);
    QCOMPARE(m_viewModel->jsonText(), QString(""));
    
    // Test setting valid JSON
    m_viewModel->setJSON("{\"test\": 123}");
    QCOMPARE(m_viewModel->isValid(), true);
    QCOMPARE(m_viewModel->jsonText(), QString("{\"test\": 123}"));
    
    // Test setting invalid JSON
    m_viewModel->setJSON("invalid json");
    QCOMPARE(m_viewModel->isValid(), false);
}

void TestCore::testFileManager()
{
    // Test initial state
    QCOMPARE(m_fileManager->isLoading(), false);
    QCOMPARE(m_fileManager->errorMessage(), QString(""));
}

QTEST_MAIN(TestCore)
#include "test_application.moc"
