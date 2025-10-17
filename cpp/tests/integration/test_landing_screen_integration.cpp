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
#include <QClipboard>

#include "Application.hpp"
#include "SettingsManager.hpp"
#include "I18nManager.hpp"

class LandingScreenIntegrationTest : public QObject
{
    Q_OBJECT

private slots:
    void initTestCase();
    void cleanupTestCase();
    void init();
    void cleanup();

    // Test scenarios
    void testLandingScreenDisplays();
    void testOpenFileButton();
    void testNewFileButton();
    void testNewFromPasteboardButton();
    void testNewFromURLButton();
    void testNewFromCurlButton();
    void testRecentFilesSection();
    void testFileOperationsFromNativeMenu();

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
    QObject* findLandingScreen();
    QObject* findButton(const QString &buttonText);
    void waitForQMLToLoad();
    void simulateButtonClick(QObject *button);
};

void LandingScreenIntegrationTest::initTestCase()
{
    // Initialize test environment
    int argc = 0;
    char **argv = nullptr;
    m_app = new QApplication(argc, argv);
    
    // Set application properties for testing
    m_app->setAttribute(Qt::AA_DontUseNativeMenuBar, false);
}

void LandingScreenIntegrationTest::cleanupTestCase()
{
    delete m_app;
}

void LandingScreenIntegrationTest::init()
{
    setupHybridArchitecture();
    waitForQMLToLoad();
}

void LandingScreenIntegrationTest::cleanup()
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

void LandingScreenIntegrationTest::setupHybridArchitecture()
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
    
    m_mainWindow->show();
}

void LandingScreenIntegrationTest::waitForQMLToLoad()
{
    // Wait for QML to load completely
    QEventLoop loop;
    QTimer::singleShot(100, &loop, &QEventLoop::quit);
    loop.exec();
}

void LandingScreenIntegrationTest::testLandingScreenDisplays()
{
    // Given the application is running
    QVERIFY(m_mainWindow != nullptr);
    QVERIFY(m_rootObject != nullptr);
    
    // When I look at the main window
    // Then the landing screen should be visible
    QObject *landingScreen = findLandingScreen();
    QVERIFY(landingScreen != nullptr);
    
    // Verify landing screen is visible
    QVariant visible = landingScreen->property("visible");
    QVERIFY(visible.isValid());
    QVERIFY(visible.toBool());
}

void LandingScreenIntegrationTest::testOpenFileButton()
{
    // Given the landing screen is displayed
    QObject *landingScreen = findLandingScreen();
    QVERIFY(landingScreen != nullptr);
    
    // When I look for the Open File button
    QObject *openButton = findButton("Open File");
    QVERIFY(openButton != nullptr);
    
    // Then the button should be visible and clickable
    QVariant visible = openButton->property("visible");
    QVERIFY(visible.isValid());
    QVERIFY(visible.toBool());
    
    QVariant enabled = openButton->property("enabled");
    QVERIFY(enabled.isValid());
    QVERIFY(enabled.toBool());
}

void LandingScreenIntegrationTest::testNewFileButton()
{
    // Given the landing screen is displayed
    QObject *landingScreen = findLandingScreen();
    QVERIFY(landingScreen != nullptr);
    
    // When I look for the New File button
    QObject *newButton = findButton("New File");
    QVERIFY(newButton != nullptr);
    
    // Then the button should be visible and clickable
    QVariant visible = newButton->property("visible");
    QVERIFY(visible.isValid());
    QVERIFY(visible.toBool());
    
    QVariant enabled = newButton->property("enabled");
    QVERIFY(enabled.isValid());
    QVERIFY(enabled.toBool());
}

void LandingScreenIntegrationTest::testNewFromPasteboardButton()
{
    // Given the landing screen is displayed
    QObject *landingScreen = findLandingScreen();
    QVERIFY(landingScreen != nullptr);
    
    // When I look for the New from Pasteboard button
    QObject *pasteboardButton = findButton("New from Pasteboard");
    QVERIFY(pasteboardButton != nullptr);
    
    // Then the button should be visible and clickable
    QVariant visible = pasteboardButton->property("visible");
    QVERIFY(visible.isValid());
    QVERIFY(visible.toBool());
    
    QVariant enabled = pasteboardButton->property("enabled");
    QVERIFY(enabled.isValid());
    QVERIFY(enabled.toBool());
}

void LandingScreenIntegrationTest::testNewFromURLButton()
{
    // Given the landing screen is displayed
    QObject *landingScreen = findLandingScreen();
    QVERIFY(landingScreen != nullptr);
    
    // When I look for the New from URL button
    QObject *urlButton = findButton("New from URL");
    QVERIFY(urlButton != nullptr);
    
    // Then the button should be visible and clickable
    QVariant visible = urlButton->property("visible");
    QVERIFY(visible.isValid());
    QVERIFY(visible.toBool());
    
    QVariant enabled = urlButton->property("enabled");
    QVERIFY(enabled.isValid());
    QVERIFY(enabled.toBool());
}

void LandingScreenIntegrationTest::testNewFromCurlButton()
{
    // Given the landing screen is displayed
    QObject *landingScreen = findLandingScreen();
    QVERIFY(landingScreen != nullptr);
    
    // When I look for the New from cURL button
    QObject *curlButton = findButton("New from cURL");
    QVERIFY(curlButton != nullptr);
    
    // Then the button should be visible and clickable
    QVariant visible = curlButton->property("visible");
    QVERIFY(visible.isValid());
    QVERIFY(visible.toBool());
    
    QVariant enabled = curlButton->property("enabled");
    QVERIFY(enabled.isValid());
    QVERIFY(enabled.toBool());
}

void LandingScreenIntegrationTest::testRecentFilesSection()
{
    // Given the landing screen is displayed
    QObject *landingScreen = findLandingScreen();
    QVERIFY(landingScreen != nullptr);
    
    // When I look for the Recent Files section
    QObject *recentFilesHeader = landingScreen->findChild<QObject*>("recentFilesHeader");
    QVERIFY(recentFilesHeader != nullptr);
    
    // Then the Recent Files section should be visible
    QVariant visible = recentFilesHeader->property("visible");
    QVERIFY(visible.isValid());
    QVERIFY(visible.toBool());
    
    // And it should have the correct text
    QVariant text = recentFilesHeader->property("text");
    QVERIFY(text.isValid());
    QVERIFY(text.toString().contains("Recent Files"));
}

void LandingScreenIntegrationTest::testFileOperationsFromNativeMenu()
{
    // Given the application is running with native menu
    QVERIFY(m_menuBar != nullptr);
    
    // When I look for File menu actions
    QList<QAction*> actions = m_menuBar->findChildren<QAction*>();
    bool foundNew = false;
    bool foundOpen = false;
    
    for (QAction *action : actions) {
        if (action->text().contains("New") && action->shortcut() == QKeySequence::New) {
            foundNew = true;
        }
        if (action->text().contains("Open") && action->shortcut() == QKeySequence::Open) {
            foundOpen = true;
        }
    }
    
    // Then the File menu should have New and Open actions
    QVERIFY(foundNew);
    QVERIFY(foundOpen);
}

// Helper methods
QObject* LandingScreenIntegrationTest::findLandingScreen()
{
    return m_rootObject->findChild<QObject*>("landingScreen");
}

QObject* LandingScreenIntegrationTest::findButton(const QString &buttonText)
{
    QList<QObject*> buttons = m_rootObject->findChildren<QObject*>();
    for (QObject *button : buttons) {
        QVariant text = button->property("text");
        if (text.isValid() && text.toString().contains(buttonText)) {
            return button;
        }
    }
    return nullptr;
}

void LandingScreenIntegrationTest::simulateButtonClick(QObject *button)
{
    if (button) {
        QMetaObject::invokeMethod(button, "clicked");
    }
}

QTEST_MAIN(LandingScreenIntegrationTest)
#include "test_landing_screen_integration.moc"
