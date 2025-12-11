# 第5课配套资源 - 文件操作和项目管理

> **作者**：大熊掌门 | 全平台搜索"大熊掌门"关注更多内容

## 📁 资源说明

本目录包含第5课《文件操作和项目管理》的所有配套代码和示例，帮助您快速掌握ClaudeCode的文件操作能力。

### 📂 文件结构

```
lesson-05-file-operations/
├── examples/              # 示例代码
│   ├── basic-operations/   # 基础文件操作示例
│   ├── project-analysis/   # 项目结构分析示例
│   ├── batch-operations/   # 批量操作示例
│   └── search-navigate/    # 搜索和导航示例
├── scripts/               # 实用脚本
│   ├── batch-rename.sh    # 批量重命名脚本
│   ├── cleanup.sh         # 项目清理脚本
│   └── backup.sh          # 备份脚本
├── templates/             # 文件模板
│   ├── package.json       # Node.js项目模板
│   ├── .gitignore         # Git忽略文件模板
│   └── eslintrc.js        # ESLint配置模板
├── sample-project/        # 示例项目
│   ├── src/              # 源代码
│   ├── tests/            # 测试文件
│   └── docs/             # 文档
└── README.md             # 本文件
```

## 🚀 快速使用

### 1. 查看示例代码

```bash
# 基础文件操作
cd examples/basic-operations
ls -la

# 项目结构分析
cd examples/project-analysis
ls -la

# 批量操作
cd examples/batch-operations
ls -la
```

### 2. 运行示例脚本

```bash
# 项目清理
chmod +x ../scripts/cleanup.sh
../scripts/cleanup.sh

# 批量重命名（谨慎使用）
chmod +x ../scripts/batch-rename.sh
../scripts/batch-rename.sh
```

### 3. 使用文件模板

```bash
# 复制模板到你的项目
cp templates/.gitignore ./
cp templates/eslintrc.js ./
```

## 📖 使用说明

### 基础文件操作

在 `examples/basic-operations/` 中包含：
- 文件读取示例
- 文件创建示例
- 文件修改示例
- 权限处理示例

### 项目结构分析

在 `examples/project-analysis/` 中包含：
- React项目结构示例
- Node.js项目分析
- 依赖关系图
- 技术栈识别

### 批量操作

在 `examples/batch-operations/` 中包含：
- ES5到ES6迁移
- 代码格式化
- 批量添加头注释
- 文件编码转换

## ⚠️ 注意事项

1. **批量操作前务必备份**
2. **在测试环境先验证脚本**
3. **仔细检查文件路径**
4. **重要数据提前备份**

## 🛠️ 自定义脚本

你可以基于这些脚本创建自己的定制版本：

```bash
# 创建自定义清理脚本
cp scripts/cleanup.sh scripts/my-cleanup.sh
vim scripts/my-cleanup.sh  # 编辑你的规则
```

## 🤝 贡献

如果您有更好的示例或脚本，欢迎提交Issue或Pull Request！

---

> **返回课程目录**：[../](../README.md)
> **作者主页**：全平台搜索"大熊掌门"