#include <QtTest>
#include "treon/JSONParser.hpp"

class TestJSONValidate : public QObject
{
    Q_OBJECT

private slots:
    void testValidObject();
    void testValidArray();
    void testInvalidValue();
};

void TestJSONValidate::testValidObject()
{
    const char* json = "{\"a\":1}";
    QVERIFY(treon::JSONParser::validate(json));
}

void TestJSONValidate::testValidArray()
{
    const char* json = "[1,2,3]";
    QVERIFY(treon::JSONParser::validate(json));
}

void TestJSONValidate::testInvalidValue()
{
    const char* json = "true";
    QVERIFY(!treon::JSONParser::validate(json));
}

QTEST_MAIN(TestJSONValidate)
#include "test_json_validate.moc"

