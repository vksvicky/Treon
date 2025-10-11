# Treon Test Suite

This directory contains the comprehensive test suite for the Treon JSON viewer application.

## Directory Structure

```
tests/
├── unit/                    # Unit tests for individual components
├── benchmark/               # Performance and benchmark tests
│   └── json/               # JSON-specific benchmarks
├── integration/            # Integration tests
│   └── features/           # BDD-style integration tests
├── common/                 # Shared test utilities and helpers
├── main_test.cpp           # Main test runner
└── CMakeLists.txt
```

## Test Categories

### Unit Tests (`unit/`)
- **Purpose**: Test individual components in isolation
- **Scope**: Single classes, methods, and functions
- **Examples**: Application class, AboutWindow class, SettingsManager
- **Framework**: Qt Test Framework

### Benchmark Tests (`benchmark/`)
- **Purpose**: Performance testing and optimization
- **Scope**: JSON processing performance, file I/O performance
- **Examples**: JSON parsing speed, file reading throughput
- **Framework**: Custom benchmark framework

### Integration Tests (`integration/`)
- **Purpose**: Test component interactions and workflows
- **Scope**: End-to-end functionality, user workflows
- **Examples**: About window display, file operations
- **Framework**: BDD-style with Gherkin features

### Common Utilities (`common/`)
- **Purpose**: Shared test helpers and utilities
- **Scope**: Test data generation, assertions, logging
- **Examples**: JSON test data, performance measurement helpers

## Running Tests

### All Tests
```bash
./scripts/run_tests.sh
```

### Unit Tests Only
```bash
cd cpp/build
ctest -R unit
```

### Benchmark Tests Only
```bash
./scripts/run_json_benchmark.sh
```

### Integration Tests Only
```bash
cd cpp/build
ctest -R integration
```

## Test Configuration

- **Test Data**: Generated in `~/Documents/TreonTestData/`
- **Reports**: Generated in `~/Documents/TreonBenchmarks/`
- **Temporary Files**: Created in system temp directory

## Adding New Tests

1. **Unit Tests**: Add to `unit/` directory
2. **Benchmark Tests**: Add to `benchmark/` directory
3. **Integration Tests**: Add to `integration/features/` directory
4. **Common Utilities**: Add to `common/` directory

## Best Practices

- Use descriptive test names
- Include both positive and negative test cases
- Add performance benchmarks for critical paths
- Keep tests independent and isolated
- Use common utilities for shared functionality
- Document test purpose and expected behavior
