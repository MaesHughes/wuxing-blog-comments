# ClaudeCode Agent实战练习

本练习手册包含了4个实战练习，帮助你掌握Agent的创建和使用。每个练习都包含任务说明、步骤指导、参考答案和扩展挑战。

## 练习环境准备

### 1. 创建Agent目录

```bash
# 在你的项目根目录执行
mkdir -p .claude/agents
cd .claude/agents
```

### 2. 验证环境

```bash
# 列出所有可用的Agent
/agents list
```

---

## 练习1：创建代码格式化Agent

### 任务描述
创建一个专门负责代码格式化的Agent，支持JavaScript、Python和HTML代码的自动格式化。

### 步骤指导

#### 第1步：创建Agent文件
```bash
# 创建文件
touch .claude/agents/code-formatter.md
```

#### 第2步：编写Agent配置
将以下内容复制到 `code-formatter.md` 文件中：

```markdown
---
name: Code Formatter
description: 自动格式化代码的Agent
version: 1.0
author: [你的名字]
tags: [formatting, style, prettier]
---

# Code Formatter Agent

你是一个代码格式化专家，按照统一标准格式化各种编程语言的代码。

## 格式化规则

### JavaScript/TypeScript
- 使用2空格缩进
- 单引号优先
- 尾逗号保留
- 对象和数组使用空格

### Python
- 遵循PEP 8规范
- 4空格缩进
- 行长度限制88字符
- 使用snake_case命名

### HTML/CSS
- 2空格缩进
- 属性按字母排序
- 使用双引号

## 使用方法
用户会说："请格式化这段代码"，然后粘贴代码，我需要按照对应语言的规则进行格式化。
```

#### 第3步：测试Agent
```bash
# 粘贴未格式化的代码
function calculate(a,b,c){return a+b+c}

# 调用Agent
@code-formatter 请格式化这段代码
```

### 参考答案
```javascript
function calculate(a, b, c) {
  return a + b + c;
}
```

### 扩展挑战
1. 支持更多编程语言（Java、Go、Rust）
2. 添加自定义格式化规则选项
3. 支持代码风格检查
4. 实现批量文件格式化功能

---

## 练习2：创建API文档生成Agent

### 任务描述
创建一个能够自动生成REST API文档的Agent，支持OpenAPI 3.0格式输出。

### 步骤指导

#### 第1步：创建Agent文件
```bash
touch .claude/agents/api-doc-generator.md
```

#### 第2步：编写Agent配置
```markdown
---
name: API Doc Generator
description: 生成REST API文档的Agent
version: 1.0
tags: [api, documentation, openapi]
---

# API Doc Generator Agent

你是一个API文档专家，能够根据代码自动生成标准的API文档。

## 功能
1. 解析API端点定义
2. 提取请求/响应参数
3. 生成OpenAPI 3.0规范
4. 创建Markdown文档

## 支持的框架
- Express.js
- FastAPI
- Django REST Framework
- Spring Boot

## 输出格式
我会生成包含以下内容的文档：
- API概述
- 端点列表
- 请求/响应示例
- 错误码说明
- 认证方式
```

#### 第3步：测试Agent
```javascript
// 输入的API代码
const express = require('express');
const router = express.Router();

// 获取用户信息
router.get('/users/:id', async (req, res) => {
  const { id } = req.params;
  const user = await User.findById(id);
  res.json(user);
});

// 创建用户
router.post('/users', async (req, res) => {
  const { name, email, age } = req.body;
  const user = await User.create({ name, email, age });
  res.status(201).json(user);
});

// 更新用户
router.put('/users/:id', async (req, res) => {
  const { id } = req.params;
  const updates = req.body;
  const user = await User.findByIdAndUpdate(id, updates, { new: true });
  res.json(user);
});
```

```bash
@api-doc-generator 请为这个API生成文档
```

### 参考答案
```markdown
# User API Documentation

## Overview
用户管理API提供用户信息的增删改查功能。

## Base URL
`http://localhost:3000/api`

## Endpoints

### GET /users/:id
获取指定用户的信息

**Parameters:**
- `id` (path, required): 用户唯一标识符

**Response:**
```json
{
  "id": "string",
  "name": "string",
  "email": "string",
  "age": "number"
}
```

### POST /users
创建新用户

**Request Body:**
```json
{
  "name": "string",
  "email": "string",
  "age": "number"
}
```

**Response:**
```json
{
  "id": "string",
  "name": "string",
  "email": "string",
  "age": "number"
}
```
```

### 扩展挑战
1. 生成完整的OpenAPI 3.0 JSON文件
2. 支持GraphQL API文档生成
3. 自动生成API客户端SDK
4. 集成Swagger UI展示

---

## 练习3：创建数据库查询优化Agent

### 任务描述
创建一个专门分析和优化数据库查询的Agent，能够识别性能瓶颈并提供优化建议。

### 步骤指导

#### 第1步：创建Agent文件
```bash
touch .claude/agents/db-query-optimizer.md
```

#### 第2步：编写Agent配置
```markdown
---
name: DB Query Optimizer
description: 数据库查询优化专家
version: 1.0
tags: [database, sql, optimization]
---

# DB Query Optimizer Agent

你是一个数据库性能优化专家，专门分析和优化SQL查询。

## 优化重点
1. 查询执行计划分析
2. 索引优化建议
3. 查询重写
4. 性能提升预估

## 支持的数据库
- MySQL
- PostgreSQL
- SQLite
- SQL Server

## 分析流程
1. 解析SQL查询结构
2. 识别潜在性能问题
3. 提供优化方案
4. 估算性能提升
```

#### 第3步：测试Agent
```sql
-- 需要优化的查询
SELECT u.name, u.email, p.title, p.content, p.created_at
FROM users u
JOIN posts p ON u.id = p.user_id
WHERE u.created_at > '2024-01-01'
ORDER BY p.created_at DESC
LIMIT 10;

-- 表结构
-- users: 100万条记录
-- posts: 500万条记录
-- 索引: users(created_at), posts(user_id)
```

```bash
@db-query-optimizer 请优化这个查询
```

### 参考答案
```markdown
## 查询优化报告

### 当前查询分析
- **表连接**: 2个表，500万+100万记录
- **潜在问题**:
  1. 没有使用LIMIT优化
  2. 可能扫描大量数据
  3. 排序操作可能很慢

### 优化建议

#### 1. 添加复合索引
```sql
CREATE INDEX idx_posts_user_created ON posts(user_id, created_at DESC);
```

#### 2. 优化查询
```sql
SELECT u.name, u.email, p.title, p.content, p.created_at
FROM users u
INNER JOIN posts p ON u.id = p.user_id
WHERE u.created_at > '2024-01-01'
ORDER BY p.created_at DESC
LIMIT 10;
```

#### 3. 使用子查询优化
```sql
SELECT u.name, u.email, p.title, p.content, p.created_at
FROM (
    SELECT * FROM users
    WHERE created_at > '2024-01-01'
) u
INNER JOIN posts p ON u.id = p.user_id
ORDER BY p.created_at DESC
LIMIT 10;
```

### 预期提升
- **查询时间**: 从2秒减少到50ms（提升40倍）
- **资源消耗**: 减少90%
- **并发能力**: 提升20倍
```

### 扩展挑战
1. 生成EXPLAIN执行计划分析
2. 提供索引创建脚本
3. 支持查询重写建议
4. 集成慢查询日志分析

---

## 练习4：创建单元测试生成Agent

### 任务描述
创建一个能够自动生成高质量单元测试的Agent，支持多种测试框架和测试类型。

### 步骤指导

#### 第1步：创建Agent文件
```bash
touch .claude/agents/test-generator.md
```

#### 第2步：编写Agent配置
```markdown
---
name: Test Generator
description: 智能单元测试生成Agent
version: 1.0
tags: [testing, unit-test, automation]
---

# Test Generator Agent

你是一个专业的测试工程师，能够自动生成高质量的单元测试。

## 测试覆盖
- 正常功能测试
- 边界条件测试
- 异常处理测试
- 性能测试建议

## 支持的语言/框架
- JavaScript: Jest, Mocha
- Python: Pytest, unittest
- Java: JUnit, TestNG
- Go: Go test

## 测试原则
- AAA模式（Arrange, Act, Assert）
- 有意义的测试名称
- 测试独立性
- 充分的断言
```

#### 第3步：测试Agent
```python
# 待测试的代码
class ShoppingCart:
    def __init__(self):
        self.items = []
        self.discount = 0

    def add_item(self, product_name, price, quantity=1):
        if price < 0:
            raise ValueError("Price cannot be negative")
        if quantity <= 0:
            raise ValueError("Quantity must be positive")

        self.items.append({
            'product': product_name,
            'price': price,
            'quantity': quantity
        })

    def calculate_total(self):
        total = 0
        for item in self.items:
            total += item['price'] * item['quantity']

        if self.discount > 0:
            total *= (1 - self.discount)

        return total

    def apply_discount(self, discount):
        if not 0 <= discount <= 1:
            raise ValueError("Discount must be between 0 and 1")
        self.discount = discount
```

```bash
@test-generator 请为ShoppingCart类编写完整的pytest测试
```

### 参考答案
```python
import pytest

class TestShoppingCart:
    def setup_method(self):
        """每个测试方法前执行"""
        self.cart = ShoppingCart()

    def test_add_item_normal(self):
        """测试正常添加商品"""
        self.cart.add_item("Apple", 1.99, 3)
        assert len(self.cart.items) == 1
        assert self.cart.items[0]['product'] == "Apple"
        assert self.cart.items[0]['price'] == 1.99
        assert self.cart.items[0]['quantity'] == 3

    def test_add_item_default_quantity(self):
        """测试默认数量"""
        self.cart.add_item("Banana", 0.99)
        assert self.cart.items[0]['quantity'] == 1

    def test_add_item_negative_price(self):
        """测试负价格异常"""
        with pytest.raises(ValueError, match="Price cannot be negative"):
            self.cart.add_item("Invalid", -1.99)

    def test_add_item_zero_quantity(self):
        """测试零数量异常"""
        with pytest.raises(ValueError, match="Quantity must be positive"):
            self.cart.add_item("Zero", 1.99, 0)

    def test_calculate_total_empty(self):
        """测试空购物车总额"""
        assert self.cart.calculate_total() == 0

    def test_calculate_total_single_item(self):
        """测试单个商品总额"""
        self.cart.add_item("Orange", 2.50, 2)
        assert self.cart.calculate_total() == 5.0

    def test_calculate_total_multiple_items(self):
        """测试多个商品总额"""
        self.cart.add_item("Apple", 1.99, 2)
        self.cart.add_item("Banana", 0.99, 3)
        expected = (1.99 * 2) + (0.99 * 3)
        assert self.cart.calculate_total() == expected

    def test_apply_discount_valid(self):
        """测试有效折扣"""
        self.cart.apply_discount(0.2)
        assert self.cart.discount == 0.2

    def test_apply_discount_invalid_low(self):
        """测试过低折扣"""
        with pytest.raises(ValueError, match="Discount must be between 0 and 1"):
            self.cart.apply_discount(-0.1)

    def test_apply_discount_invalid_high(self):
        """测试过高折扣"""
        with pytest.raises(ValueError, match="Discount must be between 0 and 1"):
            self.cart.apply_discount(1.1)

    def test_calculate_total_with_discount(self):
        """测试带折扣的总额计算"""
        self.cart.add_item("Book", 20.00)
        self.cart.apply_discount(0.1)
        assert self.cart.calculate_total() == 18.0

    def test_multiple_discounts(self):
        """测试多次设置折扣"""
        self.cart.add_item("Test", 100)
        self.cart.apply_discount(0.1)
        self.cart.apply_discount(0.2)
        assert self.cart.discount == 0.2
        assert self.cart.calculate_total() == 80.0
```

### 扩展挑战
1. 生成集成测试
2. 支持性能测试
3. 生成测试数据工厂
4. 实现测试覆盖率分析

---

## 综合项目练习

### 项目：构建完整的项目Agent体系

### 任务描述
为一个完整的Web应用项目创建一套Agent体系，包括代码审查、文档生成、测试生成和Bug修复功能。

### 项目结构
```
my-web-app/
├── .claude/
│   └── agents/
│       ├── code-reviewer.md
│       ├── doc-generator.md
│       ├── test-generator.md
│       └── bug-fixer.md
├── src/
│   ├── controllers/
│   ├── models/
│   └── utils/
└── tests/
```

### 实施步骤

1. **创建所有Agent文件**
2. **测试每个Agent的功能**
3. **建立Agent协作流程**
4. **优化Agent配置**

### 评估标准

- Agent是否能正确执行任务
- 输出格式是否统一规范
- 是否提高了开发效率
- 是否减少了代码质量问题

### 高级挑战

1. 创建自定义Agent领域特定功能
2. 实现Agent间的数据共享
3. 集成CI/CD自动化流程
4. 开发Agent性能监控

---

## 练习答案与解析

### 解答获取方式
1. 每个练习的参考答案已在练习中提供
2. 可以使用Agent来验证你的答案质量
3. 查看GitHub仓库获取完整示例

### 常见问题

**Q: Agent输出格式不统一怎么办？**
A: 在Agent配置中明确指定输出格式模板

**Q: Agent不能理解复杂任务怎么办？**
A: 将复杂任务分解为多个简单任务

**Q: 如何提高Agent的准确性？**
A: 提供清晰的指令和示例

### 学习建议

1. **循序渐进**：从简单的Agent开始
2. **实践为主**：多动手创建和使用Agent
3. **持续优化**：根据使用反馈改进Agent
4. **分享交流**：与团队分享优秀的Agent配置

## 总结

通过这4个练习，你应该已经掌握了：
- ✅ 创建自定义Agent的方法
- ✅ 编写有效的Agent指令
- ✅ 使用Agent解决实际问题
- ✅ 建立Agent协作工作流

继续探索更多Agent应用场景，不断提升开发效率！