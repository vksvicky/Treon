#include "test_application.hpp"

void TestApplication::initTestCase()
{
    m_app = new treon::Application(this);
    QVERIFY(m_app != nullptr);
}

void TestApplication::cleanupTestCase()
{
    delete m_app;
}

void TestApplication::testApplicationCreation()
{
    QVERIFY(m_app->currentFile().isEmpty());
    QVERIFY(m_app->jsonText().isEmpty());
    QVERIFY(!m_app->isValid());
    QVERIFY(!m_app->isLoading());
    QVERIFY(m_app->errorMessage().isEmpty());
}

void TestApplication::testFileOperations()
{
    // Test creating new file
    m_app->createNewFile();
    QVERIFY(m_app->jsonText() == "{\n  \n}");
    QVERIFY(!m_app->isValid());
    
    // Test closing file
    m_app->closeFile();
    QVERIFY(m_app->currentFile().isEmpty());
    QVERIFY(m_app->jsonText().isEmpty());
}

void TestApplication::testJSONValidation()
{
    // Test valid JSON
    QString validJson = "{\"test\": 123, \"array\": [1, 2, 3]}";
    m_app->validateJSON(validJson);
    QVERIFY(m_app->isValid());
    
    // Test invalid JSON
    QString invalidJson = "invalid json";
    m_app->validateJSON(invalidJson);
    QVERIFY(!m_app->isValid());
    QVERIFY(!m_app->errorMessage().isEmpty());
}

QTEST_MAIN(TestApplication)
#include "test_application.moc"
