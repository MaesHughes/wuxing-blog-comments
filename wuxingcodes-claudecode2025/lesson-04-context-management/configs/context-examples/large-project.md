# 大型项目 - ClaudeCode上下文配置示例

## 项目概述

**项目名称**：企业级电商平台
**项目类型**：微服务架构 + 多端应用
**项目描述**：支持Web、移动端、小程序的B2C电商平台
**开始日期**：2023-06-01
**团队规模**：50人+
**项目规模**：200+ 微服务

## 技术栈

### 前端技术栈
- **Web端**：React 18 + TypeScript + Ant Design Pro
- **移动端**：React Native + TypeScript
- **小程序**：Taro 3 + TypeScript
- **管理后台**：Vue 3 + TypeScript + Element Plus
- **构建工具**：Webpack 5 / Vite
- **状态管理**：Redux Toolkit / Pinia / Zustand
- **UI库**：Ant Design / Element Plus / Vant
- **图表库**：ECharts / Chart.js
- **地图服务**：高德地图 / 百度地图

### 后端技术栈
- **语言**：Java 17 / Go 1.19 / Python 3.9
- **框架**：Spring Boot 3 / Gin / FastAPI
- **微服务**：Spring Cloud Alibaba / gRPC
- **消息队列**：Kafka / RocketMQ
- **搜索引擎**：Elasticsearch 8
- **缓存**：Redis 7 / Memcached
- **数据库**：MySQL 8 / PostgreSQL 14 / MongoDB 6
- **容器化**：Docker / Kubernetes
- **服务网格**：Istio
- **API网关**：Spring Gateway / Kong

### 基础设施
- **容器编排**：Kubernetes 1.27
- **CI/CD**：GitLab CI / Jenkins
- **监控**：Prometheus + Grafana
- **日志**：ELK Stack
- **链路追踪**：Jaeger
- **配置中心**：Nacos / Apollo
- **服务发现**：Nacos / Consul
- **负载均衡**：Nginx / HAProxy

## 项目架构

### 微服务划分

```
电商平台/
├── 用户中心服务 (user-center)
├── 商品中心服务 (product-center)
├── 订单中心服务 (order-center)
├── 支付中心服务 (payment-center)
├── 库存中心服务 (inventory-center)
├── 营销中心服务 (marketing-center)
├── 消息中心服务 (message-center)
├── 搜索中心服务 (search-center)
├── 数据中心服务 (data-center)
├── 风控中心服务 (risk-control)
└── 运营管理服务 (operation-center)
```

### 代码组织

```
each-service/
├── src/
│   ├── main/              # 主程序
│   │   ├── controller/    # 控制器层
│   │   ├── service/       # 业务层
│   │   ├── repository/    # 数据访问层
│   │   ├── entity/        # 实体类
│   │   ├── dto/          # 数据传输对象
│   │   └── config/       # 配置类
│   ├── domain/           # 领域模型
│   ├── infrastructure/    # 基础设施
│   ├── application/      # 应用服务
│   └── common/           # 公共代码
├── tests/                 # 测试代码
├── docs/                  # 文档
├── scripts/               # 脚本
├── docker/                # Docker配置
└── k8s/                   # Kubernetes配置
```

## 开发规范

### 代码规范

#### Java开发规范
```java
// 包命名规范
com.company.project.module.function

// 类命名规范
UserService          // 服务类
UserRepository        // 仓储类
UserController       // 控制器类
UserDTO              // 数据传输对象
UserEntity           // 实体类

// 方法命名规范
findUserById()        // 查找
createUser()          // 创建
updateUser()          // 更新
deleteUser()          // 删除

// 常量命名规范
public static final String API_BASE_URL = "https://api.example.com";
```

#### TypeScript开发规范
```typescript
// 接口命名
interface User {
  id: string;
  name: string;
  email: string;
}

// 类型别名
type UserID = string;
type OrderStatus = 'pending' | 'processing' | 'completed';

// 枚举
enum UserRole {
  ADMIN = 'admin',
  USER = 'user',
  GUEST = 'guest'
}
```

### API设计规范

#### RESTful API
```
GET    /api/v1/users          # 获取用户列表
GET    /api/v1/users/{id}     # 获取单个用户
POST   /api/v1/users          # 创建用户
PUT    /api/v1/users/{id}     # 更新用户
DELETE /api/v1/users/{id}     # 删除用户

// 查询参数
GET /api/v1/users?page=1&size=20&sort=createdAt:desc

// 响应格式
{
  "code": 200,
  "message": "success",
  "data": {
    "list": [...],
    "total": 100,
    "page": 1,
    "size": 20
  }
}
```

### 数据库规范

#### 表设计
```sql
-- 表名：user
CREATE TABLE user (
  id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键',
  user_id VARCHAR(64) UNIQUE NOT NULL COMMENT '用户ID',
  username VARCHAR(50) NOT NULL COMMENT '用户名',
  email VARCHAR(100) UNIQUE NOT NULL COMMENT '邮箱',
  phone VARCHAR(20) COMMENT '手机号',
  avatar VARCHAR(255) COMMENT '头像',
  status TINYINT DEFAULT 1 COMMENT '状态：1正常 0禁用',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  deleted_at TIMESTAMP NULL COMMENT '删除时间',
  INDEX idx_username (username),
  INDEX idx_email (email),
  INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';
```

## 项目配置

### 分层配置原则

#### 1. 环境配置
- 开发环境（development）
- 测试环境（test）
- 预发布环境（staging）
- 生产环境（production）

#### 2. 配置管理
- 使用配置中心集中管理
- 敏感信息使用加密存储
- 支持动态配置更新

#### 3. 服务配置
```yaml
# application.yml
server:
  port: 8080
  servlet:
    context-path: /api

spring:
  profiles:
    active: ${SPRING_PROFILES_ACTIVE:dev}

  cloud:
    nacos:
      discovery:
        server-addr: ${NACOS_SERVER:localhost:8848}
      config:
        server-addr: ${NACOS_SERVER:localhost:8848}
        file-extension: yml
```

## ClaudeCode集成

### 项目理解提示词

```
请分析这个大型电商项目：
1. 微服务架构设计和依赖关系
2. 技术栈选型的合理性
3. 代码组织和分层架构
4. 性能瓶颈和优化点
5. 安全风险评估和改进建议
```

### 代码生成提示词

```
创建一个新的微服务：积分中心服务
要求：
1. 使用Spring Boot 3 + JPA
2. 包含用户积分增删改查
3. 支持积分历史记录
4. 集成Redis缓存
5. 提供RESTful API
6. 包含完整的单元测试
```

### 问题排查提示词

```
排查订单服务超时问题：
1. 分析订单创建流程中的性能瓶颈
2. 检查数据库慢查询
3. 分析外部服务调用链路
4. 提供优化建议
```

### 架构设计提示词

```
设计一个高并发秒杀系统：
- 限流和熔断机制
- 缓存策略设计
- 数据库优化方案
- 消息队列应用
- 分布式事务处理
```

## 常用命令

### 开发命令
```bash
# 本地开发
mvn clean install
mvn spring-boot:run

# 构建打包
mvn clean package -DskipTests

# Docker构建
docker build -t app .

# Kubernetes部署
kubectl apply -f k8s/
```

### 测试命令
```bash
# 运行测试
mvn test

# 生成测试报告
mvn jacoco:report

# 性能测试
jmeter -n 100 -t 5 -J test.jmx
```

## 团队协作

### Git工作流
1. 功能分支：feature/xxx
2. 开发完成后创建PR
3. 代码审查通过后合并
4. 自动触发CI/CD

### Code Review要点
- 代码规范性
- 性能考虑
- 安全检查
- 测试覆盖率
- 文档完整性

### 版本发布
1. 制定发布计划
2. 创建发布标签
3. 部署到测试环境
4. 执行回归测试
5. 部署到生产环境
6. 发布后监控

## 性能优化

### 后端优化
1. 数据库索引优化
2. SQL查询优化
3. Redis缓存策略
4. 连接池配置
5. JVM调优

### 前端优化
1. 代码分割和懒加载
2. 图片压缩和CDN
3. 首屏渲染优化
4. Bundle大小优化

### 系统优化
1. 负载均衡配置
2. 缓存架构设计
3. 数据库分库分表
4. 消息队列应用

## 安全措施

### 认证授权
- JWT Token机制
- OAuth2.0集成
- RBAC权限控制
- API限流保护

### 数据安全
- 敏感数据加密
- SQL注入防护
- XSS攻击防护
- CSRF令牌验证

### 运维安全
- HTTPS强制
- 安全头配置
- 访问日志记录
- 定期安全扫描

## 监控告警

### 应用监控
- 应用性能指标
- 业务指标监控
- 错误日志收集
- 用户行为分析

### 基础设施监控
- 服务器资源监控
- 网络流量监控
- 数据库性能监控
- 容器资源监控

### 告警机制
- 阈值告警
- 异常告警
- 自动化故障恢复
- 告警收敛

## 应急预案

### 服务降级
- 核心服务保护
- 非核心服务降级
- 熔断机制触发
- 缓存兜底数据

### 数据备份
- 数据库定时备份
- 文件同步备份
- 异地备份存储
- 备份数据验证

### 故障恢复
- 故障定位流程
- 服务回滚方案
- 数据恢复步骤
- 经验总结改进

---

> **维护者**：大熊掌门
> **更新时间**：2024-01-15
> **团队**：电商平台技术团队