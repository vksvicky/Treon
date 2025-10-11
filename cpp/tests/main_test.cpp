#include <QtTest>
#include <QApplication>

// Include all test classes
#include "test_application.hpp"
#include "test_about_window.hpp"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    
    int result = 0;
    
    // Run Application tests
    TestApplication testApp;
    result |= QTest::qExec(&testApp, argc, argv);
    
    // Run AboutWindow tests
    TestAboutWindow testAboutWindow;
    result |= QTest::qExec(&testAboutWindow, argc, argv);
    
    return result;
}
