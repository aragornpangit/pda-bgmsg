# pda-team 团队契约

> 本文件是 **pda-team 的唯一团队定义**：成员、通信、文件命名、工作流程、目录职责与纪律；三个角色技能 `pm` / `am` / `dm` 只做落地说明，**冲突时以本文件为准**。
> 团队成员运行在终端多智能体复用器 Herdr 中；会话与 pane 随重启变化，本文件不登记 pane id。

## 0. 仓库结构

本仓根目录**只有三个文件夹**，与三个角色一一对应；团队契约、仓库说明与机检脚本随团队领导（PM）放在 `pm/` 内，不散落根目录：

```
pda-bgmsg/
├── pm/                                   # 产品经理兼团队领导
│   ├── SKILL.md                          # 角色技能
│   ├── team.md                           # 团队契约（本文件，唯一权威）
│   ├── README.md                         # 仓库说明与安装
│   └── scripts/check-pda-doc-paths.sh    # 产物落盘路径机检
├── dm/SKILL.md                           # 开发经理
└── am/SKILL.md                           # 调研与分析部经理
```

## 1. 团队定义

### 1.1 成员

| 角色 | 全称 | tab label | 下属（子代理） | 职责 |
|---|---|---|---|---|
| PM | 产品经理（ProductManager），**兼任团队领导** | `PM` | `pde`（productEngineer，产品工程师） | 与用户沟通、接需求、提需求给开发团队、输出验收标准；评审 AM 调研报告与 DM 交付 |
| DM | 开发经理（DevelopManager） | `DM` | `sde`（softwareDevelopEngineer） | 组建开发团队、接需求、拆 ticket、派单实施、修改问题、汇总评审整合 |
| AM | 调研与分析部经理（AnalystManager） | `AM` | `analyst`（分析师） | 市场信息调研、竞品逆向分析，输出调研报告 |

层级：`PM`（团队领导）统管全局并与用户对话；`AM` / `DM` 是部门经理，各自管理本部门子代理；`pde` / `analyst` / `sde` 是按需派生的子代理，**不装独立技能**，纪律内嵌在对应经理的技能与派发 prompt 中。
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

### 1.3 通信方式（收件箱文件 + herdr 门铃）

**正文一律走文件，herdr 只发门铃一句。** 派单、回报、评审结论、裁决请求、缺陷退回，全部先落成收件方收件箱里的一份文件，再用 herdr 敲一句「你有新消息 <文件名>」。**消息里不贴长正文、不贴日志、不贴 diff。**

**第一步 定位伙伴**（每次重跑，禁止复用上一次的 pane id）：`herdr tab list` 按 label 找到 `tab_id` → `herdr pane list` 按该 `tab_id` 取**当前** pane id。label 不在列表里 ⇒ **停下问用户**，不猜 pane id。

**第二步 写收件箱文件**

- 路径：收件方的 `docs/<收件角色>/inbox/{seq}-{方向}-{slug}-{YYMMDDHHMM}.md`（`<收件角色>` ∈ `pm` / `dm` / `am`；目录不存在先 `mkdir -p`）
- `{seq}`：自累计流水号，001 起，一条消息一个号（与 SPEC 的 `spec-seq` 无关）
- `{方向}`：发送方2收件方，取值 `pm2dm` / `dm2pm` / `pm2am` / `am2pm` / `dm2am` / `am2dm`
- `{slug}`：英文小写短横线，不超过 5 个词
- `{YYMMDDHHMM}`：落盘时刻，两位年 + 月 + 日 + 时 + 分，无分隔符（例 `2610201430`）
- 正文**自包含**：一句话摘要 / 权威文档路径 / 请求动作 / 期望产物 / 回报要求

**第三步 发门铃**（按**对端 harness** 选通道，消息只发一句：文件名 + 目录）

| 对端 harness | 门铃 |
|---|---|
| pi-coding-agent / codex / opencode | `HERDR_ENV=1 herdr agent prompt <pane 或已注册 agent 名> '你有新消息 {文件名}，在 docs/<收件角色>/inbox/'` |
| codebuddy（cbc） | `HERDR_ENV=1 herdr pane send-text <pane> '你有新消息 {文件名}，在 docs/<收件角色>/inbox/'` 紧跟 `HERDR_ENV=1 herdr pane send-keys <pane> enter` |

发送前**必须先读目标面板**（`herdr pane read`）；若对方输入区有用户未提交内容，不得注入，改为等待或请用户转达。

**第四步 收件方处理**

1. 读 `docs/<自己>/inbox/` 下的新文件，读完**立刻回执**给发送方：`{文件名} 已经收到` ＋ 一句话结论或下一步（回执走 herdr 消息，不另写文件）；
2. **读毕即删**该文件（收件箱里只允许存在未读消息）；
3. 需要回正文时，按同样规则反向写文件 + 门铃，不把长正文塞进回执。

**送达判定**：以**对方回执**为准。`agent prompt` 返回 `"type":"agent_prompted"`、`send-text + send-keys` 返回 exit 0 只算「已投递」，不算「已收到」；无回执时**问**，不重复投递。

**不入库**：收件箱是运行时通道，不是交付物；被服务项目的 `.gitignore` 必须含 `docs/*/inbox/`。

### 1.4 依赖的 harness 技能（mattpocock）

团队依赖 mattpocock 的 skills（`tdd` / `code-review` / `to-spec` / `to-tickets` / `research` / `grilling` 等）。
**检查**：当前 harness 的 skill 目录里能看到这些技能（用户级共享位置通常是 `~/.agents/skills/mattpocock-skills`，仅供参考，不作为硬判据）。

未安装时按顺序处理：

```bash
# 首选：按 harness 安装（pi / opencode / codebuddy / amp / cursor / devin / windsurf；省略 -a 则交互选择）
npx skills@latest add mattpocock/skills -a <agent>
# 回退（提示词安装失败时）：克隆源码，把 skills/ 下的技能目录 copy 到 ~/.agents/skills/，再软链到 harness 技能目录
git clone https://github.com/mattpocock/skills.git
```

已知缺口（2026-10 核查）：上游 `mattpocock/skills` **没有 `to-prd`**，`implement-spec` 仍在 `in-progress/` 未发布。PM 写 PRD 按本文件 §4 模板手写；若后续上游提供 `to-prd`，优先改用它。

## 2. 文件命名规范（权威）

`{seq}` 序号，`{slug}` 简短语义（英文小写短横线，不超过 5 个词），`{YYMMDD-HHMM}` 年月日与时刻，`v{N}` 同一文件原地升级的版本号。

| 产物 | 目录 | 文件名 |
|---|---|---|
| 调研报告 | `docs/research/` | `{seq}-research-{slug}-{YYMMDD-HHMM}--v{N}.md` |
| 规格书 SPEC | `docs/spec/` | `{spec-seq}-spec-{slug}-{YYMMDD-HHMM}--v{N}.md` |
| 开发工单 ticket | `docs/tickets/` | `{spec-seq}-ticket-{slug}-{YYMMDD-HHMM}--v{N}.md` |
| 产品需求文档 PRD | `docs/prd/` | `{seq}-prd-{slug}-{YYMMDD}-v{N}.md` |
| 收件箱消息 | `docs/<收件角色>/inbox/` | `{seq}-{方向}-{slug}-{YYMMDDHHMM}.md`（无版本号，读毕即删） |

规则：

1. **spec 与 ticket 必须对齐 `spec-seq`**：同一需求的 SPEC 与其 ticket 用同一个 `spec-seq` 前缀。
2. **版本语义**：版本内小步更新**就地改同一文件**；实质修订**另立新版本号文件**（新时间戳、`v{N+1}`），并在旧文件头部就地标注「已被 v N+1 取代」。
3. PRD 按需求方给定的格式只有日期（`YYMMDD`），无时刻；其余产物一律带时刻。
4. **独立编号**：PRD 的 `{seq}` 与 SPEC 的 `{spec-seq}` 各自独立；只有 SPEC 与 ticket 必须共用同一个 `spec-seq`。
5. 历史笔误留痕：需求原文的 `ver{seq}`、`YYMMDD-v{seq}` 写法**已作废**，一律以本表为准，历史文件不改名。

## 3. 目录职责

**落盘唯一位置（含负责人与对齐要求）**：

| 唯一目录 | 负责人 | 产物 | 对齐要求 |
|---|---|---|---|
| `docs/prd/` | PM | 产品需求文档（PRD） | `{seq}` 与 SPEC 独立编号 |
| `docs/spec/` | PM | 产品规格书（SPEC，含验收标准） | 与 ticket 共用 `spec-seq` |
| `docs/research/` | AM | 市场调研与竞品逆向报告 | 无 |
| `docs/tickets/` | DM（`sde` 更新证据） | 开发工单（ticket） | 与 SPEC 共用 `spec-seq` |
| `docs/team.md` | PM | 团队契约（本文件） | 无 |
| `docs/handoff/` | PM / DM | 交接说明（`{pm,dm}-{slug}-{YYMMDD-HHMM}-v{N}.md`，**仅在用户要求时写**） | 无 |
| `docs/<收件角色>/inbox/` | 发送方写、收件方读后删 | 角色间消息（运行时通道，**不入库**） | 方向与 `{seq}` 见 §1.3 |

1. 上述路径是**唯一允许位置**，不得写到 `docs/pd/`、`docs/dev/`、`docs/test/` 或其它任何位置，不得自建新的文档目录。
2. 三个部门的产物目录**互不越界**：只读引用可以，移动/改名不可以。
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

1. **禁止 `git add -A` / `git add .`**，提交一律显式列文件路径（优先 `git commit -m "..." -- <path>`，绕过索引），且 `add` 与 `commit` 之间不插入其它动作（避免索引被并发写者扫入）。
2. 子代理（`sde`）**只 `git add` + `git commit`，不得 `git push`**；**只有 DM 能 `git push`**，且必须等 PM 评审通过并通知后。
3. 提交前先跑 `/code-review`；提交后 `git diff --cached --name-only` 复核暂存区。

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
bash pm/scripts/check-pda-doc-paths.sh
```

检查四件事：四个产物目录存在、`pm` / `dm` / `am` 各自指向自己的唯一目录、本契约登记齐全、负样本能被正确拒绝。**改路径规范后必须重跑**。
