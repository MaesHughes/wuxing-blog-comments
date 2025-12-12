#!/bin/bash

echo "配置npm使用国内镜像..."

# 设置淘宝镜像
npm config set registry https://registry.npmmirror.com

echo "已设置为淘宝镜像"

# 验证镜像设置
npm config get registry

echo ""
echo "安装完成后，可以使用以下命令恢复官方源："
echo "npm config set registry https://registry.npmjs.org"