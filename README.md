# codex-budget-router

这是一个用于 Codex 省额度配置的 Skill。

## 作用

- 让 Codex 在用户提到“省额度、模型档位、profile、config.toml、AGENTS.md”时触发。
- 指导用户把默认配置设为 light。
- 指导用户用 `normal`、`deep`、`final` 手动升档。
- 防止 Codex 自动全项目扫描、长输出、误改论文正文。

## 重要说明

Skill 不能保证每次对话自动切换模型。
稳定省额度需要：

1. `~/.codex/config.toml` 默认 light；
2. `~/.codex/AGENTS.md` 写入全局省额度规则；
3. 复杂任务手动用 `--profile deep/final`。

## 安装位置

复制整个文件夹到：

```text
%USERPROFILE%\.codex\skills\codex-budget-router
```

然后重启 Codex。

## 测试指令

```text
请使用 codex-budget-router，检查我的省额度配置是否合理。只检查 config.toml 和 AGENTS.md，不要扫描项目，不要改论文。
```
