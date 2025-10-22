//! Main JSON processor for the Treon Rust backend
//! 
//! This module coordinates JSON processing using streaming parsers and provides
//! the main interface for the Swift frontend.

use crate::error::{Result, TreonError};
use crate::streaming_parser::StreamingParser;
use crate::tree_builder::{JSONTree, ProcessingStats};
use std::path::Path;
use std::time::Instant;

/// Main JSON processor that coordinates parsing and tree building
pub struct JSONProcessor {
    /// Streaming parser for large files
    streaming_parser: StreamingParser,
    
    /// Performance statistics
    stats: ProcessingStats,
}

impl JSONProcessor {
    /// Create a new JSON processor
    pub fn new() -> Self {
        Self {
            streaming_parser: StreamingParser::new(),
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
    
    /// Create a JSON processor with custom streaming settings
    pub fn with_streaming_settings(max_depth: usize, max_children: usize, chunk_size: usize) -> Self {
        Self {
            streaming_parser: StreamingParser::with_settings(max_depth, max_children, chunk_size),
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
    
    /// Process a JSON file and return a tree structure
    pub async fn process_file(&self, file_path: &str) -> Result<JSONTree> {
        let start_time = Instant::now();
        log::info!("🚀 Starting JSON processing for file: {}", file_path);
        
        let path = Path::new(file_path);
        if !path.exists() {
            return Err(TreonError::file_not_found(file_path));
        }
        
        // Check file size to determine processing strategy
        let metadata = tokio::fs::metadata(path).await?;
        let file_size = metadata.len() as usize;
        
        log::info!("📊 File size: {} bytes ({:.2} MB)", file_size, file_size as f64 / 1024.0 / 1024.0);
        
        // Process based on file size
        let root = if file_size > 50 * 1024 * 1024 { // 50MB threshold
            log::info!("📊 Using streaming parser for large file");
            self.streaming_parser.parse_file(path).await?
        } else {
            log::info!("📊 Using standard parser for medium file");
            self.parse_standard_file(path).await?
        };
        
        let processing_time = start_time.elapsed().as_millis() as u64;
        
        // Create the tree with statistics
        let mut tree = JSONTree::new(root, file_size);
        tree.stats = ProcessingStats {
            processing_time_ms: processing_time,
            parsing_time_ms: processing_time / 2, // Rough estimate
            tree_building_time_ms: processing_time / 2,
            peak_memory_bytes: file_size / 4, // Rough estimate
            used_streaming: file_size > 50 * 1024 * 1024,
            streaming_chunks: if file_size > 50 * 1024 * 1024 { file_size / (1024 * 1024) } else { 1 },
        };
        
        log::info!("✅ JSON processing completed in {}ms", processing_time);
        log::info!("📊 Tree stats: {} nodes, {} bytes", tree.total_nodes, tree.total_size_bytes);
        
        Ok(tree)
    }
    
    /// Process JSON data from memory
    pub async fn process_data(&self, data: &[u8]) -> Result<JSONTree> {
        let start_time = Instant::now();
        log::info!("🚀 Starting JSON processing for {} bytes of data", data.len());
        
        // Use SIMD-optimized parsing for in-memory data
        let mut json_data = data.to_vec();
        let root = self.parse_memory_data(&mut json_data).await?;
        
        let processing_time = start_time.elapsed().as_millis() as u64;
        
        // Create the tree with statistics
        let mut tree = JSONTree::new(root, data.len());
        tree.stats = ProcessingStats {
            processing_time_ms: processing_time,
            parsing_time_ms: processing_time / 2,
            tree_building_time_ms: processing_time / 2,
            peak_memory_bytes: data.len() / 2,
            used_streaming: false,
            streaming_chunks: 1,
        };
        
        log::info!("✅ JSON processing completed in {}ms", processing_time);
        
        Ok(tree)
    }
    
    /// Parse a standard-sized file using optimized parsing
    async fn parse_standard_file(&self, path: &Path) -> Result<crate::tree_builder::JSONNode> {
        let start_time = Instant::now();
        
        // Read the entire file
        let data = tokio::fs::read(path).await?;
        let mut json_data = data;
        
        // Parse using SIMD-optimized parser
        let root = self.parse_memory_data(&mut json_data).await?;
        
        let parsing_time = start_time.elapsed().as_millis() as u64;
        log::debug!("📊 Standard file parsing completed in {}ms", parsing_time);
        
        Ok(root)
    }
    
    /// Parse JSON data from memory using SIMD optimization
    async fn parse_memory_data(&self, data: &mut [u8]) -> Result<crate::tree_builder::JSONNode> {
        use simd_json::{BorrowedValue, ValueAccess};
        
        let start_time = Instant::now();
        
        // Parse using SIMD-optimized JSON parser
        let value: BorrowedValue = simd_json::from_slice(data)
            .map_err(|e| TreonError::JsonParsing(e))?;
        
        let parsing_time = start_time.elapsed().as_millis() as u64;
        log::debug!("📊 SIMD parsing completed in {}ms", parsing_time);
        
        // Build tree from parsed value
        let tree_start = Instant::now();
        let root = self.build_tree_from_value(&value, "", "$", 0).await?;
        let tree_time = tree_start.elapsed().as_millis() as u64;
        log::debug!("📊 Tree building completed in {}ms", tree_time);
        
        Ok(root)
    }
    
    /// Build a tree from a parsed JSON value
    async fn build_tree_from_value(
        &self,
        value: &BorrowedValue,
        key: &str,
        path: &str,
        depth: usize,
    ) -> Result<crate::tree_builder::JSONNode> {
        use simd_json::ValueAccess;
        use crate::tree_builder::{JSONNode, JSONValue, NodeMetadata};
        
        let start_time = Instant::now();
        
        let (json_value, children) = match value {
            BorrowedValue::String(s) => (JSONValue::String(s.to_string()), Vec::new()),
            BorrowedValue::Number(n) => (JSONValue::Number(n.as_f64().unwrap_or(0.0)), Vec::new()),
            BorrowedValue::Bool(b) => (JSONValue::Boolean(*b), Vec::new()),
            BorrowedValue::Null => (JSONValue::Null, Vec::new()),
            BorrowedValue::Object(obj) => {
                let mut children = Vec::new();
                
                for (k, v) in obj.iter() {
                    let child_path = format!("{}.{}", path, k);
                    let child = self.build_tree_from_value(v, k, &child_path, depth + 1).await?;
                    children.push(child);
                }
                
                (JSONValue::Object, children)
            }
            BorrowedValue::Array(arr) => {
                let mut children = Vec::new();
                
                for (i, v) in arr.iter().enumerate() {
                    let child_path = format!("{}[{}]", path, i);
                    let child = self.build_tree_from_value(v, &i.to_string(), &child_path, depth + 1).await?;
                    children.push(child);
                }
                
                (JSONValue::Array, children)
            }
        };
        
        let processing_time = start_time.elapsed().as_millis() as u64;
        
        let mut node = JSONNode::new(key.to_string(), path.to_string(), json_value);
        node.children = children;
        node.metadata = NodeMetadata {
            size_bytes: 0, // Will be calculated if needed
            depth,
            descendant_count: node.children.len(),
            streamed: false,
            processing_time_ms: processing_time,
        };
        
        Ok(node)
    }
    
    /// Get current performance statistics
    pub fn get_stats(&self) -> &ProcessingStats {
        &self.stats
    }
}

impl Default for JSONProcessor {
    fn default() -> Self {
        Self::new()
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::path::PathBuf;

    #[tokio::test]
    async fn test_json_processor_creation() {
        let processor = JSONProcessor::new();
        assert_eq!(processor.stats.processing_time_ms, 0);
        assert!(!processor.stats.used_streaming);
    }

    #[tokio::test]
    async fn test_process_simple_data() {
        let processor = JSONProcessor::new();
        let json_data = br#"{"name": "test", "value": 42, "active": true}"#;
        
        let result = processor.process_data(json_data).await;
        assert!(result.is_ok());
        
        let tree = result.unwrap();
        assert_eq!(tree.total_nodes, 4); // root + 3 children
        assert_eq!(tree.root.children.len(), 3);
    }

    #[tokio::test]
    async fn test_process_array_data() {
        let processor = JSONProcessor::new();
        let json_data = br#"[1, 2, 3, {"nested": "value"}]"#;
        
        let result = processor.process_data(json_data).await;
        assert!(result.is_ok());
        
        let tree = result.unwrap();
        assert_eq!(tree.root.value, crate::tree_builder::JSONValue::Array);
        assert_eq!(tree.root.children.len(), 4);
    }
}
