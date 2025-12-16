# MCP服务器配置模板集

## 1. 基础配置模板

### SQLite MCP服务器配置

```json
{
  "mcpServers": {
    "sqlite": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-sqlite",
        "./database/myapp.db"
      ],
      "env": {
        "NODE_ENV": "production"
      }
    }
  }
}
```

### PostgreSQL MCP服务器配置

```json
{
  "mcpServers": {
    "postgres": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-postgres",
        "postgresql://username:password@localhost:5432/mydatabase"
      ],
      "env": {
        "PG_SSL": "true",
        "PG_POOL_SIZE": "10"
      }
    }
  }
}
```

## 2. API集成配置模板

### 基础API服务器配置

```json
{
  "mcpServers": {
    "weather-api": {
      "command": "node",
      "args": ["./servers/weather-api-server.js"],
      "env": {
        "WEATHER_API_KEY": "your-api-key-here",
        "API_TIMEOUT": "5000",
        "CACHE_TTL": "300"
      }
    }
  }
}
```

### OAuth2 API服务器配置

```json
{
  "mcpServers": {
    "oauth-api": {
      "command": "node",
      "args": ["./servers/oauth-api-server.js"],
      "env": {
        "CLIENT_ID": "your-client-id",
        "CLIENT_SECRET": "your-client-secret",
        "TOKEN_URL": "https://api.example.com/oauth2/token",
        "SCOPES": "read,write"
      }
    }
  }
}
```

## 3. 文件系统配置模板

### 本地文件系统配置

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "/workspace"
      ],
      "env": {
        "ALLOWED_PATHS": "/workspace,/tmp",
        "BLOCKED_PATHS": "/etc,/var,/usr"
      }
    }
  }
}
```

### S3存储配置

```json
{
  "mcpServers": {
    "s3-storage": {
      "command": "node",
      "args": ["./servers/s3-server.js"],
      "env": {
        "AWS_ACCESS_KEY_ID": "your-access-key",
        "AWS_SECRET_ACCESS_KEY": "your-secret-key",
        "AWS_REGION": "us-east-1",
        "S3_BUCKET": "my-bucket-name"
      }
    }
  }
}
```

## 4. 高级配置模板

### 带缓存的配置

```json
{
  "mcpServers": {
    "cached-api": {
      "command": "node",
      "args": ["./servers/cached-api-server.js"],
      "env": {
        "REDIS_HOST": "localhost",
        "REDIS_PORT": "6379",
        "CACHE_TTL": "300",
        "CACHE_MAX_SIZE": "1000"
      }
    }
  },
  "global": {
    "cache": {
      "enabled": true,
      "type": "redis",
      "ttl": 300
    }
  }
}
```

### 生产环境配置

```json
{
  "mcpServers": {
    "production-db": {
      "command": "node",
      "args": ["./servers/production-db.js"],
      "env": {
        "NODE_ENV": "production",
        "DB_HOST": "prod-db.example.com",
        "DB_PORT": "5432",
        "DB_NAME": "production_db",
        "DB_USER": "app_user",
        "DB_PASSWORD": "${DB_PASSWORD}",
        "DB_SSL": "true",
        "DB_POOL_MIN": "10",
        "DB_POOL_MAX": "50",
        "DB_TIMEOUT": "30000"
      }
    }
  },
  "security": {
    "allowedCommands": ["node"],
    "maxExecutionTime": 30000,
    "memoryLimit": "1GB",
    "sandbox": true
  },
  "monitoring": {
    "enabled": true,
    "metrics": true,
    "logging": {
      "level": "info",
      "format": "json"
    }
  }
}
```

## 5. 环境变量模板

### .env 文件示例

```bash
# 数据库配置
DB_HOST=localhost
DB_PORT=5432
DB_NAME=mydatabase
DB_USER=myuser
DB_PASSWORD=mypassword

# API配置
WEATHER_API_KEY=your-weather-api-key
API_TIMEOUT=5000

# AWS配置
AWS_ACCESS_KEY_ID=your-aws-access-key
AWS_SECRET_ACCESS_KEY=your-aws-secret-key
AWS_REGION=us-east-1

# OAuth2配置
CLIENT_ID=your-client-id
CLIENT_SECRET=your-client-secret

# 缓存配置
REDIS_HOST=localhost
REDIS_PORT=6379
CACHE_TTL=300

# 安全配置
JWT_SECRET=your-jwt-secret-key
ENCRYPTION_KEY=your-encryption-key

# 监控配置
SENTRY_DSN=your-sentry-dsn
```

## 6. Docker配置模板

### Dockerfile for MCP Server

```dockerfile
FROM node:18-alpine

WORKDIR /app

# 复制package文件
COPY package*.json ./

# 安装依赖
RUN npm ci --only=production

# 复制源代码
COPY . .

# 创建非root用户
RUN addgroup -g 1001 -S nodejs
RUN adduser -S mcpuser -u 1001

# 更改文件所有权
RUN chown -R mcpuser:nodejs /app
USER mcpuser

# 暴露端口（如果有HTTP服务）
EXPOSE 3000

# 启动命令
CMD ["node", "server.js"]
```

### docker-compose.yml

```yaml
version: '3.8'

services:
  mcp-server:
    build: .
    env_file: .env
    ports:
      - "3000:3000"
    depends_on:
      - postgres
      - redis
    networks:
      - mcp-network

  postgres:
    image: postgres:15
    environment:
      POSTGRES_DB: mydatabase
      POSTGRES_USER: myuser
      POSTGRES_PASSWORD: mypassword
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - mcp-network

  redis:
    image: redis:7-alpine
    networks:
      - mcp-network

volumes:
  postgres_data:

networks:
  mcp-network:
    driver: bridge
```

## 7. Kubernetes配置模板

### MCP Server Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mcp-server
spec:
  replicas: 3
  selector:
    matchLabels:
      app: mcp-server
  template:
    metadata:
      labels:
        app: mcp-server
    spec:
      containers:
      - name: mcp-server
        image: mcp-server:latest
        ports:
        - containerPort: 3000
        env:
        - name: DB_HOST
          value: "postgres-service"
        - name: REDIS_HOST
          value: "redis-service"
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  name: mcp-server-service
spec:
  selector:
    app: mcp-server
  ports:
  - protocol: TCP
    port: 80
    targetPort: 3000
  type: ClusterIP
```

## 8. 监控配置模板

### Prometheus配置

```yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'mcp-server'
    static_configs:
      - targets: ['mcp-server:3000']
    metrics_path: '/metrics'
    scrape_interval: 5s
```

### Grafana Dashboard配置

```json
{
  "dashboard": {
    "title": "MCP Server Monitoring",
    "panels": [
      {
        "title": "Request Rate",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(mcp_requests_total[5m])",
            "legendFormat": "Requests/sec"
          }
        ]
      },
      {
        "title": "Response Time",
        "type": "graph",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, rate(mcp_request_duration_seconds_bucket[5m]))",
            "legendFormat": "95th percentile"
          }
        ]
      },
      {
        "title": "Error Rate",
        "type": "singlestat",
        "targets": [
          {
            "expr": "rate(mcp_errors_total[5m])",
            "legendFormat": "Errors/sec"
          }
        ]
      }
    ]
  }
}
```