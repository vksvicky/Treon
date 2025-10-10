#include "treon/ErrorHandler.hpp"
#include "treon/Constants.hpp"

#include <QDebug>
#include <QDesktopServices>
#include <QUrl>
#include <QDateTime>

using namespace treon;

// MARK: - TreonException Implementation

TreonException::TreonException(ErrorType type, const QString& message)
    : m_type(type)
    , m_message(message.isEmpty() ? TreonException::getUserFriendlyMessage(type) : message)
{
}

TreonException::TreonException(const QString& message)
    : m_type(ErrorType::UnknownError)
    , m_message(message)
{
}

QStringList TreonException::recoveryActions() const {
    return TreonException::getRecoveryActions(m_type);
}

bool TreonException::isRecoverable() const {
    return TreonException::isErrorRecoverable(m_type);
}

void TreonException::raise() const {
    throw *this;
}

QException* TreonException::clone() const {
    return new TreonException(*this);
}

QString TreonException::getUserFriendlyMessage(ErrorType type) {
    switch (type) {
        case ErrorType::FileNotFound: return ErrorMessages::fileNotFound;
        case ErrorType::InvalidJSON: return ErrorMessages::invalidJSON;
        case ErrorType::FileTooLarge: return ErrorMessages::fileTooLarge;
        case ErrorType::UnsupportedFileType: return ErrorMessages::unsupportedFileType;
        case ErrorType::PermissionDenied: return ErrorMessages::permissionDenied;
        case ErrorType::CorruptedFile: return ErrorMessages::corruptedFile;
        case ErrorType::NetworkError: return ErrorMessages::networkError;
        case ErrorType::UserCancelled: return ErrorMessages::userCancelled;
        case ErrorType::InvalidURL: return ErrorMessages::invalidURL;
        case ErrorType::CurlCommandFailed: return ErrorMessages::curlCommandFailed;
        case ErrorType::EmptyPasteboard: return ErrorMessages::emptyPasteboard;
        case ErrorType::LoadingFailed: return ErrorMessages::loadingFailed;
        case ErrorType::UnknownError: return ErrorMessages::unknownError;
    }
    return ErrorMessages::unknownError;
}

QStringList TreonException::getRecoveryActions(ErrorType type) {
    QStringList actions;
    actions << "Cancel";
    
    if (isErrorRecoverable(type)) {
        actions.prepend("Retry");
    }
    
    switch (type) {
        case ErrorType::PermissionDenied:
            actions << "Settings";
            break;
        case ErrorType::NetworkError:
        case ErrorType::UnknownError:
            actions << "Contact Support";
            break;
        default:
            break;
    }
    
    return actions;
}

bool TreonException::isErrorRecoverable(ErrorType type) {
    switch (type) {
        case ErrorType::FileNotFound:
        case ErrorType::PermissionDenied:
        case ErrorType::NetworkError:
        case ErrorType::UnknownError:
            return true;
        case ErrorType::UserCancelled:
        case ErrorType::InvalidJSON:
        case ErrorType::FileTooLarge:
        case ErrorType::UnsupportedFileType:
        case ErrorType::CorruptedFile:
        case ErrorType::InvalidURL:
        case ErrorType::CurlCommandFailed:
        case ErrorType::EmptyPasteboard:
        case ErrorType::LoadingFailed:
            return false;
    }
    return false;
}

// MARK: - ErrorHandler Implementation

ErrorHandler::ErrorHandler(QObject* parent)
    : QObject(parent)
{
}

void ErrorHandler::handleError(const TreonException& exception) {
    qDebug() << "Error occurred:" << exception.message();
    
    const QString message = exception.message();
    const QStringList actions = exception.recoveryActions();
    
    updateErrorState(message, actions);
    emit errorOccurred(message, exception.type());
}

void ErrorHandler::handleError(ErrorType type, const QString& message) {
    TreonException exception(type, message);
    handleError(exception);
}

void ErrorHandler::handleError(const QString& message) {
    TreonException exception(message);
    handleError(exception);
}

void ErrorHandler::clearError() {
    if (!m_currentError.isEmpty()) {
        m_currentError.clear();
        m_recoveryActions.clear();
        emit currentErrorChanged();
        emit hasErrorChanged();
        emit recoveryActionsChanged();
    }
}

void ErrorHandler::performRecoveryAction(ErrorRecoveryAction action) {
    switch (action) {
        case ErrorRecoveryAction::Retry:
            // Retry logic would be implemented based on context
            clearError();
            break;
        case ErrorRecoveryAction::Cancel:
        case ErrorRecoveryAction::Ignore:
            clearError();
            break;
        case ErrorRecoveryAction::OpenSettings:
            // Open system preferences
            QDesktopServices::openUrl(QUrl("x-apple.systempreferences:com.apple.preference.security?Privacy"));
            clearError();
            break;
        case ErrorRecoveryAction::ContactSupport:
            // Open email client
            {
                const QString subject = "Treon Support Request";
                const QString body = QString("Error Details:\n- App Version: %1\n- Build: %2\n- Error: %3\n- Timestamp: %4\n\nPlease describe what you were doing when this error occurred:\n\n")
                    .arg(AppConstants::version)
                    .arg(AppConstants::buildNumber)
                    .arg(m_currentError)
                    .arg(QDateTime::currentDateTime().toString());
                
                const QString mailtoUrl = QString("mailto:%1?subject=%2&body=%3")
                    .arg(AppConstants::supportEmail)
                    .arg(QUrl::toPercentEncoding(subject))
                    .arg(QUrl::toPercentEncoding(body));
                
                QDesktopServices::openUrl(QUrl(mailtoUrl));
            }
            clearError();
            break;
    }
}

QString ErrorHandler::getUserFriendlyMessage(ErrorType type) const {
    switch (type) {
        case ErrorType::FileNotFound: return ErrorMessages::fileNotFound;
        case ErrorType::InvalidJSON: return ErrorMessages::invalidJSON;
        case ErrorType::FileTooLarge: return ErrorMessages::fileTooLarge;
        case ErrorType::UnsupportedFileType: return ErrorMessages::unsupportedFileType;
        case ErrorType::PermissionDenied: return ErrorMessages::permissionDenied;
        case ErrorType::CorruptedFile: return ErrorMessages::corruptedFile;
        case ErrorType::NetworkError: return ErrorMessages::networkError;
        case ErrorType::UserCancelled: return ErrorMessages::userCancelled;
        case ErrorType::InvalidURL: return ErrorMessages::invalidURL;
        case ErrorType::CurlCommandFailed: return ErrorMessages::curlCommandFailed;
        case ErrorType::EmptyPasteboard: return ErrorMessages::emptyPasteboard;
        case ErrorType::LoadingFailed: return ErrorMessages::loadingFailed;
        case ErrorType::UnknownError: return ErrorMessages::unknownError;
    }
    return ErrorMessages::unknownError;
}

QStringList ErrorHandler::getRecoveryActions(ErrorType type) const {
    QStringList actions;
    actions << "Cancel";
    
    if (isErrorRecoverable(type)) {
        actions.prepend("Retry");
    }
    
    switch (type) {
        case ErrorType::PermissionDenied:
            actions << "Settings";
            break;
        case ErrorType::NetworkError:
        case ErrorType::UnknownError:
            actions << "Contact Support";
            break;
        default:
            break;
    }
    
    return actions;
}

bool ErrorHandler::isErrorRecoverable(ErrorType type) const {
    switch (type) {
        case ErrorType::FileNotFound:
        case ErrorType::PermissionDenied:
        case ErrorType::NetworkError:
        case ErrorType::UnknownError:
            return true;
        default:
            return false;
    }
}

void ErrorHandler::updateErrorState(const QString& message, const QStringList& actions) {
    m_currentError = message;
    m_recoveryActions = actions;
    emit currentErrorChanged();
    emit hasErrorChanged();
    emit recoveryActionsChanged();
}
