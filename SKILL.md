---
name: codex-budget-router
description: Use this skill whenever the user asks about Codex省额度、省额度配置、自动切换模型、模型档位、light/normal/deep/final profile、config.toml、AGENTS.md、减少额度消耗、避免全项目扫描、限制长输出、保护论文文件、或让 Codex 默认低成本执行并在复杂任务时建议升档。This skill configures Codex budget-saving rules, but it must explain that model/profile selection happens at session startup and cannot be guaranteed by a skill after a task has started.
---

# Codex 省额度与模型档位路由 Skill

## 0. 核心判断

本 Skill 的目标不是在任务执行中强行切换模型，而是帮助用户建立省额度配置：

1. `config.toml` 负责默认模型和 profiles。
2. `AGENTS.md` 负责每次任务的行为约束。
3. Skill 负责在用户提到省额度、模型档位、profile、light/normal/deep/final 时触发，并指导配置和验证。

必须明确告诉用户：

- Skill 不能保证每次对话自动切换模型。
- 模型和 reasoning effort 通常在 Codex 会话启动时决定。
- 真正稳定省额度，需要默认 profile 使用 light。
- 复杂任务需要用户用 `--profile deep` 或 `--profile final` 手动升档，或先让 Codex 给出是否升档的建议。

## 1. 触发场景

当用户出现以下表达时，必须使用本 Skill：

- “省额度”
- “自动切换模型”
- “默认 light”
- “复杂任务 deep”
- “最终审查 final”
- “Codex 配置”
- “config.toml”
- “AGENTS.md”
- “不要全项目扫描”
- “不要默认 GPT-5.5 超高智能”
- “简单任务低智能”
- “普通任务中智能”
- “复杂任务高智能”
- “最终检查超高智能”

## 2. 默认回答策略

用户问“怎么自动切换模型”时，必须按下面逻辑回答：

```text
不能只靠 Skill 100% 自动切换。
最稳方案是：
1. config.toml 默认 light；
2. AGENTS.md 常驻省额度规则；
3. 复杂任务手动用 --profile deep/final 升档；
4. 任务开头用固定省额度触发语。
```

不要承诺“我已保证每次自动切换”。

## 3. 推荐 config.toml

如果用户要求配置，写入或建议写入：

```toml
# Codex 省额度配置
# 默认：轻量模型 + 低推理
# 复杂任务：手动切换 profile

model = "gpt-5.4-mini"
model_reasoning_effort = "low"
model_verbosity = "low"
model_reasoning_summary = "none"
approval_policy = "on-request"
sandbox_mode = "workspace-write"

[profiles.light]
model = "gpt-5.4-mini"
model_reasoning_effort = "low"
model_verbosity = "low"
model_reasoning_summary = "none"
approval_policy = "on-request"
sandbox_mode = "workspace-write"

[profiles.normal]
model = "gpt-5.4"
model_reasoning_effort = "medium"
model_verbosity = "medium"
model_reasoning_summary = "concise"
approval_policy = "on-request"
sandbox_mode = "workspace-write"

[profiles.deep]
model = "gpt-5.5"
model_reasoning_effort = "high"
model_verbosity = "medium"
model_reasoning_summary = "concise"
approval_policy = "on-request"
sandbox_mode = "workspace-write"

[profiles.final]
model = "gpt-5.5"
model_reasoning_effort = "xhigh"
model_verbosity = "medium"
model_reasoning_summary = "concise"
approval_policy = "on-request"
sandbox_mode = "workspace-write"
```

如果当前 Codex 版本不支持某个模型名，必须提示用户改为本机菜单中真实可用的模型名。

## 4. 推荐全局 AGENTS.md

当用户要求“每次都生效”时，优先建议放置：

```text
%USERPROFILE%\.codex\AGENTS.md
```

内容建议：

```markdown
# Global Codex Budget Rules

## 省额度默认规则

1. 默认按 light 模式思路执行。
2. 未经用户明确要求，不要全项目扫描。
3. 优先读取用户指定文件。
4. 简单任务保持短输出。
5. 复杂任务先给计划，再执行。
6. 读取大型 Word、PDF、日志文件前，先说明必要性。
7. 所有正式修改必须先备份，不覆盖原文件。
8. 论文 Word 格式任务默认只改用户指定范围。
9. 用户说“最终审查”时，建议使用 final。
10. 用户说“深度分析”或“复杂失败原因分析”时，建议使用 deep。
```

项目级 AGENTS.md 可以继续覆盖或补充论文规则。

## 5. Windows 执行步骤

如果用户要求一步一步执行，按这个顺序：

### Step 1：备份旧配置

```powershell
$ConfigDir = Join-Path $env:USERPROFILE ".codex"
$ConfigPath = Join-Path $ConfigDir "config.toml"

if (!(Test-Path $ConfigDir)) {
    New-Item -ItemType Directory -Path $ConfigDir | Out-Null
}

if (Test-Path $ConfigPath) {
    Copy-Item $ConfigPath "$ConfigPath.bak" -Force
}
```

### Step 2：写入 config.toml

按第 3 节内容写入。

### Step 3：写入全局 AGENTS.md

路径：

```powershell
$GlobalAgentsPath = Join-Path $env:USERPROFILE ".codex\AGENTS.md"
```

如果存在，先备份为：

```powershell
$GlobalAgentsPath.bak
```

### Step 4：验证

```powershell
Get-Content $ConfigPath
Get-Content $GlobalAgentsPath
python -c "import os, tomllib, pathlib; p=pathlib.Path(os.environ['USERPROFILE'])/'.codex'/'config.toml'; tomllib.loads(p.read_text(encoding='utf-8-sig')); print('TOML OK')"
```

如果没有 Python，只检查文件存在和内容即可。

## 6. 日常使用方式

简单任务：

```powershell
codex --profile light "只检查目录结构，不要全项目扫描"
```

普通任务：

```powershell
codex --profile normal "优化当前 README，只改当前文件"
```

复杂任务：

```powershell
codex --profile deep "分析论文 Word 格式处理失败原因，先给计划，不要直接修改"
```

最终审查：

```powershell
codex --profile final "最终检查论文格式流程，重点检查是否误改正文"
```

如果用户使用的是 Codex 网页或 IDE，而不是 CLI，则提醒：

```text
--profile 命令主要适合 CLI。网页或 IDE 中应依靠默认配置、AGENTS.md 和任务开头的省额度约束语。
```

## 7. 固定省额度触发语

建议用户每次新任务开头添加：

```text
请按 AGENTS.md 的省额度规则执行。本次默认 light，除非我明确要求 deep 或 final，不要全项目扫描，不要读取无关文件，不要长输出，不要修改原文件。
```

## 8. 最终回复模板

配置完成后只输出：

```text
已完成 Codex 省额度配置。

修改文件：
1. %USERPROFILE%\.codex\config.toml
2. %USERPROFILE%\.codex\AGENTS.md

备份文件：
1. 如存在旧 config.toml：%USERPROFILE%\.codex\config.toml.bak
2. 如存在旧 AGENTS.md：%USERPROFILE%\.codex\AGENTS.md.bak

验证结果：
1. config.toml 已存在：是/否
2. TOML 格式有效：是/否/未验证
3. AGENTS.md 已存在：是/否

当前默认模式：
GPT-5.4-Mini + low

后续使用：
简单任务用 light，普通任务用 normal，复杂任务用 deep，最终审查用 final。
```

## 9. 禁止事项

不得：

- 承诺 Skill 能在同一会话中强行切换模型。
- 未经用户允许扫描整个电脑。
- 删除原配置文件。
- 覆盖重要论文文件。
- 把省额度任务扩展成论文修改任务。
- 输出冗长原理解释。
- 默认使用最高档模型做简单任务。
