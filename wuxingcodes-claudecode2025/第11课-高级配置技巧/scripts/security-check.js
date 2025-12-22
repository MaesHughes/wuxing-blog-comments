#!/usr/bin/env node

/**
 * ClaudeCode 安全检查脚本
 * 用于检查系统配置和潜在安全问题
 */

const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

class SecurityChecker {
    constructor() {
        this.homeDir = process.env.HOME || process.env.USERPROFILE;
        this.claudeDir = path.join(this.homeDir, '.claude');
    }

    /**
     * 执行完整的安全检查
     */
    async runFullCheck() {
        console.log('🔒 ClaudeCode 安全检查开始...\n');

        const checks = [
            { name: '权限配置', fn: this.checkPermissions },
            { name: '文件权限', fn: this.checkFilePermissions },
            { name: '敏感信息', fn: this.checkSensitiveInfo },
            { name: '网络配置', fn: this.checkNetworkConfig },
            { name: '审计日志', fn: this.checkAuditLogs },
            { name: '配置文件', fn: this.checkConfigFiles }
        ];

        const results = [];

        for (const check of checks) {
            console.log(`\n📋 检查 ${check.name}...`);
            try {
                const result = await check.fn.call(this);
                results.push({ name: check.name, ...result });
                console.log(`✅ ${check.name} 检查完成`);
            } catch (error) {
                results.push({
                    name: check.name,
                    status: 'error',
                    message: error.message
                });
                console.log(`❌ ${check.name} 检查失败: ${error.message}`);
            }
        }

        // 生成报告
        this.generateReport(results);
    }

    /**
     * 检查权限配置
     */
    async checkPermissions() {
        const configPath = path.join(this.claudeDir, 'settings.json');

        if (!fs.existsSync(configPath)) {
            return {
                status: 'warning',
                message: '未找到配置文件，使用默认配置'
            };
        }

        try {
            const config = JSON.parse(fs.readFileSync(configPath, 'utf8'));
            const issues = [];

            // 检查权限配置
            if (config.permissions) {
                const perms = config.permissions;

                // 检查是否有过于宽松的权限
                if (!perms.denied_commands || perms.denied_commands.length === 0) {
                    issues.push('未设置禁止命令列表');
                }

                if (!perms.denied_dirs || perms.denied_dirs.length === 0) {
                    issues.push('未设置禁止访问目录');
                }

                // 检查是否允许了危险命令
                const dangerousCommands = ['rm -rf', 'sudo', 'chmod 777'];
                if (perms.allowed_commands) {
                    for (const dangerous of dangerousCommands) {
                        if (perms.allowed_commands.includes(dangerous)) {
                            issues.push(`允许了危险命令: ${dangerous}`);
                        }
                    }
                }
            }

            // 检查沙盒配置
            if (!config.sandbox || !config.sandbox.enabled) {
                issues.push('未启用沙盒模式');
            }

            return {
                status: issues.length === 0 ? 'pass' : 'warning',
                issues
            };

        } catch (error) {
            return {
                status: 'error',
                message: `配置文件格式错误: ${error.message}`
            };
        }
    }

    /**
     * 检查文件权限
     */
    async checkFilePermissions() {
        const issues = [];

        // 检查Claude配置目录权限
        try {
            const stats = fs.statSync(this.claudeDir);
            const mode = (stats.mode & parseInt('777', 8)).toString(8);

            if (mode !== '700' && mode !== '755') {
                issues.push(`配置目录权限过于宽松: ${mode} (建议700或755)`);
            }
        } catch (error) {
            issues.push(`无法检查配置目录权限: ${error.message}`);
        }

        // 检查敏感文件权限
        const sensitiveFiles = [
            path.join(this.homeDir, '.ssh', 'id_rsa'),
            path.join(this.homeDir, '.aws', 'credentials'),
            path.join(this.claudeDir, 'auth.json')
        ];

        for (const file of sensitiveFiles) {
            try {
                if (fs.existsSync(file)) {
                    const stats = fs.statSync(file);
                    const mode = (stats.mode & parseInt('777', 8)).toString(8);

                    if (mode !== '600' && mode !== '400') {
                        issues.push(`敏感文件权限过于宽松: ${file} (${mode})`);
                    }
                }
            } catch (error) {
                // 忽略文件不存在的错误
            }
        }

        return {
            status: issues.length === 0 ? 'pass' : 'warning',
            issues
        };
    }

    /**
     * 检查敏感信息泄露
     */
    async checkSensitiveInfo() {
        const issues = [];
        const sensitivePatterns = [
            /password\s*[:=]\s*['"`][^'"`]+['"`]/gi,
            /secret\s*[:=]\s*['"`][^'"`]+['"`]/gi,
            /token\s*[:=]\s*['"`][^'"`]+['"`]/gi,
            /api[_-]?key\s*[:=]\s*['"`][^'"`]+['"`]/gi,
            /sk-[a-zA-Z0-9]{48}/gi,  // Stripe密钥
            /ghp_[a-zA-Z0-9]{36}/gi, // GitHub密钥
            /AKIA[0-9A-Z]{16}/gi      // AWS密钥
        ];

        // 检查配置文件
        const configFiles = [
            path.join(this.claudeDir, 'settings.json'),
            path.join(process.cwd(), '.env'),
            path.join(process.cwd(), '.env.local')
        ];

        for (const file of configFiles) {
            try {
                if (fs.existsSync(file)) {
                    const content = fs.readFileSync(file, 'utf8');

                    for (const pattern of sensitivePatterns) {
                        const matches = content.match(pattern);
                        if (matches) {
                            issues.push(`在 ${file} 中发现潜在敏感信息`);
                        }
                    }
                }
            } catch (error) {
                // 忽略读取错误
            }
        }

        return {
            status: issues.length === 0 ? 'pass' : 'warning',
            issues
        };
    }

    /**
     * 检查网络配置
     */
    async checkNetworkConfig() {
        const issues = [];

        // 检查代理配置是否安全
        const proxyVars = ['HTTP_PROXY', 'HTTPS_PROXY', 'http_proxy', 'https_proxy'];
        const hasProxy = proxyVars.some(varName => process.env[varName]);

        if (hasProxy) {
            // 检查是否使用HTTPS代理
            const httpsProxy = process.env.HTTPS_PROXY || process.env.https_proxy;
            if (httpsProxy && !httpsProxy.startsWith('https://')) {
                issues.push('HTTPS代理未使用加密连接');
            }
        }

        // 检查网络超时配置
        const configPath = path.join(this.claudeDir, 'settings.json');
        if (fs.existsSync(configPath)) {
            try {
                const config = JSON.parse(fs.readFileSync(configPath, 'utf8'));
                if (config.network && !config.network.timeout) {
                    issues.push('未设置网络超时配置');
                }
            } catch (error) {
                // 忽略解析错误
            }
        }

        return {
            status: issues.length === 0 ? 'pass' : 'warning',
            issues
        };
    }

    /**
     * 检查审计日志
     */
    async checkAuditLogs() {
        const logDir = path.join(this.claudeDir, 'logs');
        const issues = [];

        if (!fs.existsSync(logDir)) {
            issues.push('日志目录不存在');
            return {
                status: 'warning',
                issues
            };
        }

        try {
            const logFiles = fs.readdirSync(logDir);
            const auditLog = path.join(logDir, 'audit.log');

            if (!fs.existsSync(auditLog)) {
                issues.push('审计日志文件不存在');
            } else {
                // 检查日志文件权限
                const stats = fs.statSync(auditLog);
                const mode = (stats.mode & parseInt('777', 8)).toString(8);

                if (mode !== '600' && mode !== '640') {
                    issues.push(`审计日志权限过于宽松: ${mode}`);
                }

                // 检查日志文件大小
                const maxSize = 100 * 1024 * 1024; // 100MB
                if (stats.size > maxSize) {
                    issues.push(`审计日志文件过大: ${(stats.size / 1024 / 1024).toFixed(2)}MB`);
                }
            }

        } catch (error) {
            issues.push(`无法访问日志目录: ${error.message}`);
        }

        return {
            status: issues.length === 0 ? 'pass' : 'warning',
            issues
        };
    }

    /**
     * 检查配置文件完整性
     */
    async checkConfigFiles() {
        const issues = [];
        const requiredFiles = ['settings.json'];
        const optionalFiles = ['permissions.json', 'mcp.json'];

        // 检查必需文件
        for (const file of requiredFiles) {
            const filePath = path.join(this.claudeDir, file);
            if (!fs.existsSync(filePath)) {
                issues.push(`缺少必需配置文件: ${file}`);
            } else {
                // 验证JSON格式
                try {
                    JSON.parse(fs.readFileSync(filePath, 'utf8'));
                } catch (error) {
                    issues.push(`配置文件格式错误: ${file} - ${error.message}`);
                }
            }
        }

        return {
            status: issues.length === 0 ? 'pass' : 'warning',
            issues
        };
    }

    /**
     * 生成安全检查报告
     */
    generateReport(results) {
        console.log('\n' + '='.repeat(50));
        console.log('📊 安全检查报告');
        console.log('='.repeat(50));

        let passCount = 0;
        let warningCount = 0;
        let errorCount = 0;

        for (const result of results) {
            const status = result.status === 'pass' ? '✅' :
                          result.status === 'warning' ? '⚠️' : '❌';

            console.log(`\n${status} ${result.name}`);

            if (result.issues && result.issues.length > 0) {
                for (const issue of result.issues) {
                    console.log(`   - ${issue}`);
                }
            }

            if (result.message) {
                console.log(`   - ${result.message}`);
            }

            // 统计
            if (result.status === 'pass') passCount++;
            else if (result.status === 'warning') warningCount++;
            else errorCount++;
        }

        // 总结
        console.log('\n' + '-'.repeat(50));
        console.log('总结:');
        console.log(`  通过: ${passCount}`);
        console.log(`  警告: ${warningCount}`);
        console.log(`  错误: ${errorCount}`);

        if (errorCount > 0) {
            console.log('\n❌ 发现严重安全问题，请立即处理！');
            process.exit(1);
        } else if (warningCount > 0) {
            console.log('\n⚠️  发现安全问题，建议尽快处理');
        } else {
            console.log('\n✅ 安全检查通过，配置良好');
        }

        // 保存报告
        this.saveReport(results);
    }

    /**
     * 保存安全检查报告
     */
    saveReport(results) {
        const report = {
            timestamp: new Date().toISOString(),
            results
        };

        const reportPath = path.join(this.claudeDir, 'security-report.json');

        try {
            fs.writeFileSync(reportPath, JSON.stringify(report, null, 2));
            console.log(`\n📄 报告已保存到: ${reportPath}`);
        } catch (error) {
            console.log(`\n⚠️  无法保存报告: ${error.message}`);
        }
    }
}

// 主程序
if (require.main === module) {
    const checker = new SecurityChecker();
    checker.runFullCheck().catch(console.error);
}

module.exports = SecurityChecker;