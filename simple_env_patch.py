#!/usr/bin/env python3
"""
简化的CORN环境补丁
绕过复杂的3D处理依赖，提供基本功能
"""

import warnings
warnings.warn("使用简化环境补丁，某些3D功能可能受限", UserWarning)

# 模拟缺失的模块
class MockCoacd:
    def __init__(self):
        pass
    
    def run_coacd(self, *args, **kwargs):
        # 返回空的结果
        return []

class MockPymeshlab:
    def __init__(self):
        pass
    
    def MeshSet(self):
        return MockMeshSet()

class MockMeshSet:
    def __init__(self):
        pass
    
    def load_new_mesh(self, *args, **kwargs):
        pass
    
    def save_current_mesh(self, *args, **kwargs):
        pass

# 替换缺失的模块
import sys
sys.modules['coacd'] = MockCoacd()
sys.modules['pymeshlab'] = MockPymeshlab()

print("✅ 简化环境补丁已加载")
print("⚠️  某些3D处理功能可能受限")
