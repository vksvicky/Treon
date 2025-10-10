#pragma once

#include <QObject>
#include <QString>
#include <QUrl>
#include <memory>

#include "treon/JSONViewModel.hpp"
#include "treon/FileManager.hpp"
#include "treon/ErrorHandler.hpp"

namespace treon {

class Application : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString currentFile READ currentFile NOTIFY currentFileChanged)
    Q_PROPERTY(bool isLoading READ isLoading NOTIFY isLoadingChanged)
    Q_PROPERTY(QString errorMessage READ errorMessage NOTIFY errorMessageChanged)

public:
    explicit Application(QObject *parent = nullptr);
    ~Application() override = default;

    QString currentFile() const { return m_currentFile; }
    bool isLoading() const { return m_isLoading; }
    QString errorMessage() const { return m_errorMessage; }

public slots:
    void openFile();
    void openFile(const QUrl &fileUrl);
    void createNewFile();
    void validateJSON(const QString &jsonText);
    void formatJSON(const QString &jsonText);
    void clearError();

signals:
    void currentFileChanged();
    void isLoadingChanged();
    void errorMessageChanged();
    void jsonLoaded(const QString &formattedJson);
    void jsonValidated(bool isValid);
    void fileOpened(FileInfo* fileInfo);

private slots:
    void onFileOpened(FileInfo* fileInfo);
    void onFileCreated(FileInfo* fileInfo);
    void onFileManagerError(const QString& message, ErrorType type);

private:
    void setCurrentFile(const QString &file);
    void setLoading(bool loading);
    void setErrorMessage(const QString &message);

    QString m_currentFile;
    bool m_isLoading = false;
    QString m_errorMessage;
    std::unique_ptr<JSONViewModel> m_jsonViewModel;
    FileManager* m_fileManager;
    ErrorHandler* m_errorHandler;
};

} // namespace treon
