// ClaudeCode文件操作演示项目主文件
// 使用提示词：claude "读取并解释这个文件的功能"

const express = require('express');
const fs = require('fs-extra');
const path = require('path');
const glob = require('glob');
const chalk = require('chalk');

const app = express();
const PORT = process.env.PORT || 3000;

// 中间件
app.use(express.json());
app.use(express.static('public'));

/**
 * 文件操作工具类
 * 演示ClaudeCode如何协助文件操作
 */
class FileOperationDemo {
  constructor() {
    this.baseDir = path.join(__dirname, '..');
    this.operations = [];
  }

  /**
   * 记录操作日志
   */
  log(operation, details) {
    const logEntry = {
      timestamp: new Date().toISOString(),
      operation,
      details
    };
    this.operations.push(logEntry);
    console.log(chalk.green(`[操作] ${operation}:`), details);
  }

  /**
   * 读取目录内容
   */
  async readDirectory(dirPath) {
    try {
      const files = await fs.readdir(dirPath);
      const result = {
        path: dirPath,
        files: [],
        directories: []
      };

      for (const file of files) {
        const fullPath = path.join(dirPath, file);
        const stats = await fs.stat(fullPath);

        if (stats.isDirectory()) {
          result.directories.push({
            name: file,
            path: fullPath,
            size: 0,
            modified: stats.mtime
          });
        } else {
          result.files.push({
            name: file,
            path: fullPath,
            size: stats.size,
            modified: stats.mtime,
            extension: path.extname(file)
          });
        }
      }

      this.log('读取目录', `共找到 ${result.files.length} 个文件，${result.directories.length} 个目录`);
      return result;
    } catch (error) {
      this.log('读取目录失败', error.message);
      throw error;
    }
  }

  /**
   * 搜索文件
   */
  async searchFiles(pattern, options = {}) {
    try {
      const files = glob.sync(pattern, {
        cwd: this.baseDir,
        ...options
      });

      this.log('搜索文件', `模式: ${pattern}, 找到 ${files.length} 个匹配文件`);
      return files;
    } catch (error) {
      this.log('搜索文件失败', error.message);
      throw error;
    }
  }

  /**
   * 批量重命名文件
   */
  async batchRename(files, renameFn) {
    const results = {
      success: [],
      failed: []
    };

    for (const file of files) {
      try {
        const oldPath = path.join(this.baseDir, file);
        const newName = renameFn(path.basename(file));
        const newPath = path.join(path.dirname(oldPath), newName);

        if (oldPath !== newPath) {
          await fs.rename(oldPath, newPath);
          results.success.push({
            old: file,
            new: newName
          });
          this.log('重命名', `${file} → ${newName}`);
        }
      } catch (error) {
        results.failed.push({
          file,
          error: error.message
        });
        this.log('重命名失败', `${file}: ${error.message}`);
      }
    }

    return results;
  }

  /**
   * 分析项目结构
   */
  async analyzeProject() {
    const analysis = {
      totalFiles: 0,
      totalDirectories: 0,
      fileTypes: {},
      largestFiles: [],
      recentFiles: []
    };

    // 递归分析目录
    const analyzeDirectory = async (dirPath, depth = 0) => {
      if (depth > 5) return; // 限制深度

      const items = await fs.readdir(dirPath);

      for (const item of items) {
        const itemPath = path.join(dirPath, item);
        const stats = await fs.stat(itemPath);

        if (stats.isDirectory()) {
          analysis.totalDirectories++;
          await analyzeDirectory(itemPath, depth + 1);
        } else {
          analysis.totalFiles++;

          // 统计文件类型
          const ext = path.extname(item) || '无扩展名';
          analysis.fileTypes[ext] = (analysis.fileTypes[ext] || 0) + 1;

          // 记录大文件
          if (analysis.largestFiles.length < 10) {
            analysis.largestFiles.push({
              path: itemPath,
              size: stats.size
            });
            analysis.largestFiles.sort((a, b) => b.size - a.size);
          } else if (stats.size > analysis.largestFiles[9].size) {
            analysis.largestFiles[9] = {
              path: itemPath,
              size: stats.size
            };
            analysis.largestFiles.sort((a, b) => b.size - a.size);
          }

          // 记录最近文件
          if (analysis.recentFiles.length < 10) {
            analysis.recentFiles.push({
              path: itemPath,
              modified: stats.mtime
            });
            analysis.recentFiles.sort((a, b) => b.modified - a.modified);
          }
        }
      }
    };

    await analyzeDirectory(this.baseDir);

    this.log('项目分析', `共 ${analysis.totalFiles} 个文件，${analysis.totalDirectories} 个目录`);
    return analysis;
  }
}

// API路由
const fileDemo = new FileOperationDemo();

// 获取目录内容
app.get('/api/directory/:path(*)', async (req, res) => {
  try {
    const dirPath = req.params.path ?
      path.join(fileDemo.baseDir, req.params.path) :
      fileDemo.baseDir;

    const result = await fileDemo.readDirectory(dirPath);
    res.json(result);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// 搜索文件
app.get('/api/search', async (req, res) => {
  try {
    const { pattern, ...options } = req.query;
    if (!pattern) {
      return res.status(400).json({ error: '缺少搜索模式' });
    }

    const files = await fileDemo.searchFiles(pattern, options);
    res.json({ files, count: files.length });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// 项目分析
app.get('/api/analyze', async (req, res) => {
  try {
    const analysis = await fileDemo.analyzeProject();
    res.json(analysis);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// 获取操作日志
app.get('/api/logs', (req, res) => {
  res.json({
    operations: fileDemo.operations,
    count: fileDemo.operations.length
  });
});

// 启动服务器
app.listen(PORT, () => {
  console.log(chalk.blue(`服务器运行在 http://localhost:${PORT}`));
  console.log(chalk.yellow('API端点:'));
  console.log('  GET /api/directory/:path - 获取目录内容');
  console.log('  GET /api/search?pattern=*** - 搜索文件');
  console.log('  GET /api/analyze - 项目分析');
  console.log('  GET /api/logs - 操作日志');
});

module.exports = app;