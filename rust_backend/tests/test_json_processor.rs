//! Unit tests for JSON processor module

use treon_rust_backend::*;
use std::fs::File;
use std::io::Write;
use tempfile::tempdir;

#[test]
fn test_json_processor_creation() {
    let processor = JSONProcessor::new();
    assert_eq!(processor.max_file_size, 1024 * 1024 * 1024);
    assert_eq!(processor.timeout_seconds, 30);
    assert_eq!(processor.tree_builder.max_depth, 50);
    assert_eq!(processor.tree_builder.max_nodes, 50_000);
}

#[test]
fn test_json_processor_with_max_file_size() {
    let processor = JSONProcessor::new().with_max_file_size(1024);
    assert_eq!(processor.max_file_size, 1024);
    assert_eq!(processor.timeout_seconds, 30);
}

#[test]
fn test_json_processor_with_timeout() {
    let processor = JSONProcessor::new().with_timeout(60);
    assert_eq!(processor.max_file_size, 1024 * 1024 * 1024);
    assert_eq!(processor.timeout_seconds, 60);
}

#[test]
fn test_json_processor_chained_configuration() {
    let processor = JSONProcessor::new()
        .with_max_file_size(2048)
        .with_timeout(120);
    
    assert_eq!(processor.max_file_size, 2048);
    assert_eq!(processor.timeout_seconds, 120);
}

#[test]
fn test_json_processor_default() {
    let processor = JSONProcessor::default();
    assert_eq!(processor.max_file_size, 1024 * 1024 * 1024);
    assert_eq!(processor.timeout_seconds, 30);
}

#[test]
fn test_process_data_empty() {
    let processor = JSONProcessor::new();
    let data = b"{}";
    let result = processor.process_data(data);
    
    assert!(result.is_ok());
    let tree = result.unwrap();
    assert_eq!(tree.total_nodes, 1);
    assert_eq!(tree.root.children.len(), 0);
}

#[test]
fn test_process_data_single_byte() {
    let processor = JSONProcessor::new();
    let data = b"1";
    let result = processor.process_data(data);
    
    assert!(result.is_ok());
    let tree = result.unwrap();
    assert_eq!(tree.total_nodes, 1);
}

#[test]
fn test_process_small_data() {
    let processor = JSONProcessor::new();
    let data = b"{\"name\": \"test\", \"value\": 42}";
    let result = processor.process_data(data);
    
    assert!(result.is_ok());
    let tree = result.unwrap();
    assert!(tree.total_nodes > 1);
}

#[test]
fn test_process_large_data() {
    let processor = JSONProcessor::new();
    let mut data = String::from("{\"data\": [");
    
    // Create a large JSON array
    for i in 0..1000 {
        if i > 0 {
            data.push(',');
        }
        data.push_str(&format!(r#"{{"id": {}, "value": "item_{}"}}"#, i, i));
    }
    data.push_str("]}");
    
    let result = processor.process_data(data.as_bytes());
    assert!(result.is_ok());
    let tree = result.unwrap();
    assert!(tree.total_nodes > 1000);
}

#[test]
fn test_process_data_max_size() {
    let processor = JSONProcessor::new().with_max_file_size(1024); // 1KB limit
    let data = vec![0u8; 1024]; // Exactly at limit
    let result = processor.process_data(&data);
    
    // Should fail because it's not valid JSON, but not because of size
    assert!(result.is_err());
}

#[test]
fn test_process_data_exactly_at_limit() {
    let processor = JSONProcessor::new().with_max_file_size(10);
    let data = b"{\"a\": 1}"; // 9 bytes, under limit
    let result = processor.process_data(data);
    
    assert!(result.is_ok());
}

#[test]
fn test_process_data_just_over_limit() {
    let processor = JSONProcessor::new().with_max_file_size(5);
    let data = b"{\"a\": 1}"; // 9 bytes, over limit
    let result = processor.process_data(data);
    
    // Should fail because data is over max size
    assert!(result.is_err());
}

#[test]
fn test_process_data_over_max_size() {
    let processor = JSONProcessor::new().with_max_file_size(1024); // 1KB limit
    let data = vec![0u8; 2048]; // 2KB, over limit
    let result = processor.process_data(&data);
    
    // Should fail with data over max size
    assert!(result.is_err());
}

#[test]
fn test_process_data_with_timeout() {
    let processor = JSONProcessor::new().with_timeout(1); // 1 second timeout
    let data = b"{\"name\": \"test\"}";
    let result = processor.process_data(data);
    
    // Should succeed for small data even with short timeout
    assert!(result.is_ok());
}

#[test]
fn test_process_file_success() {
    let temp_dir = tempdir().expect("Failed to create temp directory");
    let file_path = temp_dir.path().join("test.json");
    
    let mut file = File::create(&file_path).expect("Failed to create test file");
    file.write_all(b"{\"name\": \"test\", \"value\": 42}").expect("Failed to write test data");
    drop(file);
    
    let processor = JSONProcessor::new();
    let result = processor.process_file(file_path.to_str().unwrap());
    
    assert!(result.is_ok());
    let tree = result.unwrap();
    assert!(tree.total_nodes > 1);
}

#[test]
fn test_process_file_not_found() {
    let processor = JSONProcessor::new();
    let result = processor.process_file("/nonexistent/file.json");
    
    assert!(result.is_err());
}

#[test]
fn test_process_file_too_large() {
    let temp_dir = tempdir().expect("Failed to create temp directory");
    let file_path = temp_dir.path().join("large.json");
    
    // Create a large file
    let mut file = File::create(&file_path).expect("Failed to create test file");
    let large_data = vec![0u8; 1024 * 1024]; // 1MB
    file.write_all(&large_data).expect("Failed to write test data");
    drop(file);
    
    let processor = JSONProcessor::new().with_max_file_size(512 * 1024); // 512KB limit
    let result = processor.process_file(file_path.to_str().unwrap());
    
    // Should fail because file is over max size
    assert!(result.is_err());
}

#[test]
fn test_get_stats() {
    let processor = JSONProcessor::new();
    let stats = processor.get_stats();
    
    assert_eq!(stats["backend"], "rust");
    assert_eq!(stats["version"], "0.1.0");
}