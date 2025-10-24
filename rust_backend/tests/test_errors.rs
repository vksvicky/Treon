//! Unit tests for error handling module

use treon_rust_backend::*;

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