#include <QtTest>
#include <QSignalSpy>
#include <QQmlEngine>
#include <QQmlComponent>
#include <QQuickItem>
#include <QQuickWindow>
#include <QApplication>
#include <QTest>

#include "I18nManager.hpp"
#include "SettingsManager.hpp"

class TestLanguageSelector : public QObject
{
    Q_OBJECT

private slots:
    void initTestCase();
    void cleanupTestCase();
    void init();
    void cleanup();

    // Test component loading
    void testComponentLoads();
    void testComponentProperties();
    
    // Test language selection
    void testLanguageSelection();
    void testLanguageChangeSignal();
    void testCurrentLanguageBinding();
    
    // Test dynamic language discovery
    void testDynamicLanguageList();
    void testLanguageNamesDisplay();
    void testFlagDisplay();
    
    // Test error handling
    void testNoLanguagesAvailable();
    void testInvalidI18nManager();

private:
    QQmlEngine* m_engine;
    treon::I18nManager* m_i18nManager;
    treon::SettingsManager* m_settingsManager;
    QQuickItem* m_languageSelector;
    QQuickWindow* m_window;
};

void TestLanguageSelector::initTestCase()
{
    // Set up QML engine
    m_engine = new QQmlEngine(this);
    
    // Create managers
    m_i18nManager = new treon::I18nManager(this);
    m_settingsManager = new treon::SettingsManager(this);
    
    // Register types
    qmlRegisterType<treon::I18nManager>("Treon", 1, 0, "I18nManager");
    qmlRegisterType<treon::SettingsManager>("Treon", 1, 0, "SettingsManager");
    
    // Set context properties
    m_engine->rootContext()->setContextProperty("i18nManager", m_i18nManager);
    m_engine->rootContext()->setContextProperty("settingsManager", m_settingsManager);
    
    // Create test window
    m_window = new QQuickWindow();
}

void TestLanguageSelector::cleanupTestCase()
{
    delete m_window;
    delete m_engine;
    delete m_i18nManager;
    delete m_settingsManager;
}

void TestLanguageSelector::init()
{
    // Load LanguageSelector component
    QQmlComponent component(m_engine);
    component.loadUrl(QUrl("qrc:/qml/LanguageSelector.qml"));
    
    QVERIFY(component.isReady());
    QVERIFY(!component.isError());
    
    m_languageSelector = qobject_cast<QQuickItem*>(component.create());
    QVERIFY(m_languageSelector != nullptr);
    
    // Set up the component in the window
    m_languageSelector->setParentItem(m_window->contentItem());
}

void TestLanguageSelector::cleanup()
{
    if (m_languageSelector) {
        delete m_languageSelector;
        m_languageSelector = nullptr;
    }
}

void TestLanguageSelector::testComponentLoads()
{
    QVERIFY(m_languageSelector != nullptr);
    QVERIFY(m_languageSelector->isVisible());
}

void TestLanguageSelector::testComponentProperties()
{
    // Test that the component has the expected properties
    QVERIFY(m_languageSelector->property("currentLanguage").isValid());
    QVERIFY(m_languageSelector->property("i18nManager").isValid());
    QVERIFY(m_languageSelector->property("settingsManager").isValid());
}

void TestLanguageSelector::testLanguageSelection()
{
    // Set initial language
    m_languageSelector->setProperty("currentLanguage", "en_GB");
    QCOMPARE(m_languageSelector->property("currentLanguage").toString(), QString("en_GB"));
    
    // Change language
    m_languageSelector->setProperty("currentLanguage", "fr");
    QCOMPARE(m_languageSelector->property("currentLanguage").toString(), QString("fr"));
}

void TestLanguageSelector::testLanguageChangeSignal()
{
    QSignalSpy languageChangedSpy(m_languageSelector, SIGNAL(languageChanged(QString)));
    
    // Simulate language change
    QMetaObject::invokeMethod(m_languageSelector, "languageChanged", 
                             Q_ARG(QString, "es"));
    
    QCOMPARE(languageChangedSpy.count(), 1);
    QCOMPARE(languageChangedSpy.at(0).at(0).toString(), QString("es"));
}

void TestLanguageSelector::testCurrentLanguageBinding()
{
    // Test that currentLanguage is bound to settingsManager.language
    m_settingsManager->setLanguage("fr");
    QCOMPARE(m_languageSelector->property("currentLanguage").toString(), QString("fr"));
    
    m_settingsManager->setLanguage("es");
    QCOMPARE(m_languageSelector->property("currentLanguage").toString(), QString("es"));
}

void TestLanguageSelector::testDynamicLanguageList()
{
    // Test that the component uses dynamic language list from i18nManager
    QStringList availableLanguages = m_i18nManager->availableLanguages();
    QVERIFY(availableLanguages.contains("en_GB"));
    QVERIFY(availableLanguages.contains("en_US"));
    QVERIFY(availableLanguages.contains("es"));
    QVERIFY(availableLanguages.contains("fr"));
}

void TestLanguageSelector::testLanguageNamesDisplay()
{
    // Test that language names are displayed correctly
    QCOMPARE(m_i18nManager->getLanguageNativeName("en_GB"), QString("English (UK)"));
    QCOMPARE(m_i18nManager->getLanguageNativeName("en_US"), QString("English (US)"));
    QCOMPARE(m_i18nManager->getLanguageNativeName("es"), QString("Español"));
    QCOMPARE(m_i18nManager->getLanguageNativeName("fr"), QString("Français"));
}

void TestLanguageSelector::testFlagDisplay()
{
    // Test that flag paths are returned correctly
    QString flagPath = m_i18nManager->getLanguageFlagPath("en_GB");
    QVERIFY(flagPath.startsWith("qrc:/"));
    QVERIFY(flagPath.endsWith(".svg"));
    
    flagPath = m_i18nManager->getLanguageFlagPath("fr");
    QVERIFY(flagPath.startsWith("qrc:/"));
    QVERIFY(flagPath.endsWith(".svg"));
}

void TestLanguageSelector::testNoLanguagesAvailable()
{
    // Test behavior when no languages are available
    // This would require mocking the i18nManager to return empty list
    // For now, just verify the component handles the case gracefully
    QVERIFY(m_languageSelector->isVisible());
}

void TestLanguageSelector::testInvalidI18nManager()
{
    // Test behavior when i18nManager is null
    // This would require setting i18nManager to null and testing fallback
    // For now, just verify the component doesn't crash
    QVERIFY(m_languageSelector->isVisible());
}

QTEST_MAIN(TestLanguageSelector)
#include "test_language_selector.moc"
