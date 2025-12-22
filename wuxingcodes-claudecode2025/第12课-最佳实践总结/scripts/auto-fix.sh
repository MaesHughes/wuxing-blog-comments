#!/bin/bash
# ClaudeCode自动修复脚本
# 用途：自动修复常见问题

# 配置参数
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="${LOG_DIR:-/var/log/claudecode}"
CONFIG_FILE="${CONFIG_FILE:-$SCRIPT_DIR/../configs/production.json}"

# 创建日志目录
mkdir -p "$LOG_DIR"

# 日志函数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_DIR/auto-fix.log"
}

# 修复统计
FIXES_ATTEMPTED=0
FIXES_SUCCEEDED=0
FIXES_FAILED=0

# 1. 修复ClaudeCode服务
fix_claude_service() {
    log "🔧 尝试修复ClaudeCode服务..."
    ((FIXES_ATTEMPTED++))

    # 检查服务状态
    if ! pgrep -f "claude" > /dev/null; then
        log "服务未运行，尝试启动..."

        # 尝试systemctl启动
        if command -v systemctl > /dev/null; then
            if systemctl start claudecode 2>/dev/null; then
                log "✅ systemctl启动成功"
            else
                log "⚠️ systemctl启动失败，尝试手动启动"
                # 手动启动（根据实际安装路径调整）
                nohup claude start > /dev/null 2>&1 &
            fi
        else
            # 手动启动
            nohup claude start > /dev/null 2>&1 &
        fi

        # 等待启动
        sleep 5

        # 验证启动
        if pgrep -f "claude" > /dev/null; then
            log "✅ ClaudeCode服务启动成功"
            ((FIXES_SUCCEEDED++))
        else
            log "❌ ClaudeCode服务启动失败"
            ((FIXES_FAILED++))
        fi
    else
        log "✅ ClaudeCode服务已运行"
        ((FIXES_SUCCEEDED++))
    fi
}

# 2. 修复文件权限
fix_permissions() {
    log "🔧 修复文件权限..."
    ((FIXES_ATTEMPTED++))

    # 修复配置目录权限
    CONFIG_DIR=$(dirname "$CONFIG_FILE")
    if [ ! -d "$CONFIG_DIR" ]; then
        mkdir -p "$CONFIG_DIR"
        log "创建配置目录: $CONFIG_DIR"
    fi

    # 设置配置文件权限
    if [ -f "$CONFIG_FILE" ]; then
        chmod 644 "$CONFIG_FILE"
        log "设置配置文件权限: 644"
    fi

    # 设置目录权限
    chmod 755 "$CONFIG_DIR"
    log "设置配置目录权限: 755"

    # 修复日志目录权限
    if [ -d "$LOG_DIR" ]; then
        chmod 755 "$LOG_DIR"
        chown -R $(whoami):$(whoami) "$LOG_DIR" 2>/dev/null
        log "修复日志目录权限"
    fi

    log "✅ 权限修复完成"
    ((FIXES_SUCCEEDED++))
}

# 3. 修复网络连接
fix_network() {
    log "🔧 修复网络连接..."
    ((FIXES_ATTEMPTED++))

    # 清理DNS缓存（Linux）
    if command -v systemctl > /dev/null; then
        if systemctl is-active --quiet systemd-resolved; then
            systemctl restart systemd-resolved
            log "清理systemd-resolved DNS缓存"
        fi
    fi

    # 更新DNS服务器（临时）
    if [ -w /etc/resolv.conf ]; then
        # 备份原文件
        cp /etc/resolv.conf /etc/resolv.conf.bak

        # 添加公共DNS
        if ! grep -q "8.8.8.8" /etc/resolv.conf; then
            echo "nameserver 8.8.8.8" >> /etc/resolv.conf
            echo "nameserver 1.1.1.1" >> /etc/resolv.conf
            log "添加公共DNS服务器"
        fi
    fi

    # 测试网络连接
    sleep 2
    if curl -s --connect-timeout 5 https://api.anthropic.com > /dev/null 2>&1; then
        log "✅ 网络连接修复成功"
        ((FIXES_SUCCEEDED++))
    else
        log "❌ 网络连接仍有问题"
        ((FIXES_FAILED++))
    fi
}

# 4. 清理磁盘空间
fix_disk_space() {
    log "🔧 清理磁盘空间..."
    ((FIXES_ATTEMPTED++))

    # 清理日志文件
    find "$LOG_DIR" -name "*.log" -mtime +7 -delete 2>/dev/null
    log "清理7天前的日志文件"

    # 清理临时文件
    find /tmp -name "claude*" -mtime +1 -delete 2>/dev/null
    log "清理ClaudeCode临时文件"

    # 清理系统临时文件
    if command -v apt > /dev/null; then
        apt-get clean > /dev/null 2>&1
    elif command -v yum > /dev/null; then
        yum clean all > /dev/null 2>&1
    fi

    log "✅ 磁盘空间清理完成"
    ((FIXES_SUCCEEDED++))
}

# 5. 修复配置文件
fix_configuration() {
    log "🔧 检查并修复配置文件..."
    ((FIXES_ATTEMPTED++))

    # 检查配置文件是否存在
    if [ ! -f "$CONFIG_FILE" ]; then
        log "配置文件不存在，创建默认配置..."
        # 创建基本配置结构
        cat > "$CONFIG_FILE" << 'EOF'
{
  "model": "claude-3-sonnet-20240229",
  "max_tokens": 4096,
  "temperature": 0.1,
  "timeout": 60000,
  "cache": {
    "enabled": true,
    "max_size": "2GB",
    "ttl": 3600
  },
  "logging": {
    "level": "info",
    "file": "/var/log/claudecode/claude.log"
  }
}
EOF
        log "创建默认配置文件: $CONFIG_FILE"
    fi

    # 验证JSON格式
    if python3 -m json.tool "$CONFIG_FILE" > /dev/null 2>&1; then
        log "✅ 配置文件格式正确"
        ((FIXES_SUCCEEDED++))
    else
        log "❌ 配置文件格式错误，需要手动修复"
        ((FIXES_FAILED++))
    fi
}

# 6. 重启服务
restart_services() {
    log "🔄 重启相关服务..."
    ((FIXES_ATTEMPTED++))

    # 重启ClaudeCode服务
    if command -v systemctl > /dev/null; then
        if systemctl is-active --quiet claudecode; then
            systemctl restart claudecode
            log "重启ClaudeCode服务"
        fi
    else
        # 手动重启
        pkill -f claude 2>/dev/null
        sleep 3
        nohup claude start > /dev/null 2>&1 &
        log "手动重启ClaudeCode"
    fi

    # 等待服务启动
    sleep 5

    # 验证服务状态
    if pgrep -f "claude" > /dev/null; then
        log "✅ 服务重启成功"
        ((FIXES_SUCCEEDED++))
    else
        log "❌ 服务重启失败"
        ((FIXES_FAILED++))
    fi
}

# 显示修复菜单
show_menu() {
    echo
    echo "=== ClaudeCode自动修复工具 ==="
    echo "1. 修复ClaudeCode服务"
    echo "2. 修复文件权限"
    echo "3. 修复网络连接"
    echo "4. 清理磁盘空间"
    echo "5. 修复配置文件"
    echo "6. 重启服务"
    echo "7. 执行全部修复"
    echo "0. 退出"
    echo "================================"
}

# 主函数
main() {
    log "=== ClaudeCode自动修复工具启动 ==="

    # 检查参数
    if [ "$1" = "--auto" ]; then
        # 自动模式：执行所有修复
        log "自动模式：执行所有修复任务"
        fix_claude_service
        fix_permissions
        fix_network
        fix_disk_space
        fix_configuration
        restart_services
    else
        # 交互模式
        while true; do
            show_menu
            read -p "请选择修复选项 (0-7): " choice

            case $choice in
                1)
                    fix_claude_service
                    ;;
                2)
                    fix_permissions
                    ;;
                3)
                    fix_network
                    ;;
                4)
                    fix_disk_space
                    ;;
                5)
                    fix_configuration
                    ;;
                6)
                    restart_services
                    ;;
                7)
                    fix_claude_service
                    fix_permissions
                    fix_network
                    fix_disk_space
                    fix_configuration
                    restart_services
                    ;;
                0)
                    log "退出修复工具"
                    break
                    ;;
                *)
                    log "无效选项，请重新选择"
                    ;;
            esac

            echo
            read -p "按回车键继续..."
        done
    fi

    # 输出修复结果
    log "================================"
    log "修复任务完成"
    log "尝试修复: $FIXES_ATTEMPTED 项"
    log "修复成功: $FIXES_SUCCEEDED 项"
    log "修复失败: $FIXES_FAILED 项"

    if [ $FIXES_FAILED -eq 0 ]; then
        log "🎉 所有修复任务成功完成"
        exit 0
    else
        log "⚠️ 有 $FIXES_FAILED 项修复失败，请查看日志"
        exit 1
    fi
}

# 执行主函数
main "$@"