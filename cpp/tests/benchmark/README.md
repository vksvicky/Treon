# Benchmark Tests

This directory contains performance and benchmark tests for the Treon application.

## JSON Benchmarks (`json/`)

### Purpose
- Measure JSON processing performance across different file sizes
- Test reading, parsing, and validation performance
- Generate performance reports for optimization

### Test Sizes
- 10KB, 35KB, 50KB, 1MB, 5MB, 25MB, 50MB, 100MB, 500MB, 1GB

### Performance Metrics
- **File Reading**: Raw file I/O performance (MB/s)
- **JSON Parsing**: JSON document parsing performance (MB/s)
- **JSON Validation**: Syntax validation performance
- **Memory Usage**: Memory efficiency during processing

### Running JSON Benchmarks
```bash
./scripts/run_json_benchmark.sh
```

### Output
- Console output with real-time progress
- Detailed performance reports in `~/Documents/TreonBenchmarks/`
- CSV-formatted results for analysis

### Configuration
- Test sizes and thresholds in `json_test_config.json`
- Enable/disable specific test sizes
- Configure performance thresholds

## Adding New Benchmarks

1. Create benchmark class in appropriate subdirectory
2. Implement performance measurement methods
3. Add to CMakeLists.txt
4. Update main benchmark runner
5. Document performance expectations

## Best Practices

- Use consistent measurement methodology
- Include warmup runs to avoid cold start effects
- Test multiple file sizes to understand scaling
- Generate detailed reports for analysis
- Set realistic performance thresholds
- Document system requirements and expected performance
