# MCP服务器集成实战练习题

## 练习1：基础SQLite MCP服务器

### 任务描述
创建一个SQLite MCP服务器，用于管理一个简单的任务管理系统。

### 功能要求
1. 创建任务表（包含：id、title、description、status、created_at、due_date）
2. 实现以下工具：
   - 添加任务
   - 查看所有任务
   - 更新任务状态
   - 删除任务
   - 搜索任务

### 实现步骤
1. 创建 `task-manager-server.js` 文件
2. 实现数据库初始化
3. 实现5个工具的功能
4. 测试所有功能

### 参考代码框架

```javascript
import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { open } from 'sqlite';
import sqlite3 from 'sqlite3';

const server = new Server({
  name: "task-manager-server",
  version: "1.0.0"
}, {
  capabilities: {
    tools: {}
  }
});

// 实现你的代码...
```

### 验证方法
测试以下功能：
- 添加3个任务
- 查看任务列表
- 更新第2个任务状态为"已完成"
- 搜索包含特定关键词的任务
- 删除第1个任务

---

## 练习2：天气API集成

### 任务描述
创建一个集成天气API的MCP服务器，提供全球城市的天气信息查询功能。

### 功能要求
1. 使用OpenWeatherMap API或其他免费天气API
2. 实现以下工具：
   - 获取当前天气
   - 获取天气预报（未来5天）
   - 城市搜索（根据名称查找城市ID）
   - 收藏城市管理（添加、删除、列出收藏）

### 实现步骤
1. 注册获取API密钥
2. 创建 `weather-server.js`
3. 实现API请求封装
4. 实现各个工具功能
5. 添加缓存机制（避免频繁请求API）

### 参考代码框架

```javascript
const WEATHER_API_KEY = process.env.WEATHER_API_KEY;
const WEATHER_BASE_URL = "https://api.openweathermap.org/data/2.5";

async function fetchWeatherData(endpoint, params) {
  // 实现API调用逻辑
}

server.setRequestHandler("tools/list", async () => ({
  tools: [
    {
      name: "get_current_weather",
      description: "获取当前天气",
      inputSchema: {
        type: "object",
        properties: {
          city: { type: "string" },
          units: { type: "string", enum: ["metric", "imperial"] }
        }
      }
    }
    // 添加更多工具...
  ]
}));
```

### 验证方法
- 查询北京的当前天气
- 获取上海未来3天的天气预报
- 搜索"New York"并获取其天气信息
- 将东京添加到收藏城市

---

## 练习3：智能代码分析器

### 任务描述
创建一个文件系统MCP服务器，专注于代码质量分析和项目结构检测。

### 功能要求
1. 代码质量分析：
   - 计算代码复杂度
   - 检测重复代码
   - 分析代码结构（函数、类、模块）
2. 项目结构分析：
   - 识别项目类型（Node.js、Python、Java等）
   - 检测使用的框架和库
   - 生成项目结构图

### 实现步骤
1. 创建 `code-analyzer-server.js`
2. 实现文件遍历和内容解析
3. 实现各种分析算法
4. 添加报告生成功能

### 参考代码框架

```javascript
async function analyzeComplexity(code, language) {
  // 实现复杂度计算
}

async function detectDuplicates(files, minLines = 5) {
  // 实现重复代码检测
}

async function analyzeProjectStructure(rootPath) {
  // 实现项目结构分析
}

server.setRequestHandler("tools/list", async () => ({
  tools: [
    {
      name: "analyze_file",
      description: "分析单个文件",
      inputSchema: {
        type: "object",
        properties: {
          filePath: { type: "string" },
          metrics: {
            type: "array",
            items: { type: "string" }
          }
        }
      }
    }
    // 添加更多工具...
  ]
}));
```

### 验证方法
- 分析一个JavaScript文件的复杂度
- 检测项目中的重复代码
- 分析项目结构并生成报告
- 查找项目中超过50行的函数

---

## 练习4：数据库连接池管理

### 任务描述
创建一个高级的数据库MCP服务器，实现连接池管理和性能优化。

### 功能要求
1. 连接池管理：
   - 支持多数据库连接（PostgreSQL、MySQL）
   - 动态调整连接池大小
   - 连接健康检查
2. 性能优化：
   - 查询缓存
   - 慢查询日志
   - 批量操作支持

### 实现步骤
1. 创建 `advanced-db-server.js`
2. 实现连接池管理器
3. 添加查询缓存层
4. 实现性能监控
5. 添加配置管理

### 参考代码框架

```javascript
class ConnectionPool {
  constructor(config) {
    this.config = config;
    this.pool = [];
    this.activeConnections = 0;
  }

  async getConnection() {
    // 实现连接获取逻辑
  }

  async releaseConnection(conn) {
    // 实现连接释放逻辑
  }

  async healthCheck() {
    // 实现健康检查
  }
}

class QueryCache {
  constructor(ttl = 300000) { // 5分钟TTL
    this.cache = new Map();
    this.ttl = ttl;
  }

  get(key) {
    // 实现缓存获取
  }

  set(key, value) {
    // 实现缓存设置
  }
}
```

### 验证方法
- 创建连接池并配置参数
- 执行100个并发查询，测试性能
- 启用查询缓存，对比性能差异
- 模拟连接断开，测试重连机制

---

## 练习5：多服务集成平台

### 任务描述
创建一个集成了多个外部服务的MCP服务器，包括数据库、API、文件系统和缓存。

### 功能要求
1. 集成至少3种不同类型的服务：
   - 数据库服务（用户数据存储）
   - API服务（如GitHub、Twitter等）
   - 文件系统服务（文件管理）
   - 缓存服务（Redis）
2. 实现服务间的数据流转
3. 添加事务支持（跨服务操作）

### 实现步骤
1. 创建 `integration-platform-server.js`
2. 设计服务接口抽象层
3. 实现各个服务适配器
4. 实现工作流编排
5. 添加错误处理和重试机制

### 参考代码框架

```javascript
class ServiceAdapter {
  constructor(config) {
    this.config = config;
  }

  async connect() {
    throw new Error('Must implement connect method');
  }

  async execute(operation, params) {
    throw new Error('Must implement execute method');
  }
}

class DatabaseAdapter extends ServiceAdapter {
  async connect() {
    // 实现数据库连接
  }

  async execute(operation, params) {
    // 实现数据库操作
  }
}

class APIAdapter extends ServiceAdapter {
  async connect() {
    // 实现API连接
  }

  async execute(operation, params) {
    // 实现API调用
  }
}

class WorkflowEngine {
  constructor() {
    this.services = new Map();
  }

  registerService(name, adapter) {
    this.services.set(name, adapter);
  }

  async executeWorkflow(steps) {
    // 实现工作流执行
  }
}
```

### 验证方法
- 注册并连接所有服务
- 实现一个工作流：从API获取数据 → 存储到数据库 → 生成报告文件
- 测试事务回滚功能
- 模拟服务故障，测试容错机制

---

## 练习6：实时数据处理

### 任务描述
创建一个支持实时数据处理的MCP服务器，包括流数据处理和事件通知。

### 功能要求
1. 流数据处理：
   - 支持WebSocket连接
   - 实时数据推送
   - 数据聚合和统计
2. 事件系统：
   - 事件订阅和发布
   - 事件过滤和路由
   - 持久化事件日志

### 实现步骤
1. 创建 `realtime-server.js`
2. 实现WebSocket服务器
3. 实现事件系统
4. 添加数据处理管道
5. 实现客户端API

### 参考代码框架

```javascript
import WebSocket from 'ws';
import EventEmitter from 'events';

class EventSystem extends EventEmitter {
  constructor() {
    super();
    this.subscriptions = new Map();
  }

  subscribe(eventType, callback, filters = {}) {
    // 实现事件订阅
  }

  publish(eventType, data) {
    // 实现事件发布
  }
}

class DataStream {
  constructor() {
    this.processors = [];
    this.subscribers = [];
  }

  pipe(processor) {
    // 添加数据处理器
  }

  subscribe(callback) {
    // 订阅数据流
  }

  push(data) {
    // 推送新数据
  }
}
```

### 验证方法
- 建立WebSocket连接并接收数据
- 创建数据流处理器，实现实时统计
- 测试事件订阅和发布机制
- 实现一个简单的实时聊天示例

---

## 练习7：性能监控和调试

### 任务描述
为MCP服务器添加全面的性能监控和调试功能。

### 功能要求
1. 性能指标收集：
   - 请求响应时间
   - 内存使用情况
   - CPU使用率
   - 错误率统计
2. 调试工具：
   - 请求日志
   - 调用链追踪
   - 性能分析报告
   - 实时监控面板

### 实现步骤
1. 创建 `monitoring-middleware.js`
2. 实现指标收集器
3. 实现日志记录器
4. 实现性能分析器
5. 创建监控API

### 参考代码框架

```javascript
class PerformanceMonitor {
  constructor() {
    this.metrics = new Map();
    this.requests = [];
  }

  recordRequest(method, duration, success) {
    // 记录请求指标
  }

  getMetrics(timeRange) {
    // 获取性能指标
  }

  generateReport() {
    // 生成性能报告
  }
}

class Debugger {
  constructor() {
    this.traces = [];
    this.enabled = process.env.NODE_ENV === 'development';
  }

  startTrace(requestId) {
    // 开始追踪
  }

  addTrace(requestId, step, data) {
    // 添加追踪点
  }

  endTrace(requestId) {
    // 结束追踪
  }
}

// 监控中间件
function withMonitoring(target, propertyKey, descriptor) {
  const originalMethod = descriptor.value;

  descriptor.value = async function(...args) {
    const start = Date.now();
    const requestId = generateRequestId();

    try {
      const result = await originalMethod.apply(this, args);

      // 记录成功请求
      this.monitor.recordRequest(propertyKey, Date.now() - start, true);

      return result;
    } catch (error) {
      // 记录失败请求
      this.monitor.recordRequest(propertyKey, Date.now() - start, false);
      throw error;
    }
  };

  return descriptor;
}
```

### 验证方法
- 运行服务器并生成性能报告
- 模拟高并发请求，监控系统表现
- 查看请求日志和调用链
- 创建自定义性能仪表盘

---

## 综合项目：企业级MCP平台

### 任务描述
结合以上所有练习，创建一个企业级的MCP平台，提供完整的工具和服务集成能力。

### 功能要求
1. 核心功能：
   - 多租户支持
   - 服务发现和注册
   - 配置管理
   - 安全认证
   - 审计日志

2. 高级功能：
   - 服务编排
   - 自动扩缩容
   - 故障恢复
   - A/B测试支持

### 项目结构

```
enterprise-mcp-platform/
├── core/
│   ├── server.js          # 主服务器
│   ├── auth.js            # 认证模块
│   ├── config.js          # 配置管理
│   └── registry.js        # 服务注册中心
├── services/
│   ├── database/          # 数据库服务
│   ├── api/              # API服务
│   ├── filesystem/       # 文件系统服务
│   └── cache/            # 缓存服务
├── middleware/
│   ├── auth.js           # 认证中间件
│   ├── ratelimit.js      # 限流中间件
│   ├── monitoring.js     # 监控中间件
│   └── logging.js        # 日志中间件
├── tools/
│   ├── deployment.js     # 部署工具
│   ├── testing.js        # 测试工具
│   └── benchmark.js      # 性能测试
└── tests/
    ├── unit/             # 单元测试
    ├── integration/      # 集成测试
    └── e2e/              # 端到端测试
```

### 验证标准
1. 功能完整性测试
2. 性能压力测试（1000 QPS）
3. 故障恢复测试
4. 安全漏洞扫描
5. 文档完整性检查

---

## 提交要求

### 每个练习需要提交：
1. **源代码** - 完整的可运行代码
2. **配置文件** - package.json、环境配置等
3. **测试用例** - 至少3个测试用例
4. **README文档** - 使用说明和API文档
5. **部署指南** - 如何部署和运行

### 评分标准：
- **功能实现** (40%) - 是否完成所有要求的功能
- **代码质量** (20%) - 代码结构、可读性、错误处理
- **性能优化** (15%) - 是否考虑了性能和优化
- **文档完整** (15%) - 文档是否清晰完整
- **测试覆盖** (10%) - 测试用例是否充分

### 提交方式：
1. 创建GitHub仓库
2. 提交代码和文档
3. 创建Issue报告测试结果
4. 提交仓库链接和测试报告

祝您练习愉快！如有问题，请随时提问。