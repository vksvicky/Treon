#include <QtTest>
#include <QApplication>
#include <QMainWindow>
#include <QMenuBar>
#include <QAction>
#include <QQmlApplicationEngine>
#include <QWindow>
#include <QWidget>
#include <QSignalSpy>
#include <QTimer>

#include "Application.hpp"
#include "SettingsManager.hpp"
#include "I18nManager.hpp"

class AboutWindowIntegrationTest : public QObject
{
    Q_OBJECT

private slots:
    void initTestCase();
    void cleanupTestCase();
    void init();
    void cleanup();

    // Test scenarios
    void testAboutWindowOpensFromNativeMenu();
    void testAboutWindowDisplaysCorrectly();
    void testAboutWindowCanBeClosed();
    void testAboutWindowShowsApplicationInfo();

private:
    QApplication *m_app;
    QMainWindow *m_mainWindow;
    QMenuBar *m_menuBar;
    QQmlApplicationEngine *m_engine;
    QObject *m_rootObject;
    treon::SettingsManager *m_settingsManager;
    treon::I18nManager *m_i18nManager;
    treon::Application *m_application;
    
    // Helper methods
    void setupHybridArchitecture();
    QAction* findAboutAction();
    QObject* findAboutDialog();
    void waitForQMLToLoad();
};

void AboutWindowIntegrationTest::initTestCase()
{
    // Initialize test environment
    int argc = 0;
    char **argv = nullptr;
    m_app = new QApplication(argc, argv);
    
    // Set application properties for testing
    m_app->setAttribute(Qt::AA_DontUseNativeMenuBar, false);
}

void AboutWindowIntegrationTest::cleanupTestCase()
{
    delete m_app;
}

void AboutWindowIntegrationTest::init()
{
    setupHybridArchitecture();
    waitForQMLToLoad();
}

void AboutWindowIntegrationTest::cleanup()
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
    if (m_application) {
        delete m_application;
        m_application = nullptr;
    }
}

void AboutWindowIntegrationTest::setupHybridArchitecture()
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
    
    m_mainWindow->setMenuBar(m_menuBar);
    
    // Initialize managers
    m_settingsManager = new treon::SettingsManager();
    m_i18nManager = new treon::I18nManager();
    m_application = new treon::Application();
    
    // Create QML application engine
    m_engine = new QQmlApplicationEngine();
    m_engine->addImportPath("qrc:/qml");
    
    // Register QML types
    qmlRegisterType<treon::Application>("Treon", 1, 0, "Application");
    qmlRegisterType<treon::AboutWindow>("Treon", 1, 0, "AboutWindow");
    
    // Set QML context properties
    m_engine->rootContext()->setContextProperty("settingsManager", m_settingsManager);
    m_engine->rootContext()->setContextProperty("i18nManager", m_i18nManager);
    m_engine->rootContext()->setContextProperty("app", m_application);
    
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
    
    // Connect menu actions to QML
    QObject::connect(aboutAction, &QAction::triggered, [this]() {
        QObject *app = m_rootObject->findChild<QObject*>("app");
        if (app) {
            QMetaObject::invokeMethod(app, "showAbout");
        }
    });
    
    m_mainWindow->show();
}

void AboutWindowIntegrationTest::waitForQMLToLoad()
{
    // Wait for QML to load completely
    QEventLoop loop;
    QTimer::singleShot(100, &loop, &QEventLoop::quit);
    loop.exec();
}

void AboutWindowIntegrationTest::testAboutWindowOpensFromNativeMenu()
{
    // Given the application is running
    QVERIFY(m_mainWindow != nullptr);
    QVERIFY(m_menuBar != nullptr);
    
    // When I click "About Treon" from the native menu
    QAction *aboutAction = findAboutAction();
    QVERIFY(aboutAction != nullptr);
    
    // Trigger the about action
    aboutAction->trigger();
    
    // Wait for the dialog to appear
    QEventLoop loop;
    QTimer::singleShot(200, &loop, &QEventLoop::quit);
    loop.exec();
    
    // Then the about dialog should open
    QObject *aboutDialog = findAboutDialog();
    QVERIFY(aboutDialog != nullptr);
    
    // Verify the dialog is visible
    QVariant visible = aboutDialog->property("visible");
    QVERIFY(visible.isValid());
    QVERIFY(visible.toBool());
}

void AboutWindowIntegrationTest::testAboutWindowDisplaysCorrectly()
{
    // Given the about dialog is open
    QAction *aboutAction = findAboutAction();
    aboutAction->trigger();
    
    QEventLoop loop;
    QTimer::singleShot(200, &loop, &QEventLoop::quit);
    loop.exec();
    
    QObject *aboutDialog = findAboutDialog();
    QVERIFY(aboutDialog != nullptr);
    
    // Then it should display the correct title
    QVariant title = aboutDialog->property("title");
    QVERIFY(title.isValid());
    QVERIFY(title.toString().contains("About"));
    
    // And it should have the correct dimensions
    QVariant width = aboutDialog->property("width");
    QVariant height = aboutDialog->property("height");
    QVERIFY(width.isValid());
    QVERIFY(height.isValid());
    QCOMPARE(width.toInt(), 500);
    QCOMPARE(height.toInt(), 675);
}

void AboutWindowIntegrationTest::testAboutWindowCanBeClosed()
{
    // Given the about dialog is open
    QAction *aboutAction = findAboutAction();
    aboutAction->trigger();
    
    QEventLoop loop;
    QTimer::singleShot(200, &loop, &QEventLoop::quit);
    loop.exec();
    
    QObject *aboutDialog = findAboutDialog();
    QVERIFY(aboutDialog != nullptr);
    
    // When I close the dialog
    QMetaObject::invokeMethod(aboutDialog, "close");
    
    QTimer::singleShot(100, &loop, &QEventLoop::quit);
    loop.exec();
    
    // Then the dialog should be closed
    QVariant visible = aboutDialog->property("visible");
    QVERIFY(visible.isValid());
    QVERIFY(!visible.toBool());
}

void AboutWindowIntegrationTest::testAboutWindowShowsApplicationInfo()
{
    // Given the about dialog is open
    QAction *aboutAction = findAboutAction();
    aboutAction->trigger();
    
    QEventLoop loop;
    QTimer::singleShot(200, &loop, &QEventLoop::quit);
    loop.exec();
    
    QObject *aboutDialog = findAboutDialog();
    QVERIFY(aboutDialog != nullptr);
    
    // Then it should contain application information
    // Check if the AboutWindow component exists
    QObject *aboutWindowInstance = aboutDialog->findChild<QObject*>("aboutWindowInstance");
    QVERIFY(aboutWindowInstance != nullptr);
    
    // Verify it has application name
    QVariant appName = aboutWindowInstance->property("applicationName");
    QVERIFY(appName.isValid());
    QVERIFY(!appName.toString().isEmpty());
}

// Helper methods
QAction* AboutWindowIntegrationTest::findAboutAction()
{
    QList<QAction*> actions = m_menuBar->findChildren<QAction*>();
    for (QAction *action : actions) {
        if (action->text().contains("About Treon")) {
            return action;
        }
    }
    return nullptr;
}

QObject* AboutWindowIntegrationTest::findAboutDialog()
{
    // Look for the about dialog loader
    QObject *aboutDialogLoader = m_rootObject->findChild<QObject*>("aboutDialogLoader");
    if (aboutDialogLoader) {
        QVariant item = aboutDialogLoader->property("item");
        if (item.isValid()) {
            return qvariant_cast<QObject*>(item);
        }
    }
    
    // Also look for any window with "About" in the title
    QList<QObject*> windows = m_rootObject->findChildren<QObject*>();
    for (QObject *window : windows) {
        QVariant title = window->property("title");
        if (title.isValid() && title.toString().contains("About")) {
            return window;
        }
    }
    
    return nullptr;
}

QTEST_MAIN(AboutWindowIntegrationTest)
#include "test_about_window_integration.moc"
