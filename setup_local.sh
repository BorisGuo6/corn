#!/usr/bin/env bash

# CORN项目本地安装脚本
# 适用于已安装Isaac Gym到/opt/isaacgym的情况

set -e  # 遇到错误时退出

echo "🚀 开始安装CORN项目依赖..."

# 获取当前脚本所在目录
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT="$(git -C "${SCRIPT_DIR}" rev-parse --show-toplevel)"

echo "📁 项目根目录: ${REPO_ROOT}"

# 检查Isaac Gym是否已安装
if [ ! -d "/opt/isaacgym" ]; then
    echo "❌ 错误: Isaac Gym未安装在/opt/isaacgym"
    echo "请先安装Isaac Gym到/opt/isaacgym目录"
    exit 1
fi

echo "✅ Isaac Gym已安装在/opt/isaacgym"

# 安装Isaac Gym Python包
echo "📦 安装Isaac Gym Python包..."
python3 -m pip install -e /opt/isaacgym/python

# 安装Eigen库
echo "📚 安装Eigen库..."
cd /tmp
if [ ! -d "eigen-3.4.0" ]; then
    wget https://gitlab.com/libeigen/eigen/-/archive/3.4.0/eigen-3.4.0.zip
    unzip eigen-3.4.0.zip
    rm -f eigen-3.4.0.zip
fi
cd "${REPO_ROOT}"

# 安装其他依赖
echo "🔧 安装其他依赖包..."
python3 -m pip install 'pyglet<2'

# 安装PKM包
echo "📦 安装PKM包..."
python3 -m pip install --no-build-isolation -e "${REPO_ROOT}/pkm"

# 配置git安全目录
echo "⚙️ 配置git安全目录..."
git config --global --add safe.directory "${REPO_ROOT}"

echo "🎉 CORN项目安装完成！"
echo ""
echo "📋 安装摘要:"
echo "   - Isaac Gym: /opt/isaacgym"
echo "   - PKM包: ${REPO_ROOT}/pkm"
echo "   - 项目根目录: ${REPO_ROOT}"
echo ""
echo "🚀 现在可以运行CORN项目了！"
echo "💡 提示: 使用 './activate_isaacgym.sh' 来激活Isaac Gym环境"
