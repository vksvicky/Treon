//! Integration tests for the main library module (FFI functions)

use treon_rust_backend::*;
use std::ffi::{CString, CStr};
use std::fs::File;
use std::io::Write;
use tempfile::tempdir;

#[test]
fn test_rust_json_value_serialization() {
    let test_values = vec![
        RustJSONValue::String("hello".to_string()),
        RustJSONValue::Number(42.5),
        RustJSONValue::Boolean(true),
        RustJSONValue::Boolean(false),
        RustJSONValue::Null,
        RustJSONValue::Object,
        RustJSONValue::Array,
    ];
    
    for value in test_values {
        let serialized = serde_json::to_string(&value).unwrap();
        let deserialized: RustJSONValue = serde_json::from_str(&serialized).unwrap();
        assert_eq!(value, deserialized, "Serialization roundtrip failed for {:?}", value);
    }
}

#[test]
fn test_rust_json_tree_serialization() {
    let tree = RustJSONTree {
        root: RustJSONNode {
            key: "".to_string(),
            path: "$".to_string(),
            value: RustJSONValue::Object,
            children: vec![
                RustJSONNode {
                    key: "string_field".to_string(),
                    path: "$.string_field".to_string(),
                    value: RustJSONValue::String("hello".to_string()),
                    children: vec![],
                    expanded: false,
                    fully_loaded: true,
                    metadata: RustNodeMetadata {
                        size_bytes: 5,
                        depth: 1,
                        descendant_count: 0,
                        streamed: false,
                        processing_time_ms: 0,
                    },
                },
            ],
            expanded: false,
            fully_loaded: true,
            metadata: RustNodeMetadata {
                size_bytes: 0,
                depth: 0,
                descendant_count: 1,
                streamed: false,
                processing_time_ms: 0,
            },
        },
        total_nodes: 2,
        total_size_bytes: 100,
        stats: RustProcessingStats {
            processing_time_ms: 10,
            parsing_time_ms: 5,
            tree_building_time_ms: 5,
            peak_memory_bytes: 1024,
            used_streaming: false,
            streaming_chunks: 0,
        },
    };
    
    // Test serialization roundtrip
    let serialized = serde_json::to_string(&tree).unwrap();
    let deserialized: RustJSONTree = serde_json::from_str(&serialized).unwrap();
    
    assert_eq!(tree.total_nodes, deserialized.total_nodes);
    assert_eq!(tree.total_size_bytes, deserialized.total_size_bytes);
    assert_eq!(tree.root.children.len(), deserialized.root.children.len());
    assert_eq!(tree.root.value, deserialized.root.value);
}

#[test]
fn test_ffi_init() {
    treon_rust_init();
    // If we get here without panicking, the test passes
}

#[test]
fn test_ffi_stats() {
    let stats_ptr = treon_rust_get_stats();
    assert!(!stats_ptr.is_null());
    
    let stats_cstr = unsafe { CStr::from_ptr(stats_ptr) };
    let stats_str = stats_cstr.to_str().expect("Invalid UTF-8 in stats");
    
    // Verify stats can be parsed as JSON
    let _stats: serde_json::Value = serde_json::from_str(stats_str)
        .expect("Failed to parse stats JSON");
    
    treon_rust_free_string(stats_ptr);
}

#[test]
fn test_ffi_process_data_valid_json() {
    let json_data = b"{\"name\": \"test\", \"value\": 42}";
    let result_ptr = treon_rust_process_data(json_data.as_ptr(), json_data.len() as i32, 0);
    
    assert!(!result_ptr.is_null(), "Failed to process valid JSON");
    
    let result_cstr = unsafe { CStr::from_ptr(result_ptr) };
    let result_str = result_cstr.to_str().expect("Invalid UTF-8 in result");
    
    // Verify result can be parsed as JSON
    let _tree: serde_json::Value = serde_json::from_str(result_str)
        .expect("Failed to parse result as JSON");
    
    treon_rust_free_string(result_ptr);
}

#[test]
fn test_ffi_process_data_empty_object() {
    let json_data = b"{}";
    let result_ptr = treon_rust_process_data(json_data.as_ptr(), json_data.len() as i32, 0);
    
    assert!(!result_ptr.is_null(), "Failed to process empty object");
    
    let result_cstr = unsafe { CStr::from_ptr(result_ptr) };
    let result_str = result_cstr.to_str().expect("Invalid UTF-8 in result");
    
    let tree: serde_json::Value = serde_json::from_str(result_str)
        .expect("Failed to parse empty object result");
    
    assert_eq!(tree["total_nodes"].as_u64().unwrap(), 1, "Empty object should have 1 node (root)");
    
    treon_rust_free_string(result_ptr);
}

#[test]
fn test_comprehensive_file_sizes() {
    let test_sizes = vec![
        (10 * 1024, "10KB"),
        (1 * 1024 * 1024, "1MB"),
        (5 * 1024 * 1024, "5MB"),
        (10 * 1024 * 1024, "10MB"),
        (25 * 1024 * 1024, "25MB"),
        (50 * 1024 * 1024, "50MB"),
        (100 * 1024 * 1024, "100MB"),
        (250 * 1024 * 1024, "250MB"),
    ];
    
    for (size_bytes, description) in test_sizes {
        println!("Testing {} file ({} bytes)", description, size_bytes);
        
        // Create test JSON data
        let test_json = create_test_json_data(size_bytes);
        
        // Test FFI processing
        let result_ptr = treon_rust_process_data(test_json.as_ptr(), test_json.len() as i32, 0);
        assert!(!result_ptr.is_null(), "Failed to process {} data", description);
        
        let result_cstr = unsafe { CStr::from_ptr(result_ptr) };
        let result_str = result_cstr.to_str().expect("Invalid UTF-8 in result");
        
        // Test that we can deserialize the result
        let decoded_tree: serde_json::Value = serde_json::from_str(result_str)
            .expect(&format!("Failed to decode {} result: {}", description, &result_str[..std::cmp::min(500, result_str.len())]));
        
        // Verify the decoded structure is valid
        assert!(decoded_tree["total_nodes"].as_u64().unwrap() > 0, "Decoded {} tree should have nodes", description);
        assert_eq!(decoded_tree["total_size_bytes"].as_u64().unwrap() as usize, test_json.len(), "Size should match for {}", description);
        
        treon_rust_free_string(result_ptr);
        println!("✅ {} test passed", description);
    }
}

#[test]
fn test_process_file_valid_json() {
    let temp_dir = tempdir().expect("Failed to create temp directory");
    let file_path = temp_dir.path().join("test.json");
    
    // Create a test JSON file
    let mut file = File::create(&file_path).expect("Failed to create test file");
    file.write_all(b"{\"name\": \"test\", \"value\": 42, \"active\": true}").expect("Failed to write test data");
    drop(file);
    
    // Test file processing
    let path_cstring = CString::new(file_path.to_str().unwrap()).expect("Failed to create CString");
    let result_ptr = treon_rust_process_file(path_cstring.as_ptr());
    
    assert!(!result_ptr.is_null(), "Failed to process valid JSON file");
    
    let result_cstr = unsafe { CStr::from_ptr(result_ptr) };
    let result_str = result_cstr.to_str().expect("Invalid UTF-8 in result");
    
    // Verify result can be parsed as JSON
    let tree: serde_json::Value = serde_json::from_str(result_str)
        .expect("Failed to parse file result as JSON");
    
    assert!(tree["total_nodes"].as_u64().unwrap() > 0, "File processing should return nodes");
    
    treon_rust_free_string(result_ptr);
}

/// Helper function to create test JSON data of a specific size
fn create_test_json_data(size_bytes: usize) -> Vec<u8> {
    let mut json = String::from("{\"data\": [");
    
    // Add enough data to reach target size
    let item_size = 1000; // Each item is ~1000 bytes
    let num_items = size_bytes / item_size;
    
    for i in 0..num_items {
        if i > 0 {
            json.push(',');
        }
        json.push_str(&format!(
            r#"{{"id": {}, "name": "item_{}", "description": "This is a test item with some data to make it larger", "values": [1, 2, 3, 4, 5], "nested": {{"key": "value_{}"}}}}"#,
            i, i, i
        ));
    }
    
    json.push_str("]}");
    json.into_bytes()
}
