#include <QtTest>
#include <QApplication>

// Include all test classes
#include "test_application.hpp"
#include "test_about_window.hpp"
#include "json_performance_test.hpp"

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
    
    // Run JSON Performance tests
    JSONPerformanceTest jsonPerformanceTest;
    result |= QTest::qExec(&jsonPerformanceTest, argc, argv);
    
    return result;
}
