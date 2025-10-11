#include <QCoreApplication>
#include <QDebug>
#include <QTimer>
#include "json_benchmark_suite.hpp"

int main(int argc, char *argv[])
{
    QCoreApplication app(argc, argv);
    
    qDebug() << "Treon JSON Performance Benchmark Runner";
    qDebug() << "========================================";
    
    // Create and run benchmark suite
    JSONBenchmarkSuite benchmarkSuite;
    
    // Run benchmark in a single shot
    QTimer::singleShot(0, [&benchmarkSuite]() {
        benchmarkSuite.runFullBenchmark();
        QCoreApplication::quit();
    });
    
    return app.exec();
}
