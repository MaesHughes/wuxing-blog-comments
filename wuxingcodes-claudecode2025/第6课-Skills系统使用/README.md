# 第6课：Skills系统使用 - 实战操作指南

> **完整示例代码及扩充课件**：https://github.com/MaesHughes/wuxing-blog-comments
> **课程仓库**：`wuxingcodes-claudecode2025/`
> **作者**：大熊掌门 | 全平台搜索"大熊掌门"关注更多内容

## 📖 简单理解四种工具

### 一个例子看懂所有工具

开发用户注册功能的流程：

```
需求分析 → 设计阶段 → 编码实现 → 测试部署
Tools → MCP → Skills → Agents
```

### 每个工具做什么？

- **Tools**：查信息（搜索技术方案）
- **MCP**：取数据（查看数据库结构）
- **Skills**：生成代码（写具体功能）
- **Agents**：专业审查（安全、性能检查）

## 🚀 快速开始：5分钟上手Skills

### 第1步：创建目录结构
```bash
# 在你的项目根目录执行
mkdir -p .claude/skills
```

### 第2步：创建第一个Skill
```bash
# 创建Skill文件
touch .claude/skills/hello-world.md
```

### 第3步：编写Skill内容
复制以下内容到 `hello-world.md`：

```markdown
---
name: Hello World
description: 简单的问候Skill，演示基本功能
version: 1.0.0
tags: [demo, hello, basic]
---

# Hello World Skill

你是一个友好的助手，专门用中文问候用户。

## 功能
- 根据时间问候
- 提供鼓励的话语
- 记录用户姓名
```

### 第4步：测试Skill
在ClaudeCode中输入：
```bash
@hello-world
```

## 📋 Skills实际操作演示

### 演示1：代码格式化Skill

#### 创建文件
```bash
# 1. 创建Skill
touch .claude/skills/code-formatter.md

# 2. 写入内容（见下面的完整代码）
```

#### 完整代码
查看 `01-code-formatter-skill.md` 获取完整代码。

#### 测试命令
```bash
# 直接调用
@code-formatter 请格式化这段代码：
function calculate(a,b,c){return a+b+c}

# 自动识别
这段JS代码没有格式化，能帮我整理一下吗？
```

#### 预期输出
```javascript
function calculate(a, b, c) {
  return a + b + c;
}
```

### 演示2：API文档生成Skill

#### 测试代码
```javascript
// 准备测试的API代码
const express = require('express');
const router = express.Router();

// 获取用户信息
router.get('/users/:id', async (req, res) => {
  const user = await User.findById(req.params.id);
  res.json(user);
});
```

#### 测试命令
```bash
@api-doc-generator 请为这个API生成文档
```

### 演示3：学习路径规划Skill

#### 测试命令
```bash
@learning-planner 我想学习React开发，目前只会HTML/CSS/JS基础
```

## 🔧 Skills管理技巧

### 查看所有Skills
```bash
# 在ClaudeCode中询问
请列出当前可用的Skills

# 或者
有哪些Skills可以使用？
```

### 调试Skill
```bash
# 如果Skill没有触发
为什么code-formatter没有工作？

# 让Claude解释选择
请解释为什么选择这个Skill
```

### 更新Skill
1. 直接编辑 `.claude/skills/` 中的文件
2. 保存后自动生效
3. 无需重启ClaudeCode

## 💡 实战技巧

### 1. 让Claude自动选择Skill
```bash
# 描述任务，让Claude自动选择
这段代码有安全问题，需要专家审查
# Claude会自动调用 @code-reviewer
```

### 2. Skills链式调用
```bash
# 一次执行多个任务
@code-reviewer 审查代码后，@doc-generator 生成文档
```

### 3. 项目级配置
创建 `CLAUDE.md` 文件：
```markdown
# 项目说明

本项目使用以下Skills：
- @code-reviewer: 代码审查
- @test-generator: 测试生成
- @api-doc-generator: 文档生成
```

## 📁 文件说明

| 文件名 | 用途 | 快速使用 |
|--------|------|----------|
| `01-code-formatter-skill.md` | 代码格式化Skill | 复制到 `.claude/skills/` |
| `02-api-doc-generator-skill.md` | API文档生成Skill | 复制到 `.claude/skills/` |
| `03-learning-planner-skill.md` | 学习规划Skill | 复制到 `.claude/skills/` |
| `04-workflow-automation-skill.md` | 工作流自动化Skill | 复制到 `.claude/skills/` |
| `05-team-skills-suite.md` | 团队协作Skill套件 | 创建5个协同Skills |

## ❓ 常见问题

**Q: Skill放在哪里？**
A: 项目级放在 `.claude/skills/`，全局放在 `~/.claude/skills/`

**Q: 如何让Claude自动识别Skill？**
A: 确保description清晰（≤200字符），包含触发关键词

**Q: Skill不工作怎么办？**
A:
1. 检查文件路径
2. 使用@语法直接调用测试
3. 询问Claude原因

## 🎯 进阶应用

### 创建Skill组合
```bash
# 创建一个主Skill来协调其他Skills
@coordinator 执行代码审查流程
```

### 条件触发
在Skill中设置触发条件：
```markdown
如果任务包含"安全" → 调用@security-expert
如果任务包含"性能" → 调用@performance-optimizer
```

## 🎯 记住这个流程

```
需求分析 → 设计阶段 → 编码实现 → 测试部署
  ↓         ↓         ↓         ↓
Tools → MCP → Skills → Agents
```

记住：**查信息 → 取数据 → 写代码 → 审质量**

## 📖 延伸阅读

- [官方文档](https://code.claude.com/docs/en/skills)
- [社区Skills仓库](https://github.com/anthropics/skills)
- [最佳实践指南](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices)

---
**下一步**: 尝试创建你自己的Skill，从简单任务开始，逐步构建复杂的工作流！