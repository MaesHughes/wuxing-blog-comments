# React项目 - ClaudeCode配置示例

## 项目概述

**项目名称**：React商城示例
**项目类型**：React + TypeScript + Ant Design
**项目描述**：一个使用React和TypeScript构建的电商网站前端示例
**开始日期**：2024-01-15

## 技术栈

### 前端技术
- **框架**：React 18.2.0
- **语言**：TypeScript 4.9+
- **构建工具**：Vite 4.5
- **UI库**：Ant Design 5.12
- **状态管理**：Redux Toolkit 1.9.7
- **路由**：React Router 6.20
- **HTTP客户端**：Axios 1.6
- **日期处理**：Day.js 1.11

## 项目结构

```
react-project/
├── public/                    # 静态资源
├── src/
│   ├── components/          # 可复用组件
│   │   ├── common/         # 通用组件
│   │   ├── layout/         # 布局组件
│   │   └── forms/          # 表单组件
│   ├── pages/              # 页面组件
│   │   ├── Home/           # 首页
│   │   ├── Products/       # 商品页
│   │   └── Cart/           # 购物车
│   ├── store/              # Redux状态管理
│   │   ├── slices/         # Redux切片
│   │   └── api/            # API端点
│   ├── hooks/              # 自定义Hooks
│   ├── services/           # API服务
│   ├── utils/              # 工具函数
│   ├── types/              # TypeScript类型
│   ├── assets/             # 静态资源
│   ├── App.tsx             # 根组件
│   └── main.tsx            # 入口文件
├── package.json
├── tsconfig.json
├── vite.config.ts
└── CLAUDE.md
```

## 编码规范

### 组件编写原则
```typescript
// 使用函数组件 + TypeScript
interface ProductCardProps {
  product: Product;
  onAddToCart: (id: string) => void;
}

export const ProductCard: React.FC<ProductCardProps> = ({
  product,
  onAddToCart
}) => {
  // 使用自定义Hooks
  const { isInCart, toggleCart } = useCart(product.id);

  return (
    <Card>
      {/* 组件内容 */}
    </Card>
  );
};
```

### Redux切片示例
```typescript
// store/slices/productSlice.ts
interface ProductState {
  products: Product[];
  loading: boolean;
  error: string | null;
}

const initialState: ProductState = {
  products: [],
  loading: false,
  error: null,
};

export const productSlice = createSlice({
  name: 'products',
  initialState,
  reducers: {
    setLoading: (state, action) => {
      state.loading = action.payload;
    },
    // 其他reducers...
  },
});
```

## 常用命令

```bash
npm run dev          # 启动开发服务器 (http://localhost:5173)
npm run build        # 构建生产版本
npm run preview      # 预览构建结果
npm run lint         # ESLint代码检查
npm run type-check   # TypeScript类型检查
npm run test         # 运行测试
```

## 开发指南

### 添加新页面
1. 在 `src/pages/` 创建页面组件目录
2. 创建 `index.tsx` 和 `styles.module.css`
3. 在路由配置中添加路由
4. 更新导航菜单

### 添加新组件
1. 选择合适的组件目录
2. 创建组件文件和类型定义
3. 编写组件逻辑
4. 添加单元测试

### API集成
1. 在 `store/api/` 定义API端点
2. 创建异步Thunk
3. 在组件中dispatch action
4. 处理加载和错误状态

## 项目特色

### 1. TypeScript严格模式
- 所有组件都有完整的类型定义
- 使用接口定义Props和State
- 严格的类型检查

### 2. 模块化状态管理
- 使用Redux Toolkit的createSlice
- 按功能模块组织状态
- 异步操作处理

### 3. 组件复用设计
- 通用组件放在common目录
- 使用Props控制组件行为
- 支持主题定制

## ClaudeCode集成提示

### 项目理解提示词
```
请分析这个React电商项目：
- 技术栈和架构特点
- 组件组织结构
- 状态管理方案
- 路由配置
```

### 代码生成提示词
```
请创建一个新的产品详情页组件，要求：
- 使用TypeScript定义Props
- 集成Redux获取产品数据
- 包含加入购物车功能
- 使用Ant Design组件库
```

### 问题排查提示词
```
帮助我排查这个错误：
[粘贴错误信息]
可能的原因和解决方案？
```

## 最佳实践

### 1. 组件设计
- 单一职责原则
- Props最小化
- 状态提升
- 避免过度嵌套

### 2. 性能优化
- 使用React.memo
- useMemo/useCallback优化
- 代码分割和懒加载
- 虚拟滚动长列表

### 3. 代码质量
- 100% TypeScript覆盖
- ESLint规则严格
- 单元测试覆盖
- 代码审查流程

## 团队协作

### Git工作流
```bash
# 功能开发
git checkout -b feature/product-filter
git add .
git commit -m "feat(product): 添加商品筛选功能"
git push origin feature/product-filter

# 创建Pull Request
# 代码审查
# 合并到main分支
```

### 代码审查要点
- TypeScript类型正确性
- 组件可复用性
- 性能优化建议
- 安全性检查

---

> **维护者**：大熊掌门
> **更新时间**：2024-01-15