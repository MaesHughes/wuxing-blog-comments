#!/bin/bash
# ClaudeCode系统健康检查脚本
# 用途：全面检查ClaudeCode系统运行状态

# 配置参数
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="${LOG_DIR:-/var/log/claudecode}"
CONFIG_FILE="${CONFIG_FILE:-$SCRIPT_DIR/../configs/production.json}"

# 创建日志目录
mkdir -p "$LOG_DIR"

# 日志函数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_DIR/health-check.log"
}

# 检查结果统计
ISSUES_FOUND=0
CHECKS_PASSED=0

# 1. 系统资源检查
check_system_resources() {
    log "📊 检查系统资源..."

    # CPU使用率
    CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | sed 's/%us,//')
    if (( $(echo "$CPU_USAGE > 80" | bc -l) 2>/dev/null )); then
        log "❌ CPU使用率过高: ${CPU_USAGE}%"
        ((ISSUES_FOUND++))
    else
        log "✅ CPU使用率正常: ${CPU_USAGE}%"
        ((CHECKS_PASSED++))
    fi

    # 内存使用
    MEM_INFO=$(free | grep Mem)
    TOTAL_MEM=$(echo $MEM_INFO | awk '{print $2}')
    USED_MEM=$(echo $MEM_INFO | awk '{print $3}')
    MEM_USAGE=$(echo "scale=1; $USED_MEM * 100 / $TOTAL_MEM" | bc)

    if (( $(echo "$MEM_USAGE > 85" | bc -l) )); then
        log "❌ 内存使用率过高: ${MEM_USAGE}%"
        ((ISSUES_FOUND++))
    else
        log "✅ 内存使用率正常: ${MEM_USAGE}%"
        ((CHECKS_PASSED++))
    fi

    # 磁盘空间
    DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
    if [ "$DISK_USAGE" -gt 85 ]; then
        log "❌ 磁盘使用率过高: ${DISK_USAGE}%"
        ((ISSUES_FOUND++))
    else
        log "✅ 磁盘使用率正常: ${DISK_USAGE}%"
        ((CHECKS_PASSED++))
    fi

    # 系统负载
    LOAD_AVG=$(uptime | awk -F'load average:' '{print $2}')
    log "ℹ️ 系统负载: $LOAD_AVG"
}

# 2. ClaudeCode服务检查
check_claude_service() {
    log "🤖 检查ClaudeCode服务..."

    # 检查进程
    if pgrep -f "claude" > /dev/null; then
        log "✅ ClaudeCode进程运行正常"
        ((CHECKS_PASSED++))

        # 显示进程信息
        CLAUDE_PID=$(pgrep -f "claude" | head -1)
        CLAUDE_MEM=$(ps -p $CLAUDE_PID -o %mem --no-headers)
        CLAUDE_CPU=$(ps -p $CLAUDE_PID -o %cpu --no-headers)
        log "ℹ️ 进程PID: $CLAUDE_PID, CPU: ${CLAUDE_CPU}%, 内存: ${CLAUDE_MEM}%"
    else
        log "❌ ClaudeCode进程未运行"
        ((ISSUES_FOUND++))
        return 1
    fi

    # 检查服务响应（假设健康检查端点）
    HEALTH_URL="http://localhost:8080/health"
    if curl -s --connect-timeout 5 "$HEALTH_URL" > /dev/null 2>&1; then
        log "✅ 服务响应正常"
        ((CHECKS_PASSED++))
    else
        log "❌ 服务响应异常或端点不可达"
        ((ISSUES_FOUND++))
    fi
}

# 3. 网络连接检查
check_network_connectivity() {
    log "🌐 检查网络连接..."

    # DNS解析测试
    if nslookup api.anthropic.com > /dev/null 2>&1; then
        log "✅ DNS解析正常"
        ((CHECKS_PASSED++))
    else
        log "❌ DNS解析失败"
        ((ISSUES_FOUND++))
    fi

    # HTTPS连接测试
    if curl -s --connect-timeout 10 https://api.anthropic.com > /dev/null 2>&1; then
        log "✅ HTTPS连接正常"
        ((CHECKS_PASSED++))

        # 延迟测试
        LATENCY=$(curl -o /dev/null -s -w '%{time_total}' https://api.anthropic.com 2>/dev/null)
        if (( $(echo "$LATENCY > 5.0" | bc -l) 2>/dev/null )); then
            log "⚠️ API延迟较高: ${LATENCY}s"
        else
            log "✅ API延迟正常: ${LATENCY}s"
        fi
    else
        log "❌ HTTPS连接失败"
        ((ISSUES_FOUND++))
    fi
}

# 4. 配置文件检查
check_configuration() {
    log "⚙️ 检查配置文件..."

    if [ -f "$CONFIG_FILE" ]; then
        log "✅ 配置文件存在: $CONFIG_FILE"
        ((CHECKS_PASSED++))

        # 检查JSON格式
        if python3 -m json.tool "$CONFIG_FILE" > /dev/null 2>&1; then
            log "✅ 配置文件JSON格式正确"
            ((CHECKS_PASSED++))
        else
            log "❌ 配置文件JSON格式错误"
            ((ISSUES_FOUND++))
        fi
    else
        log "❌ 配置文件不存在: $CONFIG_FILE"
        ((ISSUES_FOUND++))
    fi
}

# 5. 日志检查
check_logs() {
    log "📋 检查日志系统..."

    # 检查日志目录
    if [ -d "$LOG_DIR" ]; then
        log "✅ 日志目录存在: $LOG_DIR"
        ((CHECKS_PASSED++))

        # 检查最近的错误
        ERROR_COUNT=$(grep -c "ERROR" "$LOG_DIR"/*.log 2>/dev/null || echo 0)
        if [ "$ERROR_COUNT" -gt 0 ]; then
            log "⚠️ 发现 $ERROR_COUNT 个错误日志"
        else
            log "✅ 未发现错误日志"
            ((CHECKS_PASSED++))
        fi
    else
        log "❌ 日志目录不存在: $LOG_DIR"
        ((ISSUES_FOUND++))
    fi
}

# 6. 权限检查
check_permissions() {
    log "🔐 检查文件权限..."

    # 检查配置文件权限
    if [ -f "$CONFIG_FILE" ]; then
        if [ -r "$CONFIG_FILE" ]; then
            log "✅ 配置文件可读"
            ((CHECKS_PASSED++))
        else
            log "❌ 配置文件不可读"
            ((ISSUES_FOUND++))
        fi
    fi

    # 检查日志目录权限
    if [ -d "$LOG_DIR" ]; then
        if [ -w "$LOG_DIR" ]; then
            log "✅ 日志目录可写"
            ((CHECKS_PASSED++))
        else
            log "❌ 日志目录不可写"
            ((ISSUES_FOUND++))
        fi
    fi
}

# 主函数
main() {
    log "=== ClaudeCode系统健康检查开始 ==="
    log "检查时间: $(date)"
    log "================================"

    # 执行所有检查
    check_system_resources
    check_claude_service
    check_network_connectivity
    check_configuration
    check_logs
    check_permissions

    # 输出检查结果
    log "================================"
    log "健康检查完成"
    log "通过检查: $CHECKS_PASSED 项"
    log "发现问题: $ISSUES_FOUND 项"

    if [ $ISSUES_FOUND -eq 0 ]; then
        log "🎉 系统状态良好，未发现问题"
        exit 0
    else
        log "⚠️ 发现 $ISSUES_FOUND 个问题需要处理"
        log "请查看详细日志进行修复"
        exit 1
    fi
}

# 执行主函数
main "$@"