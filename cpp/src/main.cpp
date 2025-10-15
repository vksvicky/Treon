#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QDir>
#include <QIcon>
#include <QStyleFactory>

#include "Application.hpp"
#include "AboutWindow.hpp"
#include "SettingsManager.hpp"
#include "I18nManager.hpp"
#include "Logger.hpp"

int main(int argc, char *argv[])
{
    // Increase image allocation limit to handle complex SVG files
    qputenv("QT_IMAGEIO_MAXALLOC", "512");
    
    // Initialize logging first
    treon::Logger::initialize();
    LOG_INFO("Starting Treon application");
    
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
    // Use Basic style which supports custom backgrounds and content items
    qputenv("QT_QUICK_CONTROLS_STYLE", "Basic");
    
    // Set application properties for macOS
    app.setAttribute(Qt::AA_DontUseNativeMenuBar, false);
    
    QQmlApplicationEngine engine;
    
    // Add QML import path for our custom modules
    engine.addImportPath("qrc:/qml");
    
    // Initialize managers
    treon::SettingsManager settingsManager;
    treon::I18nManager i18nManager;
    
    // Load language from settings BEFORE QML is loaded
    QString savedLanguage = settingsManager.language();
    if (savedLanguage.isEmpty() || !i18nManager.isLanguageSupported(savedLanguage)) {
        // Fallback to system language or default
        i18nManager.loadSystemLanguage();
        settingsManager.setLanguage(i18nManager.currentLanguage());
    } else {
        i18nManager.setCurrentLanguage(savedLanguage);
    }
    
    // Register C++ types with QML
    qmlRegisterType<treon::Application>("Treon", 1, 0, "Application");
    qmlRegisterType<treon::AboutWindow>("Treon", 1, 0, "AboutWindow");
    qmlRegisterType<treon::SettingsManager>("Treon", 1, 0, "SettingsManager");
    qmlRegisterType<treon::I18nManager>("Treon", 1, 0, "I18nManager");
    
    // Expose managers as context properties
    engine.rootContext()->setContextProperty("settingsManager", &settingsManager);
    engine.rootContext()->setContextProperty("i18nManager", &i18nManager);
    
    // Load main QML file
    const QUrl url(QStringLiteral("qrc:/qml/main.qml"));
    
    // Handle language changes
    QObject::connect(&i18nManager, &treon::I18nManager::translationsLoaded,
                     [&engine, url, &settingsManager, &i18nManager]() {
        // Force reload of QML to apply new translations
        engine.clearComponentCache();
        
        // Re-set context properties before reloading
        engine.rootContext()->setContextProperty("settingsManager", &settingsManager);
        engine.rootContext()->setContextProperty("i18nManager", &i18nManager);
        
        engine.load(url);
        
        // Also trigger QML retranslation
        QCoreApplication::sendEvent(QCoreApplication::instance(), new QEvent(QEvent::LanguageChange));
    });
    
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    
    engine.load(url);
    
    return app.exec();
}
