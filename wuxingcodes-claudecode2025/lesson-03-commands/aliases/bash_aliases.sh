#!/bin/bash
# ClaudeCode Bash 别名配置
# 作者：大熊掌门
# 使用方法：source ~/.bash_aliases

# === 基础别名 ===
alias cc='claudecode'
alias cch='claudecode --help'
alias ccv='claudecode --version'

# === 快速启动 ===
alias cc-init='claudecode --init'
alias cca='claudecode --add'
alias ccr='claudecode --remove'
alias ccc='claudecode --clear'
alias cccx='claudecode --context'

# === 项目类型初始化 ===
alias cc-py='claudecode --init --type python'
alias cc-js='claudecode --init --type javascript'
alias cc-ts='claudecode --init --type typescript'
alias cc-react='claudecode --init --type react'
alias cc-vue='claudecode --init --type vue'
alias cc-node='claudecode --init --type node'

# === 工作流别名 ===
alias cc-review='claudecode "请审查这段代码，指出问题并提供改进建议"'
alias cc-refactor='claudecode "请重构这段代码，提高代码质量"'
alias cc-explain='claudecode "请详细解释这段代码的功能和原理"'
alias cc-optimize='claudecode "请优化这段代码的性能"'
alias cc-doc='claudecode "请为这段代码生成文档"'

# === 文件操作别名 ===
alias cc-add='function() { claudecode --add "$@"; }'
alias cc-read='function() { claudecode "请读取并解释文件: $1" "$1"; }'
alias cc-create='function() { claudecode "创建文件: $1" > "$1"; }'
alias cc-update='function() { claudecode "更新文件: $1" < "$1" > /tmp/update.txt && mv /tmp/update.txt "$1"; }'

# === 调试别名 ===
alias cc-debug='claudecode --debug'
alias cc-verbose='claudecode --verbose'
alias cc-test='claudecode --test'
alias cc-dry='claudecode --dry-run'

# === 配置别名 ===
alias cc-config='claudecode --config'
alias cc-set='claudecode --set'
alias cc-env='claudecode --env'
alias cc-profile='claudecode --profile'

# === 历史管理别名 ===
alias cc-history='claudecode --history'
alias cc-save='function() { echo "$*" >> ~/.claudecode_history.txt; }'
alias cc-search='function() { grep "$*" ~/.claudecode_history.txt; }'

# === 模板别名 ===
alias cc-template='claudecode --template'
alias cc-templates='claudecode --list-templates'
alias cc-create-template='claudecode --create-template'

# === 插件别名 ===
alias cc-plugins='claudecode --list-plugins'
alias cc-enable='claudecode --enable'
alias cc-disable='claudecode --disable'

# === 多项目工作流 ===
alias cc-work='function() { cd "$1" && claudecode; }'
alias cc-dev='function() { cd ~/dev/$1 && claudecode --init; }'
alias cc-proj='function() { cd ~/projects/$1 && claudecode --add .; }'

# === 快速提示词函数 ===
# 代码生成
cc-gen() {
    local prompt="$1"
    shift
    claudecode "$prompt" "$@"
}

# Bug修复
cc-fix() {
    claudecode "请修复这个bug：" --file "$1" --error "$2"
}

# 代码审查
cc-review-file() {
    if [ -f "$1" ]; then
        claudecode "请审查这个文件中的代码，指出潜在问题：" "$1"
    else
        echo "文件不存在: $1"
    fi
}

# 生成测试
cc-test-gen() {
    if [ -f "$1" ]; then
        claudecode "请为这个文件生成单元测试：" "$1"
    else
        echo "文件不存在: $1"
    fi
}

# API文档生成
cc-api-doc() {
    if [ -f "$1" ]; then
        claudecode "请为这个API生成文档：" "$1"
    else
        echo "文件不存在: $1"
    fi
}

# === 环境切换 ===
alias cc-dev='claudecode --profile development'
alias cc-prod='claudecode --profile production'
alias cc-test='claudecode --profile testing'

# === 常用快捷命令 ===
alias cc-hello='claudecode "Hello! 我是ClaudeCode，有什么可以帮你的吗？"'
alias cc-summarize='claudecode "请总结当前目录的内容"'
alias cc-plan='claudecode "请为我制定一个开发计划"'

# === 错误处理增强 ===
cc-safe() {
    local command="$1"
    shift
    echo "执行命令: $command $@"
    if [ "$?" -ne 0 ]; then
        echo "命令执行失败，请检查："
        echo "1. 命令语法是否正确"
        echo "2. 文件是否存在"
        echo "3. 权限是否足够"
    fi
}

# 查看文件信息
cc-info() {
    if [ -f "$1" ]; then
        echo "文件信息：$1"
        echo "大小：$(ls -lh "$1" | awk '{print $5}')"
        echo "修改时间：$(ls -l "$1" | awk '{print $6, $7, $8}')"
        echo "文件类型：$(file "$1")"
        echo "内容预览："
        echo "---"
        head -n 10 "$1"
    else
        echo "文件不存在: $1"
    fi
}

# === 性能监控 ===
alias cc-speed='time claudecode'
alias cc-stats='claudecode --stats'

# === 清理功能 ===
alias cc-clean='claudecode --clean'
alias cc-reset='claudecode --reset-all'

# === 备份功能 ===
cc-backup() {
    local backup_dir="$HOME/.claudecode-backups"
    mkdir -p "$backup_dir"
    cp -r ~/.config/claudecode "$backup_dir/config-$(date +%Y%m%d-%H%M%S)"
    echo "配置已备份到: $backup_dir"
}

# === 更新检查 ===
cc-update() {
    echo "检查 ClaudeCode 更新..."
    claudecode --check-updates
}

# === 安装/卸载别名 ===
alias cc-uninstall='claudecode --uninstall'
alias cc-install='claudecode --install'

# === 彩色输出增强 ===
cc-rainbow() {
    echo "🌟 彩虹模式已启用！" | lolcat
    claudecode "$@" | lolcat
}

# === 实用函数：快速生成项目结构 ===
cc-make-project() {
    local project_name="$1"
    local project_type="$2"

    if [ -z "$project_name" ]; then
        echo "用法: cc-make-project <项目名> [项目类型]"
        return 1
    fi

    mkdir -p "$project_name"
    cd "$project_name"

    # 创建基本项目结构
    mkdir -p src tests docs
    echo "# $project_name" > README.md

    # 创建.gitignore
    cat > .gitignore << EOF
node_modules
dist
build
.env
.env.local
.DS_Store
EOF

    # 根据项目类型创建配置
    case "$project_type" in
        "react"|"frontend")
            npm init -y
            npm install react react-dom @types/react @types/react-dom
            ;;
        "node"|"backend")
            npm init -y
            npm install express
            ;;
        "python")
            python -m venv venv
            source venv/bin/activate
            pip install pytest
            ;;
    esac

    # 添加项目到ClaudeCode上下文
    claudecode --add .

    echo "✅ 项目 '$project_name' 创建成功！"
}

# === 初始化提示 ===
echo "ClaudeCode Bash 别名已加载"
echo "输入 'cc --help' 查看基本命令"
echo "输入 'cc-aliases' 查看所有别名"