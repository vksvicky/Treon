#include <QtTest>
#include <QSignalSpy>
#include <QUrl>

#include "treon/Application.h"

class TestApplication : public QObject
{
    Q_OBJECT

private slots:
    void initTestCase();
    void cleanupTestCase();
    void testInitialState();
    void testOpenInvalidFile();
    void testValidateJSON();

private:
    treon::Application *m_app;
};

void TestApplication::initTestCase()
{
    m_app = new treon::Application(this);
}

void TestApplication::cleanupTestCase()
{
    delete m_app;
}

void TestApplication::testInitialState()
{
    QCOMPARE(m_app->currentFile(), QString(""));
    QCOMPARE(m_app->isLoading(), false);
    QCOMPARE(m_app->errorMessage(), QString(""));
}

void TestApplication::testOpenInvalidFile()
{
    QSignalSpy errorSpy(m_app, &treon::Application::errorMessageChanged);
    
    // Test with non-existent file
    QUrl invalidUrl("file:///nonexistent/file.json");
    m_app->openFile(invalidUrl);
    
    QVERIFY(errorSpy.count() > 0);
    QVERIFY(!m_app->errorMessage().isEmpty());
}

void TestApplication::testValidateJSON()
{
    QSignalSpy validSpy(m_app, &treon::Application::jsonValidated);
    
    // Test valid JSON
    m_app->validateJSON("{\"test\": 123}");
    QCOMPARE(validSpy.count(), 1);
    QCOMPARE(validSpy.takeFirst().at(0).toBool(), true);
    
    // Test invalid JSON
    m_app->validateJSON("invalid json");
    QCOMPARE(validSpy.count(), 1);
    QCOMPARE(validSpy.takeFirst().at(0).toBool(), false);
}

QTEST_MAIN(TestApplication)
#include "test_application.moc"
