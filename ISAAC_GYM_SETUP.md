# Isaac Gym 安装和配置说明

## 概述
本文档说明如何在CORN项目中使用Isaac Gym进行机器人仿真和强化学习。

## 环境信息
- **Isaac Gym版本**: Preview 4
- **Python版本**: 3.8.20 (通过conda环境)
- **安装路径**: `/opt/isaacgym` (系统标准路径)
- **软链接**: `/home/boris/workspace/LLM_TAMP/3rdparty/corn/isaacgym` → `/opt/isaacgym`
- **Conda环境名**: `isaacgym`
- **DGN资产路径**: `/home/boris/workspace/LLM_TAMP/3rdparty/corn/data/DGN`

## 快速开始

### 1. 安装CORN项目依赖
```bash
# 使用本地安装脚本（推荐）
./setup_local.sh

# 或者手动安装
conda activate isaacgym
python3 -m pip install -e /opt/isaacgym/python
python3 -m pip install --no-build-isolation -e ./pkm
```

### 2. 配置DGN资产
```bash
# 解压DGN资产（如果还没有解压）
mkdir -p data/DGN
tar -xzf /path/to/DGN.tar.gz -C data/DGN

# 验证资产配置
./verify_dgn_assets.sh
```

### 3. 激活Isaac Gym环境
```bash
# 方法1: 使用激活脚本（推荐）
./activate_isaacgym.sh

# 方法2: 手动激活
conda activate isaacgym
```

### 4. 测试安装
```bash
python -c "import isaacgym; print('Isaac Gym安装成功！')"
```

### 3. 运行示例
```bash
cd isaacgym/python/examples
python joint_monkey.py
```

## 环境配置

### 环境变量
激活环境后，以下环境变量会自动设置：
- `PYTHONPATH`: 包含Isaac Gym Python包路径
- `LD_LIBRARY_PATH`: 包含Isaac Gym库文件路径

### Docker配置
在Docker中使用时：
- Isaac Gym会映射到容器内的`/opt/isaacgym`目录
- DGN资产会映射到容器内的`/input/DGN`目录
- 数据路径配置：`DATA_PATH="/home/boris/workspace/LLM_TAMP/3rdparty/corn/data/"`

## 目录结构

### Isaac Gym
```
isaacgym/
├── python/                 # Python包和示例
│   ├── isaacgym/          # 主要Python模块
│   ├── examples/          # 示例代码
│   └── setup.py           # 安装脚本
├── assets/                # 3D模型和资源
├── docs/                  # 文档
└── licenses/              # 许可证文件
```

### DGN资产
```
data/DGN/
├── coacd/                 # 碰撞检测数据
├── meta-v8/               # 元数据版本8
│   ├── cloud/             # 点云数据
│   ├── cloud-2048/        # 2048点采样点云
│   ├── urdf/              # URDF模型文件
│   ├── pose/              # 姿态数据
│   ├── normal/            # 法向量数据
│   └── metadata.json      # 元数据文件
└── yes.json               # 验证文件
```

## 故障排除

### 常见问题
1. **Python版本不兼容**: 确保使用Python 3.6-3.9
2. **CUDA版本问题**: 检查NVIDIA驱动和CUDA版本
3. **权限问题**: 确保有足够的权限访问GPU设备

### 重新安装
如果需要重新安装：
```bash
conda activate isaacgym
cd isaacgym/python
pip uninstall isaacgym
pip install -e .
```

## 相关链接
- [Isaac Gym官方文档](https://developer.nvidia.com/isaac-gym)
- [CORN项目文档](https://github.com/iMSquared/corn)
- [NVIDIA Isaac平台](https://developer.nvidia.com/isaac)
