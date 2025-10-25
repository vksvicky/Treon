//! Comprehensive file size tests for the Treon Rust backend
//! 
//! Tests JSON processing performance and correctness across different file sizes:
//! 10KB, 1MB, 5MB, 10MB, 25MB, 50MB, 100MB, 250MB

use treon_rust_backend::*;
use std::fs::File;
use std::io::Write;
use tempfile::tempdir;

/// Generate JSON data of a specific size
fn generate_json_data(target_size: usize) -> String {
    let mut data = String::new();
    data.push('[');
    
    let mut current_size = 1; // Start with '['
    let mut item_count = 0;
    
    while current_size < target_size - 1 { // Reserve 1 byte for ']'
        let item = format!(
            r#"{{"id": {}, "name": "item_{}", "value": {}, "description": "This is item number {} with some additional data to increase size", "metadata": {{"created": "2025-01-01", "updated": "2025-01-01", "tags": ["tag1", "tag2", "tag3"]}}}}"#,
            item_count, item_count, item_count * 10, item_count
        );
        
        // Check if adding this item (plus comma if needed) would exceed the target size
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

/// Test JSON processing for a specific file size
fn test_file_size(size_name: &str, target_size: usize) {
    println!("Testing {} file size...", size_name);
    
    let processor = JSONProcessor::new();
    let json_data = generate_json_data(target_size);
    
    // Debug: Print first 200 characters of generated JSON
    println!("  Generated JSON preview: {}", &json_data[..std::cmp::min(200, json_data.len())]);
    
    // Test data processing
    let start_time = std::time::Instant::now();
    let result = processor.process_data(json_data.as_bytes());
    let processing_time = start_time.elapsed();
    
    if let Err(ref e) = result {
        println!("  Error processing {}: {}", size_name, e);
        println!("  JSON length: {}", json_data.len());
        println!("  JSON ends with: {}", &json_data[std::cmp::max(0, json_data.len() as i32 - 50) as usize..]);
    }
    
    assert!(result.is_ok(), "Failed to process {} JSON data", size_name);
    let tree = result.unwrap();
    
    // Verify basic properties
    assert!(tree.total_nodes > 0, "Tree should have nodes for {}", size_name);
    assert_eq!(tree.root.value, JSONValue::Array, "Root should be array for {}", size_name);
    
    println!("  ✓ {} processed in {:?} with {} nodes", size_name, processing_time, tree.total_nodes);
    
    // Performance assertions based on size
    match target_size {
        0..=10_000 => {
            // Small files should be very fast
            assert!(processing_time.as_millis() < 100, "{} should process in <100ms", size_name);
        }
        10_001..=1_000_000 => {
            // Medium files should be reasonably fast
            assert!(processing_time.as_millis() < 1000, "{} should process in <1s", size_name);
        }
        1_000_001..=10_000_000 => {
            // Large files should be processed within reasonable time
            assert!(processing_time.as_millis() < 5000, "{} should process in <5s", size_name);
        }
        _ => {
            // Very large files - just ensure they don't hang
            assert!(processing_time.as_millis() < 30000, "{} should process in <30s", size_name);
        }
    }
}

#[test]
fn test_10kb_file() {
    test_file_size("10KB", 10 * 1024);
}

#[test]
fn test_1mb_file() {
    test_file_size("1MB", 1 * 1024 * 1024);
}

#[test]
fn test_5mb_file() {
    test_file_size("5MB", 5 * 1024 * 1024);
}

#[test]
fn test_10mb_file() {
    test_file_size("10MB", 10 * 1024 * 1024);
}

#[test]
fn test_25mb_file() {
    test_file_size("25MB", 25 * 1024 * 1024);
}

#[test]
fn test_50mb_file() {
    test_file_size("50MB", 50 * 1024 * 1024);
}

#[test]
fn test_100mb_file() {
    test_file_size("100MB", 100 * 1024 * 1024);
}

#[test]
fn test_250mb_file() {
    test_file_size("250MB", 250 * 1024 * 1024);
}

/// Test file processing for different sizes
fn test_file_processing(size_name: &str, target_size: usize) {
    println!("Testing {} file processing...", size_name);
    
    let temp_dir = tempdir().unwrap();
    let file_path = temp_dir.path().join(format!("test_{}.json", size_name.to_lowercase()));
    
    // Generate and write test data
    let json_data = generate_json_data(target_size);
    let mut file = File::create(&file_path).unwrap();
    file.write_all(json_data.as_bytes()).unwrap();
    drop(file);
    
    let processor = JSONProcessor::new();
    
    // Test file processing
    let start_time = std::time::Instant::now();
    let result = processor.process_file(file_path.to_str().unwrap());
    let processing_time = start_time.elapsed();
    
    assert!(result.is_ok(), "Failed to process {} file", size_name);
    let tree = result.unwrap();
    
    // Verify basic properties
    assert!(tree.total_nodes > 0, "Tree should have nodes for {} file", size_name);
    assert_eq!(tree.root.value, JSONValue::Array, "Root should be array for {} file", size_name);
    
    println!("  ✓ {} file processed in {:?} with {} nodes", size_name, processing_time, tree.total_nodes);
}

#[test]
fn test_10kb_file_processing() {
    test_file_processing("10KB", 10 * 1024);
}

#[test]
fn test_1mb_file_processing() {
    test_file_processing("1MB", 1 * 1024 * 1024);
}

#[test]
fn test_5mb_file_processing() {
    test_file_processing("5MB", 5 * 1024 * 1024);
}

#[test]
fn test_10mb_file_processing() {
    test_file_processing("10MB", 10 * 1024 * 1024);
}

#[test]
fn test_25mb_file_processing() {
    test_file_processing("25MB", 25 * 1024 * 1024);
}

#[test]
fn test_50mb_file_processing() {
    test_file_processing("50MB", 50 * 1024 * 1024);
}

#[test]
fn test_100mb_file_processing() {
    test_file_processing("100MB", 100 * 1024 * 1024);
}

#[test]
fn test_250mb_file_processing() {
    test_file_processing("250MB", 250 * 1024 * 1024);
}

/// Test memory usage and performance characteristics
#[test]
fn test_memory_usage_across_sizes() {
    let sizes = vec![
        ("10KB", 10 * 1024),
        ("1MB", 1 * 1024 * 1024),
        ("5MB", 5 * 1024 * 1024),
        ("10MB", 10 * 1024 * 1024),
        ("25MB", 25 * 1024 * 1024),
        ("50MB", 50 * 1024 * 1024),
    ];
    
    for (size_name, target_size) in sizes {
        let processor = JSONProcessor::new();
        let json_data = generate_json_data(target_size);
        
        let start_time = std::time::Instant::now();
        let result = processor.process_data(json_data.as_bytes());
        let processing_time = start_time.elapsed();
        
        assert!(result.is_ok(), "Failed to process {}", size_name);
        let tree = result.unwrap();
        
        // Memory usage should be reasonable (not more than 10x the input size)
        let estimated_memory = tree.total_nodes * 100; // Rough estimate
        let max_allowed_memory = target_size * 10;
        
        assert!(
            estimated_memory < max_allowed_memory,
            "Memory usage for {} seems excessive: {} nodes (est. {} bytes) for {} input",
            size_name, tree.total_nodes, estimated_memory, target_size
        );
        
        println!("  ✓ {}: {} nodes, {:?} processing time", size_name, tree.total_nodes, processing_time);
    }
}

/// Test depth limiting for large files
#[test]
fn test_depth_limiting_large_files() {
    let tree_builder = TreeBuilder::new().with_max_depth(3);
    let processor = JSONProcessor {
        tree_builder,
        max_file_size: 1024 * 1024 * 1024,
        timeout_seconds: 30,
    };
    
    // Create a deeply nested structure
    let mut json_data = String::new();
    json_data.push_str(r#"{"level1": {"level2": {"level3": {"level4": {"level5": "deep_value"}}}}}"#);
    
    let result = processor.process_data(json_data.as_bytes());
    assert!(result.is_ok(), "Failed to process deeply nested JSON");
    
    let tree = result.unwrap();
    
    // Should respect depth limit
    fn check_max_depth(node: &JSONNode, current_depth: usize, max_depth: usize) {
        assert!(current_depth <= max_depth, "Depth {} exceeds limit {}", current_depth, max_depth);
        for child in &node.children {
            check_max_depth(child, current_depth + 1, max_depth);
        }
    }
    
    check_max_depth(&tree.root, 0, 3);
}

/// Test node limiting for large files
#[test]
fn test_node_limiting_large_files() {
    let tree_builder = TreeBuilder::new().with_max_nodes(100);
    let processor = JSONProcessor {
        tree_builder,
        max_file_size: 1024 * 1024 * 1024,
        timeout_seconds: 30,
    };
    
    // Create a wide structure with many items
    let mut json_data = String::new();
    json_data.push('[');
    for i in 0..200 {
        if i > 0 {
            json_data.push(',');
        }
        json_data.push_str(&format!(r#"{{"id": {}, "value": "item_{}"}}"#, i, i));
    }
    json_data.push(']');
    
    let result = processor.process_data(json_data.as_bytes());
    assert!(result.is_ok(), "Failed to process wide JSON structure");
    
    let tree = result.unwrap();
    
    // Should respect node limit
    assert!(tree.total_nodes <= 100, "Node count {} exceeds limit 100", tree.total_nodes);
}
