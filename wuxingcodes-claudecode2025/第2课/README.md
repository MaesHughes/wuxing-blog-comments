# ClaudeCode纯干货教程第2课课件

> **配套课程**：ClaudeCode纯干货教程第2课-核心命令与高效操作
> **课程仓库**：wuxingcodes-claudecode2025/
> **作者**：大熊掌门 | 全平台搜索"大熊掌门"关注更多内容

## 📁 课件目录结构

```
第2课/
├── README.md                    # 课件说明文档
├── 01-核心命令速查表.md          # Top 10命令详细说明
├── 02-快捷键参考.md              # 所有快捷键汇总
├── 03-项目配置模板/              # 项目管理模板
│   ├── CLAUDE.md.template       # 项目配置模板
│   ├── pre-commit-hook.sh       # Git钩子脚本
│   └── github-actions.yml       # CI/CD配置
├── 04-MCP服务器配置/             # MCP集成配置
│   ├── mcp-config.json          # 通用MCP配置
│   ├── github-mcp.json          # GitHub集成配置
│   └── database-mcp.json        # 数据库集成配置
├── 05-自动化脚本/                # 效率提升脚本
│   ├── batch-review.sh          # 批量代码审查脚本
│   ├── project-init.sh          # 项目初始化脚本
│   └── performance-check.sh     # 性能检查脚本
└── 07-高级效率技巧详解.md        # 正文高级技巧详细版本
```

## 🚀 快速开始

### 1. 复制配置模板
```bash
# 复制项目配置模板到你的项目
cp 03-项目配置模板/CLAUDE.md.template your-project/CLAUDE.md
cp 03-项目配置模板/pre-commit-hook.sh your-project/.git/hooks/pre-commit
```

### 2. 配置MCP服务器
```bash
# 复制MCP配置文件
cp 04-MCP服务器配置/mcp-config.json ~/.claude/mcp_servers.json
cp 04-MCP服务器配置/github-mcp.json ~/.claude/servers/github.json

# MCP服务器安装说明
# 大多数MCP服务器需要通过npm全局安装
npm install -g @modelcontextprotocol/server-github
npm install -g @modelcontextprotocol/server-filesystem
npm install -g @modelcontextprotocol/server-sqlite

# 或者使用yarn
yarn global add @modelcontextprotocol/server-github
yarn global add @modelcontextprotocol/server-filesystem
yarn global add @modelcontextprotocol/server-sqlite

# 验证安装
mcp list servers
```

### 3. 运行自动化脚本
```bash
# 给脚本执行权限
chmod +x *.sh
chmod +x 05-自动化脚本/*.sh

# 运行项目初始化
./05-自动化脚本/project-init.sh
```

## 📖 使用说明

1. **命令速查表**：学习核心命令的详细用法和参数
2. **快捷键参考**：掌握所有快捷键操作，提升效率
3. **项目模板**：直接复制使用，快速启动新项目
4. **MCP配置**：集成外部服务，扩展ClaudeCode功能
5. **自动化脚本**：一键执行常见任务，节省时间
6. **高级效率技巧详解**：正文简化版本的完整详细内容，包含：
   - MCP服务器深度集成配置
   - 自动化工作流构建实例
   - 高级生产力技巧应用
   - 调试和优化最佳实践

## 🎯 学习建议

1. **循序渐进**：先掌握基础命令，再学习高级技巧
2. **实践为主**：每个命令都要亲手操作验证
3. **定制优化**：根据个人需求调整配置和脚本
4. **持续更新**：关注新功能，定期更新工具链

## ❓ 问题反馈

如果在使用课件过程中遇到问题，请：
1. 检查课程正文的详细说明
2. 查看官方文档获取最新信息
3. 在课程仓库提交issue
4. 联系作者获取帮助

---

**祝你学习愉快，快速提升AI编程效率！**