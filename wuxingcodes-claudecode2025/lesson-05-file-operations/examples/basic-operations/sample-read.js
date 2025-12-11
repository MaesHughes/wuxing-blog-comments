// ClaudeCode读取文件示例
// 使用提示词：claude "读取这个文件并解释其功能"

const fs = require('fs');
const path = require('path');

/**
 * 文件读取工具类
 * 演示ClaudeCode如何理解和分析文件
 */
class FileReader {
  constructor() {
    this.encoding = 'utf8';
  }

  /**
   * 同步读取文件
   * @param {string} filePath - 文件路径
   * @returns {string} 文件内容
   */
  readFileSync(filePath) {
    try {
      const fullPath = path.resolve(filePath);
      return fs.readFileSync(fullPath, this.encoding);
    } catch (error) {
      console.error(`读取文件失败: ${error.message}`);
      return null;
    }
  }

  /**
   * 异步读取文件
   * @param {string} filePath - 文件路径
   * @returns {Promise<string>} 文件内容
   */
  async readFileAsync(filePath) {
    try {
      const fullPath = path.resolve(filePath);
      return await fs.promises.readFile(fullPath, this.encoding);
    } catch (error) {
      console.error(`读取文件失败: ${error.message}`);
      return null;
    }
  }

  /**
   * 读取文件的前N行
   * @param {string} filePath - 文件路径
   * @param {number} lines - 行数
   * @returns {string} 前N行内容
   */
  readFirstLines(filePath, lines = 10) {
    try {
      const content = this.readFileSync(filePath);
      if (!content) return null;

      return content
        .split('\n')
        .slice(0, lines)
        .join('\n');
    } catch (error) {
      console.error(`读取文件前${lines}行失败: ${error.message}`);
      return null;
    }
  }

  /**
   * 读取文件的特定行范围
   * @param {string} filePath - 文件路径
   * @param {number} start - 起始行（1开始）
   * @param {number} end - 结束行
   * @returns {string} 指定行内容
   */
  readLineRange(filePath, start, end) {
    try {
      const content = this.readFileSync(filePath);
      if (!content) return null;

      return content
        .split('\n')
        .slice(start - 1, end)
        .join('\n');
    } catch (error) {
      console.error(`读取文件第${start}-${end}行失败: ${error.message}`);
      return null;
    }
  }
}

// 导出模块
module.exports = FileReader;

// 使用示例
if (require.main === module) {
  const reader = new FileReader();

  // 读取配置文件
  console.log('=== 读取配置文件 ===');
  const config = reader.readFileSync('sample-config.json');
  console.log(config);

  // 读取前5行
  console.log('\n=== 前5行内容 ===');
  const first5Lines = reader.readFirstLines('sample-read.js', 5);
  console.log(first5Lines);
}