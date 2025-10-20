#!/usr/bin/env python3
"""
Performance Testing Framework for Treon JSON Processing
Tests different implementation approaches for JSON processing performance
"""

import json
import time
import psutil
import os
import sys
from typing import Dict, List, Tuple
import subprocess
import tempfile

class PerformanceTest:
    def __init__(self):
        self.results = {}
        
    def generate_test_json(self, size_mb: int) -> str:
        """Generate test JSON files of different sizes"""
        # Create nested structure with arrays and objects
        data = {
            "metadata": {
                "version": "1.0",
                "created": "2025-01-18",
                "size_mb": size_mb
            },
            "users": [],
            "products": [],
            "orders": []
        }
        
        # Generate data to reach target size
        target_size = size_mb * 1024 * 1024  # Convert MB to bytes
        current_size = len(json.dumps(data))
        
        # Add users
        for i in range(1000):
            user = {
                "id": i,
                "name": f"User {i}",
                "email": f"user{i}@example.com",
                "profile": {
                    "age": 20 + (i % 50),
                    "city": f"City {i % 100}",
                    "preferences": {
                        "theme": "dark" if i % 2 else "light",
                        "notifications": True,
                        "language": "en" if i % 3 == 0 else "es" if i % 3 == 1 else "fr"
                    }
                },
                "orders": []
            }
            
            # Add orders for each user
            for j in range(5):
                order = {
                    "id": f"{i}_{j}",
                    "date": f"2025-01-{j+1:02d}",
                    "items": [
                        {
                            "product_id": k,
                            "quantity": k + 1,
                            "price": (k + 1) * 10.50,
                            "category": f"Category {k % 10}"
                        } for k in range(3)
                    ],
                    "total": sum((k + 1) * 10.50 for k in range(3))
                }
                user["orders"].append(order)
            
            data["users"].append(user)
            
            # Check if we've reached target size
            current_size = len(json.dumps(data))
            if current_size >= target_size:
                break
        
        return json.dumps(data, indent=2)
    
    def test_python_json_processing(self, json_data: str) -> Dict:
        """Test Python's built-in JSON processing"""
        start_time = time.time()
        start_memory = psutil.Process().memory_info().rss / 1024 / 1024  # MB
        
        # Parse JSON
        data = json.loads(json_data)
        
        # Process data (simulate tree building)
        processed_data = self.process_json_data(data)
        
        # Serialize back to JSON
        result = json.dumps(processed_data)
        
        end_time = time.time()
        end_memory = psutil.Process().memory_info().rss / 1024 / 1024  # MB
        
        return {
            "processing_time": end_time - start_time,
            "memory_used": end_memory - start_memory,
            "peak_memory": end_memory,
            "result_size": len(result)
        }
    
    def process_json_data(self, data: Dict) -> Dict:
        """Simulate JSON processing operations"""
        processed = {
            "summary": {
                "total_users": len(data.get("users", [])),
                "total_orders": sum(len(user.get("orders", [])) for user in data.get("users", [])),
                "average_orders_per_user": 0
            },
            "users": []
        }
        
        if processed["summary"]["total_users"] > 0:
            processed["summary"]["average_orders_per_user"] = (
                processed["summary"]["total_orders"] / processed["summary"]["total_users"]
            )
        
        # Process each user
        for user in data.get("users", []):
            processed_user = {
                "id": user.get("id"),
                "name": user.get("name"),
                "order_count": len(user.get("orders", [])),
                "total_spent": sum(order.get("total", 0) for order in user.get("orders", []))
            }
            processed["users"].append(processed_user)
        
        return processed
    
    def test_cpp_implementation(self, json_file: str) -> Dict:
        """Test C++ implementation (if available)"""
        try:
            # This would call the C++ executable
            cpp_executable = "./cpp/build/Treon"  # Adjust path as needed
            if not os.path.exists(cpp_executable):
                return {"error": "C++ executable not found"}
            
            start_time = time.time()
            start_memory = psutil.Process().memory_info().rss / 1024 / 1024
            
            # Run C++ implementation
            result = subprocess.run(
                [cpp_executable, "--benchmark", json_file],
                capture_output=True,
                text=True,
                timeout=60
            )
            
            end_time = time.time()
            end_memory = psutil.Process().memory_info().rss / 1024 / 1024
            
            return {
                "processing_time": end_time - start_time,
                "memory_used": end_memory - start_memory,
                "peak_memory": end_memory,
                "return_code": result.returncode,
                "stdout": result.stdout,
                "stderr": result.stderr
            }
        except Exception as e:
            return {"error": str(e)}
    
    def test_swift_implementation(self, json_file: str) -> Dict:
        """Test Swift implementation (if available)"""
        try:
            # This would call the Swift executable
            swift_executable = "./swift/Treon"  # Adjust path as needed
            if not os.path.exists(swift_executable):
                return {"error": "Swift executable not found"}
            
            start_time = time.time()
            start_memory = psutil.Process().memory_info().rss / 1024 / 1024
            
            # Run Swift implementation
            result = subprocess.run(
                [swift_executable, "--benchmark", json_file],
                capture_output=True,
                text=True,
                timeout=60
            )
            
            end_time = time.time()
            end_memory = psutil.Process().memory_info().rss / 1024 / 1024
            
            return {
                "processing_time": end_time - start_time,
                "memory_used": end_memory - start_memory,
                "peak_memory": end_memory,
                "return_code": result.returncode,
                "stdout": result.stdout,
                "stderr": result.stderr
            }
        except Exception as e:
            return {"error": str(e)}
    
    def run_benchmark_suite(self):
        """Run complete benchmark suite"""
        print("🚀 Starting Treon Performance Benchmark Suite")
        print("=" * 60)
        
        test_sizes = [1, 10, 50, 100]  # MB
        
        for size_mb in test_sizes:
            print(f"\n📊 Testing {size_mb}MB JSON file...")
            print("-" * 40)
            
            # Generate test data
            print("Generating test data...")
            json_data = self.generate_test_json(size_mb)
            
            # Save to temporary file
            with tempfile.NamedTemporaryFile(mode='w', suffix='.json', delete=False) as f:
                f.write(json_data)
                temp_file = f.name
            
            try:
                # Test Python implementation
                print("Testing Python implementation...")
                python_results = self.test_python_json_processing(json_data)
                print(f"  ⏱️  Time: {python_results['processing_time']:.2f}s")
                print(f"  💾 Memory: {python_results['memory_used']:.1f}MB")
                
                # Test C++ implementation
                print("Testing C++ implementation...")
                cpp_results = self.test_cpp_implementation(temp_file)
                if "error" in cpp_results:
                    print(f"  ❌ Error: {cpp_results['error']}")
                else:
                    print(f"  ⏱️  Time: {cpp_results['processing_time']:.2f}s")
                    print(f"  💾 Memory: {cpp_results['memory_used']:.1f}MB")
                
                # Test Swift implementation
                print("Testing Swift implementation...")
                swift_results = self.test_swift_implementation(temp_file)
                if "error" in swift_results:
                    print(f"  ❌ Error: {swift_results['error']}")
                else:
                    print(f"  ⏱️  Time: {swift_results['processing_time']:.2f}s")
                    print(f"  💾 Memory: {swift_results['memory_used']:.1f}MB")
                
                # Store results
                self.results[size_mb] = {
                    "python": python_results,
                    "cpp": cpp_results,
                    "swift": swift_results
                }
                
            finally:
                # Clean up temporary file
                os.unlink(temp_file)
        
        self.print_summary()
    
    def print_summary(self):
        """Print benchmark summary"""
        print("\n" + "=" * 60)
        print("📈 BENCHMARK SUMMARY")
        print("=" * 60)
        
        print(f"{'Size (MB)':<10} {'Python (s)':<12} {'C++ (s)':<10} {'Swift (s)':<12} {'Winner':<10}")
        print("-" * 60)
        
        for size_mb, results in self.results.items():
            python_time = results["python"]["processing_time"]
            cpp_time = results["cpp"].get("processing_time", float('inf'))
            swift_time = results["swift"].get("processing_time", float('inf'))
            
            # Determine winner
            times = [("Python", python_time), ("C++", cpp_time), ("Swift", swift_time)]
            times = [(name, time) for name, time in times if time != float('inf')]
            winner = min(times, key=lambda x: x[1])[0] if times else "N/A"
            
            print(f"{size_mb:<10} {python_time:<12.2f} {cpp_time:<10.2f} {swift_time:<12.2f} {winner:<10}")
        
        print("\n💡 Performance Insights:")
        print("- C++ is typically fastest for large JSON processing")
        print("- Python is fastest for development but slowest for execution")
        print("- Swift provides good balance between performance and development speed")
        print("- Memory usage varies significantly between implementations")

if __name__ == "__main__":
    benchmark = PerformanceTest()
    benchmark.run_benchmark_suite()
