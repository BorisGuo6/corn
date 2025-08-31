# CORN项目依赖包安装指南

## 📋 **文件说明**

### **requirements.txt**
- 完整的依赖包列表，包含所有可能需要的包
- 适用于新环境或完整安装

### **requirements_simple.txt**
- 简化版本，只包含核心依赖包
- 适用于当前环境或快速安装

### **install_requirements.sh**
- 自动安装脚本，会智能处理pytorch3d等特殊依赖

## 🚀 **安装方法**

### **方法1：使用安装脚本（推荐）**
```bash
cd /home/boris/workspace/LLM_TAMP/3rdparty/corn
chmod +x install_requirements.sh
./install_requirements.sh
```

### **方法2：手动安装简化版本**
```bash
cd /home/boris/workspace/LLM_TAMP/3rdparty/corn
pip install -r requirements_simple.txt
```

### **方法3：手动安装完整版本**
```bash
cd /home/boris/workspace/LLM_TAMP/3rdparty/corn
pip install -r requirements.txt
```

## ⚠️ **注意事项**

### **pytorch3d兼容性问题**
- pytorch3d与CUDA版本有严格的兼容性要求
- 当前环境：PyTorch 2.4.1 + CUDA 12.x
- pytorch3d 0.3.0需要CUDA 10.1，不兼容

### **解决方案优先级**
1. **Docker容器** - 最可靠，环境完全兼容
2. **降级PyTorch** - 安装PyTorch 1.13 + CUDA 11.6
3. **从源码编译** - 复杂但可能成功

## 🔧 **环境检查**

### **检查当前环境**
```bash
# 检查Python版本
python --version

# 检查PyTorch版本
python -c "import torch; print(torch.__version__)"

# 检查CUDA版本
python -c "import torch; print(torch.version.cuda)"

# 检查Isaac Gym
python -c "import isaacgym; print('Isaac Gym可用')"
```

### **检查关键依赖**
```bash
# 检查核心包
python -c "import einops, omegaconf, icecream, hydra_core, gymnasium; print('核心依赖可用')"

# 检查3D包
python -c "import trimesh, yourdfpy; print('3D依赖可用')"

# 检查pytorch3d
python -c "import pytorch3d; print('pytorch3d可用')"
```

## 🐳 **Docker方案（推荐）**

如果依赖包安装遇到问题，建议使用Docker：

```bash
cd /home/boris/workspace/LLM_TAMP/3rdparty/corn/docker
./run.sh

# 在容器内运行训练
cd /home/user/corn/pkm/scripts/train
PYTORCH_JIT=0 python3 show_ppo_arm.py +platform=debug +env=icra_base +run=icra_ours ++env.seed=56081 ++tag=policy ++global_device=cuda:0 ++path.root=/tmp/pkm/ppo-a ++icp_obs.icp.ckpt=imm-unicorn/corn-public:512-32-balanced-SAM-wd-5e-05-920 ++load_ckpt=imm-unicorn/corn-public:dr-icra_base-icra_ours-ours-final-000042 ++env.num_env=16 ++env.use_viewer=0 ++draw_debug_lines=0
```

## 📞 **获取帮助**

如果遇到问题：
1. 检查错误信息中的具体依赖包
2. 尝试使用Docker方案
3. 联系CORN项目维护者
4. 查看项目文档和Issues
