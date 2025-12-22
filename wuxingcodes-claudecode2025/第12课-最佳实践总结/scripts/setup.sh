#!/bin/bash
# ClaudeCode生产环境部署脚本
# 用途：一键部署ClaudeCode生产环境

# 配置参数
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
INSTALL_DIR="/opt/claudecode"
SERVICE_USER="claudecode"
LOG_DIR="/var/log/claudecode"
CONFIG_DIR="/etc/claudecode"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查是否为root用户
check_root() {
    if [ "$EUID" -ne 0 ]; then
        log_error "请使用root用户运行此脚本"
        exit 1
    fi
}

# 检查系统类型
check_system() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$NAME
        VER=$VERSION_ID
    else
        log_error "无法检测操作系统类型"
        exit 1
    fi

    log_info "检测到操作系统: $OS $VER"
}

# 安装依赖
install_dependencies() {
    log_info "安装系统依赖..."

    case $OS in
        "Ubuntu"*|"Debian"*)
            apt-get update
            apt-get install -y curl wget gnupg2 software-properties-common \
                           python3 python3-pip jq bc supervisor
            ;;
        "CentOS"*|"Red Hat"*)
            yum update -y
            yum install -y curl wget python3 python3-pip jq bc supervisor
            ;;
        *)
            log_error "不支持的操作系统: $OS"
            exit 1
            ;;
    esac

    # 安装Python依赖
    pip3 install requests psutil
}

# 创建用户
create_user() {
    log_info "创建服务用户: $SERVICE_USER"

    if ! id "$SERVICE_USER" &>/dev/null; then
        useradd -r -s /bin/false -d $INSTALL_DIR $SERVICE_USER
        log_info "用户创建成功"
    else
        log_info "用户已存在"
    fi
}

# 创建目录结构
create_directories() {
    log_info "创建目录结构..."

    # 主目录
    mkdir -p $INSTALL_DIR
    mkdir -p $INSTALL_DIR/{bin,config,logs,scripts}

    # 配置目录
    mkdir -p $CONFIG_DIR

    # 日志目录
    mkdir -p $LOG_DIR

    # 设置权限
    chown -R $SERVICE_USER:$SERVICE_USER $INSTALL_DIR
    chown -R $SERVICE_USER:$SERVICE_USER $LOG_DIR
    chmod 755 $CONFIG_DIR
}

# 复制配置文件
copy_configs() {
    log_info "复制配置文件..."

    # 复制生产配置
    if [ -f "$PROJECT_DIR/configs/production.json" ]; then
        cp "$PROJECT_DIR/configs/production.json" "$CONFIG_DIR/"
        log_info "复制生产配置文件"
    fi

    # 复制团队配置
    if [ -f "$PROJECT_DIR/configs/team.json" ]; then
        cp "$PROJECT_DIR/configs/team.json" "$CONFIG_DIR/"
        log_info "复制团队配置文件"
    fi

    # 复制监控配置
    if [ -f "$PROJECT_DIR/configs/monitoring.json" ]; then
        cp "$PROJECT_DIR/configs/monitoring.json" "$CONFIG_DIR/"
        log_info "复制监控配置文件"
    fi

    # 设置权限
    chown -R $SERVICE_USER:$SERVICE_USER $CONFIG_DIR
    chmod 644 $CONFIG_DIR/*.json
}

# 复制脚本
copy_scripts() {
    log_info "复制管理脚本..."

    # 复制所有脚本
    cp "$PROJECT_DIR/scripts"/*.sh $INSTALL_DIR/scripts/
    chmod +x $INSTALL_DIR/scripts/*.sh

    # 创建符号链接
    ln -sf $INSTALL_DIR/scripts/health-check.sh /usr/local/bin/claude-health
    ln -sf $INSTALL_DIR/scripts/auto-fix.sh /usr/local/bin/claude-fix
    ln -sf $INSTALL_DIR/scripts/monitor.sh /usr/local/bin/claude-monitor

    log_info "脚本复制完成"
}

# 创建systemd服务
create_service() {
    log_info "创建systemd服务..."

    cat > /etc/systemd/system/claudecode.service << 'EOF'
[Unit]
Description=ClaudeCode Service
After=network.target

[Service]
Type=simple
User=claudecode
Group=claudecode
WorkingDirectory=/opt/claudecode
ExecStart=/opt/claudecode/bin/claudecode start
ExecStop=/opt/claudecode/bin/claudecode stop
ExecReload=/bin/kill -HUP $MAINPID
Restart=always
RestartSec=10

# 环境变量
Environment=CLAUDE_CONFIG_DIR=/etc/claudecode
Environment=CLAUDE_LOG_DIR=/var/log/claudecode

# 安全设置
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=/var/log/claudecode

[Install]
WantedBy=multi-user.target
EOF

    # 重新加载systemd
    systemctl daemon-reload

    log_info "systemd服务创建完成"
}

# 创建监控服务
create_monitor_service() {
    log_info "创建监控服务..."

    cat > /etc/systemd/system/claudecode-monitor.service << EOF
[Unit]
Description=ClaudeCode Monitor Service
After=claudecode.service

[Service]
Type=simple
User=claudecode
Group=claudecode
ExecStart=$INSTALL_DIR/scripts/monitor.sh start
ExecStop=$INSTALL_DIR/scripts/monitor.sh stop
Restart=always
RestartSec=30

[Install]
WantedBy=multi-user.target
EOF

    # 重新加载systemd
    systemctl daemon-reload

    log_info "监控服务创建完成"
}

# 配置日志轮转
setup_logrotate() {
    log_info "配置日志轮转..."

    cat > /etc/logrotate.d/claudecode << 'EOF'
/var/log/claudecode/*.log {
    daily
    missingok
    rotate 30
    compress
    delaycompress
    notifempty
    create 644 claudecode claudecode
    postrotate
        systemctl reload claudecode 2>/dev/null || true
    endscript
}
EOF

    log_info "日志轮转配置完成"
}

# 配置防火墙
setup_firewall() {
    log_info "配置防火墙规则..."

    # 检查防火墙类型
    if command -v ufw > /dev/null; then
        # Ubuntu/Debian
        ufw allow 8080/tcp
        ufw --force enable
        log_info "UFW防火墙配置完成"
    elif command -v firewall-cmd > /dev/null; then
        # CentOS/RHEL
        firewall-cmd --permanent --add-port=8080/tcp
        firewall-cmd --reload
        log_info "firewalld配置完成"
    else
        log_warn "未检测到防火墙，请手动配置"
    fi
}

# 启动服务
start_services() {
    log_info "启动ClaudeCode服务..."

    # 启用并启动主服务
    systemctl enable claudecode
    systemctl start claudecode

    # 启用并启动监控服务
    systemctl enable claudecode-monitor
    systemctl start claudecode-monitor

    # 检查服务状态
    sleep 5

    if systemctl is-active --quiet claudecode; then
        log_info "✅ ClaudeCode服务启动成功"
    else
        log_error "❌ ClaudeCode服务启动失败"
        systemctl status claudecode
    fi

    if systemctl is-active --quiet claudecode-monitor; then
        log_info "✅ 监控服务启动成功"
    else
        log_error "❌ 监控服务启动失败"
        systemctl status claudecode-monitor
    fi
}

# 显示部署信息
show_deployment_info() {
    echo
    echo "=================================="
    echo "🎉 ClaudeCode部署完成！"
    echo "=================================="
    echo
    echo "服务信息:"
    echo "  安装目录: $INSTALL_DIR"
    echo "  配置目录: $CONFIG_DIR"
    echo "  日志目录: $LOG_DIR"
    echo "  运行用户: $SERVICE_USER"
    echo
    echo "管理命令:"
    echo "  启动服务: systemctl start claudecode"
    echo "  停止服务: systemctl stop claudecode"
    echo "  重启服务: systemctl restart claudecode"
    echo "  查看状态: systemctl status claudecode"
    echo
    echo "监控命令:"
    echo "  启动监控: claude-monitor start"
    echo "  停止监控: claude-monitor stop"
    echo "  查看状态: claude-monitor status"
    echo
    echo "健康检查:"
    echo "  执行检查: claude-health"
    echo "  自动修复: claude-fix"
    echo
    echo "配置文件:"
    echo "  主配置: $CONFIG_DIR/production.json"
    echo "  团队配置: $CONFIG_DIR/team.json"
    echo "  监控配置: $CONFIG_DIR/monitoring.json"
    echo
}

# 卸载函数
uninstall() {
    log_warn "开始卸载ClaudeCode..."

    # 停止服务
    systemctl stop claudecode claudecode-monitor 2>/dev/null
    systemctl disable claudecode claudecode-monitor 2>/dev/null

    # 删除服务文件
    rm -f /etc/systemd/system/claudecode.service
    rm -f /etc/systemd/system/claudecode-monitor.service
    systemctl daemon-reload

    # 删除文件
    rm -rf $INSTALL_DIR
    rm -rf $CONFIG_DIR
    rm -rf $LOG_DIR
    rm -f /etc/logrotate.d/claudecode

    # 删除用户
    userdel -r $SERVICE_USER 2>/dev/null

    # 删除符号链接
    rm -f /usr/local/bin/claude-health
    rm -f /usr/local/bin/claude-fix
    rm -f /usr/local/bin/claude-monitor

    log_info "ClaudeCode卸载完成"
}

# 显示帮助
show_help() {
    echo "ClaudeCode部署脚本"
    echo
    echo "用法: $0 {install|uninstall|help}"
    echo
    echo "命令:"
    echo "  install   - 安装ClaudeCode生产环境"
    echo "  uninstall - 卸载ClaudeCode"
    echo "  help      - 显示帮助信息"
}

# 主函数
main() {
    case "$1" in
        "install")
            check_root
            check_system
            install_dependencies
            create_user
            create_directories
            copy_configs
            copy_scripts
            create_service
            create_monitor_service
            setup_logrotate
            setup_firewall
            start_services
            show_deployment_info
            ;;
        "uninstall")
            check_root
            uninstall
            ;;
        "help"|"--help"|"-h")
            show_help
            ;;
        *)
            log_error "无效的命令: $1"
            echo
            show_help
            exit 1
            ;;
    esac
}

# 执行主函数
main "$@"