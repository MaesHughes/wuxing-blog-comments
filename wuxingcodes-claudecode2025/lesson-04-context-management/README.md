# 第4课配套资源 - 项目初始化和上下文管理

> **作者**：大熊掌门 | 全平台搜索"大熊掌门"关注更多内容

## 📁 资源说明

这些都是我踩了无数坑总结出来的模板和工具，帮你少走弯路！每次新项目我都直接用这些，省下好多时间。

### 📂 文件结构

```
lesson-04-context-management/
├── README.md                    # 本文件
├── examples/                    # 示例项目
│   ├── react-project/          # React项目示例
│   ├── node-api/               # Node.js API示例
│   └── vue-project/            # Vue项目示例
├── templates/                   # 项目模板
│   ├── CLAUDE.md                # Claude配置文件模板
│   ├── project-context.json    # 项目上下文模板
│   └── coding-standards.md     # 编码规范模板
├── configs/                     # 配置文件示例
│   ├── claude_desktop_config.json  # Claude配置示例
│   └── context-examples/           # 上下文配置示例
├── tools/                       # 管理工具
│   ├── context-manager.py       # Python上下文管理工具
│   ├── project-init.sh          # 项目初始化脚本
│   └── config-validator.js      # 配置验证工具
└── docs/                        # 文档
    ├── best-practices.md        # 最佳实践
    └── troubleshooting.md       # 常见问题
```

## 🚀 快速开始

### 1. 选择项目模板

```bash
# 复制React项目模板
cp -r examples/react-project my-react-app
cd my-react-app

# 复制Node.js API模板
cp -r examples/node-api my-node-api
cd my-node-api

# 复制Vue项目模板
cp -r examples/vue-project my-vue-app
cd my-vue-app
```

### 2. 初始化项目配置

```bash
# 使用初始化脚本
../tools/project-init.sh

# 或手动复制配置
cp ../templates/CLAUDE.md ./
cp ../configs/claude_desktop_config.json ~/.claude/
```

### 3. 配置项目上下文

```bash
# 编辑CLAUDE.md文件
vim CLAUDE.md

# 验证配置
node ../tools/config-validator.js
```

## 📖 使用说明

### 项目模板说明

#### React项目模板
- 完整的React + TypeScript项目结构
- 预配置的开发工具链
- CLAUDE.md配置示例

#### Node.js API模板
- Express.js REST API结构
- 数据库集成示例
- 测试框架配置

#### Vue项目模板
- Vue 3 + Composition API
- TypeScript支持
- Vite构建配置

### 配置文件说明

#### CLAUDE.md
项目的"AI说明书"，包含：
- 项目概述和技术栈
- 编码规范和约定
- 常用命令和脚本
- 团队协作指南

#### context-examples/
各种场景的上下文配置示例：
- 大型项目配置
- 多模块项目配置
- 团队项目配置

## 🛠️ 工具使用

### context-manager.py
Python编写的上下文管理工具：
```bash
# 安装依赖
pip install rich click

# 运行工具
python ../tools/context-manager.py --help
```

### project-init.sh
Bash项目初始化脚本：
```bash
# 使脚本可执行
chmod +x ../tools/project-init.sh

# 运行初始化
../tools/project-init.sh
```

## 💡 最佳实践

1. **上下文维护**
   - 定期更新CLAUDE.md
   - 保持项目描述准确
   - 及时更新技术栈信息

2. **配置管理**
   - 使用版本控制跟踪配置变更
   - 团队成员共享配置标准
   - 定期审查配置有效性

3. **项目初始化**
   - 使用模板快速启动
   - 根据项目需求定制配置
   - 建立项目检查清单

## 🤝 贡献

如果您有更好的项目模板或配置示例，欢迎提交Issue或Pull Request！

---

> **返回课程目录**：[../](../README.md)
> **作者主页**：全平台搜索"大熊掌门"