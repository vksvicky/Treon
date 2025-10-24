#!/usr/bin/env bash
set -euo pipefail

# Test script for Rust backend only
echo "🦀 Running Rust backend tests..."

cd rust_backend

# Run all Rust tests
echo "📋 Running all Rust tests..."
cargo test --release

# Run specific comprehensive file size tests
echo "📊 Running comprehensive file size tests..."
cargo test --release test_comprehensive_file_sizes

# Run serialization tests
echo "🔄 Running serialization tests..."
cargo test --release test_rust_json_value_serialization
cargo test --release test_rust_json_tree_serialization

# Run FFI tests
echo "🔗 Running FFI tests..."
cargo test --release test_treon_rust_process_data

echo "✅ All Rust tests completed successfully!"
