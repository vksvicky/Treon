//! Performance benchmarks for the Treon Rust backend
//! 
//! Tests JSON processing performance across different file sizes and scenarios

use treon_rust_backend::*;
use std::time::Instant;

/// Generate JSON data of a specific size with different structures
fn generate_performance_test_data(size_name: &str, target_size: usize) -> String {
    match size_name {
        "wide_array" => generate_wide_array(target_size),
        "deep_object" => generate_deep_object(target_size),
        "mixed_structure" => generate_mixed_structure(target_size),
        _ => generate_standard_array(target_size),
    }
}

/// Generate a wide array (many items, shallow nesting)
fn generate_wide_array(target_size: usize) -> String {
    let mut data = String::new();
    data.push('[');
    
    let mut current_size = 1;
    let mut item_count = 0;
    
    while current_size < target_size - 1 {
        let item = format!(r#"{{"id": {}, "value": "item_{}"}}"#, item_count, item_count);
        
        let comma_size = if item_count > 0 { 1 } else { 0 };
        if current_size + item.len() + comma_size >= target_size - 1 {
            break;
        }
        
        if item_count > 0 {
            data.push(',');
            current_size += 1;
        }
        
        data.push_str(&item);
        current_size += item.len();
        item_count += 1;
    }
    
    data.push(']');
    data
}

/// Generate a deeply nested object
fn generate_deep_object(target_size: usize) -> String {
    // Create a simpler deep object structure
    let mut data = String::new();
    data.push('{');
    
    let mut current_size = 1;
    let mut item_count = 0;
    
    while current_size < target_size - 1 {
        let item = format!(
            r#""nested_{}": {{"level1": {{"level2": {{"level3": {{"value": "deep_value_{}"}}}}}}}}"#,
            item_count, item_count
        );
        
        let comma_size = if item_count > 0 { 1 } else { 0 };
        if current_size + item.len() + comma_size >= target_size - 1 {
            break;
        }
        
        if item_count > 0 {
            data.push(',');
            current_size += 1;
        }
        
        data.push_str(&item);
        current_size += item.len();
        item_count += 1;
    }
    
    data.push('}');
    data
}

/// Generate a mixed structure with arrays and objects
fn generate_mixed_structure(target_size: usize) -> String {
    let mut data = String::new();
    data.push('{');
    
    let mut current_size = 1;
    let mut item_count = 0;
    
    while current_size < target_size - 1 {
        let item = if item_count % 3 == 0 {
            format!(r#""array_{}": [1, 2, 3, 4, 5]"#, item_count)
        } else if item_count % 3 == 1 {
            format!(r#""object_{}": {{"nested": "value", "number": {}}}"#, item_count, item_count)
        } else {
            format!(r#""string_{}": "value_{}""#, item_count, item_count)
        };
        
        let comma_size = if item_count > 0 { 1 } else { 0 };
        if current_size + item.len() + comma_size >= target_size - 1 {
            break;
        }
        
        if item_count > 0 {
            data.push(',');
            current_size += 1;
        }
        
        data.push_str(&item);
        current_size += item.len();
        item_count += 1;
    }
    
    data.push('}');
    data
}

/// Generate a standard array (like the file size tests)
fn generate_standard_array(target_size: usize) -> String {
    let mut data = String::new();
    data.push('[');
    
    let mut current_size = 1;
    let mut item_count = 0;
    
    while current_size < target_size - 1 {
        let item = format!(
            r#"{{"id": {}, "name": "item_{}", "value": {}, "description": "This is item number {} with some additional data to increase size", "metadata": {{"created": "2025-01-01", "updated": "2025-01-01", "tags": ["tag1", "tag2", "tag3"]}}}}"#,
            item_count, item_count, item_count * 10, item_count
        );
        
        let comma_size = if item_count > 0 { 1 } else { 0 };
        if current_size + item.len() + comma_size >= target_size - 1 {
            break;
        }
        
        if item_count > 0 {
            data.push(',');
            current_size += 1;
        }
        
        data.push_str(&item);
        current_size += item.len();
        item_count += 1;
    }
    
    data.push(']');
    data
}

/// Benchmark JSON processing performance
fn benchmark_processing(size_name: &str, structure_type: &str, target_size: usize) -> (u128, usize) {
    let processor = JSONProcessor::new();
    let json_data = generate_performance_test_data(structure_type, target_size);
    
    let start_time = Instant::now();
    let result = processor.process_data(json_data.as_bytes());
    let processing_time = start_time.elapsed();
    
    if let Err(ref e) = result {
        println!("  Error processing {} {}: {}", size_name, structure_type, e);
        println!("  JSON length: {}", json_data.len());
        println!("  JSON preview: {}", &json_data[..std::cmp::min(200, json_data.len())]);
    }
    
    assert!(result.is_ok(), "Failed to process {} {} data", size_name, structure_type);
    let tree = result.unwrap();
    
    (processing_time.as_millis(), tree.total_nodes)
}

/// Test performance across different file sizes
#[test]
fn test_performance_across_sizes() {
    let sizes = vec![
        ("10KB", 10 * 1024),
        ("100KB", 100 * 1024),
        ("1MB", 1 * 1024 * 1024),
        ("5MB", 5 * 1024 * 1024),
        ("10MB", 10 * 1024 * 1024),
    ];
    
    println!("\n=== Performance Across File Sizes ===");
    println!("{:<10} {:<15} {:<10} {:<10} {:<15}", "Size", "Structure", "Time(ms)", "Nodes", "Nodes/ms");
    println!("{}", "-".repeat(70));
    
    for (size_name, target_size) in sizes {
        let (time_ms, nodes) = benchmark_processing(size_name, "standard_array", target_size);
        let nodes_per_ms = if time_ms > 0 { nodes as f64 / time_ms as f64 } else { 0.0 };
        
        println!("{:<10} {:<15} {:<10} {:<10} {:<15.2}", 
                 size_name, "standard_array", time_ms, nodes, nodes_per_ms);
    }
}

/// Test performance across different data structures
#[test]
fn test_performance_across_structures() {
    let structures = vec![
        ("wide_array", "Wide Array"),
        ("deep_object", "Deep Object"),
        ("mixed_structure", "Mixed Structure"),
        ("standard_array", "Standard Array"),
    ];
    
    let target_size = 1 * 1024 * 1024; // 1MB
    
    println!("\n=== Performance Across Data Structures (1MB) ===");
    println!("{:<15} {:<10} {:<10} {:<15}", "Structure", "Time(ms)", "Nodes", "Nodes/ms");
    println!("{}", "-".repeat(60));
    
    for (structure_type, structure_name) in structures {
        let (time_ms, nodes) = benchmark_processing("1MB", structure_type, target_size);
        let nodes_per_ms = if time_ms > 0 { nodes as f64 / time_ms as f64 } else { 0.0 };
        
        println!("{:<15} {:<10} {:<10} {:<15.2}", 
                 structure_name, time_ms, nodes, nodes_per_ms);
    }
}

/// Test memory efficiency
#[test]
fn test_memory_efficiency() {
    let sizes = vec![
        ("1MB", 1 * 1024 * 1024),
        ("5MB", 5 * 1024 * 1024),
        ("10MB", 10 * 1024 * 1024),
    ];
    
    println!("\n=== Memory Efficiency ===");
    println!("{:<10} {:<10} {:<15} {:<15} {:<10}", "Size", "Time(ms)", "Input(bytes)", "Nodes", "Ratio");
    println!("{}", "-".repeat(70));
    
    for (size_name, target_size) in sizes {
        let processor = JSONProcessor::new();
        let json_data = generate_performance_test_data("standard_array", target_size);
        
        let start_time = Instant::now();
        let result = processor.process_data(json_data.as_bytes());
        let processing_time = start_time.elapsed();
        
        assert!(result.is_ok(), "Failed to process {}", size_name);
        let tree = result.unwrap();
        
        let ratio = tree.total_nodes as f64 / target_size as f64;
        
        println!("{:<10} {:<10} {:<15} {:<15} {:<10.4}", 
                 size_name, processing_time.as_millis(), target_size, tree.total_nodes, ratio);
    }
}

/// Test processing speed consistency
#[test]
fn test_processing_consistency() {
    let target_size = 1 * 1024 * 1024; // 1MB
    let iterations = 5;
    
    println!("\n=== Processing Consistency (1MB, {} iterations) ===", iterations);
    println!("{:<10} {:<10} {:<10} {:<10} {:<10}", "Run", "Time(ms)", "Nodes", "Min(ms)", "Max(ms)");
    println!("{}", "-".repeat(60));
    
    let mut times = Vec::new();
    let mut nodes = Vec::new();
    
    for i in 0..iterations {
        let (time_ms, node_count) = benchmark_processing("1MB", "standard_array", target_size);
        times.push(time_ms);
        nodes.push(node_count);
        
        let min_time = times.iter().min().unwrap();
        let max_time = times.iter().max().unwrap();
        
        println!("{:<10} {:<10} {:<10} {:<10} {:<10}", 
                 i + 1, time_ms, node_count, min_time, max_time);
    }
    
    // Calculate statistics
    let avg_time = times.iter().sum::<u128>() as f64 / times.len() as f64;
    let min_time = *times.iter().min().unwrap();
    let max_time = *times.iter().max().unwrap();
    let variance = times.iter()
        .map(|&t| (t as f64 - avg_time).powi(2))
        .sum::<f64>() / times.len() as f64;
    let std_dev = variance.sqrt();
    
    println!("\nStatistics:");
    println!("  Average time: {:.2}ms", avg_time);
    println!("  Min time: {}ms", min_time);
    println!("  Max time: {}ms", max_time);
    println!("  Std deviation: {:.2}ms", std_dev);
    println!("  Coefficient of variation: {:.2}%", (std_dev / avg_time) * 100.0);
    
    // Consistency check - coefficient of variation should be < 50%
    // Performance can vary due to system load, CPU scheduling, etc.
    let cv = (std_dev / avg_time) * 100.0;
    assert!(cv < 50.0, "Processing time is too inconsistent: CV = {:.2}%", cv);
}

/// Test depth limiting performance impact
#[test]
fn test_depth_limiting_performance() {
    let target_size = 1 * 1024 * 1024; // 1MB
    
    println!("\n=== Depth Limiting Performance Impact ===");
    println!("{:<10} {:<10} {:<10} {:<15}", "Max Depth", "Time(ms)", "Nodes", "Nodes/ms");
    println!("{}", "-".repeat(50));
    
    let depths = vec![1, 3, 5, 10, 20, 50];
    
    for max_depth in depths {
        let tree_builder = TreeBuilder::new().with_max_depth(max_depth);
        let processor = JSONProcessor {
            tree_builder,
            max_file_size: 1024 * 1024 * 1024,
            timeout_seconds: 30,
        };
        
        let json_data = generate_performance_test_data("deep_object", target_size);
        
        let start_time = Instant::now();
        let result = processor.process_data(json_data.as_bytes());
        let processing_time = start_time.elapsed();
        
        assert!(result.is_ok(), "Failed to process with depth {}", max_depth);
        let tree = result.unwrap();
        
        let nodes_per_ms = if processing_time.as_millis() > 0 { 
            tree.total_nodes as f64 / processing_time.as_millis() as f64 
        } else { 0.0 };
        
        println!("{:<10} {:<10} {:<10} {:<15.2}", 
                 max_depth, processing_time.as_millis(), tree.total_nodes, nodes_per_ms);
    }
}

/// Test node limiting performance impact
#[test]
fn test_node_limiting_performance() {
    let target_size = 1 * 1024 * 1024; // 1MB
    
    println!("\n=== Node Limiting Performance Impact ===");
    println!("{:<10} {:<10} {:<10} {:<15}", "Max Nodes", "Time(ms)", "Nodes", "Nodes/ms");
    println!("{}", "-".repeat(50));
    
    let node_limits = vec![100, 1000, 10000, 50000, 100000];
    
    for max_nodes in node_limits {
        let tree_builder = TreeBuilder::new().with_max_nodes(max_nodes);
        let processor = JSONProcessor {
            tree_builder,
            max_file_size: 1024 * 1024 * 1024,
            timeout_seconds: 30,
        };
        
        let json_data = generate_performance_test_data("wide_array", target_size);
        
        let start_time = Instant::now();
        let result = processor.process_data(json_data.as_bytes());
        let processing_time = start_time.elapsed();
        
        assert!(result.is_ok(), "Failed to process with node limit {}", max_nodes);
        let tree = result.unwrap();
        
        let nodes_per_ms = if processing_time.as_millis() > 0 { 
            tree.total_nodes as f64 / processing_time.as_millis() as f64 
        } else { 0.0 };
        
        println!("{:<10} {:<10} {:<10} {:<15.2}", 
                 max_nodes, processing_time.as_millis(), tree.total_nodes, nodes_per_ms);
    }
}

/// Performance regression test - ensure performance doesn't degrade
#[test]
fn test_performance_regression() {
    let target_size = 1 * 1024 * 1024; // 1MB
    let max_acceptable_time_ms = 1000; // 1 second max
    
    let (time_ms, _nodes) = benchmark_processing("1MB", "standard_array", target_size);
    
    println!("\n=== Performance Regression Test ===");
    println!("Processing 1MB file: {}ms (max acceptable: {}ms)", time_ms, max_acceptable_time_ms);
    
    assert!(time_ms <= max_acceptable_time_ms, 
            "Performance regression detected: {}ms > {}ms", time_ms, max_acceptable_time_ms);
    
    println!("✓ Performance is within acceptable limits");
}
