#!/usr/bin/env python3
"""
ClaudeCode 历史管理工具
作者：大熊掌门

功能：
- 查看命令历史
- 搜索历史记录
- 管理收藏的prompt
- 导出/导入历史
"""

import json
import os
import sys
import argparse
from pathlib import Path
from datetime import datetime
from typing import List, Dict, Any
import subprocess
import re

try:
    from rich.console import Console
    from rich.table import Table
    from rich.prompt import Prompt
    from rich.tree import Tree
    from rich import print as rprint
    from rich.panel import Panel
    from rich.text import Text
    HAS_RICH = True
except ImportError:
    HAS_RICH = False
    HAS_RICH = False

class HistoryManager:
    def __init__(self):
        self.history_file = Path.home() / ".claudecode_history.txt"
        self.favorites_file = Path(__file__).parent / "favorite-prompts.txt"
        self.templates_file = Path(__file__).parent / "prompt-templates.md"
        self.cli_aliases = Path(__file__).parent / ".." / "aliases"

    def load_history(self) -> List[str]:
        """加载历史记录"""
        if not self.history_file.exists():
            return []

        try:
            with open(self.history_file, 'r', encoding='utf-8') as f:
                return f.read().strip().split('\n')
        except:
            return []

    def save_history(self, history: List[str]) -> None:
        """保存历史记录"""
        try:
            with open(self.history_file, 'w', encoding='utf-8') as f:
                f.write('\n'.join(history))
        except:
            pass

    def load_favorites(self) -> List[str]:
        """加载收藏的prompt"""
        if not self.favorites_file.exists():
            return []

        try:
            with open(self.favorites_file, 'r', encoding='utf-8') as f:
                return [line.strip() for line in f.readlines() if line.strip()]
        except:
            return []

    def save_favorites(self, favorites: List[str]) -> None:
        """保存收藏的prompt"""
        try:
            with open(self.favorites_file, 'w', encoding='utf-8') as f:
                f.write('\n'.join(favorites))
        except:
            pass

    def list_history(self, limit: int = 20) -> None:
        """列出历史记录"""
        history = self.load_history()
        recent_history = history[-limit:] if len(history) > limit else history

        if HAS_RICH:
            console = Console()
            table = Table(title="最近的ClaudeCode命令历史")
            table.add_column("序号", style="cyan")
            table.add_column("时间", style="magenta")
            table.add_column("命令", style="green")

            for i, cmd in enumerate(recent_history, 1):
                # 尝试提取时间戳（如果有）
                time_match = re.search(r'(\d{4}-\d{2}-\d{2})', cmd)
                time_str = time_match.group(1) if time_match else "未知"

                table.add_row(str(i), time_str, cmd[:50] + "..." if len(cmd) > 50 else cmd)

            console.print(table)
        else:
            print("最近的ClaudeCode命令历史:")
            print("=" * 50)
            for i, cmd in enumerate(recent_history, 1):
                print(f"{i:3d}. {cmd[:60]}")

    def search_history(self, keyword: str) -> None:
        """搜索历史记录"""
        history = self.load_history()
        matches = [cmd for cmd in history if keyword.lower() in cmd.lower()]

        if not matches:
            print(f"没有找到包含 '{keyword}' 的命令")
            return

        if HAS_RICH:
            console = Console()
            table = Table(title=f"搜索结果：'{keyword}' ({len(matches)}条)")
            table.add_column("序号", style="cyan")
            table.add_column("匹配内容", style="green")

            for i, match in enumerate(matches[:20], 1):
                # 高亮关键词
                highlighted = re.sub(
                    f"({keyword})",
                    f"[bold red]{keyword}[/bold red]",
                    match,
                    flags=re.IGNORECASE
                )
                table.add_row(str(i), highlighted[:80] + "..." if len(highlighted) > 80 else highlighted)

            console.print(table)
        else:
            print(f"搜索结果：'{keyword}' ({len(matches)}条)")
            print("=" * 50)
            for i, match in enumerate(matches[:20], 1):
                print(f"{i:3d}. {match}")

    def add_to_favorites(self, prompt: str) -> None:
        """添加到收藏"""
        favorites = self.load_favorites()

        # 检查是否已存在
        if prompt in favorites:
            print("这个prompt已经在收藏中了")
            return

        favorites.append(prompt)
        self.save_favorites(favorites)
        print(f"已添加到收藏: {prompt}")

    def remove_from_favorites(self, index: int) -> None:
        """从收藏中移除"""
        favorites = self.load_favorites()

        if index < 1 or index > len(favorites):
            print("无效的索引号")
            return

        removed = favorites.pop(index - 1)  # 转换为0-based索引
        self.save_favorites(favorites)
        print(f"已从收藏中移除: {removed}")

    def list_favorites(self) -> None:
        """列出收藏的prompt"""
        favorites = self.load_favorites()

        if not favorites:
            print("还没有收藏的prompt")
            return

        if HAS_RICH:
            console = Console()
            table = Table(title="收藏的Prompt")
            table.add_column("序号", style="cyan")
            table.add_column("Prompt", style="green")
            table.add_column("预览", style="yellow")

            for i, prompt in enumerate(favorites, 1):
                preview = prompt[:60] + "..." if len(prompt) > 60 else prompt
                table.add_row(str(i), prompt, preview)

            console.print(table)
        else:
            print("收藏的Prompt:")
            print("=" * 50)
            for i, prompt in enumerate(favorites, 1):
                print(f"{i:3d}. {prompt}")

    def run_favorite(self, index: int) -> None:
        """运行收藏的prompt"""
        favorites = self.load_favorites()

        if index < 1 or index > len(favorites):
            print("无效的索引号")
            return

        prompt = favorites[index - 1]
        print(f"运行prompt: {prompt}")

        # 执行命令
        subprocess.run(f"claudecode \"{prompt}\"", shell=True)

    def export_history(self) -> None:
        """导出历史记录"""
        history = self.load_history()

        if not history:
            print("没有历史记录可导出")
            return

        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        export_file = f"claudecode_history_{timestamp}.txt"

        try:
            with open(export_file, 'w', encoding='uit-8') as f:
                f.write('\n'.join(history))
            print(f"历史记录已导出到: {export_file}")
        except Exception as e:
            print(f"导出失败: {e}")

    def show_stats(self) -> None:
        """显示统计信息"""
        history = self.load_history()
        favorites = self.load_favorites()

        stats = [
            ("历史记录总数", len(history)),
            ("收藏总数", len(favorites)),
            ("今日使用次数", len([cmd for cmd in history if self._is_today(cmd)])),
        ]

        if HAS_RICH:
            console = Console()
            table = Table(title="ClaudeCode 使用统计")
            table.add_column("项目", style="cyan")
            table.add_column("数量", style="green")

            for item, count in stats:
                table.add_row(item, str(count))

            console.print(table)
        else:
            print("ClaudeCode 使用统计:")
            print("=" * 30)
            for item, count in stats:
                print(f"{item}: {count}")

    def _is_today(self, cmd: str) -> bool:
        """检查是否是今天的记录"""
        # 简单的判断：如果包含今天的日期
        today = datetime.now().strftime("%Y-%m-%d")
        return today in cmd

    def clean_history(self) -> None:
        """清理历史记录"""
        print("清理选项：")
        print("1. 清理重复项")
        print("2. 清理空项")
        print("3. 清理所有历史")
        print("4. 取消")

        choice = input("请选择 (1-4): ").strip()

        history = self.load_history()

        if choice == "1":
            # 保留顺序，去重
            seen = set()
            cleaned = []
            for cmd in history:
                if cmd and cmd not in seen:
                    seen.add(cmd)
                    cleaned.append(cmd)
            self.save_history(cleaned)
            print(f"清理完成，从 {len(history)} 条记录中删除了 {len(history) - len(cleaned)} 条重复项")

        elif choice == "2":
            # 移除空行
            cleaned = [cmd for cmd in history if cmd.strip()]
            self.save_history(cleaned)
            print(f"清理完成，删除了 {len(history) - len(cleaned)} 条空行")

        elif choice == "3":
            # 清空所有
            self.save_history([])
            print("历史记录已清空")

        elif choice == "4":
            print("取消清理")
        else:
            print("无效的选择")

    def show_menu(self) -> None:
        """显示交互式菜单"""
        while True:
            print("\nClaudeCode 历史管理工具")
            print("=" * 30)
            print("1. 查看历史记录")
            print("2. 搜索历史")
            print("3. 添加到收藏")
            print("4. 管理收藏")
            print("5. 导出历史")
            print("6. 清理历史")
            print("7. 显示统计")
            print("8. 退出")

            choice = input("\n请选择 (1-8): ").strip()

            if choice == "1":
                limit = input("显示条数 (默认20): ").strip()
                limit = int(limit) if limit else 20
                self.list_history(limit)
            elif choice == "2":
                keyword = input("搜索关键词: ").strip()
                self.search_history(keyword)
            elif choice == "3":
                prompt = input("输入要添加的prompt: ").strip()
                self.add_to_favorites(prompt)
            elif choice == "4":
                print("\n收藏管理:")
                self.list_favorites()
                action = input("\n操作 (remove/back): ").strip().lower()
                if action == "remove":
                    index = input("要移除的序号: ").strip()
                    try:
                        self.remove_from_favorites(int(index))
                    except:
                        pass
                elif action == "back":
                    pass
                else:
                    self.run_favorite(int(index))
            elif choice == "5":
                self.export_history()
            elif choice == "6":
                self.clean_history()
            elif choice == "7":
                self.show_stats()
            elif choice == "8":
                print("退出历史管理工具")
                break
            else:
                print("无效的选择，请重试")

            input("\n按回车键继续...")

def main():
    parser = argparse.ArgumentParser(description='ClaudeCode 历史管理工具')
    parser.add_argument('--list', action='store_true', help='查看历史记录')
    parser.add_argument('--search', metavar='KEYWORD', help='搜索历史记录')
    parser.add_argument('--add-favorite', metavar='PROMPT', help='添加到收藏')
    parser.add_argument('--favorites', action='store_true', help='查看收藏')
    def run_favorite(self, metavar='INDEX', help='运行收藏的prompt')
    parser.add_argument('--export', action='store_true', help='导出历史记录')
    parser.add_argument('--clean', action='store_true', help='清理历史记录')
    parser.add_argument('--stats', action='store_true', help='显示统计信息')
    parser.add_argument('--menu', action='store_true', help='显示交互式菜单')

    args = parser.parse_args()

    manager = HistoryManager()

    if args.list:
        limit = 20
        manager.list_history(limit)
    elif args.search:
        manager.search_history(args.search)
    elif args.add_favorite:
        manager.add_to_favorites(args.add_favorite)
    elif args.favorites:
        manager.list_favorites()
    elif args.run_favorite:
        try:
            manager.run_favorite(int(args.run_favorite))
        except:
            pass
    elif args.export:
        manager.export_history()
    elif args.clean:
        manager.clean_history()
    elif args.stats:
        manager.show_stats()
    elif args.menu:
        manager.show_menu()
    else:
        parser.print_help()

if __name__ == '__main__':
    main()