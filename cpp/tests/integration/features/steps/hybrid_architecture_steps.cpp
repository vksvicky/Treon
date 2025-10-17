#include <QtTest>
#include <QApplication>
#include <QMainWindow>
#include <QMenuBar>
#include <QAction>
#include <QKeySequence>
#include <QQmlApplicationEngine>
#include <QWindow>
#include <QWidget>
#include <QMessageBox>
#include <QFileDialog>

#include "Application.hpp"
#include "SettingsManager.hpp"
#include "I18nManager.hpp"

class HybridArchitectureTest : public QObject
{
    Q_OBJECT

private slots:
    void initTestCase();
    void cleanupTestCase();
    void init();
    void cleanup();

    // Test scenarios
    void testNativeMenuBarIntegration();
    void testMenuShortcutsWork();
    void testMenuActionsCommunicateWithQML();
    void testPreferencesIntegration();
    void testAboutDialogIntegration();
    void testTranslationSystemIntegration();
    void testFileOperationsThroughNativeMenus();
    void testErrorHandling();

private:
    QApplication *m_app;
    QMainWindow *m_mainWindow;
    QMenuBar *m_menuBar;
    QQmlApplicationEngine *m_engine;
    QObject *m_rootObject;
    treon::SettingsManager *m_settingsManager;
    treon::I18nManager *m_i18nManager;
    
    // Helper methods
    void setupHybridArchitecture();
    void verifyMenuBarExists();
    void verifyMenuItemsExist();
    void simulateKeyPress(const QKeySequence &keySequence);
    void verifyQMLObjectExists(const QString &objectName);
    void verifyDialogOpens(const QString &dialogName);
};

void HybridArchitectureTest::initTestCase()
{
    // Initialize test environment
    int argc = 0;
    char **argv = nullptr;
    m_app = new QApplication(argc, argv);
    
    // Set application properties for testing
    m_app->setAttribute(Qt::AA_DontUseNativeMenuBar, false);
}

void HybridArchitectureTest::cleanupTestCase()
{
    delete m_app;
}

void HybridArchitectureTest::init()
{
    setupHybridArchitecture();
}

void HybridArchitectureTest::cleanup()
{
    if (m_engine) {
        delete m_engine;
        m_engine = nullptr;
    }
    if (m_mainWindow) {
        delete m_mainWindow;
        m_mainWindow = nullptr;
    }
    if (m_settingsManager) {
        delete m_settingsManager;
        m_settingsManager = nullptr;
    }
    if (m_i18nManager) {
        delete m_i18nManager;
        m_i18nManager = nullptr;
    }
}

void HybridArchitectureTest::setupHybridArchitecture()
{
    // Create main window with native menu bar
    m_mainWindow = new QMainWindow();
    m_mainWindow->setWindowTitle("Treon");
    m_mainWindow->resize(1200, 800);
    
    // Create native menu bar
    m_menuBar = new QMenuBar(m_mainWindow);
    
    // Application Menu (macOS style)
    QMenu *appMenu = m_menuBar->addMenu("");
    QAction *aboutAction = appMenu->addAction("About Treon");
    aboutAction->setMenuRole(QAction::AboutRole);
    appMenu->addSeparator();
    QAction *preferencesAction = appMenu->addAction("Preferences...");
    preferencesAction->setMenuRole(QAction::PreferencesRole);
    preferencesAction->setShortcut(QKeySequence::Preferences);
    appMenu->addSeparator();
    QAction *quitAction = appMenu->addAction("Quit Treon");
    quitAction->setMenuRole(QAction::QuitRole);
    quitAction->setShortcut(QKeySequence::Quit);
    
    // File Menu
    QMenu *fileMenu = m_menuBar->addMenu("File");
    QAction *newAction = fileMenu->addAction("New");
    newAction->setShortcut(QKeySequence::New);
    QAction *openAction = fileMenu->addAction("Open...");
    openAction->setShortcut(QKeySequence::Open);
    fileMenu->addSeparator();
    QAction *closeAction = fileMenu->addAction("Close");
    closeAction->setShortcut(QKeySequence::Close);
    QAction *saveAction = fileMenu->addAction("Save");
    saveAction->setShortcut(QKeySequence::Save);
    QAction *saveAsAction = fileMenu->addAction("Save As...");
    saveAsAction->setShortcut(QKeySequence::SaveAs);
    
    // Help Menu
    QMenu *helpMenu = m_menuBar->addMenu("Help");
    QAction *helpAction = helpMenu->addAction("Treon Help");
    helpAction->setShortcut(QKeySequence("F1"));
    
    m_mainWindow->setMenuBar(m_menuBar);
    
    // Initialize managers
    m_settingsManager = new treon::SettingsManager();
    m_i18nManager = new treon::I18nManager();
    
    // Create QML application engine
    m_engine = new QQmlApplicationEngine();
    m_engine->addImportPath("qrc:/qml");
    
    // Register QML types
    qmlRegisterType<treon::Application>("Treon", 1, 0, "Application");
    qmlRegisterType<treon::AboutWindow>("Treon", 1, 0, "AboutWindow");
    
    // Set QML context properties
    m_engine->rootContext()->setContextProperty("settingsManager", m_settingsManager);
    m_engine->rootContext()->setContextProperty("i18nManager", m_i18nManager);
    
    // Load main QML content
    const QUrl url(QStringLiteral("qrc:/qml/main.qml"));
    m_engine->load(url);
    
    // Get the QML window and embed it
    m_rootObject = m_engine->rootObjects().first();
    if (m_rootObject) {
        QWindow *qmlWindow = qobject_cast<QWindow*>(m_rootObject);
        if (qmlWindow) {
            QWidget *qmlWidget = QWidget::createWindowContainer(qmlWindow, m_mainWindow);
            m_mainWindow->setCentralWidget(qmlWidget);
        }
    }
    
    // Connect menu actions to QML (same as in main.cpp)
    QObject::connect(aboutAction, &QAction::triggered, [this]() {
        QObject *app = m_rootObject->findChild<QObject*>("app");
        if (app) {
            QMetaObject::invokeMethod(app, "showAbout");
        }
    });
    
    QObject::connect(preferencesAction, &QAction::triggered, [this]() {
        QObject *prefsDialog = m_rootObject->findChild<QObject*>("prefsDialog");
        if (prefsDialog) {
            QMetaObject::invokeMethod(prefsDialog, "show");
        }
    });
    
    QObject::connect(newAction, &QAction::triggered, [this]() {
        QObject *app = m_rootObject->findChild<QObject*>("app");
        if (app) {
            QMetaObject::invokeMethod(app, "newFile");
        }
    });
    
    QObject::connect(openAction, &QAction::triggered, [this]() {
        QObject *openDialog = m_rootObject->findChild<QObject*>("openDialog");
        if (openDialog) {
            QMetaObject::invokeMethod(openDialog, "open");
        }
    });
    
    QObject::connect(saveAction, &QAction::triggered, [this]() {
        QObject *app = m_rootObject->findChild<QObject*>("app");
        if (app) {
            QMetaObject::invokeMethod(app, "saveFile");
        }
    });
    
    QObject::connect(saveAsAction, &QAction::triggered, [this]() {
        QObject *saveDialog = m_rootObject->findChild<QObject*>("saveDialog");
        if (saveDialog) {
            QMetaObject::invokeMethod(saveDialog, "open");
        }
    });
    
    QObject::connect(helpAction, &QAction::triggered, [this]() {
        QObject *app = m_rootObject->findChild<QObject*>("app");
        if (app) {
            QMetaObject::invokeMethod(app, "showHelp");
        }
    });
    
    m_mainWindow->show();
}

void HybridArchitectureTest::testNativeMenuBarIntegration()
{
    // Given the application is launched
    // When I look at the menu bar
    verifyMenuBarExists();
    verifyMenuItemsExist();
    
    // Then I should see a native macOS menu bar
    QVERIFY(m_menuBar != nullptr);
    QVERIFY(m_menuBar->isVisible());
    
    // And the menu bar should contain "File", "Help" menus
    QVERIFY(m_menuBar->findChild<QMenu*>("File") != nullptr);
    QVERIFY(m_menuBar->findChild<QMenu*>("Help") != nullptr);
    
    // And there should be no duplicate menu items
    QList<QMenu*> menus = m_menuBar->findChildren<QMenu*>();
    QStringList menuTitles;
    for (QMenu *menu : menus) {
        if (!menu->title().isEmpty()) {
            QVERIFY(!menuTitles.contains(menu->title()));
            menuTitles.append(menu->title());
        }
    }
}

void HybridArchitectureTest::testMenuShortcutsWork()
{
    // Test that shortcuts are properly set
    QList<QAction*> actions = m_menuBar->findChildren<QAction*>();
    bool foundPreferences = false;
    bool foundNew = false;
    bool foundOpen = false;
    bool foundSave = false;
    bool foundQuit = false;
    
    for (QAction *action : actions) {
        if (action->text().contains("Preferences") && action->shortcut() == QKeySequence::Preferences) {
            foundPreferences = true;
        }
        if (action->text().contains("New") && action->shortcut() == QKeySequence::New) {
            foundNew = true;
        }
        if (action->text().contains("Open") && action->shortcut() == QKeySequence::Open) {
            foundOpen = true;
        }
        if (action->text().contains("Save") && action->shortcut() == QKeySequence::Save) {
            foundSave = true;
        }
        if (action->text().contains("Quit") && action->shortcut() == QKeySequence::Quit) {
            foundQuit = true;
        }
    }
    
    QVERIFY(foundPreferences);
    QVERIFY(foundNew);
    QVERIFY(foundOpen);
    QVERIFY(foundSave);
    QVERIFY(foundQuit);
}

void HybridArchitectureTest::testMenuActionsCommunicateWithQML()
{
    // Verify that QML objects exist
    verifyQMLObjectExists("app");
    
    // Test that menu actions can find QML objects
    QObject *app = m_rootObject->findChild<QObject*>("app");
    QVERIFY(app != nullptr);
    
    // Test that QML methods can be invoked
    QVERIFY(QMetaObject::invokeMethod(app, "newFile"));
}

void HybridArchitectureTest::testPreferencesIntegration()
{
    // Verify preferences dialog can be found
    verifyQMLObjectExists("prefsDialog");
    
    QObject *prefsDialog = m_rootObject->findChild<QObject*>("prefsDialog");
    QVERIFY(prefsDialog != nullptr);
    
    // Test that preferences dialog can be shown
    QVERIFY(QMetaObject::invokeMethod(prefsDialog, "show"));
}

void HybridArchitectureTest::testAboutDialogIntegration()
{
    // Verify about dialog can be found
    verifyQMLObjectExists("app");
    
    QObject *app = m_rootObject->findChild<QObject*>("app");
    QVERIFY(app != nullptr);
    
    // Test that about dialog can be shown
    QVERIFY(QMetaObject::invokeMethod(app, "showAbout"));
}

void HybridArchitectureTest::testTranslationSystemIntegration()
{
    // Verify translation system is working
    QVERIFY(m_i18nManager != nullptr);
    QVERIFY(m_settingsManager != nullptr);
    
    // Test language switching
    QStringList languages = m_i18nManager->availableLanguages();
    QVERIFY(languages.contains("en_GB"));
    QVERIFY(languages.contains("es"));
    QVERIFY(languages.contains("fr"));
}

void HybridArchitectureTest::testFileOperationsThroughNativeMenus()
{
    // Verify file dialogs can be found
    verifyQMLObjectExists("openDialog");
    verifyQMLObjectExists("saveDialog");
    
    QObject *openDialog = m_rootObject->findChild<QObject*>("openDialog");
    QObject *saveDialog = m_rootObject->findChild<QObject*>("saveDialog");
    
    QVERIFY(openDialog != nullptr);
    QVERIFY(saveDialog != nullptr);
    
    // Test that dialogs can be opened
    QVERIFY(QMetaObject::invokeMethod(openDialog, "open"));
    QVERIFY(QMetaObject::invokeMethod(saveDialog, "open"));
}

void HybridArchitectureTest::testErrorHandling()
{
    // Test that application doesn't crash on invalid operations
    QObject *app = m_rootObject->findChild<QObject*>("app");
    QVERIFY(app != nullptr);
    
    // Test error handling methods exist
    QVERIFY(QMetaObject::invokeMethod(app, "showError", Q_ARG(QString, "Test error")));
}

// Helper methods
void HybridArchitectureTest::verifyMenuBarExists()
{
    QVERIFY(m_menuBar != nullptr);
    QVERIFY(m_menuBar->isVisible());
}

void HybridArchitectureTest::verifyMenuItemsExist()
{
    QList<QMenu*> menus = m_menuBar->findChildren<QMenu*>();
    QVERIFY(menus.size() >= 2); // At least File and Help menus
}

void HybridArchitectureTest::verifyQMLObjectExists(const QString &objectName)
{
    QObject *obj = m_rootObject->findChild<QObject*>(objectName);
    QVERIFY2(obj != nullptr, qPrintable(QString("QML object '%1' not found").arg(objectName)));
}

QTEST_MAIN(HybridArchitectureTest)
#include "hybrid_architecture_steps.moc"
