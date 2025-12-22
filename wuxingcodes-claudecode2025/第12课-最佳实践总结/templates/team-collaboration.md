# 团队协作配置模板

## 协作架构设计

```
┌─────────────────────────────────────────────────┐
│                团队协作架构                       │
│                                                 │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  │
│  │  开发团队   │  │  测试团队   │  │  运维团队   │  │
│  │             │  │             │  │             │  │
│  │  功能开发   │  │  质量保证   │  │  部署运维   │  │
│  │  代码审查   │  │  自动化测试 │  │  监控告警   │  │
│  │  单元测试   │  │  性能测试   │  │  故障处理   │  │
│  └─────────────┘  └─────────────┘  └─────────────┘  │
│         │                │                │        │
│         └────────────────┼────────────────┘        │
│                          │                          │
│  ┌─────────────────────────────────────────────────┐  │
│  │             ClaudeCode 协作平台                  │  │
│  │                                                 │  │
│  │  ┌─────────┐  ┌─────────┐  ┌─────────┐          │  │
│  │  │代码仓库 │  │CI/CD流水 │  │文档中心 │          │  │
│  │  │GitHub   │  │Jenkins  │  │Confluence│          │  │
│  │  │GitLab   │  │GitLab CI│  │Notion   │          │  │
│  │  └─────────┘  └─────────┘  └─────────┘          │  │
│  │                                                 │  │
│  │  ┌─────────┐  ┌─────────┐  ┌─────────┐          │  │
│  │  │项目管理 │  │通信协作 │  │知识库   │          │  │
│  │  │Jira     │  │Slack    │  │Wiki     │          │  │
│  │  │Trello   │  │Teams    │  │GitBook  │          │  │
│  │  └─────────┘  └─────────┘  └─────────┘          │  │
│  └─────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────┘
```

## 角色权限配置

### 团队角色定义

```yaml
team_roles:
  owner:
    name: "所有者"
    permissions:
      - "system:*"
      - "user:*"
      - "config:*"
      - "deployment:*"
    description: "拥有所有权限，负责系统整体管理"

  admin:
    name: "管理员"
    permissions:
      - "user:read"
      - "user:create"
      - "user:update"
      - "config:read"
      - "config:update"
      - "deployment:read"
      - "deployment:update"
    description: "负责用户管理和系统配置"

  developer:
    name: "开发者"
    permissions:
      - "code:*"
      - "config:read"
      - "deployment:staging"
      - "logs:read"
    description: "负责功能开发和代码提交"

  tester:
    name: "测试工程师"
    permissions:
      - "test:*"
      - "deployment:staging"
      - "logs:read"
      - "config:read"
    description: "负责测试和质量保证"

  ops:
    name: "运维工程师"
    permissions:
      - "deployment:*"
      - "monitoring:*"
      - "logs:*"
      - "backup:*"
    description: "负责部署和系统运维"

  viewer:
    name: "观察者"
    permissions:
      - "code:read"
      - "logs:read"
      - "monitoring:read"
    description: "只读权限，可以查看系统状态"
```

### 权限控制系统

```python
# rbac.py - 基于角色的访问控制

class Permission:
    """权限定义"""
    # 系统权限
    SYSTEM_ADMIN = "system:admin"
    SYSTEM_MONITOR = "system:monitor"

    # 用户权限
    USER_READ = "user:read"
    USER_CREATE = "user:create"
    USER_UPDATE = "user:update"
    USER_DELETE = "user:delete"

    # 代码权限
    CODE_READ = "code:read"
    CODE_WRITE = "code:write"
    CODE_REVIEW = "code:review"
    CODE_MERGE = "code:merge"

    # 配置权限
    CONFIG_READ = "config:read"
    CONFIG_UPDATE = "config:update"

    # 部署权限
    DEPLOY_READ = "deployment:read"
    DEPLOY_STAGING = "deployment:staging"
    DEPLOY_PRODUCTION = "deployment:production"

    # 监控权限
    MONITOR_READ = "monitoring:read"
    MONITOR_UPDATE = "monitoring:update"

class Role:
    """角色定义"""
    ROLES = {
        'owner': [
            Permission.SYSTEM_ADMIN,
            Permission.USER_CREATE,
            Permission.USER_UPDATE,
            Permission.USER_DELETE,
            Permission.CODE_WRITE,
            Permission.CODE_REVIEW,
            Permission.CONFIG_UPDATE,
            Permission.DEPLOY_PRODUCTION,
            Permission.MONITOR_UPDATE,
        ],
        'admin': [
            Permission.USER_READ,
            Permission.USER_CREATE,
            Permission.USER_UPDATE,
            Permission.CONFIG_READ,
            Permission.CONFIG_UPDATE,
            Permission.DEPLOY_READ,
            Permission.DEPLOY_STAGING,
        ],
        'developer': [
            Permission.CODE_READ,
            Permission.CODE_WRITE,
            Permission.CONFIG_READ,
            Permission.DEPLOY_STAGING,
        ],
        'tester': [
            Permission.CODE_READ,
            Permission.DEPLOY_STAGING,
            Permission.CONFIG_READ,
        ],
        'ops': [
            Permission.DEPLOY_READ,
            Permission.DEPLOY_STAGING,
            Permission.DEPLOY_PRODUCTION,
            Permission.MONITOR_READ,
            Permission.MONITOR_UPDATE,
        ],
        'viewer': [
            Permission.CODE_READ,
            Permission.MONITOR_READ,
        ],
    }

class RBAC:
    """权限控制类"""

    @staticmethod
    def has_permission(user_role: str, permission: str) -> bool:
        """检查用户是否有指定权限"""
        role_permissions = Role.ROLES.get(user_role, [])
        return permission in role_permissions

    @staticmethod
    def check_permissions(user_role: str, required_permissions: list) -> bool:
        """检查用户是否拥有所有必需权限"""
        return all(RBAC.has_permission(user_role, perm) for perm in required_permissions)
```

## 工作流配置

### Git工作流

```yaml
git_workflow:
  branches:
    main:
      description: "主分支，生产环境代码"
      protection:
        require_reviews: true
        required_reviewers: 2
        require_status_checks: true
        status_checks:
          - "ci/test"
          - "ci/security"
          - "ci/lint"

    develop:
      description: "开发分支，集成最新功能"
      protection:
        require_reviews: true
        required_reviewers: 1
        require_status_checks: true
        status_checks:
          - "ci/test"
          - "ci/lint"

    feature/*:
      description: "功能分支，从develop创建"
      protection:
        require_reviews: false

    release/*:
      description: "发布分支，从main创建"
      protection:
        require_reviews: true
        required_reviewers: 2

    hotfix/*:
      description: "热修复分支，从main创建"
      protection:
        require_reviews: true
        required_reviewers: 2

  commit_rules:
    format: "type(scope): description"
    types:
      - "feat: 新功能"
      - "fix: 修复bug"
      - "docs: 文档更新"
      - "style: 代码格式化"
      - "refactor: 重构"
      - "test: 测试"
      - "chore: 构建或工具"
    examples:
      - "feat(auth): 添加OAuth2认证"
      - "fix(api): 修复用户创建接口错误"
      - "docs(readme): 更新安装说明"

  pull_request_template: |
    ## 变更描述
    请简要描述此PR的内容和目的

    ## 变更类型
    - [ ] 新功能 (feature)
    - [ ] 修复 (fix)
    - [ ] 文档 (docs)
    - [ ] 样式 (style)
    - [ ] 重构 (refactor)
    - [ ] 测试 (test)
    - [ ] 构建 (build)

    ## 测试
    - [ ] 单元测试已通过
    - [ ] 集成测试已通过
    - [ ] 手动测试已完成

    ## 检查清单
    - [ ] 代码符合项目规范
    - [ ] 已添加必要的注释
    - [ ] 已更新相关文档
    - [ ] 无安全漏洞
    - [ ] 性能影响可接受
```

### CI/CD流水线

```yaml
# .github/workflows/ci-cd.yml
name: CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  # 代码质量检查
  quality:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3

    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: '3.9'

    - name: Install dependencies
      run: |
        pip install flake8 black isort mypy
        pip install -r requirements.txt

    - name: Run linting
      run: |
        flake8 --max-line-length=120 --exclude=migrations .
        black --check .
        isort --check-only .
        mypy .

    - name: Run security scan
      run: |
        pip install bandit safety
        bandit -r .
        safety check

  # 单元测试
  test:
    runs-on: ubuntu-latest
    needs: quality

    strategy:
      matrix:
        python-version: [3.8, 3.9, 3.10]

    steps:
    - uses: actions/checkout@v3

    - name: Set up Python ${{ matrix.python-version }}
      uses: actions/setup-python@v4
      with:
        python-version: ${{ matrix.python-version }}

    - name: Install dependencies
      run: |
        pip install -r requirements.txt
        pip install -r requirements-test.txt

    - name: Run tests
      run: |
        pytest --cov=app --cov-report=xml

    - name: Upload coverage
      uses: codecov/codecov-action@v3
      with:
        file: ./coverage.xml

  # 构建Docker镜像
  build:
    runs-on: ubuntu-latest
    needs: test
    if: github.ref == 'refs/heads/main' || github.ref == 'refs/heads/develop'

    steps:
    - uses: actions/checkout@v3

    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v2

    - name: Log in to Container Registry
      uses: docker/login-action@v2
      with:
        registry: ${{ env.REGISTRY }}
        username: ${{ github.actor }}
        password: ${{ secrets.GITHUB_TOKEN }}

    - name: Extract metadata
      id: meta
      uses: docker/metadata-action@v4
      with:
        images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
        tags: |
          type=ref,event=branch
          type=ref,event=pr
          type=sha

    - name: Build and push Docker image
      uses: docker/build-push-action@v4
      with:
        context: .
        push: true
        tags: ${{ steps.meta.outputs.tags }}
        labels: ${{ steps.meta.outputs.labels }}
        cache-from: type=gha
        cache-to: type=gha,mode=max

  # 部署到测试环境
  deploy-staging:
    runs-on: ubuntu-latest
    needs: build
    if: github.ref == 'refs/heads/develop'
    environment: staging

    steps:
    - uses: actions/checkout@v3

    - name: Deploy to staging
      run: |
        # 部署到测试环境的脚本
        echo "Deploying to staging environment..."
        # 这里可以是kubectl apply, docker-compose等命令

  # 部署到生产环境
  deploy-production:
    runs-on: ubuntu-latest
    needs: build
    if: github.ref == 'refs/heads/main'
    environment: production

    steps:
    - uses: actions/checkout@v3

    - name: Deploy to production
      run: |
        # 部署到生产环境的脚本
        echo "Deploying to production environment..."
        # 执行蓝绿部署或滚动更新
```

## 代码审查规范

### 审查清单

```markdown
# 代码审查清单

## 功能性
- [ ] 代码实现了需求文档中的所有功能
- [ ] 边界条件处理正确
- [ ] 错误处理完善
- [ ] 性能考虑合理

## 代码质量
- [ ] 代码逻辑清晰易懂
- [ ] 变量和函数命名规范
- [ ] 代码结构合理
- [ ] 没有明显的代码重复
- [ ] 注释充分且准确

## 安全性
- [ ] 输入验证完整
- [ ] SQL注入防护
- [ ] XSS攻击防护
- [ ] 敏感信息保护
- [ ] 权限控制正确

## 测试
- [ ] 单元测试覆盖率达标
- [ ] 测试用例设计合理
- [ ] 集成测试通过
- [ ] 性能测试满足要求

## 文档
- [ ] API文档更新
- [ ] 代码注释充分
- [ ] README更新
- [ ] 变更日志记录
```

### 审查流程

```python
# review_flow.py - 代码审查流程

class CodeReviewFlow:
    """代码审查流程管理"""

    def __init__(self):
        self.reviewers = {
            'frontend': ['alice', 'bob'],
            'backend': ['charlie', 'david'],
            'devops': ['eve'],
            'security': ['frank']
        }

    def get_required_reviewers(self, pr_info):
        """获取必需的审查者"""
        reviewers = []

        # 根据修改的文件确定审查者
        if any(f.startswith('frontend/') for f in pr_info['changed_files']):
            reviewers.extend(self.reviewers['frontend'])

        if any(f.startswith('backend/') for f in pr_info['changed_files']):
            reviewers.extend(self.reviewers['backend'])

        if any(f.startswith('deploy/') or f.startswith('docker/') for f in pr_info['changed_files']):
            reviewers.extend(self.reviewers['devops'])

        # 安全审查（敏感代码）
        if any('auth' in f or 'security' in f for f in pr_info['changed_files']):
            reviewers.extend(self.reviewers['security'])

        # 去重
        return list(set(reviewers))

    def check_review_status(self, pr_info):
        """检查审查状态"""
        required_reviewers = self.get_required_reviewers(pr_info)
        approvals = pr_info.get('approvals', [])

        missing_reviews = set(required_reviewers) - set(approvals)
        requested_changes = pr_info.get('requested_changes', [])

        return {
            'can_merge': len(missing_reviews) == 0 and len(requested_changes) == 0,
            'missing_reviews': list(missing_reviews),
            'requested_changes': requested_changes
        }

    def auto_assign_reviewers(self, pr_info):
        """自动分配审查者"""
        # 轮询分配算法
        reviewer_load = {r: 0 for r in self.reviewers['backend']}

        # 更新当前负载
        for pr in self.get_open_prs():
            for reviewer in pr.get('assigned_reviewers', []):
                if reviewer in reviewer_load:
                    reviewer_load[reviewer] += 1

        # 分配负载最轻的审查者
        required = self.get_required_reviewers(pr_info)
        assigned = []

        for role in required:
            candidates = [r for r in self.reviewers.get(role, []) if r not in assigned]
            if candidates:
                reviewer = min(candidates, key=lambda x: reviewer_load.get(x, 0))
                assigned.append(reviewer)
                reviewer_load[reviewer] = reviewer_load.get(reviewer, 0) + 1

        return assigned
```

## 团队沟通配置

### Slack集成

```yaml
# slack-integration.yml
slack_config:
  bot_token: "xoxb-your-bot-token"
  app_token: "xapp-your-app-token"

  channels:
    dev-alerts: "C0123456789"  # 开发告警
    ci-cd: "C0987654321"       # CI/CD通知
    code-review: "C1122334455"  # 代码审查
    deployments: "C5566778899"  # 部署通知
    incidents: "C9988776655"    # 故障响应

  notifications:
    pull_request:
      opened:
        channel: "code-review"
        message: |
          🆕 New PR: *<{pr_url}|{title}>*
          Author: {author}
          Reviewers: {reviewers}

      approved:
        channel: "code-review"
        message: |
          ✅ PR Approved: *<{pr_url}|{title}>*
          Approved by: {reviewer}

      merged:
        channel: "ci-cd"
        message: |
          🎉 PR Merged: *<{pr_url}|{title}>*
          Merged by: {merger}

    deployment:
      started:
        channel: "deployments"
        message: |
          🚀 Deployment Started: {environment}
          Commit: {commit}
          Deployer: {deployer}

      success:
        channel: "deployments"
        message: |
          ✅ Deployment Successful: {environment}
          Duration: {duration}

      failed:
        channel: "incidents"
        message: |
          ❌ Deployment Failed: {environment}
          Error: {error}
          @channel 请检查
```

### 自动化通知机器人

```python
# slack_bot.py - Slack通知机器人

import os
import requests
from datetime import datetime

class SlackNotifier:
    def __init__(self, token):
        self.token = token
        self.base_url = "https://slack.com/api"

    def send_message(self, channel, message):
        """发送消息到频道"""
        url = f"{self.base_url}/chat.postMessage"
        headers = {
            "Authorization": f"Bearer {self.token}",
            "Content-Type": "application/json"
        }
        data = {
            "channel": channel,
            "text": message
        }

        response = requests.post(url, headers=headers, json=data)
        return response.json()

    def notify_pr_opened(self, pr_data):
        """通知PR开启"""
        message = f"""🆕 新的Pull Request
标题: {pr_data['title']}
作者: {pr_data['author']}
链接: {pr_data['url']}
需要审查: {', '.join(pr_data['reviewers'])}"""

        self.send_message(os.getenv('SLACK_CODE_REVIEW_CHANNEL'), message)

    def notify_deployment(self, env, status, details=None):
        """通知部署状态"""
        if status == 'started':
            message = f"🚀 开始部署到 {env} 环境"
        elif status == 'success':
            message = f"✅ {env} 环境部署成功"
        else:
            message = f"❌ {env} 环境部署失败: {details}"

        channel = os.getenv('SLACK_DEPLOYMENTS_CHANNEL')
        self.send_message(channel, message)

    def notify_incident(self, severity, message):
        """通知故障"""
        emoji = {"critical": "🚨", "warning": "⚠️", "info": "ℹ️"}
        prefix = emoji.get(severity, "📢")

        formatted_msg = f"{prefix} {severity.upper()}: {message}"

        # 紧急故障@相关人员
        if severity == 'critical':
            formatted_msg += "\n@channel 请立即处理"

        channel = os.getenv('SLACK_INCIDENTS_CHANNEL')
        self.send_message(channel, formatted_msg)
```

## 知识管理

### 文档模板

```markdown
# 技术文档模板

## 项目概述
- 项目背景
- 核心功能
- 技术栈
- 架构设计

## 快速开始
- 环境要求
- 安装步骤
- 配置说明
- 运行测试

## API文档
### 接口列表
- [ ] 用户管理
- [ ] 认证授权
- [ ] 数据查询

### 接口详情
```http
GET /api/users
```

**请求参数:**
- page: 页码
- size: 每页数量

**响应示例:**
```json
{
  "code": 200,
  "data": [...]
}
```

## 开发指南
- 代码规范
- 分支策略
- 提交规范
- 测试要求

## 部署指南
- 环境配置
- 部署步骤
- 配置说明
- 监控设置

## 运维手册
- 日常检查
- 故障处理
- 性能优化
- 备份恢复

## 常见问题
- Q1: 如何配置数据库连接？
- A1: ...

## 更新日志
### v1.0.0 (2024-01-01)
- 初始版本发布
```

### Wiki组织结构

```
知识库/
├── 01-项目文档/
│   ├── 项目概述.md
│   ├── 需求文档/
│   ├── 设计文档/
│   └── 会议记录/
├── 02-开发指南/
│   ├── 环境搭建.md
│   ├── 代码规范.md
│   ├── API文档/
│   └── 测试指南.md
├── 03-部署运维/
│   ├── 环境配置.md
│   ├── 部署流程.md
│   ├── 监控告警.md
│   └── 故障处理.md
├── 04-团队协作/
│   ├── 工作流程.md
│   ├── 代码审查.md
│   ├── 发布规范.md
│   └── 值班安排.md
└── 05-知识分享/
    ├── 技术分享/
    ├── 案例研究/
    ├── 最佳实践/
    └── 外部资源/
```

## 团队绩效管理

### 代码质量指标

```yaml
quality_metrics:
  code_coverage:
    target: 80%
    warning: 70%

  code_review_time:
    target: "24h"
    warning: "48h"

  bug_fix_time:
    target: "4h"
    warning: "8h"

  deployment_frequency:
    target: "daily"
    warning: "weekly"

  change_failure_rate:
    target: "5%"
    warning: "10%"

  mean_time_to_recovery:
    target: "1h"
    warning: "4h"
```

### 团队Dashboard

```python
# team_dashboard.py - 团队绩效仪表板

class TeamDashboard:
    def __init__(self):
        self.metrics = {
            'productivity': {
                'commits_today': 0,
                'prs_opened': 0,
                'prs_merged': 0,
                'issues_closed': 0
            },
            'quality': {
                'code_coverage': 0,
                'test_pass_rate': 0,
                'bug_count': 0,
                'code_review_time': 0
            },
            'collaboration': {
                'active_reviewers': 0,
                'avg_review_time': 0,
                'knowledge_shares': 0
            }
        }

    def update_metrics(self):
        """更新指标数据"""
        # 从GitHub/GitLab获取数据
        self.metrics['productivity']['commits_today'] = self.get_commits_today()
        self.metrics['productivity']['prs_opened'] = self.get_prs_opened()
        self.metrics['productivity']['prs_merged'] = self.get_prs_merged()

        # 从测试系统获取质量数据
        self.metrics['quality']['code_coverage'] = self.get_code_coverage()
        self.metrics['quality']['test_pass_rate'] = self.get_test_pass_rate()

        # 计算协作指标
        self.metrics['collaboration']['active_reviewers'] = self.get_active_reviewers()

    def generate_report(self):
        """生成团队报告"""
        report = f"""
# 团队绩效报告 - {datetime.now().strftime('%Y-%m-%d')}

## 生产力指标
- 今日提交: {self.metrics['productivity']['commits_today']}
- 新建PR: {self.metrics['productivity']['prs_opened']}
- 合并PR: {self.metrics['productivity']['prs_merged']}
- 关闭Issue: {self.metrics['productivity']['issues_closed']}

## 质量指标
- 代码覆盖率: {self.metrics['quality']['code_coverage']}%
- 测试通过率: {self.metrics['quality']['test_pass_rate']}%
- 活跃Bug: {self.metrics['quality']['bug_count']}
- 平均审查时间: {self.metrics['quality']['code_review_time']}h

## 协作指标
- 活跃审查者: {self.metrics['collaboration']['active_reviewers']}
- 平均审查时间: {self.metrics['collaboration']['avg_review_time']}h
- 本月技术分享: {self.metrics['collaboration']['knowledge_shares']}

## 改进建议
{self.generate_recommendations()}
        """
        return report

    def generate_recommendations(self):
        """生成改进建议"""
        recommendations = []

        if self.metrics['quality']['code_coverage'] < 80:
            recommendations.append("- 提高代码覆盖率到80%以上")

        if self.metrics['quality']['code_review_time'] > 24:
            recommendations.append("- 缩短代码审查响应时间")

        if self.metrics['collaboration']['knowledge_shares'] < 2:
            recommendations.append("- 增加团队技术分享频率")

        return "\n".join(recommendations) if recommendations else "- 各项指标良好，继续保持"
```

## 团队最佳实践

### 日常实践

1. **每日站会** (15分钟)
   - 昨天完成什么
   - 今天计划做什么
   - 遇到什么困难

2. **代码审查** (及时响应)
   - PR创建后24小时内响应
   - 建设性反馈
   - 保持礼貌和专业

3. **知识分享** (每周一次)
   - 技术方案讨论
   - 经验总结分享
   - 新技术探索

4. **回顾会议** (每两周)
   - 做得好的地方
   - 需要改进的地方
   - 行动计划制定

### 沟通原则

1. **透明开放**
   - 及时同步进度
   - 主动分享问题
   - 坦诚交流困难

2. **尊重专业**
   - 尊重不同意见
   - 基于数据决策
   - 承认知识局限

3. **持续学习**
   - 保持好奇心
   - 分享学习成果
   - 鼓励创新尝试

4. **追求卓越**
   - 代码质量第一
   - 用户体验优先
   - 技术债务管理