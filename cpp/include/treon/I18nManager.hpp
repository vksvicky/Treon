#pragma once

#include <QObject>
#include <QString>
#include <QStringList>
#include <QTranslator>
#include <QLocale>
#include <QApplication>

namespace treon {

class I18nManager : public QObject
{
    Q_OBJECT
    
    // Properties
    Q_PROPERTY(QString currentLanguage READ currentLanguage WRITE setCurrentLanguage NOTIFY currentLanguageChanged)
    Q_PROPERTY(QStringList availableLanguages READ availableLanguages CONSTANT)
    Q_PROPERTY(QStringList availableLanguageNames READ availableLanguageNames CONSTANT)

public:
    explicit I18nManager(QObject *parent = nullptr);
    ~I18nManager();

    // Language management
    QString currentLanguage() const;
    void setCurrentLanguage(const QString &language);
    QStringList availableLanguages() const;
    QStringList availableLanguageNames() const;
    
    // Translation methods
    QString tr(const QString &key, const QString &context = QString()) const;
    QString tr(const QString &key, const QString &context, int n) const;
    
    // Utility methods
    void loadLanguage(const QString &language);
    void loadSystemLanguage();
    QString getLanguageName(const QString &languageCode) const;
    QString getLanguageNativeName(const QString &languageCode) const;
    QLocale getLocale(const QString &languageCode) const;

public slots:
    void switchLanguage(const QString &language);
    void reloadTranslations();

signals:
    void currentLanguageChanged();
    void languageChanged(const QString &language);
    void translationsLoaded();

private:
    void initializeTranslations();
    void setupLanguageMap();
    QString getTranslationFilePath(const QString &language) const;
    bool loadTranslationFile(const QString &language);
    
    QTranslator *m_translator;
    QString m_currentLanguage;
    QStringList m_availableLanguages;
    QMap<QString, QString> m_languageNames;
    QMap<QString, QString> m_languageNativeNames;
    
    // Default language
    static const QString DEFAULT_LANGUAGE;
};

// Global translation function
QString tr(const QString &key, const QString &context = QString());
QString tr(const QString &key, const QString &context, int n);

} // namespace treon
