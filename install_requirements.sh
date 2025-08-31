#!/bin/bash

# CORN项目依赖包安装脚本
# 使用requirements.txt安装所有必需的依赖包

echo "🔧 开始安装CORN项目依赖包..."

# 检查是否在Isaac Gym环境中
if ! python -c "import isaacgym" 2>/dev/null; then
    echo "❌ 错误: 请先激活Isaac Gym环境"
    echo "运行: conda activate isaacgym"
    exit 1
fi

# 检查requirements.txt是否存在
if [ ! -f "requirements.txt" ]; then
    echo "❌ 错误: 找不到requirements.txt文件"
    exit 1
fi

echo "📦 从requirements.txt安装依赖包..."

# 安装基础依赖包
echo "   安装基础依赖包..."
pip install -r requirements.txt

# 特殊处理pytorch3d（需要兼容的CUDA版本）
echo ""
echo "🔧 特殊处理pytorch3d..."

# 检查PyTorch和CUDA版本
PYTORCH_VERSION=$(python -c "import torch; print(torch.__version__)" 2>/dev/null)
CUDA_VERSION=$(python -c "import torch; print(torch.version.cuda)" 2>/dev/null)

echo "   当前PyTorch版本: ${PYTORCH_VERSION}"
echo "   当前CUDA版本: ${CUDA_VERSION}"

# 根据版本选择合适的pytorch3d安装方式
if [[ "${PYTORCH_VERSION}" == "2.4"* ]] && [[ "${CUDA_VERSION}" == "12"* ]]; then
    echo "   检测到PyTorch 2.4 + CUDA 12.x，尝试安装兼容版本..."
    
    # 尝试从预编译wheel安装
    pip install pytorch3d --no-cache-dir --no-build-isolation --force-reinstall
    
elif [[ "${PYTORCH_VERSION}" == "2.0"* ]] && [[ "${CUDA_VERSION}" == "11"* ]]; then
    echo "   检测到PyTorch 2.0 + CUDA 11.x，尝试安装兼容版本..."
    
    # 尝试从预编译wheel安装
    pip install pytorch3d --no-cache-dir --no-build-isolation --force-reinstall
    
else
    echo "   尝试从源码编译安装pytorch3d..."
    pip install pytorch3d --no-cache-dir --no-build-isolation --force-reinstall
fi

echo ""
echo "🔍 验证关键依赖包..."

# 验证关键包
CRITICAL_DEPS=("torch" "torchvision" "omegaconf" "hydra-core" "einops" "icecream" "gymnasium")
for dep in "${CRITICAL_DEPS[@]}"; do
    if python -c "import $dep" 2>/dev/null; then
        echo "   ✅ $dep 可用"
    else
        echo "   ❌ $dep 不可用"
    fi
done

# 特殊验证pytorch3d
if python -c "import pytorch3d" 2>/dev/null; then
    echo "   ✅ pytorch3d 可用"
else
    echo "   ❌ pytorch3d 不可用"
    echo "   💡 提示: pytorch3d可能需要特殊的安装方式"
fi

echo ""
echo "🎉 依赖包安装完成！"
echo "💡 现在可以尝试运行CORN训练脚本了"
echo ""
echo "📋 如果遇到问题，建议："
echo "   1. 使用Docker容器运行"
echo "   2. 或者联系CORN项目维护者获取兼容的依赖版本"
