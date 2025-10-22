//! JSON tree building for the Treon Rust backend
//! 
//! This module provides efficient tree building with streaming support for large files.

use serde::{Deserialize, Serialize};
use std::collections::HashMap;

/// Represents a JSON value type
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub enum JSONValue {
    String(String),
    Number(f64),
    Boolean(bool),
    Null,
    Object,
    Array,
}

impl JSONValue {
    /// Get the display name for the value type
    pub fn display_name(&self) -> &'static str {
        match self {
            JSONValue::String(_) => "String",
            JSONValue::Number(_) => "Number", 
            JSONValue::Boolean(_) => "Boolean",
            JSONValue::Null => "null",
            JSONValue::Object => "Object",
            JSONValue::Array => "Array",
        }
    }
    
    /// Get the display name with count for containers
    pub fn display_name_with_count(&self, count: usize) -> String {
        match self {
            JSONValue::Object => format!("Object{{{}}}", count),
            JSONValue::Array => format!("Array[{}]", count),
            _ => self.display_name().to_string(),
        }
    }
}

/// Represents a node in the JSON tree
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct JSONNode {
    /// The key for this node (empty for root)
    pub key: String,
    
    /// The path to this node (e.g., "$.users[0].name")
    pub path: String,
    
    /// The value type and data
    pub value: JSONValue,
    
    /// Child nodes (for objects and arrays)
    pub children: Vec<JSONNode>,
    
    /// Whether this node is expanded in the UI
    pub expanded: bool,
    
    /// Whether this node has been fully loaded (for streaming)
    pub fully_loaded: bool,
    
    /// Metadata for performance tracking
    pub metadata: NodeMetadata,
}

/// Metadata for performance tracking and optimization
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct NodeMetadata {
    /// Size of this node's data in bytes
    pub size_bytes: usize,
    
    /// Depth in the tree
    pub depth: usize,
    
    /// Number of total descendants
    pub descendant_count: usize,
    
    /// Whether this node was loaded via streaming
    pub streamed: bool,
    
    /// Processing time in milliseconds
    pub processing_time_ms: u64,
}

impl JSONNode {
    /// Create a new JSON node
    pub fn new(key: String, path: String, value: JSONValue) -> Self {
        Self {
            key,
            path,
            value,
            children: Vec::new(),
            expanded: false,
            fully_loaded: true,
            metadata: NodeMetadata {
                size_bytes: 0,
                depth: 0,
                descendant_count: 0,
                streamed: false,
                processing_time_ms: 0,
            },
        }
    }
    
    /// Create a placeholder node for streaming
    pub fn placeholder(key: String, path: String, value: JSONValue, estimated_count: usize) -> Self {
        Self {
            key,
            path,
            value,
            children: Vec::new(),
            expanded: false,
            fully_loaded: false,
            metadata: NodeMetadata {
                size_bytes: 0,
                depth: 0,
                descendant_count: estimated_count,
                streamed: true,
                processing_time_ms: 0,
            },
        }
    }
    
    /// Add a child node
    pub fn add_child(&mut self, child: JSONNode) {
        self.children.push(child);
        self.metadata.descendant_count += 1;
    }
    
    /// Get the display value for this node
    pub fn display_value(&self) -> String {
        match &self.value {
            JSONValue::String(s) => format!("\"{}\"", s),
            JSONValue::Number(n) => n.to_string(),
            JSONValue::Boolean(b) => b.to_string(),
            JSONValue::Null => "null".to_string(),
            JSONValue::Object => self.value.display_name_with_count(self.children.len()),
            JSONValue::Array => self.value.display_name_with_count(self.children.len()),
        }
    }
    
    /// Check if this node has children
    pub fn has_children(&self) -> bool {
        !self.children.is_empty() || !self.fully_loaded
    }
    
    /// Get the total size of this node and all descendants
    pub fn total_size(&self) -> usize {
        self.metadata.size_bytes + self.children.iter().map(|c| c.total_size()).sum::<usize>()
    }
}

/// Represents the complete JSON tree
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct JSONTree {
    /// Root node of the tree
    pub root: JSONNode,
    
    /// Total number of nodes in the tree
    pub total_nodes: usize,
    
    /// Total size of the JSON data in bytes
    pub total_size_bytes: usize,
    
    /// Processing statistics
    pub stats: ProcessingStats,
}

/// Processing statistics for performance monitoring
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ProcessingStats {
    /// Total processing time in milliseconds
    pub processing_time_ms: u64,
    
    /// Time spent parsing JSON in milliseconds
    pub parsing_time_ms: u64,
    
    /// Time spent building tree in milliseconds
    pub tree_building_time_ms: u64,
    
    /// Peak memory usage in bytes
    pub peak_memory_bytes: usize,
    
    /// Whether streaming was used
    pub used_streaming: bool,
    
    /// Number of streaming chunks processed
    pub streaming_chunks: usize,
}

impl JSONTree {
    /// Create a new JSON tree
    pub fn new(root: JSONNode, total_size_bytes: usize) -> Self {
        let total_nodes = Self::count_nodes(&root);
        
        Self {
            root,
            total_nodes,
            total_size_bytes,
            stats: ProcessingStats {
                processing_time_ms: 0,
                parsing_time_ms: 0,
                tree_building_time_ms: 0,
                peak_memory_bytes: 0,
                used_streaming: false,
                streaming_chunks: 0,
            },
        }
    }
    
    /// Count the total number of nodes in the tree
    fn count_nodes(node: &JSONNode) -> usize {
        1 + node.children.iter().map(Self::count_nodes).sum::<usize>()
    }
    
    /// Get a node by path
    pub fn get_node_by_path(&self, path: &str) -> Option<&JSONNode> {
        self.get_node_by_path_recursive(&self.root, path)
    }
    
    /// Recursively find a node by path
    fn get_node_by_path_recursive(&self, node: &JSONNode, path: &str) -> Option<&JSONNode> {
        if node.path == path {
            return Some(node);
        }
        
        for child in &node.children {
            if let Some(found) = self.get_node_by_path_recursive(child, path) {
                return Some(found);
            }
        }
        
        None
    }
    
    /// Get all nodes at a specific depth
    pub fn get_nodes_at_depth(&self, depth: usize) -> Vec<&JSONNode> {
        let mut result = Vec::new();
        self.collect_nodes_at_depth(&self.root, depth, 0, &mut result);
        result
    }
    
    /// Recursively collect nodes at a specific depth
    fn collect_nodes_at_depth(&self, node: &JSONNode, target_depth: usize, current_depth: usize, result: &mut Vec<&JSONNode>) {
        if current_depth == target_depth {
            result.push(node);
            return;
        }
        
        for child in &node.children {
            self.collect_nodes_at_depth(child, target_depth, current_depth + 1, result);
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_json_node_creation() {
        let node = JSONNode::new("test".to_string(), "$.test".to_string(), JSONValue::String("value".to_string()));
        assert_eq!(node.key, "test");
        assert_eq!(node.path, "$.test");
        assert_eq!(node.value, JSONValue::String("value".to_string()));
        assert!(node.children.is_empty());
    }

    #[test]
    fn test_json_tree_creation() {
        let root = JSONNode::new("".to_string(), "$".to_string(), JSONValue::Object);
        let tree = JSONTree::new(root, 1000);
        assert_eq!(tree.total_nodes, 1);
        assert_eq!(tree.total_size_bytes, 1000);
    }

    #[test]
    fn test_display_value() {
        let string_node = JSONNode::new("name".to_string(), "$.name".to_string(), JSONValue::String("John".to_string()));
        assert_eq!(string_node.display_value(), "\"John\"");
        
        let number_node = JSONNode::new("age".to_string(), "$.age".to_string(), JSONValue::Number(30.0));
        assert_eq!(number_node.display_value(), "30");
        
        let bool_node = JSONNode::new("active".to_string(), "$.active".to_string(), JSONValue::Boolean(true));
        assert_eq!(bool_node.display_value(), "true");
    }
}
