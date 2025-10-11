#include "test_about_window.hpp"

void TestAboutWindow::initTestCase()
{
    // Initialize Qt application if not already done
    if (!QApplication::instance()) {
        int argc = 0;
        char **argv = nullptr;
        new QApplication(argc, argv);
    }
}

void TestAboutWindow::cleanupTestCase()
{
    // Cleanup if needed
}

void TestAboutWindow::init()
{
    m_aboutWindow = new treon::AboutWindow(this);
}

void TestAboutWindow::cleanup()
{
    delete m_aboutWindow;
    m_aboutWindow = nullptr;
}

void TestAboutWindow::testConstructor()
{
    QVERIFY(m_aboutWindow != nullptr);
    QVERIFY(!m_aboutWindow->isVisible());
    QVERIFY(!m_aboutWindow->applicationName().isEmpty());
    QVERIFY(!m_aboutWindow->applicationVersion().isEmpty());
}

void TestAboutWindow::testApplicationInfo()
{
    // Test application name
    QCOMPARE(m_aboutWindow->applicationName(), QString("Treon"));
    
    // Test application version
    QCOMPARE(m_aboutWindow->applicationVersion(), QString("1.0.0"));
    
    // Test organization name
    QCOMPARE(m_aboutWindow->organizationName(), QString("CycleRunCode Club"));
    
    // Test organization domain
    QCOMPARE(m_aboutWindow->organizationDomain(), QString("cycleruncode.club"));
    
    // Test copyright (should contain current year)
    QString copyright = m_aboutWindow->copyright();
    QVERIFY(copyright.contains("Copyright ©"));
    QVERIFY(copyright.contains("CycleRunCode Club"));
    
    // Test license
    QCOMPARE(m_aboutWindow->license(), QString("MIT License"));
    
    // Test build info (should not be empty)
    QVERIFY(!m_aboutWindow->applicationBuild().isEmpty());
}

void TestAboutWindow::testSystemInfo()
{
    // Test Qt version (should not be empty)
    QVERIFY(!m_aboutWindow->qtVersion().isEmpty());
    
    // Test build date (should not be empty)
    QVERIFY(!m_aboutWindow->buildDate().isEmpty());
    
    // Test build time (should not be empty)
    QVERIFY(!m_aboutWindow->buildTime().isEmpty());
    
    // Test compiler info (should not be empty)
    QVERIFY(!m_aboutWindow->compilerInfo().isEmpty());
    
    // Test platform info (should not be empty)
    QVERIFY(!m_aboutWindow->platformInfo().isEmpty());
}

void TestAboutWindow::testVisibility()
{
    // Initially not visible
    QVERIFY(!m_aboutWindow->isVisible());
    
    // Set visible
    m_aboutWindow->setIsVisible(true);
    QVERIFY(m_aboutWindow->isVisible());
    
    // Set not visible
    m_aboutWindow->setIsVisible(false);
    QVERIFY(!m_aboutWindow->isVisible());
}

void TestAboutWindow::testIconPaths()
{
    // Test icon path
    QCOMPARE(m_aboutWindow->iconPath(), QString(":/icon.png"));
    
    // Test logo path
    QCOMPARE(m_aboutWindow->logoPath(), QString(":/icon.png"));
}

void TestAboutWindow::testCredits()
{
    QStringList credits = m_aboutWindow->credits();
    QVERIFY(!credits.isEmpty());
    QVERIFY(credits.contains("Development Team"));
    QVERIFY(credits.contains("CycleRunCode Club"));
}

void TestAboutWindow::testThirdPartyLibraries()
{
    QStringList libraries = m_aboutWindow->thirdPartyLibraries();
    QVERIFY(!libraries.isEmpty());
    
    // Should contain Qt
    bool hasQt = false;
    for (const QString &lib : libraries) {
        if (lib.contains("Qt")) {
            hasQt = true;
            break;
        }
    }
    QVERIFY(hasQt);
}

void TestAboutWindow::testShow()
{
    QSignalSpy spy(m_aboutWindow, &treon::AboutWindow::isVisibleChanged);
    
    m_aboutWindow->show();
    
    QVERIFY(m_aboutWindow->isVisible());
    QCOMPARE(spy.count(), 1);
}

void TestAboutWindow::testHide()
{
    // First make it visible
    m_aboutWindow->setIsVisible(true);
    QSignalSpy spy(m_aboutWindow, &treon::AboutWindow::isVisibleChanged);
    
    m_aboutWindow->hide();
    
    QVERIFY(!m_aboutWindow->isVisible());
    QCOMPARE(spy.count(), 1);
}

void TestAboutWindow::testToggle()
{
    // Initially not visible
    QVERIFY(!m_aboutWindow->isVisible());
    
    // Toggle to visible
    m_aboutWindow->toggle();
    QVERIFY(m_aboutWindow->isVisible());
    
    // Toggle to not visible
    m_aboutWindow->toggle();
    QVERIFY(!m_aboutWindow->isVisible());
}

void TestAboutWindow::testGetSystemInfo()
{
    QString systemInfo = m_aboutWindow->getSystemInfo();
    QVERIFY(!systemInfo.isEmpty());
    QVERIFY(systemInfo.contains("Platform:"));
    QVERIFY(systemInfo.contains("Qt Version:"));
    QVERIFY(systemInfo.contains("Build:"));
}

void TestAboutWindow::testGetVersionInfo()
{
    QString versionInfo = m_aboutWindow->getVersionInfo();
    QVERIFY(!versionInfo.isEmpty());
    QVERIFY(versionInfo.contains("Treon"));
    QVERIFY(versionInfo.contains("1.0.0"));
    QVERIFY(versionInfo.contains("Copyright"));
}

void TestAboutWindow::testGetBuildInfo()
{
    QString buildInfo = m_aboutWindow->getBuildInfo();
    QVERIFY(!buildInfo.isEmpty());
    QVERIFY(buildInfo.contains("Build Date:"));
    QVERIFY(buildInfo.contains("Build Time:"));
    QVERIFY(buildInfo.contains("Compiler:"));
}

void TestAboutWindow::testOpenWebsite()
{
    QSignalSpy spy(m_aboutWindow, &treon::AboutWindow::websiteRequested);
    
    m_aboutWindow->openWebsite();
    
    QCOMPARE(spy.count(), 1);
    QList<QVariant> arguments = spy.takeFirst();
    QVERIFY(arguments.at(0).toString().contains("cycleruncode.club"));
}

void TestAboutWindow::testOpenDocumentation()
{
    // Documentation functionality is not available yet
    // This test is kept for when documentation becomes available
    QSignalSpy spy(m_aboutWindow, &treon::AboutWindow::documentationRequested);
    
    m_aboutWindow->openDocumentation();
    
    QCOMPARE(spy.count(), 1);
    QList<QVariant> arguments = spy.takeFirst();
    QVERIFY(arguments.at(0).toString().contains("cycleruncode.club"));
}

void TestAboutWindow::testOpenSupport()
{
    QSignalSpy spy(m_aboutWindow, &treon::AboutWindow::supportRequested);
    
    m_aboutWindow->openSupport();
    
    QCOMPARE(spy.count(), 1);
    QList<QVariant> arguments = spy.takeFirst();
    QString mailtoUrl = arguments.at(0).toString();
    QVERIFY(mailtoUrl.contains("mailto:support@cycleruncode.club"));
    QVERIFY(mailtoUrl.contains("subject=Treon Support"));
}

void TestAboutWindow::testOpenLicense()
{
    QSignalSpy spy(m_aboutWindow, &treon::AboutWindow::licenseRequested);
    
    m_aboutWindow->openLicense();
    
    QCOMPARE(spy.count(), 1);
    QList<QVariant> arguments = spy.takeFirst();
    QString licensePath = arguments.at(0).toString();
    QVERIFY(licensePath.contains("LICENSE"));
}

void TestAboutWindow::testCopyVersionInfo()
{
    QSignalSpy spy(m_aboutWindow, &treon::AboutWindow::versionInfoCopied);
    
    m_aboutWindow->copyVersionInfo();
    
    QCOMPARE(spy.count(), 1);
    QList<QVariant> arguments = spy.takeFirst();
    QString copiedInfo = arguments.at(0).toString();
    QVERIFY(copiedInfo.contains("Treon"));
    QVERIFY(copiedInfo.contains("1.0.0"));
    
    // Verify clipboard content
    QCOMPARE(QApplication::clipboard()->text(), copiedInfo);
}

void TestAboutWindow::testCopySystemInfo()
{
    QSignalSpy spy(m_aboutWindow, &treon::AboutWindow::systemInfoCopied);
    
    m_aboutWindow->copySystemInfo();
    
    QCOMPARE(spy.count(), 1);
    QList<QVariant> arguments = spy.takeFirst();
    QString copiedInfo = arguments.at(0).toString();
    QVERIFY(copiedInfo.contains("Platform:"));
    QVERIFY(copiedInfo.contains("Qt Version:"));
    
    // Verify clipboard content
    QCOMPARE(QApplication::clipboard()->text(), copiedInfo);
}

void TestAboutWindow::testSignals()
{
    // Test visibility changed signal
    QSignalSpy visibilitySpy(m_aboutWindow, &treon::AboutWindow::isVisibleChanged);
    m_aboutWindow->setIsVisible(true);
    QCOMPARE(visibilitySpy.count(), 1);
    
    m_aboutWindow->setIsVisible(false);
    QCOMPARE(visibilitySpy.count(), 2);
    
    // Test that setting same value doesn't emit signal
    m_aboutWindow->setIsVisible(false);
    QCOMPARE(visibilitySpy.count(), 2);
}

void TestAboutWindow::testWebsiteRequestedSignal()
{
    QSignalSpy spy(m_aboutWindow, &treon::AboutWindow::websiteRequested);
    m_aboutWindow->openWebsite();
    QCOMPARE(spy.count(), 1);
}

void TestAboutWindow::testDocumentationRequestedSignal()
{
    QSignalSpy spy(m_aboutWindow, &treon::AboutWindow::documentationRequested);
    m_aboutWindow->openDocumentation();
    QCOMPARE(spy.count(), 1);
}

void TestAboutWindow::testSupportRequestedSignal()
{
    QSignalSpy spy(m_aboutWindow, &treon::AboutWindow::supportRequested);
    m_aboutWindow->openSupport();
    QCOMPARE(spy.count(), 1);
}

void TestAboutWindow::testLicenseRequestedSignal()
{
    QSignalSpy spy(m_aboutWindow, &treon::AboutWindow::licenseRequested);
    m_aboutWindow->openLicense();
    QCOMPARE(spy.count(), 1);
}

void TestAboutWindow::testVersionInfoCopiedSignal()
{
    QSignalSpy spy(m_aboutWindow, &treon::AboutWindow::versionInfoCopied);
    m_aboutWindow->copyVersionInfo();
    QCOMPARE(spy.count(), 1);
}

void TestAboutWindow::testSystemInfoCopiedSignal()
{
    QSignalSpy spy(m_aboutWindow, &treon::AboutWindow::systemInfoCopied);
    m_aboutWindow->copySystemInfo();
    QCOMPARE(spy.count(), 1);
}

QTEST_MAIN(TestAboutWindow)
#include "test_about_window.moc"
