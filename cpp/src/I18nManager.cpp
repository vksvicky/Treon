#include "treon/I18nManager.hpp"
#include <QDebug>
#include <QDir>
#include <QStandardPaths>
#include <QCoreApplication>
#include <QLocale>

namespace treon {

const QString I18nManager::DEFAULT_LANGUAGE = "en";

I18nManager::I18nManager(QObject *parent)
    : QObject(parent)
    , m_translator(nullptr)
    , m_currentLanguage(DEFAULT_LANGUAGE)
{
    setupLanguageMap();
    initializeTranslations();
}

I18nManager::~I18nManager()
{
    if (m_translator) {
        QCoreApplication::removeTranslator(m_translator);
        delete m_translator;
    }
}

void I18nManager::setupLanguageMap()
{
    m_availableLanguages = QStringList() 
        << "en" << "es" << "fr" << "de" << "it" << "pt" << "ru" << "ja" << "ko" << "zh";
    
    // English names
    m_languageNames["en"] = "English";
    m_languageNames["es"] = "Spanish";
    m_languageNames["fr"] = "French";
    m_languageNames["de"] = "German";
    m_languageNames["it"] = "Italian";
    m_languageNames["pt"] = "Portuguese";
    m_languageNames["ru"] = "Russian";
    m_languageNames["ja"] = "Japanese";
    m_languageNames["ko"] = "Korean";
    m_languageNames["zh"] = "Chinese";
    
    // Native names
    m_languageNativeNames["en"] = "English";
    m_languageNativeNames["es"] = "Español";
    m_languageNativeNames["fr"] = "Français";
    m_languageNativeNames["de"] = "Deutsch";
    m_languageNativeNames["it"] = "Italiano";
    m_languageNativeNames["pt"] = "Português";
    m_languageNativeNames["ru"] = "Русский";
    m_languageNativeNames["ja"] = "日本語";
    m_languageNativeNames["ko"] = "한국어";
    m_languageNativeNames["zh"] = "中文";
}

void I18nManager::initializeTranslations()
{
    m_translator = new QTranslator(this);
    loadSystemLanguage();
}

QString I18nManager::currentLanguage() const
{
    return m_currentLanguage;
}

void I18nManager::setCurrentLanguage(const QString &language)
{
    if (m_currentLanguage != language && m_availableLanguages.contains(language)) {
        loadLanguage(language);
    }
}

QStringList I18nManager::availableLanguages() const
{
    return m_availableLanguages;
}

QStringList I18nManager::availableLanguageNames() const
{
    QStringList names;
    for (const QString &lang : m_availableLanguages) {
        names << getLanguageName(lang);
    }
    return names;
}

QString I18nManager::tr(const QString &key, const QString &context) const
{
    if (context.isEmpty()) {
        return QCoreApplication::translate("Treon", key.toUtf8().constData());
    } else {
        return QCoreApplication::translate(context.toUtf8().constData(), key.toUtf8().constData());
    }
}

QString I18nManager::tr(const QString &key, const QString &context, int n) const
{
    if (context.isEmpty()) {
        return QCoreApplication::translate("Treon", key.toUtf8().constData(), nullptr, n);
    } else {
        return QCoreApplication::translate(context.toUtf8().constData(), key.toUtf8().constData(), nullptr, n);
    }
}

void I18nManager::loadLanguage(const QString &language)
{
    if (loadTranslationFile(language)) {
        m_currentLanguage = language;
        emit currentLanguageChanged();
        emit languageChanged(language);
        emit translationsLoaded();
    }
}

void I18nManager::loadSystemLanguage()
{
    QLocale systemLocale = QLocale::system();
    QString systemLanguage = systemLocale.name().left(2); // Get language code (e.g., "en" from "en_US")
    
    if (m_availableLanguages.contains(systemLanguage)) {
        loadLanguage(systemLanguage);
    } else {
        loadLanguage(DEFAULT_LANGUAGE);
    }
}

QString I18nManager::getLanguageName(const QString &languageCode) const
{
    return m_languageNames.value(languageCode, languageCode);
}

QString I18nManager::getLanguageNativeName(const QString &languageCode) const
{
    return m_languageNativeNames.value(languageCode, languageCode);
}

QLocale I18nManager::getLocale(const QString &languageCode) const
{
    return QLocale(languageCode);
}

void I18nManager::switchLanguage(const QString &language)
{
    setCurrentLanguage(language);
}

void I18nManager::reloadTranslations()
{
    loadLanguage(m_currentLanguage);
}

QString I18nManager::getTranslationFilePath(const QString &language) const
{
    // Look for translation files in several locations
    QStringList searchPaths;
    
    // Application directory
    searchPaths << QCoreApplication::applicationDirPath() + "/translations";
    searchPaths << QCoreApplication::applicationDirPath() + "/../translations";
    
    // Resources
    searchPaths << ":/translations";
    
    // System paths
    searchPaths << QStandardPaths::locateAll(QStandardPaths::AppDataLocation, "translations", QStandardPaths::LocateDirectory);
    
    QString fileName = QString("treon_%1.qm").arg(language);
    
    for (const QString &path : searchPaths) {
        QString filePath = QDir(path).filePath(fileName);
        if (QFile::exists(filePath)) {
            return filePath;
        }
    }
    
    return QString();
}

bool I18nManager::loadTranslationFile(const QString &language)
{
    // Remove existing translator
    if (m_translator) {
        QCoreApplication::removeTranslator(m_translator);
    }
    
    QString filePath = getTranslationFilePath(language);
    if (filePath.isEmpty()) {
        qDebug() << "Translation file not found for language:" << language;
        return false;
    }
    
    if (m_translator->load(filePath)) {
        QCoreApplication::installTranslator(m_translator);
        qDebug() << "Loaded translation file:" << filePath;
        return true;
    } else {
        qDebug() << "Failed to load translation file:" << filePath;
        return false;
    }
}

// Global translation functions
QString tr(const QString &key, const QString &context)
{
    return QCoreApplication::translate(context.isEmpty() ? "Treon" : context.toUtf8().constData(), 
                                      key.toUtf8().constData());
}

QString tr(const QString &key, const QString &context, int n)
{
    return QCoreApplication::translate(context.isEmpty() ? "Treon" : context.toUtf8().constData(), 
                                      key.toUtf8().constData(), nullptr, n);
}

} // namespace treon
