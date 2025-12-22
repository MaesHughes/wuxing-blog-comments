#!/bin/bash
# ClaudeCode实时监控脚本
# 用途：持续监控系统状态和性能指标

# 配置参数
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="${LOG_DIR:-/var/log/claudecode}"
CONFIG_FILE="${CONFIG_FILE:-$SCRIPT_DIR/../configs/monitoring.json}"
METRICS_FILE="$LOG_DIR/metrics.csv"
ALERT_LOG="$LOG_DIR/alerts.log"

# 创建日志目录
mkdir -p "$LOG_DIR"

# 日志函数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_DIR/monitor.log"
}

# 告警函数
send_alert() {
    local severity=$1
    local message=$2
    local metric=$3
    local value=$4

    local alert_entry="[$(date '+%Y-%m-%d %H:%M:%S')] [${severity}] ${message}"
    echo "$alert_entry" | tee -a "$ALERT_LOG"

    # 这里可以集成实际的告警通知系统
    case $severity in
        "CRITICAL")
            # 发送邮件、短信等
            log "🚨 CRITICAL告警: $message"
            ;;
        "WARNING")
            # 发送邮件、Slack等
            log "⚠️ WARNING告警: $message"
            ;;
        "INFO")
            log "ℹ️ INFO: $message"
            ;;
    esac
}

# 读取监控配置
load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        # 使用jq解析JSON配置（如果安装了jq）
        if command -v jq > /dev/null; then
            ALERT_RULES=$(jq -r '.monitoring_config.alerting.rules[] | @base64' "$CONFIG_FILE")
            METRICS_INTERVAL=$(jq -r '.monitoring_config.metrics_collection.interval // 30000' "$CONFIG_FILE")
        else
            # 默认配置
            METRICS_INTERVAL=30000
        fi
    else
        METRICS_INTERVAL=30000
    fi

    # 转换为秒
    METRICS_INTERVAL=$((METRICS_INTERVAL / 1000))
}

# 收集系统指标
collect_system_metrics() {
    local timestamp=$(date +%s)

    # CPU使用率
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | sed 's/%us,//')

    # 内存使用
    local mem_info=$(free | grep Mem)
    local total_mem=$(echo $mem_info | awk '{print $2}')
    local used_mem=$(echo $mem_info | awk '{print $3}')
    local mem_usage=$(echo "scale=2; $used_mem * 100 / $total_mem" | bc)

    # 磁盘使用
    local disk_usage=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')

    # 网络IO
    local net_io=$(cat /proc/net/dev | grep eth0 | awk '{print $2","$10}' 2>/dev/null || echo "0,0")

    # 系统负载
    local load_avg=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//')

    echo "$timestamp,$cpu_usage,$mem_usage,$disk_usage,$net_io,$load_avg"
}

# 收集应用指标
collect_app_metrics() {
    local timestamp=$(date +%s)

    # 检查ClaudeCode进程
    if pgrep -f "claude" > /dev/null; then
        local claude_pid=$(pgrep -f "claude" | head -1)
        local claude_cpu=$(ps -p $claude_pid -o %cpu --no-headers 2>/dev/null || echo 0)
        local claude_mem=$(ps -p $claude_pid -o %mem --no-headers 2>/dev/null || echo 0)
        local claude_status="running"
    else
        local claude_cpu=0
        local claude_mem=0
        local claude_status="stopped"
    fi

    # 检查服务响应时间
    local response_time=0
    local service_status="down"
    if curl -s --connect-timeout 5 --max-time 10 http://localhost:8080/health > /dev/null 2>&1; then
        response_time=$(curl -o /dev/null -s -w '%{time_total}' http://localhost:8080/health 2>/dev/null)
        service_status="up"
    fi

    echo "$timestamp,$claude_status,$claude_cpu,$claude_mem,$response_time"
}

# 检查告警条件
check_alerts() {
    local metrics=$1
    local timestamp=$(echo $metrics | cut -d',' -f1)
    local cpu_usage=$(echo $metrics | cut -d',' -f2)
    local mem_usage=$(echo $metrics | cut -d',' -f3)
    local disk_usage=$(echo $metrics | cut -d',' -f4)
    local load_avg=$(echo $metrics | cut -d',' -f6)

    # CPU告警
    if (( $(echo "$cpu_usage > 80" | bc -l) 2>/dev/null )); then
        send_alert "WARNING" "CPU使用率过高: ${cpu_usage}%" "cpu_usage" "$cpu_usage"
    fi

    # 内存告警
    if (( $(echo "$mem_usage > 85" | bc -l) 2>/dev/null )); then
        send_alert "WARNING" "内存使用率过高: ${mem_usage}%" "mem_usage" "$mem_usage"
    fi

    # 磁盘告警
    if [ "$disk_usage" -gt 85 ]; then
        send_alert "CRITICAL" "磁盘使用率过高: ${disk_usage}%" "disk_usage" "$disk_usage"
    fi

    # 负载告警
    if (( $(echo "$load_avg > 2.0" | bc -l) 2>/dev/null )); then
        send_alert "WARNING" "系统负载过高: $load_avg" "load_avg" "$load_avg"
    fi
}

# 检查应用告警
check_app_alerts() {
    local app_metrics=$1
    local timestamp=$(echo $app_metrics | cut -d',' -f1)
    local claude_status=$(echo $app_metrics | cut -d',' -f2)
    local response_time=$(echo $app_metrics | cut -d',' -f5)

    # 服务状态告警
    if [ "$claude_status" = "stopped" ]; then
        send_alert "CRITICAL" "ClaudeCode服务已停止" "service_status" "stopped"
    fi

    # 响应时间告警
    if (( $(echo "$response_time > 5.0" | bc -l) 2>/dev/null )); then
        send_alert "WARNING" "服务响应时间过长: ${response_time}s" "response_time" "$response_time"
    fi
}

# 初始化指标文件
init_metrics_file() {
    if [ ! -f "$METRICS_FILE" ]; then
        # 系统指标标题
        echo "timestamp,cpu_usage,memory_usage,disk_usage,network_io,load_avg" > "$METRICS_FILE"
    fi
}

# 监控主循环
start_monitoring() {
    log "🚀 启动ClaudeCode监控系统"
    log "监控间隔: ${METRICS_INTERVAL}秒"
    log "指标文件: $METRICS_FILE"
    log "告警日志: $ALERT_LOG"

    init_metrics_file

    # 创建PID文件
    echo $$ > "$LOG_DIR/monitor.pid"

    while true; do
        # 收集系统指标
        local sys_metrics=$(collect_system_metrics)
        echo "$sys_metrics" >> "$METRICS_FILE"

        # 检查系统告警
        check_alerts "$sys_metrics"

        # 收集应用指标
        local app_metrics=$(collect_app_metrics)
        check_app_alerts "$app_metrics"

        # 每小时输出一次状态
        if [ $(($(date +%s) % 3600)) -lt $METRICS_INTERVAL ]; then
            local cpu=$(echo $sys_metrics | cut -d',' -f2)
            local mem=$(echo $sys_metrics | cut -d',' -f3)
            log "📊 系统状态 - CPU: ${cpu}%, 内存: ${mem}%"
        fi

        sleep $METRICS_INTERVAL
    done
}

# 停止监控
stop_monitoring() {
    if [ -f "$LOG_DIR/monitor.pid" ]; then
        local pid=$(cat "$LOG_DIR/monitor.pid")
        if kill -0 $pid 2>/dev/null; then
            kill $pid
            log "停止监控进程 (PID: $pid)"
            rm -f "$LOG_DIR/monitor.pid"
        else
            log "监控进程不存在"
            rm -f "$LOG_DIR/monitor.pid"
        fi
    else
        log "未找到监控PID文件"
    fi
}

# 显示监控状态
show_status() {
    echo "=== ClaudeCode监控状态 ==="

    # 检查监控进程
    if [ -f "$LOG_DIR/monitor.pid" ]; then
        local pid=$(cat "$LOG_DIR/monitor.pid")
        if kill -0 $pid 2>/dev/null; then
            echo "✅ 监控进程运行中 (PID: $pid)"
        else
            echo "❌ 监控进程已停止"
        fi
    else
        echo "❌ 监控未启动"
    fi

    # 显示最近的指标
    if [ -f "$METRICS_FILE" ]; then
        echo
        echo "最近的系统指标:"
        tail -5 "$METRICS_FILE"
    fi

    # 显示最近的告警
    if [ -f "$ALERT_LOG" ]; then
        echo
        echo "最近的告警:"
        tail -5 "$ALERT_LOG"
    fi
}

# 显示使用帮助
show_help() {
    echo "ClaudeCode监控脚本使用说明:"
    echo
    echo "用法: $0 {start|stop|restart|status|help}"
    echo
    echo "命令:"
    echo "  start   - 启动监控"
    echo "  stop    - 停止监控"
    echo "  restart - 重启监控"
    echo "  status  - 查看监控状态"
    echo "  help    - 显示帮助信息"
    echo
    echo "配置文件: $CONFIG_FILE"
    echo "指标文件: $METRICS_FILE"
    echo "告警日志: $ALERT_LOG"
}

# 主函数
main() {
    # 加载配置
    load_config

    case "$1" in
        "start")
            start_monitoring
            ;;
        "stop")
            stop_monitoring
            ;;
        "restart")
            stop_monitoring
            sleep 2
            start_monitoring
            ;;
        "status")
            show_status
            ;;
        "help"|"--help"|"-h")
            show_help
            ;;
        *)
            echo "错误: 无效的命令 '$1'"
            echo
            show_help
            exit 1
            ;;
    esac
}

# 捕获退出信号
trap 'log "监控脚本退出"; exit 0' SIGINT SIGTERM

# 执行主函数
main "$@"