# CORN 项目安装指南

## 概述

CORN (Comprehensive Object Recognition and Navigation) 是一个基于 Isaac Gym 的机器人强化学习项目。本文档总结了在 Linux 系统上安装 CORN 及其依赖的完整流程，基于实际安装经验。

## 系统要求

- **操作系统**: Ubuntu 20.04+ (推荐)
- **Python**: 3.8.x (必须，Isaac Gym 限制)
- **CUDA**: 11.8 (推荐) 或 12.1
- **GPU**: NVIDIA GPU with CUDA support
- **内存**: 至少 16GB RAM

## 快速安装

### 1. 环境准备

```bash
# 创建 Python 3.8 环境
conda create -n isaacgym python=3.8 -y
conda activate isaacgym

# 验证 Python 版本
python --version  # 应该显示 Python 3.8.x
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

### 3. 安装 PyTorch (关键步骤)

**⚠️ 重要**: 必须使用指定版本，避免兼容性问题

```bash
# 卸载可能存在的旧版本
pip uninstall torch torchvision -y
conda remove pytorch-cuda -y  # 清理 conda 环境

# 安装指定版本 (根据你的 CUDA 版本选择)
# 对于 CUDA 11.8
pip install torch==2.0.1 torchvision==0.15.2 --index-url https://download.pytorch.org/whl/cu118

# 对于 CUDA 12.1
pip install torch==2.0.1 torchvision==0.15.2 --index-url https://download.pytorch.org/whl/cu121

# 验证安装
python -c "import torch; print(f'PyTorch: {torch.__version__}'); print(f'CUDA: {torch.version.cuda}')"
```

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

### 5. 安装其他依赖

```bash
cd ~/workspace/LLM_TAMP/3rdparty/corn
pip install -r requirements.txt
```

### 6. 安装 PKM

```bash
cd pkm
pip install -e .
```

## 环境变量设置

创建 `setup_env.sh` 脚本:

```bash
#!/bin/bash
# CORN 环境设置脚本

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

## 版本兼容性

### 推荐组合

| 组件 | 版本 | 备注 |
|------|------|------|
| Python | 3.8.x | Isaac Gym 限制 |
| PyTorch | 2.0.1 | 避免 2.4.x 版本 |
| CUDA | 11.8 或 12.1 | 与 PyTorch 版本匹配 |
| PyTorch3D | 0.7.4 | 与 PyTorch 2.0.1 兼容 |
| Isaac Gym | Preview 4 | 官方版本 |

### 不兼容组合

| 组件 | 版本 | 问题 |
|------|------|------|
| PyTorch | 2.4.1 | CUDA 扩展编译失败 |
| Python | 3.9+ | Isaac Gym 不支持 |
| CUDA | 12.4 | 与预编译包不兼容 |

## 常见问题解决

### 问题 1: CUDA 版本不匹配

**错误**: `CUDA version mismatch` 或 `undefined symbol`

**解决方案**:
```bash
# 1. 卸载所有 PyTorch 相关包
pip uninstall torch torchvision -y
conda remove pytorch-cuda -y

# 2. 重新安装指定版本
pip install torch==2.0.1 torchvision==0.15.2 --index-url https://download.pytorch.org/whl/cu118
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

### 问题 4: PKM 编译失败

**错误**: `RuntimeError: CUDA version mismatch`

**解决方案**:
1. 确保 PyTorch 和系统 CUDA 版本一致
2. 清理并重新编译扩展
3. 检查环境变量设置

## 验证安装

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

## 运行示例

```bash
# 设置环境
source setup_env.sh

# 运行训练脚本
cd pkm/scripts/train
python show_ppo_arm.py +platform=debug +env=icra_base +run=icra_ours
```

## 注意事项

1. **Python 版本**: 严格使用 Python 3.8，Isaac Gym 不支持更高版本
2. **CUDA 版本**: 确保 PyTorch、PyTorch3D 和系统 CUDA 版本一致
3. **环境隔离**: 使用独立的 conda 环境，避免包冲突
4. **路径设置**: 正确设置所有环境变量和库路径
5. **预编译包**: 优先使用预编译包，避免编译问题

## 故障排除

如果遇到问题，请按以下顺序检查：

1. **环境检查**: Python 版本、CUDA 版本、conda 环境
2. **包版本**: PyTorch、PyTorch3D 版本兼容性
3. **环境变量**: CUDA 路径、库路径、Python 路径
4. **系统依赖**: 编译器、库文件、权限设置

## 技术支持

- **项目仓库**: [CORN GitHub](https://github.com/your-repo/corn)
- **问题报告**: 创建 GitHub Issue
- **讨论**: 使用 GitHub Discussions

---

**最后更新**: 2024年8月31日  
**测试环境**: Ubuntu 20.04, Python 3.8, CUDA 11.8, PyTorch 2.0.1  
**维护者**: CORN 开发团队
