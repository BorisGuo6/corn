#!/usr/bin/env python3
"""
修复CORN项目中的gym导入问题
将所有 'import gym' 替换为 'import gymnasium as gym'
"""

import os
import re
from pathlib import Path

def fix_gym_imports(directory):
    """递归修复目录中所有Python文件的gym导入"""
    directory = Path(directory)
    fixed_files = []
    
    # 查找所有Python文件
    python_files = list(directory.rglob("*.py"))
    
    for py_file in python_files:
        try:
            with open(py_file, 'r', encoding='utf-8') as f:
                content = f.read()
            
            original_content = content
            
            # 修复各种gym导入模式
            # 1. import gym
            content = re.sub(r'^import gym\b', 'import gymnasium as gym', content, flags=re.MULTILINE)
            
            # 2. from gym import
            content = re.sub(r'^from gym import', 'from gymnasium import', content, flags=re.MULTILINE)
            
            # 3. from gym.
            content = re.sub(r'^from gym\.', 'from gymnasium.', content, flags=re.MULTILINE)
            
            # 4. 行内注释中的gym
            content = re.sub(r'#.*\bgym\b', lambda m: m.group(0).replace('gym', 'gymnasium'), content)
            
            # 如果内容有变化，写回文件
            if content != original_content:
                with open(py_file, 'w', encoding='utf-8') as f:
                    f.write(content)
                fixed_files.append(str(py_file))
                print(f"✅ 修复: {py_file}")
            
        except Exception as e:
            print(f"❌ 处理文件 {py_file} 时出错: {e}")
    
    return fixed_files

def main():
    """主函数"""
    print("🔧 开始修复CORN项目中的gym导入问题...")
    
    # 项目根目录
    project_root = Path(__file__).parent
    pkm_src = project_root / "pkm" / "src"
    
    if not pkm_src.exists():
        print(f"❌ 找不到pkm源码目录: {pkm_src}")
        return
    
    print(f"📁 扫描目录: {pkm_src}")
    
    # 修复导入
    fixed_files = fix_gym_imports(pkm_src)
    
    print(f"\n🎉 修复完成！共修复了 {len(fixed_files)} 个文件")
    
    if fixed_files:
        print("\n📋 修复的文件列表:")
        for file in fixed_files:
            print(f"   - {file}")
    
    print("\n💡 现在可以尝试运行CORN训练脚本了")

if __name__ == "__main__":
    main()
