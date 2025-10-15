#include "I18nManager.hpp"
#include <QDebug>
#include <QDir>
#include <QStandardPaths>
#include <QCoreApplication>
#include <QLocale>
#include <QResource>
#include <QFileInfo>
#include <QSet>

namespace treon {

const QString I18nManager::DEFAULT_LANGUAGE = "en_GB";
const QStringList I18nManager::SUPPORTED_LANGUAGES = {"en_GB", "en_US", "es", "fr"};

I18nManager::I18nManager(QObject *parent)
    : QObject(parent)
    , m_translator(nullptr)
    , m_currentLanguage(DEFAULT_LANGUAGE)
{
    setupLanguageMap();
    setupSupportedLanguages();
    discoverAvailableLanguages();
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
    // English names
    m_languageNames["en_GB"] = "English (UK)";
    m_languageNames["en_US"] = "English (US)";
    m_languageNames["es"] = "Spanish";
    m_languageNames["fr"] = "French";
    
    // Native names
    m_languageNativeNames["en_GB"] = "English (UK)";
    m_languageNativeNames["en_US"] = "English (US)";
    m_languageNativeNames["es"] = "Español";
    m_languageNativeNames["fr"] = "Français";
}

void I18nManager::setupSupportedLanguages()
{
    // Set up flag paths for supported languages
    m_languageFlagPaths["en_GB"] = "qrc:/en_GB.svg";
    m_languageFlagPaths["en_US"] = "qrc:/en_US.svg";
    m_languageFlagPaths["es"] = "qrc:/es.svg";
    m_languageFlagPaths["fr"] = "qrc:/fr.svg";
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

QStringList I18nManager::availableLanguageNativeNames() const
{
    QStringList names;
    for (const QString &lang : m_availableLanguages) {
        names << getLanguageNativeName(lang);
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
    
    // Map language codes to actual file names
    QString fileLanguage = language;
    if (language == "en_GB") {
        fileLanguage = "en_GB";
    } else if (language == "en_US") {
        fileLanguage = "en"; // en_US maps to treon_en.qm
    }
    
    QString fileName = QString("treon_%1.qm").arg(fileLanguage);
    
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

void I18nManager::discoverAvailableLanguages()
{
    m_availableLanguages.clear();
    QSet<QString> uniqueLanguages; // Use QSet to avoid duplicates
    
    // Scan for available translation files
    QStringList foundFiles = scanForTranslationFiles();
    
    // Map found files to language codes
    for (const QString &file : foundFiles) {
        QString languageCode = mapLanguageCodeToFile(file);
        if (!languageCode.isEmpty() && SUPPORTED_LANGUAGES.contains(languageCode) && !uniqueLanguages.contains(languageCode)) {
            m_availableLanguages << languageCode;
            uniqueLanguages.insert(languageCode);
        }
    }
    
    // Always include default language if no translations found
    if (m_availableLanguages.isEmpty()) {
        m_availableLanguages << DEFAULT_LANGUAGE;
    }
    
    // Sort languages for consistent ordering
    m_availableLanguages.sort();
    
    qDebug() << "Discovered available languages:" << m_availableLanguages;
    emit languageDiscoveryCompleted();
}

bool I18nManager::isLanguageSupported(const QString &language) const
{
    return SUPPORTED_LANGUAGES.contains(language);
}

QString I18nManager::getLanguageFlagPath(const QString &languageCode) const
{
    return m_languageFlagPaths.value(languageCode, "");
}

QStringList I18nManager::scanForTranslationFiles() const
{
    QStringList foundFiles;
    QSet<QString> uniqueFiles; // Use QSet to avoid duplicates
    
    // Search paths for translation files
    QStringList searchPaths;
    searchPaths << ":/translations";
    searchPaths << QCoreApplication::applicationDirPath() + "/translations";
    searchPaths << QCoreApplication::applicationDirPath() + "/../Resources/translations";
    searchPaths << QStandardPaths::locateAll(QStandardPaths::AppDataLocation, "translations", QStandardPaths::LocateDirectory);
    
    for (const QString &path : searchPaths) {
        QDir dir(path);
        if (dir.exists()) {
            QStringList filters;
            filters << "treon_*.qm";
            QStringList files = dir.entryList(filters, QDir::Files);
            
            for (const QString &file : files) {
                QString fullPath = dir.absoluteFilePath(file);
                if (QFileInfo(fullPath).exists() && !uniqueFiles.contains(fullPath)) {
                    foundFiles << fullPath;
                    uniqueFiles.insert(fullPath);
                }
            }
        }
    }
    
    return foundFiles;
}

QString I18nManager::mapLanguageCodeToFile(const QString &filePath) const
{
    QFileInfo fileInfo(filePath);
    QString fileName = fileInfo.baseName();
    
    // Extract language code from filename (e.g., "treon_en_GB.qm" -> "en_GB")
    if (fileName.startsWith("treon_")) {
        QString languageCode = fileName.mid(6); // Remove "treon_" prefix
        
        // Handle special cases
        if (languageCode == "en") {
            languageCode = "en_US"; // treon_en.qm maps to en_US
        }
        
        return languageCode;
    }
    
    return QString();
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
