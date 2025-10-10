#pragma once

#include <QObject>
#include <QString>
#include <QStringList>
#include <QException>
#include <memory>

namespace treon {

// MARK: - Error Types
enum class ErrorType {
    FileNotFound,
    InvalidJSON,
    FileTooLarge,
    UnsupportedFileType,
    PermissionDenied,
    CorruptedFile,
    NetworkError,
    UserCancelled,
    UnknownError,
    InvalidURL,
    CurlCommandFailed,
    EmptyPasteboard,
    LoadingFailed
};

// MARK: - Error Recovery Actions
enum class ErrorRecoveryAction {
    Retry,
    Cancel,
    Ignore,
    OpenSettings,
    ContactSupport
};

// MARK: - Treon Exception
class TreonException : public QException {
public:
    explicit TreonException(ErrorType type, const QString& message = QString());
    explicit TreonException(const QString& message);
    
    ErrorType type() const { return m_type; }
    QString message() const { return m_message; }
    QStringList recoveryActions() const;
    bool isRecoverable() const;
    
    void raise() const override;
    QException* clone() const override;

private:
    static QString getUserFriendlyMessage(ErrorType type);
    static QStringList getRecoveryActions(ErrorType type);
    static bool isErrorRecoverable(ErrorType type);
    
    ErrorType m_type;
    QString m_message;
};

// MARK: - Error Handler
class ErrorHandler : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString currentError READ currentError NOTIFY currentErrorChanged)
    Q_PROPERTY(bool hasError READ hasError NOTIFY hasErrorChanged)
    Q_PROPERTY(QStringList recoveryActions READ recoveryActions NOTIFY recoveryActionsChanged)

public:
    explicit ErrorHandler(QObject* parent = nullptr);
    ~ErrorHandler() override = default;

    QString currentError() const { return m_currentError; }
    bool hasError() const { return !m_currentError.isEmpty(); }
    QStringList recoveryActions() const { return m_recoveryActions; }

public slots:
    void handleError(const TreonException& exception);
    void handleError(ErrorType type, const QString& message = QString());
    void handleError(const QString& message);
    void clearError();
    void performRecoveryAction(ErrorRecoveryAction action);

signals:
    void currentErrorChanged();
    void hasErrorChanged();
    void recoveryActionsChanged();
    void errorOccurred(const QString& message, ErrorType type);

private:
    QString getUserFriendlyMessage(ErrorType type) const;
    QStringList getRecoveryActions(ErrorType type) const;
    bool isErrorRecoverable(ErrorType type) const;
    void updateErrorState(const QString& message, const QStringList& actions);

    QString m_currentError;
    QStringList m_recoveryActions;
};

} // namespace treon
