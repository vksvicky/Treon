#pragma once

#include <QObject>
#include <QString>
#include <QUrl>
#include <QVersionNumber>
#include <QDate>

namespace treon {

class AboutWindow : public QObject
{
    Q_OBJECT
    
    // Application information properties
    Q_PROPERTY(QString applicationName READ applicationName CONSTANT)
    Q_PROPERTY(QString applicationVersion READ applicationVersion CONSTANT)
    Q_PROPERTY(QString applicationBuild READ applicationBuild CONSTANT)
    Q_PROPERTY(QString organizationName READ organizationName CONSTANT)
    Q_PROPERTY(QString organizationDomain READ organizationDomain CONSTANT)
    Q_PROPERTY(QString copyright READ copyright CONSTANT)
    Q_PROPERTY(QString license READ license CONSTANT)
    Q_PROPERTY(QString licenseFilePath READ licenseFilePath CONSTANT)
    
    // System information properties
    Q_PROPERTY(QString qtVersion READ qtVersion CONSTANT)
    Q_PROPERTY(QString buildDate READ buildDate CONSTANT)
    Q_PROPERTY(QString buildTime READ buildTime CONSTANT)
    Q_PROPERTY(QString compilerInfo READ compilerInfo CONSTANT)
    Q_PROPERTY(QString platformInfo READ platformInfo CONSTANT)
    
    // UI state properties
    Q_PROPERTY(bool isVisible READ isVisible WRITE setIsVisible NOTIFY isVisibleChanged)
    Q_PROPERTY(QString iconPath READ iconPath CONSTANT)
    Q_PROPERTY(QString logoPath READ logoPath CONSTANT)
    
    // Credits and acknowledgments
    Q_PROPERTY(QStringList credits READ credits CONSTANT)
    Q_PROPERTY(QStringList acknowledgments READ acknowledgments CONSTANT)
    Q_PROPERTY(QStringList thirdPartyLibraries READ thirdPartyLibraries CONSTANT)

public:
    explicit AboutWindow(QObject *parent = nullptr);
    ~AboutWindow();

    // Application information getters
    QString applicationName() const;
    QString applicationVersion() const;
    QString applicationBuild() const;
    QString organizationName() const;
    QString organizationDomain() const;
    QString copyright() const;
    QString license() const;
    QString licenseFilePath() const;
    
    // System information getters
    QString qtVersion() const;
    QString buildDate() const;
    QString buildTime() const;
    QString compilerInfo() const;
    QString platformInfo() const;
    
    // UI state getters/setters
    bool isVisible() const;
    void setIsVisible(bool visible);
    QString iconPath() const;
    QString logoPath() const;
    
    // Credits and acknowledgments getters
    QStringList credits() const;
    QStringList acknowledgments() const;
    QStringList thirdPartyLibraries() const;

public slots:
    // Window management
    void show();
    void hide();
    void toggle();
    void open();
    
    // Information retrieval
    QString getSystemInfo() const;
    QString getVersionInfo() const;
    QString getBuildInfo() const;
    
    // External actions
    void openWebsite();
    void openDocumentation();
    void openSupport();
    void openLicense();
    void copyVersionInfo();
    void copySystemInfo();

signals:
    // UI state signals
    void isVisibleChanged();
    
    // Action signals
    void websiteRequested(const QString &url);
    void documentationRequested(const QString &url);
    void supportRequested(const QString &url);
    void licenseRequested(const QString &url);
    void versionInfoCopied(const QString &info);
    void systemInfoCopied(const QString &info);

private:
    void initializeApplicationInfo();
    void initializeSystemInfo();
    void initializeCredits();
    void initializeThirdPartyLibraries();
    
    QString formatVersionString() const;
    QString formatBuildString() const;
    QString formatSystemString() const;
    
    // Application information
    QString m_applicationName;
    QString m_applicationVersion;
    QString m_applicationBuild;
    QString m_organizationName;
    QString m_organizationDomain;
    QString m_copyright;
    QString m_license;
    
    // System information
    QString m_qtVersion;
    QString m_buildDate;
    QString m_buildTime;
    QString m_compilerInfo;
    QString m_platformInfo;
    
    // UI state
    bool m_isVisible;
    QString m_iconPath;
    QString m_logoPath;
    
    // Credits and acknowledgments
    QStringList m_credits;
    QStringList m_acknowledgments;
    QStringList m_thirdPartyLibraries;
};

} // namespace treon
