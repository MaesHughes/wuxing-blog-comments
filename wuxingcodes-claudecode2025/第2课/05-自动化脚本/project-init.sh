#!/bin/bash

# ClaudeCode项目自动化初始化脚本
# 作者：大熊掌门
# 使用方法：./project-init.sh [项目名称] [项目类型]

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

print_success() {
    print_message $GREEN "✅ $1"
}

print_error() {
    print_message $RED "❌ $1"
}

print_warning() {
    print_message $YELLOW "⚠️  $1"
}

print_info() {
    print_message $BLUE "ℹ️  $1"
}

# 检查参数
if [ $# -eq 0 ]; then
    print_error "请提供项目名称"
    echo "使用方法: $0 <项目名称> [项目类型]"
    echo "项目类型选项: web, mobile, api, library"
    exit 1
fi

PROJECT_NAME=$1
PROJECT_TYPE=${2:-web}

print_info "开始初始化项目: $PROJECT_NAME (类型: $PROJECT_TYPE)"

# 检查ClaudeCode是否安装
if ! command -v claude &> /dev/null; then
    print_error "ClaudeCode未安装，请先安装ClaudeCode"
    echo "安装命令: npm install -g @anthropic/claude-code"
    exit 1
fi

# 创建项目目录
print_info "创建项目目录..."
mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME"

# 初始化Git仓库
print_info "初始化Git仓库..."
git init

# 创建标准目录结构
print_info "创建项目目录结构..."
mkdir -p {src,tests,docs,config,scripts,public}
mkdir -p src/{components,pages,utils,hooks,services,types}

# 根据项目类型创建特定结构
case $PROJECT_TYPE in
    "web")
        mkdir -p src/{styles,assets,store}
        mkdir -p public/{images,fonts,icons}
        ;;
    "mobile")
        mkdir -p src/{navigation,screens,constants}
        ;;
    "api")
        mkdir -p src/{controllers,models,middleware,routes,validators}
        ;;
    "library")
        mkdir -p src/{lib,examples,benchmarks}
        ;;
esac

# 创建基础配置文件
print_info "创建基础配置文件..."

# package.json
cat > package.json << EOF
{
  "name": "$PROJECT_NAME",
  "version": "1.0.0",
  "description": "项目描述",
  "main": "src/index.js",
  "scripts": {
    "dev": "开发服务器启动命令",
    "build": "构建命令",
    "test": "测试命令",
    "lint": "代码检查",
    "format": "代码格式化",
    "clean": "清理构建文件"
  },
  "keywords": [],
  "author": "",
  "license": "MIT",
  "devDependencies": {
    "@anthropic/claude-code": "latest"
  }
}
EOF

# .gitignore
cat > .gitignore << EOF
# Dependencies
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Production builds
dist/
build/
out/

# Environment variables
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Logs
logs/
*.log

# Runtime data
pids/
*.pid
*.seed
*.pid.lock

# Coverage directory used by tools like istanbul
coverage/

# ClaudeCode
.claude/
.claudeignore

# Database
*.db
*.sqlite
*.sqlite3

# Cache
.cache/
.parcel-cache/

# Temporary files
tmp/
temp/
EOF

# .claudeignore
cat > .claudeignore << EOF
# 忽略大型依赖目录
node_modules/
dist/
build/
coverage/

# 忽略日志文件
*.log
logs/

# 忽略临时文件
tmp/
temp/
.cache/

# 忽略敏感文件
.env
.env.*
*.key
*.pem

# 忽略大型媒体文件
*.mp4
*.avi
*.mov
*.psd
*.ai

# 忽略生成的文档
docs/build/
EOF

# 复制CLAUDE.md模板
print_info "复制ClaudeCode项目配置模板..."
if [ -f "../CLAUDE.md.template" ]; then
    cp ../CLAUDE.md.template CLAUDE.md
    # 替换占位符
    sed -i "s/\[你的项目名称\]/$PROJECT_NAME/g" CLAUDE.md
    sed -i "s/\[项目名称\]/$PROJECT_NAME/g" CLAUDE.md
    sed -i "s/\[项目类型\]/$PROJECT_TYPE项目/g" CLAUDE.md
    sed -i "s/\[主要技术和框架\]/待配置/g" CLAUDE.md
    sed -i "s/\[团队人数和角色\]/待配置/g" CLAUDE.md
    print_success "CLAUDE.md配置文件已创建"
else
    print_warning "未找到CLAUDE.md模板，将创建基础配置文件"
    cat > CLAUDE.md << EOF
# $PROJECT_NAME

## 项目概述
- **项目名称**: $PROJECT_NAME
- **项目类型**: $PROJECT_TYPE
- **技术栈**: 待配置

## 快速开始
1. 安装依赖: \`npm install\`
2. 启动开发: \`npm run dev\`
3. 运行测试: \`npm test\`

## 项目结构
- \`src/\`: 源代码
- \`tests/\`: 测试文件
- \`docs/\`: 项目文档
- \`config/\`: 配置文件
EOF
fi

# 创建README.md
print_info "创建README.md..."
cat > README.md << EOF
# $PROJECT_NAME

项目描述待添加

## 快速开始

### 环境要求
- Node.js >= 16
- ClaudeCode CLI

### 安装和运行
\`\`\`bash
# 克隆项目
git clone [仓库地址]
cd $PROJECT_NAME

# 安装依赖
npm install

# 启动开发服务器
npm run dev
\`\`\`

## 项目结构
- \`src/\`: 源代码
- \`tests/\`: 测试文件
- \`docs/\`: 项目文档
- \`config/\`: 配置文件

## 脚本命令
- \`npm run dev\`: 启动开发服务器
- \`npm run build\`: 构建生产版本
- \`npm test\`: 运行测试
- \`npm run lint\`: 代码检查
- \`npm run format\`: 代码格式化

## 贡献指南
1. Fork项目
2. 创建功能分支 (\`git checkout -b feature/AmazingFeature\`)
3. 提交更改 (\`git commit -m 'Add some AmazingFeature'\`)
4. 推送到分支 (\`git push origin feature/AmazingFeature\`)
5. 打开Pull Request

## 许可证
本项目采用MIT许可证 - 查看 [LICENSE](LICENSE) 文件了解详情

## 作者
- **作者姓名** - *初始工作* - [AuthorProfile]

## 致谢
- [ClaudeCode](https://claude.ai) - AI编程助手
- [项目链接](https://github.com/yourusername/$PROJECT_NAME)
EOF

# 初始化ClaudeCode项目
print_info "初始化ClaudeCode项目..."
if claude init &> /dev/null; then
    print_success "ClaudeCode项目初始化成功"
else
    print_warning "ClaudeCode项目初始化失败，请手动运行 'claude init'"
fi

# 添加基本的源代码文件
print_info "创建基础源代码文件..."

# 创建主入口文件
case $PROJECT_TYPE in
    "web")
        cat > src/index.js << EOF
// 主入口文件
console.log('$PROJECT_NAME 应用启动');

// 应用初始化代码将在这里添加
EOF
        ;;
    "api")
        cat > src/index.js << EOF
// API服务器入口文件
const express = require('express');

const app = express();
const PORT = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.json({ message: '$PROJECT_NAME API服务运行中' });
});

app.listen(PORT, () => {
  console.log(\`服务器运行在端口 \${PORT}\`);
});
EOF
        ;;
    *)
        cat > src/index.js << EOF
// 主入口文件
console.log('$PROJECT_NAME 项目启动');

// 初始化代码将在这里添加
EOF
        ;;
esac

# 创建测试文件
cat > tests/index.test.js << EOF
// 基础测试文件
describe('$PROJECT_NAME', () => {
  test('项目初始化测试', () => {
    expect(true).toBe(true);
  });
});
EOF

# 初始Git提交
print_info "进行初始Git提交..."
git add .
git commit -m "feat: 初始化$PROJECT_NAME项目

- 创建项目基础结构
- 添加配置文件
- 设置ClaudeCode集成
- 创建基础文档"

print_success "项目初始化完成！"
print_info "下一步操作："
echo "1. 进入项目目录: cd $PROJECT_NAME"
echo "2. 安装依赖: npm install"
echo "3. 配置项目参数: 编辑CLAUDE.md和package.json"
echo "4. 启动开发: npm run dev"
echo "5. 使用ClaudeCode: claude \"开始开发\""

print_info "ClaudeCode常用命令："
echo "- claude \"项目结构优化建议\""
echo "- claude \"添加测试用例\""
echo "- claude \"代码审查和优化\""
echo "- /add-dir src  # 添加源码目录到上下文"
echo "- /context      # 查看上下文使用情况"

print_success "项目 $PROJECT_NAME 初始化完成，开始你的AI辅助编程之旅吧！"