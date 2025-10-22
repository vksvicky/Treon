//! Error handling for the Treon Rust backend

use thiserror::Error;

/// Errors that can occur in the Treon Rust backend
#[derive(Error, Debug)]
pub enum TreonError {
    #[error("IO error: {0}")]
    Io(#[from] std::io::Error),
    
    #[error("JSON parsing error: {0}")]
    JsonParsing(#[from] simd_json::Error),
    
    #[error("JSON serialization error: {0}")]
    JsonSerialization(#[from] serde_json::Error),
    
    #[error("File not found: {0}")]
    FileNotFound(String),
    
    #[error("Invalid file format: {0}")]
    InvalidFileFormat(String),
    
    #[error("Memory allocation error: {0}")]
    MemoryError(String),
    
    #[error("Processing timeout: {0}")]
    Timeout(String),
    
    #[error("Invalid UTF-8: {0}")]
    InvalidUtf8(#[from] std::str::Utf8Error),
    
    #[error("Generic error: {0}")]
    Generic(String),
}

/// Result type for Treon operations
pub type Result<T> = std::result::Result<T, TreonError>;

impl TreonError {
    /// Create a generic error with a message
    pub fn generic(msg: impl Into<String>) -> Self {
        Self::Generic(msg.into())
    }
    
    /// Create a file not found error
    pub fn file_not_found(path: impl Into<String>) -> Self {
        Self::FileNotFound(path.into())
    }
    
    /// Create an invalid file format error
    pub fn invalid_file_format(reason: impl Into<String>) -> Self {
        Self::InvalidFileFormat(reason.into())
    }
    
    /// Create a memory error
    pub fn memory_error(reason: impl Into<String>) -> Self {
        Self::MemoryError(reason.into())
    }
    
    /// Create a timeout error
    pub fn timeout(reason: impl Into<String>) -> Self {
        Self::Timeout(reason.into())
    }
}
