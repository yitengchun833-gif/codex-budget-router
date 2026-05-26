[README_codex-budget-router_开源使用说明.md](https://github.com/user-attachments/files/28282188/README_codex-budget-router_.md)
# codex-budget-router

> Codex 省额度与模型档位路由 Skill  
> 适用于：Codex CLI / Codex IDE / Codex App / 支持 `SKILL.md` 的 Agent Skills 工具  
> 核心目标：让 Codex 默认低成本执行简单任务，复杂任务再手动升档，减少无意义全项目扫描、长输出和误改文件风险。

---

## 1. 项目简介

`codex-budget-router` 是一个用于 **Codex 省额度配置、模型档位管理和任务复杂度路由** 的 Agent Skill。

它不是用来直接完成某一个业务任务，而是用来帮助用户建立一套稳定的 Codex 使用规则：

- 默认使用轻量模式处理简单任务；
- 普通任务使用中等模型和中等推理；
- 复杂任务再建议切换到高推理模式；
- 最终审查类任务才使用最高推理档位；
- 通过 `AGENTS.md` 约束 Codex 不要乱扫项目、不要输出过长、不要误改重要文件；
- 通过 `config.toml` 配置 `light / normal / deep / final` 四种 profile；
- 通过 Skill 触发规则，在用户提到“省额度、模型档位、profile、config.toml、AGENTS.md”等关键词时自动给出省额度方案。

---

## 2. 这个 Skill 解决什么问题

很多用户在使用 Codex 时会遇到这些问题：

1. 简单任务也默认使用高推理模型，额度消耗过快。
2. Codex 一上来就扫描整个项目，浪费上下文和额度。
3. 只是检查文件，却输出很长的分析过程。
4. 处理文档或论文时，未经确认就改动正文。
5. 不知道什么时候该用轻量模型，什么时候该升档。
6. 不知道 `config.toml`、`AGENTS.md`、`profile` 分别应该怎么配置。
7. 希望建立一套可以长期复用的 Codex 使用习惯。

`codex-budget-router` 的作用就是把这些规则固定下来，让 Codex 在任务开始前就知道：**先省额度，必要时再升档**。

---

## 3. 核心定位

一句话概括：

> `codex-budget-router` 是 Codex 的“省额度调度说明书”，负责建立默认低成本、复杂任务再升档的使用规则。

它主要包含三层：

```text
config.toml        → 配置默认模型和 profile
AGENTS.md          → 约束 Codex 的日常行为
SKILL.md           → 在用户询问省额度、模型档位、profile 时触发说明和指导
```

---

## 4. 重要限制

请注意：这个 Skill **不能保证在任务执行中强行切换模型**。

更准确的说法是：

1. Codex 的模型和 reasoning effort 通常在会话启动或任务启动时确定。
2. Skill 可以提醒用户使用合适的 profile，但不能在任务中途强行切换底层模型。
3. 最稳定的省额度方式是：默认配置为 `light`，复杂任务手动使用 `--profile deep` 或 `--profile final`。
4. 如果使用的是 Codex 网页端或 IDE，而不是 CLI，则主要依靠 `AGENTS.md` 和任务开头的省额度提示词约束行为。

不要宣传成：

```text
自动无感切换所有模型
100% 保证每次任务自动省额度
任务运行中自动从 GPT-5.4-Mini 切到 GPT-5.5
```

正确宣传方式是：

```text
帮助用户建立 Codex 省额度配置和任务分级规则。
默认轻量执行，复杂任务建议升档。
```

---

## 5. 功能特性

### 5.1 四档 profile 设计

| Profile | 推荐模型 | 推理档位 | 适合任务 |
|---|---|---|---|
| `light` | `gpt-5.4-mini` | `low` | 查目录、检查文件、简单复制、轻量说明 |
| `normal` | `gpt-5.4` | `medium` | README 优化、普通代码修改、普通文档整理 |
| `deep` | `gpt-5.5` | `high` | 复杂失败诊断、多文件分析、复杂流程设计 |
| `final` | `gpt-5.5` | `xhigh` | 最终审查、关键提交前检查、重要风险排查 |

> 模型名称需要以你当前 Codex 菜单中实际可用的模型为准。如果版本变化，请修改 `config.example.toml` 中的模型名。

---

### 5.2 默认低成本执行

默认配置使用：

```toml
model = "gpt-5.4-mini"
model_reasoning_effort = "low"
model_verbosity = "low"
model_reasoning_summary = "none"
```

目的：

- 减少简单任务消耗；
- 降低无意义长推理；
- 避免每次都使用最高档模型；
- 让复杂任务由用户明确触发。

---

### 5.3 AGENTS.md 行为约束

`GLOBAL_AGENTS.example.md` 负责规定：

1. 不要默认扫描整个项目。
2. 优先读取用户指定文件。
3. 简单任务保持短输出。
4. 复杂任务先给计划，再执行。
5. 读取大型 Word、PDF、日志前，先说明必要性。
6. 所有正式修改必须先备份。
7. 不覆盖原文件。
8. 论文或重要文档任务默认只改用户指定范围。
9. 用户说“最终审查”时建议使用 `final`。
10. 用户说“深度分析”或“复杂失败诊断”时建议使用 `deep`。

---

### 5.4 自动安装脚本

项目包含：

```text
install.ps1
```

用于把整个 Skill 安装到：

```text
%USERPROFILE%\.codex\skills\codex-budget-router
```

如果旧版本已经存在，脚本会先移动到：

```text
%USERPROFILE%\.codex\skills\.trash\时间戳-codex-budget-router
```

---

### 5.5 一键应用配置脚本

项目包含：

```text
apply_budget_config.ps1
```

用于把示例配置写入：

```text
%USERPROFILE%\.codex\config.toml
%USERPROFILE%\.codex\AGENTS.md
```

如果旧文件已存在，会先备份为：

```text
config.toml.bak
AGENTS.md.bak
```

---

## 6. 文件结构

```text
codex-budget-router/
├── SKILL.md
├── README.md
├── config.example.toml
├── GLOBAL_AGENTS.example.md
├── apply_budget_config.ps1
├── install.ps1
└── PROMPT_TO_CODEX.txt
```

### 6.1 文件说明

| 文件 | 作用 |
|---|---|
| `SKILL.md` | Skill 主说明，定义名称、触发条件、使用规则和省额度逻辑 |
| `README.md` | 项目介绍和基础使用说明 |
| `config.example.toml` | Codex 省额度配置示例 |
| `GLOBAL_AGENTS.example.md` | 全局 AGENTS.md 示例规则 |
| `apply_budget_config.ps1` | 一键写入 `config.toml` 和全局 `AGENTS.md` |
| `install.ps1` | 一键安装 Skill 到 Codex skills 目录 |
| `PROMPT_TO_CODEX.txt` | 可直接发给 Codex 的执行提示词 |

---

## 7. 安装方法

### 7.1 手动安装

把整个文件夹复制到：

```text
%USERPROFILE%\.codex\skills\codex-budget-router
```

Windows 示例：

```powershell
Copy-Item ".\codex-budget-router" "$env:USERPROFILE\.codex\skills\codex-budget-router" -Recurse -Force
```

然后重启 Codex。

---

### 7.2 使用安装脚本

进入项目目录：

```powershell
cd .\codex-budget-router
```

执行：

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

安装完成后重启 Codex。

---

## 8. 应用省额度配置

### 8.1 使用脚本自动配置

进入 Skill 目录：

```powershell
cd "$env:USERPROFILE\.codex\skills\codex-budget-router"
```

执行：

```powershell
powershell -ExecutionPolicy Bypass -File .\apply_budget_config.ps1
```

脚本会自动：

1. 创建 `%USERPROFILE%\.codex` 目录；
2. 备份旧 `config.toml`；
3. 备份旧 `AGENTS.md`；
4. 写入新的 `config.toml`；
5. 写入新的全局 `AGENTS.md`；
6. 尝试校验 TOML 格式。

---

### 8.2 手动配置 config.toml

复制 `config.example.toml` 内容到：

```text
%USERPROFILE%\.codex\config.toml
```

默认配置如下：

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

---

### 8.3 手动配置 AGENTS.md

复制 `GLOBAL_AGENTS.example.md` 内容到：

```text
%USERPROFILE%\.codex\AGENTS.md
```

推荐内容：

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

---

## 9. 使用方法

### 9.1 CLI 使用

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
codex --profile deep "分析 Word 格式处理失败原因，先给计划，不要直接修改"
```

最终审查：

```powershell
codex --profile final "最终检查项目配置和关键文件，重点确认是否误改内容"
```

---

### 9.2 Codex 网页端 / IDE 使用

如果不是 CLI，无法直接依赖 `--profile` 参数。建议在任务开头写：

```text
请按省额度规则执行：简单检查用 light 思路，不要全项目扫描，不要长输出；如果你判断任务需要 deep 或 final，请先提醒我，不要直接执行。
```

或者：

```text
请使用 codex-budget-router 检查这个任务应该用 light、normal、deep 还是 final。先判断档位，不要修改文件。
```

---

### 9.3 显式调用 Skill

可以直接对 Codex 说：

```text
请使用 codex-budget-router，检查我的省额度配置是否合理。只检查 config.toml 和 AGENTS.md，不要扫描项目，不要改任何文件。
```

或者：

```text
请使用 codex-budget-router，判断这个任务应该用 light、normal、deep 还是 final，并说明原因。
```

---

## 10. 触发词

当用户提到以下内容时，应触发本 Skill：

```text
省额度
模型档位
自动切换模型
light
normal
deep
final
profile
config.toml
AGENTS.md
不要全项目扫描
不要长输出
不要默认 GPT-5.5
简单任务低智能
复杂任务高智能
最终审查超高智能
Codex 配置
```

---

## 11. 推荐任务分级

### 11.1 light

适合：

- 查看目录；
- 检查文件是否存在；
- 简单复制；
- 简单 README 修改；
- 简单配置检查；
- 单文件小改动。

示例：

```text
请按 light 思路执行，只检查当前目录是否存在 SKILL.md，不要读取其他文件。
```

---

### 11.2 normal

适合：

- 修改 README；
- 优化 Skill 描述；
- 普通代码修复；
- 普通文档整理；
- 少量文件联动。

示例：

```text
请按 normal 思路执行，优化当前 README 的安装说明，只改 README.md。
```

---

### 11.3 deep

适合：

- 多文件流程分析；
- 复杂错误诊断；
- Word / PDF / 日志失败原因分析；
- 跨 Skill 工作流优化；
- 需要先理解项目结构的任务。

示例：

```text
请按 deep 思路分析这个流程为什么失败，先给计划，不要直接修改。
```

---

### 11.4 final

适合：

- 最终发布前审查；
- 重要提交前检查；
- 论文、合同、配置、自动化脚本的最终风险审查；
- 检查是否误改正文、泄露密钥、遗漏备份。

示例：

```text
请按 final 思路做最终审查，重点检查是否存在敏感信息、误改文件、覆盖原始文件。
```

---

## 12. 验证方法

### 12.1 检查 Skill 是否安装

```powershell
Test-Path "$env:USERPROFILE\.codex\skills\codex-budget-router\SKILL.md"
```

返回：

```text
True
```

说明 Skill 主文件存在。

---

### 12.2 检查 config.toml

```powershell
Test-Path "$env:USERPROFILE\.codex\config.toml"
Get-Content "$env:USERPROFILE\.codex\config.toml"
```

如安装 Python，可校验 TOML：

```powershell
python -c "import os, tomllib, pathlib; p=pathlib.Path(os.environ['USERPROFILE'])/'.codex'/'config.toml'; tomllib.loads(p.read_text(encoding='utf-8-sig')); print('TOML OK')"
```

---

### 12.3 检查 AGENTS.md

```powershell
Test-Path "$env:USERPROFILE\.codex\AGENTS.md"
Get-Content "$env:USERPROFILE\.codex\AGENTS.md"
```

---

## 13. 给 Codex 的一键提示词

可以直接复制 `PROMPT_TO_CODEX.txt` 中的内容：

```text
请使用已安装的 codex-budget-router Skill，帮我检查并应用 Codex 省额度配置。

要求：
1. 只处理 %USERPROFILE%\.codex\config.toml 和 %USERPROFILE%\.codex\AGENTS.md。
2. 如果文件已存在，先备份。
3. 默认模式设为 light。
4. 不扫描项目，不读取论文，不修改论文正文。
5. 完成后只输出修改文件、备份位置和验证结果。
```

---

## 14. 开源前检查清单

发布到 GitHub 前，建议检查：

- [ ] 不包含个人 API Key。
- [ ] 不包含 `.env`。
- [ ] 不包含 GitHub Token。
- [ ] 不包含真实论文文件。
- [ ] 不包含学校账号或个人身份信息。
- [ ] `config.example.toml` 只包含示例模型名。
- [ ] `GLOBAL_AGENTS.example.md` 不包含个人隐私内容。
- [ ] `README.md` 说明了 Skill 不能强行在任务中切换模型。
- [ ] `install.ps1` 不会删除用户文件，只会备份旧版本。
- [ ] `apply_budget_config.ps1` 会备份旧配置。
- [ ] `PROMPT_TO_CODEX.txt` 不要求读取整个项目。
- [ ] 已添加 License。
- [ ] 已添加 `.gitignore`。

---

## 15. 推荐 .gitignore

```gitignore
# Secrets
.env
*.env
.env.*
*token*
*secret*
*password*

# Codex local files
.codex/
.trash/
*.bak

# System
.DS_Store
Thumbs.db

# Python
__pycache__/
*.pyc
.pytest_cache/
.mypy_cache/
.ruff_cache/

# Node
node_modules/

# Temporary
*.tmp
*.log
```

---

## 16. 推荐仓库描述

短描述：

```text
A Codex Agent Skill for budget-saving profiles, model-effort routing, and AGENTS.md rules.
```

中文描述：

```text
Codex 省额度与模型档位路由 Skill：默认 light，复杂任务 deep/final，减少全项目扫描、长输出和误改文件风险。
```

---

## 17. 推荐 README 开头文案

```markdown
# codex-budget-router

`codex-budget-router` 是一个用于 Codex 的省额度配置与任务档位路由 Skill。它通过 `config.toml`、`AGENTS.md` 和 `SKILL.md` 组合，让 Codex 默认以低成本方式处理简单任务，并在复杂分析、最终审查等场景下提醒用户切换到更高档位。

它适合经常使用 Codex 处理文档、代码、论文、配置文件和多文件项目的用户。
```

---

## 18. 常见问题

### Q1：这个 Skill 能不能自动切换模型？

不能保证。  
它可以指导配置 profile，并在任务中提醒用户应该用哪个档位。真正稳定的模型选择通常需要在任务启动时通过 `--profile` 或 Codex 设置完成。

---

### Q2：为什么要用 AGENTS.md？

因为 `AGENTS.md` 是持续生效的项目或全局行为规则。  
它可以让 Codex 每次执行任务时都遵守“不要乱扫项目、不要长输出、不要覆盖文件”等原则。

---

### Q3：为什么默认使用 light？

因为大多数日常任务不需要最高推理模型。  
例如查文件、看目录、复制文件、简单 README 修改，用 light 更合适。

---

### Q4：什么时候用 final？

只有最终审查、重要提交前检查、风险排查时才建议使用 final。  
不要把 final 当默认模式。

---

### Q5：是否适合所有 Codex 版本？

不一定。  
不同 Codex 版本可用模型名可能不同。如果模型名不匹配，请把 `config.toml` 中的模型名改成你本机菜单里真实可用的模型。

---

## 19. 适合人群

适合：

- 经常用 Codex 处理项目的人；
- Plus / Pro 额度敏感用户；
- 想避免 Codex 过度扫描项目的人；
- 想建立固定任务档位的人；
- 需要处理论文、文档、代码、配置文件的人；
- 想把简单任务和复杂任务分开管理的人。

不适合：

- 希望完全自动无感切换所有模型的人；
- 不想配置 `config.toml` 或 `AGENTS.md` 的人；
- 只偶尔使用 Codex 且不关心额度的人。

---

## 20. 免责声明

本项目只是 Codex 使用规则与配置辅助工具，不保证降低实际账单或额度消耗到某个固定数值。  
模型可用性、profile 配置项、reasoning effort 名称可能随 Codex 版本变化。  
使用前请根据你自己的 Codex 版本、可用模型和任务需求调整配置。

---

## 21. License

建议使用：

```text
MIT License
```

发布前请在仓库根目录添加 `LICENSE` 文件。

---

## 22. 更新日志建议

```markdown
# CHANGELOG

## 0.1.0
- 初始版本。
- 新增 `SKILL.md`。
- 新增 `config.example.toml`。
- 新增 `GLOBAL_AGENTS.example.md`。
- 新增 `install.ps1`。
- 新增 `apply_budget_config.ps1`。
- 新增 `PROMPT_TO_CODEX.txt`。
```

---

## 23. 最终一句话

> 默认 light，普通 normal，复杂 deep，终审 final。  
> 先省额度，再做复杂分析。
