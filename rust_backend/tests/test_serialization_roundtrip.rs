//! Serialization roundtrip tests for the Treon Rust backend
//! 
//! Tests that data can be serialized and then deserialized correctly,
//! ensuring data integrity across the serialization boundary.

use treon_rust_backend::*;
use serde_json;

/// Test serialization roundtrip for all JSON value types
#[test]
fn test_json_value_serialization_roundtrip() {
    println!("\n=== JSON Value Serialization Roundtrip Tests ===");
    println!("{:<15} {:<20} {:<20}", "Value Type", "Original", "Roundtrip");
    println!("{}", "-".repeat(60));
    
    let test_values = vec![
        ("String", RustJSONValue::String("hello world".to_string())),
        ("Empty String", RustJSONValue::String("".to_string())),
        ("Unicode String", RustJSONValue::String("Hello 世界 🌍".to_string())),
        ("Number Integer", RustJSONValue::Number(42.0)),
        ("Number Float", RustJSONValue::Number(3.14159)),
        ("Number Zero", RustJSONValue::Number(0.0)),
        ("Number Negative", RustJSONValue::Number(-123.45)),
        ("Boolean True", RustJSONValue::Boolean(true)),
        ("Boolean False", RustJSONValue::Boolean(false)),
        ("Null", RustJSONValue::Null),
        ("Object", RustJSONValue::Object),
        ("Array", RustJSONValue::Array),
    ];
    
    for (value_type, original_value) in test_values {
        // Serialize to JSON string
        let serialized = serde_json::to_string(&original_value)
            .expect("Failed to serialize value");
        
        // Deserialize back to RustJSONValue
        let deserialized: RustJSONValue = serde_json::from_str(&serialized)
            .expect("Failed to deserialize value");
        
        // Verify they are equal
        assert_eq!(original_value, deserialized, 
                  "Roundtrip failed for {}: {:?} != {:?}", 
                  value_type, original_value, deserialized);
        
        let original_str = format!("{:?}", original_value);
        let deserialized_str = format!("{:?}", deserialized);
        
        println!("{:<15} {:<20} {:<20}", 
                 value_type,
                 if original_str.len() > 20 { &original_str[..17] } else { &original_str },
                 if deserialized_str.len() > 20 { &deserialized_str[..17] } else { &deserialized_str });
    }
}

/// Test serialization roundtrip for JSON nodes
#[test]
fn test_json_node_serialization_roundtrip() {
    println!("\n=== JSON Node Serialization Roundtrip Tests ===");
    println!("{:<20} {:<15} {:<20}", "Test Case", "Original", "Roundtrip");
    println!("{}", "-".repeat(60));
    
    let test_cases = vec![
        ("Simple Node", create_simple_node()),
        ("Node with Children", create_node_with_children()),
        ("Deep Node", create_deep_node()),
        ("Wide Node", create_wide_node()),
    ];
    
    for (test_name, original_node) in test_cases {
        // Serialize to JSON string
        let serialized = serde_json::to_string(&original_node)
            .expect("Failed to serialize node");
        
        // Deserialize back to RustJSONNode
        let deserialized: RustJSONNode = serde_json::from_str(&serialized)
            .expect("Failed to deserialize node");
        
        // Verify they are equal
        assert_eq!(original_node, deserialized, 
                  "Roundtrip failed for {}: {:?} != {:?}", 
                  test_name, original_node, deserialized);
        
        println!("{:<20} {:<15} {:<20}", 
                 test_name, "✅ PASS", "✅ PASS");
    }
}

/// Test serialization roundtrip for JSON trees
#[test]
fn test_json_tree_serialization_roundtrip() {
    println!("\n=== JSON Tree Serialization Roundtrip Tests ===");
    println!("{:<20} {:<15} {:<20}", "Test Case", "Original", "Roundtrip");
    println!("{}", "-".repeat(60));
    
    let test_cases = vec![
        ("Simple Tree", create_simple_tree()),
        ("Complex Tree", create_complex_tree()),
        ("Large Tree", create_large_tree()),
    ];
    
    for (test_name, original_tree) in test_cases {
        // Serialize to JSON string
        let serialized = serde_json::to_string(&original_tree)
            .expect("Failed to serialize tree");
        
        // Deserialize back to RustJSONTree
        let deserialized: RustJSONTree = serde_json::from_str(&serialized)
            .expect("Failed to deserialize tree");
        
        // Verify they are equal
        assert_eq!(original_tree, deserialized, 
                  "Roundtrip failed for {}: {:?} != {:?}", 
                  test_name, original_tree, deserialized);
        
        println!("{:<20} {:<15} {:<20}", 
                 test_name, "✅ PASS", "✅ PASS");
    }
}

/// Test serialization roundtrip for node metadata
#[test]
fn test_node_metadata_serialization_roundtrip() {
    println!("\n=== Node Metadata Serialization Roundtrip Tests ===");
    println!("{:<20} {:<15} {:<20}", "Test Case", "Original", "Roundtrip");
    println!("{}", "-".repeat(60));
    
    let test_cases = vec![
        ("Default Metadata", RustNodeMetadata {
            size_bytes: 0,
            depth: 0,
            descendant_count: 0,
            streamed: false,
            processing_time_ms: 0,
        }),
        ("Full Metadata", RustNodeMetadata {
            size_bytes: 1024,
            depth: 5,
            descendant_count: 100,
            streamed: true,
            processing_time_ms: 150,
        }),
        ("Large Values", RustNodeMetadata {
            size_bytes: usize::MAX,
            depth: 1000,
            descendant_count: 1000000,
            streamed: true,
            processing_time_ms: u64::MAX,
        }),
    ];
    
    for (test_name, original_metadata) in test_cases {
        // Serialize to JSON string
        let serialized = serde_json::to_string(&original_metadata)
            .expect("Failed to serialize metadata");
        
        // Deserialize back to RustNodeMetadata
        let deserialized: RustNodeMetadata = serde_json::from_str(&serialized)
            .expect("Failed to deserialize metadata");
        
        // Verify they are equal
        assert_eq!(original_metadata, deserialized, 
                  "Roundtrip failed for {}: {:?} != {:?}", 
                  test_name, original_metadata, deserialized);
        
        println!("{:<20} {:<15} {:<20}", 
                 test_name, "✅ PASS", "✅ PASS");
    }
}

/// Test serialization roundtrip for processing stats
#[test]
fn test_processing_stats_serialization_roundtrip() {
    println!("\n=== Processing Stats Serialization Roundtrip Tests ===");
    println!("{:<20} {:<15} {:<20}", "Test Case", "Original", "Roundtrip");
    println!("{}", "-".repeat(60));
    
    let test_cases = vec![
        ("Default Stats", RustProcessingStats {
            processing_time_ms: 0,
            parsing_time_ms: 0,
            tree_building_time_ms: 0,
            peak_memory_bytes: 0,
            used_streaming: false,
            streaming_chunks: 0,
        }),
        ("Full Stats", RustProcessingStats {
            processing_time_ms: 1000,
            parsing_time_ms: 500,
            tree_building_time_ms: 300,
            peak_memory_bytes: 1024 * 1024,
            used_streaming: true,
            streaming_chunks: 10,
        }),
        ("Large Stats", RustProcessingStats {
            processing_time_ms: u64::MAX,
            parsing_time_ms: u64::MAX,
            tree_building_time_ms: u64::MAX,
            peak_memory_bytes: usize::MAX,
            used_streaming: true,
            streaming_chunks: usize::MAX,
        }),
    ];
    
    for (test_name, original_stats) in test_cases {
        // Serialize to JSON string
        let serialized = serde_json::to_string(&original_stats)
            .expect("Failed to serialize stats");
        
        // Deserialize back to RustProcessingStats
        let deserialized: RustProcessingStats = serde_json::from_str(&serialized)
            .expect("Failed to deserialize stats");
        
        // Verify they are equal
        assert_eq!(original_stats, deserialized, 
                  "Roundtrip failed for {}: {:?} != {:?}", 
                  test_name, original_stats, deserialized);
        
        println!("{:<20} {:<15} {:<20}", 
                 test_name, "✅ PASS", "✅ PASS");
    }
}

/// Test serialization roundtrip for complex nested structures
#[test]
fn test_complex_nested_serialization_roundtrip() {
    println!("\n=== Complex Nested Serialization Roundtrip Tests ===");
    println!("{:<20} {:<15} {:<20}", "Test Case", "Original", "Roundtrip");
    println!("{}", "-".repeat(60));
    
    let test_cases = vec![
        ("Deep Nesting", create_deeply_nested_structure()),
        ("Wide Structure", create_wide_structure()),
        ("Mixed Types", create_mixed_type_structure()),
        ("Edge Cases", create_edge_case_structure()),
    ];
    
    for (test_name, original_tree) in test_cases {
        // Serialize to JSON string
        let serialized = serde_json::to_string(&original_tree)
            .expect("Failed to serialize complex structure");
        
        // Deserialize back to RustJSONTree
        let deserialized: RustJSONTree = serde_json::from_str(&serialized)
            .expect("Failed to deserialize complex structure");
        
        // Verify they are equal
        assert_eq!(original_tree, deserialized, 
                  "Roundtrip failed for {}: {:?} != {:?}", 
                  test_name, original_tree, deserialized);
        
        println!("{:<20} {:<15} {:<20}", 
                 test_name, "✅ PASS", "✅ PASS");
    }
}

/// Test serialization performance
#[test]
fn test_serialization_performance() {
    println!("\n=== Serialization Performance Tests ===");
    println!("{:<20} {:<15} {:<15} {:<15}", "Test Case", "Size(bytes)", "Time(ms)", "MB/s");
    println!("{}", "-".repeat(70));
    
    let test_cases = vec![
        ("Small Tree", create_simple_tree()),
        ("Medium Tree", create_complex_tree()),
        ("Large Tree", create_large_tree()),
    ];
    
    for (test_name, tree) in test_cases {
        let start_time = std::time::Instant::now();
        
        // Serialize
        let serialized = serde_json::to_string(&tree)
            .expect("Failed to serialize tree");
        
        // Deserialize
        let _deserialized: RustJSONTree = serde_json::from_str(&serialized)
            .expect("Failed to deserialize tree");
        
        let elapsed = start_time.elapsed();
        let size_mb = serialized.len() as f64 / (1024.0 * 1024.0);
        let time_sec = elapsed.as_secs_f64();
        let mb_per_sec = if time_sec > 0.0 { size_mb / time_sec } else { 0.0 };
        
        println!("{:<20} {:<15} {:<15} {:<15.2}", 
                 test_name, 
                 serialized.len(), 
                 elapsed.as_millis(), 
                 mb_per_sec);
    }
}

/// Test serialization consistency across multiple runs
#[test]
fn test_serialization_consistency() {
    println!("\n=== Serialization Consistency Tests ===");
    println!("{:<20} {:<15} {:<15} {:<15}", "Test Case", "Run", "Size(bytes)", "Status");
    println!("{}", "-".repeat(70));
    
    let tree = create_complex_tree();
    let iterations = 5;
    
    let mut sizes = Vec::new();
    
    for i in 0..iterations {
        let serialized = serde_json::to_string(&tree)
            .expect("Failed to serialize tree");
        
        sizes.push(serialized.len());
        
        println!("{:<20} {:<15} {:<15} {:<15}", 
                 "Complex Tree", 
                 i + 1, 
                 serialized.len(), 
                 "✅ PASS");
    }
    
    // Verify all serializations produce the same size
    let first_size = sizes[0];
    let all_same_size = sizes.iter().all(|&size| size == first_size);
    
    assert!(all_same_size, "Serialization is not consistent: sizes = {:?}", sizes);
    
    println!("\nConsistency check: {}", if all_same_size { "✅ PASS" } else { "❌ FAIL" });
}

// Helper functions to create test data

fn create_simple_node() -> RustJSONNode {
    RustJSONNode {
        key: "simple_key".to_string(),
        path: "$.simple_key".to_string(),
        value: RustJSONValue::String("simple_value".to_string()),
        children: vec![],
        expanded: false,
        fully_loaded: true,
        metadata: RustNodeMetadata {
            size_bytes: 12,
            depth: 1,
            descendant_count: 0,
            streamed: false,
            processing_time_ms: 1,
        },
    }
}

fn create_node_with_children() -> RustJSONNode {
    let mut node = RustJSONNode {
        key: "parent".to_string(),
        path: "$.parent".to_string(),
        value: RustJSONValue::Object,
        children: vec![],
        expanded: true,
        fully_loaded: true,
        metadata: RustNodeMetadata {
            size_bytes: 50,
            depth: 1,
            descendant_count: 2,
            streamed: false,
            processing_time_ms: 5,
        },
    };
    
    let child1 = RustJSONNode {
        key: "child1".to_string(),
        path: "$.parent.child1".to_string(),
        value: RustJSONValue::Number(42.0),
        children: vec![],
        expanded: false,
        fully_loaded: true,
        metadata: RustNodeMetadata {
            size_bytes: 8,
            depth: 2,
            descendant_count: 0,
            streamed: false,
            processing_time_ms: 1,
        },
    };
    
    let child2 = RustJSONNode {
        key: "child2".to_string(),
        path: "$.parent.child2".to_string(),
        value: RustJSONValue::Boolean(true),
        children: vec![],
        expanded: false,
        fully_loaded: true,
        metadata: RustNodeMetadata {
            size_bytes: 4,
            depth: 2,
            descendant_count: 0,
            streamed: false,
            processing_time_ms: 1,
        },
    };
    
    node.children = vec![child1, child2];
    node
}

fn create_deep_node() -> RustJSONNode {
    let mut current = RustJSONNode {
        key: "level0".to_string(),
        path: "$.level0".to_string(),
        value: RustJSONValue::Object,
        children: vec![],
        expanded: true,
        fully_loaded: true,
        metadata: RustNodeMetadata {
            size_bytes: 100,
            depth: 0,
            descendant_count: 1,
            streamed: false,
            processing_time_ms: 10,
        },
    };
    
    for i in 1..5 {
        let child = RustJSONNode {
            key: format!("level{}", i),
            path: format!("$.level0.level{}", i),
            value: if i == 4 { RustJSONValue::String("deep_value".to_string()) } else { RustJSONValue::Object },
            children: vec![],
            expanded: i < 4,
            fully_loaded: true,
            metadata: RustNodeMetadata {
                size_bytes: 20,
                depth: i,
                descendant_count: if i == 4 { 0 } else { 1 },
                streamed: false,
                processing_time_ms: 2,
            },
        };
        
        current.children = vec![child];
        current = current.children.into_iter().next().unwrap();
    }
    
    // Rebuild the tree structure
    create_deep_node_rebuild()
}

fn create_deep_node_rebuild() -> RustJSONNode {
    let level4 = RustJSONNode {
        key: "level4".to_string(),
        path: "$.level0.level1.level2.level3.level4".to_string(),
        value: RustJSONValue::String("deep_value".to_string()),
        children: vec![],
        expanded: false,
        fully_loaded: true,
        metadata: RustNodeMetadata {
            size_bytes: 20,
            depth: 4,
            descendant_count: 0,
            streamed: false,
            processing_time_ms: 2,
        },
    };
    
    let level3 = RustJSONNode {
        key: "level3".to_string(),
        path: "$.level0.level1.level2.level3".to_string(),
        value: RustJSONValue::Object,
        children: vec![level4],
        expanded: true,
        fully_loaded: true,
        metadata: RustNodeMetadata {
            size_bytes: 20,
            depth: 3,
            descendant_count: 1,
            streamed: false,
            processing_time_ms: 2,
        },
    };
    
    let level2 = RustJSONNode {
        key: "level2".to_string(),
        path: "$.level0.level1.level2".to_string(),
        value: RustJSONValue::Object,
        children: vec![level3],
        expanded: true,
        fully_loaded: true,
        metadata: RustNodeMetadata {
            size_bytes: 20,
            depth: 2,
            descendant_count: 1,
            streamed: false,
            processing_time_ms: 2,
        },
    };
    
    let level1 = RustJSONNode {
        key: "level1".to_string(),
        path: "$.level0.level1".to_string(),
        value: RustJSONValue::Object,
        children: vec![level2],
        expanded: true,
        fully_loaded: true,
        metadata: RustNodeMetadata {
            size_bytes: 20,
            depth: 1,
            descendant_count: 1,
            streamed: false,
            processing_time_ms: 2,
        },
    };
    
    RustJSONNode {
        key: "level0".to_string(),
        path: "$.level0".to_string(),
        value: RustJSONValue::Object,
        children: vec![level1],
        expanded: true,
        fully_loaded: true,
        metadata: RustNodeMetadata {
            size_bytes: 100,
            depth: 0,
            descendant_count: 1,
            streamed: false,
            processing_time_ms: 10,
        },
    }
}

fn create_wide_node() -> RustJSONNode {
    let mut node = RustJSONNode {
        key: "wide_parent".to_string(),
        path: "$.wide_parent".to_string(),
        value: RustJSONValue::Object,
        children: vec![],
        expanded: true,
        fully_loaded: true,
        metadata: RustNodeMetadata {
            size_bytes: 200,
            depth: 1,
            descendant_count: 10,
            streamed: false,
            processing_time_ms: 20,
        },
    };
    
    for i in 0..10 {
        let child = RustJSONNode {
            key: format!("item_{}", i),
            path: format!("$.wide_parent.item_{}", i),
            value: RustJSONValue::Number(i as f64),
            children: vec![],
            expanded: false,
            fully_loaded: true,
            metadata: RustNodeMetadata {
                size_bytes: 8,
                depth: 2,
                descendant_count: 0,
                streamed: false,
                processing_time_ms: 1,
            },
        };
        node.children.push(child);
    }
    
    node
}

fn create_simple_tree() -> RustJSONTree {
    RustJSONTree {
        root: create_simple_node(),
        total_nodes: 1,
        total_size_bytes: 12,
        stats: RustProcessingStats {
            processing_time_ms: 1,
            parsing_time_ms: 1,
            tree_building_time_ms: 0,
            peak_memory_bytes: 1024,
            used_streaming: false,
            streaming_chunks: 0,
        },
    }
}

fn create_complex_tree() -> RustJSONTree {
    RustJSONTree {
        root: create_node_with_children(),
        total_nodes: 3,
        total_size_bytes: 62,
        stats: RustProcessingStats {
            processing_time_ms: 7,
            parsing_time_ms: 3,
            tree_building_time_ms: 4,
            peak_memory_bytes: 2048,
            used_streaming: false,
            streaming_chunks: 0,
        },
    }
}

fn create_large_tree() -> RustJSONTree {
    RustJSONTree {
        root: create_wide_node(),
        total_nodes: 11,
        total_size_bytes: 280,
        stats: RustProcessingStats {
            processing_time_ms: 30,
            parsing_time_ms: 10,
            tree_building_time_ms: 20,
            peak_memory_bytes: 4096,
            used_streaming: false,
            streaming_chunks: 0,
        },
    }
}

fn create_deeply_nested_structure() -> RustJSONTree {
    RustJSONTree {
        root: create_deep_node(),
        total_nodes: 5,
        total_size_bytes: 180,
        stats: RustProcessingStats {
            processing_time_ms: 20,
            parsing_time_ms: 5,
            tree_building_time_ms: 15,
            peak_memory_bytes: 3072,
            used_streaming: false,
            streaming_chunks: 0,
        },
    }
}

fn create_wide_structure() -> RustJSONTree {
    create_large_tree()
}

fn create_mixed_type_structure() -> RustJSONTree {
    let mut root = RustJSONNode {
        key: "".to_string(),
        path: "$".to_string(),
        value: RustJSONValue::Object,
        children: vec![],
        expanded: true,
        fully_loaded: true,
        metadata: RustNodeMetadata {
            size_bytes: 100,
            depth: 0,
            descendant_count: 4,
            streamed: false,
            processing_time_ms: 10,
        },
    };
    
    let children = vec![
        ("string_field", RustJSONValue::String("hello".to_string())),
        ("number_field", RustJSONValue::Number(42.5)),
        ("boolean_field", RustJSONValue::Boolean(true)),
        ("null_field", RustJSONValue::Null),
    ];
    
    for (_i, (key, value)) in children.iter().enumerate() {
        let child = RustJSONNode {
            key: key.to_string(),
            path: format!("$.{}", key),
            value: value.clone(),
            children: vec![],
            expanded: false,
            fully_loaded: true,
            metadata: RustNodeMetadata {
                size_bytes: 10,
                depth: 1,
                descendant_count: 0,
                streamed: false,
                processing_time_ms: 1,
            },
        };
        root.children.push(child);
    }
    
    RustJSONTree {
        root,
        total_nodes: 5,
        total_size_bytes: 140,
        stats: RustProcessingStats {
            processing_time_ms: 15,
            parsing_time_ms: 5,
            tree_building_time_ms: 10,
            peak_memory_bytes: 1536,
            used_streaming: false,
            streaming_chunks: 0,
        },
    }
}

fn create_edge_case_structure() -> RustJSONTree {
    let mut root = RustJSONNode {
        key: "".to_string(),
        path: "$".to_string(),
        value: RustJSONValue::Object,
        children: vec![],
        expanded: true,
        fully_loaded: true,
        metadata: RustNodeMetadata {
            size_bytes: 50,
            depth: 0,
            descendant_count: 3,
            streamed: false,
            processing_time_ms: 5,
        },
    };
    
    let children = vec![
        ("empty_string", RustJSONValue::String("".to_string())),
        ("zero_number", RustJSONValue::Number(0.0)),
        ("unicode_string", RustJSONValue::String("Hello 世界 🌍".to_string())),
    ];
    
    for (_i, (key, value)) in children.iter().enumerate() {
        let child = RustJSONNode {
            key: key.to_string(),
            path: format!("$.{}", key),
            value: value.clone(),
            children: vec![],
            expanded: false,
            fully_loaded: true,
            metadata: RustNodeMetadata {
                size_bytes: 15,
                depth: 1,
                descendant_count: 0,
                streamed: false,
                processing_time_ms: 1,
            },
        };
        root.children.push(child);
    }
    
    RustJSONTree {
        root,
        total_nodes: 4,
        total_size_bytes: 95,
        stats: RustProcessingStats {
            processing_time_ms: 8,
            parsing_time_ms: 3,
            tree_building_time_ms: 5,
            peak_memory_bytes: 1024,
            used_streaming: false,
            streaming_chunks: 0,
        },
    }
}
