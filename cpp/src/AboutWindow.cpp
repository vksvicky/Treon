#include "treon/AboutWindow.hpp"
#include "treon/Strings.hpp"
#include <QApplication>
#include <QClipboard>
#include <QDebug>
#include <QDesktopServices>
#include <QUrl>
#include <QDateTime>
#include <QVersionNumber>
#include <QSysInfo>
#include <QStandardPaths>
#include <QFile>
#include <QTemporaryFile>

namespace treon {

AboutWindow::AboutWindow(QObject *parent)
    : QObject(parent)
    , m_isVisible(false)
    , m_iconPath(":/icon.png")
    , m_logoPath(":/icon.png")
{
    initializeApplicationInfo();
    initializeSystemInfo();
    initializeThirdPartyLibraries();
}

AboutWindow::~AboutWindow()
{
}

void AboutWindow::initializeApplicationInfo()
{
    m_applicationName = strings::APP_NAME;
    m_applicationVersion = strings::APP_VERSION;
    m_applicationBuild = QString::number(QDateTime::currentDateTime().toSecsSinceEpoch());
    m_organizationName = strings::ORGANIZATION_NAME;
    m_organizationDomain = strings::ORGANIZATION_DOMAIN;
    m_copyright = QString("Copyright © %1 %2").arg(QDate::currentDate().year()).arg(m_organizationName);
    m_license = "MIT License";
}

void AboutWindow::initializeSystemInfo()
{
    m_qtVersion = QT_VERSION_STR;
    m_buildDate = QDate::currentDate().toString("yyyy-MM-dd");
    m_buildTime = QTime::currentTime().toString("hh:mm:ss");
    
    // Compiler information
    #if defined(__clang__)
        m_compilerInfo = QString("Clang %1.%2.%3").arg(__clang_major__).arg(__clang_minor__).arg(__clang_patchlevel__);
    #elif defined(__GNUC__)
        m_compilerInfo = QString("GCC %1.%2.%3").arg(__GNUC__).arg(__GNUC_MINOR__).arg(__GNUC_PATCHLEVEL__);
    #elif defined(_MSC_VER)
        m_compilerInfo = QString("MSVC %1").arg(_MSC_VER);
    #else
        m_compilerInfo = "Unknown Compiler";
    #endif
    
    // Platform information
    m_platformInfo = QString("%1 %2 (%3)")
        .arg(QSysInfo::prettyProductName())
        .arg(QSysInfo::currentCpuArchitecture())
        .arg(QSysInfo::kernelType());
}

/*************  ✨ Windsurf Command ⭐  *************/
/**
 * @brief Initializes the list of third-party libraries used by Treon.
 *
 * The list is populated with the following libraries:
 * - Qt Framework
 * - CMake Build System
 * - JSON for Modern C++
 * - Catch2 Testing
 * - Gherkin BDD
 */
/*******  ad83ec42-ac6c-4ef8-8174-4ad3a2c78738  *******/
void AboutWindow::initializeThirdPartyLibraries()
{
    m_thirdPartyLibraries << strings::libraries::QT_FRAMEWORK.arg(m_qtVersion)
                          << strings::libraries::CMAKE_BUILD_SYSTEM
                          << strings::libraries::JSON_LIBRARY
                          << strings::libraries::CATCH2_TESTING
                          << strings::libraries::GHERKIN_BDD;
}

QString AboutWindow::applicationName() const
{
    return m_applicationName;
}

QString AboutWindow::applicationVersion() const
{
    return m_applicationVersion;
}

QString AboutWindow::applicationBuild() const
{
    return m_applicationBuild;
}

QString AboutWindow::organizationName() const
{
    return m_organizationName;
}

QString AboutWindow::organizationDomain() const
{
    return m_organizationDomain;
}

QString AboutWindow::copyright() const
{
    return m_copyright;
}

QString AboutWindow::license() const
{
    return m_license;
}

QString AboutWindow::licenseFilePath() const
{
    // Copy the LICENSE file from resources to a temporary location
    QString tempPath = QStandardPaths::writableLocation(QStandardPaths::TempLocation) + "/LICENSE.txt";
    
    // Only copy if the file doesn't already exist
    if (!QFile::exists(tempPath)) {
        QFile::copy(":/LICENSE.txt", tempPath);
    }
    
    return tempPath;
}

QString AboutWindow::qtVersion() const
{
    return m_qtVersion;
}

QString AboutWindow::buildDate() const
{
    return m_buildDate;
}

QString AboutWindow::buildTime() const
{
    return m_buildTime;
}

QString AboutWindow::compilerInfo() const
{
    return m_compilerInfo;
}

QString AboutWindow::platformInfo() const
{
    return m_platformInfo;
}

bool AboutWindow::isVisible() const
{
    return m_isVisible;
}

void AboutWindow::setIsVisible(bool visible)
{
    if (m_isVisible != visible) {
        m_isVisible = visible;
        emit isVisibleChanged();
    }
}

QString AboutWindow::iconPath() const
{
    return m_iconPath;
}

QString AboutWindow::logoPath() const
{
    return m_logoPath;
}

QStringList AboutWindow::credits() const
{
    return m_credits;
}

QStringList AboutWindow::acknowledgments() const
{
    return m_acknowledgments;
}

QStringList AboutWindow::thirdPartyLibraries() const
{
    return m_thirdPartyLibraries;
}

void AboutWindow::show()
{
    setIsVisible(true);
}

void AboutWindow::hide()
{
    setIsVisible(false);
}

void AboutWindow::toggle()
{
    setIsVisible(!m_isVisible);
}

void AboutWindow::open()
{
    show();
}

QString AboutWindow::getSystemInfo() const
{
    return formatSystemString();
}

QString AboutWindow::getVersionInfo() const
{
    return formatVersionString();
}

QString AboutWindow::getBuildInfo() const
{
    return formatBuildString();
}

void AboutWindow::openWebsite()
{
    QString url = QString("https://%1").arg(m_organizationDomain);
    emit websiteRequested(url);
    QDesktopServices::openUrl(QUrl(url));
}

void AboutWindow::openDocumentation()
{
    QString url = QString("https://%1/docs").arg(m_organizationDomain);
    emit documentationRequested(url);
    QDesktopServices::openUrl(QUrl(url));
}

void AboutWindow::openSupport()
{
    QString url = QString("https://%1/support").arg(m_organizationDomain);
    emit supportRequested(url);
    QDesktopServices::openUrl(QUrl(url));
}

void AboutWindow::openLicense()
{
    // Open the local LICENSE file from resources
    QString licensePath = "qrc:/LICENSE";
    qDebug() << "Attempting to open license file:" << licensePath;
    emit licenseRequested(licensePath);
    
    // Read the license content and open it in a text editor
    QFile licenseFile(licensePath);
    if (licenseFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QString licenseContent = licenseFile.readAll();
        licenseFile.close();
        qDebug() << "License content read, length:" << licenseContent.length();
        
        // Create a temporary file to open with the system's default text editor
        QTemporaryFile tempFile;
        if (tempFile.open()) {
            tempFile.write(licenseContent.toUtf8());
            tempFile.close();
            qDebug() << "Temporary file created:" << tempFile.fileName();
            
            // Open the temporary file with the system's default application
            bool success = QDesktopServices::openUrl(QUrl::fromLocalFile(tempFile.fileName()));
            qDebug() << "Open URL result:" << success;
        } else {
            qDebug() << "Failed to create temporary file";
        }
    } else {
        qDebug() << "Failed to open license file:" << licenseFile.errorString();
    }
}

void AboutWindow::copyVersionInfo()
{
    QString info = formatVersionString();
    QApplication::clipboard()->setText(info);
    emit versionInfoCopied(info);
}

void AboutWindow::copySystemInfo()
{
    QString info = formatSystemString();
    QApplication::clipboard()->setText(info);
    emit systemInfoCopied(info);
}

QString AboutWindow::formatVersionString() const
{
    return QString("%1 %2\nBuild: %3\n%4")
        .arg(m_applicationName)
        .arg(m_applicationVersion)
        .arg(m_applicationBuild)
        .arg(m_copyright);
}

QString AboutWindow::formatBuildString() const
{
    return QString("Build Date: %1\nBuild Time: %2\nCompiler: %3")
        .arg(m_buildDate)
        .arg(m_buildTime)
        .arg(m_compilerInfo);
}

QString AboutWindow::formatSystemString() const
{
    return QString("Platform: %1\nQt Version: %2\nBuild: %3")
        .arg(m_platformInfo)
        .arg(m_qtVersion)
        .arg(m_applicationBuild);
}

} // namespace treon
