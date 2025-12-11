# 第6课第4节：测试生成与文档编写

## 🎯 学习目标

- 掌握自动生成测试代码
- 学会编写完整的测试用例
- 理解文档生成技巧
- 学会创建API文档

## 📚 课程内容

### 4.1 单元测试生成

#### Jest测试用例生成

```bash
# Prompt示例
"为这个函数生成完整的Jest测试用例：
function calculateDiscount(price, discountRate, memberLevel) {
  let discount = price * discountRate;
  if (memberLevel === 'gold') {
    discount *= 1.2;
  } else if (memberLevel === 'silver') {
    discount *= 1.1;
  }
  return Math.max(0, price - discount);
}

要求：
- 测试所有分支
- 包含边界情况
- 测试错误输入
- 使用描述性的测试名称
- 包含setup和teardown"
```

#### 生成的测试代码

```typescript
// calculateDiscount.test.ts
import { calculateDiscount } from './calculateDiscount';

describe('calculateDiscount', () => {
  // 测试正常情况
  describe('正常输入', () => {
    test('应该正确计算普通会员的折扣', () => {
      expect(calculateDiscount(100, 0.1, 'normal')).toBe(90);
      expect(calculateDiscount(200, 0.2, 'normal')).toBe(160);
    });

    test('应该正确计算银牌会员的额外折扣', () => {
      expect(calculateDiscount(100, 0.1, 'silver')).toBe(89);
      expect(calculateDiscount(200, 0.2, 'silver')).toBe(156);
    });

    test('应该正确计算金牌会员的额外折扣', () => {
      expect(calculateDiscount(100, 0.1, 'gold')).toBe(88);
      expect(calculateDiscount(200, 0.2, 'gold')).toBe(152);
    });

    test('应该处理零折扣率', () => {
      expect(calculateDiscount(100, 0, 'normal')).toBe(100);
      expect(calculateDiscount(100, 0, 'gold')).toBe(100);
    });

    test('应该处理最大折扣率', () => {
      expect(calculateDiscount(100, 1, 'normal')).toBe(0);
      expect(calculateDiscount(100, 1, 'gold')).toBe(0);
    });
  });

  // 测试边界情况
  describe('边界情况', () => {
    test('应该处理零价格', () => {
      expect(calculateDiscount(0, 0.1, 'normal')).toBe(0);
      expect(calculateDiscount(0, 0.5, 'gold')).toBe(0);
    });

    test('应该处理小数价格和折扣率', () => {
      expect(calculateDiscount(99.99, 0.15, 'normal')).toBeCloseTo(84.99, 2);
      expect(calculateDiscount(100.5, 0.25, 'silver')).toBeCloseTo(72.49, 2);
    });

    test('应该防止负数结果', () => {
      expect(calculateDiscount(100, 1.5, 'normal')).toBe(0);
      expect(calculateDiscount(50, 2, 'gold')).toBe(0);
    });

    test('应该处理无效会员等级', () => {
      expect(calculateDiscount(100, 0.1, 'unknown')).toBe(90);
      expect(calculateDiscount(100, 0.1, '')).toBe(90);
      expect(calculateDiscount(100, 0.1, null)).toBe(90);
    });
  });

  // 测试错误输入
  describe('错误输入', () => {
    test('应该处理非数字价格', () => {
      expect(() => calculateDiscount('100', 0.1, 'normal')).toThrow();
      expect(() => calculateDiscount(null, 0.1, 'normal')).toThrow();
      expect(() => calculateDiscount(undefined, 0.1, 'normal')).toThrow();
    });

    test('应该处理非数字折扣率', () => {
      expect(() => calculateDiscount(100, '0.1', 'normal')).toThrow();
      expect(() => calculateDiscount(100, null, 'normal')).toThrow();
      expect(() => calculateDiscount(100, undefined, 'normal')).toThrow();
    });

    test('应该处理NaN输入', () => {
      expect(() => calculateDiscount(NaN, 0.1, 'normal')).toThrow();
      expect(() => calculateDiscount(100, NaN, 'normal')).toThrow();
    });

    test('应该处理无穷大', () => {
      expect(() => calculateDiscount(Infinity, 0.1, 'normal')).toThrow();
      expect(() => calculateDiscount(100, Infinity, 'normal')).toThrow();
    });
  });

  // 性能测试
  describe('性能测试', () => {
    test('应该在合理时间内完成计算', () => {
      const start = performance.now();
      for (let i = 0; i < 10000; i++) {
        calculateDiscount(100, 0.1, 'gold');
      }
      const end = performance.now();
      expect(end - start).toBeLessThan(100); // 100ms内完成10000次计算
    });
  });

  // 快照测试
  describe('快照测试', () => {
    test('折扣计算结果应该匹配快照', () => {
      const results = [
        calculateDiscount(100, 0.1, 'normal'),
        calculateDiscount(100, 0.1, 'silver'),
        calculateDiscount(100, 0.1, 'gold'),
      ];
      expect(results).toMatchSnapshot();
    });
  });
});
```

### 4.2 React组件测试

```bash
# React组件测试Prompt
"为这个React组件生成完整的测试代码：
import React, { useState } from 'react';

const Counter = ({ initialValue = 0, step = 1 }) => {
  const [count, setCount] = useState(initialValue);

  const increment = () => setCount(prev => prev + step);
  const decrement = () => setCount(prev => prev - step);
  const reset = () => setCount(initialValue);

  return (
    <div>
      <span data-testid="count">{count}</span>
      <button onClick={increment}>+</button>
      <button onClick={decrement}>-</button>
      <button onClick={reset}>Reset</button>
    </div>
  );
};

要求：
- 使用React Testing Library
- 测试用户交互
- 测试props变化
- 测试可访问性
- 包含异步场景"
```

#### 生成的React测试

```typescript
// Counter.test.tsx
import React from 'react';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { axe, toHaveNoViolations } from 'jest-axe';
import Counter from './Counter';

// 扩展匹配器
expect.extend(toHaveNoViolations);

describe('Counter组件', () => {
  const user = userEvent.setup();

  // 基础渲染测试
  describe('基础渲染', () => {
    test('应该正确渲染初始值', () => {
      render(<Counter />);
      expect(screen.getByTestId('count')).toHaveTextContent('0');
    });

    test('应该渲染自定义初始值', () => {
      render(<Counter initialValue={5} />);
      expect(screen.getByTestId('count')).toHaveTextContent('5');
    });

    test('应该渲染所有按钮', () => {
      render(<Counter />);
      expect(screen.getByRole('button', { name: '+' })).toBeInTheDocument();
      expect(screen.getByRole('button', { name: '-' })).toBeInTheDocument();
      expect(screen.getByRole('button', { name: 'Reset' })).toBeInTheDocument();
    });
  });

  // 用户交互测试
  describe('用户交互', () => {
    test('应该增加计数', async () => {
      render(<Counter />);
      const incrementBtn = screen.getByRole('button', { name: '+' });

      await user.click(incrementBtn);
      expect(screen.getByTestId('count')).toHaveTextContent('1');

      await user.dblClick(incrementBtn);
      expect(screen.getByTestId('count')).toHaveTextContent('3');
    });

    test('应该减少计数', async () => {
      render(<Counter initialValue={5} />);
      const decrementBtn = screen.getByRole('button', { name: '-' });

      await user.click(decrementBtn);
      expect(screen.getByTestId('count')).toHaveTextContent('4');
    });

    test('应该重置计数', async () => {
      render(<Counter initialValue={5} />);
      const incrementBtn = screen.getByRole('button', { name: '+' });
      const resetBtn = screen.getByRole('button', { name: 'Reset' });

      await user.click(incrementBtn);
      await user.click(incrementBtn);
      expect(screen.getByTestId('count')).toHaveTextContent('7');

      await user.click(resetBtn);
      expect(screen.getByTestId('count')).toHaveTextContent('5');
    });

    test('应该支持键盘操作', async () => {
      render(<Counter />);
      const incrementBtn = screen.getByRole('button', { name: '+' });

      incrementBtn.focus();
      await user.keyboard('{Enter}');
      expect(screen.getByTestId('count')).toHaveTextContent('1');

      await user.keyboard(' ');
      expect(screen.getByTestId('count')).toHaveTextContent('2');
    });
  });

  // Props测试
  describe('Props测试', () => {
    test('应该使用自定义步长', async () => {
      render(<Counter step={5} />);
      const incrementBtn = screen.getByRole('button', { name: '+' });

      await user.click(incrementBtn);
      expect(screen.getByTestId('count')).toHaveTextContent('5');
    });

    test('应该处理负步长', async () => {
      render(<Counter step={-1} />);
      const incrementBtn = screen.getByRole('button', { name: '+' });

      await user.click(incrementBtn);
      expect(screen.getByTestId('count')).toHaveTextContent('-1');
    });

    test('应该处理小数步长', async () => {
      render(<Counter step={0.5} />);
      const incrementBtn = screen.getByRole('button', { name: '+' });

      await user.click(incrementBtn);
      await user.click(incrementBtn);
      expect(screen.getByTestId('count')).toHaveTextContent('1');
    });
  });

  // 边界情况测试
  describe('边界情况', () => {
    test('应该处理大量点击', async () => {
      render(<Counter />);
      const incrementBtn = screen.getByRole('button', { name: '+' });

      for (let i = 0; i < 100; i++) {
        await user.click(incrementBtn);
      }
      expect(screen.getByTestId('count')).toHaveTextContent('100');
    });

    test('应该处理快速连续点击', async () => {
      render(<Counter />);
      const incrementBtn = screen.getByRole('button', { name: '+' });

      fireEvent.mouseDown(incrementBtn);
      fireEvent.mouseUp(incrementBtn);
      fireEvent.mouseDown(incrementBtn);
      fireEvent.mouseUp(incrementBtn);

      await waitFor(() => {
        expect(screen.getByTestId('count')).toHaveTextContent('2');
      });
    });
  });

  // 可访问性测试
  describe('可访问性', () => {
    test('应该通过axe测试', async () => {
      const { container } = render(<Counter />);
      const results = await axe(container);
      expect(results).toHaveNoViolations();
    });

    test('应该有正确的ARIA标签', () => {
      render(<Counter />);
      const buttons = screen.getAllByRole('button');
      buttons.forEach(button => {
        expect(button).toHaveAttribute('type');
      });
    });

    test('应该支持键盘导航', async () => {
      render(<Counter />);
      const firstButton = screen.getByRole('button', { name: '+' });

      firstButton.focus();
      expect(firstButton).toHaveFocus();

      await user.tab();
      expect(screen.getByRole('button', { name: '-' })).toHaveFocus();
    });
  });

  // 快照测试
  describe('快照测试', () => {
    test('应该匹配快照', () => {
      const { container } = render(<Counter />);
      expect(container).toMatchSnapshot();
    });

    test('应该匹配自定义值的快照', () => {
      const { container } = render(<Counter initialValue={10} step={2} />);
      expect(container).toMatchSnapshot();
    });
  });
});
```

### 4.3 API测试生成

```typescript
// API测试示例
describe('User API', () => {
  const baseURL = 'http://localhost:3000/api';

  // 获取用户列表
  describe('GET /users', () => {
    test('应该返回用户列表', async () => {
      const response = await fetch(`${baseURL}/users`);
      const data = await response.json();

      expect(response.status).toBe(200);
      expect(Array.isArray(data)).toBe(true);
      expect(data[0]).toHaveProperty('id');
      expect(data[0]).toHaveProperty('name');
      expect(data[0]).toHaveProperty('email');
    });

    test('应该支持分页', async () => {
      const response = await fetch(`${baseURL}/users?page=1&limit=10`);
      const data = await response.json();

      expect(response.status).toBe(200);
      expect(data).toHaveProperty('data');
      expect(data).toHaveProperty('pagination');
      expect(data.data).toHaveLength(10);
    });
  });

  // 创建用户
  describe('POST /users', () => {
    test('应该创建新用户', async () => {
      const newUser = {
        name: 'John Doe',
        email: 'john@example.com',
        password: 'password123'
      };

      const response = await fetch(`${baseURL}/users`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(newUser),
      });

      const data = await response.json();

      expect(response.status).toBe(201);
      expect(data).toHaveProperty('id');
      expect(data.name).toBe(newUser.name);
      expect(data.email).toBe(newUser.email);
      expect(data).not.toHaveProperty('password');
    });

    test('应该验证必填字段', async () => {
      const invalidUser = {
        name: '',
        email: 'invalid-email'
      };

      const response = await fetch(`${baseURL}/users`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(invalidUser),
      });

      const data = await response.json();

      expect(response.status).toBe(400);
      expect(data).toHaveProperty('errors');
    });
  });
});
```

### 4.4 文档生成

#### API文档生成

```bash
# API文档生成Prompt
"为这个API生成完整的文档，包含：
- OpenAPI 3.0规范
- 请求/响应示例
- 错误码说明
- 认证方式
- 使用示例
- SDK生成指导"
```

#### 生成的API文档

```yaml
# openapi.yaml
openapi: 3.0.0
info:
  title: User Management API
  description: 用户管理系统的RESTful API
  version: 1.0.0
  contact:
    name: API Support
    email: api-support@example.com
  license:
    name: MIT
    url: https://opensource.org/licenses/MIT

servers:
  - url: https://api.example.com/v1
    description: Production server
  - url: https://staging-api.example.com/v1
    description: Staging server
  - url: http://localhost:3000/v1
    description: Development server

security:
  - BearerAuth: []

paths:
  /users:
    get:
      summary: 获取用户列表
      description: 返回分页的用户列表，支持搜索和筛选
      tags:
        - Users
      parameters:
        - name: page
          in: query
          description: 页码，从1开始
          required: false
          schema:
            type: integer
            minimum: 1
            default: 1
        - name: limit
          in: query
          description: 每页数量，最大100
          required: false
          schema:
            type: integer
            minimum: 1
            maximum: 100
            default: 20
        - name: search
          in: query
          description: 搜索关键词（搜索用户名和邮箱）
          required: false
          schema:
            type: string
            minLength: 1
            maxLength: 100
        - name: status
          in: query
          description: 用户状态筛选
          required: false
          schema:
            type: string
            enum: [active, inactive, suspended]
      responses:
        '200':
          description: 成功返回用户列表
          content:
            application/json:
              schema:
                type: object
                properties:
                  data:
                    type: array
                    items:
                      $ref: '#/components/schemas/User'
                  pagination:
                    $ref: '#/components/schemas/Pagination'
              example:
                data:
                  - id: 1
                    name: John Doe
                    email: john@example.com
                    status: active
                    createdAt: '2025-01-01T00:00:00Z'
                pagination:
                  page: 1
                  limit: 20
                  total: 100
                  totalPages: 5
        '400':
          $ref: '#/components/responses/BadRequest'
        '401':
          $ref: '#/components/responses/Unauthorized'
        '403':
          $ref: '#/components/responses/Forbidden'

    post:
      summary: 创建新用户
      description: 创建一个新用户账号
      tags:
        - Users
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/CreateUserRequest'
            example:
              name: John Doe
              email: john@example.com
              password: password123
              role: user
      responses:
        '201':
          description: 用户创建成功
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/User'
              example:
                id: 123
                name: John Doe
                email: john@example.com
                status: active
                role: user
                createdAt: '2025-01-01T00:00:00Z'
        '400':
          $ref: '#/components/responses/BadRequest'
        '409':
          description: 邮箱已存在
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'

  /users/{id}:
    get:
      summary: 获取用户详情
      description: 根据ID获取特定用户的信息
      tags:
        - Users
      parameters:
        - name: id
          in: path
          required: true
          description: 用户ID
          schema:
            type: integer
            minimum: 1
      responses:
        '200':
          description: 成功返回用户信息
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/User'
        '404':
          $ref: '#/components/responses/NotFound'

    put:
      summary: 更新用户信息
      description: 更新指定用户的信息
      tags:
        - Users
      parameters:
        - name: id
          in: path
          required: true
          schema:
            type: integer
            minimum: 1
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/UpdateUserRequest'
      responses:
        '200':
          description: 更新成功
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/User'
        '400':
          $ref: '#/components/responses/BadRequest'
        '404':
          $ref: '#/components/responses/NotFound'

    delete:
      summary: 删除用户
      description: 删除指定的用户账号
      tags:
        - Users
      parameters:
        - name: id
          in: path
          required: true
          schema:
            type: integer
            minimum: 1
      responses:
        '204':
          description: 删除成功
        '404':
          $ref: '#/components/responses/NotFound'

components:
  securitySchemes:
    BearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT

  schemas:
    User:
      type: object
      properties:
        id:
          type: integer
          example: 123
        name:
          type: string
          minLength: 1
          maxLength: 100
          example: John Doe
        email:
          type: string
          format: email
          example: john@example.com
        status:
          type: string
          enum: [active, inactive, suspended]
          example: active
        role:
          type: string
          enum: [admin, user, moderator]
          example: user
        avatar:
          type: string
          format: uri
          example: https://example.com/avatars/123.jpg
        createdAt:
          type: string
          format: date-time
          example: '2025-01-01T00:00:00Z'
        updatedAt:
          type: string
          format: date-time
          example: '2025-01-01T00:00:00Z'

    CreateUserRequest:
      type: object
      required:
        - name
        - email
        - password
      properties:
        name:
          type: string
          minLength: 1
          maxLength: 100
          description: 用户姓名
        email:
          type: string
          format: email
          description: 用户邮箱
        password:
          type: string
          minLength: 8
          maxLength: 128
          pattern: '^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d@$!%*?&]{8,}$'
          description: 密码（至少8位，包含大小写字母和数字）
        role:
          type: string
          enum: [admin, user, moderator]
          default: user
          description: 用户角色

    UpdateUserRequest:
      type: object
      properties:
        name:
          type: string
          minLength: 1
          maxLength: 100
        status:
          type: string
          enum: [active, inactive, suspended]
        role:
          type: string
          enum: [admin, user, moderator]
        avatar:
          type: string
          format: uri

    Pagination:
      type: object
      properties:
        page:
          type: integer
          minimum: 1
          example: 1
        limit:
          type: integer
          minimum: 1
          maximum: 100
          example: 20
        total:
          type: integer
          minimum: 0
          example: 100
        totalPages:
          type: integer
          minimum: 0
          example: 5

    Error:
      type: object
      properties:
        code:
          type: string
          example: VALIDATION_ERROR
        message:
          type: string
          example: 请求参数验证失败
        details:
          type: array
          items:
            type: object
            properties:
              field:
                type: string
              message:
                type: string

  responses:
    BadRequest:
      description: 请求参数错误
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/Error'

    Unauthorized:
      description: 未授权访问
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/Error'

    Forbidden:
      description: 权限不足
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/Error'

    NotFound:
      description: 资源不存在
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/Error'

tags:
  - name: Users
    description: 用户管理相关接口
```

## 🎪 动手实践

### 练习1：生成完整测试套件

任务：为待办事项应用生成测试
包含：
- 单元测试（Redux reducers）
- 组件测试（React组件）
- 集成测试（API调用）
- E2E测试（用户流程）
- 性能测试

### 练习2：创建文档生成器

任务：创建自动化文档生成工具
功能：
- 从代码提取注释
- 生成API文档
- 创建使用指南
- 生成示例代码
- 支持多语言

### 练习3：测试数据生成

任务：创建测试数据生成器
要求：
- 生成模拟数据
- 支持多种数据类型
- 关联数据生成
- 数据一致性保证
- 可定制规则

## 📖 最佳实践

### 1. 测试策略

```typescript
// 测试金字塔
// 70% 单元测试
// 20% 集成测试
// 10% E2E测试

// 测试覆盖率配置
module.exports = {
  collectCoverage: true,
  collectCoverageFrom: [
    'src/**/*.{ts,tsx}',
    '!src/**/*.d.ts',
    '!src/index.tsx',
  ],
  coverageThreshold: {
    global: {
      branches: 80,
      functions: 80,
      lines: 80,
      statements: 80,
    },
  },
};
```

### 2. 文档自动化

```typescript
// JSDoc示例
/**
 * 计算折扣后的价格
 * @param {number} price - 商品原价
 * @param {number} discountRate - 折扣率 (0-1)
 * @param {string} memberLevel - 会员等级
 * @param {string} [memberLevel.gold] - 黄金会员
 * @param {string} [memberLevel.silver] - 白银会员
 * @returns {number} 折扣后的价格
 * @throws {Error} 当参数无效时抛出错误
 * @example
 * // returns 90
 * calculateDiscount(100, 0.1, 'normal')
 * @example
 * // returns 88
 * calculateDiscount(100, 0.1, 'gold')
 */
```

### 3. 持续集成

```yaml
# .github/workflows/test.yml
name: Test
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [16, 18, 20]

    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-node@v2
        with:
          node-version: ${{ matrix.node-version }}
      - run: npm ci
      - run: npm run test:coverage
      - run: npm run lint
      - run: npm run type-check
```

## 🔍 代码审查清单

生成测试代码后，检查：
- [ ] 测试覆盖率是否达标
- [ ] 边界情况是否测试
- [ ] 错误场景是否覆盖
- [ ] 性能测试是否添加
- [ ] 测试是否独立
- [ ] 测试数据是否合理
- [ ] 文档是否完整
- [ ] 示例是否可运行

## 💡 进阶技巧

### 自动化测试生成

```bash
# 测试生成器
"创建一个测试代码生成器，支持：
- 自动读取函数签名
- 生成基础测试用例
- 分析代码复杂度
- 生成边界测试
- 输出测试报告"
```

### 交互式文档

```bash
# 文档生成
"生成交互式API文档，包含：
- 在线测试接口
- 参数提示
- 响应示例
- 错误模拟
- SDK代码生成"
```

## 🎉 总结

通过本节学习，你掌握了：
- 自动生成各种类型的测试
- 编写高质量的测试用例
- 生成专业的API文档
- 建立完善的文档体系

下一节将学习项目实战和最佳实践总结。