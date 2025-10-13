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

void TestApplication::testJSONFormatting()
{
    // Test formatting valid JSON
    QString compactJson = "{\"test\":123,\"array\":[1,2,3]}";
    
    // First validate the JSON to set it in the application
    m_app->validateJSON(compactJson);
    QVERIFY(m_app->isValid());
    
    // Spy on signals
    QSignalSpy jsonTextChangedSpy(m_app, &treon::Application::jsonTextChanged);
    QSignalSpy jsonModelChangedSpy(m_app, &treon::Application::jsonModelChanged);
    QSignalSpy jsonFormattedSpy(m_app, &treon::Application::jsonFormatted);
    
    m_app->formatJSON(compactJson);
    
    // Verify signals were emitted
    QCOMPARE(jsonTextChangedSpy.count(), 1);
    QCOMPARE(jsonModelChangedSpy.count(), 1);
    QCOMPARE(jsonFormattedSpy.count(), 1);
    
    // Verify JSON was formatted (should be indented)
    QString formattedJson = m_app->jsonText();
    QVERIFY(formattedJson.contains('\n'));
    QVERIFY(formattedJson.contains("  ")); // Should have indentation
    
    // Test formatting invalid JSON
    QString invalidJson = "invalid json";
    m_app->formatJSON(invalidJson);
    QVERIFY(!m_app->errorMessage().isEmpty());
}

void TestApplication::testJSONMinification()
{
    // Test minifying valid JSON
    QString formattedJson = "{\n  \"test\": 123,\n  \"array\": [1, 2, 3]\n}";
    
    // First validate the JSON to set it in the application
    m_app->validateJSON(formattedJson);
    QVERIFY(m_app->isValid());
    
    // Spy on signals
    QSignalSpy jsonTextChangedSpy(m_app, &treon::Application::jsonTextChanged);
    QSignalSpy jsonModelChangedSpy(m_app, &treon::Application::jsonModelChanged);
    QSignalSpy jsonFormattedSpy(m_app, &treon::Application::jsonFormatted);
    
    m_app->minifyJSON(formattedJson);
    
    // Verify signals were emitted
    QCOMPARE(jsonTextChangedSpy.count(), 1);
    QCOMPARE(jsonModelChangedSpy.count(), 1);
    QCOMPARE(jsonFormattedSpy.count(), 1);
    
    // Verify JSON was minified (should be compact)
    QString minifiedJson = m_app->jsonText();
    QVERIFY(!minifiedJson.contains('\n'));
    QVERIFY(!minifiedJson.contains("  ")); // Should not have indentation
    
    // Test minifying invalid JSON
    QString invalidJson = "invalid json";
    m_app->minifyJSON(invalidJson);
    QVERIFY(!m_app->errorMessage().isEmpty());
}

QTEST_MAIN(TestApplication)
#include "test_application.moc"
