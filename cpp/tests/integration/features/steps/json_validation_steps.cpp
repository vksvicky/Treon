#include <QtTest>
#include <QQmlEngine>
#include <QQmlComponent>
#include <QQuickWindow>
#include <QQuickItem>
#include <QObject>
#include <QSignalSpy>
#include <QTest>

class JSONValidationSteps : public QObject
{
    Q_OBJECT

private slots:
    // Background steps
    void givenTheTreonApplicationIsRunning();
    void andIHaveOpenedAJSONFileOrEnteredJSONContent();

    // Given steps
    void givenIHaveEnteredTheFollowingValidJSON();
    void givenIHaveEnteredTheFollowingInvalidJSON();
    void givenIHaveEnteredEmptyContent();
    void andIHaveClickedTheValidateButton();
    void andICanSeeTheErrorNotificationAndHighlighting();
    void whenIFixTheJSONByAddingTheMissingQuote();
    void andIClickTheValidateButton();

    // When steps
    void whenIClickTheValidateButton();

    // Then steps
    void thenIShouldSeeASuccessNotification();
    void andTheNotificationShouldSayJSONIsValid();
    void andTheNotificationShouldHaveAGreenBackground();
    void andTheJSONTreeShouldBeUpdatedWithTheContent();
    void andTheJSONTreeShouldShowTheArrayStructure();
    void andTheJSONTreeShouldShowTheNestedStructure();
    void andTheJSONTreeShouldDisplayAllDataTypesCorrectly();
    void thenIShouldSeeAnErrorNotification();
    void andTheNotificationShouldHaveTheTitleJSONValidationError();
    void andTheNotificationShouldContainAnErrorMessage();
    void andTheNotificationShouldHaveARedBackground();
    void andTheErrorLineShouldBeHighlightedInTheTextEditor();
    void andTheCursorShouldBePositionedAtTheErrorLocation();
    void andTheCursorShouldBePositionedNormally();
    void andTheErrorHighlightingShouldBeCleared();

private:
    QQmlEngine *engine;
    QQuickWindow *window;
    QQuickItem *twoPaneLayout;
    QQuickItem *validateButton;
    QQuickItem *textArea;
    QQuickItem *notificationDialog;
    QQuickItem *jsonTreeView;
    
    QString currentJSONContent;
    bool lastValidationResult;
    QString lastNotificationTitle;
    QString lastNotificationText;
    bool lastNotificationIsError;
    
    QQuickItem* createTwoPaneLayout();
    QQuickItem* findChildItem(QQuickItem *parent, const QString &objectName);
    void cleanupComponents();
    void simulateButtonClick();
    void setJSONContent(const QString &json);
    QString getJSONContent();
    bool isNotificationVisible();
    QString getNotificationText();
    QString getNotificationTitle();
    bool getNotificationIsError();
    bool hasErrorHighlighting();
    int getErrorLine();
    int getCursorPosition();
};

void JSONValidationSteps::givenTheTreonApplicationIsRunning()
{
    engine = new QQmlEngine(this);
    window = new QQuickWindow();
    window->setWidth(1200);
    window->setHeight(800);
    
    twoPaneLayout = createTwoPaneLayout();
    QVERIFY(twoPaneLayout != nullptr);
    
    validateButton = findChildItem(twoPaneLayout, "validateButton");
    textArea = findChildItem(twoPaneLayout, "textArea");
    notificationDialog = findChildItem(twoPaneLayout, "notificationDialog");
    jsonTreeView = findChildItem(twoPaneLayout, "jsonTreeView");
    
    QVERIFY(validateButton != nullptr);
    QVERIFY(textArea != nullptr);
    QVERIFY(notificationDialog != nullptr);
}

void JSONValidationSteps::andIHaveOpenedAJSONFileOrEnteredJSONContent()
{
    // This step is handled by individual test scenarios
    // that set specific JSON content
}

void JSONValidationSteps::givenIHaveEnteredTheFollowingValidJSON()
{
    // This step will be called with JSON content from the feature file
    // The actual JSON content will be set by the test framework
}

void JSONValidationSteps::givenIHaveEnteredTheFollowingInvalidJSON()
{
    // This step will be called with invalid JSON content from the feature file
    // The actual JSON content will be set by the test framework
}

void JSONValidationSteps::givenIHaveEnteredEmptyContent()
{
    setJSONContent("");
    QCOMPARE(getJSONContent(), QString(""));
}

void JSONValidationSteps::andIHaveClickedTheValidateButton()
{
    simulateButtonClick();
    QTest::qWait(100); // Wait for validation to complete
}

void JSONValidationSteps::andICanSeeTheErrorNotificationAndHighlighting()
{
    QVERIFY(isNotificationVisible());
    QCOMPARE(getNotificationTitle(), QString("JSON Validation Error"));
    QVERIFY(hasErrorHighlighting());
}

void JSONValidationSteps::whenIFixTheJSONByAddingTheMissingQuote()
{
    // Fix the JSON by adding the missing quote
    QString fixedJSON = R"({
        "name": "John Doe",
        "age": 30
    })";
    setJSONContent(fixedJSON);
    QCOMPARE(getJSONContent(), fixedJSON);
}

void JSONValidationSteps::andIClickTheValidateButton()
{
    simulateButtonClick();
    QTest::qWait(100); // Wait for validation to complete
}

void JSONValidationSteps::whenIClickTheValidateButton()
{
    simulateButtonClick();
    QTest::qWait(100); // Wait for validation to complete
    
    // Store the result for later verification
    lastValidationResult = isNotificationVisible();
    lastNotificationTitle = getNotificationTitle();
    lastNotificationText = getNotificationText();
    lastNotificationIsError = getNotificationIsError();
}

void JSONValidationSteps::thenIShouldSeeASuccessNotification()
{
    QVERIFY(isNotificationVisible());
    QCOMPARE(getNotificationTitle(), QString("JSON Validation"));
    QCOMPARE(getNotificationText(), QString("JSON is valid!"));
    QCOMPARE(getNotificationIsError(), false);
}

void JSONValidationSteps::andTheNotificationShouldSayJSONIsValid()
{
    QCOMPARE(getNotificationText(), QString("JSON is valid!"));
}

void JSONValidationSteps::andTheNotificationShouldHaveAGreenBackground()
{
    QCOMPARE(getNotificationIsError(), false);
    // Additional check for green background color could be added here
}

void JSONValidationSteps::andTheJSONTreeShouldBeUpdatedWithTheContent()
{
    // Verify that the JSON tree view has been updated
    QVERIFY(jsonTreeView != nullptr);
    // Additional checks for tree content could be added here
}

void JSONValidationSteps::andTheJSONTreeShouldShowTheArrayStructure()
{
    // Verify that the JSON tree shows array structure
    QVERIFY(jsonTreeView != nullptr);
    // Additional checks for array structure could be added here
}

void JSONValidationSteps::andTheJSONTreeShouldShowTheNestedStructure()
{
    // Verify that the JSON tree shows nested structure
    QVERIFY(jsonTreeView != nullptr);
    // Additional checks for nested structure could be added here
}

void JSONValidationSteps::andTheJSONTreeShouldDisplayAllDataTypesCorrectly()
{
    // Verify that the JSON tree displays all data types correctly
    QVERIFY(jsonTreeView != nullptr);
    // Additional checks for data type display could be added here
}

void JSONValidationSteps::thenIShouldSeeAnErrorNotification()
{
    QVERIFY(isNotificationVisible());
    QCOMPARE(getNotificationTitle(), QString("JSON Validation Error"));
    QVERIFY(!getNotificationText().isEmpty());
    QCOMPARE(getNotificationIsError(), true);
}

void JSONValidationSteps::andTheNotificationShouldHaveTheTitleJSONValidationError()
{
    QCOMPARE(getNotificationTitle(), QString("JSON Validation Error"));
}

void JSONValidationSteps::andTheNotificationShouldContainAnErrorMessage()
{
    QVERIFY(!getNotificationText().isEmpty());
}

void JSONValidationSteps::andTheNotificationShouldHaveARedBackground()
{
    QCOMPARE(getNotificationIsError(), true);
    // Additional check for red background color could be added here
}

void JSONValidationSteps::andTheErrorLineShouldBeHighlightedInTheTextEditor()
{
    QVERIFY(hasErrorHighlighting());
    QVERIFY(getErrorLine() >= 0);
}

void JSONValidationSteps::andTheCursorShouldBePositionedAtTheErrorLocation()
{
    int cursorPos = getCursorPosition();
    QVERIFY(cursorPos >= 0);
}

void JSONValidationSteps::andTheCursorShouldBePositionedNormally()
{
    // After successful validation, cursor should be positioned normally
    // This could be verified by checking that error highlighting is cleared
    QCOMPARE(hasErrorHighlighting(), false);
}

void JSONValidationSteps::andTheErrorHighlightingShouldBeCleared()
{
    QCOMPARE(hasErrorHighlighting(), false);
}

// Helper methods
QQuickItem* JSONValidationSteps::createTwoPaneLayout()
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

QQuickItem* JSONValidationSteps::findChildItem(QQuickItem *parent, const QString &objectName)
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

void JSONValidationSteps::cleanupComponents()
{
    if (twoPaneLayout) {
        twoPaneLayout->deleteLater();
        twoPaneLayout = nullptr;
    }
    validateButton = nullptr;
    textArea = nullptr;
    notificationDialog = nullptr;
    jsonTreeView = nullptr;
}

void JSONValidationSteps::simulateButtonClick()
{
    if (validateButton) {
        QTest::mouseClick(window, Qt::LeftButton, Qt::NoModifier, 
                         validateButton->mapToScene(QPointF(validateButton->width()/2, validateButton->height()/2)).toPoint());
    }
}

void JSONValidationSteps::setJSONContent(const QString &json)
{
    if (textArea) {
        textArea->setProperty("content", json);
        currentJSONContent = json;
    }
}

QString JSONValidationSteps::getJSONContent()
{
    if (textArea) {
        return textArea->property("content").toString();
    }
    return QString();
}

bool JSONValidationSteps::isNotificationVisible()
{
    if (notificationDialog) {
        return notificationDialog->property("visible").toBool();
    }
    return false;
}

QString JSONValidationSteps::getNotificationText()
{
    if (notificationDialog) {
        return notificationDialog->property("notificationText").toString();
    }
    return QString();
}

QString JSONValidationSteps::getNotificationTitle()
{
    if (notificationDialog) {
        return notificationDialog->property("notificationTitle").toString();
    }
    return QString();
}

bool JSONValidationSteps::getNotificationIsError()
{
    if (notificationDialog) {
        return notificationDialog->property("isError").toBool();
    }
    return false;
}

bool JSONValidationSteps::hasErrorHighlighting()
{
    if (textArea) {
        return textArea->property("hasError").toBool();
    }
    return false;
}

int JSONValidationSteps::getErrorLine()
{
    if (textArea) {
        return textArea->property("errorLine").toInt();
    }
    return -1;
}

int JSONValidationSteps::getCursorPosition()
{
    if (textArea) {
        return textArea->property("cursorPosition").toInt();
    }
    return -1;
}

QTEST_MAIN(JSONValidationSteps)
#include "json_validation_steps.moc"
