#!/bin/bash

# 激活Isaac Gym conda环境的脚本
echo "正在激活Isaac Gym环境..."

# 激活conda环境
source /home/boris/anaconda3/etc/profile.d/conda.sh
conda activate isaacgym

# 设置环境变量
export PYTHONPATH="/opt/isaacgym/python:${PYTHONPATH}"
export LD_LIBRARY_PATH="/opt/isaacgym/python/isaacgym/_bindings/linux-x86_64:${LD_LIBRARY_PATH}"

echo "Isaac Gym环境已激活！"
echo "Python版本: $(python --version)"
echo "Python路径: $(which python)"
echo "Isaac Gym路径: /home/boris/workspace/LLM_TAMP/3rdparty/corn/isaacgym"

# 测试Isaac Gym导入
python -c "import isaacgym; print('Isaac Gym导入成功！')" 2>/dev/null && echo "✅ Isaac Gym测试通过" || echo "❌ Isaac Gym测试失败"
