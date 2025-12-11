#!/bin/bash
# ClaudeCode 项目初始化脚本
# 使用方法：./project-init.sh [项目类型] [项目名称]

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_message() {
    echo -e "${2}${1}${NC}"
}

# 显示帮助
show_help() {
    echo "ClaudeCode 项目初始化工具"
    echo ""
    echo "用法: $0 [项目类型] [项目名称]"
    echo ""
    echo "项目类型："
    echo "  react      React + TypeScript 项目"
    echo "  vue        Vue 3 + TypeScript 项目"
    echo "  node       Node.js + Express API 项目"
    echo "  python     Django/FastAPI 项目"
    echo "  go         Gin/Echo Go 项目"
    echo "  generic    通用项目模板"
    echo ""
    echo "示例："
    echo "  $0 react my-react-app"
    echo "  $0 node my-api"
    echo "  $0 python --help  # 查看Python选项"
}

# 检查必要工具
check_tools() {
    print_message "检查必要工具..." $BLUE

    # 检查Node.js
    if command -v node >/dev/null 2>&1; then
        NODE_VERSION=$(node --version)
        print_message "✓ Node.js: $NODE_VERSION" $GREEN
    else
        print_message "✗ Node.js 未安装" $RED
        echo "请从 https://nodejs.org 下载安装"
        exit 1
    fi

    # 检查npm/yarn/pnpm
    if command -v npm >/dev/null 2>&1; then
        NPM_VERSION=$(npm --version)
        print_message "✓ npm: $NPM_VERSION" $GREEN
        PKG_MANAGER="npm"
    elif command -v yarn >/dev/null 2>&1; then
        YARN_VERSION=$(yarn --version)
        print_message "✓ yarn: $YARN_VERSION" $GREEN
        PKG_MANAGER="yarn"
    elif command -v pnpm >/dev/null 2>&1; then
        PNPM_VERSION=$(pnpm --version)
        print_message "✓ pnpm: $PNPM_VERSION" $GREEN
        PKG_MANAGER="pnpm"
    else
        print_message "✗ 未找到包管理器" $RED
        exit 1
    fi

    # 检查Git
    if command -v git >/dev/null 2>&1; then
        GIT_VERSION=$(git --version)
        print_message "✓ Git: $GIT_VERSION" $GREEN
    else
        print_message "⚠ Git 未安装，建议安装" $YELLOW
    fi
}

# 创建项目目录
create_project_dir() {
    if [ -n "$PROJECT_NAME" ]; then
        if [ -d "$PROJECT_NAME" ]; then
            print_message "目录 $PROJECT_NAME 已存在" $YELLOW
            read -p "是否继续？(y/N) " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                exit 1
            fi
        else
            mkdir "$PROJECT_NAME"
            cd "$PROJECT_NAME"
            print_message "创建项目目录: $PROJECT_NAME" $GREEN
        fi
    fi
}

# 初始化Git仓库
init_git() {
    if [ ! -d ".git" ]; then
        print_message "初始化Git仓库..." $BLUE
        git init
        git add .
        git commit -m "Initial commit: ClaudeCode project setup"

        # 创建.gitignore
        create_gitignore
    else
        print_message "Git仓库已存在" $YELLOW
    fi
}

# 创建.gitignore文件
create_gitignore() {
    print_message "创建 .gitignore..." $BLUE

    cat > .gitignore << 'EOF'
# Dependencies
node_modules/
jspm_packages/

# Build outputs
dist/
build/
out/

# Environment variables
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# Logs
npm-debug.log*
yarn-debug.log*
yarn-error.log*
lerna-debug.log*

# Runtime data
pids
*.pid
*.seed
*.pid.lock

# Coverage directory
coverage/
*.lcov

# nyc test coverage
.nyc_output

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
.DS_Store?
._*
Thumbs.db

# Temporary files
*.tmp
*.temp
EOF
}

# 安装依赖
install_dependencies() {
    print_message "安装项目依赖..." $BLUE

    case $PKG_MANAGER in
        "npm")
            npm install
            ;;
        "yarn")
            yarn install
            ;;
        "pnpm")
            pnpm install
            ;;
    esac

    print_message "依赖安装完成" $GREEN
}

# 创建React项目
create_react_project() {
    print_message "创建React项目..." $BLUE

    # 创建基础目录结构
    mkdir -p src/{components,pages,hooks,services,utils,types,assets}
    mkdir -p public

    # 创建package.json
    cat > package.json << 'EOF'
{
  "name": "'$PROJECT_NAME'",
  "version": "1.0.0",
  "private": true,
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "tsc && vite build",
    "lint": "eslint . --ext ts,tsx --report-unused-disable-directives --max-warnings 0",
    "preview": "vite preview",
    "test": "vitest"
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-router-dom": "^6.20.0"
  },
  "devDependencies": {
    "@types/react": "^18.2.37",
    "@types/react-dom": "^18.2.15",
    "@vitejs/plugin-react": "^4.1.1",
    "eslint": "^8.53.0",
    "eslint-plugin-react-hooks": "^4.6.0",
    "eslint-plugin-react-refresh": "^0.4.4",
    "typescript": "^5.2.2",
    "vite": "^4.5.0",
    "vitest": "^0.34.6"
  }
}
EOF

    # 创建Vite配置
    cat > vite.config.ts << 'EOF'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    port: 3000,
    open: true
  }
})
EOF

    # 创建TypeScript配置
    cat > tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "useDefineForClassFields": true,
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx",
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true
  },
  "include": ["src"],
  "references": [{ "path": "./tsconfig.node.json" }]
}
EOF

    # 创建入口文件
    cat > src/main.tsx << 'EOF'
import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App'
import './index.css'

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
)
EOF

    # 创建App组件
    cat > src/App.tsx << 'EOF'
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom'
import './App.css'

function App() {
  return (
    <Router>
      <div className="App">
        <header className="App-header">
          <h1>ClaudeCode React Project</h1>
        </header>
        <main>
          <Routes>
            <Route path="/" element={<div>Home Page</div>} />
          </Routes>
        </main>
      </div>
    </Router>
  )
}

export default App
EOF

    # 创建样式文件
    cat > src/index.css << 'EOF'
body {
  margin: 0;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto',
    'Oxygen', 'Ubuntu', 'Cantarell', 'Fira Sans', 'Droid Sans',
    'Helvetica Neue', sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

code {
  font-family: source-code-pro, Menlo, Monaco, Consolas, 'Courier New',
    monospace;
}

.App {
  text-align: center;
}

.App-header {
  background-color: #282c34;
  padding: 20px;
  color: white;
  margin-bottom: 2rem;
}
EOF

    # 创建public/index.html
    cat > public/index.html << 'EOF
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>ClaudeCode React Project</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>
EOF
}

# 创建Node.js项目
create_node_project() {
    print_message "创建Node.js项目..." $BLUE

    # 创建基础目录结构
    mkdir -p src/{controllers,models,routes,middleware,services,utils,types}
    mkdir -p tests

    # 创建package.json
    cat > package.json << 'EOF'
{
  "name": "'$PROJECT_NAME'",
  "version": "1.0.0",
  "description": "Node.js API server",
  "main": "dist/index.js",
  "scripts": {
    "dev": "tsx watch src/index.ts",
    "build": "tsc",
    "start": "node dist/index.js",
    "test": "jest",
    "lint": "eslint src/**/*.ts"
  },
  "keywords": ["node", "typescript", "api"],
  "author": "",
  "license": "MIT",
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5",
    "helmet": "^7.1.0",
    "morgan": "^1.10.0"
  },
  "devDependencies": {
    "@types/express": "^4.17.21",
    "@types/cors": "^2.8.17",
    "@types/morgan": "^1.9.9",
    "@types/node": "^20.10.0",
    "@typescript-eslint/eslint-plugin": "^6.13.0",
    "@typescript-eslint/parser": "^6.13.0",
    "eslint": "^8.54.0",
    "jest": "^29.7.0",
    "tsx": "^4.6.0",
    "typescript": "^5.3.0"
  }
}
EOF

    # 创建TypeScript配置
    cat > tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "lib": ["ES2020"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist", "tests"]
}
EOF

    # 创建入口文件
    cat > src/index.ts << 'EOF'
import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';

const app = express();
const PORT = process.env.PORT || 3000;

// 中间件
app.use(helmet());
app.use(cors());
app.use(morgan('combined'));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// 基础路由
app.get('/', (req, res) => {
  res.json({
    message: 'ClaudeCode Node.js API',
    version: '1.0.0'
  });
});

// 错误处理
app.use((err: any, req: express.Request, res: express.Response, next: express.NextFunction) => {
  console.error(err.stack);
  res.status(500).json({
    error: 'Something went wrong!'
  });
});

// 启动服务器
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});

export default app;
EOF

    # 创建环境配置
    cat > .env.example << 'EOF'
PORT=3000
NODE_ENV=development
EOF
}

# 创建Python项目
create_python_project() {
    print_message "创建Python项目..." $BLUE

    # 创建基础目录结构
    mkdir -p {app,tests,docs,scripts}
    mkdir -p app/{models,views,urls,utils}

    # 创建requirements.txt
    cat > requirements.txt << 'EOF'
fastapi==0.104.1
uvicorn[standard]==0.24.0
pydantic==2.5.0
python-multipart==0.0.6
SQLAlchemy==2.0.23
psycopg2-binary==2.9.9
pytest==7.4.3
pytest-asyncio==0.21.1
black==23.11.0
isort==5.12.0
mypy==1.7.1
EOF

    # 创建main.py
    cat > main.py << 'EOF'
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(
    title="ClaudeCode API",
    description="A FastAPI example",
    version="1.0.0"
)

# CORS中间件
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def read_root():
    return {"message": "ClaudeCode Python API"}

@app.get("/health")
def health_check():
    return {"status": "healthy"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
EOF

    # 创建pyproject.toml
    cat > pyproject.toml << 'EOF'
[tool.black]
line-length = 88
target-version = ['py39']

[tool.isort]
profile = "black"
multi_line_output = 3

[tool.mypy]
python_version = "3.9"
warn_return_any = true
warn_unused_configs = true
disallow_untyped_defs = true

[tool.pytest.ini_options]
python_files = ["test_*.py", "*_test.py"]
testpaths = ["tests"]
EOF

    # 创建.gitignore
    cat >> .gitignore << 'EOF'

# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
venv/
.venv/
pip-log.txt
pip-delete-this-directory.txt
.tox/
.coverage
.coverage.*
.cache
nosetests.xml
coverage.xml
*.cover
*.py,cover
.hypothesis/
.pytest_cache/

# mypy
.mypy_cache/
.dmypy.json
dmypy.json
EOF
}

# 创建Go项目
create_go_project() {
    print_message "创建Go项目..." $BLUE

    # 创建go.mod
    go mod init "$PROJECT_NAME"

    # 创建基础目录结构
    mkdir -p {cmd,internal/{handler,service,model,repository},pkg,configs}

    # 创建main.go
    cat > main.go << 'EOF
package main

import (
    "log"
    "net/http"

    "github.com/gin-gonic/gin"
)

func main() {
    r := gin.Default()

    // 健康检查
    r.GET("/health", func(c *gin.Context) {
        c.JSON(200, gin.H{
            "status": "healthy",
        })
    })

    // API路由
    v1 := r.Group("/api/v1")
    {
        v1.GET("/", func(c *gin.Context) {
            c.JSON(200, gin.H{
                "message": "ClaudeCode Go API",
                "version": "1.0.0",
            })
        })
    }

    log.Println("Server starting on :8080")
    log.Fatal(http.ListenAndServe(":8080", r))
}
EOF

    # 创建.gitignore
    cat >> .gitignore << 'EOF'

# Go
*.exe
*.exe~
*.dll
*.so
*.dylib
*.test
*.out

# Go workspace file
go.work

# Dependency directories
vendor/

# Go build cache
.cache/

# IDE
.vscode/
.idea/
*.swp
*.swo
EOF

    # 安装Gin
    go get -u github.com/gin-gonic/gin
}

# 创建通用项目
create_generic_project() {
    print_message "创建通用项目..." $BLUE

    mkdir -p {src,docs,tests,scripts,config}

    # 创建README.md
    cat > README.md << 'EOF'
# $PROJECT_NAME

## 项目描述

## 安装

\`\`\`bash
# 安装依赖
[安装命令]
\`\`\`

## 使用

\`\`\`bash
# 运行项目
[运行命令]
\`\`\`

## 项目结构

- src/ - 源代码
- docs/ - 文档
- tests/ - 测试
- scripts/ - 脚本
- config/ - 配置文件
EOF

    # 创建基础源码文件
    cat > src/index.js << 'EOF
// ClaudeCode 项目入口文件
console.log('Hello, ClaudeCode!');
EOF
}

# 复制CLAUDE.md模板
copy_claude_md() {
    print_message "复制CLAUDE.md配置文件..." $BLUE

    # 获取模板目录
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    TEMPLATE_DIR="$SCRIPT_DIR/../templates"

    if [ -f "$TEMPLATE_DIR/CLAUDE.md" ]; then
        cp "$TEMPLATE_DIR/CLAUDE.md" ./CLAUDE.md

        # 替换项目名称
        if [ -n "$PROJECT_NAME" ]; then
            sed -i.bak "s/\\[你的项目名称\\]/$PROJECT_NAME/g" CLAUDE.md
            sed -i.bak "s/\\[项目名称\\]/$PROJECT_NAME/g" CLAUDE.md
            rm CLAUDE.md.bak
        fi

        print_message "✓ CLAUDE.md 已创建" $GREEN
    else
        print_message "⚠ 模板文件不存在，创建基础CLAUDE.md" $YELLOW
        create_basic_claude_md
    fi
}

# 创建基础CLAUDE.md
create_basic_claude_md() {
    cat > CLAUDE.md << 'EOF
# 项目上下文配置

## 项目概述

**项目名称**：${PROJECT_NAME:-未命名项目}
**项目类型**：${PROJECT_TYPE:-通用项目}
**项目描述**：${PROJECT_NAME:-项目}的配置文件
**开始日期**：$(date +%Y-%m-%d)

## 技术栈

### 主要技术
- **语言**：[填写主要编程语言]
- **框架**：[填写使用框架]
- **数据库**：[填写数据库]
- **其他工具**：[填写其他工具]

## 项目结构
```
${PROJECT_NAME:-项目}/
├── src/                # 源代码
├── tests/              # 测试文件
├── docs/               # 文档
└── README.md           # 项目说明
```

## 常用命令
[填写常用命令]

## ClaudeCode提示

### 项目初始化
```
请帮我分析这个项目：
- 技术栈识别
- 项目结构评估
- 改进建议
```
EOF
}

# 显示后续步骤
show_next_steps() {
    print_message "\n项目初始化完成！" $GREEN
    print_message "\n后续步骤：" $BLUE
    echo "1. 编辑 CLAUDE.md 配置项目信息"
    echo "2. 根据项目需求修改配置文件"
    echo "3. 开始开发你的项目"
    echo ""
    print_message "ClaudeCode使用提示：" $YELLOW
    echo "- 使用 'claude \"阅读CLAUDE.md\"' 了解项目配置"
    echo "- 使用 'claude \"帮我创建[功能]\"' 开发功能"
    echo "- 定期更新CLAUDE.md保持信息准确"
}

# 主函数
main() {
    # 显示帮助
    if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
        show_help
        exit 0
    fi

    # 获取参数
    PROJECT_TYPE="$1"
    PROJECT_NAME="$2"

    # 验证参数
    if [ -z "$PROJECT_TYPE" ]; then
        print_message "错误：请指定项目类型" $RED
        show_help
        exit 1
    fi

    # 设置默认项目名称
    if [ -z "$PROJECT_NAME" ]; then
        PROJECT_NAME="claudecode-$(date +%s)"
    fi

    print_message "初始化 $PROJECT_TYPE 项目: $PROJECT_NAME" $BLUE
    echo ""

    # 执行初始化步骤
    check_tools
    create_project_dir
    init_git

    # 根据类型创建项目
    case $PROJECT_TYPE in
        "react")
            create_react_project
            ;;
        "node")
            create_node_project
            ;;
        "python")
            create_python_project
            ;;
        "go")
            create_go_project
            ;;
        "vue")
            print_message "Vue项目模板开发中..." $YELLOW
            create_generic_project
            ;;
        "generic")
            create_generic_project
            ;;
        *)
            print_message "未知项目类型: $PROJECT_TYPE" $RED
            exit 1
            ;;
    esac

    # 安装依赖（如果是Node.js项目）
    if [ "$PROJECT_TYPE" = "react" ] || [ "$PROJECT_TYPE" = "node" ]; then
        install_dependencies
    fi

    # 复制CLAUDE.md
    copy_claude_md

    # 显示后续步骤
    show_next_steps
}

# 运行主函数
main "$@"