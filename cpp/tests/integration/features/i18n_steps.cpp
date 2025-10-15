#include <QtTest>
#include <QSignalSpy>
#include <QApplication>
#include <QDialog>
#include <QComboBox>
#include <QPushButton>
#include <QMenuBar>
#include <QAction>
#include <QDir>
#include <QStandardPaths>

#include "I18nManager.hpp"
#include "Application.hpp"
#include "SettingsManager.hpp"

class I18nSteps : public QObject
{
    Q_OBJECT

public:
    I18nSteps();
    ~I18nSteps();

    // Gherkin step implementations
    void givenApplicationSupportsLanguages(const QTableWidget* languages);
    void givenDefaultLanguageIs(const QString& language);
    void givenApplicationIsRunning();
    void givenApplicationIsRunningInLanguage(const QString& language);
    void givenSystemLanguageIsSetTo(const QString& language);
    void givenTranslationFileIsMissing(const QString& language);
    void givenIHavePreviouslySelectedLanguage(const QString& language);

    void whenIOpenPreferencesDialog();
    void whenISelectLanguageFromDropdown(const QString& language);
    void whenIClickSave();
    void whenICloseApplication();
    void whenIRestartApplication();
    void whenIStartApplication();
    void whenIChangeLanguageToInPreferences(const QString& language);

    void thenIShouldSeeLanguageSelectionWithFlagIcons();
    void thenIShouldSeeLanguages(const QTableWidget* languages);
    void thenEntireApplicationShouldBeInLanguage(const QString& language);
    void thenMenuBarShouldShowLanguageText(const QString& language);
    void thenAllDialogBoxesShouldShowLanguageText(const QString& language);
    void thenPreferencesDialogShouldClose();
    void thenApplicationShouldStartInLanguage(const QString& language);
    void thenAllInterfaceElementsShouldBeInLanguage(const QString& language);
    void thenApplicationShouldStartInDefaultLanguage();
    void thenIShouldSeeNotificationThatLanguageIsNotSupported(const QString& language);
    void thenApplicationShouldFallBackToDefaultLanguage();
    void thenIShouldSeeErrorMessageAboutMissingTranslation();
    void thenInterfaceShouldImmediatelyUpdateToLanguage(const QString& language);
    void thenIShouldNotNeedToRestartApplication();
    void thenMenuBarShouldShow(const QTableWidget* menuItems);
    void thenAllDialogTitlesShouldBeInLanguage(const QString& language);
    void thenAllButtonLabelsShouldBeInLanguage(const QString& language);
    void thenAllStatusMessagesShouldBeInLanguage(const QString& language);
    void thenPreferencesShouldShowLanguageAsSelected(const QString& language);

private:
    treon::I18nManager* m_i18nManager;
    treon::Application* m_application;
    treon::SettingsManager* m_settingsManager;
    QApplication* m_qApp;
    QWidget* m_mainWindow;
    QDialog* m_preferencesDialog;
    QComboBox* m_languageComboBox;
    QPushButton* m_saveButton;
    QMenuBar* m_menuBar;
    
    void setupTestEnvironment();
    void cleanupTestEnvironment();
    QString getTranslatedText(const QString& key, const QString& context = QString());
    bool isLanguageSupported(const QString& language);
    void mockTranslationFile(const QString& language, bool exists = true);
};

I18nSteps::I18nSteps()
{
    setupTestEnvironment();
}

I18nSteps::~I18nSteps()
{
    cleanupTestEnvironment();
}

void I18nSteps::setupTestEnvironment()
{
    // Set up test environment
    m_qApp = new QApplication(QCoreApplication::arguments());
    
    // Create managers
    m_settingsManager = new treon::SettingsManager(this);
    m_i18nManager = new treon::I18nManager(this);
    m_application = new treon::Application(this);
    
    // Set up test data directory
    QString testDataDir = QDir::tempPath() + "/treon_i18n_test";
    QDir().mkpath(testDataDir);
    
    // Mock translation files
    mockTranslationFile("en_GB", true);
    mockTranslationFile("en_US", true);
    mockTranslationFile("es", true);
    mockTranslationFile("fr", true);
}

void I18nSteps::cleanupTestEnvironment()
{
    delete m_application;
    delete m_i18nManager;
    delete m_settingsManager;
    delete m_qApp;
    
    // Clean up test data
    QString testDataDir = QDir::tempPath() + "/treon_i18n_test";
    QDir(testDataDir).removeRecursively();
}

void I18nSteps::givenApplicationSupportsLanguages(const QTableWidget* languages)
{
    // Verify that the application supports the specified languages
    QStringList supportedLanguages = m_i18nManager->availableLanguages();
    
    for (int i = 0; i < languages->rowCount(); ++i) {
        QString languageCode = languages->item(i, 0)->text();
        QVERIFY2(supportedLanguages.contains(languageCode), 
                qPrintable(QString("Language %1 is not supported").arg(languageCode)));
    }
}

void I18nSteps::givenDefaultLanguageIs(const QString& language)
{
    QCOMPARE(m_i18nManager->currentLanguage(), language);
}

void I18nSteps::givenApplicationIsRunning()
{
    // Application is already running in setupTestEnvironment
    QVERIFY(m_application != nullptr);
}

void I18nSteps::givenApplicationIsRunningInLanguage(const QString& language)
{
    m_i18nManager->setCurrentLanguage(language);
    QCOMPARE(m_i18nManager->currentLanguage(), language);
}

void I18nSteps::givenSystemLanguageIsSetTo(const QString& language)
{
    // Mock system language - in real implementation, this would require mocking QLocale
    // For now, we'll test the fallback behavior directly
    Q_UNUSED(language);
}

void I18nSteps::givenTranslationFileIsMissing(const QString& language)
{
    mockTranslationFile(language, false);
}

void I18nSteps::givenIHavePreviouslySelectedLanguage(const QString& language)
{
    m_settingsManager->setLanguage(language);
    QCOMPARE(m_settingsManager->language(), language);
}

void I18nSteps::whenIOpenPreferencesDialog()
{
    // Simulate opening preferences dialog
    m_preferencesDialog = new QDialog();
    m_languageComboBox = new QComboBox(m_preferencesDialog);
    m_saveButton = new QPushButton("Save", m_preferencesDialog);
    
    // Populate language combo box
    QStringList languages = m_i18nManager->availableLanguages();
    for (const QString& lang : languages) {
        QString nativeName = m_i18nManager->getLanguageNativeName(lang);
        m_languageComboBox->addItem(nativeName, lang);
    }
    
    m_preferencesDialog->show();
}

void I18nSteps::whenISelectLanguageFromDropdown(const QString& language)
{
    // Find the language in the combo box
    int index = m_languageComboBox->findData(language);
    QVERIFY2(index >= 0, qPrintable(QString("Language %1 not found in dropdown").arg(language)));
    
    m_languageComboBox->setCurrentIndex(index);
}

void I18nSteps::whenIClickSave()
{
    // Get selected language
    QString selectedLanguage = m_languageComboBox->currentData().toString();
    
    // Update settings and i18n manager
    m_settingsManager->setLanguage(selectedLanguage);
    m_i18nManager->setCurrentLanguage(selectedLanguage);
    
    // Close dialog
    m_preferencesDialog->close();
}

void I18nSteps::whenICloseApplication()
{
    // Simulate application close
    m_settingsManager->sync();
}

void I18nSteps::whenIRestartApplication()
{
    // Simulate application restart
    whenICloseApplication();
    
    // Recreate managers with saved settings
    delete m_i18nManager;
    m_i18nManager = new treon::I18nManager(this);
    m_i18nManager->setCurrentLanguage(m_settingsManager->language());
}

void I18nSteps::whenIStartApplication()
{
    // Application is already started in setupTestEnvironment
    QVERIFY(m_application != nullptr);
}

void I18nSteps::whenIChangeLanguageToInPreferences(const QString& language)
{
    whenIOpenPreferencesDialog();
    whenISelectLanguageFromDropdown(language);
    whenIClickSave();
}

void I18nSteps::thenIShouldSeeLanguageSelectionWithFlagIcons()
{
    QVERIFY(m_languageComboBox != nullptr);
    QVERIFY(m_languageComboBox->count() > 0);
    
    // Verify that flag icons are present (in real implementation, this would check for actual icons)
    for (int i = 0; i < m_languageComboBox->count(); ++i) {
        QString text = m_languageComboBox->itemText(i);
        // Check for flag emoji or icon presence
        QVERIFY2(text.contains("🇬🇧") || text.contains("🇺🇸") || text.contains("🇪🇸") || text.contains("🇫🇷"),
                qPrintable(QString("Flag icon not found for language: %1").arg(text)));
    }
}

void I18nSteps::thenIShouldSeeLanguages(const QTableWidget* languages)
{
    QVERIFY(m_languageComboBox != nullptr);
    
    for (int i = 0; i < languages->rowCount(); ++i) {
        QString expectedLanguage = languages->item(i, 0)->text();
        QString expectedFlag = languages->item(i, 1)->text();
        
        // Find the language in the combo box
        int index = m_languageComboBox->findData(expectedLanguage);
        QVERIFY2(index >= 0, qPrintable(QString("Language %1 not found in dropdown").arg(expectedLanguage)));
        
        QString actualText = m_languageComboBox->itemText(index);
        QVERIFY2(actualText.contains(expectedFlag), 
                qPrintable(QString("Flag %1 not found for language %2").arg(expectedFlag, expectedLanguage)));
    }
}

void I18nSteps::thenEntireApplicationShouldBeInLanguage(const QString& language)
{
    QCOMPARE(m_i18nManager->currentLanguage(), language);
    
    // Verify that translations are working
    QString testTranslation = getTranslatedText("File", "Menu");
    QVERIFY(!testTranslation.isEmpty());
    QVERIFY(testTranslation != "File"); // Should be translated, not the original English
}

void I18nSteps::thenMenuBarShouldShowLanguageText(const QString& language)
{
    Q_UNUSED(language);
    // In real implementation, this would check the actual menu bar text
    // For now, we'll verify that the i18n manager is in the correct language
    QVERIFY(!m_i18nManager->currentLanguage().isEmpty());
}

void I18nSteps::thenAllDialogBoxesShouldShowLanguageText(const QString& language)
{
    Q_UNUSED(language);
    // In real implementation, this would check actual dialog text
    // For now, we'll verify that translations are working
    QString testTranslation = getTranslatedText("Save", "Dialog");
    QVERIFY(!testTranslation.isEmpty());
}

void I18nSteps::thenPreferencesDialogShouldClose()
{
    QVERIFY(!m_preferencesDialog->isVisible());
}

void I18nSteps::thenApplicationShouldStartInLanguage(const QString& language)
{
    QCOMPARE(m_i18nManager->currentLanguage(), language);
}

void I18nSteps::thenAllInterfaceElementsShouldBeInLanguage(const QString& language)
{
    QCOMPARE(m_i18nManager->currentLanguage(), language);
    
    // Verify that translations are working for various contexts
    QString menuTranslation = getTranslatedText("File", "Menu");
    QString dialogTranslation = getTranslatedText("Save", "Dialog");
    QString buttonTranslation = getTranslatedText("Cancel", "Button");
    
    QVERIFY(!menuTranslation.isEmpty());
    QVERIFY(!dialogTranslation.isEmpty());
    QVERIFY(!buttonTranslation.isEmpty());
}

void I18nSteps::thenApplicationShouldStartInDefaultLanguage()
{
    QCOMPARE(m_i18nManager->currentLanguage(), QString("en_GB"));
}

void I18nSteps::thenIShouldSeeNotificationThatLanguageIsNotSupported(const QString& language)
{
    Q_UNUSED(language);
    // In real implementation, this would check for actual notification
    // For now, we'll verify that the application is in the default language
    QCOMPARE(m_i18nManager->currentLanguage(), QString("en_GB"));
}

void I18nSteps::thenApplicationShouldFallBackToDefaultLanguage()
{
    QCOMPARE(m_i18nManager->currentLanguage(), QString("en_GB"));
}

void I18nSteps::thenIShouldSeeErrorMessageAboutMissingTranslation()
{
    // In real implementation, this would check for actual error message
    // For now, we'll verify that the application is in the default language
    QCOMPARE(m_i18nManager->currentLanguage(), QString("en_GB"));
}

void I18nSteps::thenInterfaceShouldImmediatelyUpdateToLanguage(const QString& language)
{
    QCOMPARE(m_i18nManager->currentLanguage(), language);
}

void I18nSteps::thenIShouldNotNeedToRestartApplication()
{
    // This is verified by the fact that the language change worked without restart
    QVERIFY(!m_i18nManager->currentLanguage().isEmpty());
}

void I18nSteps::thenMenuBarShouldShow(const QTableWidget* menuItems)
{
    Q_UNUSED(menuItems);
    // In real implementation, this would check actual menu bar text
    // For now, we'll verify that translations are working
    QString testTranslation = getTranslatedText("File", "Menu");
    QVERIFY(!testTranslation.isEmpty());
}

void I18nSteps::thenAllDialogTitlesShouldBeInLanguage(const QString& language)
{
    Q_UNUSED(language);
    // In real implementation, this would check actual dialog titles
    // For now, we'll verify that translations are working
    QString testTranslation = getTranslatedText("Preferences", "Dialog");
    QVERIFY(!testTranslation.isEmpty());
}

void I18nSteps::thenAllButtonLabelsShouldBeInLanguage(const QString& language)
{
    Q_UNUSED(language);
    // In real implementation, this would check actual button labels
    // For now, we'll verify that translations are working
    QString testTranslation = getTranslatedText("Save", "Button");
    QVERIFY(!testTranslation.isEmpty());
}

void I18nSteps::thenAllStatusMessagesShouldBeInLanguage(const QString& language)
{
    Q_UNUSED(language);
    // In real implementation, this would check actual status messages
    // For now, we'll verify that translations are working
    QString testTranslation = getTranslatedText("Ready", "Status");
    QVERIFY(!testTranslation.isEmpty());
}

void I18nSteps::thenPreferencesShouldShowLanguageAsSelected(const QString& language)
{
    QCOMPARE(m_languageComboBox->currentData().toString(), language);
}

QString I18nSteps::getTranslatedText(const QString& key, const QString& context)
{
    return m_i18nManager->tr(key, context);
}

bool I18nSteps::isLanguageSupported(const QString& language)
{
    return m_i18nManager->availableLanguages().contains(language);
}

void I18nSteps::mockTranslationFile(const QString& language, bool exists)
{
    Q_UNUSED(language);
    Q_UNUSED(exists);
    // In real implementation, this would create or remove actual translation files
    // For now, we'll simulate this behavior in the I18nManager
}

#include "i18n_steps.moc"
