//! Error handling for the Treon Rust backend

use thiserror::Error;

/// Result type for the Treon Rust backend
#[allow(dead_code)]
pub type Result<T> = std::result::Result<T, TreonError>;

/// Error types for the Treon Rust backend
#[derive(Error, Debug)]
#[allow(dead_code)]
pub enum TreonError {
    #[error("IO error: {0}")]
    Io(#[from] std::io::Error),
    
    #[error("JSON parsing error: {0}")]
    JsonParsing(String),
    
    #[error("Invalid input: {0}")]
    InvalidInput(String),
    
    #[error("Memory allocation error: {0}")]
    MemoryError(String),
    
    #[error("Processing timeout: {0}")]
    Timeout(String),
    
    #[error("Internal error: {0}")]
    Internal(String),
}

#[allow(dead_code)]
impl TreonError {
    /// Create a new JSON parsing error
    pub fn json_parsing(msg: impl Into<String>) -> Self {
        Self::JsonParsing(msg.into())
    }
    
    /// Create a new invalid input error
    pub fn invalid_input(msg: impl Into<String>) -> Self {
        Self::InvalidInput(msg.into())
    }
    
    /// Create a new memory error
    pub fn memory_error(msg: impl Into<String>) -> Self {
        Self::MemoryError(msg.into())
    }
    
    /// Create a new timeout error
    pub fn timeout(msg: impl Into<String>) -> Self {
        Self::Timeout(msg.into())
    }
    
    /// Create a new internal error
    pub fn internal(msg: impl Into<String>) -> Self {
        Self::Internal(msg.into())
    }
}
