#include <QtTest>
#include <QSignalSpy>
#include <QTranslator>
#include <QCoreApplication>
#include <QDir>
#include <QStandardPaths>
#include <QApplication>
#include <QTest>
#include <QSettings>

#include "I18nManager.hpp"
#include "SettingsManager.hpp"

class TestTranslationSystem : public QObject
{
    Q_OBJECT

private slots:
    void initTestCase();
    void cleanupTestCase();
    void init();
    void cleanup();
    
    // Test that I18nManager discovers available languages correctly
    void testDiscoversAvailableLanguages();
    
    // Test that language switching works correctly
    void testLanguageSwitchingWorks();
    
    // Test that translations are loaded correctly for each language
    void testTranslationsAreLoadedCorrectly();
    
    // Test that language change signals are emitted
    void testLanguageChangeSignalsAreEmitted();
    
    // Test that unsupported languages are handled gracefully
    void testUnsupportedLanguagesAreHandledGracefully();
    
    // Test that initializeWithSavedLanguage works correctly
    void testInitializeWithSavedLanguageWorks();
    
    // Test that translation context works correctly
    void testTranslationContextWorks();
    
    // Test that missing translations fall back to original text
    void testMissingTranslationsFallBackToOriginal();
    
    // Test that language names are returned correctly
    void testLanguageNamesAreReturnedCorrectly();
    
    // Test that native language names are returned correctly
    void testNativeLanguageNamesAreReturnedCorrectly();
    
    // Test that language support detection works
    void testLanguageSupportDetectionWorks();
    
    // Test that translation reloading works
    void testTranslationReloadingWorks();

private:
    QString m_tempSettingsPath;
    QSettings* m_settings;
    treon::I18nManager* m_i18nManager;
};

void TestTranslationSystem::initTestCase()
{
    // Set up test environment
}

void TestTranslationSystem::cleanupTestCase()
{
    // Clean up test environment
}

void TestTranslationSystem::init()
{
    // Create a temporary settings file for testing
    m_tempSettingsPath = QStandardPaths::writableLocation(QStandardPaths::TempLocation) + "/treon_test_settings.ini";
    m_settings = new QSettings(m_tempSettingsPath, QSettings::IniFormat);
    
    // Create I18nManager for testing
    m_i18nManager = new treon::I18nManager();
    
    // Set up test environment
    m_i18nManager->discoverAvailableLanguages();
}

void TestTranslationSystem::cleanup()
{
    delete m_i18nManager;
    delete m_settings;
    
    // Clean up temporary settings file
    QFile::remove(m_tempSettingsPath);
}

void TestTranslationSystem::testDiscoversAvailableLanguages()
{
    QStringList languages = m_i18nManager->availableLanguages();
    
    QVERIFY(languages.contains("en_GB"));
    QVERIFY(languages.contains("en_US"));
    QVERIFY(languages.contains("es"));
    QVERIFY(languages.contains("fr"));
    QVERIFY(languages.size() >= 4);
}

void TestTranslationSystem::testLanguageSwitchingWorks()
{
    // Start with English
    m_i18nManager->switchLanguage("en_GB");
    QCOMPARE(m_i18nManager->currentLanguage(), QString("en_GB"));
    
    // Switch to Spanish
    m_i18nManager->switchLanguage("es");
    QCOMPARE(m_i18nManager->currentLanguage(), QString("es"));
    
    // Switch to French
    m_i18nManager->switchLanguage("fr");
    QCOMPARE(m_i18nManager->currentLanguage(), QString("fr"));
}

void TestTranslationSystem::testTranslationsAreLoadedCorrectly()
{
    // Test English translations
    m_i18nManager->switchLanguage("en_GB");
    QCOMPARE(m_i18nManager->tr("About Treon", "QObject"), QString("About Treon"));
    QCOMPARE(m_i18nManager->tr("File", "QObject"), QString("File"));
    QCOMPARE(m_i18nManager->tr("New", "QObject"), QString("New"));
    
    // Test Spanish translations
    m_i18nManager->switchLanguage("es");
    QCOMPARE(m_i18nManager->tr("About Treon", "QObject"), QString("Acerca de Treon"));
    QCOMPARE(m_i18nManager->tr("File", "QObject"), QString("Archivo"));
    QCOMPARE(m_i18nManager->tr("New", "QObject"), QString("Nuevo"));
    
    // Test French translations
    m_i18nManager->switchLanguage("fr");
    QCOMPARE(m_i18nManager->tr("About Treon", "QObject"), QString("À propos de Treon"));
    QCOMPARE(m_i18nManager->tr("File", "QObject"), QString("Fichier"));
    QCOMPARE(m_i18nManager->tr("New", "QObject"), QString("Nouveau"));
}

void TestTranslationSystem::testLanguageChangeSignalsAreEmitted()
{
    QSignalSpy languageChangedSpy(m_i18nManager, &treon::I18nManager::currentLanguageChanged);
    QSignalSpy languageChangedWithValueSpy(m_i18nManager, &treon::I18nManager::languageChanged);
    
    // Change language
    m_i18nManager->switchLanguage("es");
    
    // Check that signals were emitted
    QCOMPARE(languageChangedSpy.count(), 1);
    QCOMPARE(languageChangedWithValueSpy.count(), 1);
    
    // Check the signal value
    QList<QVariant> arguments = languageChangedWithValueSpy.takeFirst();
    QCOMPARE(arguments.at(0).toString(), QString("es"));
}

void TestTranslationSystem::testUnsupportedLanguagesAreHandledGracefully()
{
    QString originalLanguage = m_i18nManager->currentLanguage();
    
    // Try to switch to an unsupported language
    m_i18nManager->switchLanguage("unsupported_lang");
    
    // Should remain on the original language
    QCOMPARE(m_i18nManager->currentLanguage(), originalLanguage);
}

void TestTranslationSystem::testInitializeWithSavedLanguageWorks()
{
    // Test with a valid saved language
    m_i18nManager->initializeWithSavedLanguage("es");
    QCOMPARE(m_i18nManager->currentLanguage(), QString("es"));
    
    // Test with an invalid saved language
    m_i18nManager->initializeWithSavedLanguage("invalid_lang");
    // Should fall back to system language or default
    QString currentLang = m_i18nManager->currentLanguage();
    QVERIFY(currentLang == "en_GB" || currentLang == "en_US");
    
    // Test with empty saved language
    m_i18nManager->initializeWithSavedLanguage("");
    // Should fall back to system language or default
    currentLang = m_i18nManager->currentLanguage();
    QVERIFY(currentLang == "en_GB" || currentLang == "en_US");
}

void TestTranslationSystem::testTranslationContextWorks()
{
    m_i18nManager->switchLanguage("es");
    
    // Test with different contexts
    QString aboutText = m_i18nManager->tr("About Treon", "QObject");
    QCOMPARE(aboutText, QString("Acerca de Treon"));
    
    // Test with empty context (should default to QObject)
    QString fileText = m_i18nManager->tr("File");
    QCOMPARE(fileText, QString("Archivo"));
}

void TestTranslationSystem::testMissingTranslationsFallBackToOriginal()
{
    m_i18nManager->switchLanguage("es");
    
    // Test with a non-existent translation
    QString missingTranslation = m_i18nManager->tr("NonExistentString", "QObject");
    QCOMPARE(missingTranslation, QString("NonExistentString"));
    
    // Test with empty string
    QString emptyTranslation = m_i18nManager->tr("", "QObject");
    QCOMPARE(emptyTranslation, QString(""));
}

void TestTranslationSystem::testLanguageNamesAreReturnedCorrectly()
{
    // Test English language name
    QString englishName = m_i18nManager->getLanguageName("en_GB");
    QCOMPARE(englishName, QString("English (UK)"));
    
    // Test Spanish language name
    QString spanishName = m_i18nManager->getLanguageName("es");
    QCOMPARE(spanishName, QString("Spanish"));
    
    // Test French language name
    QString frenchName = m_i18nManager->getLanguageName("fr");
    QCOMPARE(frenchName, QString("French"));
}

void TestTranslationSystem::testNativeLanguageNamesAreReturnedCorrectly()
{
    // Test Spanish native name
    QString spanishNativeName = m_i18nManager->getLanguageNativeName("es");
    QCOMPARE(spanishNativeName, QString("Español"));
    
    // Test French native name
    QString frenchNativeName = m_i18nManager->getLanguageNativeName("fr");
    QCOMPARE(frenchNativeName, QString("Français"));
}

void TestTranslationSystem::testLanguageSupportDetectionWorks()
{
    // Test supported languages
    QVERIFY(m_i18nManager->isLanguageSupported("en_GB"));
    QVERIFY(m_i18nManager->isLanguageSupported("en_US"));
    QVERIFY(m_i18nManager->isLanguageSupported("es"));
    QVERIFY(m_i18nManager->isLanguageSupported("fr"));
    
    // Test unsupported languages
    QVERIFY(!m_i18nManager->isLanguageSupported("de"));
    QVERIFY(!m_i18nManager->isLanguageSupported("it"));
    QVERIFY(!m_i18nManager->isLanguageSupported("invalid_lang"));
}

void TestTranslationSystem::testTranslationReloadingWorks()
{
    // Set initial language
    m_i18nManager->switchLanguage("es");
    QCOMPARE(m_i18nManager->currentLanguage(), QString("es"));
    
    // Reload translations
    m_i18nManager->reloadTranslations();
    
    // Should still be in Spanish
    QCOMPARE(m_i18nManager->currentLanguage(), QString("es"));
    
    // Translations should still work
    QCOMPARE(m_i18nManager->tr("File", "QObject"), QString("Archivo"));
}

// Test SettingsManager language persistence
class TestSettingsManagerTranslation : public QObject
{
    Q_OBJECT

private slots:
    void initTestCase();
    void cleanupTestCase();
    void init();
    void cleanup();
    
    void testLanguagePersistenceWorks();
    void testDefaultLanguageIsSet();

private:
    QString m_tempSettingsPath;
    treon::SettingsManager* m_settingsManager;
};

void TestSettingsManagerTranslation::initTestCase()
{
    // Set up test environment
}

void TestSettingsManagerTranslation::cleanupTestCase()
{
    // Clean up test environment
}

void TestSettingsManagerTranslation::init()
{
    m_tempSettingsPath = QStandardPaths::writableLocation(QStandardPaths::TempLocation) + "/treon_settings_test.ini";
    m_settingsManager = new treon::SettingsManager();
}

void TestSettingsManagerTranslation::cleanup()
{
    delete m_settingsManager;
    QFile::remove(m_tempSettingsPath);
}

void TestSettingsManagerTranslation::testLanguagePersistenceWorks()
{
    // Set language
    m_settingsManager->setLanguage("fr");
    QCOMPARE(m_settingsManager->language(), QString("fr"));
    
    // Create new SettingsManager instance (simulating app restart)
    delete m_settingsManager;
    m_settingsManager = new treon::SettingsManager();
    
    // Language should be persisted
    QCOMPARE(m_settingsManager->language(), QString("fr"));
}

void TestSettingsManagerTranslation::testDefaultLanguageIsSet()
{
    // Test default language
    QString defaultLang = m_settingsManager->language();
    QVERIFY(defaultLang == "en_GB" || defaultLang == "en_US");
}

QTEST_MAIN(TestTranslationSystem)
#include "test_translation_system.moc"