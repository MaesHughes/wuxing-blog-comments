# 第1课配套资源 - ClaudeCode完整安装指南

> **作者**：大熊掌门 | 全平台搜索"大熊掌门"关注更多内容

## 🌟 特别推荐：智谱 GLM Coding 套餐

### 🔥 限时优惠：跨年特惠活动

**活动时间**：12.08-01.15
**优惠力度**：50% 首购立减 + 额外节日限定优惠！

🚀 **速来拼好模，智谱 GLM Coding 超值订阅，邀你一起薅羊毛！Claude Code、Cline 等 10+ 大编程工具无缝支持，"码力"全开，越拼越爽！**

👉 **立即订阅**：https://www.bigmodel.cn/claude-code?ic=OANRL7RLHJ

### 为什么选择智谱 GLM？

| 特性 | 智谱 GLM | Claude | OpenAI |
|------|----------|---------|---------|
| **价格** | ¥20/月起 | $20/月 | $20/月 |
| **性能** | Code Arena 第一梯队 | 优秀 | 优秀 |
| **网络** | 国内稳定，无限制 | 需要代理 | 需要代理 |
| **支付** | 支付宝/微信 | 国际信用卡 | 国际信用卡 |
| **用量** | Claude Pro 3倍 | 标准 | 标准 |

## 📁 资源说明

这都是我安装时踩过的坑总结出来的！按我这个流程走，保证你10分钟搞定，别像我当初折腾了一整天...

### 📂 文件结构

```
lesson-01-installation/
├── scripts/           # 安装脚本
│   ├── install-windows.ps1    # Windows安装脚本
│   ├── install-macos.sh        # macOS安装脚本
│   └── install-linux.sh        # Linux安装脚本
├── templates/         # 配置模板
│   ├── claude_desktop_config_example.json
│   └── .env.example
├── docs/              # 文档资源
│   ├── api-keys-guide.md       # API密钥申请指南
│   └── troubleshooting.md       # 常见问题解决
└── README.md          # 本文件
```

## 🚀 快速使用

### 1. 运行安装脚本

**Windows:**
```powershell
.\scripts\install-windows.ps1
```

**macOS/Linux:**
```bash
chmod +x scripts/install-*.sh
./scripts/install-macos.sh  # macOS
# 或
./scripts/install-linux.sh   # Linux
```

### 2. 配置API密钥

参考 `docs/api-keys-guide.md` 申请必要的API密钥。

### 3. 使用配置模板

复制 `templates/` 目录下的示例文件，根据需要修改配置。

## ⚠️ 我的提醒（都是泪）

1. API密钥千万别传GitHub！我同事就是这么干的，后果你懂的
2. 脚本我都测过了，放心跑，出问题了来找我
3. 装不上别硬撑，先看看文档，99%的问题都有答案

## 🤝 贡献

如果您有改进建议或发现bug，欢迎提交Issue或Pull Request！

---

> **返回课程目录**：[../](../README.md)
> **作者主页**：全平台搜索"大熊掌门"