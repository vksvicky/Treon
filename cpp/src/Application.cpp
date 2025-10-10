#include "treon/Application.h"
#include "treon/JSONParser.h"

#include <QFile>
#include <QTextStream>
#include <QDebug>

using namespace treon;

Application::Application(QObject *parent)
    : QObject(parent)
    , m_jsonViewModel(std::make_unique<JSONViewModel>())
{
}

void Application::openFile(const QUrl &fileUrl)
{
    if (!fileUrl.isLocalFile()) {
        setErrorMessage("Only local files are supported");
        return;
    }

    setLoading(true);
    setErrorMessage("");

    const QString filePath = fileUrl.toLocalFile();
    QFile file(filePath);
    
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        setErrorMessage("Failed to open file: " + file.errorString());
        setLoading(false);
        return;
    }

    QTextStream in(&file);
    const QString jsonContent = in.readAll();
    file.close();

    if (jsonContent.isEmpty()) {
        setErrorMessage("File is empty");
        setLoading(false);
        return;
    }

    // Validate JSON
    const std::string jsonStd = jsonContent.toStdString();
    if (!JSONParser::validate(jsonStd)) {
        setErrorMessage("Invalid JSON format");
        setLoading(false);
        return;
    }

    setCurrentFile(filePath);
    emit jsonLoaded(jsonContent);
    setLoading(false);
}

void Application::validateJSON(const QString &jsonText)
{
    const std::string jsonStd = jsonText.toStdString();
    const bool isValid = JSONParser::validate(jsonStd);
    emit jsonValidated(isValid);
    
    if (!isValid) {
        setErrorMessage("Invalid JSON format");
    } else {
        setErrorMessage("");
    }
}

void Application::formatJSON(const QString &jsonText)
{
    // Placeholder for JSON formatting
    // Will be implemented with proper indentation
    emit jsonLoaded(jsonText);
}

void Application::setCurrentFile(const QString &file)
{
    if (m_currentFile != file) {
        m_currentFile = file;
        emit currentFileChanged();
    }
}

void Application::setLoading(bool loading)
{
    if (m_isLoading != loading) {
        m_isLoading = loading;
        emit isLoadingChanged();
    }
}

void Application::setErrorMessage(const QString &message)
{
    if (m_errorMessage != message) {
        m_errorMessage = message;
        emit errorMessageChanged();
    }
}
