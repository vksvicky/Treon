#include "treon/JSONViewModel.hpp"
#include "treon/JSONParser.hpp"

using namespace treon;

JSONViewModel::JSONViewModel(QObject *parent)
    : QObject(parent)
{
}

void JSONViewModel::setJSON(const QString &json)
{
    if (m_jsonText != json) {
        m_jsonText = json;
        emit jsonTextChanged();
        updateValidation();
    }
}

void JSONViewModel::clear()
{
    if (!m_jsonText.isEmpty()) {
        m_jsonText.clear();
        emit jsonTextChanged();
        updateValidation();
    }
}

void JSONViewModel::updateValidation()
{
    const bool wasValid = m_isValid;
    
    if (m_jsonText.isEmpty()) {
        m_isValid = false;
        m_rootNode = nullptr;
    } else {
        const std::string jsonStd = m_jsonText.toStdString();
        m_isValid = JSONParser::validate(jsonStd);
        
        if (m_isValid) {
            m_rootNode = JSONParser::parse(jsonStd);
        } else {
            m_rootNode = nullptr;
        }
    }
    
    if (m_isValid != wasValid) {
        emit isValidChanged();
    }
}
