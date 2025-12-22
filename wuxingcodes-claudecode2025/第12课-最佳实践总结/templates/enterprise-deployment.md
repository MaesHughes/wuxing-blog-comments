# 企业级部署模板

## 部署架构

```
┌─────────────────────────────────────────────────┐
│                   负载均衡层                      │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  │
│  │   Nginx     │  │    HAProxy  │  │   F5        │  │
│  │  (SSL终结)   │  │  (健康检查)  │  │  (高级)     │  │
│  └─────────────┘  └─────────────┘  └─────────────┘  │
└─────────────────────────────────────────────────┘
                        │
┌─────────────────────────────────────────────────┐
│                   应用服务层                      │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  │
│  │ ClaudeCode  │  │ ClaudeCode  │  │ ClaudeCode  │  │
│  │   节点1      │  │   节点2      │  │   节点N      │  │
│  └─────────────┘  └─────────────┘  └─────────────┘  │
└─────────────────────────────────────────────────┘
                        │
┌─────────────────────────────────────────────────┐
│                   缓存层                         │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  │
│  │    Redis    │  │  Memcached  │  │  本地缓存    │  │
│  │   (主)      │  │   (辅助)    │  │  (L1)       │  │
│  └─────────────┘  └─────────────┘  └─────────────┘  │
└─────────────────────────────────────────────────┘
                        │
┌─────────────────────────────────────────────────┐
│                   数据层                         │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  │
│  │ PostgreSQL  │  │   MongoDB   │  │  文件存储    │  │
│  │  (主从)     │  │  (分片)     │  │  (MinIO)    │  │
│  └─────────────┘  └─────────────┘  └─────────────┘  │
└─────────────────────────────────────────────────┘
```

## 配置模板

### 生产环境配置

```json
{
  "environment": "production",
  "cluster": {
    "name": "claudecode-enterprise",
    "nodes": [
      {
        "id": "node-01",
        "host": "10.0.1.10",
        "port": 8080,
        "region": "us-east-1a",
        "zone": "primary"
      },
      {
        "id": "node-02",
        "host": "10.0.1.11",
        "port": 8080,
        "region": "us-east-1b",
        "zone": "secondary"
      }
    ]
  },
  "load_balancer": {
    "type": "nginx",
    "ssl": {
      "enabled": true,
      "certificate": "/etc/ssl/certs/claudecode.crt",
      "private_key": "/etc/ssl/private/claudecode.key"
    },
    "health_check": {
      "path": "/health",
      "interval": 10,
      "timeout": 5,
      "unhealthy_threshold": 3,
      "healthy_threshold": 2
    }
  },
  "security": {
    "authentication": {
      "type": "oauth2",
      "provider": "enterprise-sso",
      "client_id": "claudecode-enterprise",
      "issuer_url": "https://sso.company.com"
    },
    "authorization": {
      "rbac": {
        "enabled": true,
        "roles": ["admin", "developer", "viewer"],
        "policies": "config/rbac.yaml"
      }
    },
    "encryption": {
      "at_rest": {
        "enabled": true,
        "algorithm": "AES-256-GCM",
        "key_id": "arn:aws:kms:us-east-1:123456789012:key/abcd"
      },
      "in_transit": {
        "enabled": true,
        "tls_version": "1.3",
        "cipher_suites": ["TLS_AES_256_GCM_SHA384"]
      }
    }
  },
  "performance": {
    "cache": {
      "redis": {
        "cluster": "redis-cluster-prod",
        "ttl": 3600,
        "max_connections": 100
      },
      "local": {
        "enabled": true,
        "size": "1GB",
        "policy": "lru"
      }
    },
    "connection_pool": {
      "max_connections": 500,
      "idle_timeout": 60000,
      "max_lifetime": 1800000
    },
    "rate_limiting": {
      "enabled": true,
      "requests_per_minute": 1000,
      "burst_size": 100
    }
  },
  "monitoring": {
    "metrics": {
      "prometheus": {
        "enabled": true,
        "endpoint": "/metrics",
        "port": 9090
      }
    },
    "tracing": {
      "jaeger": {
        "enabled": true,
        "endpoint": "http://jaeger-collector:14268/api/traces"
      }
    },
    "logging": {
      "level": "info",
      "format": "json",
      "outputs": [
        {
          "type": "elasticsearch",
          "endpoint": "http://elasticsearch:9200",
          "index": "claudecode-enterprise"
        }
      ]
    }
  },
  "backup": {
    "enabled": true,
    "schedule": "0 2 * * *",
    "retention": 30,
    "storage": {
      "type": "s3",
      "bucket": "claudecode-backups",
      "prefix": "enterprise/"
    }
  }
}
```

### Nginx负载均衡配置

```nginx
upstream claudecode_backend {
    least_conn;
    server 10.0.1.10:8080 max_fails=3 fail_timeout=30s;
    server 10.0.1.11:8080 max_fails=3 fail_timeout=30s;
    server 10.0.1.12:8080 max_fails=3 fail_timeout=30s;

    # 保持连接
    keepalive 32;
}

# HTTP重定向到HTTPS
server {
    listen 80;
    server_name claudecode.company.com;
    return 301 https://$server_name$request_uri;
}

# HTTPS主配置
server {
    listen 443 ssl http2;
    server_name claudecode.company.com;

    # SSL配置
    ssl_certificate /etc/ssl/certs/claudecode.crt;
    ssl_certificate_key /etc/ssl/private/claudecode.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512;
    ssl_prefer_server_ciphers off;

    # 安全头
    add_header Strict-Transport-Security "max-age=63072000" always;
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";

    # 日志
    access_log /var/log/nginx/claudecode_access.log;
    error_log /var/log/nginx/claudecode_error.log;

    # 限流
    limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;

    location / {
        limit_req zone=api burst=20 nodelay;

        proxy_pass http://claudecode_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # 超时设置
        proxy_connect_timeout 5s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # 健康检查
    location /health {
        proxy_pass http://claudecode_backend;
        access_log off;
    }

    # 静态文件
    location /static/ {
        alias /var/www/claudecode/static/;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

### Docker Compose配置

```yaml
version: '3.8'

services:
  claudecode-1:
    image: claudecode:enterprise
    hostname: claudecode-1
    environment:
      - CLAUDE_CONFIG_DIR=/config
      - CLAUDE_NODE_ID=node-01
      - CLAUDE_CLUSTER_NAME=claudecode-enterprise
    volumes:
      - ./config:/config:ro
      - ./logs:/app/logs
    networks:
      - claudecode-network
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 4G
        reservations:
          cpus: '1'
          memory: 2G
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  claudecode-2:
    image: claudecode:enterprise
    hostname: claudecode-2
    environment:
      - CLAUDE_CONFIG_DIR=/config
      - CLAUDE_NODE_ID=node-02
      - CLAUDE_CLUSTER_NAME=claudecode-enterprise
    volumes:
      - ./config:/config:ro
      - ./logs:/app/logs
    networks:
      - claudecode-network
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 4G
        reservations:
          cpus: '1'
          memory: 2G
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  redis:
    image: redis:7-alpine
    hostname: redis
    command: redis-server --appendonly yes --cluster-enabled yes
    volumes:
      - redis-data:/data
    networks:
      - claudecode-network
    deploy:
      resources:
        limits:
          cpus: '1'
          memory: 2G

  postgres:
    image: postgres:15
    hostname: postgres
    environment:
      POSTGRES_DB: claudecode
      POSTGRES_USER: claudecode
      POSTGRES_PASSWORD_FILE: /run/secrets/db_password
    volumes:
      - postgres-data:/var/lib/postgresql/data
    networks:
      - claudecode-network
    secrets:
      - db_password

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./ssl:/etc/ssl:ro
    networks:
      - claudecode-network
    depends_on:
      - claudecode-1
      - claudecode-2

  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./monitoring/prometheus.yml:/etc/prometheus/prometheus.yml:ro
      - prometheus-data:/prometheus
    networks:
      - claudecode-network

  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    environment:
      GF_SECURITY_ADMIN_PASSWORD_FILE: /run/secrets/grafana_password
    volumes:
      - grafana-data:/var/lib/grafana
      - ./monitoring/grafana/dashboards:/etc/grafana/provisioning/dashboards:ro
    networks:
      - claudecode-network
    secrets:
      - grafana_password

networks:
  claudecode-network:
    driver: bridge

volumes:
  redis-data:
  postgres-data:
  prometheus-data:
  grafana-data:

secrets:
  db_password:
    file: ./secrets/db_password.txt
  grafana_password:
    file: ./secrets/grafana_password.txt
```

## Kubernetes部署清单

### Namespace

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: claudecode
  labels:
    name: claudecode
```

### Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: claudecode
  namespace: claudecode
  labels:
    app: claudecode
spec:
  replicas: 3
  selector:
    matchLabels:
      app: claudecode
  template:
    metadata:
      labels:
        app: claudecode
    spec:
      containers:
      - name: claudecode
        image: claudecode:enterprise
        ports:
        - containerPort: 8080
        env:
        - name: CLAUDE_CONFIG_DIR
          value: "/config"
        - name: CLAUDE_NODE_ID
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        volumeMounts:
        - name: config
          mountPath: /config
          readOnly: true
        - name: logs
          mountPath: /app/logs
        resources:
          requests:
            cpu: "1"
            memory: "2Gi"
          limits:
            cpu: "2"
            memory: "4Gi"
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
      volumes:
      - name: config
        configMap:
          name: claudecode-config
      - name: logs
        emptyDir: {}
```

### Service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: claudecode-service
  namespace: claudecode
spec:
  selector:
    app: claudecode
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080
  type: ClusterIP
```

### Ingress

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: claudecode-ingress
  namespace: claudecode
  annotations:
    kubernetes.io/ingress.class: nginx
    cert-manager.io/cluster-issuer: letsencrypt-prod
    nginx.ingress.kubernetes.io/rate-limit: "100"
spec:
  tls:
  - hosts:
    - claudecode.company.com
    secretName: claudecode-tls
  rules:
  - host: claudecode.company.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: claudecode-service
            port:
              number: 80
```

## 运维检查清单

### 部署前检查

- [ ] 硬件资源满足最低要求
- [ ] 网络端口已开放
- [ ] SSL证书已申请
- [ ] DNS记录已配置
- [ ] 备份策略已制定
- [ ] 监控系统已部署
- [ ] 日志收集已配置
- [ ] 安全策略已审核

### 部署后验证

- [ ] 服务健康检查通过
- [ ] 负载均衡正常工作
- [ ] SSL证书有效
- [ ] 认证授权正常
- [ ] 监控指标正常
- [ ] 日志输出正常
- [ ] 备份任务执行
- [ ] 性能基线建立

### 日常运维

- [ ] 每日健康检查
- [ ] 每周性能评估
- [ ] 每月安全扫描
- [ ] 季度灾难演练
- [ ] 年度架构评估

## 故障处理手册

### 服务不可用

1. 检查服务状态
   ```bash
   kubectl get pods -n claudecode
   kubectl logs -f deployment/claudecode -n claudecode
   ```

2. 查看资源使用
   ```bash
   kubectl top pods -n claudecode
   kubectl describe nodes
   ```

3. 重启服务
   ```bash
   kubectl rollout restart deployment/claudecode -n claudecode
   ```

### 性能问题

1. 查看指标
   - Prometheus: CPU、内存、响应时间
   - Grafana: 性能趋势图
   - 日志: 错误和慢请求

2. 扩容处理
   ```bash
   kubectl scale deployment claudecode --replicas=5 -n claudecode
   ```

### 安全事件

1. 隔离受影响节点
2. 分析安全日志
3. 更新安全策略
4. 恢复服务运行