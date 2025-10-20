#include <QApplication>
#include <QMainWindow>
#include <QMenuBar>
#include <QAction>
#include <QKeySequence>
#include <QWidget>
#include <QVBoxLayout>
#include <QLabel>
#include <QPushButton>
#include <QFileDialog>
#include <QMessageBox>
#include <QDir>
#include <QIcon>
#include <QStyleFactory>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QWindow>
#include <QQmlEngine>
#include <QDebug>

#include "Application.hpp"
#include "AboutWindow.hpp"
#include "SettingsManager.hpp"
#include "I18nManager.hpp"
#include "PreferencesDialog.hpp"
#include "Logger.hpp"

int main(int argc, char *argv[])
{
    // Increase image allocation limit to handle complex SVG files
    qputenv("QT_IMAGEIO_MAXALLOC", "512");
    
    // Initialize logging first
    treon::Logger::initialize();
    
    QApplication app(argc, argv);
    
    // Set application metadata
    app.setApplicationName("Treon");
    app.setApplicationDisplayName("Treon JSON Viewer");
    app.setApplicationVersion("1.0.0");
    app.setOrganizationName("CycleRunCode Club");
    app.setOrganizationDomain("cycleruncode.club");
    
    // Set app icon
    app.setWindowIcon(QIcon(":/icon.png"));
    
    // Set Qt Quick Controls 2 style that supports customization
    qputenv("QT_QUICK_CONTROLS_STYLE", "Basic");
    
    // Set application properties for macOS - ENABLE native menu bar
    app.setAttribute(Qt::AA_DontUseNativeMenuBar, false);
    
    // Create main window with native menu bar
    QMainWindow mainWindow;
    mainWindow.setWindowTitle("Treon");
    mainWindow.resize(1200, 800);
    
    // Initialize managers first
    treon::SettingsManager settingsManager;
    treon::I18nManager i18nManager;
    
    // Initialize I18nManager with saved language
    QString savedLanguage = settingsManager.language();
    qDebug() << "Saved language from settings:" << savedLanguage;
    i18nManager.loadLanguage(savedLanguage);
    
    // Create native menu bar AFTER language is loaded
    QMenuBar *menuBar = new QMenuBar(&mainWindow);
    
    // Application Menu (macOS style) - no title for the first menu
    QMenu *appMenu = menuBar->addMenu("");
    
    QAction *aboutAction = appMenu->addAction("About Treon");
    aboutAction->setMenuRole(QAction::AboutRole);
    
    appMenu->addSeparator();
    
    QAction *preferencesAction = appMenu->addAction("Preferences...");
    preferencesAction->setMenuRole(QAction::PreferencesRole);
    preferencesAction->setText("Preferences..."); // Force the text after setting the role
    preferencesAction->setShortcut(QKeySequence::Preferences);
    
    appMenu->addSeparator();
    
    QAction *hideAction = appMenu->addAction("Hide Treon");
    hideAction->setShortcut(QKeySequence("Ctrl+H"));
    
    QAction *hideOthersAction = appMenu->addAction("Hide Others");
    hideOthersAction->setShortcut(QKeySequence("Ctrl+Alt+H"));
    
    QAction *showAllAction = appMenu->addAction("Show All");
    showAllAction->setShortcut(QKeySequence("Ctrl+Alt+H"));
    
    appMenu->addSeparator();
    
    QAction *quitAction = appMenu->addAction("Quit Treon");
    quitAction->setMenuRole(QAction::QuitRole);
    quitAction->setShortcut(QKeySequence::Quit);
    
    // File Menu
    QMenu *fileMenu = menuBar->addMenu("File");
    
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
    
    fileMenu->addSeparator();
    
    QAction *pageSetupAction = fileMenu->addAction("Page Setup...");
    pageSetupAction->setShortcut(QKeySequence("Ctrl+Shift+P"));
    
    QAction *printAction = fileMenu->addAction("Print...");
    printAction->setShortcut(QKeySequence::Print);
    
    // Help Menu
    QMenu *helpMenu = menuBar->addMenu("Help");
    
    QAction *helpAction = helpMenu->addAction("Treon Help");
    helpAction->setShortcut(QKeySequence("F1"));
    
    // Set the menu bar
    mainWindow.setMenuBar(menuBar);
    
    // Create QML application engine
    QQmlApplicationEngine engine;
    
    // Add QML import path for our custom modules
    engine.addImportPath("qrc:/qml");
    
    // Register QML types
    qmlRegisterType<treon::Application>("Treon", 1, 0, "Application");
    qmlRegisterType<treon::AboutWindow>("Treon", 1, 0, "AboutWindow");
    
    // Set QML context properties
    engine.rootContext()->setContextProperty("settingsManager", &settingsManager);
    engine.rootContext()->setContextProperty("i18nManager", &i18nManager);
    
    // Load main QML content
    const QUrl url(QStringLiteral("qrc:/qml/main.qml"));
    engine.load(url);
    
    // Get the QML window and embed it in the C++ main window
    QObject *rootObject = engine.rootObjects().first();
    if (rootObject) {
        QWindow *qmlWindow = qobject_cast<QWindow*>(rootObject);
        if (qmlWindow) {
            // Create a widget container for the QML window
            QWidget *qmlWidget = QWidget::createWindowContainer(qmlWindow, &mainWindow);
            mainWindow.setCentralWidget(qmlWidget);
        }
    }
    
    // Connect menu actions to QML
    QObject::connect(aboutAction, &QAction::triggered, [rootObject]() {
        qDebug() << "About action triggered, looking for QML objects...";
        
        // Try to find the AboutWindow object directly
        QList<QObject*> aboutWindows = rootObject->findChildren<QObject*>("AboutWindow_QMLTYPE_49");
        if (aboutWindows.isEmpty()) {
            // Try to find any object with AboutWindow in the class name
            QList<QObject*> allObjects = rootObject->findChildren<QObject*>();
            for (QObject *obj : allObjects) {
                QString className = obj->metaObject()->className();
                if (className.contains("AboutWindow")) {
                    qDebug() << "Found AboutWindow object:" << className;
                    // Try to call show() method
                    bool success = QMetaObject::invokeMethod(obj, "show");
                    qDebug() << "AboutWindow show() result:" << success;
                    if (success) return;
                }
            }
        } else {
            qDebug() << "Found" << aboutWindows.size() << "AboutWindow objects";
            for (QObject *aboutWindow : aboutWindows) {
                bool success = QMetaObject::invokeMethod(aboutWindow, "show");
                qDebug() << "AboutWindow show() result:" << success;
                if (success) return;
            }
        }
        
        // Try to find the app object
        QObject *app = rootObject->findChild<QObject*>("app");
        if (app) {
            qDebug() << "Found app object, calling showAbout()";
            bool success = QMetaObject::invokeMethod(app, "showAbout");
            qDebug() << "showAbout() call result:" << success;
        } else {
            qDebug() << "App object not found, trying to find Application objects";
            QList<QObject*> appObjects = rootObject->findChildren<QObject*>();
            for (QObject *obj : appObjects) {
                QString className = obj->metaObject()->className();
                if (className.contains("Application")) {
                    qDebug() << "Found Application object:" << className;
                    bool success = QMetaObject::invokeMethod(obj, "showAbout");
                    qDebug() << "Application showAbout() result:" << success;
                    if (success) return;
                }
            }
        }
        
        qDebug() << "No About window could be opened";
    });
    
    QObject::connect(preferencesAction, &QAction::triggered, [&mainWindow, &i18nManager, &engine]() {
        qDebug() << "Preferences action triggered, opening C++ preferences dialog";
        
        treon::PreferencesDialog dialog(&mainWindow);
        
        // Connect language change signal
        QObject::connect(&dialog, &treon::PreferencesDialog::languageChanged,
                        [&i18nManager, &engine](const QString &language) {
            qDebug() << "Language changed to:" << language;
            i18nManager.switchLanguage(language);
            
            // Force QML engine to retranslate
            qDebug() << "Forcing QML retranslation...";
            engine.retranslate();
            qDebug() << "QML retranslation completed";
        });
        
        int result = dialog.exec();
        qDebug() << "Preferences dialog result:" << result;
    });
    
    QObject::connect(quitAction, &QAction::triggered, &app, &QApplication::quit);
    
    QObject::connect(newAction, &QAction::triggered, [rootObject]() {
        qDebug() << "New action triggered, looking for app object...";
        QObject *app = rootObject->findChild<QObject*>("app");
        if (app) {
            qDebug() << "Found app object, calling createNewFile()";
            bool success = QMetaObject::invokeMethod(app, "createNewFile");
            qDebug() << "createNewFile() result:" << success;
        } else {
            qDebug() << "App object not found, trying to find Application objects";
            QList<QObject*> allObjects = rootObject->findChildren<QObject*>();
            for (QObject *obj : allObjects) {
                QString className = obj->metaObject()->className();
                if (className.contains("Application")) {
                    qDebug() << "Found Application object:" << className;
                    bool success = QMetaObject::invokeMethod(obj, "createNewFile");
                    qDebug() << "Application createNewFile() result:" << success;
                    if (success) return;
                }
            }
            qDebug() << "No Application object found for new file";
        }
    });
    
    QObject::connect(openAction, &QAction::triggered, [rootObject]() {
        qDebug() << "Open action triggered, looking for file dialog...";
        QObject *fileDialog = rootObject->findChild<QObject*>("fileDialog");
        if (fileDialog) {
            qDebug() << "Found fileDialog, calling open()";
            bool success = QMetaObject::invokeMethod(fileDialog, "open");
            qDebug() << "fileDialog open() result:" << success;
        } else {
            qDebug() << "fileDialog not found, trying to find FileDialog objects";
            QList<QObject*> allObjects = rootObject->findChildren<QObject*>();
            for (QObject *obj : allObjects) {
                QString className = obj->metaObject()->className();
                if (className.contains("FileDialog")) {
                    qDebug() << "Found FileDialog object:" << className;
                    bool success = QMetaObject::invokeMethod(obj, "open");
                    qDebug() << "FileDialog open() result:" << success;
                    if (success) return;
                }
            }
            qDebug() << "No FileDialog object found";
        }
    });
    
    QObject::connect(closeAction, &QAction::triggered, [rootObject]() {
        QObject *app = rootObject->findChild<QObject*>("app");
        if (app) {
            QMetaObject::invokeMethod(app, "closeFile");
        } else {
            QMessageBox::information(nullptr, "Close File", "Close file action triggered!");
        }
    });
    
    QObject::connect(saveAction, &QAction::triggered, [rootObject]() {
        QObject *app = rootObject->findChild<QObject*>("app");
        if (app) {
            QMetaObject::invokeMethod(app, "saveFile");
        } else {
            QMessageBox::information(nullptr, "Save File", "Save file action triggered!");
        }
    });
    
    QObject::connect(saveAsAction, &QAction::triggered, [rootObject]() {
        QObject *saveDialog = rootObject->findChild<QObject*>("saveDialog");
        if (saveDialog) {
            QMetaObject::invokeMethod(saveDialog, "open");
        } else {
            QFileDialog::getSaveFileName(nullptr, "Save JSON File", "", "JSON files (*.json)");
        }
    });
    
    // Page Setup action (Cmd+Shift+P on macOS)
    QObject::connect(pageSetupAction, &QAction::triggered, [rootObject]() {
        QObject *app = rootObject->findChild<QObject*>("app");
        if (app) {
            QMetaObject::invokeMethod(app, "showPageSetup");
        } else {
            QMessageBox::information(nullptr, "Page Setup", "Page Setup action triggered!");
        }
    });
    
    // Print action (Cmd+P on macOS)
    QObject::connect(printAction, &QAction::triggered, [rootObject]() {
        QObject *app = rootObject->findChild<QObject*>("app");
        if (app) {
            QMetaObject::invokeMethod(app, "printDocument");
        } else {
            QMessageBox::information(nullptr, "Print", "Print action triggered!");
        }
    });
    
    QObject::connect(helpAction, &QAction::triggered, [rootObject]() {
        QObject *app = rootObject->findChild<QObject*>("app");
        if (app) {
            QMetaObject::invokeMethod(app, "showHelp");
        } else {
            QMessageBox::information(nullptr, "Help", "Help action triggered!");
        }
    });
    
    // Show the main window
    mainWindow.show();
    
    return app.exec();
}
