# 第1课：30分钟快速上手ClaudeCode - 课件资源

## 📁 课件说明

本目录包含了《ClaudeCode纯干货教程》第1课的所有课件资源，配合课程正文使用。

## 课件内容

本目录包含了第1课《30分钟快速上手ClaudeCode》的所有课件材料：

### 1. 安装脚本 (`01-安装脚本.md`)
- Windows一键安装脚本 (install.bat)
- macOS/Linux一键安装脚本 (install.sh)
- 权限修复脚本
- 网络问题解决脚本
- API连接验证脚本
- 项目初始化脚本

### 2. 配置文件模板 (`02-配置文件模板.md`)
- 基础配置文件 (config.json)
- 简化配置文件 (config-simple.json)
- 性能优化配置 (config-performance.json)
- 安全配置 (config-secure.json)
- 前端开发配置 (config-frontend.json)
- 后端开发配置 (config-backend.json)
- 团队协作配置 (config-team.json)
- 环境变量配置 (.env)
- VS Code设置
- 环境变量设置脚本

### 3. 常见问题解决方案 (`03-常见问题解决方案.md`)
- Windows/macOS/Linux诊断命令
- command not found 错误解决
- 权限错误 (EACCES) 解决
- 网络连接问题解决
- API密钥问题诊断
- 版本冲突问题处理
- 完整清理脚本
- 性能优化配置
- 故障排除检查清单

## 使用说明

### 1. 安装ClaudeCode

```bash
# macOS/Linux
chmod +x install.sh
./install.sh

# Windows
# 双击运行 install.bat 或在CMD中执行
install.bat
```

### 2. 配置环境

```bash
# 1. 设置API密钥
export ANTHROPIC_API_KEY="你的API密钥"

# 2. 复制配置文件
cp config.json ~/.claude/

# 3. 初始化项目
./init-project.sh my-project
```

### 3. 遇到问题

根据错误类型查看对应的解决方案：
- 安装问题 → 查看 `01-安装脚本.md`
- 配置问题 → 查看 `02-配置文件模板.md`
- 运行问题 → 查看 `03-常见问题解决方案.md`

## 快速验证

安装完成后，运行以下命令验证：

```bash
# 1. 检查版本
claude --version

# 2. 测试对话
claude "你好，请介绍一下你自己"

# 3. 创建项目
mkdir test-project && cd test-project
claude init
```

## 注意事项

1. **API密钥安全**
   - 不要在代码中硬编码API密钥
   - 使用环境变量存储
   - 定期更换API密钥

2. **系统要求**
   - Node.js 18.0或更高版本
   - 至少2GB可用内存
   - 稳定的网络连接

3. **权限问题**
   - Windows建议使用管理员身份安装
   - macOS/Linux可能需要sudo权限
   - 遇到权限问题时参考解决方案

## 下一步

完成安装和配置后，可以：
1. 继续学习第2课《核心命令与高效操作》
2. 尝试创建第一个AI辅助项目
3. 探索高级配置选项

## 获取帮助

如果遇到本课件未覆盖的问题：
1. 查看官方文档：https://docs.anthropic.com
2. 加入社区讨论：https://community.anthropic.com
3. 搜索GitHub Issues：https://github.com/anthropics/claude-code

## 🔗 相关链接

- 课程正文：查看课程配套资源
- GitHub仓库：https://github.com/MaesHughes/wuxing-blog-comments
- 作者：大熊掌门 | 全平台搜索"大熊掌门"

## 📝 更新日志

- 2025-12-12：初始版本发布
- 包含Windows、macOS、Linux全平台支持
- 添加完整的问题解决方案

---

💡 **提示**：如果遇到问题，请先查看 `03-常见问题解决方案.md` 文件。