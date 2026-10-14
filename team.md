# pda-team 团队契约

> 本文件是 **pda-team 的唯一团队定义**：成员、通信、文件命名、工作流程、目录职责与纪律。
> 三个角色技能 `pda-pm` / `pda-am` / `pda-dm` 只做落地说明，**冲突时以本文件为准**。
> 团队所有成员运行在终端多智能体复用器 Herdr 中；会话与 pane 会随重启变化，本文件不登记 pane id。

## 1. 团队定义

### 1.1 成员

| 角色 | 全称 | tab label | 下属（子代理） | 职责 |
|---|---|---|---|---|
| PM | 产品经理（ProductManager），**兼任团队领导** | `PM` | `pde`（productEngineer，产品工程师） | 与用户沟通、接需求、提需求给开发团队、输出验收标准；评审 AM 调研报告与 DM 交付 |
| DM | 开发经理（DevelopManager） | `DM` | `sde`（softwareDevelopEngineer） | 组建开发团队、接需求、拆 ticket、派单实施、修改问题、汇总评审整合 |
| AM | 调研与分析部经理（AnalystManager） | `AM` | `analyst`（分析师） | 市场信息调研、竞品逆向分析，输出调研报告 |

层级：`PM`（团队领导）统管全局并与用户对话；`AM` 与 `DM` 是部门经理，各自管理本部门子代理；`pde` / `analyst` / `sde` 是各部门按需派生的子代理，**不装独立技能**，纪律内嵌在对应经理的技能与派发 prompt 中。

派单来源：`AM` **只接受 PM 派单**（DM 需要调研时经 PM 转派）；`DM` 只接受 PM 的 SPEC 与 PM 的修复要求。

### 1.2 运行环境

- 所有成员运行在 **Herdr**（终端多智能体复用器）中，各自占一个 tab。
- 识别伙伴**一律按 tab label**（`herdr tab list`），**不按 pane id 记忆**：pane id 会随重启/移动变化。
- 团队启动顺序：先用用户会话（或 PM 会话外部）备好 PM 自己的 tab；**PM 负责确认或创建 `DM`、`AM` 两个 tab**，并请用户在各 tab 内启动自己的 harness。

```bash
# 1) 查 label（按 label 文字匹配，不抄历史 id）
HERDR_ENV=1 herdr tab list --workspace "$HERDR_WORKSPACE_ID"
# 2) 由 label 解析出 tab_id，再取该 tab 当前 pane id
HERDR_ENV=1 herdr pane list --workspace "$HERDR_WORKSPACE_ID"
```

若目标 label 不存在：**停下问用户**，不要猜测 pane id、不要对不存在的会话反复重试。
需要新建 tab 时：

```bash
# <ROLE> 取 DM / AM；PM 自己的 tab 由用户创建，不在 PM 会话内自建
HERDR_ENV=1 herdr tab create --label <ROLE> --cwd "$PWD"
```

### 1.3 通信方式

发送前两步（每次都要重跑，禁止复用上一次的 pane id）：

1. `herdr tab list` 按 label 找到 `tab_id`；
2. `herdr pane list` 按该 `tab_id` 取**当前** pane id。

然后按**对端 harness** 选通道：

| 对端 harness | 发送方式 |
|---|---|
| pi-coding-agent / codex / opencode | `HERDR_ENV=1 herdr agent prompt <pane 或已注册 agent 名> '<消息>'` |
| codebuddy（cbc） | `HERDR_ENV=1 herdr pane send-text <pane> '<消息>'` 紧跟 `HERDR_ENV=1 herdr pane send-keys <pane> enter` |

送达判定：`agent prompt` 需返回 `"type":"agent_prompted"`；`send-text + send-keys` 需 exit 0，并用 `herdr pane read <pane> --source recent-unwrapped --lines 40` 复核消息已进入对方输入区或历史。

发送前**必须先读目标面板**（`herdr pane read`）；若对方输入区有用户未提交内容，不得注入，改为等待或请用户转达。
消息必须**自包含**：一句话摘要 + 权威文档路径 + 请求动作 + 期望产物 + 回报要求。

### 1.4 依赖的 harness 技能（mattpocock）

团队依赖 mattpocock 的 skills（`tdd` / `code-review` / `to-spec` / `to-tickets` / `research` / `grilling` 等）。
**检查**：当前 harness 的 skill 目录里能看到这些技能（用户级共享位置通常是 `~/.agents/skills/mattpocock-skills`，仅供参考，不作为硬判据）。

未安装时按顺序处理：

```bash
# 首选：按 harness 安装（pi / opencode / codebuddy / amp / cursor / devin / windsurf；省略 -a 则交互选择）
npx skills@latest add mattpocock/skills -a <agent>
```

提示词安装失败时回退到源码安装：

```bash
git clone https://github.com/mattpocock/skills.git
# 把 skills/ 下的技能目录 copy 到 ~/.agents/skills/，再软链到当前 harness 的 skill 目录
ln -s ~/.agents/skills/<skill> <harness-skills-dir>/<skill>
```

已知缺口（2026-10 核查，供参考）：上游 `mattpocock/skills` **没有 `to-prd`**，`implement-spec` 仍在 `in-progress/` 未发布。PM 写 PRD 按本文件 §4 的模板手写；若后续上游提供 `to-prd`，优先改用它。

## 2. 文件命名规范（权威）

`{seq}` 序号，`{slug}` 简短语义（英文小写短横线，不超过 5 个词），`{YYMMDD-HHMM}` 年月日与时刻，`v{N}` 同一文件原地升级的版本号。

| 产物 | 目录 | 文件名 |
|---|---|---|
| 调研报告 | `docs/research/` | `{seq}-research-{slug}-{YYMMDD-HHMM}--v{N}.md` |
| 规格书 SPEC | `docs/spec/` | `{spec-seq}-spec-{slug}-{YYMMDD-HHMM}--v{N}.md` |
| 开发工单 ticket | `docs/tickets/` | `{spec-seq}-ticket-{slug}-{YYMMDD-HHMM}--v{N}.md` |
| 产品需求文档 PRD | `docs/prd/` | `{seq}-prd-{slug}-{YYMMDD}-v{N}.md` |

规则：

1. **spec 与 ticket 必须对齐 `spec-seq`**：同一需求的 SPEC 与其 ticket 用同一个 `spec-seq` 前缀。
2. **版本语义**：版本内小步更新**就地改同一文件**；实质修订**另立新版本号文件**（新时间戳、`v{N+1}`），并在旧文件头部就地标注「已被 v N+1 取代」。
3. PRD 按需求方给定的格式只有日期（`YYMMDD`），无时刻；其余产物一律带时刻。
4. 历史笔误留痕：需求原文 §4.7 的 `ver{seq}` 写法与 §2.5.2 的 `YYMMDD-v{seq}` 写法**已作废**，一律以本表为准，历史文件不改名。
5. PRD 的 `{seq}` 与 SPEC 的 `{spec-seq}` **各自独立编号**；只有 SPEC 与 ticket 必须共用同一个 `spec-seq`。

## 3. 目录职责

**落盘唯一位置（含负责人与对齐要求）**：

| 唯一目录 | 负责人 | 产物 | 对齐要求 |
|---|---|---|---|
| `docs/prd/` | PM | 产品需求文档（PRD） | `{seq}` 与 SPEC 独立编号 |
| `docs/spec/` | PM | 产品规格书（SPEC，含验收标准） | 与 ticket 共用 `spec-seq` |
| `docs/research/` | AM | 市场调研与竞品逆向报告 | 无 |
| `docs/tickets/` | DM（`sde` 更新证据） | 开发工单（ticket） | 与 SPEC 共用 `spec-seq` |
| `docs/team.md` | PM | 团队契约（本文件） | 无 |

1. 上述路径是**唯一允许位置**，不得写到 `docs/pd/`、`docs/dev/`、`docs/test/` 或其它任何位置，不得自建新的文档目录。
2. 三个部门的产物目录**互不越界**：谁也不能改其它部门产物所在的路径；只读引用可以，移动/改名不可以。
3. 旧体系（`docs/pd/`、`docs/dev/`、`docs/test/`）只保留历史，**不再接收新产物**；历史文件不改名、不搬迁（历史事实留痕）。
4. 机检口径：新产物路径必须匹配 `docs/(prd|spec|research|tickets)/` 前缀（脚本见 §7）。

## 4. 工作流程

1. **AM 调研**：AM 完成需求相关的市场信息调研与竞品逆向分析，输出调研报告，**经 PM 评审后落盘** `docs/research/`。
2. **PM 出 PRD 与 SPEC**：PM 基于《分析师调研报告》与《用户交流信息》，输出 PRD 与 SPEC（SPEC 含验收标准），**经 DM 评审后落盘** `docs/prd/`、`docs/spec/`。
3. **DM 拆 ticket**：DM 基于 SPEC，用 `/to-tickets` 把任务拆成与 SPEC 对应的开发工单，落盘 `docs/tickets/`；DM 负责汇总、评审、整合团队成员的结果。
4. **DM 交付评审**：DM 完成一个 ticket，把代码提交给 PM **部门**评审；一个 ticket 对应一个 SPEC。链路：`pde` 逐条对照 SPEC 核验并回报 → PM 复核给结论 → **PM 通知 DM** → DM 才执行 `git push`。
5. **并行**：对无依赖关系的任务，PM / DM / AM 都必须安排团队成员并行（优先级：dynamic workflow > 多个 subagents 并行），不得为省事而串行。

### 4.1 PRD 模板（PM）

`Problem Statement` / `目标用户与场景` / `方案概述` / `用户故事（可验收）` / `验收标准` / `范围外` / `开放问题`。

### 4.2 SPEC 模板（PM）

`Problem Statement` / `Solution` / `User Stories` / `验收标准（逐条可测）` / `实现决策` / `测试接缝` / `Out of Scope` / `变更记录`。
SPEC 必须自包含：每条 User Story 都能转成 ticket 与用例。

## 5. 纪律

### 5.1 Git

1. **禁止 `git add -A` / `git add .`**，提交一律显式列文件路径。
2. 子代理（`sde`）**只 `git add` + `git commit`，不得 `git push`**；**只有 DM 能 `git push`**，且必须等 PM 评审通过并通知后。
3. 提交前先跑 `/code-review`；提交后 `git diff --cached --name-only` 复核暂存区。
4. `git add` 与 `git commit` 之间不插入其它动作（避免索引被并发写者扫入）。

### 5.2 并行子代理

1. 派发前先做**依赖分析**：只有无依赖任务可并行；共享文件、共享构建目标、有顺序验收关系的任务必须串行。
2. 每份派发 prompt 必须显式写清：输入（产物路径）、边界、期望产物、回报要求、`timeoutMs`（长链路不短于 45 min）。
3. 子代理一律后台/异步派发，**派完立即结束本轮**，由完成通知唤醒再验收；不做轮询。
4. 开发子代理**每人一个 git worktree**，只在 worktree 内编辑与提交；主工作树只读。
5. 所有子代理结果由所属经理**复核证据**后，才能写入权威文档或进入下一步。

### 5.3 评审门禁

| 门禁 | 提交方 | 评审方 | 通过条件 |
|---|---|---|---|
| 调研报告 | AM | PM | PM 认可结论与证据来源，落盘 `docs/research/` |
| PRD 与 SPEC | PM | DM | DM 认可可实施性与切片粒度，落盘 `docs/prd/`、`docs/spec/` |
| ticket 代码 | DM | PM 部门（`pde` 核验 → PM 复核） | 逐条对照 SPEC 验收标准全部通过；PM 通知 DM 后方可 push |
| 跨部门分歧 | 任一方 | PM | PM 裁决并回结论 |

## 6. 表达（全角色）

读者是**稍微懂一点软件工程但没有参与本项目的人**（含用户）：只说白话，先说结论再说证据，突出重点，术语翻成人话。

## 7. 机检

```bash
bash scripts/check-pda-doc-paths.sh
```

检查四件事：四个产物目录存在、`pda-pm` / `pda-am` / `pda-dm` 各自指向自己的唯一目录、本契约登记齐全、负样本能被正确拒绝。**改路径规范后必须重跑**。
