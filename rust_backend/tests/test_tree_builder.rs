//! Unit tests for tree builder module

use treon_rust_backend::*;

#[test]
fn test_json_node_creation() {
    let node = JSONNode::new(
        Some("test_key".to_string()),
        JSONValue::String("test_value".to_string()),
        "$.test_key".to_string(),
        1,
    );
    
    assert_eq!(node.key, Some("test_key".to_string()));
    assert_eq!(node.value, JSONValue::String("test_value".to_string()));
    assert_eq!(node.path, "$.test_key");
    assert_eq!(node.metadata.depth, 1);
    assert_eq!(node.children.len(), 0);
}

#[test]
fn test_json_node_creation_with_none_key() {
    let node = JSONNode::new(
        None,
        JSONValue::Object,
        "$".to_string(),
        0,
    );
    
    assert_eq!(node.key, None);
    assert_eq!(node.value, JSONValue::Object);
    assert_eq!(node.path, "$");
    assert_eq!(node.metadata.depth, 0);
}

#[test]
fn test_json_node_add_child() {
    let mut parent = JSONNode::new(
        Some("parent".to_string()),
        JSONValue::Object,
        "$.parent".to_string(),
        0,
    );
    
    let child = JSONNode::new(
        Some("child".to_string()),
        JSONValue::String("child_value".to_string()),
        "$.parent.child".to_string(),
        1,
    );
    
    parent.add_child(child);
    
    assert_eq!(parent.children.len(), 1);
    assert_eq!(parent.metadata.child_count, 1);
}

#[test]
fn test_json_node_total_nodes() {
    let mut root = JSONNode::new(
        None,
        JSONValue::Object,
        "$".to_string(),
        0,
    );
    
    for i in 0..3 {
        let child = JSONNode::new(
            Some(format!("child_{}", i)),
            JSONValue::String(format!("value_{}", i)),
            format!("$.child_{}", i),
            1,
        );
        root.add_child(child);
    }
    
    assert_eq!(root.total_nodes(), 4); // 1 root + 3 children
}

#[test]
fn test_json_node_max_depth() {
    let mut root = JSONNode::new(
        None,
        JSONValue::Object,
        "$".to_string(),
        0,
    );
    
    let mut child1 = JSONNode::new(
        Some("child1".to_string()),
        JSONValue::Object,
        "$.child1".to_string(),
        1,
    );
    
    let child2 = JSONNode::new(
        Some("child2".to_string()),
        JSONValue::String("deep_value".to_string()),
        "$.child1.child2".to_string(),
        2,
    );
    
    child1.add_child(child2);
    root.add_child(child1);
    
    assert_eq!(root.max_depth(), 2);
}

#[test]
fn test_json_node_placeholder() {
    let placeholder = JSONNode::placeholder(
        "large_array".to_string(),
        "$.large_array".to_string(),
        JSONValue::Array,
        1000,
    );
    
    assert_eq!(placeholder.key, Some("large_array".to_string()));
    assert_eq!(placeholder.value, JSONValue::Array);
    assert_eq!(placeholder.metadata.child_count, 1000);
    assert_eq!(placeholder.children.len(), 0); // Placeholder has no actual children
}

#[test]
fn test_json_value_types() {
    let string_val = JSONValue::String("hello".to_string());
    let number_val = JSONValue::Number(42.5);
    let bool_val = JSONValue::Boolean(true);
    let null_val = JSONValue::Null;
    let object_val = JSONValue::Object;
    let array_val = JSONValue::Array;
    
    assert!(matches!(string_val, JSONValue::String(_)));
    assert!(matches!(number_val, JSONValue::Number(_)));
    assert!(matches!(bool_val, JSONValue::Boolean(_)));
    assert!(matches!(null_val, JSONValue::Null));
    assert!(matches!(object_val, JSONValue::Object));
    assert!(matches!(array_val, JSONValue::Array));
}

#[test]
fn test_json_value_equality() {
    let val1 = JSONValue::String("test".to_string());
    let val2 = JSONValue::String("test".to_string());
    let val3 = JSONValue::String("different".to_string());
    
    assert_eq!(val1, val2);
    assert_ne!(val1, val3);
}

#[test]
fn test_json_tree_creation() {
    let root = JSONNode::new(
        None,
        JSONValue::Object,
        "$".to_string(),
        0,
    );
    
    let tree = JSONTree::new(root);
    
    assert_eq!(tree.total_nodes, 1);
    assert_eq!(tree.max_depth, 0);
    assert_eq!(tree.total_size_bytes, 0);
}

#[test]
fn test_json_tree_with_children() {
    let mut root = JSONNode::new(
        None,
        JSONValue::Object,
        "$".to_string(),
        0,
    );
    
    for i in 0..5 {
        let child = JSONNode::new(
            Some(format!("key_{}", i)),
            JSONValue::String(format!("value_{}", i)),
            format!("$.key_{}", i),
            1,
        );
        root.add_child(child);
    }
    
    let tree = JSONTree::new(root);
    
    assert_eq!(tree.total_nodes, 6); // 1 root + 5 children
    assert_eq!(tree.max_depth, 1);
}

#[test]
fn test_tree_builder_new() {
    let builder = TreeBuilder::new();
    
    assert_eq!(builder.max_depth, 100);
    assert_eq!(builder.max_nodes, 100_000);
}

#[test]
fn test_tree_builder_with_max_depth() {
    let builder = TreeBuilder::new().with_max_depth(50);
    
    assert_eq!(builder.max_depth, 50);
    assert_eq!(builder.max_nodes, 100_000); // Should keep default
}

#[test]
fn test_tree_builder_with_max_nodes() {
    let builder = TreeBuilder::new().with_max_nodes(50_000);
    
    assert_eq!(builder.max_depth, 100); // Should keep default
    assert_eq!(builder.max_nodes, 50_000);
}

#[test]
fn test_tree_builder_chained_configuration() {
    let builder = TreeBuilder::new()
        .with_max_depth(25)
        .with_max_nodes(10_000);
    
    assert_eq!(builder.max_depth, 25);
    assert_eq!(builder.max_nodes, 10_000);
}

#[test]
fn test_tree_builder_default() {
    let builder = TreeBuilder::default();
    
    assert_eq!(builder.max_depth, 100);
    assert_eq!(builder.max_nodes, 100_000);
}

#[test]
fn test_tree_builder_build_from_data() {
    let builder = TreeBuilder::new();
    let data = b"{\"test\": \"data\"}";
    let result = builder.build_from_data(data);
    
    assert!(result.is_ok());
    let tree = result.unwrap();
    assert!(tree.total_nodes > 0);
}

#[test]
fn test_tree_builder_build_from_file() {
    let builder = TreeBuilder::new();
    let result = builder.build_from_file("test_file.json");
    
    assert!(result.is_ok());
    let tree = result.unwrap();
    assert!(tree.total_nodes > 0);
}

#[test]
fn test_tree_builder_build_from_file_with_path() {
    let builder = TreeBuilder::new();
    let result = builder.build_from_file("/path/to/test_file.json");
    
    assert!(result.is_ok());
    let tree = result.unwrap();
    assert!(tree.total_nodes > 0);
    
    // Check that filename was extracted correctly
    assert_eq!(tree.root.children.len(), 1);
    if let Some(child) = tree.root.children.first() {
        assert_eq!(child.key, Some("filename".to_string()));
        assert!(matches!(child.value, JSONValue::String(_)));
    }
}

#[test]
fn test_node_metadata() {
    let node = JSONNode::new(
        Some("test".to_string()),
        JSONValue::String("value".to_string()),
        "$.test".to_string(),
        2,
    );
    
    assert_eq!(node.metadata.depth, 2);
    assert_eq!(node.metadata.child_count, 0);
    assert_eq!(node.metadata.size_bytes, 0);
    assert_eq!(node.metadata.is_expanded, false);
}