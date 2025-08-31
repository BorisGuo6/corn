# PKM 安装指南

## 概述

PKM (Physical Knowledge Model) 是一个基于 Isaac Gym 的机器人强化学习框架。本文档总结了在 Linux 系统上安装 PKM 及其依赖的完整流程。

## 系统要求

- **操作系统**: Ubuntu 20.04+ (推荐)
- **Python**: 3.8.x (必须，Isaac Gym 限制)
- **CUDA**: 11.8 (推荐) 或 12.1
- **GPU**: NVIDIA GPU with CUDA support
- **内存**: 至少 16GB RAM

## 环境准备

### 1. 创建 Conda 环境

```bash
# 创建 Python 3.8 环境
conda create -n isaacgym python=3.8 -y
conda activate isaacgym
```

### 2. 安装 Isaac Gym

```bash
# 下载 Isaac Gym (需要 NVIDIA 开发者账号)
# 下载地址: https://developer.nvidia.com/isaac-gym

# 解压到 /opt/isaacgym
sudo mkdir -p /opt
sudo cp -r ~/Downloads/IsaacGym_Preview_4_Package /opt/isaacgym

# 安装 Python 包
cd /opt/isaacgym/python
pip install -e .
```

## 关键依赖安装

### 3. 安装 PyTorch (重要!)

**⚠️ 关键点**: 必须安装与 CUDA 版本兼容的 PyTorch

```bash
# 对于 CUDA 11.8
pip install torch==2.0.1 torchvision==0.15.2 --index-url https://download.pytorch.org/whl/cu118

# 对于 CUDA 12.1
pip install torch==2.0.1 torchvision==0.15.2 --index-url https://download.pytorch.org/whl/cu121

# 验证安装
python -c "import torch; print(f'PyTorch: {torch.__version__}'); print(f'CUDA: {torch.version.cuda}')"
```

**常见问题**: 
- 不要使用 conda 安装 PyTorch，避免版本冲突
- 确保 `pytorch-cuda` 包版本与系统 CUDA 版本一致

### 4. 安装 PyTorch3D

```bash
# 方法1: 预编译包 (推荐)
pip install --no-index --no-cache-dir pytorch3d -f https://dl.fbaipublicfiles.com/pytorch3d/packaging/wheels/py38_cu118_pyt201/download.html

# 方法2: 从源码编译 (如果预编译包不兼容)
cd ~/workspace/LLM_TAMP/3rdparty/pytorch3d
export FORCE_CUDA=1
export CUDA_HOME=/usr/local/cuda-11.8  # 或 /usr/local/cuda-12.1
pip install -e .
```

**版本兼容性表**:
| PyTorch | CUDA | PyTorch3D | 备注 |
|---------|------|-----------|------|
| 2.0.1 | 11.8 | 0.7.4 | ✅ 推荐组合 |
| 2.0.1 | 12.1 | 0.7.4 | ✅ 可用 |
| 2.4.1 | 12.1 | 0.7.4 | ❌ 不兼容 |

### 5. 环境变量设置

创建 `setup_env.sh` 脚本:

```bash
#!/bin/bash
# PKM 环境设置脚本

# 激活 conda 环境
source ~/anaconda3/etc/profile.d/conda.sh
conda activate isaacgym

# 设置 CUDA 环境 (根据你的 CUDA 版本选择)
export PATH=/usr/local/cuda-11.8/bin:$PATH  # 或 cuda-12.1
export LD_LIBRARY_PATH=/usr/local/cuda-11.8/lib64:$LD_LIBRARY_PATH

# 设置 Isaac Gym 库路径
export LD_LIBRARY_PATH=~/anaconda3/envs/isaacgym/lib:$LD_LIBRARY_PATH
export PYTHONPATH=/opt/isaacgym/python:$PYTHONPATH

echo "环境设置完成！"
```

## 安装 PKM

### 6. 安装 PKM 包

```bash
cd ~/workspace/LLM_TAMP/3rdparty/corn/pkm

# 设置环境变量
source setup_env.sh

# 安装 PKM
pip install -e .
```

## 验证安装

### 7. 测试所有依赖

```bash
# 测试 Isaac Gym
python -c "import isaacgym; print('Isaac Gym: ✅')"

# 测试 PyTorch
python -c "import torch; print(f'PyTorch: ✅ {torch.__version__}')"

# 测试 PyTorch3D
python -c "from pytorch3d.renderer import look_at_view_transform; print('PyTorch3D: ✅')"

# 测试 PKM
python -c "import pkm; print('PKM: ✅')"
```

## 常见问题解决

### 问题 1: CUDA 版本不匹配

**错误**: `CUDA version mismatch` 或 `undefined symbol`

**解决方案**:
1. 卸载所有 PyTorch 相关包
2. 重新安装指定版本的 PyTorch
3. 清理 conda 环境中的 `pytorch-cuda` 包

```bash
pip uninstall torch torchvision -y
conda remove pytorch-cuda -y
# 重新安装指定版本
```

### 问题 2: Isaac Gym 导入失败

**错误**: `libpython3.8.so.1.0: cannot open shared object file`

**解决方案**:
```bash
export LD_LIBRARY_PATH=~/anaconda3/envs/isaacgym/lib:$LD_LIBRARY_PATH
```

### 问题 3: PyTorch3D 库依赖问题

**错误**: `libcudart.so.11.0: cannot open shared object file`

**解决方案**:
1. 确保使用正确的 CUDA 版本
2. 使用预编译的 PyTorch3D 包
3. 设置正确的 `LD_LIBRARY_PATH`

## 运行示例

```bash
# 设置环境
source setup_env.sh

# 运行训练脚本
cd scripts/train
python show_ppo_arm.py +platform=debug +env=icra_base +run=icra_ours
```

## 注意事项

1. **Python 版本**: 严格使用 Python 3.8，Isaac Gym 不支持更高版本
2. **CUDA 版本**: 确保 PyTorch、PyTorch3D 和系统 CUDA 版本一致
3. **环境隔离**: 使用独立的 conda 环境，避免包冲突
4. **路径设置**: 正确设置所有环境变量和库路径

## 技术支持

如果遇到问题，请检查：
1. CUDA 和 PyTorch 版本兼容性
2. 环境变量设置
3. 库路径配置
4. 系统依赖是否完整

---

**最后更新**: 2024年8月31日
**测试环境**: Ubuntu 20.04, Python 3.8, CUDA 11.8, PyTorch 2.0.1
