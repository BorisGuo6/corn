#!/bin/bash

# CORN 项目环境设置脚本
# 基于实际安装经验总结
# 更新日期: 2024年8月31日

echo "=========================================="
echo "CORN 项目环境设置脚本"
echo "=========================================="

# 检查 conda 是否可用
if ! command -v conda &> /dev/null; then
    echo "❌ 错误: conda 未安装或不在 PATH 中"
    echo "请先安装 Anaconda 或 Miniconda"
    exit 1
fi

# 激活 conda 环境
echo "🔧 激活 conda 环境..."
source ~/anaconda3/etc/profile.d/conda.sh

# 检查 isaacgym 环境是否存在
if ! conda env list | grep -q "isaacgym"; then
    echo "❌ 错误: isaacgym 环境不存在"
    echo "请先创建环境: conda create -n isaacgym python=3.8 -y"
    exit 1
fi

conda activate isaacgym
echo "✅ conda 环境已激活: isaacgym"

# 检查 Python 版本
PYTHON_VERSION=$(python --version 2>&1 | cut -d' ' -f2 | cut -d'.' -f1,2)
if [[ "$PYTHON_VERSION" != "3.8" ]]; then
    echo "⚠️  警告: 当前 Python 版本是 $PYTHON_VERSION，推荐使用 Python 3.8"
    echo "Isaac Gym 仅支持 Python 3.6-3.8"
fi

# 设置 CUDA 环境
echo "🔧 设置 CUDA 环境..."

# 检测可用的 CUDA 版本
if [ -d "/usr/local/cuda-11.8" ]; then
    echo "✅ 检测到 CUDA 11.8"
    export PATH=/usr/local/cuda-11.8/bin:$PATH
    export LD_LIBRARY_PATH=/usr/local/cuda-11.8/lib64:$LD_LIBRARY_PATH
    CUDA_VERSION="11.8"
elif [ -d "/usr/local/cuda-12.1" ]; then
    echo "✅ 检测到 CUDA 12.1"
    export PATH=/usr/local/cuda-12.1/bin:$PATH
    export LD_LIBRARY_PATH=/usr/local/cuda-12.1/lib64:$LD_LIBRARY_PATH
    CUDA_VERSION="12.1"
elif [ -d "/usr/local/cuda-12.4" ]; then
    echo "⚠️  检测到 CUDA 12.4 (可能与某些包不兼容)"
    export PATH=/usr/local/cuda-12.4/bin:$PATH
    export LD_LIBRARY_PATH=/usr/local/cuda-12.4/lib64:$LD_LIBRARY_PATH
    CUDA_VERSION="12.4"
else
    echo "❌ 错误: 未检测到 CUDA 安装"
    echo "请先安装 CUDA 11.8 或 12.1"
    exit 1
fi

# 设置 Isaac Gym 库路径
echo "🔧 设置 Isaac Gym 库路径..."
if [ -d "/opt/isaacgym" ]; then
    export PYTHONPATH=/opt/isaacgym/python:$PYTHONPATH
    echo "✅ Isaac Gym 路径已设置: /opt/isaacgym"
else
    echo "⚠️  警告: Isaac Gym 未安装在 /opt/isaacgym"
    echo "请检查 Isaac Gym 安装路径"
fi

# 设置 conda 环境库路径
export LD_LIBRARY_PATH=~/anaconda3/envs/isaacgym/lib:$LD_LIBRARY_PATH

echo ""
echo "=========================================="
echo "环境设置完成！"
echo "=========================================="

# 显示当前环境信息
echo "📋 环境信息:"
echo "  Python 版本: $(python --version)"
echo "  CUDA 版本: $CUDA_VERSION"
echo "  conda 环境: $CONDA_DEFAULT_ENV"
echo "  CUDA 路径: $(which nvcc 2>/dev/null || echo '未找到')"
echo "  Isaac Gym: $(python -c 'import isaacgym; print("可用")' 2>/dev/null || echo '不可用')"

# 测试关键依赖
echo ""
echo "🧪 测试关键依赖..."

# 测试 PyTorch
if python -c "import torch; print(f'PyTorch: {torch.__version__}')" 2>/dev/null; then
    echo "✅ PyTorch: 可用"
    python -c "import torch; print(f'  - 版本: {torch.__version__}'); print(f'  - CUDA: {torch.version.cuda}'); print(f'  - CUDA 可用: {torch.cuda.is_available()}')" 2>/dev/null
else
    echo "❌ PyTorch: 不可用"
fi

# 测试 PyTorch3D
if python -c "from pytorch3d.renderer import look_at_view_transform; print('PyTorch3D: 可用')" 2>/dev/null; then
    echo "✅ PyTorch3D: 可用"
else
    echo "❌ PyTorch3D: 不可用"
fi

# 测试 Isaac Gym
if python -c "import isaacgym; print('Isaac Gym: 可用')" 2>/dev/null; then
    echo "✅ Isaac Gym: 可用"
else
    echo "❌ Isaac Gym: 不可用"
fi

echo ""
echo "=========================================="
echo "使用说明:"
echo "1. 每次使用前运行: source setup_env.sh"
echo "2. 安装 PKM: cd pkm && pip install -e ."
echo "3. 运行训练: cd pkm/scripts/train && python show_ppo_arm.py"
echo "=========================================="

# 提示用户保存环境变量
echo ""
echo "💡 提示: 要永久保存这些环境变量，请将以下内容添加到 ~/.bashrc:"
echo ""
echo "# CORN 项目环境变量"
echo "export PATH=/usr/local/cuda-$CUDA_VERSION/bin:\$PATH"
echo "export LD_LIBRARY_PATH=/usr/local/cuda-$CUDA_VERSION/lib64:\$LD_LIBRARY_PATH"
echo "export LD_LIBRARY_PATH=~/anaconda3/envs/isaacgym/lib:\$LD_LIBRARY_PATH"
echo "export PYTHONPATH=/opt/isaacgym/python:\$PYTHONPATH"
echo ""
