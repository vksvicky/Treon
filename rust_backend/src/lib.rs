//! Treon Rust Backend
//! 
//! High-performance JSON processing backend for the Treon macOS application.
//! This module provides FFI functions that can be called from Swift.

use std::ffi::{CStr, CString};
use std::os::raw::c_char;

pub mod error;
pub mod tree_builder;
pub mod json_processor;

// Re-export the main types for easier access in tests
pub use error::{TreonError, Result};
pub use tree_builder::{JSONNode, JSONValue, JSONTree, TreeBuilder};
pub use json_processor::JSONProcessor;

use serde::{Deserialize, Serialize};
use log::{info, error};

/// Rust JSON tree structure that matches Swift expectations
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct RustJSONTree {
    pub root: RustJSONNode,
    pub total_nodes: usize,
    pub total_size_bytes: usize,
    pub stats: RustProcessingStats,
}

/// Rust JSON node structure that matches Swift expectations
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct RustJSONNode {
    pub key: String,
    pub path: String,
    pub value: RustJSONValue,
    pub children: Vec<RustJSONNode>,
    pub expanded: bool,
    pub fully_loaded: bool,
    pub metadata: RustNodeMetadata,
}

/// Rust JSON value type that matches Swift expectations
#[derive(Debug, Clone, PartialEq)]
pub enum RustJSONValue {
    String(String),
    Number(f64),
    Boolean(bool),
    Null,
    Object,
    Array,
}

impl Serialize for RustJSONValue {
    fn serialize<S>(&self, serializer: S) -> std::result::Result<S::Ok, S::Error>
    where
        S: serde::Serializer,
    {
        match self {
            RustJSONValue::String(s) => serializer.serialize_str(s),
            RustJSONValue::Number(n) => serializer.serialize_f64(*n),
            RustJSONValue::Boolean(b) => serializer.serialize_bool(*b),
            RustJSONValue::Null => serializer.serialize_none(),
            RustJSONValue::Object => serializer.serialize_str("Object"),
            RustJSONValue::Array => serializer.serialize_str("Array"),
        }
    }
}

impl<'de> Deserialize<'de> for RustJSONValue {
    fn deserialize<D>(deserializer: D) -> std::result::Result<Self, D::Error>
    where
        D: serde::Deserializer<'de>,
    {
        use serde::de::{self, Visitor};
        use std::fmt;

        struct RustJSONValueVisitor;

        impl<'de> Visitor<'de> for RustJSONValueVisitor {
            type Value = RustJSONValue;

            fn expecting(&self, formatter: &mut fmt::Formatter) -> fmt::Result {
                formatter.write_str("a JSON value")
            }

            fn visit_str<E>(self, value: &str) -> std::result::Result<RustJSONValue, E>
            where
                E: de::Error,
            {
                match value {
                    "Object" => Ok(RustJSONValue::Object),
                    "Array" => Ok(RustJSONValue::Array),
                    s => Ok(RustJSONValue::String(s.to_string())),
                }
            }

            fn visit_string<E>(self, value: String) -> std::result::Result<RustJSONValue, E>
            where
                E: de::Error,
            {
                match value.as_str() {
                    "Object" => Ok(RustJSONValue::Object),
                    "Array" => Ok(RustJSONValue::Array),
                    _ => Ok(RustJSONValue::String(value)),
                }
            }

            fn visit_f64<E>(self, value: f64) -> std::result::Result<RustJSONValue, E>
            where
                E: de::Error,
            {
                Ok(RustJSONValue::Number(value))
            }

            fn visit_i64<E>(self, value: i64) -> std::result::Result<RustJSONValue, E>
            where
                E: de::Error,
            {
                Ok(RustJSONValue::Number(value as f64))
            }

            fn visit_u64<E>(self, value: u64) -> std::result::Result<RustJSONValue, E>
            where
                E: de::Error,
            {
                Ok(RustJSONValue::Number(value as f64))
            }

            fn visit_bool<E>(self, value: bool) -> std::result::Result<RustJSONValue, E>
            where
                E: de::Error,
            {
                Ok(RustJSONValue::Boolean(value))
            }

            fn visit_none<E>(self) -> std::result::Result<RustJSONValue, E>
            where
                E: de::Error,
            {
                Ok(RustJSONValue::Null)
            }

            fn visit_unit<E>(self) -> std::result::Result<RustJSONValue, E>
            where
                E: de::Error,
            {
                Ok(RustJSONValue::Null)
            }
        }

        deserializer.deserialize_any(RustJSONValueVisitor)
    }
}

/// Rust node metadata that matches Swift expectations
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct RustNodeMetadata {
    pub size_bytes: usize,
    pub depth: usize,
    pub descendant_count: usize,
    pub streamed: bool,
    pub processing_time_ms: u64,
}

/// Rust processing statistics
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct RustProcessingStats {
    pub processing_time_ms: u64,
    pub parsing_time_ms: u64,
    pub tree_building_time_ms: u64,
    pub peak_memory_bytes: usize,
    pub used_streaming: bool,
    pub streaming_chunks: usize,
}

/// Convert JSON value to Rust JSON value
fn convert_json_value(value: &serde_json::Value) -> RustJSONValue {
    match value {
        serde_json::Value::String(s) => RustJSONValue::String(s.clone()),
        serde_json::Value::Number(n) => RustJSONValue::Number(n.as_f64().unwrap_or(0.0)),
        serde_json::Value::Bool(b) => RustJSONValue::Boolean(*b),
        serde_json::Value::Null => RustJSONValue::Null,
        serde_json::Value::Object(_) => RustJSONValue::Object,
        serde_json::Value::Array(_) => RustJSONValue::Array,
    }
}

/// Convert JSON to tree with depth limiting
fn convert_json_to_tree_limited(
    value: &serde_json::Value,
    key: Option<String>,
    path: String,
    depth: usize,
    max_depth: usize,
) -> Result<RustJSONNode> {
    if depth >= max_depth {
        let rust_value = convert_json_value(value);
        return Ok(RustJSONNode {
            key: key.unwrap_or_else(|| "".to_string()),
            path,
            value: rust_value,
            children: Vec::new(),
            expanded: false,
            fully_loaded: false,
            metadata: RustNodeMetadata {
                size_bytes: 0,
                depth,
                descendant_count: 0,
                streamed: false,
                processing_time_ms: 0,
            },
        });
    }

    let rust_value = convert_json_value(value);
    let mut children = Vec::new();
    let mut child_count = 0;
    let mut fully_loaded = true;

    match value {
        serde_json::Value::Object(obj) => {
            let max_children = if obj.len() > 10000 { 50 } else if obj.len() > 1000 { 100 } else { obj.len() };
            
            for (i, (k, v)) in obj.iter().enumerate() {
                if i >= max_children {
                    fully_loaded = false;
                    break;
                }
                
                let child_path = if path == "$" {
                    format!("$.{}", k)
                } else {
                    format!("{}.{}", path, k)
                };
                
                let child = convert_json_to_tree_limited(v, Some(k.clone()), child_path, depth + 1, max_depth)?;
                child_count += 1 + child.metadata.descendant_count;
                children.push(child);
            }
        }
        serde_json::Value::Array(arr) => {
            let max_children = if arr.len() > 10000 { 50 } else if arr.len() > 1000 { 100 } else { arr.len() };
            
            for (i, v) in arr.iter().enumerate() {
                if i >= max_children {
                    fully_loaded = false;
                    break;
                }
                
                let child_path = format!("{}[{}]", path, i);
                let child = convert_json_to_tree_limited(v, Some(i.to_string()), child_path, depth + 1, max_depth)?;
                child_count += 1 + child.metadata.descendant_count;
                children.push(child);
            }
        }
        _ => {}
    }

    Ok(RustJSONNode {
        key: key.unwrap_or_else(|| "".to_string()),
        path,
        value: rust_value,
        children,
        expanded: false,
        fully_loaded,
        metadata: RustNodeMetadata {
            size_bytes: 0,
            depth,
            descendant_count: child_count,
            streamed: false,
            processing_time_ms: 0,
        },
    })
}

/// Process JSON data with depth limiting
fn process_json_data_with_depth(data: &[u8], max_depth: usize) -> Result<RustJSONTree> {
    let start_time = std::time::Instant::now();
    
    // Parse JSON
    let json_value: serde_json::Value = serde_json::from_slice(data)
        .map_err(|e| TreonError::json_parsing(format!("JSON parsing failed: {}", e)))?;
    
    let parsing_time = start_time.elapsed();
    
    // Determine actual depth limit
    let actual_max_depth = if max_depth == 0 {
        // Automatic depth limiting based on file size
        if data.len() > 200 * 1024 * 1024 { 2 } // >200MB: max depth 2
        else if data.len() > 100 * 1024 * 1024 { 3 } // >100MB: max depth 3
        else if data.len() > 50 * 1024 * 1024 { 4 } // >50MB: max depth 4
        else { 5 } // Smaller files: max depth 5
    } else {
        // User-defined depth, but cap it for very large files
        if data.len() > 200 * 1024 * 1024 { std::cmp::min(max_depth, 3) }
        else if data.len() > 100 * 1024 * 1024 { std::cmp::min(max_depth, 5) }
        else if data.len() > 50 * 1024 * 1024 { std::cmp::min(max_depth, 7) }
        else { max_depth }
    };
    
    // Build tree
    let tree_start = std::time::Instant::now();
    let root_node = convert_json_to_tree_limited(&json_value, None, "$".to_string(), 0, actual_max_depth)?;
    let tree_building_time = tree_start.elapsed();
    
    // Count total nodes
    let total_nodes = 1 + root_node.metadata.descendant_count;
    
    log::info!("Built tree with {} total nodes for {} bytes", total_nodes, data.len());
    
    let tree = RustJSONTree {
        root: root_node,
        total_nodes,
        total_size_bytes: data.len(),
        stats: RustProcessingStats {
            processing_time_ms: start_time.elapsed().as_millis() as u64,
            parsing_time_ms: parsing_time.as_millis() as u64,
            tree_building_time_ms: tree_building_time.as_millis() as u64,
            peak_memory_bytes: 0, // TODO: Implement memory tracking
            used_streaming: false,
            streaming_chunks: 0,
        },
    };
    
    Ok(tree)
}

/// Initialize the Rust backend
#[no_mangle]
pub extern "C" fn treon_rust_init() {
    env_logger::init();
    info!("Rust backend initialized");
}

/// Process JSON data from memory
#[no_mangle]
pub extern "C" fn treon_rust_process_data(
    data: *const u8,
    length: i32,
    max_depth: i32,
) -> *mut c_char {
    if data.is_null() || length <= 0 {
        return std::ptr::null_mut();
    }
    
    let data_slice = unsafe { std::slice::from_raw_parts(data, length as usize) };
    
    match process_json_data_with_depth(data_slice, max_depth as usize) {
        Ok(tree) => {
            match serde_json::to_string(&tree) {
                Ok(json_str) => {
                    let c_string = CString::new(json_str).unwrap_or_else(|_| CString::new("{}").unwrap());
                    c_string.into_raw()
                }
                Err(e) => {
                    error!("Failed to serialize tree: {}", e);
                    std::ptr::null_mut()
                }
            }
        }
        Err(e) => {
            error!("Failed to process JSON data: {}", e);
            std::ptr::null_mut()
        }
    }
}

/// Process JSON file
#[no_mangle]
pub extern "C" fn treon_rust_process_file(file_path: *const c_char) -> *mut c_char {
    if file_path.is_null() {
        return std::ptr::null_mut();
    }
    
    let path_cstr = unsafe { CStr::from_ptr(file_path) };
    let path_str = match path_cstr.to_str() {
        Ok(s) => s,
        Err(_) => return std::ptr::null_mut(),
    };
    
    match std::fs::read(path_str) {
        Ok(data) => treon_rust_process_data(data.as_ptr(), data.len() as i32, 0),
        Err(e) => {
            error!("Failed to read file {}: {}", path_str, e);
            std::ptr::null_mut()
        }
    }
}

/// Free a string returned by the Rust backend
#[no_mangle]
pub extern "C" fn treon_rust_free_string(s: *mut c_char) {
    if !s.is_null() {
        unsafe {
            let _ = CString::from_raw(s);
        }
    }
}

/// Get performance statistics
#[no_mangle]
pub extern "C" fn treon_rust_get_stats() -> *mut c_char {
    let stats = serde_json::json!({
        "backend": "rust",
        "version": "1.0.0",
        "status": "active"
    });
    
    match serde_json::to_string(&stats) {
        Ok(json_str) => {
            let c_string = CString::new(json_str).unwrap_or_else(|_| CString::new("{}").unwrap());
            c_string.into_raw()
        }
        Err(_) => std::ptr::null_mut()
    }
}
