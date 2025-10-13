#ifndef TEST_APPLICATION_HPP
#define TEST_APPLICATION_HPP

#include <QtTest>
#include <QSignalSpy>
#include "Application.hpp"

class TestApplication : public QObject
{
    Q_OBJECT

private slots:
    void initTestCase();
    void cleanupTestCase();
    void testApplicationCreation();
    void testFileOperations();
    void testJSONValidation();

private:
    treon::Application *m_app;
};

#endif // TEST_APPLICATION_HPP