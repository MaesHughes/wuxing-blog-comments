# 第2课配套资源 - ClaudeCode核心配置详解

> **作者**：大熊掌门 | 全平台搜索"大熊掌门"关注更多内容

## 📁 资源说明

这些都是我调配置调到深夜2点总结出来的！特别是那个高性能配置，我试了N种组合才找到最佳参数...

### 📂 文件结构

```
lesson-02-configuration/
├── templates/          # 配置文件模板
│   ├── claude_desktop_config.json
│   ├── claude_desktop_config_high_performance.json
│   ├── claude_desktop_config_minimal.json
│   ├── .env.example
│   └── mcp_servers_example.json
├── tools/              # 配置管理工具
│   ├── config-manager.py    # Python配置管理工具
│   ├── profile-switcher.js    # Node.js配置切换工具
│   └── validator.py           # 配置验证工具
├── profiles/           # 预设配置文件
│   ├── development.json    # 开发环境
│   ├── production.json     # 生产环境
│   ├── testing.json         # 测试环境
│   └── offline.json          # 离线环境
└── README.md           # 本文件
```

## 🚀 快速使用

### 1. 选择配置模板（别选错！）

听我的，按这个选，错不了：

- **刚开始玩**：用 `minimal.json`，简单稳定，不会懵
- **日常写代码**：用 `claude_desktop_config.json`，我一直在用
- **电脑配置好的**：试试 `high_performance.json`，速度起飞！

### 2. 使用配置管理工具

```bash
# Python 配置管理
python tools/config-manager.py --validate

# 切换配置文件
node tools/profile-switcher.js development
```

### 3. 导入预设配置

将 `profiles/` 目录下的预设配置复制到您的配置目录。

## 📖 详细说明

### 配置模板说明
- `claude_desktop_config.json` - 标准配置，适合大多数用户
- `high_performance.json` - 高性能配置，适合大量并发
- `minimal.json` - 最小配置，适合简单任务

### 工具使用指南
- `config-manager.py` - 验证和优化配置
- `profile-switcher.js` - 快速切换不同环境配置
- `validator.py` - 检查配置文件的正确性

## ⚠️ 我要叮嘱几句

1. API key换成你自己的！别用我的，我会断开的（开玩笑）
2. 电脑内存小的就别开高性能了，会卡成PPT（我试过）
3. 配置记得备份，我手贱重置过一次，哭死

## 🤝 贡献

欢迎提交更好的配置模板和工具！

---

> **返回课程目录**：[../](../README.md)
> **作者主页**：全平台搜索"大熊掌门"