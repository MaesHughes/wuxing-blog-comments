# 第3课配套资源 - ClaudeCode核心命令大全

> **作者**：大熊掌门 | 全平台搜索"大熊掌门"关注更多内容

## 📁 资源说明

我敢说，这绝对是全网最全的ClaudeCode命令整理！我花了一周时间整理的，包括我自己常用的各种骚操作...

### 📂 文件结构

```
lesson-03-commands/
├── cheatsheets/        # 速查表
│   ├── claudecode-commands.pdf    # PDF版本速查表
│   ├── quick-reference.md         # Markdown版本速查表
│   └── advanced-commands.md        # 高级命令参考
├── aliases/            # 命令别名配置
│   ├── bash_aliases.sh            # Bash别名
│   ├── zsh_aliases.zsh           # Zsh别名
│   ├── powershell_aliases.ps1     # PowerShell别名
│   └── claude-alias.json          # ClaudeCode内部别名
├── history/            # 命令历史管理
│   ├── history-manager.py         # Python历史管理工具
│   ├── favorite-prompts.txt       # 常用prompt集合
│   └── prompt-templates.md        # Prompt模板
└── README.md           # 本文件
```

## 🚀 快速使用

### 1. 下载速查表

选择适合您的格式：
- **PDF版本**：`cheatsheets/claudecode-commands.pdf` - 适合打印
- **Markdown版本**：`cheatsheets/quick-reference.md` - 适合在线查看

### 2. 配置命令别名

根据您的shell类型复制对应的别名文件：
```bash
# Bash
cp aliases/bash_aliases.sh ~/.bash_aliases
source ~/.bash_aliases

# Zsh
cp aliases/zsh_aliases.zsh ~/.zshrc
source ~/.zshrc

# PowerShell
# 以管理员身份运行
.\aliases\powershell_aliases.ps1
```

### 3. 使用历史管理工具

```bash
# 安装依赖
pip install rich click

# 运行历史管理工具
python history/history-manager.py
```

## 📖 详细说明

### 速查表说明
- `quick-reference.md` - 基础命令速查，适合初学者
- `advanced-commands.md` - 高级命令详解，适合有经验的用户
- `claudecode-commands.pdf` - 打印友好的PDF版本

### 别名配置说明
- `bash_aliases.sh` - Linux/macOS Bash的别名配置
- `zsh_aliases.zsh` - macOS Zsh的别名配置
- `powershell_aliases.ps1` - Windows PowerShell的别名配置
- `claude-alias.json` - ClaudeCode内部命令别名

### 历史管理工具
- `history-manager.py` - 命令历史查看和管理
- `favorite-prompts.txt` - 常用的prompt示例
- `prompt-templates.md` - Prompt编写模板

## ⚡ 我的高效秘诀（珍藏版）

### 1. 懒人必备技巧
- 命令太长？起个别名啊！比如我把"创建React项目"设成了`cc-r`
- 常用的prompt我都存下来了，不用每次都想
- 模板？那是我压箱底的宝贝，99%的情况都能套用

### 2. 我的压箱底组合（一般人我不告诉）
```bash
# 新项目三连击（我每天都要用）
cc-new myproject && cc-init --template react && cc-add-context

# Bug修复模式（debug专用的）
cc-debug --verbose --save-log --auto-fix
```

### 3. 我的私藏别名
```bash
# 这些是我自己用的，超方便
alias cc-genie="claudecode --model 4.5 --speed fast"  # AI精灵模式
alias cc-careful="claudecode --review --strict"        # 代码审查模式
alias cc-quick="claudecode --no-context --simple"     # 快速模式
```

## 🤝 贡献

欢迎分享您的：
- 更多的命令别名
- 实用的prompt模板
- 命令使用技巧

---

> **返回课程目录**：[../](../README.md)
> **作者主页**：全平台搜索"大熊掌门"