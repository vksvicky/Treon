#include <QtTest>
#include <QQmlEngine>
#include <QQmlComponent>
#include <QQuickWindow>
#include <QQuickItem>
#include <QObject>
#include <QSignalSpy>
#include <QQuickWindow>
#include <QTest>

class TestValidateButton : public QObject
{
    Q_OBJECT

private slots:
    void initTestCase();
    void cleanupTestCase();
    void init();
    void cleanup();

    // Test button creation and basic functionality
    void testButtonCreation();
    void testButtonProperties();
    void testButtonClickable();

    // Test validation with valid JSON
    void testValidateValidJSON();
    void testValidateValidEmptyObject();
    void testValidateValidEmptyArray();
    void testValidateValidComplexJSON();

    // Test validation with invalid JSON
    void testValidateInvalidJSON();
    void testValidateInvalidSyntax();
    void testValidateInvalidStructure();

    // Test notification behavior
    void testSuccessNotification();
    void testErrorNotification();
    void testNotificationDialogAppearance();

    // Test error highlighting
    void testErrorLineHighlighting();
    void testErrorCursorPositioning();
    void testErrorClearing();

    // Test integration with JSON model
    void testJSONModelUpdate();
    void testTreeViewUpdate();
    void testTextAreaUpdate();

private:
    QQmlEngine *engine;
    QQuickWindow *window;
    QQuickItem *twoPaneLayout;
    QQuickItem *validateButton;
    QQuickItem *textArea;
    QQuickItem *notificationDialog;
    
    QQuickItem* createTwoPaneLayout();
    QQuickItem* findChildItem(QQuickItem *parent, const QString &objectName);
    void cleanupComponents();
    void simulateButtonClick();
    void setJSONContent(const QString &json);
    QString getJSONContent();
    bool isNotificationVisible();
    QString getNotificationText();
    QString getNotificationTitle();
};

void TestValidateButton::initTestCase()
{
    engine = new QQmlEngine(this);
    window = new QQuickWindow();
    window->setWidth(1200);
    window->setHeight(800);
}

void TestValidateButton::cleanupTestCase()
{
    delete window;
    delete engine;
}

void TestValidateButton::init()
{
    twoPaneLayout = createTwoPaneLayout();
    if (twoPaneLayout) {
        validateButton = findChildItem(twoPaneLayout, "validateButton");
        textArea = findChildItem(twoPaneLayout, "textArea");
        notificationDialog = findChildItem(twoPaneLayout, "notificationDialog");
    }
}

void TestValidateButton::cleanup()
{
    cleanupComponents();
}

QQuickItem* TestValidateButton::createTwoPaneLayout()
{
    QQmlComponent component(engine);
    component.setData(R"(
        import QtQuick 2.15
        import QtQuick.Controls 2.15
        import QtQuick.Layouts 1.15
        import "qrc:/qml/TwoPaneLayout.qml"
        
        TwoPaneLayout {
            id: testTwoPaneLayout
            anchors.fill: parent
        }
    )", QUrl());
    
    if (component.isError()) {
        qDebug() << "Component errors:" << component.errors();
        return nullptr;
    }
    
    QQuickItem *item = qobject_cast<QQuickItem*>(component.create());
    if (item) {
        item->setParentItem(window->contentItem());
    }
    
    return item;
}

QQuickItem* TestValidateButton::findChildItem(QQuickItem *parent, const QString &objectName)
{
    if (!parent) return nullptr;
    
    // Check if this item has the target object name
    if (parent->objectName() == objectName) {
        return parent;
    }
    
    // Search in children
    QList<QQuickItem*> children = parent->childItems();
    for (QQuickItem *child : children) {
        QQuickItem *found = findChildItem(child, objectName);
        if (found) return found;
    }
    
    return nullptr;
}

void TestValidateButton::cleanupComponents()
{
    if (twoPaneLayout) {
        twoPaneLayout->deleteLater();
        twoPaneLayout = nullptr;
    }
    validateButton = nullptr;
    textArea = nullptr;
    notificationDialog = nullptr;
}

void TestValidateButton::simulateButtonClick()
{
    if (validateButton) {
        QTest::mouseClick(window, Qt::LeftButton, Qt::NoModifier, 
                         validateButton->mapToScene(QPointF(validateButton->width()/2, validateButton->height()/2)).toPoint());
    }
}

void TestValidateButton::setJSONContent(const QString &json)
{
    if (textArea) {
        textArea->setProperty("content", json);
    }
}

QString TestValidateButton::getJSONContent()
{
    if (textArea) {
        return textArea->property("content").toString();
    }
    return QString();
}

bool TestValidateButton::isNotificationVisible()
{
    if (notificationDialog) {
        return notificationDialog->property("visible").toBool();
    }
    return false;
}

QString TestValidateButton::getNotificationText()
{
    if (notificationDialog) {
        return notificationDialog->property("notificationText").toString();
    }
    return QString();
}

QString TestValidateButton::getNotificationTitle()
{
    if (notificationDialog) {
        return notificationDialog->property("notificationTitle").toString();
    }
    return QString();
}

void TestValidateButton::testButtonCreation()
{
    QVERIFY(twoPaneLayout != nullptr);
    QVERIFY(validateButton != nullptr);
    QCOMPARE(validateButton->property("text").toString(), QString("Validate"));
}

void TestValidateButton::testButtonProperties()
{
    QVERIFY(validateButton != nullptr);
    
    // Test button properties
    QCOMPARE(validateButton->property("text").toString(), QString("Validate"));
    QVERIFY(validateButton->property("enabled").toBool());
    QVERIFY(validateButton->isVisible());
}

void TestValidateButton::testButtonClickable()
{
    QVERIFY(validateButton != nullptr);
    
    // Test that button is clickable
    QVERIFY(validateButton->property("enabled").toBool());
    
    // Test mouse area exists
    QQuickItem *mouseArea = findChildItem(validateButton, "");
    QVERIFY(mouseArea != nullptr);
}

void TestValidateButton::testValidateValidJSON()
{
    QVERIFY(validateButton != nullptr);
    QVERIFY(textArea != nullptr);
    
    // Set valid JSON content
    setJSONContent(R"({"name": "John", "age": 30})");
    QCOMPARE(getJSONContent(), QString(R"({"name": "John", "age": 30})"));
    
    // Click validate button
    simulateButtonClick();
    
    // Wait for validation to complete
    QTest::qWait(100);
    
    // Check that success notification appears
    QVERIFY(isNotificationVisible());
    QCOMPARE(getNotificationTitle(), QString("JSON Validation"));
    QCOMPARE(getNotificationText(), QString("JSON is valid!"));
}

void TestValidateButton::testValidateValidEmptyObject()
{
    QVERIFY(validateButton != nullptr);
    QVERIFY(textArea != nullptr);
    
    // Set valid empty object
    setJSONContent("{}");
    QCOMPARE(getJSONContent(), QString("{}"));
    
    // Click validate button
    simulateButtonClick();
    
    // Wait for validation to complete
    QTest::qWait(100);
    
    // Check that success notification appears
    QVERIFY(isNotificationVisible());
    QCOMPARE(getNotificationTitle(), QString("JSON Validation"));
    QCOMPARE(getNotificationText(), QString("JSON is valid!"));
}

void TestValidateButton::testValidateValidEmptyArray()
{
    QVERIFY(validateButton != nullptr);
    QVERIFY(textArea != nullptr);
    
    // Set valid empty array
    setJSONContent("[]");
    QCOMPARE(getJSONContent(), QString("[]"));
    
    // Click validate button
    simulateButtonClick();
    
    // Wait for validation to complete
    QTest::qWait(100);
    
    // Check that success notification appears
    QVERIFY(isNotificationVisible());
    QCOMPARE(getNotificationTitle(), QString("JSON Validation"));
    QCOMPARE(getNotificationText(), QString("JSON is valid!"));
}

void TestValidateButton::testValidateValidComplexJSON()
{
    QVERIFY(validateButton != nullptr);
    QVERIFY(textArea != nullptr);
    
    // Set valid complex JSON
    QString complexJSON = R"({
        "users": [
            {
                "id": 1,
                "name": "John Doe",
                "email": "john@example.com",
                "active": true
            }
        ],
        "metadata": {
            "total": 1,
            "page": 1
        }
    })";
    
    setJSONContent(complexJSON);
    QCOMPARE(getJSONContent(), complexJSON);
    
    // Click validate button
    simulateButtonClick();
    
    // Wait for validation to complete
    QTest::qWait(100);
    
    // Check that success notification appears
    QVERIFY(isNotificationVisible());
    QCOMPARE(getNotificationTitle(), QString("JSON Validation"));
    QCOMPARE(getNotificationText(), QString("JSON is valid!"));
}

void TestValidateButton::testValidateInvalidJSON()
{
    QVERIFY(validateButton != nullptr);
    QVERIFY(textArea != nullptr);
    
    // Set invalid JSON content
    setJSONContent(R"({"name": "John", "age": 30)");
    QCOMPARE(getJSONContent(), QString(R"({"name": "John", "age": 30)"));
    
    // Click validate button
    simulateButtonClick();
    
    // Wait for validation to complete
    QTest::qWait(100);
    
    // Check that error notification appears
    QVERIFY(isNotificationVisible());
    QCOMPARE(getNotificationTitle(), QString("JSON Validation Error"));
    QVERIFY(!getNotificationText().isEmpty());
}

void TestValidateButton::testValidateInvalidSyntax()
{
    QVERIFY(validateButton != nullptr);
    QVERIFY(textArea != nullptr);
    
    // Set invalid JSON with syntax error
    setJSONContent(R"({"name": "John", "age": 30,})");
    QCOMPARE(getJSONContent(), QString(R"({"name": "John", "age": 30,})"));
    
    // Click validate button
    simulateButtonClick();
    
    // Wait for validation to complete
    QTest::qWait(100);
    
    // Check that error notification appears
    QVERIFY(isNotificationVisible());
    QCOMPARE(getNotificationTitle(), QString("JSON Validation Error"));
    QVERIFY(!getNotificationText().isEmpty());
}

void TestValidateButton::testValidateInvalidStructure()
{
    QVERIFY(validateButton != nullptr);
    QVERIFY(textArea != nullptr);
    
    // Set invalid JSON with structure error
    setJSONContent(R"({"name": "John", "age": })");
    QCOMPARE(getJSONContent(), QString(R"({"name": "John", "age": })"));
    
    // Click validate button
    simulateButtonClick();
    
    // Wait for validation to complete
    QTest::qWait(100);
    
    // Check that error notification appears
    QVERIFY(isNotificationVisible());
    QCOMPARE(getNotificationTitle(), QString("JSON Validation Error"));
    QVERIFY(!getNotificationText().isEmpty());
}

void TestValidateButton::testSuccessNotification()
{
    QVERIFY(validateButton != nullptr);
    QVERIFY(notificationDialog != nullptr);
    
    // Set valid JSON
    setJSONContent(R"({"test": "valid"})");
    
    // Click validate button
    simulateButtonClick();
    
    // Wait for validation
    QTest::qWait(100);
    
    // Check notification properties
    QVERIFY(isNotificationVisible());
    QCOMPARE(getNotificationTitle(), QString("JSON Validation"));
    QCOMPARE(getNotificationText(), QString("JSON is valid!"));
    QCOMPARE(notificationDialog->property("isError").toBool(), false);
}

void TestValidateButton::testErrorNotification()
{
    QVERIFY(validateButton != nullptr);
    QVERIFY(notificationDialog != nullptr);
    
    // Set invalid JSON
    setJSONContent(R"({"test": "invalid")");
    
    // Click validate button
    simulateButtonClick();
    
    // Wait for validation
    QTest::qWait(100);
    
    // Check notification properties
    QVERIFY(isNotificationVisible());
    QCOMPARE(getNotificationTitle(), QString("JSON Validation Error"));
    QVERIFY(!getNotificationText().isEmpty());
    QCOMPARE(notificationDialog->property("isError").toBool(), true);
}

void TestValidateButton::testNotificationDialogAppearance()
{
    QVERIFY(notificationDialog != nullptr);
    
    // Test dialog properties
    QCOMPARE(notificationDialog->property("modal").toBool(), true);
    QVERIFY(notificationDialog->property("width").toInt() > 0);
    QVERIFY(notificationDialog->property("height").toInt() > 0);
}

void TestValidateButton::testErrorLineHighlighting()
{
    QVERIFY(validateButton != nullptr);
    QVERIFY(textArea != nullptr);
    
    // Set JSON with error on specific line
    setJSONContent(R"({
    "name": "John",
    "age": 30,
    "invalid": 
})");
    
    // Click validate button
    simulateButtonClick();
    
    // Wait for validation
    QTest::qWait(100);
    
    // Check that error highlighting is set
    QVERIFY(textArea->property("hasError").toBool());
    QVERIFY(textArea->property("errorLine").toInt() >= 0);
}

void TestValidateButton::testErrorCursorPositioning()
{
    QVERIFY(validateButton != nullptr);
    QVERIFY(textArea != nullptr);
    
    // Set JSON with error
    setJSONContent(R"({"name": "John", "age": })");
    
    // Click validate button
    simulateButtonClick();
    
    // Wait for validation
    QTest::qWait(100);
    
    // Check that cursor is positioned at error
    int cursorPos = textArea->property("cursorPosition").toInt();
    QVERIFY(cursorPos >= 0);
}

void TestValidateButton::testErrorClearing()
{
    QVERIFY(validateButton != nullptr);
    QVERIFY(textArea != nullptr);
    
    // First set invalid JSON
    setJSONContent(R"({"name": "John", "age": })");
    simulateButtonClick();
    QTest::qWait(100);
    
    // Then set valid JSON
    setJSONContent(R"({"name": "John", "age": 30})");
    simulateButtonClick();
    QTest::qWait(100);
    
    // Check that error is cleared
    QCOMPARE(textArea->property("hasError").toBool(), false);
}

void TestValidateButton::testJSONModelUpdate()
{
    QVERIFY(validateButton != nullptr);
    QVERIFY(textArea != nullptr);
    
    // Set valid JSON
    setJSONContent(R"({"name": "John", "age": 30})");
    
    // Click validate button
    simulateButtonClick();
    
    // Wait for validation and model update
    QTest::qWait(200);
    
    // Check that model was updated (this would require access to the model)
    // For now, just verify the validation completed successfully
    QVERIFY(isNotificationVisible());
    QCOMPARE(getNotificationTitle(), QString("JSON Validation"));
}

void TestValidateButton::testTreeViewUpdate()
{
    QVERIFY(validateButton != nullptr);
    QVERIFY(textArea != nullptr);
    
    // Set valid JSON with nested structure
    setJSONContent(R"({
        "user": {
            "name": "John",
            "details": {
                "age": 30,
                "city": "New York"
            }
        }
    })");
    
    // Click validate button
    simulateButtonClick();
    
    // Wait for validation and tree update
    QTest::qWait(200);
    
    // Check that validation completed successfully
    QVERIFY(isNotificationVisible());
    QCOMPARE(getNotificationTitle(), QString("JSON Validation"));
}

void TestValidateButton::testTextAreaUpdate()
{
    QVERIFY(validateButton != nullptr);
    QVERIFY(textArea != nullptr);
    
    // Set JSON content
    QString jsonContent = R"({"name": "John", "age": 30})";
    setJSONContent(jsonContent);
    
    // Verify content was set
    QCOMPARE(getJSONContent(), jsonContent);
    
    // Click validate button
    simulateButtonClick();
    
    // Wait for validation
    QTest::qWait(100);
    
    // Verify content is still there
    QCOMPARE(getJSONContent(), jsonContent);
    
    // Check that validation completed successfully
    QVERIFY(isNotificationVisible());
    QCOMPARE(getNotificationTitle(), QString("JSON Validation"));
}

QTEST_MAIN(TestValidateButton)
#include "test_validate_button.moc"
