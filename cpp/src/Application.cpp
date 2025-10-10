#include "treon/Application.hpp"
#include "treon/JSONParser.hpp"

#include <QDebug>

using namespace treon;

Application::Application(QObject *parent)
    : QObject(parent)
    , m_jsonViewModel(std::make_unique<JSONViewModel>())
    , m_fileManager(&FileManager::instance())
    , m_errorHandler(new ErrorHandler(this))
{
    // Connect to FileManager signals
    connect(m_fileManager, &FileManager::fileOpened, this, &Application::onFileOpened);
    connect(m_fileManager, &FileManager::fileCreated, this, &Application::onFileCreated);
    connect(m_fileManager, &FileManager::isLoadingChanged, this, [this]() {
        setLoading(m_fileManager->isLoading());
    });
    connect(m_fileManager, &FileManager::errorMessageChanged, this, [this]() {
        setErrorMessage(m_fileManager->errorMessage());
    });
    
    // Connect to ErrorHandler signals
    connect(m_errorHandler, &ErrorHandler::errorOccurred, this, &Application::onFileManagerError);
}

void Application::openFile()
{
    m_fileManager->openFile();
}

void Application::openFile(const QUrl &fileUrl)
{
    m_fileManager->openFile(fileUrl);
}

void Application::createNewFile()
{
    m_fileManager->createNewFile();
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

void Application::clearError()
{
    setErrorMessage("");
    m_errorHandler->clearError();
}

void Application::onFileOpened(FileInfo* fileInfo)
{
    if (fileInfo) {
        setCurrentFile(fileInfo->url().toLocalFile());
        emit jsonLoaded(fileInfo->content());
        emit fileOpened(fileInfo);
    }
}

void Application::onFileCreated(FileInfo* fileInfo)
{
    if (fileInfo) {
        setCurrentFile(fileInfo->url().toLocalFile());
        emit jsonLoaded(fileInfo->content());
        emit fileOpened(fileInfo);
    }
}

void Application::onFileManagerError(const QString& message, ErrorType type)
{
    setErrorMessage(message);
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
