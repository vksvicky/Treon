#include <QtTest>
#include <QJsonDocument>
#include <QJsonParseError>
#include <QString>
#include <QObject>

class TestJSONValidation : public QObject
{
    Q_OBJECT

private slots:
    void initTestCase();
    void cleanupTestCase();
    void init();
    void cleanup();

    // Test valid JSON cases
    void testValidEmptyObject();
    void testValidEmptyArray();
    void testValidSimpleObject();
    void testValidSimpleArray();
    void testValidNestedObject();
    void testValidNestedArray();
    void testValidComplexJSON();
    void testValidJSONWithAllTypes();

    // Test invalid JSON cases
    void testInvalidEmptyString();
    void testInvalidMissingClosingBrace();
    void testInvalidMissingClosingBracket();
    void testInvalidTrailingComma();
    void testInvalidUnquotedKey();
    void testInvalidSingleQuote();
    void testInvalidUnescapedQuote();
    void testInvalidUnterminatedString();
    void testInvalidUnexpectedToken();

    // Test edge cases
    void testVeryLargeValidJSON();
    void testJSONWithUnicode();
    void testJSONWithSpecialCharacters();
    void testJSONWithNumbers();
    void testJSONWithBooleans();
    void testJSONWithNull();

private:
    bool validateJSON(const QString &json, QString &errorMessage, int &errorOffset);
    QJsonDocument parseJSON(const QString &json, QJsonParseError &error);
};

void TestJSONValidation::initTestCase()
{
    // Test suite initialization
}

void TestJSONValidation::cleanupTestCase()
{
    // Test suite cleanup
}

void TestJSONValidation::init()
{
    // Test case initialization
}

void TestJSONValidation::cleanup()
{
    // Test case cleanup
}

bool TestJSONValidation::validateJSON(const QString &json, QString &errorMessage, int &errorOffset)
{
    QJsonParseError error;
    QJsonDocument doc = QJsonDocument::fromJson(json.toUtf8(), &error);
    
    if (error.error == QJsonParseError::NoError) {
        errorMessage = "";
        errorOffset = -1;
        return true;
    } else {
        errorMessage = error.errorString();
        errorOffset = static_cast<int>(error.offset);
        return false;
    }
}

QJsonDocument TestJSONValidation::parseJSON(const QString &json, QJsonParseError &error)
{
    return QJsonDocument::fromJson(json.toUtf8(), &error);
}

// Test valid JSON cases
void TestJSONValidation::testValidEmptyObject()
{
    QString json = "{}";
    QString errorMessage;
    int errorOffset;
    
    QVERIFY(validateJSON(json, errorMessage, errorOffset));
    QVERIFY(errorMessage.isEmpty());
    QCOMPARE(errorOffset, -1);
}

void TestJSONValidation::testValidEmptyArray()
{
    QString json = "[]";
    QString errorMessage;
    int errorOffset;
    
    QVERIFY(validateJSON(json, errorMessage, errorOffset));
    QVERIFY(errorMessage.isEmpty());
    QCOMPARE(errorOffset, -1);
}

void TestJSONValidation::testValidSimpleObject()
{
    QString json = R"({"name": "John", "age": 30})";
    QString errorMessage;
    int errorOffset;
    
    QVERIFY(validateJSON(json, errorMessage, errorOffset));
    QVERIFY(errorMessage.isEmpty());
    QCOMPARE(errorOffset, -1);
}

void TestJSONValidation::testValidSimpleArray()
{
    QString json = R"([1, 2, 3, "hello", true])";
    QString errorMessage;
    int errorOffset;
    
    QVERIFY(validateJSON(json, errorMessage, errorOffset));
    QVERIFY(errorMessage.isEmpty());
    QCOMPARE(errorOffset, -1);
}

void TestJSONValidation::testValidNestedObject()
{
    QString json = R"({
        "user": {
            "name": "John",
            "address": {
                "street": "123 Main St",
                "city": "New York"
            }
        }
    })";
    QString errorMessage;
    int errorOffset;
    
    QVERIFY(validateJSON(json, errorMessage, errorOffset));
    QVERIFY(errorMessage.isEmpty());
    QCOMPARE(errorOffset, -1);
}

void TestJSONValidation::testValidNestedArray()
{
    QString json = R"([
        [1, 2, 3],
        ["a", "b", "c"],
        [true, false, null]
    ])";
    QString errorMessage;
    int errorOffset;
    
    QVERIFY(validateJSON(json, errorMessage, errorOffset));
    QVERIFY(errorMessage.isEmpty());
    QCOMPARE(errorOffset, -1);
}

void TestJSONValidation::testValidComplexJSON()
{
    QString json = R"({
        "users": [
            {
                "id": 1,
                "name": "John Doe",
                "email": "john@example.com",
                "active": true,
                "profile": {
                    "age": 30,
                    "city": "New York",
                    "interests": ["programming", "music", "travel"]
                }
            },
            {
                "id": 2,
                "name": "Jane Smith",
                "email": "jane@example.com",
                "active": false,
                "profile": {
                    "age": 25,
                    "city": "San Francisco",
                    "interests": ["art", "photography"]
                }
            }
        ],
        "metadata": {
            "total": 2,
            "page": 1,
            "per_page": 10
        }
    })";
    QString errorMessage;
    int errorOffset;
    
    QVERIFY(validateJSON(json, errorMessage, errorOffset));
    QVERIFY(errorMessage.isEmpty());
    QCOMPARE(errorOffset, -1);
}

void TestJSONValidation::testValidJSONWithAllTypes()
{
    QString json = R"({
        "string": "hello world",
        "number": 42,
        "float": 3.14159,
        "boolean_true": true,
        "boolean_false": false,
        "null_value": null,
        "array": [1, 2, 3],
        "object": {"nested": "value"}
    })";
    QString errorMessage;
    int errorOffset;
    
    QVERIFY(validateJSON(json, errorMessage, errorOffset));
    QVERIFY(errorMessage.isEmpty());
    QCOMPARE(errorOffset, -1);
}

// Test invalid JSON cases
void TestJSONValidation::testInvalidEmptyString()
{
    QString json = "";
    QString errorMessage;
    int errorOffset;
    
    QVERIFY(!validateJSON(json, errorMessage, errorOffset));
    QVERIFY(!errorMessage.isEmpty());
    QVERIFY(errorOffset >= 0);
}

void TestJSONValidation::testInvalidMissingClosingBrace()
{
    QString json = R"({"name": "John", "age": 30)";
    QString errorMessage;
    int errorOffset;
    
    QVERIFY(!validateJSON(json, errorMessage, errorOffset));
    QVERIFY(!errorMessage.isEmpty());
    QVERIFY(errorOffset >= 0);
}

void TestJSONValidation::testInvalidMissingClosingBracket()
{
    QString json = R"([1, 2, 3, "hello")";
    QString errorMessage;
    int errorOffset;
    
    QVERIFY(!validateJSON(json, errorMessage, errorOffset));
    QVERIFY(!errorMessage.isEmpty());
    QVERIFY(errorOffset >= 0);
}

void TestJSONValidation::testInvalidTrailingComma()
{
    QString json = R"({"name": "John", "age": 30,})";
    QString errorMessage;
    int errorOffset;
    
    QVERIFY(!validateJSON(json, errorMessage, errorOffset));
    QVERIFY(!errorMessage.isEmpty());
    QVERIFY(errorOffset >= 0);
}

void TestJSONValidation::testInvalidUnquotedKey()
{
    QString json = R"({name: "John", "age": 30})";
    QString errorMessage;
    int errorOffset;
    
    QVERIFY(!validateJSON(json, errorMessage, errorOffset));
    QVERIFY(!errorMessage.isEmpty());
    QVERIFY(errorOffset >= 0);
}

void TestJSONValidation::testInvalidSingleQuote()
{
    QString json = R"({'name': 'John', 'age': 30})";
    QString errorMessage;
    int errorOffset;
    
    QVERIFY(!validateJSON(json, errorMessage, errorOffset));
    QVERIFY(!errorMessage.isEmpty());
    QVERIFY(errorOffset >= 0);
}

void TestJSONValidation::testInvalidUnescapedQuote()
{
    QString json = R"({"name": "John "Doe"", "age": 30})";
    QString errorMessage;
    int errorOffset;
    
    QVERIFY(!validateJSON(json, errorMessage, errorOffset));
    QVERIFY(!errorMessage.isEmpty());
    QVERIFY(errorOffset >= 0);
}

void TestJSONValidation::testInvalidUnterminatedString()
{
    QString json = R"({"name": "John, "age": 30})";
    QString errorMessage;
    int errorOffset;
    
    QVERIFY(!validateJSON(json, errorMessage, errorOffset));
    QVERIFY(!errorMessage.isEmpty());
    QVERIFY(errorOffset >= 0);
}


void TestJSONValidation::testInvalidUnexpectedToken()
{
    QString json = R"({"name": "John", "age": 30, "extra": })";
    QString errorMessage;
    int errorOffset;
    
    QVERIFY(!validateJSON(json, errorMessage, errorOffset));
    QVERIFY(!errorMessage.isEmpty());
    QVERIFY(errorOffset >= 0);
}

// Test edge cases
void TestJSONValidation::testVeryLargeValidJSON()
{
    QString json = "{";
    for (int i = 0; i < 1000; ++i) {
        json += QString(R"("key%1": "value%1")").arg(i);
        if (i < 999) json += ", ";
    }
    json += "}";
    
    QString errorMessage;
    int errorOffset;
    
    QVERIFY(validateJSON(json, errorMessage, errorOffset));
    QVERIFY(errorMessage.isEmpty());
    QCOMPARE(errorOffset, -1);
}

void TestJSONValidation::testJSONWithUnicode()
{
    QString json = R"({"name": "José", "city": "São Paulo", "emoji": "😀"})";
    QString errorMessage;
    int errorOffset;
    
    QVERIFY(validateJSON(json, errorMessage, errorOffset));
    QVERIFY(errorMessage.isEmpty());
    QCOMPARE(errorOffset, -1);
}

void TestJSONValidation::testJSONWithSpecialCharacters()
{
    QString json = R"({"path": "C:\\Users\\John", "regex": "\\d+", "quotes": "\"hello\""})";
    QString errorMessage;
    int errorOffset;
    
    QVERIFY(validateJSON(json, errorMessage, errorOffset));
    QVERIFY(errorMessage.isEmpty());
    QCOMPARE(errorOffset, -1);
}

void TestJSONValidation::testJSONWithNumbers()
{
    QString json = R"({
        "integer": 42,
        "negative": -42,
        "float": 3.14159,
        "scientific": 1.23e-4,
        "zero": 0,
        "large": 999999999
    })";
    QString errorMessage;
    int errorOffset;
    
    QVERIFY(validateJSON(json, errorMessage, errorOffset));
    QVERIFY(errorMessage.isEmpty());
    QCOMPARE(errorOffset, -1);
}

void TestJSONValidation::testJSONWithBooleans()
{
    QString json = R"({"true": true, "false": false})";
    QString errorMessage;
    int errorOffset;
    
    QVERIFY(validateJSON(json, errorMessage, errorOffset));
    QVERIFY(errorMessage.isEmpty());
    QCOMPARE(errorOffset, -1);
}

void TestJSONValidation::testJSONWithNull()
{
    QString json = R"({"value": null, "other": "not null"})";
    QString errorMessage;
    int errorOffset;
    
    QVERIFY(validateJSON(json, errorMessage, errorOffset));
    QVERIFY(errorMessage.isEmpty());
    QCOMPARE(errorOffset, -1);
}

QTEST_MAIN(TestJSONValidation)
#include "test_json_validation.moc"
