import * as claudecode from 'claudecode';

// 插件配置接口
interface TemplateConfig {
    greeting: string;
    enableNotifications: boolean;
    snippetPrefix: string;
}

export function activate(context: claudecode.ExtensionContext) {
    console.log('ClaudeCode插件模板已激活');

    // 获取配置
    const config = claudecode.workspace.getConfiguration('template');
    const templateConfig: TemplateConfig = {
        greeting: config.get('greeting', 'Hello'),
        enableNotifications: config.get('enableNotifications', true),
        snippetPrefix: config.get('snippetPrefix', 'tpl')
    };

    // 注册Hello World命令
    const helloWorldCommand = claudecode.commands.registerCommand(
        'template.helloWorld',
        () => {
            const message = `${templateConfig.greeting}, World! 来自ClaudeCode插件模板`;

            if (templateConfig.enableNotifications) {
                claudecode.window.showInformationMessage(message);
            }

            console.log(message);
        }
    );

    // 注册显示插件信息命令
    const showInfoCommand = claudecode.commands.registerCommand(
        'template.showInfo',
        async () => {
            const pluginInfo = {
                name: 'ClaudeCode Plugin Template',
                version: '1.0.0',
                author: '大熊掌门',
                description: 'ClaudeCode插件开发模板',
                commands: [
                    'template.helloWorld',
                    'template.showInfo',
                    'template.createSnippet'
                ]
            };

            const infoMessage = `
插件名称: ${pluginInfo.name}
版本: ${pluginInfo.version}
作者: ${pluginInfo.author}
描述: ${pluginInfo.description}
可用命令: ${pluginInfo.commands.join(', ')}
            `.trim();

            const action = await claudecode.window.showInformationMessage(
                infoMessage,
                '查看文档',
                '关闭'
            );

            if (action === '查看文档') {
                claudecode.env.openExternal(
                    claudecode.Uri.parse('https://docs.claudecode.com')
                );
            }
        }
    );

    // 注册创建代码片段命令
    const createSnippetCommand = claudecode.commands.registerCommand(
        'template.createSnippet',
        async () => {
            const editor = claudecode.window.activeTextEditor;
            if (!editor) {
                claudecode.window.showErrorMessage('没有活动的编辑器');
                return;
            }

            const selection = editor.selection;
            const selectedText = editor.document.getText(selection);

            if (!selectedText) {
                claudecode.window.showWarningMessage('请先选择要创建片段的代码');
                return;
            }

            // 获取片段名称
            const snippetName = await claudecode.window.showInputBox({
                prompt: '请输入代码片段名称',
                placeHolder: 'mySnippet'
            });

            if (!snippetName) {
                return;
            }

            // 获取片段描述
            const snippetDescription = await claudecode.window.showInputBox({
                prompt: '请输入代码片段描述',
                placeHolder: '这是一个自定义代码片段'
            });

            // 创建代码片段
            const snippet = {
                [snippetName]: {
                    prefix: `${templateConfig.snippetPrefix}-${snippetName}`,
                    body: selectedText.split('\n'),
                    description: snippetDescription || '自定义代码片段'
                }
            };

            // 显示创建的片段
            const snippetJson = JSON.stringify(snippet, null, 2);
            const document = await claudecode.workspace.openTextDocument({
                content: snippetJson,
                language: 'json'
            });

            await claudecode.window.showTextDocument(document);

            claudecode.window.showInformationMessage(
                `代码片段 "${snippetName}" 已创建`
            );
        }
    );

    // 注册状态栏项
    const statusBarItem = claudecode.window.createStatusBarItem(
        claudecode.StatusBarAlignment.Right,
        100
    );
    statusBarItem.text = '$(plug) Template Plugin';
    statusBarItem.tooltip = 'ClaudeCode插件模板';
    statusBarItem.command = 'template.showInfo';
    statusBarItem.show();

    // 注册悬停提示提供者
    const hoverProvider = claudecode.languages.registerHoverProvider(
        { scheme: 'file' },
        {
            provideHover(document, position) {
                const range = document.getWordRangeAtPosition(position);
                if (!range) {
                    return;
                }

                const word = document.getText(range);
                if (word.includes('tpl') || word.includes('template')) {
                    return new claudecode.Hover(
                        `**模板提示**：这是一个与模板相关的关键词\n\n` +
                        `使用 \`${templateConfig.snippetPrefix}\` 前缀来访问模板片段`,
                        range
                    );
                }
            }
        }
    );

    // 注册代码补全提供者
    const completionProvider = claudecode.languages.registerCompletionItemProvider(
        { scheme: 'file' },
        {
            provideCompletionItems(document, position) {
                const linePrefix = document.lineAt(position).text.substring(0, position.character);

                if (linePrefix.endsWith(templateConfig.snippetPrefix)) {
                    return [
                        {
                            label: `${templateConfig.snippetPrefix}-hello`,
                            kind: claudecode.CompletionItemKind.Snippet,
                            insertText: `console.log('${templateConfig.greeting}, World!');`,
                            insertTextFormat: claudecode.InsertTextFormat.Snippet,
                            documentation: '插入Hello World代码'
                        },
                        {
                            label: `${templateConfig.snippetPrefix}-function`,
                            kind: claudecode.CompletionItemKind.Snippet,
                            insertText: [
                                'function ${1:functionName}(${2:parameters}) {',
                                '\t${3:// function body}',
                                '}'
                            ].join('\n'),
                            insertTextFormat: claudecode.InsertTextFormat.Snippet,
                            documentation: '插入函数模板'
                        }
                    ];
                }

                return [];
            }
        },
        templateConfig.snippetPrefix.length // 触发字符长度
    );

    // 监听配置变化
    const configWatcher = claudecode.workspace.onDidChangeConfiguration(event => {
        if (event.affectsConfiguration('template')) {
            console.log('插件配置已更新');

            // 重新读取配置
            const newConfig = claudecode.workspace.getConfiguration('template');
            templateConfig.greeting = newConfig.get('greeting', 'Hello');
            templateConfig.enableNotifications = newConfig.get('enableNotifications', true);
            templateConfig.snippetPrefix = newConfig.get('snippetPrefix', 'tpl');
        }
    });

    // 将所有注册项添加到上下文中，以便在插件停用时清理
    context.subscriptions.push(
        helloWorldCommand,
        showInfoCommand,
        createSnippetCommand,
        statusBarItem,
        hoverProvider,
        completionProvider,
        configWatcher
    );

    console.log('插件模板的所有功能已注册完成');
}

// 插件停用时调用
export function deactivate() {
    console.log('ClaudeCode插件模板已停用');
}

// 导出公共API（如果需要）
export const extensionAPI = {
    getVersion: () => '1.0.0',
    getName: () => 'ClaudeCode Plugin Template',
    getCommands: () => [
        'template.helloWorld',
        'template.showInfo',
        'template.createSnippet'
    ]
};