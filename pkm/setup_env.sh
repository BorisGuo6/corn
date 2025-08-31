#!/bin/bash

# PKM 环境设置脚本
echo "设置 PKM 环境..."

# 激活 conda 环境
source ~/anaconda3/etc/profile.d/conda.sh
conda activate isaacgym

# 设置 CUDA 11.8 环境
export PATH=/usr/local/cuda-11.8/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda-11.8/lib64:$LD_LIBRARY_PATH

# 设置 Isaac Gym 库路径
export LD_LIBRARY_PATH=~/anaconda3/envs/isaacgym/lib:$LD_LIBRARY_PATH

# 设置 Isaac Gym Python 路径
export PYTHONPATH=/opt/isaacgym/python:$PYTHONPATH

echo "环境设置完成！"
echo "当前 Python 版本: $(python --version)"
echo "当前 PyTorch 版本: $(python -c 'import torch; print(torch.__version__)')"
echo "CUDA 可用: $(python -c 'import torch; print(torch.cuda.is_available())')"
echo "Isaac Gym 可用: $(python -c 'import isaacgym; print("是")' 2>/dev/null || echo "否")"
echo "PyTorch3D 可用: $(python -c 'from pytorch3d.renderer import look_at_view_transform; print("是")' 2>/dev/null || echo "否")"
