#!/usr/bin/env python3
"""
vulkan兼容性补丁
为CORN项目修复set_vulkan_device函数中的索引错误
"""
import warnings
warnings.warn("使用vulkan兼容性补丁，某些渲染功能可能受限", UserWarning)

import os
import subprocess
import sys

def set_vulkan_device():
    """修复的set_vulkan_device函数"""
    try:
        # 尝试运行vulkaninfo命令
        vk_info = subprocess.run(
            'vulkaninfo',
            env=dict(MESA_VK_DEVICE_SELECT='list'),
            check=True,
            stderr=subprocess.PIPE,
            stdout=subprocess.DEVNULL
        ).stderr
        
        vk_info = vk_info.decode('utf-8').split('\n')
        vk_info = [s for s in vk_info if 'discrete GPU' in s]
        
        if vk_info:
            # 安全地获取最后一个元素
            last_info = vk_info[-1]
            if ': ' in last_info and ' "' in last_info:
                vk_device = last_info.split(': ', 1)[1].split(' "', 1)[0]
                print('vk_device', vk_device)
                os.environ['MESA_VK_DEVICE_SELECT'] = vk_device
            else:
                print('⚠️ 无法解析vulkan设备信息，使用默认设置')
                os.environ['MESA_VK_DEVICE_SELECT'] = '0'
        else:
            print('⚠️ 未找到discrete GPU，使用默认设置')
            os.environ['MESA_VK_DEVICE_SELECT'] = '0'
            
    except (subprocess.CalledProcessError, IndexError, Exception) as e:
        print(f'⚠️ vulkan设备设置失败: {e}，使用默认设置')
        os.environ['MESA_VK_DEVICE_SELECT'] = '0'

# 尝试立即应用补丁
try:
    import pkm.env.common
    pkm.env.common.set_vulkan_device = set_vulkan_device
    print("✅ vulkan补丁已立即应用")
except ImportError:
    print("⚠️ 无法立即应用vulkan补丁，将在运行时应用")
    # 创建一个monkey patch函数
    def monkey_patch_vulkan():
        try:
            import pkm.env.common
            pkm.env.common.set_vulkan_device = set_vulkan_device
            print("✅ vulkan补丁已应用")
        except ImportError:
            print("⚠️ 无法应用vulkan补丁，模块未导入")
    
    # 将补丁函数添加到全局命名空间
    globals()['monkey_patch_vulkan'] = monkey_patch_vulkan

print("✅ vulkan兼容性补丁已加载")
print("⚠️  某些渲染功能可能受限")
