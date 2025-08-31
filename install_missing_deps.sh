#!/bin/bash

# CORN项目缺失依赖包安装脚本
# 安装训练和运行所需的所有依赖包

echo "🔧 安装CORN项目缺失的依赖包..."

# 检查是否在Isaac Gym环境中
if ! python -c "import isaacgym" 2>/dev/null; then
    echo "❌ 错误: 请先激活Isaac Gym环境"
    echo "运行: conda activate isaacgym"
    exit 1
fi

# 常见缺失的依赖包列表
MISSING_DEPS=(
    "einops"           # 张量操作库
    "omegaconf"        # 配置管理
    "icecream"         # 调试工具
    "hydra-core"       # 配置框架
    "wandb"            # 实验跟踪
    "tensorboard"      # 训练监控
    "tqdm"             # 进度条
    "matplotlib"       # 绘图
    "seaborn"          # 统计绘图
    "pandas"           # 数据处理
    "scikit-learn"     # 机器学习工具
    "opencv-python"    # 计算机视觉
    "pillow"           # 图像处理
    "imageio"          # 图像I/O
    "trimesh"          # 3D网格处理
    "pyrender"         # 3D渲染
    "pyglet"           # OpenGL绑定
    "gymnasium"        # 强化学习环境
    "stable-baselines3" # 强化学习算法
    "ray[rllib]"       # 分布式强化学习
)

echo "📦 开始安装依赖包..."

# 安装每个依赖包
for dep in "${MISSING_DEPS[@]}"; do
    echo "   安装: $dep"
    if pip install "$dep" >/dev/null 2>&1; then
        echo "   ✅ $dep 安装成功"
    else
        echo "   ❌ $dep 安装失败"
    fi
done

echo ""
echo "🔍 验证关键依赖包..."

# 验证关键包
CRITICAL_DEPS=("einops" "omegaconf" "icecream" "hydra-core")
for dep in "${CRITICAL_DEPS[@]}"; do
    if python -c "import $dep" 2>/dev/null; then
        echo "   ✅ $dep 可用"
    else
        echo "   ❌ $dep 不可用"
    fi
done

echo ""
echo "🎉 依赖包安装完成！"
echo "💡 现在可以尝试运行CORN训练脚本了"
