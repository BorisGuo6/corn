#!/usr/bin/env python3
"""
mvp兼容性补丁
为CORN项目提供mvp模块的替代实现
"""
import warnings
warnings.warn("使用mvp兼容性补丁，某些视觉功能可能受限", UserWarning)

import torch
import torch.nn as nn

class MockMvpModel(nn.Module):
    """模拟的MVP模型"""
    def __init__(self, model_name="vits-mae-hoi"):
        super().__init__()
        self.model_name = model_name
        # 创建一个简单的特征提取器，输出384维特征
        self.feature_extractor = nn.Sequential(
            nn.Conv2d(3, 64, kernel_size=7, stride=2, padding=3),
            nn.ReLU(),
            nn.AdaptiveAvgPool2d((1, 1)),
            nn.Flatten(),
            nn.Linear(64, 384)
        )
        
    def forward(self, x):
        # x: [batch, channels, height, width]
        return self.feature_extractor(x)

def load(model_name):
    """模拟mvp.load函数"""
    print(f"⚠️  使用模拟的MVP模型: {model_name}")
    print("⚠️  这是一个兼容性补丁，实际功能受限")
    return MockMvpModel(model_name)

# 创建模拟的mvp模块
import sys
class MockMvpModule:
    def __init__(self):
        self.load = load

sys.modules['mvp'] = MockMvpModule()
print("✅ mvp兼容性补丁已加载")
print("⚠️  某些视觉特征提取功能可能受限")
