#!/usr/bin/env node

/**
 * ClaudeCode 格式化钩子脚本
 * 用于在文件编辑后自动格式化代码
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

class CodeFormatter {
    constructor() {
        // 支持的文件类型和对应的格式化工具
        this.formatters = {
            '.js': 'prettier --write',
            '.jsx': 'prettier --write',
            '.ts': 'prettier --write',
            '.tsx': 'prettier --write',
            '.json': 'prettier --write',
            '.css': 'prettier --write',
            '.scss': 'prettier --write',
            '.less': 'prettier --write',
            '.md': 'prettier --write',
            '.html': 'prettier --write',
            '.py': 'black',
            '.java': 'google-java-format -i',
            '.go': 'gofmt -w',
            '.rs': 'rustfmt',
            '.php': 'php-cs-fixer fix',
            '.rb': 'rubocop -a'
        };
    }

    /**
     * 格式化文件
     * @param {string} filePath - 文件路径
     */
    async formatFile(filePath) {
        try {
            // 检查文件是否存在
            if (!fs.existsSync(filePath)) {
                console.log(`⚠️  文件不存在: ${filePath}`);
                return;
            }

            // 获取文件扩展名
            const ext = path.extname(filePath);
            const formatter = this.formatters[ext];

            if (!formatter) {
                console.log(`ℹ️  跳过不支持的文件类型: ${ext}`);
                return;
            }

            console.log(`🔧 格式化文件: ${filePath}`);

            // 执行格式化命令
            execSync(`${formatter} "${filePath}"`, { stdio: 'inherit' });

            // 特殊处理：检查markdown代码块
            if (ext === '.md') {
                await this.fixMarkdownCodeBlocks(filePath);
            }

            console.log(`✅ 格式化完成: ${filePath}`);

        } catch (error) {
            console.log(`❌ 格式化失败: ${filePath}`);
            console.log(`错误信息: ${error.message}`);
        }
    }

    /**
     * 修复Markdown代码块的语言标签
     * @param {string} filePath - Markdown文件路径
     */
    async fixMarkdownCodeBlocks(filePath) {
        try {
            const content = fs.readFileSync(filePath, 'utf8');

            // 查找未标记的代码块
            const unlabeledBlockRegex = /```\n([^`]+?)\n```/gs;
            const matches = content.match(unlabeledBlockRegex);

            if (matches) {
                console.log(`🔍 发现 ${matches.length} 个未标记的代码块`);

                // 简单的语言检测
                const languageDetection = {
                    javascript: /\b(function|const|let|var|=>|import|export)\b/,
                    typescript: /\b(interface|type|as\b|declare)\b/,
                    python: /\b(def|class|import|from|if __name__)\b/,
                    json: /\s*[{[]/,
                    html: /<[^>]+>/,
                    css: /[#.]\w+\s*[{]/,
                    bash: /\b(bash|sh|echo|sudo|npm)\b/
                };

                let modifiedContent = content;

                for (const match of matches) {
                    let language = '';

                    // 尝试检测语言
                    for (const [lang, pattern] of Object.entries(languageDetection)) {
                        if (pattern.test(match)) {
                            language = lang;
                            break;
                        }
                    }

                    // 替换为带语言标签的代码块
                    const labeledBlock = match.replace('```', `\`\`\`${language}`);
                    modifiedContent = modifiedContent.replace(match, labeledBlock);
                }

                // 写回文件
                fs.writeFileSync(filePath, modifiedContent, 'utf8');
                console.log(`✅ 修复了代码块语言标签`);
            }

        } catch (error) {
            console.log(`⚠️  修复代码块失败: ${error.message}`);
        }
    }

    /**
     * 批量格式化目录
     * @param {string} dirPath - 目录路径
     * @param {string[]} excludePatterns - 排除模式
     */
    async formatDirectory(dirPath, excludePatterns = ['node_modules', '.git', 'dist', 'build']) {
        try {
            const files = fs.readdirSync(dirPath, { withFileTypes: true });

            for (const file of files) {
                const fullPath = path.join(dirPath, file.name);

                // 跳过排除的目录
                if (file.isDirectory() && excludePatterns.some(pattern => file.name.includes(pattern))) {
                    continue;
                }

                if (file.isDirectory()) {
                    // 递归处理子目录
                    await this.formatDirectory(fullPath, excludePatterns);
                } else if (file.isFile()) {
                    // 格式化文件
                    await this.formatFile(fullPath);
                }
            }
        } catch (error) {
            console.log(`❌ 处理目录失败: ${dirPath}`);
            console.log(`错误信息: ${error.message}`);
        }
    }
}

// 主程序
if (require.main === module) {
    const formatter = new CodeFormatter();
    const filePath = process.argv[2];

    if (!filePath) {
        console.log('用法: node format-hook.js <file_or_directory>');
        process.exit(1);
    }

    if (fs.statSync(filePath).isDirectory()) {
        formatter.formatDirectory(filePath);
    } else {
        formatter.formatFile(filePath);
    }
}

// 导出为钩子函数
module.exports = async function(filePath) {
    const formatter = new CodeFormatter();
    await formatter.formatFile(filePath);
};