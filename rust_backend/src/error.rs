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

#[cfg(test)]
mod tests {
    use super::*;
    
    #[test]
    fn test_result_type() {
        let result: Result<String> = Ok("test".to_string());
        assert!(result.is_ok());
        
        let result: Result<String> = Err(TreonError::invalid_input("test error"));
        assert!(result.is_err());
    }
    
    #[test]
    fn test_json_parsing_error() {
        let error = TreonError::json_parsing("Invalid JSON");
        assert!(matches!(error, TreonError::JsonParsing(_)));
        assert_eq!(error.to_string(), "JSON parsing error: Invalid JSON");
    }
    
    #[test]
    fn test_invalid_input_error() {
        let error = TreonError::invalid_input("Invalid input");
        assert!(matches!(error, TreonError::InvalidInput(_)));
        assert_eq!(error.to_string(), "Invalid input: Invalid input");
    }
    
    #[test]
    fn test_memory_error() {
        let error = TreonError::memory_error("Out of memory");
        assert!(matches!(error, TreonError::MemoryError(_)));
        assert_eq!(error.to_string(), "Memory allocation error: Out of memory");
    }
    
    #[test]
    fn test_timeout_error() {
        let error = TreonError::timeout("Processing timeout");
        assert!(matches!(error, TreonError::Timeout(_)));
        assert_eq!(error.to_string(), "Processing timeout: Processing timeout");
    }
    
    #[test]
    fn test_internal_error() {
        let error = TreonError::internal("Internal error");
        assert!(matches!(error, TreonError::Internal(_)));
        assert_eq!(error.to_string(), "Internal error: Internal error");
    }
    
    #[test]
    fn test_io_error_conversion() {
        let io_error = std::io::Error::new(std::io::ErrorKind::NotFound, "File not found");
        let treon_error: TreonError = io_error.into();
        assert!(matches!(treon_error, TreonError::Io(_)));
    }
    
    #[test]
    fn test_error_display() {
        let error = TreonError::json_parsing("Test error");
        let error_string = format!("{}", error);
        assert!(error_string.contains("JSON parsing error"));
        assert!(error_string.contains("Test error"));
    }
}