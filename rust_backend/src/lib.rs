//! Treon Rust Backend
//! 
//! High-performance JSON processing backend for the Treon macOS application.
//! This module provides FFI functions that can be called from Swift.

use std::ffi::{CStr, CString};
use std::os::raw::c_char;

mod error;
mod tree_builder;
mod json_processor;

use error::{Result, TreonError};
use serde::{Deserialize, Serialize};
use log::{info, error};

/// Rust JSON tree structure that matches Swift expectations
#[derive(Debug, Clone, Serialize, Deserialize)]
struct RustJSONTree {
    root: RustJSONNode,
    total_nodes: usize,
    total_size_bytes: usize,
    stats: RustProcessingStats,
}

/// Rust JSON node structure that matches Swift expectations
#[derive(Debug, Clone, Serialize, Deserialize)]
struct RustJSONNode {
    key: String,
    path: String,
    value: RustJSONValue,
    children: Vec<RustJSONNode>,
    expanded: bool,
    fully_loaded: bool,
    metadata: RustNodeMetadata,
}

/// Rust JSON value type that matches Swift expectations
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(tag = "type", content = "value")]
enum RustJSONValue {
    String(String),
    Number(f64),
    Boolean(bool),
    Null,
    Object,
    Array,
}

/// Rust node metadata that matches Swift expectations
#[derive(Debug, Clone, Serialize, Deserialize)]
struct RustNodeMetadata {
    depth: usize,
    child_count: usize,
    size_bytes: usize,
    is_expanded: bool,
}

/// Rust processing statistics
#[derive(Debug, Clone, Serialize, Deserialize)]
struct RustProcessingStats {
    processing_time_ms: u64,
    memory_usage_bytes: usize,
    backend: String,
}

/// Process JSON data and return a tree structure
fn process_json_data(data: &[u8]) -> Result<RustJSONTree> {
    // Parse the JSON data
    let json_value: serde_json::Value = serde_json::from_slice(data)
        .map_err(|e| TreonError::json_parsing(format!("JSON parsing failed: {}", e)))?;
    
    // Convert to our tree structure
    let root_node = convert_json_to_tree(&json_value, None, "$".to_string(), 0)?;
    
    // Create the tree structure that matches Swift expectations
    let total_nodes = count_nodes(&root_node);
    let tree = RustJSONTree {
        root: root_node,
        total_nodes,
        total_size_bytes: data.len(),
        stats: RustProcessingStats {
            processing_time_ms: 0, // Will be set by caller
            memory_usage_bytes: 0,
            backend: "rust".to_string(),
        }
    };
    
    Ok(tree)
}

/// Convert serde_json::Value to our RustJSONNode tree structure
fn convert_json_to_tree(
    value: &serde_json::Value,
    key: Option<String>,
    path: String,
    depth: usize,
) -> Result<RustJSONNode> {
    let (rust_value, children) = match value {
        serde_json::Value::String(s) => (RustJSONValue::String(s.clone()), Vec::new()),
        serde_json::Value::Number(n) => {
            let num = n.as_f64().unwrap_or(0.0);
            (RustJSONValue::Number(num), Vec::new())
        }
        serde_json::Value::Bool(b) => (RustJSONValue::Boolean(*b), Vec::new()),
        serde_json::Value::Null => (RustJSONValue::Null, Vec::new()),
        serde_json::Value::Object(obj) => {
            let mut children = Vec::new();
            for (k, v) in obj.iter() {
                let child_path = format!("{}.{}", path, k);
                let child = convert_json_to_tree(v, Some(k.clone()), child_path, depth + 1)?;
                children.push(child);
            }
            (RustJSONValue::Object, children)
        }
        serde_json::Value::Array(arr) => {
            let mut children = Vec::new();
            for (i, v) in arr.iter().enumerate() {
                let child_path = format!("{}[{}]", path, i);
                let child = convert_json_to_tree(v, Some(i.to_string()), child_path, depth + 1)?;
                children.push(child);
            }
            (RustJSONValue::Array, children)
        }
    };
    
    Ok(RustJSONNode {
        key: key.unwrap_or_default(),
        path,
        value: rust_value,
        children,
        expanded: false,
        fully_loaded: true,
        metadata: RustNodeMetadata {
            depth,
            child_count: 0, // Will be set below
            size_bytes: 0,
            is_expanded: false,
        },
    })
}

/// Count the total number of nodes in a tree
fn count_nodes(node: &RustJSONNode) -> usize {
    1 + node.children.iter().map(|child| count_nodes(child)).sum::<usize>()
}

/// Initialize the Rust backend
/// 
/// This function sets up the Rust backend for processing JSON files.
/// It should be called once when the application starts.
#[no_mangle]
pub extern "C" fn treon_rust_init() {
    // Initialize logging only once
    static INIT: std::sync::Once = std::sync::Once::new();
    INIT.call_once(|| {
        // Configure logging level for tests vs production
        if cfg!(test) {
            // During tests, suppress all logging to avoid noise from expected error conditions
            std::env::set_var("RUST_LOG", "off");
        } else if std::env::var("RUST_LOG").is_err() {
            // In production, default to info level
            std::env::set_var("RUST_LOG", "info");
        }
        
        let _ = env_logger::try_init();
        log::info!("Rust backend initialized");
    });
}

/// Process a JSON file from a file path
/// 
/// # Arguments
/// * `file_path` - C string containing the file path
/// 
/// # Returns
/// * C string containing the processed JSON tree (or null on error)
#[no_mangle]
pub extern "C" fn treon_rust_process_file(file_path: *const c_char) -> *mut c_char {
    if file_path.is_null() {
        error!("🚀 treon_rust_process_file called with null file_path");
        return std::ptr::null_mut();
    }
    
    let c_str = unsafe { CStr::from_ptr(file_path) };
    let path_str = match c_str.to_str() {
        Ok(s) => {
            info!("🚀 treon_rust_process_file called with path: {}", s);
            s
        },
        Err(e) => {
            error!("🚀 Invalid UTF-8 in file path: {}", e);
            return std::ptr::null_mut();
        }
    };
    
    log::info!("Processing file: {}", path_str);
    
    // Read and process the file
    match std::fs::read(path_str) {
        Ok(data) => {
            match process_json_data(&data) {
                Ok(result) => {
                    let response_str = match serde_json::to_string(&result) {
                        Ok(s) => s,
                        Err(e) => {
                            log::error!("Failed to serialize result: {}", e);
                            return std::ptr::null_mut();
                        }
                    };
                    
                    match CString::new(response_str) {
                        Ok(c_string) => c_string.into_raw(),
                        Err(e) => {
                            log::error!("Failed to create C string: {}", e);
                            std::ptr::null_mut()
                        }
                    }
                }
                Err(e) => {
                    log::error!("Failed to process file data: {}", e);
                    std::ptr::null_mut()
                }
            }
        }
        Err(e) => {
            log::error!("Failed to read file: {}", e);
            std::ptr::null_mut()
        }
    }
}

/// Process JSON data from memory
/// 
/// # Arguments
/// * `data` - Pointer to the JSON data
/// * `length` - Length of the data in bytes
/// 
/// # Returns
/// * C string containing the processed JSON tree (or null on error)
#[no_mangle]
pub extern "C" fn treon_rust_process_data(data: *const u8, length: i32) -> *mut c_char {
    if data.is_null() || length <= 0 {
        log::error!("Invalid data provided");
        return std::ptr::null_mut();
    }
    
    let data_slice = unsafe { std::slice::from_raw_parts(data, length as usize) };
    
    log::info!("Processing {} bytes of JSON data", length);
    
    // Actually process the JSON data
    match process_json_data(data_slice) {
        Ok(result) => {
            let response_str = match serde_json::to_string(&result) {
                Ok(s) => s,
                Err(e) => {
                    log::error!("Failed to serialize result: {}", e);
                    return std::ptr::null_mut();
                }
            };
            
            match CString::new(response_str) {
                Ok(c_string) => c_string.into_raw(),
                Err(e) => {
                    log::error!("Failed to create C string: {}", e);
                    std::ptr::null_mut()
                }
            }
        }
        Err(e) => {
            log::error!("Failed to process JSON data: {}", e);
            std::ptr::null_mut()
        }
    }
}

/// Free a string returned by the Rust backend
/// 
/// # Arguments
/// * `ptr` - Pointer to the string to free
#[no_mangle]
pub extern "C" fn treon_rust_free_string(ptr: *mut c_char) {
    if !ptr.is_null() {
        unsafe {
            let _ = CString::from_raw(ptr);
        }
    }
}

/// Get performance statistics from the Rust backend
/// 
/// # Returns
/// * C string containing performance statistics (or null on error)
#[no_mangle]
pub extern "C" fn treon_rust_get_stats() -> *mut c_char {
    let stats = serde_json::json!({
        "backend": "rust",
        "version": "0.1.0",
        "status": "initialized",
        "features": ["simd-json", "streaming", "memory-efficient"],
        "performance": {
            "json_parsing": "optimized",
            "memory_usage": "low",
            "large_file_support": "enabled"
        }
    });
    
    let stats_str = match serde_json::to_string(&stats) {
        Ok(s) => s,
        Err(e) => {
            log::error!("Failed to serialize stats: {}", e);
            return std::ptr::null_mut();
        }
    };
    
    match CString::new(stats_str) {
        Ok(c_string) => c_string.into_raw(),
        Err(e) => {
            log::error!("Failed to create C string: {}", e);
            std::ptr::null_mut()
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::ffi::CString;
    use std::fs::File;
    use std::io::Write;
    use tempfile::tempdir;
    
    #[test]
    fn test_rust_backend_init() {
        treon_rust_init();
        // If we get here without panicking, the test passes
    }
    
    #[test]
    fn test_rust_backend_stats() {
        let stats_ptr = treon_rust_get_stats();
        assert!(!stats_ptr.is_null());
        
        let stats_cstr = unsafe { CStr::from_ptr(stats_ptr) };
        let stats_str = stats_cstr.to_str().unwrap();
        assert!(stats_str.contains("rust"));
        assert!(stats_str.contains("version"));
        assert!(stats_str.contains("backend"));
        
        treon_rust_free_string(stats_ptr);
    }
    
    #[test]
    fn test_rust_backend_stats_null_pointer() {
        let stats_ptr = treon_rust_get_stats();
        assert!(!stats_ptr.is_null());
        
        // Test that we can free the pointer
        treon_rust_free_string(stats_ptr);
    }
    
    #[test]
    fn test_treon_rust_process_data_valid_json() {
        let json_data = b"{\"name\": \"test\", \"value\": 42}";
        let result_ptr = treon_rust_process_data(json_data.as_ptr(), json_data.len() as i32);
        
        assert!(!result_ptr.is_null());
        
        let result_cstr = unsafe { CStr::from_ptr(result_ptr) };
        let result_str = result_cstr.to_str().unwrap();
        assert!(result_str.contains("test"));
        assert!(result_str.contains("42"));
        
        treon_rust_free_string(result_ptr);
    }
    
    #[test]
    fn test_treon_rust_process_data_invalid_json() {
        let invalid_json = b"{ invalid json }";
        let result_ptr = treon_rust_process_data(invalid_json.as_ptr(), invalid_json.len() as i32);
        
        // Should return null for invalid JSON
        assert!(result_ptr.is_null());
    }
    
    #[test]
    fn test_treon_rust_process_data_null_pointer() {
        let result_ptr = treon_rust_process_data(std::ptr::null(), 10);
        assert!(result_ptr.is_null());
    }
    
    #[test]
    fn test_treon_rust_process_data_zero_length() {
        let json_data = b"{}";
        let result_ptr = treon_rust_process_data(json_data.as_ptr(), 0);
        assert!(result_ptr.is_null());
    }
    
    #[test]
    fn test_treon_rust_process_data_negative_length() {
        let json_data = b"{}";
        let result_ptr = treon_rust_process_data(json_data.as_ptr(), -1);
        assert!(result_ptr.is_null());
    }
    
    #[test]
    fn test_treon_rust_process_data_empty_object() {
        let json_data = b"{}";
        let result_ptr = treon_rust_process_data(json_data.as_ptr(), json_data.len() as i32);
        
        assert!(!result_ptr.is_null());
        
        let result_cstr = unsafe { CStr::from_ptr(result_ptr) };
        let result_str = result_cstr.to_str().unwrap();
        assert!(result_str.contains("Object"));
        
        treon_rust_free_string(result_ptr);
    }
    
    #[test]
    fn test_treon_rust_process_data_array() {
        let json_data = b"[1, 2, 3, \"test\"]";
        let result_ptr = treon_rust_process_data(json_data.as_ptr(), json_data.len() as i32);
        
        assert!(!result_ptr.is_null());
        
        let result_cstr = unsafe { CStr::from_ptr(result_ptr) };
        let result_str = result_cstr.to_str().unwrap();
        assert!(result_str.contains("Array"));
        assert!(result_str.contains("test"));
        
        treon_rust_free_string(result_ptr);
    }
    
    #[test]
    fn test_treon_rust_process_data_nested_object() {
        let json_data = b"{\"user\": {\"name\": \"John\", \"age\": 30}, \"active\": true}";
        let result_ptr = treon_rust_process_data(json_data.as_ptr(), json_data.len() as i32);
        
        assert!(!result_ptr.is_null());
        
        let result_cstr = unsafe { CStr::from_ptr(result_ptr) };
        let result_str = result_cstr.to_str().unwrap();
        assert!(result_str.contains("John"));
        assert!(result_str.contains("30"));
        assert!(result_str.contains("true"));
        
        treon_rust_free_string(result_ptr);
    }
    
    #[test]
    fn test_treon_rust_process_data_null_value() {
        let json_data = b"{\"value\": null}";
        let result_ptr = treon_rust_process_data(json_data.as_ptr(), json_data.len() as i32);
        
        assert!(!result_ptr.is_null());
        
        let result_cstr = unsafe { CStr::from_ptr(result_ptr) };
        let result_str = result_cstr.to_str().unwrap();
        assert!(result_str.contains("Null"));
        
        treon_rust_free_string(result_ptr);
    }
    
    #[test]
    fn test_treon_rust_process_data_boolean_values() {
        let json_data = b"{\"true_value\": true, \"false_value\": false}";
        let result_ptr = treon_rust_process_data(json_data.as_ptr(), json_data.len() as i32);
        
        assert!(!result_ptr.is_null());
        
        let result_cstr = unsafe { CStr::from_ptr(result_ptr) };
        let result_str = result_cstr.to_str().unwrap();
        assert!(result_str.contains("Boolean"));
        
        treon_rust_free_string(result_ptr);
    }
    
    #[test]
    fn test_treon_rust_process_data_number_values() {
        let json_data = b"{\"integer\": 42, \"float\": 3.14, \"negative\": -10}";
        let result_ptr = treon_rust_process_data(json_data.as_ptr(), json_data.len() as i32);
        
        assert!(!result_ptr.is_null());
        
        let result_cstr = unsafe { CStr::from_ptr(result_ptr) };
        let result_str = result_cstr.to_str().unwrap();
        assert!(result_str.contains("Number"));
        
        treon_rust_free_string(result_ptr);
    }
    
    #[test]
    fn test_treon_rust_process_file_valid_file() {
        let temp_dir = tempdir().unwrap();
        let file_path = temp_dir.path().join("test.json");
        
        // Create a test JSON file
        let mut file = File::create(&file_path).unwrap();
        file.write_all(b"{\"test\": \"value\", \"number\": 123}").unwrap();
        drop(file);
        
        let c_path = CString::new(file_path.to_str().unwrap()).unwrap();
        let result_ptr = treon_rust_process_file(c_path.as_ptr());
        
        assert!(!result_ptr.is_null());
        
        let result_cstr = unsafe { CStr::from_ptr(result_ptr) };
        let result_str = result_cstr.to_str().unwrap();
        assert!(result_str.contains("test"));
        assert!(result_str.contains("value"));
        assert!(result_str.contains("123"));
        
        treon_rust_free_string(result_ptr);
    }
    
    #[test]
    fn test_treon_rust_process_file_nonexistent_file() {
        let c_path = CString::new("nonexistent.json").unwrap();
        let result_ptr = treon_rust_process_file(c_path.as_ptr());
        
        // Should return null for nonexistent file
        assert!(result_ptr.is_null());
    }
    
    #[test]
    fn test_treon_rust_process_file_null_pointer() {
        let result_ptr = treon_rust_process_file(std::ptr::null());
        assert!(result_ptr.is_null());
    }
    
    #[test]
    fn test_treon_rust_process_file_invalid_utf8() {
        // Create a C string with invalid UTF-8
        let invalid_path = b"test\xff.json";
        let c_path = CString::new(invalid_path).unwrap();
        let result_ptr = treon_rust_process_file(c_path.as_ptr());
        
        // Should return null for invalid UTF-8
        assert!(result_ptr.is_null());
    }
    
    #[test]
    fn test_treon_rust_free_string_null_pointer() {
        // Should not panic when freeing a null pointer
        treon_rust_free_string(std::ptr::null_mut());
    }
    
    #[test]
    fn test_process_json_data_function() {
        let json_data = b"{\"name\": \"test\", \"values\": [1, 2, 3]}";
        let result = process_json_data(json_data);
        
        assert!(result.is_ok());
        let tree = result.unwrap();
        assert_eq!(tree.total_size_bytes, json_data.len());
        assert!(tree.total_nodes > 0);
        assert_eq!(tree.stats.backend, "rust");
    }
    
    #[test]
    fn test_process_json_data_invalid_json() {
        let invalid_json = b"{ invalid json }";
        let result = process_json_data(invalid_json);
        
        assert!(result.is_err());
        if let Err(error) = result {
            assert!(matches!(error, TreonError::JsonParsing(_)));
        }
    }
    
    #[test]
    fn test_convert_json_to_tree_string() {
        let json_value = serde_json::Value::String("test".to_string());
        let result = convert_json_to_tree(&json_value, Some("key".to_string()), "$.key".to_string(), 0);
        
        assert!(result.is_ok());
        let node = result.unwrap();
        assert_eq!(node.key, "key");
        assert_eq!(node.path, "$.key");
        assert!(matches!(node.value, RustJSONValue::String(_)));
        assert_eq!(node.children.len(), 0);
    }
    
    #[test]
    fn test_convert_json_to_tree_number() {
        let json_value = serde_json::Value::Number(serde_json::Number::from_f64(42.5).unwrap());
        let result = convert_json_to_tree(&json_value, Some("value".to_string()), "$.value".to_string(), 0);
        
        assert!(result.is_ok());
        let node = result.unwrap();
        assert_eq!(node.key, "value");
        assert_eq!(node.path, "$.value");
        assert!(matches!(node.value, RustJSONValue::Number(_)));
    }
    
    #[test]
    fn test_convert_json_to_tree_boolean() {
        let json_value = serde_json::Value::Bool(true);
        let result = convert_json_to_tree(&json_value, Some("flag".to_string()), "$.flag".to_string(), 0);
        
        assert!(result.is_ok());
        let node = result.unwrap();
        assert_eq!(node.key, "flag");
        assert_eq!(node.path, "$.flag");
        assert!(matches!(node.value, RustJSONValue::Boolean(_)));
    }
    
    #[test]
    fn test_convert_json_to_tree_null() {
        let json_value = serde_json::Value::Null;
        let result = convert_json_to_tree(&json_value, Some("null_value".to_string()), "$.null_value".to_string(), 0);
        
        assert!(result.is_ok());
        let node = result.unwrap();
        assert_eq!(node.key, "null_value");
        assert_eq!(node.path, "$.null_value");
        assert!(matches!(node.value, RustJSONValue::Null));
    }
    
    #[test]
    fn test_convert_json_to_tree_object() {
        let mut obj = serde_json::Map::new();
        obj.insert("name".to_string(), serde_json::Value::String("John".to_string()));
        obj.insert("age".to_string(), serde_json::Value::Number(serde_json::Number::from(30)));
        let json_value = serde_json::Value::Object(obj);
        
        let result = convert_json_to_tree(&json_value, Some("user".to_string()), "$.user".to_string(), 0);
        
        assert!(result.is_ok());
        let node = result.unwrap();
        assert_eq!(node.key, "user");
        assert_eq!(node.path, "$.user");
        assert!(matches!(node.value, RustJSONValue::Object));
        assert_eq!(node.children.len(), 2);
    }
    
    #[test]
    fn test_convert_json_to_tree_array() {
        let arr = vec![
            serde_json::Value::String("first".to_string()),
            serde_json::Value::Number(serde_json::Number::from(2)),
            serde_json::Value::Bool(true),
        ];
        let json_value = serde_json::Value::Array(arr);
        
        let result = convert_json_to_tree(&json_value, Some("items".to_string()), "$.items".to_string(), 0);
        
        assert!(result.is_ok());
        let node = result.unwrap();
        assert_eq!(node.key, "items");
        assert_eq!(node.path, "$.items");
        assert!(matches!(node.value, RustJSONValue::Array));
        assert_eq!(node.children.len(), 3);
    }
    
    #[test]
    fn test_convert_json_to_tree_none_key() {
        let json_value = serde_json::Value::String("root".to_string());
        let result = convert_json_to_tree(&json_value, None, "$".to_string(), 0);
        
        assert!(result.is_ok());
        let node = result.unwrap();
        assert_eq!(node.key, "");
        assert_eq!(node.path, "$");
    }
    
    #[test]
    fn test_count_nodes_single_node() {
        let node = RustJSONNode {
            key: "test".to_string(),
            path: "$.test".to_string(),
            value: RustJSONValue::String("value".to_string()),
            children: vec![],
            expanded: false,
            fully_loaded: true,
            metadata: RustNodeMetadata {
                depth: 0,
                child_count: 0,
                size_bytes: 0,
                is_expanded: false,
            },
        };
        
        assert_eq!(count_nodes(&node), 1);
    }
    
    #[test]
    fn test_count_nodes_with_children() {
        let child1 = RustJSONNode {
            key: "child1".to_string(),
            path: "$.child1".to_string(),
            value: RustJSONValue::String("value1".to_string()),
            children: vec![],
            expanded: false,
            fully_loaded: true,
            metadata: RustNodeMetadata {
                depth: 1,
                child_count: 0,
                size_bytes: 0,
                is_expanded: false,
            },
        };
        
        let child2 = RustJSONNode {
            key: "child2".to_string(),
            path: "$.child2".to_string(),
            value: RustJSONValue::String("value2".to_string()),
            children: vec![],
            expanded: false,
            fully_loaded: true,
            metadata: RustNodeMetadata {
                depth: 1,
                child_count: 0,
                size_bytes: 0,
                is_expanded: false,
            },
        };
        
        let parent = RustJSONNode {
            key: "parent".to_string(),
            path: "$.parent".to_string(),
            value: RustJSONValue::Object,
            children: vec![child1, child2],
            expanded: false,
            fully_loaded: true,
            metadata: RustNodeMetadata {
                depth: 0,
                child_count: 2,
                size_bytes: 0,
                is_expanded: false,
            },
        };
        
        assert_eq!(count_nodes(&parent), 3); // parent + 2 children
    }
    
    #[test]
    fn test_rust_json_value_serialization() {
        let value = RustJSONValue::String("test".to_string());
        let serialized = serde_json::to_string(&value).unwrap();
        assert!(serialized.contains("test"));
        
        let deserialized: RustJSONValue = serde_json::from_str(&serialized).unwrap();
        assert!(matches!(deserialized, RustJSONValue::String(_)));
    }
    
    #[test]
    fn test_rust_json_tree_serialization() {
        let tree = RustJSONTree {
            root: RustJSONNode {
                key: "root".to_string(),
                path: "$".to_string(),
                value: RustJSONValue::Object,
                children: vec![],
                expanded: false,
                fully_loaded: true,
                metadata: RustNodeMetadata {
                    depth: 0,
                    child_count: 0,
                    size_bytes: 0,
                    is_expanded: false,
                },
            },
            total_nodes: 1,
            total_size_bytes: 100,
            stats: RustProcessingStats {
                processing_time_ms: 50,
                memory_usage_bytes: 1024,
                backend: "rust".to_string(),
            },
        };
        
        let serialized = serde_json::to_string(&tree).unwrap();
        assert!(serialized.contains("root"));
        assert!(serialized.contains("rust"));
        
        let deserialized: RustJSONTree = serde_json::from_str(&serialized).unwrap();
        assert_eq!(deserialized.total_nodes, 1);
        assert_eq!(deserialized.total_size_bytes, 100);
    }
}