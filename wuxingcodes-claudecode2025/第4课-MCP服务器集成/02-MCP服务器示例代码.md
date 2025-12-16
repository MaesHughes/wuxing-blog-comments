# MCP服务器示例代码集合

## 1. 数据库MCP服务器示例

### SQLite MCP服务器

```javascript
// sqlite-server.js
import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ErrorCode,
  ListToolsRequestSchema,
  McpError,
} from "@modelcontextprotocol/sdk/types.js";
import sqlite3 from 'sqlite3';
import { open } from 'sqlite';

const server = new Server(
  {
    name: "sqlite-server",
    version: "1.0.0",
  },
  {
    capabilities: {
      tools: {},
      resources: {},
    },
  }
);

let db = null;

// 初始化数据库连接
async function initializeDatabase(dbPath) {
  db = await open({
    filename: dbPath,
    driver: sqlite3.Database
  });

  // 创建示例表
  await db.exec(`
    CREATE TABLE IF NOT EXISTS users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      email TEXT UNIQUE,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

    CREATE TABLE IF NOT EXISTS products (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      price DECIMAL(10,2),
      category TEXT,
      stock INTEGER DEFAULT 0
    );
  `);
}

server.setRequestHandler(ListToolsRequestSchema, async () => ({
  tools: [
    {
      name: "execute_sql",
      description: "执行SQL查询",
      inputSchema: {
        type: "object",
        properties: {
          query: {
            type: "string",
            description: "SQL查询语句"
          },
          params: {
            type: "array",
            items: { type: "string" },
            description: "查询参数"
          }
        },
        required: ["query"],
      },
    },
    {
      name: "create_table",
      description: "创建数据表",
      inputSchema: {
        type: "object",
        properties: {
          table_name: { type: "string" },
          columns: {
            type: "object",
            description: "列定义"
          }
        },
        required: ["table_name", "columns"],
      },
    },
    {
      name: "insert_data",
      description: "插入数据",
      inputSchema: {
        type: "object",
        properties: {
          table: { type: "string" },
          data: {
            type: "object",
            description: "要插入的数据"
          }
        },
        required: ["table", "data"],
      },
    }
  ],
}));

server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;

  try {
    switch (name) {
      case "execute_sql":
        return await executeSQL(args.query, args.params);

      case "create_table":
        return await createTable(args.table_name, args.columns);

      case "insert_data":
        return await insertData(args.table, args.data);

      default:
        throw new McpError(
          ErrorCode.MethodNotFound,
          `Unknown tool: ${name}`
        );
    }
  } catch (error) {
    return {
      content: [{
        type: "text",
        text: `Error: ${error.message}`
      }]
    };
  }
});

async function executeSQL(query, params = []) {
  try {
    const result = await db.all(query, params);

    return {
      content: [{
        type: "text",
        text: JSON.stringify({
          query,
          rowCount: result.length,
          data: result
        }, null, 2)
      }]
    };
  } catch (error) {
    throw new Error(`SQL执行失败: ${error.message}`);
  }
}

async function createTable(tableName, columns) {
  try {
    const columnDefs = Object.entries(columns)
      .map(([name, definition]) => `${name} ${definition}`)
      .join(', ');

    const sql = `CREATE TABLE IF NOT EXISTS ${tableName} (${columnDefs})`;

    await db.exec(sql);

    return {
      content: [{
        type: "text",
        text: `表 ${tableName} 创建成功`
      }]
    };
  } catch (error) {
    throw new Error(`创建表失败: ${error.message}`);
  }
}

async function insertData(tableName, data) {
  try {
    const columns = Object.keys(data).join(', ');
    const placeholders = Object.keys(data).map(() => '?').join(', ');
    const values = Object.values(data);

    const sql = `INSERT INTO ${tableName} (${columns}) VALUES (${placeholders})`;

    const result = await db.run(sql, values);

    return {
      content: [{
        type: "text",
        text: `数据插入成功，ID: ${result.lastID}`
      }]
    };
  } catch (error) {
    throw new Error(`插入数据失败: ${error.message}`);
  }
}

// 启动服务器
async function main() {
  const dbPath = process.argv[2] || './database.sqlite';
  await initializeDatabase(dbPath);

  const transport = new StdioServerTransport();
  await server.connect(transport);

  console.error(`SQLite MCP Server running, database: ${dbPath}`);
}

main().catch((error) => {
  console.error("Server error:", error);
  process.exit(1);
});
```

## 2. API集成MCP服务器示例

### GitHub API集成

```javascript
// github-api-server.js
import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import fetch from 'node-fetch';

const server = new Server({
  name: "github-api-server",
  version: "1.0.0"
}, {
  capabilities: {
    tools: {}
  }
});

const GITHUB_API_BASE = "https://api.github.com";

// GitHub API请求封装
async function githubRequest(endpoint, options = {}) {
  const token = process.env.GITHUB_TOKEN;

  const response = await fetch(`${GITHUB_API_BASE}${endpoint}`, {
    headers: {
      'Authorization': `token ${token}`,
      'Accept': 'application/vnd.github.v3+json',
      'User-Agent': 'MCP-GitHub-Server',
      ...options.headers
    },
    ...options
  });

  if (!response.ok) {
    throw new Error(`GitHub API错误: ${response.status} ${response.statusText}`);
  }

  return response.json();
}

server.setRequestHandler("tools/list", async () => ({
  tools: [
    {
      name: "search_repositories",
      description: "搜索GitHub仓库",
      inputSchema: {
        type: "object",
        properties: {
          query: { type: "string", description: "搜索关键词" },
          language: { type: "string", description: "编程语言" },
          sort: {
            type: "string",
            enum: ["stars", "forks", "updated"],
            default: "stars"
          },
          limit: { type: "number", default: 10 }
        },
        required: ["query"]
      }
    },
    {
      name: "get_repository_info",
      description: "获取仓库详细信息",
      inputSchema: {
        type: "object",
        properties: {
          owner: { type: "string", description: "仓库所有者" },
          repo: { type: "string", description: "仓库名称" }
        },
        required: ["owner", "repo"]
      }
    },
    {
      name: "list_repository_files",
      description: "列出仓库文件",
      inputSchema: {
        type: "object",
        properties: {
          owner: { type: "string" },
          repo: { type: "string" },
          path: { type: "string", default: "" }
        },
        required: ["owner", "repo"]
      }
    },
    {
      name: "get_file_content",
      description: "获取文件内容",
      inputSchema: {
        type: "object",
        properties: {
          owner: { type: "string" },
          repo: { type: "string" },
          path: { type: "string" }
        },
        required: ["owner", "repo", "path"]
      }
    }
  ]
}));

server.setRequestHandler("tools/call", async (request) => {
  const { name, arguments: args } = request.params;

  try {
    switch (name) {
      case "search_repositories":
        return await searchRepositories(args);

      case "get_repository_info":
        return await getRepositoryInfo(args);

      case "list_repository_files":
        return await listRepositoryFiles(args);

      case "get_file_content":
        return await getFileContent(args);

      default:
        throw new Error(`Unknown tool: ${name}`);
    }
  } catch (error) {
    return {
      content: [{
        type: "text",
        text: `Error: ${error.message}`
      }]
    };
  }
});

async function searchRepositories(args) {
  const { query, language, sort = "stars", limit = 10 } = args;

  let searchQuery = query;
  if (language) {
    searchQuery += ` language:${language}`;
  }

  const result = await githubRequest(`/search/repositories?q=${encodeURIComponent(searchQuery)}&sort=${sort}&per_page=${limit}`);

  return {
    content: [{
      type: "text",
      text: JSON.stringify({
        total_count: result.total_count,
        items: result.items.map(repo => ({
          name: repo.name,
          full_name: repo.full_name,
          description: repo.description,
          language: repo.language,
          stars: repo.stargazers_count,
          forks: repo.forks_count,
          url: repo.html_url
        }))
      }, null, 2)
    }]
  };
}

async function getRepositoryInfo(args) {
  const { owner, repo } = args;

  const repoInfo = await githubRequest(`/repos/${owner}/${repo}`);
  const languages = await githubRequest(`/repos/${owner}/${repo}/languages`);

  return {
    content: [{
      type: "text",
      text: JSON.stringify({
        name: repoInfo.name,
        full_name: repoInfo.full_name,
        description: repoInfo.description,
        language: repoInfo.language,
        languages: languages,
        stars: repoInfo.stargazers_count,
        forks: repoInfo.forks_count,
        open_issues: repoInfo.open_issues_count,
        created_at: repoInfo.created_at,
        updated_at: repoInfo.updated_at,
        clone_url: repoInfo.clone_url,
        homepage: repoInfo.homepage
      }, null, 2)
    }]
  };
}

async function listRepositoryFiles(args) {
  const { owner, repo, path = "" } = args;

  const contents = await githubRequest(`/repos/${owner}/${repo}/contents/${path}`);

  const files = Array.isArray(contents) ? contents : [contents];

  return {
    content: [{
      type: "text",
      text: JSON.stringify(files.map(item => ({
        name: item.name,
        type: item.type,
        size: item.size,
        path: item.path,
        download_url: item.download_url
      })), null, 2)
    }]
  };
}

async function getFileContent(args) {
  const { owner, repo, path } = args;

  const file = await githubRequest(`/repos/${owner}/${repo}/contents/${path}`);

  if (file.type !== 'file') {
    throw new Error('指定的路径不是文件');
  }

  const content = Buffer.from(file.content, 'base64').toString('utf-8');

  return {
    content: [{
      type: "text",
      text: JSON.stringify({
        name: file.name,
        path: file.path,
        size: file.size,
        content: content,
        encoding: file.encoding
      }, null, 2)
    }]
  };
}

async function main() {
  if (!process.env.GITHUB_TOKEN) {
    console.error('请设置GITHUB_TOKEN环境变量');
    process.exit(1);
  }

  const transport = new StdioServerTransport();
  await server.connect(transport);

  console.error('GitHub API MCP Server running');
}

main().catch(console.error);
```

## 3. 文件系统MCP服务器示例

### 智能文件搜索服务器

```javascript
// smart-file-server.js
import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import fs from 'fs/promises';
import path from 'path';
import { createHash } from 'crypto';

const server = new Server({
  name: "smart-file-server",
  version: "1.0.0"
}, {
  capabilities: {
    tools: {},
    resources: {}
  }
});

// 文件索引
const fileIndex = new Map();
const rootPath = process.env.ROOT_PATH || process.cwd();

// 构建文件索引
async function buildFileIndex(dirPath) {
  const index = new Map();

  async function traverse(currentPath, depth = 0) {
    if (depth > 10) return; // 防止过深遍历

    try {
      const entries = await fs.readdir(currentPath, { withFileTypes: true });

      for (const entry of entries) {
        const fullPath = path.join(currentPath, entry.name);
        const relativePath = path.relative(rootPath, fullPath);

        if (entry.isDirectory()) {
          // 忽略某些目录
          if (['node_modules', '.git', '.vscode', 'dist', 'build'].includes(entry.name)) {
            continue;
          }

          await traverse(fullPath, depth + 1);
        } else {
          try {
            const stats = await fs.stat(fullPath);
            const content = await fs.readFile(fullPath, 'utf-8');

            index.set(relativePath, {
              path: fullPath,
              relativePath,
              size: stats.size,
              modified: stats.mtime,
              extension: path.extname(entry.name),
              hash: createHash('md5').update(content).digest('hex'),
              lineCount: content.split('\n').length,
              contentPreview: content.substring(0, 200)
            });
          } catch (error) {
            // 跳过无法读取的文件
          }
        }
      }
    } catch (error) {
      // 跳过无法访问的目录
    }
  }

  await traverse(dirPath);
  return index;
}

// 初始化索引
buildFileIndex(rootPath).then(index => {
  for (const [key, value] of index.entries()) {
    fileIndex.set(key, value);
  }
  console.error(`文件索引构建完成，共 ${fileIndex.size} 个文件`);
});

server.setRequestHandler("tools/list", async () => ({
  tools: [
    {
      name: "search_files",
      description: "在文件内容中搜索",
      inputSchema: {
        type: "object",
        properties: {
          query: { type: "string", description: "搜索关键词或正则表达式" },
          fileTypes: {
            type: "array",
            items: { type: "string" },
            description: "文件类型过滤"
          },
          maxResults: { type: "number", default: 20 }
        },
        required: ["query"]
      }
    },
    {
      name: "find_similar_files",
      description: "查找相似文件（基于内容）",
      inputSchema: {
        type: "object",
        properties: {
          filePath: { type: "string", description: "参考文件路径" },
          threshold: { type: "number", default: 0.7, description: "相似度阈值" }
        },
        required: ["filePath"]
      }
    },
    {
      name: "analyze_code_structure",
      description: "分析代码结构",
      inputSchema: {
        type: "object",
        properties: {
          path: { type: "string", description: "文件或目录路径" },
          includeFunctions: { type: "boolean", default: true },
          includeClasses: { type: "boolean", default: true },
          includeImports: { type: "boolean", default: true }
        },
        required: ["path"]
      }
    }
  ]
}));

server.setRequestHandler("tools/call", async (request) => {
  const { name, arguments: args } = request.params;

  try {
    switch (name) {
      case "search_files":
        return await searchFiles(args.query, args.fileTypes, args.maxResults);

      case "find_similar_files":
        return await findSimilarFiles(args.filePath, args.threshold);

      case "analyze_code_structure":
        return await analyzeCodeStructure(
          args.path,
          args.includeFunctions,
          args.includeClasses,
          args.includeImports
        );

      default:
        throw new Error(`Unknown tool: ${name}`);
    }
  } catch (error) {
    return {
      content: [{
        type: "text",
        text: `Error: ${error.message}`
      }]
    };
  }
});

async function searchFiles(query, fileTypes = [], maxResults = 20) {
  const results = [];
  const isRegex = query.startsWith('/') && query.endsWith('/');
  const pattern = isRegex ? new RegExp(query.slice(1, -1)) : null;

  for (const [relativePath, fileInfo] of fileIndex.entries()) {
    // 文件类型过滤
    if (fileTypes.length > 0 && !fileTypes.includes(fileInfo.extension)) {
      continue;
    }

    // 内容匹配
    let matches = false;
    const content = fileInfo.contentPreview;

    if (isRegex) {
      matches = pattern.test(content);
    } else {
      matches = content.toLowerCase().includes(query.toLowerCase());
    }

    if (matches) {
      results.push({
        path: relativePath,
        size: fileInfo.size,
        modified: fileInfo.modified,
        lineCount: fileInfo.lineCount,
        preview: fileInfo.contentPreview.substring(0, 100)
      });

      if (results.length >= maxResults) break;
    }
  }

  return {
    content: [{
      type: "text",
      text: JSON.stringify({
        query,
        totalMatches: results.length,
        files: results
      }, null, 2)
    }]
  };
}

// 计算文本相似度
function calculateSimilarity(text1, text2) {
  const longer = text1.length > text2.length ? text1 : text2;
  const shorter = text1.length > text2.length ? text2 : text1;

  if (longer.length === 0) return 1.0;

  const editDistance = levenshteinDistance(longer, shorter);
  return (longer.length - editDistance) / longer.length;
}

// Levenshtein距离
function levenshteinDistance(str1, str2) {
  const matrix = [];

  for (let i = 0; i <= str2.length; i++) {
    matrix[i] = [i];
  }

  for (let j = 0; j <= str1.length; j++) {
    matrix[0][j] = j;
  }

  for (let i = 1; i <= str2.length; i++) {
    for (let j = 1; j <= str1.length; j++) {
      if (str2.charAt(i - 1) === str1.charAt(j - 1)) {
        matrix[i][j] = matrix[i - 1][j - 1];
      } else {
        matrix[i][j] = Math.min(
          matrix[i - 1][j - 1] + 1,
          matrix[i][j - 1] + 1,
          matrix[i - 1][j] + 1
        );
      }
    }
  }

  return matrix[str2.length][str1.length];
}

async function findSimilarFiles(filePath, threshold = 0.7) {
  const fileInfo = fileIndex.get(filePath);
  if (!fileInfo) {
    throw new Error('文件不存在');
  }

  const targetContent = await fs.readFile(fileInfo.path, 'utf-8');
  const similarFiles = [];

  for (const [relativePath, info] of fileIndex.entries()) {
    if (relativePath === filePath) continue;

    try {
      const content = await fs.readFile(info.path, 'utf-8');
      const similarity = calculateSimilarity(targetContent, content);

      if (similarity >= threshold) {
        similarFiles.push({
          path: relativePath,
          similarity: Math.round(similarity * 100) / 100
        });
      }
    } catch (error) {
      // 忽略读取错误
    }
  }

  similarFiles.sort((a, b) => b.similarity - a.similarity);

  return {
    content: [{
      type: "text",
      text: JSON.stringify({
        referenceFile: filePath,
        threshold,
        similarFiles: similarFiles.slice(0, 10)
      }, null, 2)
    }]
  };
}

async function analyzeCodeStructure(analyzePath, includeFunctions, includeClasses, includeImports) {
  const fullPath = path.resolve(rootPath, analyzePath);
  const stats = await fs.stat(fullPath);

  if (stats.isFile()) {
    return await analyzeSingleFile(fullPath);
  } else {
    return await analyzeDirectory(fullPath);
  }
}

async function analyzeSingleFile(filePath) {
  const content = await fs.readFile(filePath, 'utf-8');
  const extension = path.extname(filePath);
  const analysis = {
    path: path.relative(rootPath, filePath),
    type: extension,
    structure: {}
  };

  // JavaScript/TypeScript分析
  if (['.js', '.jsx', '.ts', '.tsx'].includes(extension)) {
    // 提取函数
    const functionMatches = content.match(/(?:function\s+(\w+)|const\s+(\w+)\s*=\s*(?:async\s+)?\(?[^)]*\)?\s*=>|(\w+)\s*:\s*\([^)]*\)\s*=>)/g);
    analysis.structure.functions = functionMatches ? [...new Set(functionMatches)] : [];

    // 提取类
    const classMatches = content.match(/class\s+(\w+)/g);
    analysis.structure.classes = classMatches || [];

    // 提取导入
    const importMatches = content.match(/import\s+.+?\s+from\s+['"][^'"]+['"]/g);
    analysis.structure.imports = importMatches || [];
  }

  // Python分析
  if (extension === '.py') {
    const functionMatches = content.match(/def\s+(\w+)/g);
    analysis.structure.functions = functionMatches || [];

    const classMatches = content.match(/class\s+(\w+)/g);
    analysis.structure.classes = classMatches || [];

    const importMatches = content.match(/(?:import\s+\w+|from\s+\w+\s+import)/g);
    analysis.structure.imports = importMatches || [];
  }

  return {
    content: [{
      type: "text",
      text: JSON.stringify(analysis, null, 2)
    }]
  };
}

async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);

  console.error(`Smart File MCP Server running, root: ${rootPath}`);
}

main().catch(console.error);
```

## 4. 组合MCP服务器示例

### 多功能MCP服务器

```javascript
// multi-function-server.js
import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import sqlite3 from 'sqlite3';
import fetch from 'node-fetch';
import fs from 'fs/promises';

const server = new Server({
  name: "multi-function-server",
  version: "1.0.0"
}, {
  capabilities: {
    tools: {},
    resources: {}
  }
});

// 初始化各个模块
const db = new sqlite3.Database('./data.db');
const cache = new Map();

// 工具列表
server.setRequestHandler("tools/list", async () => ({
  tools: [
    // 数据库工具
    {
      name: "db_query",
      description: "执行数据库查询",
      inputSchema: {
        type: "object",
        properties: {
          sql: { type: "string", description: "SQL语句" }
        },
        required: ["sql"]
      }
    },

    // API工具
    {
      name: "api_call",
      description: "调用外部API",
      inputSchema: {
        type: "object",
        properties: {
          url: { type: "string", description: "API URL" },
          method: {
            type: "string",
            enum: ["GET", "POST", "PUT", "DELETE"],
            default: "GET"
          },
          headers: { type: "object" },
          body: { type: "object" }
        },
        required: ["url"]
      }
    },

    // 文件工具
    {
      name: "file_read",
      description: "读取文件内容",
      inputSchema: {
        type: "object",
        properties: {
          path: { type: "string", description: "文件路径" }
        },
        required: ["path"]
      }
    },

    // 缓存工具
    {
      name: "cache_set",
      description: "设置缓存",
      inputSchema: {
        type: "object",
        properties: {
          key: { type: "string" },
          value: { type: "any" },
          ttl: { type: "number", default: 300 }
        },
        required: ["key", "value"]
      }
    },

    {
      name: "cache_get",
      description: "获取缓存",
      inputSchema: {
        type: "object",
        properties: {
          key: { type: "string" }
        },
        required: ["key"]
      }
    }
  ]
}));

// 工具调用处理
server.setRequestHandler("tools/call", async (request) => {
  const { name, arguments: args } = request.params;

  try {
    switch (name) {
      case "db_query":
        return await executeDBQuery(args.sql);

      case "api_call":
        return await makeAPICall(args);

      case "file_read":
        return await readFile(args.path);

      case "cache_set":
        return setCache(args.key, args.value, args.ttl);

      case "cache_get":
        return getCache(args.key);

      default:
        throw new Error(`Unknown tool: ${name}`);
    }
  } catch (error) {
    return {
      content: [{
        type: "text",
        text: `Error: ${error.message}`
      }]
    };
  }
});

// 数据库查询实现
async function executeDBQuery(sql) {
  return new Promise((resolve, reject) => {
    db.all(sql, (err, rows) => {
      if (err) {
        reject(err);
      } else {
        resolve({
          content: [{
            type: "text",
            text: JSON.stringify(rows, null, 2)
          }]
        });
      }
    });
  });
}

// API调用实现
async function makeAPICall({ url, method = "GET", headers = {}, body = null }) {
  const options = {
    method,
    headers: {
      'Content-Type': 'application/json',
      ...headers
    }
  };

  if (body) {
    options.body = JSON.stringify(body);
  }

  const response = await fetch(url, options);
  const data = await response.json();

  return {
    content: [{
      type: "text",
      text: JSON.stringify({
        status: response.status,
        statusText: response.statusText,
        data
      }, null, 2)
    }]
  };
}

// 文件读取实现
async function readFile(filePath) {
  const content = await fs.readFile(filePath, 'utf-8');

  return {
    content: [{
      type: "text",
      text: content
    }]
  };
}

// 缓存设置实现
function setCache(key, value, ttl = 300) {
  cache.set(key, {
    value,
    expires: Date.now() + ttl * 1000
  });

  return {
    content: [{
      type: "text",
      text: `缓存设置成功: ${key}`
    }]
  };
}

// 缓存获取实现
function getCache(key) {
  const item = cache.get(key);

  if (!item || Date.now() > item.expires) {
    cache.delete(key);
    return {
      content: [{
        type: "text",
        text: "缓存已过期或不存在"
      }]
    };
  }

  return {
    content: [{
      type: "text",
      text: JSON.stringify(item.value, null, 2)
    }]
  };
}

// 定期清理过期缓存
setInterval(() => {
  const now = Date.now();
  for (const [key, item] of cache.entries()) {
    if (now > item.expires) {
      cache.delete(key);
    }
  }
}, 60000); // 每分钟清理一次

async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);

  console.error('Multi-Function MCP Server running');
}

main().catch(console.error);

// 优雅关闭
process.on('SIGINT', () => {
  console.log('\n正在关闭服务器...');
  db.close((err) => {
    if (err) {
      console.error('关闭数据库失败:', err);
    } else {
      console.log('数据库连接已关闭');
    }
    process.exit(0);
  });
});
```

## 5. 测试脚本

### MCP服务器测试脚本

```javascript
// test-mcp-server.js
import { spawn } from 'child_process';
import { createInterface } from 'readline';

class MCPServerTester {
  constructor(serverCommand, serverArgs = []) {
    this.serverProcess = null;
    this.serverCommand = serverCommand;
    this.serverArgs = serverArgs;
    this.requestId = 1;
  }

  async start() {
    console.log(`启动MCP服务器: ${this.serverCommand} ${this.serverArgs.join(' ')}`);

    this.serverProcess = spawn(this.serverCommand, this.serverArgs, {
      stdio: ['pipe', 'pipe', 'inherit']
    });

    this.serverProcess.on('error', (error) => {
      console.error('服务器启动失败:', error);
    });

    this.serverProcess.on('exit', (code) => {
      console.log(`服务器退出，代码: ${code}`);
    });

    // 等待服务器启动
    await new Promise(resolve => setTimeout(resolve, 2000));
  }

  async sendRequest(method, params = {}) {
    const request = {
      jsonrpc: "2.0",
      id: this.requestId++,
      method,
      params
    };

    const requestStr = JSON.stringify(request) + '\n';

    return new Promise((resolve, reject) => {
      let response = '';

      const onData = (data) => {
        response += data.toString();

        try {
          const lines = response.split('\n');
          for (const line of lines) {
            if (line.trim()) {
              const json = JSON.parse(line);
              if (json.id === request.id) {
                this.serverProcess.stdout.removeListener('data', onData);
                resolve(json);
                return;
              }
            }
          }
        } catch (error) {
          // 还不是完整的JSON，继续等待
        }
      };

      this.serverProcess.stdout.on('data', onData);
      this.serverProcess.stdin.write(requestStr);

      // 超时处理
      setTimeout(() => {
        this.serverProcess.stdout.removeListener('data', onData);
        reject(new Error('请求超时'));
      }, 30000);
    });
  }

  async testListTools() {
    console.log('\n测试: 列出工具');
    try {
      const response = await this.sendRequest('tools/list');
      console.log('工具列表:', JSON.stringify(response.result?.tools, null, 2));
      return response.result?.tools || [];
    } catch (error) {
      console.error('获取工具列表失败:', error.message);
      return [];
    }
  }

  async testTool(toolName, args = {}) {
    console.log(`\n测试: 调用工具 ${toolName}`);
    console.log('参数:', JSON.stringify(args, null, 2));

    try {
      const response = await this.sendRequest('tools/call', {
        name: toolName,
        arguments: args
      });

      console.log('响应:', JSON.stringify(response.result, null, 2));
      return response.result;
    } catch (error) {
      console.error(`工具调用失败 (${toolName}):`, error.message);
      return null;
    }
  }

  async stop() {
    if (this.serverProcess) {
      console.log('\n停止服务器...');
      this.serverProcess.kill('SIGTERM');
      await new Promise(resolve => {
        this.serverProcess.on('exit', resolve);
        setTimeout(resolve, 5000); // 最多等待5秒
      });
    }
  }

  async runTests() {
    await this.start();

    try {
      // 获取工具列表
      const tools = await this.testListTools();

      if (tools.length === 0) {
        console.log('没有可用的工具');
        return;
      }

      // 测试每个工具
      for (const tool of tools) {
        const toolName = tool.name;

        // 根据工具类型准备测试参数
        let testArgs = {};

        switch (toolName) {
          case 'execute_sql':
            testArgs = { query: 'SELECT 1 as test' };
            break;

          case 'get_weather':
            testArgs = { city: '北京' };
            break;

          case 'search_files':
            testArgs = { query: 'import', maxResults: 5 };
            break;

          case 'cache_set':
            testArgs = { key: 'test', value: 'hello world' };
            break;

          case 'cache_get':
            testArgs = { key: 'test' };
            break;

          default:
            console.log(`跳过测试工具: ${toolName} (需要手动测试参数)`);
            continue;
        }

        await this.testTool(toolName, testArgs);
      }

    } finally {
      await this.stop();
    }
  }
}

// 使用示例
async function main() {
  const serverPath = process.argv[2];

  if (!serverPath) {
    console.log('使用方法: node test-mcp-server.js <server-command> [args...]');
    console.log('示例:');
    console.log('  node test-mcp-server.js node ./sqlite-server.js ./test.db');
    console.log('  node test-mcp-server.js npx -y @modelcontextprotocol/server-sqlite ./test.db');
    process.exit(1);
  }

  const args = process.argv.slice(3);
  const tester = new MCPServerTester(serverPath, args);

  await tester.runTests();
}

// 交互式测试模式
async function interactiveMode() {
  const tester = new MCPServerTester(process.argv[2], process.argv.slice(3));
  await tester.start();

  const rl = createInterface({
    input: process.stdin,
    output: process.stdout
  });

  console.log('\n交互式测试模式');
  console.log('输入命令:');
  console.log('  list - 列出工具');
  console.log('  call <tool-name> [args] - 调用工具');
  console.log('  exit - 退出');
  console.log();

  const prompt = () => {
    rl.question('mcp-test> ', async (input) => {
      const [cmd, ...argParts] = input.trim().split(' ');

      switch (cmd) {
        case 'list':
          await tester.testListTools();
          break;

        case 'call':
          if (argParts.length < 1) {
            console.log('使用方法: call <tool-name> [args]');
            break;
          }

          const toolName = argParts[0];
          let args = {};

          if (argParts.length > 1) {
            try {
              args = JSON.parse(argParts.slice(1).join(' '));
            } catch (error) {
              console.log('参数解析失败，请提供有效的JSON');
              break;
            }
          }

          await tester.testTool(toolName, args);
          break;

        case 'exit':
          await tester.stop();
          rl.close();
          process.exit(0);

        default:
          console.log('未知命令');
      }

      console.log();
      prompt();
    });
  };

  prompt();
}

// 如果有--interactive参数，进入交互模式
if (process.argv.includes('--interactive')) {
  interactiveMode();
} else {
  main().catch(console.error);
}
```

这些示例代码涵盖了：

1. **数据库MCP服务器** - SQLite集成，支持SQL执行和数据操作
2. **API集成MCP服务器** - GitHub API集成，支持仓库搜索和文件读取
3. **文件系统MCP服务器** - 智能文件搜索、相似度检测、代码结构分析
4. **组合MCP服务器** - 整合多种功能的综合服务器
5. **测试脚本** - 用于测试和调试MCP服务器的工具

每个示例都包含了完整的实现，可以直接运行和测试。