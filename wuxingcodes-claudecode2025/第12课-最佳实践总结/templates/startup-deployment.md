# 初创公司部署模板

## 简化架构

```
┌─────────────────────────────────────────┐
│              单机部署架构                  │
│                                         │
│  ┌─────────────┐  ┌─────────────┐       │
│  │  Nginx      │  │  ClaudeCode │       │
│  │ (反向代理)   │──│  主服务     │       │
│  │  (SSL)      │  │             │       │
│  └─────────────┘  └─────────────┘       │
│         │                │              │
│  ┌─────────────┐  ┌─────────────┐       │
│  │  Redis      │  │  SQLite     │       │
│  │ (缓存)      │  │ (数据库)    │       │
│  └─────────────┘  └─────────────┘       │
│                                         │
│  ┌─────────────┐  ┌─────────────┐       │
│  │  监控脚本   │  │  日志文件   │       │
│  │  (crontab)  │  │ (logrotate) │       │
│  └─────────────┘  └─────────────┘       │
└─────────────────────────────────────────┘
```

## 快速部署脚本

### 一键安装脚本

```bash
#!/bin/bash
# startup-deploy.sh - 初创公司快速部署

set -e

# 配置变量
INSTALL_DIR="/opt/claudecode"
SERVICE_USER="claudecode"
DOMAIN="your-domain.com"
EMAIL="admin@your-domain.com"

# 颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 安装系统依赖
install_system_deps() {
    log_info "安装系统依赖..."

    # 更新系统
    apt-get update && apt-get upgrade -y

    # 安装基础软件
    apt-get install -y \
        nginx \
        redis-server \
        sqlite3 \
        python3 \
        python3-pip \
        certbot \
        python3-certbot-nginx \
        supervisor \
        curl \
        wget \
        git

    # 安装Python依赖
    pip3 install flask gunicorn redis psutil requests
}

# 创建用户和目录
setup_user() {
    log_info "创建服务用户..."

    if ! id "$SERVICE_USER" &>/dev/null; then
        useradd -r -s /bin/bash -d $INSTALL_DIR $SERVICE_USER
    fi

    # 创建目录
    mkdir -p $INSTALL_DIR/{app,config,logs,static}
    chown -R $SERVICE_USER:$SERVICE_USER $INSTALL_DIR
}

# 配置Redis
setup_redis() {
    log_info "配置Redis..."

    # Redis配置
    cat > /etc/redis/claudecode.conf << 'EOF'
port 6379
bind 127.0.0.1
timeout 0
save 900 1
save 300 10
save 60 10000
maxmemory 256mb
maxmemory-policy allkeys-lru
EOF

    # 使用自定义配置
    systemctl enable redis-server
    systemctl restart redis-server
}

# 初始化数据库
setup_database() {
    log_info "初始化数据库..."

    sudo -u $SERVICE_USER sqlite3 $INSTALL_DIR/config/claudecode.db << 'EOF'
CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT UNIQUE NOT NULL,
    email TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS sessions (
    id TEXT PRIMARY KEY,
    user_id INTEGER NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users (id)
);

CREATE TABLE IF NOT EXISTS api_keys (
    id TEXT PRIMARY KEY,
    user_id INTEGER NOT NULL,
    name TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_used TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users (id)
);

CREATE TABLE IF NOT EXISTS usage_logs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    request_type TEXT NOT NULL,
    tokens_used INTEGER NOT NULL,
    cost DECIMAL(10, 4) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users (id)
);

-- 创建索引
CREATE INDEX IF NOT EXISTS idx_sessions_user_id ON sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_api_keys_user_id ON api_keys(user_id);
CREATE INDEX IF NOT EXISTS idx_usage_logs_user_id ON usage_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_usage_logs_created_at ON usage_logs(created_at);
EOF

    chown $SERVICE_USER:$SERVICE_USER $INSTALL_DIR/config/claudecode.db
}

# 配置ClaudeCode应用
setup_app() {
    log_info "配置ClaudeCode应用..."

    # 创建应用配置
    cat > $INSTALL_DIR/config/config.py << EOF
import os

class Config:
    # 基础配置
    SECRET_KEY = os.urandom(32)
    DEBUG = False

    # 数据库配置
    DATABASE_PATH = '$INSTALL_DIR/config/claudecode.db'

    # Redis配置
    REDIS_HOST = 'localhost'
    REDIS_PORT = 6379
    REDIS_DB = 0

    # Claude API配置
    CLAUDE_API_KEY = os.getenv('CLAUDE_API_KEY', '')

    # 缓存配置
    CACHE_TYPE = 'redis'
    CACHE_DEFAULT_TIMEOUT = 300

    # 安全配置
    SESSION_COOKIE_SECURE = True
    SESSION_COOKIE_HTTPONLY = True
    SESSION_COOKIE_SAMESITE = 'Lax'

    # 日志配置
    LOG_FILE = '$INSTALL_DIR/logs/app.log'
    LOG_LEVEL = 'INFO'

    # 限制配置
    MAX_REQUESTS_PER_MINUTE = 60
    MAX_TOKENS_PER_REQUEST = 4000
EOF

    # 创建启动脚本
    cat > $INSTALL_DIR/app/start.sh << 'EOF'
#!/bin/bash
cd /opt/claudecode/app
exec gunicorn --bind 127.0.0.1:8080 --workers 4 --timeout 120 app:app
EOF
    chmod +x $INSTALL_DIR/app/start.sh
}

# 配置Nginx
setup_nginx() {
    log_info "配置Nginx..."

    cat > /etc/nginx/sites-available/claudecode << EOF
server {
    listen 80;
    server_name $DOMAIN;

    # 重定向到HTTPS
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name $DOMAIN;

    # SSL配置（将由certbot自动配置）
    ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;

    # 安全头
    add_header Strict-Transport-Security "max-age=31536000" always;
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;

    # 日志
    access_log /var/log/nginx/claudecode_access.log;
    error_log /var/log/nginx/claudecode_error.log;

    # 静态文件
    location /static/ {
        alias $INSTALL_DIR/static/;
        expires 1y;
    }

    # 应用代理
    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;

        # 超时设置
        proxy_connect_timeout 5s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # API限流
    location /api/ {
        limit_req zone=api burst=20 nodelay;
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}

# 限流配置
http {
    limit_req_zone \$binary_remote_addr zone=api:10m rate=10r/s;
}
EOF

    # 启用站点
    ln -sf /etc/nginx/sites-available/claudecode /etc/nginx/sites-enabled/
    rm -f /etc/nginx/sites-enabled/default

    # 测试配置
    nginx -t
    systemctl restart nginx
}

# 配置SSL证书
setup_ssl() {
    log_info "配置SSL证书..."

    # 获取Let's Encrypt证书
    certbot --nginx -d $DOMAIN --non-interactive --agree-tos --email $EMAIL

    # 设置自动续期
    echo "0 12 * * * /usr/bin/certbot renew --quiet" | crontab -
}

# 配置Supervisor
setup_supervisor() {
    log_info "配置Supervisor..."

    cat > /etc/supervisor/conf.d/claudecode.conf << EOF
[program:claudecode]
command=$INSTALL_DIR/app/start.sh
directory=$INSTALL_DIR/app
user=$SERVICE_USER
autostart=true
autorestart=true
redirect_stderr=true
stdout_logfile=$INSTALL_DIR/logs/supervisor.log
stdout_logfile_maxbytes=50MB
stdout_logfile_backups=10
EOF

    supervisorctl reread
    supervisorctl update
    supervisorctl start claudecode
}

# 配置监控
setup_monitoring() {
    log_info "配置基础监控..."

    # 创建监控脚本
    cat > $INSTALL_DIR/scripts/monitor.sh << 'EOF'
#!/bin/bash
# 基础监控脚本

LOG_FILE="/opt/claudecode/logs/monitor.log"

# 检查服务状态
check_service() {
    if ! supervisorctl status claudecode | grep -q "RUNNING"; then
        echo "$(date): ClaudeCode服务异常" >> $LOG_FILE
        supervisorctl restart claudecode
    fi
}

# 检查磁盘空间
check_disk() {
    DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
    if [ $DISK_USAGE -gt 85 ]; then
        echo "$(date): 磁盘空间不足: ${DISK_USAGE}%" >> $LOG_FILE
    fi
}

# 检查内存
check_memory() {
    MEM_USAGE=$(free | grep Mem | awk '{printf "%.2f", $3/$2 * 100.0}')
    if (( $(echo "$MEM_USAGE > 85" | bc -l) )); then
        echo "$(date): 内存使用率过高: ${MEM_USAGE}%" >> $LOG_FILE
    fi
}

# 执行检查
check_service
check_disk
check_memory
EOF
    chmod +x $INSTALL_DIR/scripts/monitor.sh

    # 添加到crontab
    echo "*/5 * * * * $INSTALL_DIR/scripts/monitor.sh" | crontab -
}

# 配置日志轮转
setup_logrotate() {
    log_info "配置日志轮转..."

    cat > /etc/logrotate.d/claudecode << 'EOF'
/opt/claudecode/logs/*.log {
    daily
    missingok
    rotate 30
    compress
    delaycompress
    notifempty
    create 644 claudecode claudecode
    postrotate
        supervisorctl restart claudecode
    endscript
}
EOF
}

# 配置备份
setup_backup() {
    log_info "配置自动备份..."

    # 创建备份脚本
    cat > $INSTALL_DIR/scripts/backup.sh << 'EOF'
#!/bin/bash
# 数据备份脚本

BACKUP_DIR="/opt/backups/claudecode"
DATE=$(date +%Y%m%d_%H%M%S)

# 创建备份目录
mkdir -p $BACKUP_DIR

# 备份数据库
cp /opt/claudecode/config/claudecode.db $BACKUP_DIR/claudecode_$DATE.db

# 备份配置文件
tar -czf $BACKUP_DIR/config_$DATE.tar.gz /opt/claudecode/config/

# 清理30天前的备份
find $BACKUP_DIR -name "*.db" -mtime +30 -delete
find $BACKUP_DIR -name "*.tar.gz" -mtime +30 -delete
EOF
    chmod +x $INSTALL_DIR/scripts/backup.sh

    # 添加到crontab（每天凌晨2点备份）
    (crontab -l 2>/dev/null; echo "0 2 * * * $INSTALL_DIR/scripts/backup.sh") | crontab -
}

# 创建管理脚本
create_management_scripts() {
    log_info "创建管理脚本..."

    # 服务管理脚本
    cat > /usr/local/bin/claudecode << 'EOF'
#!/bin/bash
case "$1" in
    start)
        supervisorctl start claudecode
        ;;
    stop)
        supervisorctl stop claudecode
        ;;
    restart)
        supervisorctl restart claudecode
        ;;
    status)
        supervisorctl status claudecode
        ;;
    logs)
        tail -f /opt/claudecode/logs/app.log
        ;;
    *)
        echo "用法: claudecode {start|stop|restart|status|logs}"
        exit 1
        ;;
esac
EOF
    chmod +x /usr/local/bin/claudecode

    # 健康检查脚本
    cat > /usr/local/bin/claudecode-health << 'EOF'
#!/bin/bash
echo "=== ClaudeCode健康检查 ==="
echo

# 检查服务状态
echo -n "服务状态: "
if supervisorctl status claudecode | grep -q "RUNNING"; then
    echo "✅ 运行中"
else
    echo "❌ 已停止"
fi

# 检查端口
echo -n "端口8080: "
if netstat -tuln | grep -q ":8080 "; then
    echo "✅ 监听中"
else
    echo "❌ 未监听"
fi

# 检查Redis
echo -n "Redis服务: "
if systemctl is-active --quiet redis-server; then
    echo "✅ 运行中"
else
    echo "❌ 已停止"
fi

# 检查磁盘
DISK=$(df / | awk 'NR==2 {print $5}')
echo "磁盘使用: $DISK"

# 检查内存
MEM=$(free | grep Mem | awk '{printf "%.1f%%", $3/$2 * 100.0}')
echo "内存使用: $MEM"

echo
echo "最近的日志:"
tail -5 /opt/claudecode/logs/app.log
EOF
    chmod +x /usr/local/bin/claudecode-health
}

# 显示部署信息
show_info() {
    log_info "🎉 部署完成！"
    echo
    echo "访问地址: https://$DOMAIN"
    echo "管理命令:"
    echo "  claudecode start    - 启动服务"
    echo "  claudecode stop     - 停止服务"
    echo "  claudecode restart  - 重启服务"
    echo "  claudecode status   - 查看状态"
    echo "  claudecode logs     - 查看日志"
    echo "  claudecode-health   - 健康检查"
    echo
    echo "重要文件:"
    echo "  配置文件: $INSTALL_DIR/config/config.py"
    echo "  数据库: $INSTALL_DIR/config/claudecode.db"
    echo "  日志目录: $INSTALL_DIR/logs/"
    echo "  备份目录: /opt/backups/claudecode/"
    echo
    echo "下一步:"
    echo "  1. 设置环境变量 CLAUDE_API_KEY"
    echo "  2. 创建管理员账户"
    echo "  3. 配置邮件服务（可选）"
}

# 主函数
main() {
    # 检查权限
    if [ "$EUID" -ne 0 ]; then
        log_error "请使用root用户运行"
        exit 1
    fi

    # 检查域名
    if [ "$DOMAIN" = "your-domain.com" ]; then
        log_error "请修改脚本中的DOMAIN变量为实际域名"
        exit 1
    fi

    # 执行安装
    install_system_deps
    setup_user
    setup_redis
    setup_database
    setup_app
    setup_nginx
    setup_ssl
    setup_supervisor
    setup_monitoring
    setup_logrotate
    setup_backup
    create_management_scripts
    show_info
}

# 执行主函数
main "$@"
```

## 配置文件模板

### 应用配置

```python
# config.py - 生产环境配置
import os

class ProductionConfig:
    """生产环境配置"""

    # 基础配置
    SECRET_KEY = os.environ.get('SECRET_KEY', os.urandom(32))
    DEBUG = False
    TESTING = False

    # 服务器配置
    HOST = '127.0.0.1'
    PORT = 8080

    # 数据库配置
    DATABASE_PATH = os.environ.get('DB_PATH', '/opt/claudecode/config/claudecode.db')

    # Redis配置
    REDIS_HOST = os.environ.get('REDIS_HOST', 'localhost')
    REDIS_PORT = int(os.environ.get('REDIS_PORT', 6379))
    REDIS_DB = int(os.environ.get('REDIS_DB', 0))
    REDIS_PASSWORD = os.environ.get('REDIS_PASSWORD')

    # Claude API配置
    CLAUDE_API_KEY = os.environ.get('CLAUDE_API_KEY')
    CLAUDE_API_BASE = 'https://api.anthropic.com'

    # 缓存配置
    CACHE_TYPE = 'redis'
    CACHE_DEFAULT_TIMEOUT = 300
    CACHE_REDIS_URL = f'redis://:{REDIS_PASSWORD}@{REDIS_HOST}:{REDIS_PORT}/{REDIS_DB}' if REDIS_PASSWORD else f'redis://{REDIS_HOST}:{REDIS_PORT}/{REDIS_DB}'

    # 安全配置
    SESSION_COOKIE_SECURE = True
    SESSION_COOKIE_HTTPONLY = True
    SESSION_COOKIE_SAMESITE = 'Lax'
    PERMANENT_SESSION_LIFETIME = 86400  # 24小时

    # API限制
    RATE_LIMIT_STORAGE_URL = CACHE_REDIS_URL
    RATE_LIMIT_DEFAULT = "60 per minute"

    # 文件上传配置
    MAX_CONTENT_LENGTH = 16 * 1024 * 1024  # 16MB
    UPLOAD_FOLDER = '/opt/claudecode/uploads'

    # 日志配置
    LOG_LEVEL = 'INFO'
    LOG_FILE = '/opt/claudecode/logs/app.log'
    LOG_MAX_BYTES = 10 * 1024 * 1024  # 10MB
    LOG_BACKUP_COUNT = 5

    # 邮件配置（可选）
    MAIL_SERVER = os.environ.get('MAIL_SERVER')
    MAIL_PORT = int(os.environ.get('MAIL_PORT', 587))
    MAIL_USE_TLS = os.environ.get('MAIL_USE_TLS', 'true').lower() == 'true'
    MAIL_USERNAME = os.environ.get('MAIL_USERNAME')
    MAIL_PASSWORD = os.environ.get('MAIL_PASSWORD')

    # 监控配置
    ENABLE_METRICS = True
    METRICS_PORT = 9090

class DevelopmentConfig(ProductionConfig):
    """开发环境配置"""
    DEBUG = True
    LOG_LEVEL = 'DEBUG'

class TestingConfig(ProductionConfig):
    """测试环境配置"""
    TESTING = True
    DATABASE_PATH = ':memory:'
    WTF_CSRF_ENABLED = False

# 配置字典
config = {
    'development': DevelopmentConfig,
    'production': ProductionConfig,
    'testing': TestingConfig,
    'default': ProductionConfig
}
```

### 环境变量配置

```bash
# .env - 环境变量配置文件
# 复制此文件为 .env 并填写实际值

# Claude API密钥（必需）
CLAUDE_API_KEY=your-claude-api-key-here

# 安全密钥（自动生成，无需修改）
SECRET_KEY=

# 数据库路径（可选，默认为配置中的值）
DB_PATH=

# Redis配置（可选，如果Redis不在本机）
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_DB=0
REDIS_PASSWORD=

# 邮件服务配置（可选）
MAIL_SERVER=smtp.gmail.com
MAIL_PORT=587
MAIL_USE_TLS=true
MAIL_USERNAME=your-email@gmail.com
MAIL_PASSWORD=your-app-password

# 其他配置
FLASK_ENV=production
```

## Docker部署（可选）

### Dockerfile

```dockerfile
FROM python:3.9-slim

# 设置工作目录
WORKDIR /app

# 安装系统依赖
RUN apt-get update && apt-get install -y \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# 复制requirements文件
COPY requirements.txt .

# 安装Python依赖
RUN pip install --no-cache-dir -r requirements.txt

# 复制应用代码
COPY . .

# 创建非root用户
RUN useradd -m -u 1000 appuser && chown -R appuser:appuser /app
USER appuser

# 暴露端口
EXPOSE 8080

# 启动命令
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "--workers", "4", "app:app"]
```

### docker-compose.yml

```yaml
version: '3.8'

services:
  app:
    build: .
    ports:
      - "8080:8080"
    environment:
      - FLASK_ENV=production
      - REDIS_HOST=redis
    volumes:
      - ./data:/app/data
      - ./logs:/app/logs
    depends_on:
      - redis
    restart: unless-stopped

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    restart: unless-stopped

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./ssl:/etc/ssl:ro
    depends_on:
      - app
    restart: unless-stopped

volumes:
  redis_data:
```

## 快速开始指南

### 1. 准备工作

```bash
# 更新系统
sudo apt update && sudo apt upgrade -y

# 设置域名（修改为您自己的域名）
DOMAIN=claude.yourcompany.com
EMAIL=admin@yourcompany.com
```

### 2. 运行部署脚本

```bash
# 下载并运行部署脚本
wget https://raw.githubusercontent.com/your-repo/startup-deploy.sh
chmod +x startup-deploy.sh
sudo ./startup-deploy.sh
```

### 3. 配置API密钥

```bash
# 设置Claude API密钥
export CLAUDE_API_KEY="your-actual-api-key"
echo 'export CLAUDE_API_KEY="your-actual-api-key"' >> ~/.bashrc
```

### 4. 创建管理员账户

```bash
# 使用CLI工具创建管理员
sudo -u claudecode python3 /opt/claudecode/app/create_admin.py
```

### 5. 验证部署

```bash
# 检查服务状态
claudecode status

# 查看健康状态
claudecode-health

# 访问应用
curl https://your-domain.com/health
```

## 成本优化建议

### 1. 服务器选择

- **推荐配置**: 2核CPU, 4GB内存, 50GB SSD
- **云服务选择**:
  - AWS: t3.medium (约 $30/月)
  - 阿里云: ecs.c6.large (约 ¥150/月)
  - 腾讯云: S5.MEDIUM4 (约 ¥130/月)

### 2. 优化措施

- **启用Gzip压缩**: 减少70%带宽使用
- **配置CDN**: 降低服务器负载
- **使用Redis缓存**: 减少API调用
- **启用HTTP/2**: 提升加载速度
- **定期清理日志**: 避免磁盘占满

### 3. 监控告警

```bash
# 设置磁盘使用告警（90%）
echo "0 6 * * * df / | awk 'NR==2 {if (\$5+0 > 90) system(\"mail -s \"Disk Alert\" admin@yourdomain.com\")}" | crontab -

# 设置内存使用告警
echo "0 */4 * * * free | awk 'NR==2{if (\$3/\$2 > 0.9) system(\"mail -s \"Memory Alert\" admin@yourdomain.com\")}" | crontab -
```

## 故障排查

### 常见问题

1. **服务无法启动**
   ```bash
   # 查看详细错误
   supervisorctl tail -f claudecode

   # 检查配置
   python3 -c "from config import config; print(config['default'])"
   ```

2. **SSL证书问题**
   ```bash
   # 手动续期
   certbot renew --dry-run

   # 强制续期
   certbot renew --force-renewal
   ```

3. **数据库锁定**
   ```bash
   # 检查进程
   lsof /opt/claudecode/config/claudecode.db

   # 重启服务
   supervisorctl restart claudecode
   ```

4. **Redis连接失败**
   ```bash
   # 检查Redis状态
   systemctl status redis-server

   # 测试连接
   redis-cli ping
   ```

### 应急处理

```bash
# 快速重启所有服务
systemctl restart nginx redis-server
supervisorctl restart claudecode

# 清理临时文件
rm -rf /tmp/claudecode-*
rm -rf /opt/claudecode/logs/*.log.old

# 恢复备份（如果需要）
cp /opt/backups/claudecode/claudecode_latest.db /opt/claudecode/config/claudecode.db
```