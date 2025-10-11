#ifndef TEST_ABOUT_WINDOW_HPP
#define TEST_ABOUT_WINDOW_HPP

#include <QtTest>
#include <QSignalSpy>
#include <QClipboard>
#include <QApplication>
#include <QDesktopServices>
#include <QUrl>

#include "treon/AboutWindow.hpp"

class TestAboutWindow : public QObject
{
    Q_OBJECT

private slots:
    void initTestCase();
    void cleanupTestCase();
    void init();
    void cleanup();

    // Basic functionality tests
    void testConstructor();
    void testApplicationInfo();
    void testSystemInfo();
    void testVisibility();
    void testIconPaths();
    
    // Credits and libraries tests
    void testCredits();
    void testThirdPartyLibraries();
    
    // Window management tests
    void testShow();
    void testHide();
    void testToggle();
    
    // Information retrieval tests
    void testGetSystemInfo();
    void testGetVersionInfo();
    void testGetBuildInfo();
    
    // External actions tests
    void testOpenWebsite();
    void testOpenDocumentation();
    void testOpenSupport();
    void testOpenLicense();
    void testCopyVersionInfo();
    void testCopySystemInfo();
    
    // Signal tests
    void testSignals();
    void testWebsiteRequestedSignal();
    void testDocumentationRequestedSignal();
    void testSupportRequestedSignal();
    void testLicenseRequestedSignal();
    void testVersionInfoCopiedSignal();
    void testSystemInfoCopiedSignal();

private:
    treon::AboutWindow *m_aboutWindow;
};

#endif // TEST_ABOUT_WINDOW_HPP