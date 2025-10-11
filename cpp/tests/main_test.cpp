#include <QtTest>
#include <QApplication>
#include <QDebug>

// Include unit test classes
#include "unit/test_application.hpp"
#include "unit/test_about_window.hpp"

// Include common test utilities
#include "common/test_helpers.hpp"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    
    qDebug() << "=== Treon Unit Test Suite ===";
    qDebug() << "System:" << treon::test::TestHelpers::getSystemInfo();
    qDebug() << "Started at:" << treon::test::TestHelpers::getCurrentTimestamp();
    qDebug() << "";
    
    int result = 0;
    int totalTests = 0;
    int passedTests = 0;
    
    // Run Application tests
    qDebug() << "Running Application tests...";
    TestApplication testApp;
    int appResult = QTest::qExec(&testApp, argc, argv);
    result |= appResult;
    totalTests++;
    if (appResult == 0) passedTests++;
    
    // Run AboutWindow tests
    qDebug() << "Running AboutWindow tests...";
    TestAboutWindow testAboutWindow;
    int aboutResult = QTest::qExec(&testAboutWindow, argc, argv);
    result |= aboutResult;
    totalTests++;
    if (aboutResult == 0) passedTests++;
    
    // Summary
    qDebug() << "";
    qDebug() << "=== Test Summary ===";
    qDebug() << "Total test suites:" << totalTests;
    qDebug() << "Passed:" << passedTests;
    qDebug() << "Failed:" << (totalTests - passedTests);
    qDebug() << "Overall result:" << (result == 0 ? "PASS" : "FAIL");
    qDebug() << "===================";
    
    return result;
}
