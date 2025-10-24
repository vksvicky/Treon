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
    pub tree_builder: TreeBuilder,
    pub max_file_size: usize,
    pub timeout_seconds: u64,
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
