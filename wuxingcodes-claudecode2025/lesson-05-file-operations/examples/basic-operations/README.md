# 基础文件操作示例

嘿，这些都是我平时用ClaudeCode操作文件时总结的实际例子，绝对实用！

## 1. 文件读取那些事儿

### 读取单个文件（我每天都要用）
```bash
# 查看配置文件内容（老是忘配置项）
claude "帮我看看 config.json 里面都配置了啥"
```

### 读取特定行数（文件太大时特别有用）
```bash
# package.json 太长了，只想看前面部分
claude "读取 package.json 的前20行，我只想看依赖"
```

### 一次看多个文件（效率神器）
```bash
# 同时看几个配置，对比着看很方便
claude "把 config.json 和 .env.example 都给我看看，要对照着看"
```

## 2. 创建文件的妙招

### 创建配置文件（再也不用手写了）
```bash
# 每次新项目都要建这个，烦死了
claude "帮我创建个 .env.example，把常用的环境变量都写上"
```

### 创建React组件（懒人福音）
```bash
# 我老是记不住组件的结构
claude "创建一个Button组件，要能点，要有loading状态"
```

## 3. 修改文件的实用技巧

### 添加导入（老是要查怎么写）
```bash
# 又要加新依赖了，import怎么写的来着？
claude "在 index.js 开头加上 express 和 dotenv，要按字母顺序"
```

### 改函数（改bug最常用）
```bash
# 测试说这里有问题，加个错误处理
claude "给 getUser 函数加个 try-catch，出错时返回 null"
```

## 4. 实际使用案例

查看以下文件了解实际应用：
- `sample-read.js` - 读取示例
- `sample-create.js` - 创建示例
- `sample-edit.js` - 修改示例