import QtQuick 2.15

QtObject {
    id: translationUtils
    
    // Property to track language changes for reactivity
    property string currentLanguage: i18nManager ? i18nManager.currentLanguage : "en_GB"
    
    // Custom translation function that works with I18nManager
    function tr(key, context) {
        var ctx = context || "QObject"
        // Force dependency on currentLanguage to make it reactive
        var lang = currentLanguage
        var result = i18nManager ? i18nManager.tr(key, ctx) : key
        console.log("TranslationUtils tr('" + key + "', '" + ctx + "') = '" + result + "' (lang: " + lang + ")")
        return result
    }
    
    // Convenience function for common translations
    function trCommon(key) {
        return tr(key, "QObject")
    }
}
