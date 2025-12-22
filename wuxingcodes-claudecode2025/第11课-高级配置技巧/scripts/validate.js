#!/usr/bin/env node

/**
 * ClaudeCode 命令验证脚本
 * 用于在执行命令前进行安全检查
 */

const fs = require('fs');
const path = require('path');

class CommandValidator {
    constructor() {
        // 危险命令模式
        this.dangerousPatterns = [
            /rm\s+-rf/i,           // 强制删除
            /chmod\s+777/i,        // 危险权限
            />\s*\/dev\/null/,     // 输出到/dev/null
            /\|\s*sh/,             // 管道到shell
            /\$\(/,               // 命令替换
            /&&\s*rm/,            // 链式删除
            /;\s*rm/,             // 分号删除
            /dd\s+if=/,           // dd命令
            /mkfs/,               // 文件系统格式化
            /fdisk/,              // 磁盘分区
            /sudo\s+rm/,         // sudo删除
            /su\s+-c/             // su执行
        ];

        // 敏感文件路径
        this.sensitivePaths = [
            /\.ssh\//,
            /\.aws\//,
            /\.config\//,
            /\/etc\//,
            /\/root\//,
            /.*\.key$/,
            /.*\.pem$/,
            /.*\.p12$/,
            /\.env$/,
            /.*secret/,
            /.*password/
        ];

        // 允许的命令列表
        this.allowedCommands = [
            'git', 'npm', 'node', 'npx', 'python', 'pip',
            'pytest', 'eslint', 'prettier', 'yarn', 'pnpm',
            'make', 'cmake', 'gcc', 'g++', 'javac', 'java'
        ];
    }

    /**
     * 验证命令是否安全
     * @param {string} command - 命令名称
     * @param {string[]} args - 命令参数
     * @returns {boolean} - 是否通过验证
     */
    validateCommand(command, args) {
        const fullCommand = `${command} ${args.join(' ')}`;

        // 1. 检查命令是否在允许列表中
        if (!this.allowedCommands.includes(command)) {
            console.log(`❌ 命令不在允许列表中: ${command}`);
            return false;
        }

        // 2. 检查危险模式
        for (const pattern of this.dangerousPatterns) {
            if (pattern.test(fullCommand)) {
                console.log(`❌ 检测到危险命令模式: ${fullCommand}`);
                console.log(`匹配模式: ${pattern}`);
                return false;
            }
        }

        // 3. 检查敏感文件访问
        for (const arg of args) {
            if (this.isSensitivePath(arg)) {
                console.log(`❌ 尝试访问敏感路径: ${arg}`);
                return false;
            }
        }

        // 4. 特殊命令检查
        if (command === 'rm') {
            if (args.includes('-rf') || args.length > 3) {
                console.log(`❌ 危险的删除操作: rm ${args.join(' ')}`);
                return false;
            }
        }

        if (command === 'chmod') {
            if (args.includes('777') || args.includes('666')) {
                console.log(`❌ 危险的权限设置: chmod ${args.join(' ')}`);
                return false;
            }
        }

        console.log(`✅ 命令安全验证通过: ${command}`);
        return true;
    }

    /**
     * 检查文件操作是否安全
     * @param {string} operation - 操作类型 (read/write/delete)
     * @param {string} filePath - 文件路径
     * @returns {boolean} - 是否安全
     */
    validateFileOperation(operation, filePath) {
        // 1. 检查路径遍历攻击
        if (filePath.includes('..')) {
            console.log(`❌ 检测到路径遍历: ${filePath}`);
            return false;
        }

        // 2. 检查绝对路径（通常应该使用相对路径）
        if (path.isAbsolute(filePath) && !filePath.startsWith(process.cwd())) {
            console.log(`❌ 禁止访问外部绝对路径: ${filePath}`);
            return false;
        }

        // 3. 检查敏感文件
        if (this.isSensitivePath(filePath)) {
            console.log(`❌ 尝试访问敏感文件: ${filePath}`);
            return false;
        }

        // 4. 检查文件大小（防止处理过大文件）
        try {
            if (fs.existsSync(filePath)) {
                const stats = fs.statSync(filePath);
                const maxSize = 10 * 1024 * 1024; // 10MB
                if (stats.size > maxSize) {
                    console.log(`❌ 文件过大: ${filePath} (${stats.size} bytes)`);
                    return false;
                }
            }
        } catch (error) {
            console.log(`⚠️  无法访问文件: ${filePath} - ${error.message}`);
        }

        console.log(`✅ 文件操作安全: ${operation} ${filePath}`);
        return true;
    }

    /**
     * 检查是否为敏感路径
     * @param {string} path - 路径
     * @returns {boolean} - 是否敏感
     */
    isSensitivePath(path) {
        return this.sensitivePaths.some(pattern => pattern.test(path));
    }

    /**
     * 记录审计日志
     * @param {string} event - 事件类型
     * @param {string} details - 详细信息
     */
    logAudit(event, details) {
        const logEntry = {
            timestamp: new Date().toISOString(),
            event,
            details,
            user: process.env.USER || 'unknown'
        };

        const logFile = path.join(process.env.HOME || '', '.claude/audit.log');

        try {
            fs.appendFileSync(logFile, JSON.stringify(logEntry) + '\n');
        } catch (error) {
            console.log(`⚠️  无法写入审计日志: ${error.message}`);
        }
    }
}

// 主程序
if (require.main === module) {
    const validator = new CommandValidator();
    const command = process.argv[2];
    const args = process.argv.slice(3);

    if (!command) {
        console.log('用法: node validate.js <command> [args...]');
        process.exit(1);
    }

    // 验证命令
    if (!validator.validateCommand(command, args)) {
        // 记录失败尝试
        validator.logAudit('command_blocked', `${command} ${args.join(' ')}`);
        process.exit(1);
    }

    // 记录成功验证
    validator.logAudit('command_allowed', `${command} ${args.join(' ')}`);
}

module.exports = CommandValidator;