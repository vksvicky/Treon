#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QDir>

#include "treon/Application.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    
    app.setApplicationName("Treon");
    app.setApplicationVersion("1.0.0");
    app.setOrganizationName("CycleRunCode");
    
    QQmlApplicationEngine engine;
    
    // Register C++ types with QML
    qmlRegisterType<treon::Application>("Treon", 1, 0, "Application");
    
    // Set QML import path
    engine.addImportPath(QDir::currentPath() + "/qml");
    
    // Load main QML file
    const QUrl url(QStringLiteral("qrc:/qml/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    
    engine.load(url);
    
    return app.exec();
}
