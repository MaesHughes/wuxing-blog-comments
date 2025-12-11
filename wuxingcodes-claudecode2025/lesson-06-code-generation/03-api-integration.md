# 第6课第3节：API集成与数据处理

## 🎯 学习目标

- 掌握API调用代码生成
- 学会数据处理和转换
- 理解错误处理策略
- 学会创建API封装层

## 📚 课程内容

### 3.1 基础API调用生成

#### Fetch API封装

```bash
# Prompt示例
"创建一个完整的API客户端，使用Fetch API：
- 支持请求/响应拦截器
- 自动错误处理
- 请求取消功能
- 支持认证Token
- 包含请求重试机制"
```

#### 生成的API客户端

```typescript
// api-client.ts
interface ApiClientOptions {
  baseURL?: string;
  timeout?: number;
  retries?: number;
  retryDelay?: number;
  headers?: Record<string, string>;
}

interface RequestConfig extends RequestInit {
  retries?: number;
  signal?: AbortSignal;
}

class ApiClient {
  private baseURL: string;
  private timeout: number;
  private retries: number;
  private retryDelay: number;
  private headers: Record<string, string>;
  private interceptors: {
    request: Array<(config: RequestConfig) => RequestConfig>;
    response: Array<(response: Response) => Response | Promise<Response>>;
  };

  constructor(options: ApiClientOptions = {}) {
    this.baseURL = options.baseURL || '';
    this.timeout = options.timeout || 10000;
    this.retries = options.retries || 3;
    this.retryDelay = options.retryDelay || 1000;
    this.headers = options.headers || {};
    this.interceptors = { request: [], response: [] };
  }

  // 添加请求拦截器
  addRequestInterceptor(interceptor: (config: RequestConfig) => RequestConfig) {
    this.interceptors.request.push(interceptor);
  }

  // 添加响应拦截器
  addResponseInterceptor(interceptor: (response: Response) => Response | Promise<Response>) {
    this.interceptors.response.push(interceptor);
  }

  // 创建请求配置
  private createRequestConfig(url: string, options: RequestConfig = {}): RequestConfig {
    const fullUrl = url.startsWith('http') ? url : `${this.baseURL}${url}`;

    const config: RequestConfig = {
      ...options,
      headers: {
        'Content-Type': 'application/json',
        ...this.headers,
        ...options.headers,
      },
    };

    // 应用请求拦截器
    return this.interceptors.request.reduce(
      (acc, interceptor) => interceptor(acc),
      { ...config, url: fullUrl }
    );
  }

  // 处理响应
  private async handleResponse(response: Response): Promise<Response> {
    let processedResponse = response;

    // 应用响应拦截器
    for (const interceptor of this.interceptors.response) {
      processedResponse = await interceptor(processedResponse);
    }

    if (!processedResponse.ok) {
      throw new ApiError(
        processedResponse.status,
        processedResponse.statusText,
        await processedResponse.json().catch(() => null)
      );
    }

    return processedResponse;
  }

  // 带超时的fetch
  private async fetchWithTimeout(url: string, options: RequestConfig): Promise<Response> {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), this.timeout);

    try {
      const response = await fetch(url, {
        ...options,
        signal: controller.signal,
      });
      clearTimeout(timeoutId);
      return response;
    } catch (error) {
      clearTimeout(timeoutId);
      if (error instanceof Error && error.name === 'AbortError') {
        throw new Error('Request timeout');
      }
      throw error;
    }
  }

  // 带重试的请求
  private async requestWithRetry(
    url: string,
    options: RequestConfig,
    attempt: number = 0
  ): Promise<Response> {
    try {
      const response = await this.fetchWithTimeout(url, options);
      return await this.handleResponse(response);
    } catch (error) {
      // 如果是客户端错误（4xx）或已达到最大重试次数，直接抛出错误
      if (error instanceof ApiError && error.status < 500) {
        throw error;
      }

      if (attempt >= this.retries) {
        throw error;
      }

      // 等待后重试
      await new Promise(resolve => setTimeout(resolve, this.retryDelay * Math.pow(2, attempt)));

      return this.requestWithRetry(url, options, attempt + 1);
    }
  }

  // GET请求
  async get<T = any>(url: string, params?: Record<string, any>, options: RequestConfig = {}): Promise<T> {
    let finalUrl = url;

    if (params) {
      const searchParams = new URLSearchParams();
      Object.entries(params).forEach(([key, value]) => {
        if (value !== undefined && value !== null) {
          searchParams.append(key, String(value));
        }
      });
      finalUrl += `?${searchParams.toString()}`;
    }

    const config = this.createRequestConfig(finalUrl, { ...options, method: 'GET' });
    const response = await this.requestWithRetry(config.url!, config);
    return response.json();
  }

  // POST请求
  async post<T = any>(url: string, data?: any, options: RequestConfig = {}): Promise<T> {
    const config = this.createRequestConfig(url, {
      ...options,
      method: 'POST',
      body: data ? JSON.stringify(data) : undefined,
    });

    const response = await this.requestWithRetry(config.url!, config);
    return response.json();
  }

  // PUT请求
  async put<T = any>(url: string, data?: any, options: RequestConfig = {}): Promise<T> {
    const config = this.createRequestConfig(url, {
      ...options,
      method: 'PUT',
      body: data ? JSON.stringify(data) : undefined,
    });

    const response = await this.requestWithRetry(config.url!, config);
    return response.json();
  }

  // DELETE请求
  async delete<T = any>(url: string, options: RequestConfig = {}): Promise<T> {
    const config = this.createRequestConfig(url, { ...options, method: 'DELETE' });
    const response = await this.requestWithRetry(config.url!, config);
    return response.json();
  }

  // 文件上传
  async upload<T = any>(url: string, file: File, options: RequestConfig = {}): Promise<T> {
    const formData = new FormData();
    formData.append('file', file);

    const config = this.createRequestConfig(url, {
      ...options,
      method: 'POST',
      body: formData,
      headers: {
        ...options.headers,
        'Content-Type': undefined, // 让浏览器自动设置
      },
    });

    const response = await this.requestWithRetry(config.url!, config);
    return response.json();
  }
}

// API错误类
class ApiError extends Error {
  constructor(
    public status: number,
    public statusText: string,
    public data?: any
  ) {
    super(`API Error: ${status} ${statusText}`);
    this.name = 'ApiError';
  }
}

// 创建默认实例
export const apiClient = new ApiClient({
  baseURL: process.env.REACT_APP_API_URL,
  timeout: 10000,
  retries: 3,
});

// 添加认证拦截器
apiClient.addRequestInterceptor((config) => {
  const token = localStorage.getItem('authToken');
  if (token) {
    config.headers = {
      ...config.headers,
      Authorization: `Bearer ${token}`,
    };
  }
  return config;
});

// 添加日志拦截器
apiClient.addRequestInterceptor((config) => {
  console.log(`[API Request] ${config.method?.toUpperCase()} ${config.url}`);
  return config;
});

apiClient.addResponseInterceptor((response) => {
  console.log(`[API Response] ${response.status} ${response.url}`);
  return response;
});

export default ApiClient;
```

### 3.2 数据处理与转换

#### 数据转换器生成

```bash
# Prompt示例
"创建一个数据转换工具，实现以下功能：
- 深度对象转换
- 数据格式标准化
- 日期时间处理
- 数据验证和清理
- 支持自定义转换规则"
```

#### 生成的数据转换器

```typescript
// data-transformer.ts
interface TransformRule {
  field: string;
  type: 'string' | 'number' | 'boolean' | 'date' | 'array' | 'object';
  required?: boolean;
  default?: any;
  transform?: (value: any) => any;
  validate?: (value: any) => boolean;
}

interface TransformSchema {
  [key: string]: TransformRule | TransformSchema;
}

class DataTransformer {
  private dateFormats = [
    'YYYY-MM-DD',
    'YYYY/MM/DD',
    'DD/MM/YYYY',
    'MM/DD/YYYY',
    'YYYY-MM-DD HH:mm:ss',
    'ISO8601',
  ];

  // 转换数据
  transform(data: any, schema: TransformSchema): any {
    if (Array.isArray(data)) {
      return data.map(item => this.transformObject(item, schema));
    }

    return this.transformObject(data, schema);
  }

  // 转换单个对象
  private transformObject(obj: any, schema: TransformSchema): any {
    if (!obj || typeof obj !== 'object') {
      return obj;
    }

    const result: any = {};

    Object.entries(schema).forEach(([key, rule]) => {
      const value = this.getNestedValue(obj, key);

      if (this.isTransformRule(rule)) {
        result[key] = this.transformField(value, rule);
      } else {
        // 嵌套对象
        result[key] = this.transform(value, rule);
      }
    });

    return result;
  }

  // 判断是否是转换规则
  private isTransformRule(rule: any): rule is TransformRule {
    return rule && typeof rule === 'object' && 'type' in rule;
  }

  // 获取嵌套值
  private getNestedValue(obj: any, path: string): any {
    return path.split('.').reduce((current, key) => {
      return current && current[key] !== undefined ? current[key] : undefined;
    }, obj);
  }

  // 转换字段
  private transformField(value: any, rule: TransformRule): any {
    // 处理必需字段
    if (value === undefined || value === null) {
      if (rule.required) {
        throw new Error(`Field ${rule.field} is required`);
      }
      return rule.default !== undefined ? rule.default : value;
    }

    // 应用自定义转换
    if (rule.transform) {
      value = rule.transform(value);
    }

    // 验证值
    if (rule.validate && !rule.validate(value)) {
      throw new Error(`Field ${rule.field} validation failed`);
    }

    // 类型转换
    switch (rule.type) {
      case 'string':
        return this.toString(value);
      case 'number':
        return this.toNumber(value);
      case 'boolean':
        return this.toBoolean(value);
      case 'date':
        return this.toDate(value);
      case 'array':
        return this.toArray(value);
      case 'object':
        return this.toObject(value);
      default:
        return value;
    }
  }

  // 转换为字符串
  private toString(value: any): string {
    if (typeof value === 'string') return value;
    if (value === null || value === undefined) return '';
    return String(value);
  }

  // 转换为数字
  private toNumber(value: any): number {
    if (typeof value === 'number') return value;
    const num = Number(value);
    if (isNaN(num)) throw new Error(`Cannot convert ${value} to number`);
    return num;
  }

  // 转换为布尔值
  private toBoolean(value: any): boolean {
    if (typeof value === 'boolean') return value;
    if (typeof value === 'string') {
      const lower = value.toLowerCase();
      return lower === 'true' || lower === '1' || lower === 'yes';
    }
    if (typeof value === 'number') {
      return value !== 0;
    }
    return Boolean(value);
  }

  // 转换为日期
  private toDate(value: any): Date | null {
    if (value instanceof Date) return value;
    if (typeof value === 'string') {
      // 尝试不同的日期格式
      for (const format of this.dateFormats) {
        const date = this.parseDate(value, format);
        if (date) return date;
      }
      // 尝试ISO解析
      const date = new Date(value);
      if (!isNaN(date.getTime())) return date;
    }
    if (typeof value === 'number') {
      return new Date(value);
    }
    throw new Error(`Cannot convert ${value} to date`);
  }

  // 解析日期
  private parseDate(dateString: string, format: string): Date | null {
    // 简化的日期解析逻辑
    // 实际项目中建议使用moment.js或date-fns
    try {
      if (format === 'ISO8601') {
        return new Date(dateString);
      }
      // 其他格式的解析逻辑...
      return null;
    } catch {
      return null;
    }
  }

  // 转换为数组
  private toArray(value: any): any[] {
    if (Array.isArray(value)) return value;
    if (value === null || value === undefined) return [];
    if (typeof value === 'string') {
      try {
        return JSON.parse(value);
      } catch {
        return value.split(',').map(item => item.trim());
      }
    }
    return [value];
  }

  // 转换为对象
  private toObject(value: any): any {
    if (typeof value === 'object' && value !== null) return value;
    if (typeof value === 'string') {
      try {
        return JSON.parse(value);
      } catch {
        return {};
      }
    }
    return {};
  }

  // 创建转换规则
  static rules = {
    string: (field: string, required = false, defaultValue = ''): TransformRule => ({
      field,
      type: 'string',
      required,
      default: defaultValue,
    }),

    number: (field: string, required = false, defaultValue = 0): TransformRule => ({
      field,
      type: 'number',
      required,
      default: defaultValue,
    }),

    boolean: (field: string, required = false, defaultValue = false): TransformRule => ({
      field,
      type: 'boolean',
      required,
      default: defaultValue,
    }),

    date: (field: string, required = false, defaultValue = null): TransformRule => ({
      field,
      type: 'date',
      required,
      default: defaultValue,
    }),

    array: (field: string, required = false, defaultValue = []): TransformRule => ({
      field,
      type: 'array',
      required,
      default: defaultValue,
    }),
  };
}

// 使用示例
const transformer = new DataTransformer();

// 用户数据转换schema
const userSchema: TransformSchema = {
  id: DataTransformer.rules.number('id', true),
  name: DataTransformer.rules.string('name', true),
  email: {
    ...DataTransformer.rules.string('email', true),
    transform: (value: string) => value.toLowerCase(),
    validate: (value: string) => /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value),
  },
  age: {
    ...DataTransformer.rules.number('age', false),
    transform: (value: any) => parseInt(value, 10),
    validate: (value: number) => value >= 0 && value <= 150,
  },
  isActive: DataTransformer.rules.boolean('isActive', false, true),
  createdAt: DataTransformer.rules.date('createdAt', true),
  profile: {
    avatar: DataTransformer.rules.string('profile.avatar'),
    bio: DataTransformer.rules.string('profile.bio'),
  },
  tags: DataTransformer.rules.array('tags', false),
};

export { DataTransformer, userSchema };
```

### 3.3 GraphQL集成

```bash
# GraphQL客户端生成
"创建一个GraphQL客户端，包含：
- Query和Mutation封装
- 自动缓存管理
- 订阅支持
- 错误处理
- TypeScript类型生成"
```

### 3.4 WebSocket集成

```bash
# WebSocket封装生成
"创建一个WebSocket管理器，实现：
- 自动重连机制
- 心跳检测
- 消息队列
- 事件系统
- TypeScript支持"
```

## 🎪 动手实践

### 练习1：创建完整的API服务

任务：生成一个完整的用户管理API服务
包含：
- 用户CRUD操作
- 认证和授权
- 文件上传
- 分页和筛选
- 缓存管理

### 练习2：数据处理管道

任务：创建数据处理管道
功能：
- ETL流程实现
- 数据清洗和验证
- 批量数据处理
- 错误恢复机制
- 监控和日志

### 练习3：实时数据同步

任务：实现实时数据同步
要求：
- WebSocket长连接
- 数据变更推送
- 离线数据缓存
- 冲突解决策略
- 状态管理

## 📖 最佳实践

### 1. API设计原则

- **RESTful设计**：遵循REST规范
- **版本控制**：API版本管理
- **文档完整**：自动生成文档
- **错误处理**：统一的错误格式

### 2. 性能优化

```typescript
// 请求缓存
const cache = new Map();

async function cachedFetch(url: string) {
  if (cache.has(url)) {
    return cache.get(url);
  }

  const response = await fetch(url);
  const data = await response.json();

  // 缓存5分钟
  cache.set(url, data);
  setTimeout(() => cache.delete(url), 5 * 60 * 1000);

  return data;
}

// 批量请求
async function batchRequests(urls: string[]) {
  const promises = urls.map(url => fetch(url));
  const responses = await Promise.all(promises);
  return Promise.all(responses.map(res => res.json()));
}
```

### 3. 错误处理策略

```typescript
// 全局错误处理
class ErrorHandler {
  static handle(error: Error) {
    console.error('API Error:', error);

    if (error instanceof ApiError) {
      switch (error.status) {
        case 401:
          // 跳转登录
          redirectToLogin();
          break;
        case 403:
          // 显示无权限
          showPermissionError();
          break;
        case 404:
          // 显示资源不存在
          showNotFoundError();
          break;
        case 500:
          // 显示服务器错误
          showServerError();
          break;
      }
    }

    // 显示通用错误
    showGenericError(error.message);
  }
}
```

## 🔍 代码审查清单

生成API代码后，检查：
- [ ] 错误处理是否完整
- [ ] 安全性是否考虑
- [ ] 性能是否优化
- [ ] 类型定义是否完整
- [ ] 文档是否齐全
- [ ] 测试是否覆盖
- [ ] 缓存策略是否合理
- [ ] 监控是否到位

## 💡 进阶技巧

### API模拟服务

```bash
# Mock API生成
"创建一个API模拟服务，支持：
- 基于OpenAPI规范
- 动态数据生成
- 场景测试
- 响应延迟模拟
- 错误场景模拟"
```

### 数据可视化

```bash
# 数据可视化组件
"生成数据可视化组件，包含：
- 图表组件库
- 实时数据更新
- 交互功能
- 响应式设计
- 导出功能"
```

## 🎉 总结

通过本节学习，你掌握了：
- API客户端的创建和配置
- 数据转换和处理技巧
- 错误处理最佳实践
- 性能优化策略

下一节将学习如何生成测试代码和文档。