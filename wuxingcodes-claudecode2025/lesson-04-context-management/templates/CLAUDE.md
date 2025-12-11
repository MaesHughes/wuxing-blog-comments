# 项目上下文配置

这是一个使用ClaudeCode的项目配置模板。复制此文件到你的项目根目录，并根据项目情况修改内容。

## 项目概述

**项目名称**：[你的项目名称]
**项目类型**：[React/Vue/Node.js/其他]
**项目描述**：[简要描述项目的主要功能和目标]
**开始日期**：[YYYY-MM-DD]

## 技术栈

### 前端技术
- **框架**：React 18.2.0 / Vue 3.3.0
- **语言**：TypeScript 4.9+
- **构建工具**：Vite 4.3+ / Webpack 5
- **UI库**：Ant Design / Element Plus / Tailwind CSS
- **状态管理**：Redux Toolkit / Pinia / Zustand
- **路由**：React Router 6 / Vue Router 4

### 后端技术
- **运行时**：Node.js 18+
- **框架**：Express.js / Koa.js / Nest.js
- **数据库**：MongoDB / PostgreSQL / MySQL
- **ORM**：Mongoose / Prisma / TypeORM
- **认证**：JWT / Passport.js
- **缓存**：Redis / Memcached

### 开发工具
- **包管理**：npm / yarn / pnpm
- **代码规范**：ESLint + Prettier
- **测试框架**：Jest / Vitest / Cypress
- **CI/CD**：GitHub Actions / GitLab CI
- **容器化**：Docker + Docker Compose

## 项目结构

```
[项目名称]/
├── src/                      # 源代码
│   ├── components/          # 可复用组件
│   ├── pages/              # 页面组件
│   ├── hooks/              # 自定义Hooks
│   ├── services/           # API服务
│   ├── utils/              # 工具函数
│   ├── types/              # TypeScript类型
│   └── assets/             # 静态资源
├── tests/                    # 测试文件
├── docs/                     # 项目文档
├── scripts/                  # 构建脚本
├── public/                   # 公共资源
├── package.json             # 项目配置
├── tsconfig.json            # TypeScript配置
├── vite.config.js           # 构建配置
└── README.md                # 项目说明
```

## 编码规范

### 命名约定
- **文件名**：kebab-case（user-profile.tsx）
- **组件名**：PascalCase（UserProfile）
- **变量名**：camelCase（userName）
- **常量名**：UPPER_SNAKE_CASE（API_BASE_URL）
- **类型名**：PascalCase（UserProfile）

### 代码风格
- 使用2空格缩进
- 使用单引号
- 语句末尾加分号
- 对象和数组使用尾随逗号
- 函数使用箭头函数（除非需要this）

### 组件规范
- 使用函数组件 + Hooks
- 组件文件导出默认组件
- Props使用TypeScript接口定义
- 复杂逻辑提取到自定义Hooks

### Git提交规范
```
<类型>(<范围>): <描述>

[可选的正文]

[可选的脚注]
```

类型：feat, fix, docs, style, refactor, test, chore
范围：影响的功能模块

## 常用命令

### 开发命令
```bash
npm run dev          # 启动开发服务器
npm run build        # 构建生产版本
npm run preview      # 预览生产构建
npm run test         # 运行测试
npm run lint         # 代码检查
npm run format       # 代码格式化
```

### 实用命令
```bash
npm run db:seed      # 数据库种子
npm run db:migrate   # 数据库迁移
npm run docs:dev     # 文档开发服务器
npm run deploy       # 部署到生产环境
```

## 开发流程

1. **功能开发**
   - 创建功能分支：`git checkout -b feature/功能名`
   - 编写代码和测试
   - 运行测试确保通过
   - 提交代码并创建PR

2. **代码审查**
   - 自测功能完整性
   - 确保测试覆盖率
   - 更新相关文档
   - 等待代码审查

3. **发布流程**
   - 合并到主分支
   - 创建发布标签
   - 触发CI/CD流程
   - 验证发布版本

## 团队协作

### 分工原则
- **前端**：负责UI/UX实现和用户交互
- **后端**：负责API设计和业务逻辑
- **测试**：负责测试用例和质量保证
- **运维**：负责部署和监控

### 沟通方式
- **日常沟通**：使用Slack/钉钉
- **任务管理**：使用Jira/Trello
- **代码审查**：使用GitHub/GitLab
- **文档协作**：使用Confluence/Notion

### 代码所有权
- 每个模块指定负责人
- 重大改动需要多人审查
- 保持代码的可维护性
- 及时更新技术文档

## 部署说明

### 环境配置
- **开发环境**：http://dev.example.com
- **测试环境**：http://test.example.com
- **预生产环境**：http://staging.example.com
- **生产环境**：http://example.com

### 环境变量
```bash
# 必需的环境变量
NODE_ENV=production
PORT=3000
DATABASE_URL=mongodb://localhost:27017/myapp
JWT_SECRET=your-secret-key

# 可选的环境变量
REDIS_URL=redis://localhost:6379
SMTP_HOST=smtp.gmail.com
SENTRY_DSN=your-sentry-dsn
```

## 注意事项

### 安全要求
- 所有API必须验证身份
- 敏感数据必须加密
- 定期更新依赖包
- 使用HTTPS协议

### 性能要求
- 首屏加载时间 < 3秒
- API响应时间 < 500ms
- 图片使用WebP格式
- 实现代码分割和懒加载

### 可访问性
- 遵循WCAG 2.1 AA标准
- 提供键盘导航支持
- 图片添加alt属性
- 使用语义化HTML标签

## 常见问题

### Q: 如何添加新的依赖？
A: 使用 `npm install 包名` 安装，确保在package.json中记录版本号。

### Q: 如何处理环境变量？
A: 创建.env文件，使用dotenv库加载，不要提交.env到版本控制。

### Q: 如何优化项目性能？
A: 使用性能分析工具，优化关键路径，实现缓存策略。

## 联系方式

- **项目负责人**：[姓名] <[email]>
- **技术支持**：[邮箱] / [Slack频道]
- **问题反馈**：[GitHub Issues链接]

---

> **最后更新**：[更新日期]
> **维护者**：[维护者姓名]