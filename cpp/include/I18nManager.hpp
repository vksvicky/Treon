#pragma once

#include <QObject>
#include <QString>
#include <QStringList>
#include <QTranslator>
#include <QLocale>
#include <QApplication>
#include <QMap>
#include <QDir>

namespace treon {

class I18nManager : public QObject
{
    Q_OBJECT
    
    // Properties
    Q_PROPERTY(QString currentLanguage READ currentLanguage WRITE setCurrentLanguage NOTIFY currentLanguageChanged)
    Q_PROPERTY(QStringList availableLanguages READ availableLanguages CONSTANT)
    Q_PROPERTY(QStringList availableLanguageNames READ availableLanguageNames CONSTANT)
    Q_PROPERTY(QStringList availableLanguageNativeNames READ availableLanguageNativeNames CONSTANT)

public:
    explicit I18nManager(QObject *parent = nullptr);
    ~I18nManager();

    // Language management
    QString currentLanguage() const;
    void setCurrentLanguage(const QString &language);
    QStringList availableLanguages() const;
    QStringList availableLanguageNames() const;
    QStringList availableLanguageNativeNames() const;
    
    // Translation methods
    Q_INVOKABLE QString tr(const QString &key, const QString &context = QString()) const;
    Q_INVOKABLE QString tr(const QString &key, const QString &context, int n) const;
    
    // Utility methods
    void loadLanguage(const QString &language);
    void loadSystemLanguage();
    Q_INVOKABLE QString getLanguageName(const QString &languageCode) const;
    Q_INVOKABLE QString getLanguageNativeName(const QString &languageCode) const;
    Q_INVOKABLE QString getLanguageFlagPath(const QString &languageCode) const;
    Q_INVOKABLE QLocale getLocale(const QString &languageCode) const;
    
    // Language discovery
    void discoverAvailableLanguages();
    bool isLanguageSupported(const QString &language) const;

public slots:
    void switchLanguage(const QString &language);
    void reloadTranslations();

signals:
    void currentLanguageChanged();
    void languageChanged(const QString &language);
    void translationsLoaded();
    void languageDiscoveryCompleted();

private:
    void initializeTranslations();
    void setupLanguageMap();
    void setupSupportedLanguages();
    QString getTranslationFilePath(const QString &language) const;
    bool loadTranslationFile(const QString &language);
    QStringList scanForTranslationFiles() const;
    QString mapLanguageCodeToFile(const QString &language) const;
    
    QTranslator *m_translator;
    QString m_currentLanguage;
    QStringList m_availableLanguages;
    QMap<QString, QString> m_languageNames;
    QMap<QString, QString> m_languageNativeNames;
    QMap<QString, QString> m_languageFlagPaths;
    
    // Default language - British English
    static const QString DEFAULT_LANGUAGE;
    
    // Supported languages
    static const QStringList SUPPORTED_LANGUAGES;
};

// Global translation function
QString tr(const QString &key, const QString &context = QString());
QString tr(const QString &key, const QString &context, int n);

} // namespace treon
