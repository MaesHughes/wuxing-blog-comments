# ClaudeCode插件开发模板

> **作者**：大熊掌门
> **版本**：1.0.0
> **课程**：ClaudeCode纯干货教程第7课

## 🚀 快速开始

这是一个完整的ClaudeCode插件开发模板，包含常用的插件功能和最佳实践。

### 环境要求

- Node.js 16+
- ClaudeCode 2.0+
- TypeScript 4.9+

### 安装和运行

```bash
# 1. 安装依赖
npm install

# 2. 编译TypeScript
npm run compile

# 3. 调试插件
# 在ClaudeCode中按F5启动调试会话

# 4. 构建插件包
npm run package
```

## 📁 项目结构

```
plugin-template/
├── src/
│   ├── extension.ts          # 插件入口文件
│   ├── commands/             # 命令定义（可选）
│   ├── providers/            # 服务提供者（可选）
│   └── utils/                # 工具函数（可选）
├── snippets/                 # 代码片段定义
├── resources/                # 资源文件（可选）
├── test/                     # 测试文件
├── out/                      # 编译输出
├── package.json              # 插件配置
├── tsconfig.json             # TypeScript配置
├── .vscode/                   # ClaudeCode配置
│   ├── launch.json           # 调试配置
│   └── tasks.json            # 任务配置
└── README.md                 # 说明文档
```

## 🛠️ 功能特性

### 1. 命令注册

模板包含三个示例命令：

- `template.helloWorld` - 显示Hello World消息
- `template.showInfo` - 显示插件信息
- `template.createSnippet` - 从选中代码创建代码片段

**快捷键**：`Ctrl+Shift+H` (Mac: `Cmd+Shift+H`)

### 2. 配置管理

支持以下配置选项：

```json
{
    "template.greeting": "你好",
    "template.enableNotifications": true,
    "template.snippetPrefix": "tpl"
}
```

### 3. 代码补全

提供智能代码补全功能：

- `tpl-hello` - 插入Hello World代码
- `tpl-function` - 插入函数模板

### 4. 悬停提示

为模板相关关键词提供悬停提示。

### 5. 状态栏

在状态栏显示插件状态，点击可查看插件信息。

## 📝 开发指南

### 添加新命令

1. 在`package.json`的`contributes.commands`中声明命令：

```json
{
    "command": "template.myCommand",
    "title": "My Command",
    "category": "Template"
}
```

2. 在`extension.ts`中注册命令：

```typescript
const myCommand = claudecode.commands.registerCommand(
    'template.myCommand',
    () => {
        // 命令实现
    }
);
context.subscriptions.push(myCommand);
```

### 添加配置选项

1. 在`package.json`的`contributes.configuration`中添加配置：

```json
{
    "template.myOption": {
        "type": "boolean",
        "default": true,
        "description": "我的配置选项"
    }
}
```

2. 在代码中读取配置：

```typescript
const config = claudecode.workspace.getConfiguration('template');
const myOption = config.get('myOption', true);
```

### 创建代码片段

在`snippets/`目录下创建语言特定的片段文件：

```json
{
    "My Snippet": {
        "prefix": "my-snippet",
        "body": ["console.log('$1');"],
        "description": "My custom snippet"
    }
}
```

## 🧪 测试

```bash
# 运行测试
npm test

# 代码检查
npm run lint

# 监听模式编译
npm run watch
```

## 📦 发布

```bash
# 创建插件包
npm run package

# 发布到插件市场
npm run publish

# 发布到Open VSX
vsce publish --base-content-url https://open-vsx.org
```

## 🔧 自定义开发

### 修改插件信息

编辑`package.json`中的以下字段：

- `name` - 插件唯一标识
- `displayName` - 显示名称
- `description` - 插件描述
- `version` - 版本号
- `publisher` - 发布者

### 添加依赖

```bash
# 安装运行时依赖
npm install axios

# 安装开发依赖
npm install --save-dev @types/node
```

### 调试技巧

1. 使用`console.log()`输出调试信息
2. 使用ClaudeCode的调试器设置断点
3. 查看开发者控制台的输出

## 📚 学习资源

- [ClaudeCode插件开发官方文档](https://docs.claudecode.com)
- [插件API参考](https://docs.claudecode.com/api)
- [插件发布指南](https://docs.claudecode.com/publish)

## 🤝 贡献

欢迎提交Issue和Pull Request来改进这个模板！

## 📄 许可证

MIT License

---

> **提示**：这个模板是ClaudeCode纯干货教程第7课的学习材料，更多教程内容请关注"大熊掌门"。