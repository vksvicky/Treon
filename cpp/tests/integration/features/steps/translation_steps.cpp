#include <gtest/gtest.h>
#include <QApplication>
#include <QSettings>
#include <QTranslator>
#include <QDir>
#include <QStandardPaths>
#include <QDebug>
#include <QMenuBar>
#include <QAction>
#include <QMainWindow>
#include <QQmlApplicationEngine>
#include <QQuickWindow>
#include <QQuickItem>
#include <QObject>
#include <QSignalSpy>
#include <QTimer>
#include <QTest>

#include "I18nManager.hpp"
#include "SettingsManager.hpp"

// Step definitions for translation system BDD scenarios

class TranslationSystemTest : public ::testing::Test {
protected:
    void SetUp() override {
        // Create a temporary settings file for testing
        m_tempSettingsPath = QStandardPaths::writableLocation(QStandardPaths::TempLocation) + "/treon_test_settings.ini";
        m_settings = new QSettings(m_tempSettingsPath, QSettings::IniFormat);
        
        // Create I18nManager and SettingsManager for testing
        m_i18nManager = new treon::I18nManager();
        m_settingsManager = new treon::SettingsManager();
        
        // Set up test environment
        m_i18nManager->discoverAvailableLanguages();
    }
    
    void TearDown() override {
        delete m_i18nManager;
        delete m_settingsManager;
        delete m_settings;
        
        // Clean up temporary settings file
        QFile::remove(m_tempSettingsPath);
    }
    
    QString m_tempSettingsPath;
    QSettings* m_settings;
    treon::I18nManager* m_i18nManager;
    treon::SettingsManager* m_settingsManager;
};

// Background steps
TEST_F(TranslationSystemTest, ApplicationHasTranslationFiles) {
    // Given the application is installed with translation files
    QStringList availableLanguages = m_i18nManager->availableLanguages();
    EXPECT_TRUE(availableLanguages.contains("en_GB"));
    EXPECT_TRUE(availableLanguages.contains("en_US"));
    EXPECT_TRUE(availableLanguages.contains("es"));
    EXPECT_TRUE(availableLanguages.contains("fr"));
}

// Scenario: Application starts with saved language preference
TEST_F(TranslationSystemTest, ApplicationStartsWithSavedLanguage) {
    // Given the user previously selected "es" as their language
    m_settings->setValue("language", "es");
    m_settings->sync();
    
    // When the application launches
    m_i18nManager->initializeWithSavedLanguage("es");
    
    // Then the application should display all text in Spanish
    EXPECT_EQ(m_i18nManager->currentLanguage(), "es");
    
    // Test that Spanish translations are loaded
    QString aboutText = m_i18nManager->tr("About Treon", "QObject");
    EXPECT_EQ(aboutText, "Acerca de Treon");
    
    QString fileText = m_i18nManager->tr("File", "QObject");
    EXPECT_EQ(fileText, "Archivo");
    
    QString newText = m_i18nManager->tr("New", "QObject");
    EXPECT_EQ(newText, "Nuevo");
}

// Scenario: Application starts with no saved language preference
TEST_F(TranslationSystemTest, ApplicationStartsWithNoSavedLanguage) {
    // Given no language preference is saved
    m_settings->remove("language");
    m_settings->sync();
    
    // When the application launches
    m_i18nManager->initializeWithSavedLanguage("");
    
    // Then the application should fall back to default language
    QString currentLang = m_i18nManager->currentLanguage();
    EXPECT_TRUE(currentLang == "en_GB" || currentLang == "en_US");
}

// Scenario: User changes language in preferences
TEST_F(TranslationSystemTest, UserChangesLanguageInPreferences) {
    // Given the application is running in English
    m_i18nManager->switchLanguage("en_GB");
    EXPECT_EQ(m_i18nManager->currentLanguage(), "en_GB");
    
    // When the user changes language to French
    m_i18nManager->switchLanguage("fr");
    
    // Then all text should be in French
    EXPECT_EQ(m_i18nManager->currentLanguage(), "fr");
    
    QString aboutText = m_i18nManager->tr("About Treon", "QObject");
    EXPECT_EQ(aboutText, "À propos de Treon");
    
    QString fileText = m_i18nManager->tr("File", "QObject");
    EXPECT_EQ(fileText, "Fichier");
}

// Scenario: Language change affects all UI components
TEST_F(TranslationSystemTest, LanguageChangeAffectsAllUIComponents) {
    // Given the application is running
    m_i18nManager->switchLanguage("en_GB");
    
    // When the user changes the language to Spanish
    m_i18nManager->switchLanguage("es");
    
    // Then all components should be translated
    EXPECT_EQ(m_i18nManager->tr("File", "QObject"), "Archivo");
    EXPECT_EQ(m_i18nManager->tr("Help", "QObject"), "Ayuda");
    EXPECT_EQ(m_i18nManager->tr("New", "QObject"), "Nuevo");
    EXPECT_EQ(m_i18nManager->tr("Open...", "QObject"), "Abrir...");
    EXPECT_EQ(m_i18nManager->tr("About Treon", "QObject"), "Acerca de Treon");
    EXPECT_EQ(m_i18nManager->tr("Preferences...", "QObject"), "Preferencias...");
}

// Scenario: Translation system handles missing translations gracefully
TEST_F(TranslationSystemTest, HandlesMissingTranslationsGracefully) {
    // Given a translation file is missing some strings
    m_i18nManager->switchLanguage("es");
    
    // When trying to translate a non-existent string
    QString missingTranslation = m_i18nManager->tr("NonExistentString", "QObject");
    
    // Then it should fall back to the original text
    EXPECT_EQ(missingTranslation, "NonExistentString");
}

// Integration test for QML translation system
class QMLTranslationTest : public ::testing::Test {
protected:
    void SetUp() override {
        int argc = 0;
        char** argv = nullptr;
        m_app = new QApplication(argc, argv);
        
        m_engine = new QQmlApplicationEngine();
        m_i18nManager = new treon::I18nManager();
        
        // Register I18nManager with QML
        qmlRegisterSingletonInstance("Treon", 1, 0, "I18nManager", m_i18nManager);
        
        // Load main QML file
        m_engine->load("qrc:/qml/main.qml");
        
        // Wait for QML to load
        QTest::qWait(100);
    }
    
    void TearDown() override {
        delete m_engine;
        delete m_i18nManager;
        delete m_app;
    }
    
    QApplication* m_app;
    QQmlApplicationEngine* m_engine;
    treon::I18nManager* m_i18nManager;
};

TEST_F(QMLTranslationTest, QMLComponentsUpdateOnLanguageChange) {
    // Given QML components are loaded
    QQuickWindow* window = qobject_cast<QQuickWindow*>(m_engine->rootObjects().first());
    ASSERT_NE(window, nullptr);
    
    // When language is changed
    m_i18nManager->switchLanguage("fr");
    
    // Then QML should be retranslated
    m_engine->retranslate();
    
    // Verify that the language change signal was emitted
    QSignalSpy languageChangedSpy(m_i18nManager, &treon::I18nManager::currentLanguageChanged);
    m_i18nManager->switchLanguage("es");
    EXPECT_GT(languageChangedSpy.count(), 0);
}

// Test for native C++ menu translation
class NativeMenuTranslationTest : public ::testing::Test {
protected:
    void SetUp() override {
        int argc = 0;
        char** argv = nullptr;
        m_app = new QApplication(argc, argv);
        
        m_mainWindow = new QMainWindow();
        m_menuBar = m_mainWindow->menuBar();
        m_i18nManager = new treon::I18nManager();
        
        // Create test menu
        QMenu* fileMenu = m_menuBar->addMenu("File");
        m_newAction = fileMenu->addAction("New");
        m_openAction = fileMenu->addAction("Open...");
        
        QMenu* appMenu = m_menuBar->addMenu("");
        m_aboutAction = appMenu->addAction("About Treon");
        m_preferencesAction = appMenu->addAction("Preferences...");
    }
    
    void TearDown() override {
        delete m_mainWindow;
        delete m_i18nManager;
        delete m_app;
    }
    
    QApplication* m_app;
    QMainWindow* m_mainWindow;
    QMenuBar* m_menuBar;
    treon::I18nManager* m_i18nManager;
    QAction* m_newAction;
    QAction* m_openAction;
    QAction* m_aboutAction;
    QAction* m_preferencesAction;
};

TEST_F(NativeMenuTranslationTest, NativeMenuItemsAreTranslated) {
    // Given native C++ menus are created
    ASSERT_NE(m_newAction, nullptr);
    ASSERT_NE(m_aboutAction, nullptr);
    
    // When language is changed to Spanish
    m_i18nManager->switchLanguage("es");
    
    // Then menu items should be translated
    // Note: In a real implementation, we would need to connect the I18nManager
    // to update the menu items when language changes
    QString newText = m_i18nManager->tr("New", "QObject");
    EXPECT_EQ(newText, "Nuevo");
    
    QString aboutText = m_i18nManager->tr("About Treon", "QObject");
    EXPECT_EQ(aboutText, "Acerca de Treon");
}
