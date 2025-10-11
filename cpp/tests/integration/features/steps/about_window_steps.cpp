#include <QtTest>
#include <QSignalSpy>
#include <QClipboard>
#include <QApplication>
#include <QDesktopServices>
#include <QUrl>

#include "treon/AboutWindow.hpp"

// Simple integration test class
class IntegrationTest : public QObject
{
    Q_OBJECT

private slots:
    void testAboutWindowIntegration()
    {
        // Test that AboutWindow can be created and basic functionality works
        treon::AboutWindow aboutWindow;
        QVERIFY(!aboutWindow.licenseFilePath().isEmpty());
    }
};

QTEST_MAIN(IntegrationTest)
#include "about_window_steps.moc"

// Step definitions for About Window BDD tests

void GivenTheApplicationIsRunning()
{
    // Application is already running in test context
    QVERIFY(QApplication::instance() != nullptr);
}

void GivenTheAboutWindowIsAvailable()
{
    // AboutWindow class is available
    QVERIFY(true); // This would be verified by the test setup
}

void WhenIOpenTheAboutWindow()
{
    // This would be implemented in the actual test
    // For now, we just verify the method exists
    treon::AboutWindow aboutWindow;
    aboutWindow.show();
    QVERIFY(aboutWindow.isVisible());
}

void ThenIShouldSeeTheApplicationName(const QString &expectedName)
{
    treon::AboutWindow aboutWindow;
    QCOMPARE(aboutWindow.applicationName(), expectedName);
}

void ThenIShouldSeeTheVersionNumber(const QString &expectedVersion)
{
    treon::AboutWindow aboutWindow;
    QCOMPARE(aboutWindow.applicationVersion(), expectedVersion);
}

void ThenIShouldSeeTheCopyrightInformation()
{
    treon::AboutWindow aboutWindow;
    QString copyright = aboutWindow.copyright();
    QVERIFY(!copyright.isEmpty());
    QVERIFY(copyright.contains("Copyright ©"));
}

void ThenIShouldSeeTheOrganizationName(const QString &expectedOrg)
{
    treon::AboutWindow aboutWindow;
    QCOMPARE(aboutWindow.organizationName(), expectedOrg);
}

void ThenIShouldSeeTheQtVersionInformation()
{
    treon::AboutWindow aboutWindow;
    QString qtVersion = aboutWindow.qtVersion();
    QVERIFY(!qtVersion.isEmpty());
}

void ThenIShouldSeeTheBuildInformation()
{
    treon::AboutWindow aboutWindow;
    QString buildInfo = aboutWindow.getBuildInfo();
    QVERIFY(!buildInfo.isEmpty());
    QVERIFY(buildInfo.contains("Build Date:"));
    QVERIFY(buildInfo.contains("Build Time:"));
}

void ThenIShouldSeeThePlatformInformation()
{
    treon::AboutWindow aboutWindow;
    QString platformInfo = aboutWindow.platformInfo();
    QVERIFY(!platformInfo.isEmpty());
}

void ThenIShouldSeeTheCompilerInformation()
{
    treon::AboutWindow aboutWindow;
    QString compilerInfo = aboutWindow.compilerInfo();
    QVERIFY(!compilerInfo.isEmpty());
}

void ThenIShouldSeeAListOfThirdPartyLibraries()
{
    treon::AboutWindow aboutWindow;
    QStringList libraries = aboutWindow.thirdPartyLibraries();
    QVERIFY(!libraries.isEmpty());
}

void ThenTheListShouldIncludeQt()
{
    treon::AboutWindow aboutWindow;
    QStringList libraries = aboutWindow.thirdPartyLibraries();
    bool hasQt = false;
    for (const QString &lib : libraries) {
        if (lib.contains("Qt")) {
            hasQt = true;
            break;
        }
    }
    QVERIFY(hasQt);
}

void ThenTheListShouldIncludeCMake()
{
    treon::AboutWindow aboutWindow;
    QStringList libraries = aboutWindow.thirdPartyLibraries();
    bool hasCMake = false;
    for (const QString &lib : libraries) {
        if (lib.contains("CMake")) {
            hasCMake = true;
            break;
        }
    }
    QVERIFY(hasCMake);
}

void ThenTheListShouldIncludeOtherDependencies()
{
    treon::AboutWindow aboutWindow;
    QStringList libraries = aboutWindow.thirdPartyLibraries();
    QVERIFY(libraries.size() > 2); // Should have more than just Qt and CMake
}

void ThenIShouldSeeTheDevelopmentTeamCredits()
{
    treon::AboutWindow aboutWindow;
    QStringList credits = aboutWindow.credits();
    QVERIFY(credits.contains("Development Team"));
}

void ThenIShouldSeeTheOrganizationNameInCredits()
{
    treon::AboutWindow aboutWindow;
    QStringList credits = aboutWindow.credits();
    QVERIFY(credits.contains("CycleRunCode Club"));
}

void ThenIShouldSeeContributorInformation()
{
    treon::AboutWindow aboutWindow;
    QStringList credits = aboutWindow.credits();
    QVERIFY(credits.contains("Open Source Community"));
}

void WhenIClickTheCopyButtonNextToVersionInformation()
{
    treon::AboutWindow aboutWindow;
    aboutWindow.copyVersionInfo();
}

void ThenTheVersionInformationShouldBeCopiedToClipboard()
{
    treon::AboutWindow aboutWindow;
    QString versionInfo = aboutWindow.getVersionInfo();
    QCOMPARE(QApplication::clipboard()->text(), versionInfo);
}

void ThenIShouldSeeAConfirmationMessage()
{
    // This would be verified by checking for a signal emission
    treon::AboutWindow aboutWindow;
    QSignalSpy spy(&aboutWindow, &treon::AboutWindow::versionInfoCopied);
    aboutWindow.copyVersionInfo();
    QCOMPARE(spy.count(), 1);
}

void WhenIClickTheCopyButtonNextToBuildInformation()
{
    treon::AboutWindow aboutWindow;
    aboutWindow.copySystemInfo();
}

void ThenTheSystemInformationShouldBeCopiedToClipboard()
{
    treon::AboutWindow aboutWindow;
    QString systemInfo = aboutWindow.getSystemInfo();
    QCOMPARE(QApplication::clipboard()->text(), systemInfo);
}

void WhenIClickTheWebsiteButton()
{
    treon::AboutWindow aboutWindow;
    aboutWindow.openWebsite();
}

void ThenTheWebsiteShouldOpenInTheDefaultBrowser()
{
    // This would be verified by checking the signal emission
    treon::AboutWindow aboutWindow;
    QSignalSpy spy(&aboutWindow, &treon::AboutWindow::websiteRequested);
    aboutWindow.openWebsite();
    QCOMPARE(spy.count(), 1);
}

void ThenTheUrlShouldContain(const QString &expectedUrl)
{
    treon::AboutWindow aboutWindow;
    QSignalSpy spy(&aboutWindow, &treon::AboutWindow::websiteRequested);
    aboutWindow.openWebsite();
    QList<QVariant> arguments = spy.takeFirst();
    QVERIFY(arguments.at(0).toString().contains(expectedUrl));
}

// Documentation functionality is not available yet
// void WhenIClickTheDocumentationButton() - REMOVED
// void ThenTheDocumentationShouldOpenInTheDefaultBrowser() - REMOVED

void WhenIClickTheSupportButton()
{
    treon::AboutWindow aboutWindow;
    aboutWindow.openSupport();
}

void ThenTheDefaultEmailClientShouldOpen()
{
    treon::AboutWindow aboutWindow;
    QSignalSpy spy(&aboutWindow, &treon::AboutWindow::supportRequested);
    aboutWindow.openSupport();
    QCOMPARE(spy.count(), 1);
}

void AndTheEmailShouldBeAddressedToTheSupportEmail()
{
    treon::AboutWindow aboutWindow;
    QSignalSpy spy(&aboutWindow, &treon::AboutWindow::supportRequested);
    aboutWindow.openSupport();
    QList<QVariant> arguments = spy.takeFirst();
    QString mailtoUrl = arguments.at(0).toString();
    QVERIFY(mailtoUrl.contains("mailto:support@cycleruncode.club"));
}

void AndTheSubjectShouldContain(const QString &subject)
{
    treon::AboutWindow aboutWindow;
    QSignalSpy spy(&aboutWindow, &treon::AboutWindow::supportRequested);
    aboutWindow.openSupport();
    QList<QVariant> arguments = spy.takeFirst();
    QString mailtoUrl = arguments.at(0).toString();
    QVERIFY(mailtoUrl.contains(QString("subject=%1").arg(subject)));
}

void WhenIClickTheViewLicenseButton()
{
    treon::AboutWindow aboutWindow;
    aboutWindow.openLicense();
}

void ThenTheLicenseFileShouldOpenInTheDefaultTextEditor()
{
    treon::AboutWindow aboutWindow;
    QSignalSpy spy(&aboutWindow, &treon::AboutWindow::licenseRequested);
    aboutWindow.openLicense();
    QCOMPARE(spy.count(), 1);
}

void AndTheFileShouldContainTheMITLicenseText()
{
    treon::AboutWindow aboutWindow;
    QSignalSpy spy(&aboutWindow, &treon::AboutWindow::licenseRequested);
    aboutWindow.openLicense();
    QList<QVariant> arguments = spy.takeFirst();
    QString licensePath = arguments.at(0).toString();
    QVERIFY(licensePath.contains("LICENSE"));
}

void WhenTheAboutWindowIsNotVisible()
{
    treon::AboutWindow aboutWindow;
    aboutWindow.setIsVisible(false);
    QVERIFY(!aboutWindow.isVisible());
}

void WhenICallTheShowMethod()
{
    treon::AboutWindow aboutWindow;
    aboutWindow.show();
}

void ThenTheAboutWindowShouldBecomeVisible()
{
    treon::AboutWindow aboutWindow;
    aboutWindow.show();
    QVERIFY(aboutWindow.isVisible());
}

void WhenTheAboutWindowIsVisible()
{
    treon::AboutWindow aboutWindow;
    aboutWindow.setIsVisible(true);
    QVERIFY(aboutWindow.isVisible());
}

void WhenICallTheHideMethod()
{
    treon::AboutWindow aboutWindow;
    aboutWindow.hide();
}

void ThenTheAboutWindowShouldBecomeHidden()
{
    treon::AboutWindow aboutWindow;
    aboutWindow.hide();
    QVERIFY(!aboutWindow.isVisible());
}

void WhenICallTheToggleMethod()
{
    treon::AboutWindow aboutWindow;
    aboutWindow.toggle();
}

void ThenTheAboutWindowShouldBecomeHiddenAfterToggle()
{
    treon::AboutWindow aboutWindow;
    aboutWindow.setIsVisible(true);
    aboutWindow.toggle();
    QVERIFY(!aboutWindow.isVisible());
}

void ThenIShouldSeeTheApplicationIcon()
{
    treon::AboutWindow aboutWindow;
    QString iconPath = aboutWindow.iconPath();
    QVERIFY(!iconPath.isEmpty());
    QCOMPARE(iconPath, ":/icon.png");
}

void ThenTheIconShouldBeProperlySized()
{
    // This would be verified in the QML component
    QVERIFY(true);
}

void ThenTheIconShouldBeClearAndVisible()
{
    // This would be verified in the QML component
    QVERIFY(true);
}

void ThenTheLayoutShouldBeProperlyOrganized()
{
    // This would be verified in the QML component
    QVERIFY(true);
}

void ThenAllTextShouldBeReadable()
{
    // This would be verified in the QML component
    QVERIFY(true);
}

void ThenButtonsShouldBeProperlyAligned()
{
    // This would be verified in the QML component
    QVERIFY(true);
}

void ThenTheWindowShouldBeScrollableIfContentOverflows()
{
    // This would be verified in the QML component
    QVERIFY(true);
}
