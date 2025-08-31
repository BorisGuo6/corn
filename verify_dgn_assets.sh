#!/bin/bash

# DGN资产验证脚本
# 验证CORN项目所需的DGN资产是否正确解压和配置

echo "🔍 验证DGN资产配置..."

# 检查数据目录
DATA_DIR="/home/boris/workspace/LLM_TAMP/3rdparty/corn/data"
DGN_DIR="${DATA_DIR}/DGN"

if [ ! -d "${DGN_DIR}" ]; then
    echo "❌ 错误: DGN目录不存在: ${DGN_DIR}"
    exit 1
fi

echo "✅ DGN目录存在: ${DGN_DIR}"

# 检查关键子目录
REQUIRED_DIRS=("coacd" "meta-v8" "meta-v8/cloud" "meta-v8/urdf" "meta-v8/pose")

for dir in "${REQUIRED_DIRS[@]}"; do
    if [ -d "${DGN_DIR}/${dir}" ]; then
        echo "✅ 目录存在: ${dir}"
    else
        echo "❌ 目录缺失: ${dir}"
        MISSING_DIRS=true
    fi
done

# 检查文件数量
echo ""
echo "📊 资产统计信息:"

# 统计各个目录的文件数量
for dir in "${REQUIRED_DIRS[@]}"; do
    if [ -d "${DGN_DIR}/${dir}" ]; then
        file_count=$(find "${DGN_DIR}/${dir}" -type f | wc -l)
        echo "   ${dir}: ${file_count} 个文件"
    fi
done

# 检查总文件数
total_files=$(find "${DGN_DIR}" -type f | wc -l)
echo "   总计: ${total_files} 个文件"

# 检查Docker配置
echo ""
echo "🐳 检查Docker配置..."

# 读取Docker run.sh中的DATA_PATH
DOCKER_DATA_PATH=$(grep "^DATA_PATH=" docker/run.sh | cut -d'"' -f2)

if [ "${DOCKER_DATA_PATH}" = "/home/boris/workspace/LLM_TAMP/3rdparty/corn/data/" ]; then
    echo "✅ Docker DATA_PATH配置正确: ${DOCKER_DATA_PATH}"
else
    echo "❌ Docker DATA_PATH配置不正确: ${DOCKER_DATA_PATH}"
    echo "   期望: /home/boris/workspace/LLM_TAMP/3rdparty/corn/data/"
fi

# 检查Docker映射
echo ""
echo "📋 Docker映射配置:"
echo "   主机路径: ${DOCKER_DATA_PATH}"
echo "   容器路径: /input"
echo "   DGN资产: ${DOCKER_DATA_PATH}DGN → /input/DGN"

echo ""
if [ "${MISSING_DIRS}" = true ]; then
    echo "⚠️  警告: 部分必需目录缺失，请检查DGN.tar.gz是否完整"
    exit 1
else
    echo "🎉 DGN资产验证通过！CORN项目现在可以使用这些资产了。"
fi
