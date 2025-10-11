# JSON Performance Testing Framework

This directory contains a comprehensive JSON performance testing framework for the Treon application. The framework is designed to be flexible, configurable, and easy to use.

## Overview

The JSON testing framework consists of several components:

- **JSONPerformanceTest**: Qt Test-based performance tests
- **JSONBenchmarkSuite**: Standalone benchmark runner with detailed reporting
- **JSONDataGenerator**: Generates test JSON files of various sizes
- **JSONTestConfig**: Configuration system for test parameters

## Quick Start

### 1. Run Quick Tests (Recommended for Development)
```bash
./scripts/configure_json_tests.sh
# Choose option 2: Run quick tests (10KB - 1MB)
```

### 2. Run Full Test Suite
```bash
./scripts/run_json_benchmark.sh
```

### 3. Configure Custom Tests
```bash
./scripts/configure_json_tests.sh
# Choose option 5: Enable/disable specific test sizes
```

## Test Sizes

The framework supports the following test sizes:

| Size | Label | Bytes | Default Status |
|------|-------|-------|----------------|
| 10kb | 10KB | 10,240 | ✅ Enabled |
| 35kb | 35KB | 35,840 | ✅ Enabled |
| 50kb | 50KB | 51,200 | ✅ Enabled |
| 1mb | 1MB | 1,048,576 | ✅ Enabled |
| 5mb | 5MB | 5,242,880 | ✅ Enabled |
| 25mb | 25MB | 26,214,400 | ✅ Enabled |
| 50mb | 50MB | 52,428,800 | ✅ Enabled |
| 100mb | 100MB | 104,857,600 | ✅ Enabled |
| 500mb | 500MB | 524,288,000 | ❌ Disabled |
| 1gb | 1GB | 1,073,741,824 | ❌ Disabled |

## Configuration

### JSON Configuration File
The test configuration is stored in `json_test_config.json`:

```json
{
  "testSizes": {
    "10kb": {
      "label": "10KB",
      "sizeBytes": 10240,
      "enabled": true
    }
  },
  "performanceThresholds": {
    "generation": 10000,
    "write": 5000,
    "read": 2000,
    "parse": 10000,
    "validation": 5000
  }
}
```

### Programmatic Configuration
You can also configure tests programmatically:

```cpp
JSONTestConfig& config = JSONTestConfig::instance();

// Enable/disable specific test sizes
config.enableTestSize("500mb", true);
config.disableTestSize("1gb");

// Add custom test sizes
config.addCustomTestSize("2mb", "2MB", 2 * 1024 * 1024);

// Set performance thresholds
config.setPerformanceThreshold("parse", 15000); // 15 seconds
```

## Performance Metrics

The framework measures the following performance metrics:

1. **Generation Time**: Time to generate JSON data in memory
2. **Write Time**: Time to write JSON data to disk
3. **Read Time**: Time to read JSON data from disk
4. **Parse Time**: Time to parse JSON data into QJsonDocument
5. **Validation Time**: Time to validate JSON syntax

## Output and Reports

### Console Output
The tests provide detailed console output showing:
- Test progress
- Individual operation times
- Performance warnings
- Summary statistics

### Detailed Reports
Detailed benchmark reports are saved to:
```
~/Documents/TreonBenchmarks/benchmark_report_YYYY-MM-DD_HH-MM-SS.txt
```

Reports include:
- Performance summary table
- Throughput analysis
- Detailed results for each test size
- System information

## Usage Examples

### Running Specific Test Sizes
```bash
# Enable only 1MB and 5MB tests
./scripts/configure_json_tests.sh
# Choose option 5, then enable 1mb and 5mb
```

### Running Stress Tests
```bash
# Run large file tests (5MB - 1GB)
./scripts/configure_json_tests.sh
# Choose option 4: Run stress tests
```

### Custom Test Configuration
```bash
# Edit the configuration file directly
vim cpp/tests/json_test_config.json

# Then run tests
./scripts/run_json_benchmark.sh
```

## Performance Thresholds

The framework includes performance thresholds to catch regressions:

- **Generation**: 10 seconds (configurable)
- **Write**: 5 seconds (configurable)
- **Read**: 2 seconds (configurable)
- **Parse**: 10 seconds (configurable)
- **Validation**: 5 seconds (configurable)

If any operation exceeds its threshold, a warning is displayed.

## Integration with CI/CD

The tests can be integrated into CI/CD pipelines:

```bash
# Run quick tests in CI (fast feedback)
./scripts/configure_json_tests.sh
# Choose option 2: Run quick tests

# Run full tests in nightly builds
./scripts/run_json_benchmark.sh
```

## Troubleshooting

### Common Issues

1. **Out of Memory**: Large tests (500MB+) may require significant RAM
   - Solution: Disable large tests or increase system memory

2. **Long Execution Times**: Full test suite can take 30+ minutes
   - Solution: Use quick tests for development, full tests for releases

3. **Disk Space**: Test files require temporary disk space
   - Solution: Ensure sufficient free space in temp directory

### Debug Information

Enable debug output:
```bash
export QT_LOGGING_RULES="*.debug=true"
./scripts/run_json_benchmark.sh
```

## Contributing

When adding new test sizes or features:

1. Update `json_test_config.json`
2. Add appropriate performance thresholds
3. Update this documentation
4. Test with both quick and full test suites

## Performance Expectations

Typical performance expectations on modern hardware:

| File Size | Generation | Write | Read | Parse |
|-----------|------------|-------|------|-------|
| 10KB | < 1ms | < 1ms | < 1ms | < 1ms |
| 1MB | < 10ms | < 5ms | < 2ms | < 10ms |
| 10MB | < 100ms | < 50ms | < 20ms | < 100ms |
| 100MB | < 1s | < 500ms | < 200ms | < 1s |

These are rough guidelines and may vary based on hardware and system load.
