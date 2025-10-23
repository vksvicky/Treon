//! JSON processing for the Treon Rust backend
//! 
//! This module provides high-level JSON processing functionality
//! that coordinates between parsing and tree building.

use crate::error::Result;
use crate::tree_builder::{JSONTree, TreeBuilder};
use std::time::Instant;

/// JSON processor for handling large JSON files
#[allow(dead_code)]
pub struct JSONProcessor {
    tree_builder: TreeBuilder,
    max_file_size: usize,
    timeout_seconds: u64,
}

#[allow(dead_code)]
impl JSONProcessor {
    /// Create a new JSON processor
    pub fn new() -> Self {
        Self {
            tree_builder: TreeBuilder::new()
                .with_max_depth(50)
                .with_max_nodes(50_000),
            max_file_size: 1024 * 1024 * 1024, // 1GB
            timeout_seconds: 30,
        }
    }
    
    /// Set the maximum file size to process
    pub fn with_max_file_size(mut self, size: usize) -> Self {
        self.max_file_size = size;
        self
    }
    
    /// Set the processing timeout
    pub fn with_timeout(mut self, seconds: u64) -> Self {
        self.timeout_seconds = seconds;
        self
    }
    
    /// Process JSON data from memory
    pub fn process_data(&self, data: &[u8]) -> Result<JSONTree> {
        let start_time = Instant::now();
        
        // Check data size
        if data.len() > self.max_file_size {
            return Err(crate::error::TreonError::invalid_input(
                format!("Data too large: {} bytes (max: {} bytes)", data.len(), self.max_file_size)
            ));
        }
        
        log::info!("Processing {} bytes of JSON data", data.len());
        
        // Build the tree
        let tree = self.tree_builder.build_from_data(data)?;
        
        let processing_time = start_time.elapsed();
        log::info!("JSON processing completed in {:?}", processing_time);
        
        // Check timeout
        if processing_time.as_secs() > self.timeout_seconds {
            return Err(crate::error::TreonError::timeout(
                format!("Processing took too long: {:?}", processing_time)
            ));
        }
        
        Ok(tree)
    }
    
    /// Process a JSON file
    pub fn process_file(&self, file_path: &str) -> Result<JSONTree> {
        let start_time = Instant::now();
        
        log::info!("Processing JSON file: {}", file_path);
        
        // Check if file exists and get its size
        let metadata = std::fs::metadata(file_path)?;
        if metadata.len() > self.max_file_size as u64 {
            return Err(crate::error::TreonError::invalid_input(
                format!("File too large: {} bytes (max: {} bytes)", metadata.len(), self.max_file_size)
            ));
        }
        
        // Read the file
        let data = std::fs::read(file_path)?;
        
        // Process the data
        let tree = self.process_data(&data)?;
        
        let processing_time = start_time.elapsed();
        log::info!("File processing completed in {:?}", processing_time);
        
        Ok(tree)
    }
    
    /// Get processing statistics
    pub fn get_stats(&self) -> serde_json::Value {
        serde_json::json!({
            "max_file_size": self.max_file_size,
            "timeout_seconds": self.timeout_seconds,
            "max_depth": self.tree_builder.max_depth,
            "max_nodes": self.tree_builder.max_nodes,
            "backend": "rust",
            "version": "0.1.0"
        })
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
    fn test_process_small_data() {
        let processor = JSONProcessor::new();
        let data = b"{}";
        let result = processor.process_data(data);
        assert!(result.is_ok());
        
        let tree = result.unwrap();
        assert_eq!(tree.root.value, crate::tree_builder::JSONValue::Object);
    }
    
    #[test]
    fn test_process_large_data() {
        let processor = JSONProcessor::new().with_max_file_size(100);
        let data = vec![0u8; 200]; // 200 bytes
        let result = processor.process_data(&data);
        assert!(result.is_err());
        
        if let Err(error) = result {
            assert!(matches!(error, crate::error::TreonError::InvalidInput(_)));
        }
    }
    
    #[test]
    fn test_process_data_exactly_at_limit() {
        let processor = JSONProcessor::new().with_max_file_size(100);
        let data = vec![0u8; 100]; // Exactly 100 bytes
        let result = processor.process_data(&data);
        assert!(result.is_ok());
    }
    
    #[test]
    fn test_process_data_just_over_limit() {
        let processor = JSONProcessor::new().with_max_file_size(100);
        let data = vec![0u8; 101]; // Just over 100 bytes
        let result = processor.process_data(&data);
        assert!(result.is_err());
    }
    
    #[test]
    fn test_process_file_success() {
        let temp_dir = tempdir().unwrap();
        let file_path = temp_dir.path().join("test.json");
        
        // Create a test JSON file
        let mut file = File::create(&file_path).unwrap();
        file.write_all(b"{\"test\": \"value\"}").unwrap();
        drop(file);
        
        let processor = JSONProcessor::new();
        let result = processor.process_file(file_path.to_str().unwrap());
        
        assert!(result.is_ok());
        let tree = result.unwrap();
        assert_eq!(tree.root.value, crate::tree_builder::JSONValue::Object);
    }
    
    #[test]
    fn test_process_file_not_found() {
        let processor = JSONProcessor::new();
        let result = processor.process_file("nonexistent.json");
        
        assert!(result.is_err());
        if let Err(error) = result {
            assert!(matches!(error, crate::error::TreonError::Io(_)));
        }
    }
    
    #[test]
    fn test_process_file_too_large() {
        let temp_dir = tempdir().unwrap();
        let file_path = temp_dir.path().join("large.json");
        
        // Create a large test file
        let mut file = File::create(&file_path).unwrap();
        let large_data = vec![0u8; 200]; // 200 bytes
        file.write_all(&large_data).unwrap();
        drop(file);
        
        let processor = JSONProcessor::new().with_max_file_size(100);
        let result = processor.process_file(file_path.to_str().unwrap());
        
        assert!(result.is_err());
        if let Err(error) = result {
            assert!(matches!(error, crate::error::TreonError::InvalidInput(_)));
        }
    }
    
    #[test]
    fn test_get_stats() {
        let processor = JSONProcessor::new()
            .with_max_file_size(2048)
            .with_timeout(60);
        
        let stats = processor.get_stats();
        
        assert_eq!(stats["max_file_size"], 2048);
        assert_eq!(stats["timeout_seconds"], 60);
        assert_eq!(stats["max_depth"], 50);
        assert_eq!(stats["max_nodes"], 50_000);
        assert_eq!(stats["backend"], "rust");
        assert_eq!(stats["version"], "0.1.0");
    }
    
    #[test]
    fn test_process_data_with_timeout() {
        let processor = JSONProcessor::new().with_timeout(0); // Very short timeout
        let data = b"{}";
        
        // This should still succeed because processing is very fast
        let result = processor.process_data(data);
        assert!(result.is_ok());
    }
    
    #[test]
    fn test_process_data_empty() {
        let processor = JSONProcessor::new();
        let data = b"";
        let result = processor.process_data(data);
        
        // Should succeed with empty data
        assert!(result.is_ok());
    }
    
    #[test]
    fn test_process_data_single_byte() {
        let processor = JSONProcessor::new();
        let data = b"a";
        let result = processor.process_data(data);
        
        // Should succeed with single byte
        assert!(result.is_ok());
    }
    
    #[test]
    fn test_process_data_max_size() {
        let processor = JSONProcessor::new();
        let data = vec![0u8; processor.max_file_size];
        let result = processor.process_data(&data);
        
        // Should succeed with data at max size
        assert!(result.is_ok());
    }
    
    #[test]
    fn test_process_data_over_max_size() {
        let processor = JSONProcessor::new();
        let data = vec![0u8; processor.max_file_size + 1];
        let result = processor.process_data(&data);
        
        // Should fail with data over max size
        assert!(result.is_err());
    }
}