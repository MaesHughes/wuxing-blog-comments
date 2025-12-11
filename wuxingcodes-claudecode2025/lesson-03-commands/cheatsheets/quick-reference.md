# ClaudeCode 命令速查表

> **作者**：大熊掌门 | 全平台搜索"大熊掌门"关注更多内容

## 🚀 基础命令（必会！）

### 启动 ClaudeCode
```bash
# 默认启动
claudecode

# 指定工作目录
claudecode /path/to/project

# 使用特定配置文件
claudecode --config /path/to/config.json
```

### 退出
```bash
# 正常退出
exit
Ctrl+C

# 强制退出
Ctrl+D
```

## 📝 基础提示词命令

### 单行模式
```bash
# 最简单的使用方式
claudecode "写一个Python hello world"

# 带参数
claudecode "解释这段代码" /path/to/file.py

# 生成代码
claudecode "创建一个REST API"
```

### 交互模式
```bash
# 进入交互模式
claudecode

# 或使用 -i 参数
claudecode -i
```

## ⚙️ 常用选项

### 配置选项
```bash
# 显示配置
claudecode --config

# 指定配置文件
claudecode --config-file /path/to/config.json

# 设置模型
claudecode --model claude-3-5-sonnet

# 设置温度
claudecode --temperature 0.7
```

### 输出选项
```bash
# 输出到文件
claudecode "生成代码" > output.py

# 追加到文件
claudecode "添加功能" >> existing.py

# 不显示颜色
claudecode --no-color
```

### 调试选项
```bash
# 详细输出
claudecode --verbose

# 调试模式
claudecode --debug

# 静默模式
claudecode --quiet
```

## 🔧 项目管理

### 初始化项目
```bash
# 在当前目录初始化
claudecode --init

# 指定项目类型
claudecode --init --type python
claudecode --init --type react
claudecode --init --type node
```

### 上下文管理
```bash
# 添加文件到上下文
claudecode --add file.py

# 移除文件
claudecode --remove file.py

# 查看上下文
claudecode --context

# 清空上下文
claudecode --clear
```

### 项目配置
```bash
# 查看项目配置
claudecode --project-config

# 编辑配置
claudecode --edit-config

# 重置项目
claudecode --reset
```

## 🎯 高级功能

### 批处理
```bash
# 处理多个文件
claudecode --batch file1.py file2.py file3.py

# 使用脚本文件
claudecode --script commands.txt
```

### 模板系统
```bash
# 列出模板
claudecode --list-templates

# 使用模板
claudecode --template rest-api

# 创建模板
claudecode --create-template mytemplate
```

### 插件系统
```bash
# 列出插件
claudecode --list-plugins

# 启用插件
claudecode --enable plugin-name

# 禁用插件
claudecode --disable plugin-name
```

## 🎨 界面控制

### 编辑器集成
```bash
# VS Code集成
claudecode --editor vscode

# Vim集成
claudecode --editor vim

# Emacs集成
claudecode --editor emacs
```

### 显示选项
```bash
# 彩色输出
claudecode --color

# 无颜色
claudecode --no-color

# 紧凑模式
claudecode --compact
```

## 📚 帮用快捷键

### 命令行快捷键
- `Ctrl+C` - 中断当前操作
- `Ctrl+D` - EOF（结束输入）
- `Tab` - 自动补全（如果启用）
- `↑/↓` - 浏览命令历史

### 交互模式快捷键
- `Ctrl+C` - 中断生成
- `Ctrl+R` - 搜索历史
- `Ctrl+L` - 清屏
- `Ctrl+D` - 退出

## 🔍 帮助命令

### 获取帮助
```bash
# 显示帮助
claudecode --help

# 显示版本
claudecode --version

# 查看文档
claudecode --docs
```

### 查看示例
```bash
# 查看示例
claudecode --examples

# 查看特定功能的帮助
claudecode --help --init
```

## 💡 实用技巧

### 1. 创建别名
```bash
# Bash/Zsh
alias cc='claudecode'
alias cci='claudecode --init'
alias cca='claudecode --add'

# PowerShell
Set-Alias -Name cc -Value 'claudecode'
```

### 2. 使用历史
```bash
# 查看历史
history | grep claudecode

# 搜索历史
Ctrl+R 然后输入关键词
```

### 3. 快速启动项目
```bash
# 函数形式
function quickstart() {
  cd $1
  claudecode --init --type python
  claudecode --add README.md
  claudecode "请帮我分析这个项目"
}
```

## ⚠️ 注意事项

1. **API限制**：注意API调用频率限制
2. **上下文大小**：大文件可能超出上下文限制
3. **隐私保护**：不要输入敏感信息
4. **备份重要**：重要代码仍需要版本控制

## 🚨 故障排除

### 常见问题

1. **命令未找到**
   - 检查PATH环境变量
   - 确保已正确安装ClaudeCode

2. **API密钥错误**
   - 检查配置文件
   - 验证密钥有效性

3. **上下文错误**
   - 使用--clear清空上下文
   - 重新添加正确的文件

4. **响应慢**
   - 检查网络连接
   - 考虑优化prompt

---

> **完整版命令参考**：[advanced-commands.md](advanced-commands.md)
> **返回课程目录**：[../](../README.md)
> **作者主页**：全平台搜索"大熊掌门"