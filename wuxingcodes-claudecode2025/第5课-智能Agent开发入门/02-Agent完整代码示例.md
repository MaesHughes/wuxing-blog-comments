# ClaudeCode Agent完整代码示例

本文档提供了实际的代码示例，展示如何使用不同的Agent完成具体的编程任务。

## 1. 代码审查示例

### 输入代码
```javascript
function getUserData(userId) {
    var user = database.query('SELECT * FROM users WHERE id = ' + userId);
    if (user) {
        return user.name + ' - ' + user.email;
    }
}
```

### 调用Agent
```bash
@code-reviewer 请审查这段代码
```

### Agent输出
```markdown
## 代码审查报告

### ✅ 优点
- 函数功能明确，名称清晰
- 基本的逻辑判断正确

### ⚠️ 需要改进的地方
1. **SQL注入风险**: 使用字符串拼接构建SQL查询，存在严重的SQL注入风险
2. **变量声明**: 使用了`var`而不是`const/let`
3. **错误处理**: 缺少对数据库查询异常的处理
4. **返回值**: 没有处理user为空的情况

### 🔧 建议的修改代码
```javascript
async function getUserData(userId) {
    // 参数验证
    if (!userId || typeof userId !== 'string') {
        throw new Error('Invalid userId parameter');
    }

    try {
        // 使用参数化查询防止SQL注入
        const query = 'SELECT * FROM users WHERE id = ?';
        const user = await database.query(query, [userId]);

        if (!user || user.length === 0) {
            return null; // 或返回默认值
        }

        return `${user.name} - ${user.email}`;
    } catch (error) {
        console.error('Database query error:', error);
        throw new Error('Failed to fetch user data');
    }
}
```

### 📊 整体评分
- 代码质量: ⭐⭐⭐
- 性能: ⭐⭐⭐
- 安全性: ⭐
```

## 2. 文档生成示例

### 输入代码
```python
class UserService:
    def __init__(self, db_connection):
        self.db = db_connection

    def create_user(self, username, email, age=None):
        if age and age < 18:
            raise ValueError("User must be at least 18 years old")

        user_id = self.db.insert(
            "INSERT INTO users (username, email, age) VALUES (?, ?, ?)",
            (username, email, age)
        )
        return user_id

    def get_user(self, user_id):
        return self.db.fetch_one(
            "SELECT * FROM users WHERE id = ?",
            (user_id,)
        )
```

### 调用Agent
```bash
@doc-generator 请为UserService类生成API文档
```

### Agent输出
```markdown
# UserService API Documentation

## Overview
UserService类负责用户数据的创建和查询操作。

## Class: UserService

### Constructor

```python
def __init__(self, db_connection)
```

初始化UserService实例。

**Parameters:**
- `db_connection` (DatabaseConnection): 数据库连接对象

---

## Methods

### create_user()

```python
def create_user(self, username, email, age=None) -> int
```

创建新用户。

**Parameters:**
- `username` (str): 用户名
- `email` (str): 用户邮箱
- `age` (int, optional): 用户年龄，默认为None

**Returns:**
- `int`: 新创建用户的ID

**Raises:**
- `ValueError`: 当年龄小于18岁时抛出

**Example:**
```python
service = UserService(db)
user_id = service.create_user("john_doe", "john@example.com", 25)
```

### get_user()

```python
def get_user(self, user_id) -> dict
```

根据用户ID获取用户信息。

**Parameters:**
- `user_id` (int): 用户唯一标识符

**Returns:**
- `dict`: 用户信息字典，包含所有用户字段

**Returns None** if user not found.

**Example:**
```python
user = service.get_user(123)
if user:
    print(f"User: {user['username']}")
```
```

## 3. 测试生成示例

### 输入代码
```java
public class Calculator {
    public int add(int a, int b) {
        return a + b;
    }

    public int divide(int a, int b) {
        return a / b;
    }

    public boolean isEven(int number) {
        return number % 2 == 0;
    }
}
```

### 调用Agent
```bash
@test-writer 请为Calculator类编写JUnit测试
```

### Agent输出
```java
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

class CalculatorTest {

    private Calculator calculator;

    @BeforeEach
    void setUp() {
        calculator = new Calculator();
    }

    @Test
    void testAdd() {
        // Test normal cases
        assertEquals(5, calculator.add(2, 3));
        assertEquals(0, calculator.add(-1, 1));
        assertEquals(100, calculator.add(50, 50));
    }

    @Test
    void testAddEdgeCases() {
        // Test with zero
        assertEquals(2, calculator.add(2, 0));
        assertEquals(-3, calculator.add(0, -3));
    }

    @Test
    void testDivide() {
        // Test normal cases
        assertEquals(5, calculator.divide(10, 2));
        assertEquals(2, calculator.divide(6, 3));
        assertEquals(-2, calculator.divide(-4, 2));
    }

    @Test
    void testDivideByZero() {
        // Test division by zero
        assertThrows(ArithmeticException.class,
                     () -> calculator.divide(10, 0));
    }

    @Test
    void testIsEven() {
        // Test even numbers
        assertTrue(calculator.isEven(0));
        assertTrue(calculator.isEven(2));
        assertTrue(calculator.isEven(100));

        // Test odd numbers
        assertFalse(calculator.isEven(1));
        assertFalse(calculator.isEven(3));
        assertFalse(calculator.isEven(99));
    }

    @Test
    void testIsEvenNegative() {
        // Test negative numbers
        assertTrue(calculator.isEven(-2));
        assertTrue(calculator.isEven(-100));
        assertFalse(calculator.isEven(-1));
        assertFalse(calculator.isEven(-3));
    }
}
```

## 4. Bug修复示例

### 错误信息
```
TypeError: Cannot read property 'name' of undefined
    at getUserInfo (app.js:15:25)
```

### 输入代码
```javascript
function getUserInfo(userId) {
    const user = database.getUser(userId);
    return {
        fullName: user.firstName + ' ' + user.lastName,
        email: user.email,
        age: user.age
    };
}
```

### 调用Agent
```bash
@bug-fixer 这段代码报错，帮我修复
```

### Agent输出
```markdown
## 问题分析

**错误类型**: TypeError
**错误位置**: app.js:15:25
**根本原因**:
- `database.getUser(userId)` 返回了 `undefined`（用户不存在）
- 尝试访问 `undefined.firstName` 导致错误
- 没有处理用户不存在的情况

## 修复方案

将代码修改为：

```javascript
function getUserInfo(userId) {
    const user = database.getUser(userId);

    // 检查用户是否存在
    if (!user) {
        return {
            error: 'User not found',
            fullName: 'Unknown User',
            email: 'N/A',
            age: null
        };
    }

    return {
        fullName: user.firstName + ' ' + user.lastName,
        email: user.email,
        age: user.age
    };
}

// 或者抛出错误
function getUserInfo(userId) {
    const user = database.getUser(userId);

    if (!user) {
        throw new Error(`User with ID ${userId} not found`);
    }

    return {
        fullName: user.firstName + ' ' + user.lastName,
        email: user.email,
        age: user.age
    };
}
```

## 验证步骤

1. **测试正常情况**：传入存在的用户ID
2. **测试边界情况**：传入不存在的用户ID
3. **测试数据类型**：确保传入正确的用户ID类型
4. **检查返回值**：验证返回对象的格式正确

## 预防措施

- 始终检查API返回的数据是否存在
- 使用可选链操作符 `?.` （ES2020+）
- 添加适当的错误处理
- 记录错误日志便于调试
```

## 5. 多Agent协作示例

### 开发流程示例

```bash
# 1. 先用代码审查Agent检查现有代码
@code-reviewer 请审查这个函数的实现

# 2. 使用文档生成Agent为API生成文档
@doc-generator 请为刚才的代码生成API文档

# 3. 用测试Agent编写测试用例
@test-writer 请为这个函数编写完整的测试

# 4. 最后用代码审查Agent检查测试代码质量
@code-reviewer 请审查刚才生成的测试代码
```

### 协作输出

1. **代码审查Agent**：发现3个性能问题，1个安全风险
2. **文档生成Agent**：生成标准的API文档
3. **测试Agent**：编写了15个测试用例，覆盖率95%
4. **代码审查Agent**：测试代码质量良好，无严重问题

## 实际项目应用

### React组件审查示例

```javascript
// 输入的React组件
import React, { useState } from 'react';

function UserList() {
    const [users, setUsers] = useState([]);

    useEffect(() => {
        fetchUsers().then(setUsers);
    }, []);

    return (
        <div>
            {users.map(user => (
                <div key={user.id}>
                    <h3>{user.name}</h3>
                    <p>{user.email}</p>
                    <button onClick={() => deleteUser(user.id)}>
                        Delete
                    </button>
                </div>
            ))}
        </div>
    );
}
```

### Agent审查输出
```markdown
## React组件审查报告

### ⚠️ 改进建议
1. **依赖导入**: 缺少 `useEffect` 导入
2. **错误处理**: fetchUsers 需要错误处理
3. **性能优化**: 使用 React.memo 或 useCallback
4. **加载状态**: 添加加载状态提示
5. **空状态处理**: 处理 users 为空的情况

### 📋 优化后的代码
[提供完整的优化代码示例]
```

## 使用技巧

1. **批量处理**：可以同时处理多个相关任务
2. **链式调用**：Agent的输出可以作为下一个Agent的输入
3. **上下文保持**：在同一次对话中，Agent会保持上下文
4. **自定义输出**：可以通过指令指定输出格式和内容

## 总结

这些示例展示了Agent在实际开发中的应用场景。通过合理使用不同的Agent，可以大大提高开发效率和代码质量。记住要根据具体需求选择合适的Agent，并根据反馈持续优化Agent配置。