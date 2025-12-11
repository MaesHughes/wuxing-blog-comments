#!/usr/bin/env python3
"""
ClaudeCode 上下文管理工具
使用方法：python context-manager.py [选项]
"""

import json
import os
import sys
import argparse
from pathlib import Path
from typing import Dict, List, Any
from datetime import datetime
import shutil

try:
    from rich.console import Console
    from rich.table import Table
    from rich.tree import Tree
    from rich.panel import Panel
    from rich import print as rprint
    HAS_RICH = True
except ImportError:
    HAS_RICH = False
    print("Warning: rich not installed. Install with: pip install rich")

class ContextManager:
    def __init__(self):
        self.console = Console() if HAS_RICH else None
        self.current_dir = Path.cwd()
        self.claude_files = self._find_claude_files()

    def _find_claude_files(self) -> List[Path]:
        """查找所有的CLAUDE.md文件"""
        claude_files = []

        # 在当前目录查找
        if (self.current_dir / "CLAUDE.md").exists():
            claude_files.append(self.current_dir / "CLAUDE.md")

        # 在父目录查找
        parent = self.current_dir.parent
        while parent != parent.parent:
            if (parent / "CLAUDE.md").exists():
                claude_files.append(parent / "CLAUDE.md")
            parent = parent.parent

        return claude_files

    def list_contexts(self):
        """列出所有的上下文配置"""
        if not self.claude_files:
            print("未找到CLAUDE.md文件")
            return

        if HAS_RICH:
            table = Table(title="ClaudeCode 上下文配置")
            table.add_column("路径", style="cyan")
            table.add_column("项目名", style="green")
            table.add_column("技术栈", style="yellow")
            table.add_column("最后修改", style="magenta")

            for file_path in self.claude_files:
                info = self._parse_claude_file(file_path)
                table.add_row(
                    str(file_path.relative_to(self.current_dir)),
                    info.get("项目名", "未知"),
                    info.get("技术栈", "未知"),
                    self._get_file_mtime(file_path)
                )

            self.console.print(table)
        else:
            print("\nClaudeCode 上下文配置:")
            print("-" * 50)
            for file_path in self.claude_files:
                info = self._parse_claude_file(file_path)
                print(f"\n文件: {file_path}")
                print(f"项目: {info.get('项目名', '未知')}")
                print(f"技术栈: {info.get('技术栈', '未知')}")

    def _parse_claude_file(self, file_path: Path) -> Dict[str, str]:
        """解析CLAUDE.md文件提取信息"""
        info = {"项目名": "未知", "技术栈": "未知"}

        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()

            # 提取项目名称
            lines = content.split('\n')
            for line in lines:
                if line.startswith('**项目名称**：'):
                    info['项目名'] = line.split('：')[1].strip()
                elif line.startswith('### 前端技术') or line.startswith('### 后端技术'):
                    # 继续读取技术栈信息
                    continue
                elif line.startswith('- **框架**：') or line.startswith('- **运行时**：'):
                    tech = line.split('：')[1].strip()
                    if info['技术栈'] == '未知':
                        info['技术栈'] = tech
                    else:
                        info['技术栈'] += f", {tech}"
        except:
            pass

        return info

    def _get_file_mtime(self, file_path: Path) -> str:
        """获取文件修改时间"""
        try:
            mtime = file_path.stat().st_mtime
            return datetime.fromtimestamp(mtime).strftime("%Y-%m-%d %H:%M")
        except:
            return "未知"

    def create_context(self, project_type: str, project_name: str = None):
        """创建新的上下文配置"""
        if not project_name:
            project_name = Path.cwd().name

        target_file = Path.cwd() / "CLAUDE.md"

        if target_file.exists():
            overwrite = input(f"{target_file} 已存在，是否覆盖？(y/N): ")
            if overwrite.lower() != 'y':
                print("操作取消")
                return

        # 根据项目类型选择模板
        templates = {
            "react": self._get_react_template,
            "vue": self._get_vue_template,
            "node": self._get_node_template,
            "python": self._get_python_template,
            "go": self._get_go_template,
            "generic": self._get_generic_template
        }

        template_func = templates.get(project_type, templates["generic"])
        content = template_func(project_name)

        # 写入文件
        with open(target_file, 'w', encoding='utf-8') as f:
            f.write(content)

        print(f"✅ 已创建上下文配置: {target_file}")

    def _get_react_template(self, project_name: str) -> str:
        """React项目模板"""
        return f"""# React项目 - ClaudeCode配置

## 项目概述

**项目名称**：{project_name}
**项目类型**：React + TypeScript
**项目描述**：React前端应用
**开始日期**：{datetime.now().strftime('%Y-%m-%d')}

## 技术栈

### 前端技术
- **框架**：React 18.x
- **语言**：TypeScript
- **构建工具**：Vite / Webpack
- **UI库**：Ant Design / Material-UI
- **状态管理**：Redux Toolkit / Zustand
- **路由**：React Router

### 开发工具
- **包管理**：npm / yarn / pnpm
- **代码规范**：ESLint + Prettier
- **测试框架**：Jest / Testing Library

## 项目结构
```
{project_name}/
├── src/
│   ├── components/    # 组件
│   ├── pages/        # 页面
│   ├── hooks/        # 自定义Hooks
│   ├── services/     # API服务
│   ├── utils/        # 工具函数
│   └── types/        # 类型定义
└── public/          # 静态资源
```

## 常用命令
```bash
npm run dev          # 开发服务器
npm run build        # 构建生产版本
npm run test         # 运行测试
npm run lint         # 代码检查
```

## ClaudeCode提示

### 项目初始化
```
请帮我初始化一个React项目：
- 使用TypeScript
- 配置Vite构建
- 集成Ant Design
- 设置Redux Toolkit
```

### 组件开发
```
创建一个用户登录组件：
- 包含用户名和密码输入
- 表单验证
- 登录按钮
- 错误提示
```

### 状态管理
```
设计用户认证的Redux状态：
- 包含登录状态
- 用户信息
- 错误处理
"""

    def _get_vue_template(self, project_name: str) -> str:
        """Vue项目模板"""
        return f"""# Vue项目 - ClaudeCode配置

## 项目概述

**项目名称**：{project_name}
**项目类型**：Vue 3 + TypeScript
**项目描述**：Vue前端应用
**开始日期**：{datetime.now().strftime('%Y-%m-%d')}

## 技术栈

### 前端技术
- **框架**：Vue 3.x
- **语言**：TypeScript
- **构建工具**：Vite
- **UI库**：Element Plus / Vuetify
- **状态管理**：Pinia
- **路由**：Vue Router 4

## 项目结构
```
{project_name}/
├── src/
│   ├── components/    # 组件
│   ├── views/         # 页面
│   ├── composables/   # 组合式函数
│   ├── stores/        # Pinia状态
│   ├── api/          # API接口
│   └── utils/        # 工具函数
```

## 常用命令
```bash
npm run dev          # 开发服务器
npm run build        # 构建生产版本
npm run test         # 运行测试
```

## ClaudeCode提示

### 组件开发
```
创建一个商品卡片组件：
- 使用Composition API
- TypeScript类型定义
- 响应式设计
"""

    def _get_node_template(self, project_name: str) -> str:
        """Node.js项目模板"""
        return f"""# Node.js项目 - ClaudeCode配置

## 项目概述

**项目名称**：{project_name}
**项目类型**：Node.js + TypeScript
**项目描述**：Node.js后端API服务
**开始日期**：{datetime.now().strftime('%Y-%m-%d')}

## 技术栈

### 后端技术
- **运行时**：Node.js 18+
- **框架**：Express.js / Fastify
- **语言**：TypeScript
- **数据库**：MongoDB / PostgreSQL
- **ORM**：Mongoose / Prisma
- **认证**：JWT / Passport

### 开发工具
- **包管理**：npm / yarn
- **API文档**：Swagger
- **测试框架**：Jest / Supertest

## 项目结构
```
{project_name}/
├── src/
│   ├── controllers/    # 控制器
│   ├── models/         # 数据模型
│   ├── routes/         # 路由
│   ├── middleware/     # 中间件
│   ├── services/       # 业务逻辑
│   └── utils/          # 工具函数
```

## 常用命令
```bash
npm run dev          # 开发服务器
npm run build        # 构建TypeScript
npm run test         # 运行测试
npm start            # 生产模式
```

## ClaudeCode提示

### API开发
```
创建用户管理API：
- RESTful接口设计
- JWT认证
- 输入验证
- 错误处理
"""

    def _get_python_template(self, project_name: str) -> str:
        """Python项目模板"""
        return f"""# Python项目 - ClaudeCode配置

## 项目概述

**项目名称**：{project_name}
**项目类型**：Python Web应用
**项目描述**：Python后端服务
**开始日期**：{datetime.now().strftime('%Y-%m-%d')}

## 技术栈

### 后端技术
- **语言**：Python 3.9+
- **框架**：Django / FastAPI / Flask
- **数据库**：PostgreSQL / MySQL
- **ORM**：SQLAlchemy / Django ORM
- **API**：DRF / FastAPI自动生成

### 开发工具
- **包管理**：pip / poetry
- **虚拟环境**：venv / conda
- **代码格式**：black / isort
- **测试框架**：pytest

## 项目结构
```
{project_name}/
├── app/
│   ├── models/         # 数据模型
│   ├── views/          # 视图
│   ├── serializers/    # 序列化器
│   ├── urls/          # 路由
│   └── utils/          # 工具函数
```

## 常用命令
```bash
python manage.py runserver    # Django
uvicorn main:app --reload      # FastAPI
pytest                         # 运行测试
```

## ClaudeCode提示

### Django开发
```
创建Django博客应用：
- 文章模型
- 视图和URL
- 管理后台
- API接口
"""

    def _get_go_template(self, project_name: str) -> str:
        """Go项目模板"""
        return f"""# Go项目 - ClaudeCode配置

## 项目概述

**项目名称**：{project_name}
**项目类型**：Go Web服务
**项目描述**：Go语言后端API
**开始日期**：{datetime.now().strftime('%Y-%m-%d')}

## 技术栈

### 后端技术
- **语言**：Go 1.19+
- **框架**：Gin / Echo / Fiber
- **数据库**：PostgreSQL / MySQL
- **ORM**：GORM / sqlx
- **配置**：Viper
- **日志**：Logrus / Zap

### 开发工具
- **包管理**：Go Modules
- **工具**：Air / hot-reload
- **测试**：Go test
- **API文档**：Swagger

## 项目结构
```
{project_name}/
├── cmd/                # 应用入口
├── internal/           # 内部包
│   ├── handler/        # 处理器
│   ├── service/        # 服务
│   ├── repository/     # 仓储
│   └── model/          # 模型
├── pkg/                # 公共包
└── configs/            # 配置
```

## 常用命令
```bash
go run main.go        # 运行应用
go build -o app      # 构建应用
go test ./...        # 运行测试
go mod tidy          # 整理依赖
```

## ClaudeCode提示

### Go开发
```
创建RESTful API：
- Gin框架
- GORM集成
- 中间件使用
- 错误处理
"""

    def _get_generic_template(self, project_name: str) -> str:
        """通用项目模板"""
        return f"""# {project_name} - ClaudeCode配置

## 项目概述

**项目名称**：{project_name}
**项目类型**：通用项目
**项目描述**：{project_name}项目
**开始日期**：{datetime.now().strftime('%Y-%m-%d')}

## 技术栈

### 主要技术
- **语言**：[填写主要编程语言]
- **框架**：[填写使用框架]
- **数据库**：[填写数据库]
- **其他工具**：[填写其他工具]

## 项目结构
```
{project_name}/
├── src/                # 源代码
├── tests/              # 测试文件
├── docs/               # 文档
├── config/             # 配置文件
└── scripts/            # 脚本
```

## 常用命令
[填写常用命令]

## ClaudeCode提示

### 通用开发
```
请帮我：
1. 分析项目结构
2. 推荐最佳实践
3. 优化代码组织
"""

    def validate_context(self, file_path: str = None):
        """验证上下文配置"""
        if not file_path:
            if not self.claude_files:
                print("未找到CLAUDE.md文件")
                return
            file_path = str(self.claude_files[0])

        target_file = Path(file_path)
        if not target_file.exists():
            print(f"文件不存在: {target_file}")
            return

        # 验证内容
        with open(target_file, 'r', encoding='utf-8') as f:
            content = f.read()

        print(f"\n验证文件: {target_file}")
        print("=" * 50)

        # 检查必要章节
        required_sections = [
            "项目概述",
            "技术栈",
            "项目结构",
            "常用命令"
        ]

        for section in required_sections:
            if section in content:
                print(f"✅ 包含 {section}")
            else:
                print(f"❌ 缺少 {section}")

        # 统计信息
        lines = content.split('\n')
        print(f"\n文件统计:")
        print(f"- 总行数: {len(lines)}")
        print(f"- 代码块数: {content.count('```') // 2}")
        print(f"- 链接数: {content.count('[') + content.count(']') // 2}")

    def update_project_info(self, key: str, value: str):
        """更新项目信息"""
        if not self.claude_files:
            print("未找到CLAUDE.md文件")
            return

        file_path = self.claude_files[0]
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.readlines()

        # 查找并更新
        updated = False
        for i, line in enumerate(content):
            if f"**{key}**：" in line:
                content[i] = f"**{key}**：{value}\n"
                updated = True
                break

        if updated:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.writelines(content)
            print(f"✅ 已更新 {key}: {value}")
        else:
            print(f"❌ 未找到 {key}")

def main():
    parser = argparse.ArgumentParser(description='ClaudeCode 上下文管理工具')
    subparsers = parser.add_subparsers(dest='command', help='可用命令')

    # 列出命令
    list_parser = subparsers.add_parser('list', help='列出所有上下文配置')

    # 创建命令
    create_parser = subparsers.add_parser('create', help='创建新的上下文配置')
    create_parser.add_argument('type', choices=['react', 'vue', 'node', 'python', 'go', 'generic'],
                             help='项目类型')
    create_parser.add_argument('--name', help='项目名称')

    # 验证命令
    validate_parser = subparsers.add_parser('validate', help='验证上下文配置')
    validate_parser.add_argument('--file', help='指定文件路径')

    # 更新命令
    update_parser = subparsers.add_parser('update', help='更新项目信息')
    update_parser.add_argument('key', help='信息键名')
    update_parser.add_argument('value', help='信息值')

    args = parser.parse_args()

    # 执行命令
    manager = ContextManager()

    if args.command == 'list':
        manager.list_contexts()
    elif args.command == 'create':
        manager.create_context(args.type, args.name)
    elif args.command == 'validate':
        manager.validate_context(args.file)
    elif args.command == 'update':
        manager.update_project_info(args.key, args.value)
    else:
        parser.print_help()

if __name__ == '__main__':
    main()