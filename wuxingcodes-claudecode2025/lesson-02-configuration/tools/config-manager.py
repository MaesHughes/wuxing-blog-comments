#!/usr/bin/env python3
"""
ClaudeCode 配置管理工具
作者：大熊掌门

功能：
- 验证配置文件
- 优化配置参数
- 切换配置文件
- 生成配置报告
"""

import json
import os
import sys
import argparse
from pathlib import Path
from typing import Dict, List, Any
import logging

# 配置日志
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

class ConfigManager:
    def __init__(self):
        self.config_dir = Path.home() / ".config" / "claude-desktop"
        self.config_file = self.config_dir / "claude_desktop_config.json"

    def validate_config(self, config_path: str = None) -> bool:
        """验证配置文件"""
        if config_path:
            config_file = Path(config_path)
        else:
            config_file = self.config_file

        if not config_file.exists():
            logger.error(f"配置文件不存在: {config_file}")
            return False

        try:
            with open(config_file, 'r', encoding='utf-8') as f:
                config = json.load(f)

            # 验证必要字段
            required_fields = ['providers', 'version']
            for field in required_fields:
                if field not in config:
                    logger.error(f"缺少必要字段: {field}")
                    return False

            # 验证 providers
            providers = config.get('providers', {})
            if not providers:
                logger.error("没有配置任何 providers")
                return False

            for provider_name, provider_config in providers.items():
                if 'api_key' not in provider_config and '${' not in str(provider_config.get('api_key', '')):
                    logger.warning(f"{provider_name} 缺少 api_key")

            # 验证 mcpServers
            mcp_servers = config.get('mcpServers', {})
            for server_name, server_config in mcp_servers.items():
                if 'command' not in server_config:
                    logger.warning(f"MCP 服务器 {server_name} 缺少 command")

            logger.info("配置文件验证通过")
            return True

        except json.JSONDecodeError as e:
            logger.error(f"JSON 格式错误: {e}")
            return False
        except Exception as e:
            logger.error(f"验证失败: {e}")
            return False

    def optimize_config(self, config_path: str = None) -> None:
        """优化配置参数"""
        if config_path:
            config_file = Path(config_path)
        else:
            config_file = self.config_file

        with open(config_file, 'r', encoding='utf-8') as f:
            config = json.load(f)

        # 性能优化建议
        performance = config.get('performance', {})

        if performance.get('maxConcurrentRequests', 5) < 3:
            logger.info("建议: maxConcurrentRequests 设置为 5 或更高以获得更好性能")

        if not performance.get('cacheEnabled', True):
            logger.info("建议: 启用缓存以提高响应速度")

        if performance.get('cacheSize', 1000) < 500:
            logger.info("建议: cacheSize 设置为 1000 或更大")

        # 安全优化建议
        security = config.get('security', {})

        if security.get('allowedHosts'):
            allowed_hosts = security['allowedHosts']
            if 'localhost' not in allowed_hosts and '127.0.0.1' not in allowed_hosts:
                logger.warning("安全建议: 确保 allowedHosts 包含 localhost")

        if not security.get('enableSandbox', False):
            logger.info("安全建议: 考虑启用 sandbox 以增加安全性")

        logger.info("配置优化分析完成")

    def switch_config(self, profile_name: str) -> bool:
        """切换到指定的配置文件"""
        profiles_dir = Path(__file__).parent.parent / 'profiles'
        profile_file = profiles_dir / f"{profile_name}.json"

        if not profile_file.exists():
            logger.error(f"配置文件不存在: {profile_file}")
            return False

        try:
            # 备份当前配置
            if self.config_file.exists():
                backup_file = self.config_file.with_suffix('.json.backup')
                self.config_file.rename(backup_file)
                logger.info(f"当前配置已备份到: {backup_file}")

            # 复制新配置
            import shutil
            self.config_dir.mkdir(parents=True, exist_ok=True)
            shutil.copy2(profile_file, self.config_file)

            logger.info(f"已切换到配置: {profile_name}")
            return True

        except Exception as e:
            logger.error(f"切换配置失败: {e}")
            return False

    def generate_report(self, config_path: str = None) -> None:
        """生成配置报告"""
        if config_path:
            config_file = Path(config_path)
        else:
            config_file = self.config_file

        with open(config_file, 'r', encoding='utf-8') as f:
            config = json.load(f)

        report = []
        report.append("ClaudeCode 配置报告")
        report.append("=" * 50)
        report.append(f"配置文件: {config_file}")
        report.append(f"生成时间: {os.popen('date').read().strip()}")
        report.append("")

        # Providers 信息
        providers = config.get('providers', {})
        report.append("AI Providers:")
        for name, provider in providers.items():
            model = provider.get('model', 'Unknown')
            report.append(f"  - {name}: {model}")
        report.append("")

        # MCP 服务器
        mcp_servers = config.get('mcpServers', {})
        report.append(f"MCP 服务器数量: {len(mcp_servers)}")
        for name in mcp_servers.keys():
            report.append(f"  - {name}")
        report.append("")

        # 性能配置
        performance = config.get('performance', {})
        report.append("性能配置:")
        report.append(f"  - 最大并发数: {performance.get('maxConcurrentRequests', 5)}")
        report.append(f"  - 缓存启用: {performance.get('cacheEnabled', True)}")
        report.append(f"  - 缓存大小: {performance.get('cacheSize', 1000)}")
        report.append("")

        # 功能特性
        features = config.get('features', {})
        report.append("功能特性:")
        for key, value in features.items():
            report.append(f"  - {key}: {value}")
        report.append("")

        # 保存报告
        report_file = self.config_dir / "config-report.txt"
        with open(report_file, 'w', encoding='utf-8') as f:
            f.write('\n'.join(report))

        logger.info(f"配置报告已生成: {report_file}")

    def list_profiles(self) -> None:
        """列出所有可用的配置文件"""
        profiles_dir = Path(__file__).parent.parent / 'profiles'

        if not profiles_dir.exists():
            logger.info("没有找到配置文件目录")
            return

        logger.info("可用的配置文件:")
        for profile_file in profiles_dir.glob('*.json'):
            profile_name = profile_file.stem
            logger.info(f"  - {profile_name}")

def main():
    parser = argparse.ArgumentParser(description='ClaudeCode 配置管理工具')
    parser.add_argument('--validate', action='store_true', help='验证配置文件')
    parser.add_argument('--optimize', action='store_true', help='优化配置参数')
    parser.add_argument('--switch', metavar='PROFILE', help='切换到指定的配置文件')
    parser.add_argument('--report', action='store_true', help='生成配置报告')
    parser.add_argument('--list', action='store_true', help='列出所有配置文件')
    parser.add_argument('--config', metavar='PATH', help='指定配置文件路径')

    args = parser.parse_args()

    manager = ConfigManager()

    if args.validate:
        manager.validate_config(args.config)
    elif args.optimize:
        manager.optimize_config(args.config)
    elif args.switch:
        manager.switch_config(args.switch)
    elif args.report:
        manager.generate_report(args.config)
    elif args.list:
        manager.list_profiles()
    else:
        parser.print_help()

if __name__ == '__main__':
    main()