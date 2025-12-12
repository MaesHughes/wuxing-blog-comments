#!/bin/bash

# 项目名称
PROJECT_NAME=$1

if [ -z "$PROJECT_NAME" ]; then
    echo "用法: ./init-project.sh <项目名称>"
    exit 1
fi

echo "创建项目: $PROJECT_NAME"

# 创建项目目录
mkdir $PROJECT_NAME
cd $PROJECT_NAME

# 创建基础文件结构
mkdir -p src tests docs

# 创建README.md
cat > README.md << EOF
# $PROJECT_NAME

## 项目描述

这是一个使用ClaudeCode创建的项目。

## 开发环境

- Node.js 18+
- ClaudeCode

## 快速开始

\`\`\`bash
# 安装依赖
npm install

# 启动开发
npm start
\`\`\`
EOF

# 创建CLAUDE.md
cat > CLAUDE.md << EOF
# Claude助手配置

你是一个专业的编程助手，专门帮助开发这个项目。

## 项目信息
- 项目名称：$PROJECT_NAME
- 技术栈：根据项目需要确定
- 编码规范：使用ESLint和Prettier

## 注意事项
- 所有代码都要有适当的注释
- 遵循最佳实践
- 确保代码可读性和可维护性
EOF

# 初始化Git仓库
git init

# 创建.gitignore
cat > .gitignore << EOF
# Dependencies
node_modules/

# Build outputs
dist/
build/

# Environment files
.env
.env.local
.env.*.local

# IDE
.vscode/
.idea/

# OS
.DS_Store
Thumbs.db

# Logs
*.log
npm-debug.log*
EOF

# 使用Claude初始化项目
if command -v claude &> /dev/null; then
    echo "使用Claude初始化项目..."
    claude init
    echo "项目初始化完成！"
else
    echo "警告：ClaudeCode未安装，请先安装ClaudeCode"
fi

echo ""
echo "项目 '$PROJECT_NAME' 创建完成！"
echo "目录结构："
# 使用ls代替tree，因为tree可能未安装
ls -la