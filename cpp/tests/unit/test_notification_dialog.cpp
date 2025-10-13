#include <QtTest>
#include <QObject>
#include <QSignalSpy>
#include <QColor>
#include <QString>

// Mock NotificationDialog class for testing
class MockNotificationDialog : public QObject
{
    Q_OBJECT

public:
    explicit MockNotificationDialog(QObject *parent = nullptr) : QObject(parent) {}

    // Properties
    Q_PROPERTY(QString notificationTitle READ notificationTitle WRITE setNotificationTitle NOTIFY notificationTitleChanged)
    Q_PROPERTY(QString notificationText READ notificationText WRITE setNotificationText NOTIFY notificationTextChanged)
    Q_PROPERTY(QColor notificationColor READ notificationColor WRITE setNotificationColor NOTIFY notificationColorChanged)
    Q_PROPERTY(QColor textColor READ textColor WRITE setTextColor NOTIFY textColorChanged)
    Q_PROPERTY(int dialogWidth READ dialogWidth WRITE setDialogWidth NOTIFY dialogWidthChanged)
    Q_PROPERTY(int dialogHeight READ dialogHeight WRITE setDialogHeight NOTIFY dialogHeightChanged)
    Q_PROPERTY(bool isError READ isError WRITE setIsError NOTIFY isErrorChanged)
    Q_PROPERTY(bool modal READ modal WRITE setModal NOTIFY modalChanged)
    Q_PROPERTY(bool visible READ visible WRITE setVisible NOTIFY visibleChanged)

    // Getters
    QString notificationTitle() const { return m_notificationTitle; }
    QString notificationText() const { return m_notificationText; }
    QColor notificationColor() const { return m_notificationColor; }
    QColor textColor() const { return m_textColor; }
    int dialogWidth() const { return m_dialogWidth; }
    int dialogHeight() const { return m_dialogHeight; }
    bool isError() const { return m_isError; }
    bool modal() const { return m_modal; }
    bool visible() const { return m_visible; }

    // Setters
    void setNotificationTitle(const QString &title) {
        if (m_notificationTitle != title) {
            m_notificationTitle = title;
            emit notificationTitleChanged();
        }
    }
    void setNotificationText(const QString &text) {
        if (m_notificationText != text) {
            m_notificationText = text;
            emit notificationTextChanged();
        }
    }
    void setNotificationColor(const QColor &color) {
        if (m_notificationColor != color) {
            m_notificationColor = color;
            emit notificationColorChanged();
        }
    }
    void setTextColor(const QColor &color) {
        if (m_textColor != color) {
            m_textColor = color;
            emit textColorChanged();
        }
    }
    void setDialogWidth(int width) {
        if (m_dialogWidth != width) {
            m_dialogWidth = width;
            emit dialogWidthChanged();
        }
    }
    void setDialogHeight(int height) {
        if (m_dialogHeight != height) {
            m_dialogHeight = height;
            emit dialogHeightChanged();
        }
    }
    void setIsError(bool error) {
        if (m_isError != error) {
            m_isError = error;
            emit isErrorChanged();
        }
    }
    void setModal(bool modal) {
        if (m_modal != modal) {
            m_modal = modal;
            emit modalChanged();
        }
    }
    void setVisible(bool visible) {
        if (m_visible != visible) {
            m_visible = visible;
            emit visibleChanged();
        }
    }

    // Mock methods
    Q_INVOKABLE void showSuccess(const QString &title, const QString &message) {
        setNotificationTitle(title.isEmpty() ? "Success" : title);
        setNotificationText(message.isEmpty() ? "Operation completed successfully" : message);
        setNotificationColor(QColor("#34c759")); // Success green
        setTextColor(QColor("white"));
        setIsError(false);
        setVisible(true);
    }

    Q_INVOKABLE void showError(const QString &title, const QString &message) {
        setNotificationTitle(title.isEmpty() ? "Error" : title);
        setNotificationText(message.isEmpty() ? "An error occurred" : message);
        setNotificationColor(QColor("#ff3b30")); // Error red
        setTextColor(QColor("white"));
        setIsError(true);
        setVisible(true);
    }

    Q_INVOKABLE void showInfo(const QString &title, const QString &message) {
        setNotificationTitle(title.isEmpty() ? "Information" : title);
        setNotificationText(message.isEmpty() ? "Information" : message);
        setNotificationColor(QColor("#007aff")); // Info blue
        setTextColor(QColor("white"));
        setIsError(false);
        setVisible(true);
    }

    Q_INVOKABLE void showWarning(const QString &title, const QString &message) {
        setNotificationTitle(title.isEmpty() ? "Warning" : title);
        setNotificationText(message.isEmpty() ? "Warning" : message);
        setNotificationColor(QColor("#ff9500")); // Warning orange
        setTextColor(QColor("white"));
        setIsError(false);
        setVisible(true);
    }

signals:
    void notificationTitleChanged();
    void notificationTextChanged();
    void notificationColorChanged();
    void textColorChanged();
    void dialogWidthChanged();
    void dialogHeightChanged();
    void isErrorChanged();
    void modalChanged();
    void visibleChanged();

private:
    QString m_notificationTitle = "Notification";
    QString m_notificationText = "";
    QColor m_notificationColor = QColor("#007aff");
    QColor m_textColor = QColor("white");
    int m_dialogWidth = 300;
    int m_dialogHeight = 150;
    bool m_isError = false;
    bool m_modal = true;
    bool m_visible = false;
};

class TestNotificationDialog : public QObject
{
    Q_OBJECT

private slots:
    void initTestCase();
    void cleanupTestCase();
    void init();
    void cleanup();

    // Test dialog creation and basic properties
    void testDialogCreation();
    void testDefaultProperties();
    void testCustomProperties();

    // Test notification types
    void testShowSuccess();
    void testShowError();
    void testShowInfo();
    void testShowWarning();

    // Test dialog behavior
    void testModalBehavior();
    void testSizeConstraints();
    void testButtonFunctionality();

    // Test styling and appearance
    void testSuccessStyling();
    void testErrorStyling();
    void testInfoStyling();
    void testWarningStyling();

    // Test text handling
    void testLongText();
    void testEmptyText();
    void testSpecialCharacters();
    void testUnicodeText();

    // Test signal emissions
    void testSignalEmissions();

private:
    MockNotificationDialog *dialog;
};

void TestNotificationDialog::initTestCase()
{
    // Test suite initialization
}

void TestNotificationDialog::cleanupTestCase()
{
    // Test suite cleanup
}

void TestNotificationDialog::init()
{
    dialog = new MockNotificationDialog(this);
}

void TestNotificationDialog::cleanup()
{
    if (dialog) {
        dialog->deleteLater();
        dialog = nullptr;
    }
}

void TestNotificationDialog::testDialogCreation()
{
    QVERIFY(dialog != nullptr);
    QVERIFY(dialog->visible() == false); // Should not be visible initially
}

void TestNotificationDialog::testDefaultProperties()
{
    QVERIFY(dialog != nullptr);
    
    // Test default property values
    QCOMPARE(dialog->notificationTitle(), QString("Notification"));
    QCOMPARE(dialog->notificationText(), QString(""));
    QCOMPARE(dialog->dialogWidth(), 300);
    QCOMPARE(dialog->dialogHeight(), 150);
    QCOMPARE(dialog->isError(), false);
    QCOMPARE(dialog->modal(), true);
}

void TestNotificationDialog::testCustomProperties()
{
    QVERIFY(dialog != nullptr);
    
    // Set custom properties
    dialog->setNotificationTitle("Custom Title");
    dialog->setNotificationText("Custom Message");
    dialog->setDialogWidth(400);
    dialog->setDialogHeight(200);
    dialog->setIsError(true);
    
    // Verify properties were set
    QCOMPARE(dialog->notificationTitle(), QString("Custom Title"));
    QCOMPARE(dialog->notificationText(), QString("Custom Message"));
    QCOMPARE(dialog->dialogWidth(), 400);
    QCOMPARE(dialog->dialogHeight(), 200);
    QCOMPARE(dialog->isError(), true);
}

void TestNotificationDialog::testShowSuccess()
{
    QVERIFY(dialog != nullptr);
    
    // Call showSuccess method
    dialog->showSuccess("Test Success", "Operation completed successfully");
    
    // Verify properties were set correctly
    QCOMPARE(dialog->notificationTitle(), QString("Test Success"));
    QCOMPARE(dialog->notificationText(), QString("Operation completed successfully"));
    QCOMPARE(dialog->isError(), false);
    QCOMPARE(dialog->visible(), true);
    QCOMPARE(dialog->notificationColor(), QColor("#34c759"));
}

void TestNotificationDialog::testShowError()
{
    QVERIFY(dialog != nullptr);
    
    // Call showError method
    dialog->showError("Test Error", "Something went wrong");
    
    // Verify properties were set correctly
    QCOMPARE(dialog->notificationTitle(), QString("Test Error"));
    QCOMPARE(dialog->notificationText(), QString("Something went wrong"));
    QCOMPARE(dialog->isError(), true);
    QCOMPARE(dialog->visible(), true);
    QCOMPARE(dialog->notificationColor(), QColor("#ff3b30"));
}

void TestNotificationDialog::testShowInfo()
{
    QVERIFY(dialog != nullptr);
    
    // Call showInfo method
    dialog->showInfo("Test Info", "Here is some information");
    
    // Verify properties were set correctly
    QCOMPARE(dialog->notificationTitle(), QString("Test Info"));
    QCOMPARE(dialog->notificationText(), QString("Here is some information"));
    QCOMPARE(dialog->isError(), false);
    QCOMPARE(dialog->visible(), true);
    QCOMPARE(dialog->notificationColor(), QColor("#007aff"));
}

void TestNotificationDialog::testShowWarning()
{
    QVERIFY(dialog != nullptr);
    
    // Call showWarning method
    dialog->showWarning("Test Warning", "Please be careful");
    
    // Verify properties were set correctly
    QCOMPARE(dialog->notificationTitle(), QString("Test Warning"));
    QCOMPARE(dialog->notificationText(), QString("Please be careful"));
    QCOMPARE(dialog->isError(), false);
    QCOMPARE(dialog->visible(), true);
    QCOMPARE(dialog->notificationColor(), QColor("#ff9500"));
}

void TestNotificationDialog::testModalBehavior()
{
    QVERIFY(dialog != nullptr);
    
    // Test that dialog is modal by default
    QCOMPARE(dialog->modal(), true);
    
    // Test changing modal property
    dialog->setModal(false);
    QCOMPARE(dialog->modal(), false);
}

void TestNotificationDialog::testSizeConstraints()
{
    QVERIFY(dialog != nullptr);
    
    // Test default size constraints
    QVERIFY(dialog->dialogWidth() > 0);
    QVERIFY(dialog->dialogHeight() > 0);
    
    // Test setting custom sizes
    dialog->setDialogWidth(400);
    dialog->setDialogHeight(200);
    QCOMPARE(dialog->dialogWidth(), 400);
    QCOMPARE(dialog->dialogHeight(), 200);
}

void TestNotificationDialog::testButtonFunctionality()
{
    QVERIFY(dialog != nullptr);
    
    // Test visibility toggle
    QCOMPARE(dialog->visible(), false);
    dialog->setVisible(true);
    QCOMPARE(dialog->visible(), true);
}

void TestNotificationDialog::testSuccessStyling()
{
    QVERIFY(dialog != nullptr);
    
    // Test success styling
    dialog->showSuccess("Test", "Message");
    
    // Verify styling properties
    QCOMPARE(dialog->isError(), false);
    QCOMPARE(dialog->notificationColor(), QColor("#34c759"));
    QCOMPARE(dialog->textColor(), QColor("white"));
}

void TestNotificationDialog::testErrorStyling()
{
    QVERIFY(dialog != nullptr);
    
    // Test error styling
    dialog->showError("Test", "Message");
    
    // Verify styling properties
    QCOMPARE(dialog->isError(), true);
    QCOMPARE(dialog->notificationColor(), QColor("#ff3b30"));
    QCOMPARE(dialog->textColor(), QColor("white"));
}

void TestNotificationDialog::testInfoStyling()
{
    QVERIFY(dialog != nullptr);
    
    // Test info styling
    dialog->showInfo("Test", "Message");
    
    // Verify styling properties
    QCOMPARE(dialog->isError(), false);
    QCOMPARE(dialog->notificationColor(), QColor("#007aff"));
    QCOMPARE(dialog->textColor(), QColor("white"));
}

void TestNotificationDialog::testWarningStyling()
{
    QVERIFY(dialog != nullptr);
    
    // Test warning styling
    dialog->showWarning("Test", "Message");
    
    // Verify styling properties
    QCOMPARE(dialog->isError(), false);
    QCOMPARE(dialog->notificationColor(), QColor("#ff9500"));
    QCOMPARE(dialog->textColor(), QColor("white"));
}

void TestNotificationDialog::testLongText()
{
    QVERIFY(dialog != nullptr);
    
    QString longText = "This is a very long message that should be handled properly by the dialog. "
                      "It contains multiple sentences and should wrap correctly within the dialog bounds. "
                      "The dialog should adjust its size appropriately to accommodate this longer content.";
    
    dialog->setNotificationText(longText);
    QCOMPARE(dialog->notificationText(), longText);
}

void TestNotificationDialog::testEmptyText()
{
    QVERIFY(dialog != nullptr);
    
    dialog->setNotificationText("");
    QCOMPARE(dialog->notificationText(), QString(""));
}

void TestNotificationDialog::testSpecialCharacters()
{
    QVERIFY(dialog != nullptr);
    
    QString specialText = "Special chars: !@#$%^&*()_+-=[]{}|;':\",./<>?";
    dialog->setNotificationText(specialText);
    QCOMPARE(dialog->notificationText(), specialText);
}

void TestNotificationDialog::testUnicodeText()
{
    QVERIFY(dialog != nullptr);
    
    QString unicodeText = "Unicode: 你好世界 🌍 émojis 🎉";
    dialog->setNotificationText(unicodeText);
    QCOMPARE(dialog->notificationText(), unicodeText);
}

void TestNotificationDialog::testSignalEmissions()
{
    QVERIFY(dialog != nullptr);
    
    // Test signal emissions for property changes
    QSignalSpy titleSpy(dialog, &MockNotificationDialog::notificationTitleChanged);
    QSignalSpy textSpy(dialog, &MockNotificationDialog::notificationTextChanged);
    QSignalSpy colorSpy(dialog, &MockNotificationDialog::notificationColorChanged);
    QSignalSpy visibleSpy(dialog, &MockNotificationDialog::visibleChanged);
    
    // Change properties and verify signals are emitted
    dialog->setNotificationTitle("New Title");
    QCOMPARE(titleSpy.count(), 1);
    
    dialog->setNotificationText("New Text");
    QCOMPARE(textSpy.count(), 1);
    
    dialog->setNotificationColor(QColor("#ff0000"));
    QCOMPARE(colorSpy.count(), 1);
    
    dialog->setVisible(true);
    QCOMPARE(visibleSpy.count(), 1);
    
    // Test that showSuccess emits multiple signals
    titleSpy.clear();
    textSpy.clear();
    colorSpy.clear();
    visibleSpy.clear();
    
    // First set visible to false to ensure the signal is emitted
    dialog->setVisible(false);
    visibleSpy.clear(); // Clear the signal from setVisible
    
    dialog->showSuccess("Success", "Operation completed");
    
    QCOMPARE(titleSpy.count(), 1);
    QCOMPARE(textSpy.count(), 1);
    QCOMPARE(colorSpy.count(), 1);
    QCOMPARE(visibleSpy.count(), 1);
}

QTEST_MAIN(TestNotificationDialog)
#include "test_notification_dialog.moc"
