#!/bin/bash

# ClaudeCode插件管理脚本
# 作者：大熊掌门
# 用途：批量管理ClaudeCode插件的安装、更新和维护

echo "🚀 ClaudeCode插件管理工具"
echo "================================"

# 必装插件列表
ESSENTIAL_PLUGINS=(
    "claudecode.ai-assistant"
    "gitlens.gitlens"
    "rangav.vscode-thunder-client"
    "esbenp.prettier-vscode"
    "dbaeumer.vscode-eslint"
    "ms-python.python"
    "ms-azuretools.vscode-docker"
    "alefragnani.Bookmarks"
    "ms-vscode.liveshare"
    "ms-vscode-remote.remote-ssh"
)

# 函数：安装插件
install_plugins() {
    echo "📦 开始安装插件..."

    for plugin in "${ESSENTIAL_PLUGINS[@]}"; do
        echo "正在安装: $plugin"
        claudecode install "$plugin" --force
        if [ $? -eq 0 ]; then
            echo "✅ $plugin 安装成功"
        else
            echo "❌ $plugin 安装失败"
        fi
    done

    echo "🎉 插件安装完成！"
}

# 函数：更新所有插件
update_plugins() {
    echo "🔄 开始更新插件..."
    claudecode update --all

    if [ $? -eq 0 ]; then
        echo "✅ 所有插件更新成功"
    else
        echo "❌ 插件更新失败"
    fi
}

# 函数：列出已安装插件
list_plugins() {
    echo "📋 已安装的插件："
    claudecode list --format table
}

# 函数：清理未使用的插件
cleanup_plugins() {
    echo "🧹 清理未使用的插件..."
    claudecode cleanup

    echo "✅ 清理完成"
}

# 函数：检查插件健康状态
check_health() {
    echo "🏥 检查插件健康状态..."
    claudecode health-check

    echo "📊 生成健康报告..."
    claudecode report --format json > plugin-health-report.json

    echo "📄 健康报告已保存到 plugin-health-report.json"
}

# 函数：创建插件配置文件
create_config() {
    echo "⚙️ 创建插件配置文件..."

    # 创建全局配置
    cat > ~/.claudecode/settings.json << EOF
{
    "extensions.autoUpdate": true,
    "extensions.autoCheckUpdates": true,
    "extensions.ignoreRecommendations": false,
    "extensions.showRecommendationsOnlyOnDemand": false,
    "extensions.supportUntrustedWorkspaces": false
}
EOF

    # 创建工作区配置模板
    mkdir -p .vscode
    cat > .vscode/settings.json << EOF
{
    "extensions.recommendations": [
        "ms-python.python",
        "esbenp.prettier-vscode",
        "dbaeumer.vscode-eslint",
        "bradlc.vscode-tailwindcss"
    ]
}
EOF

    echo "✅ 配置文件创建完成"
    echo "📁 全局配置: ~/.claudecode/settings.json"
    echo "📁 工作区配置: .vscode/settings.json"
}

# 函数：备份插件配置
backup_config() {
    echo "💾 备份插件配置..."

    backup_dir="plugin-backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$backup_dir"

    # 备份已安装插件列表
    claudecode list --format json > "$backup_dir/installed-plugins.json"

    # 备份配置文件
    if [ -f ~/.claudecode/settings.json ]; then
        cp ~/.claudecode/settings.json "$backup_dir/"
    fi

    if [ -f .vscode/settings.json ]; then
        cp .vscode/settings.json "$backup_dir/"
    fi

    echo "✅ 配置已备份到: $backup_dir"
}

# 函数：显示帮助信息
show_help() {
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  install     安装必装插件"
    echo "  update      更新所有插件"
    echo "  list        列出已安装插件"
    echo "  cleanup     清理未使用的插件"
    echo "  health      检查插件健康状态"
    echo "  config      创建插件配置文件"
    echo "  backup      备份插件配置"
    echo "  help        显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 install    # 安装所有必装插件"
    echo "  $0 update     # 更新所有插件"
    echo "  $0 health     # 检查插件状态"
}

# 主程序
main() {
    case "${1:-help}" in
        "install")
            install_plugins
            ;;
        "update")
            update_plugins
            ;;
        "list")
            list_plugins
            ;;
        "cleanup")
            cleanup_plugins
            ;;
        "health")
            check_health
            ;;
        "config")
            create_config
            ;;
        "backup")
            backup_config
            ;;
        "help"|*)
            show_help
            ;;
    esac
}

# 执行主程序
main "$@"