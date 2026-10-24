# pda-fleet 团队契约

> 本文件是 **pda-fleet 的唯一团队定义**：组织、成员、通信、文件命名、工作流程、目录职责与纪律；三个角色技能 `pda-pm` / `pda-dm` / `pda-am` 只做落地说明，**冲突时以本文件为准**。
> 团队成员运行在终端多智能体复用器 Herdr 中；会话与 pane 随重启变化，本文件不登记 pane id。

## 0. 仓库结构

本仓根目录按角色分文件夹，一个角色一个目录；团队契约、仓库说明与机检脚本随产品总放在 `pm/` 内，不散落根目录：

```
pda-fleet/
├── pm/                                   # 产品总（技能 pda-pm）
│   ├── SKILL.md                          # 角色技能
│   ├── team.md                           # 团队契约（本文件，唯一权威）
│   ├── README.md                         # 仓库说明与安装
│   └── scripts/check-pda-doc-paths.sh    # 产物落盘路径机检
├── dm/SKILL.md                           # 开发经理（pda-dm）
└── am/SKILL.md                           # 分析经理（pda-am）
```

## 1. 团队定义

### 1.1 组织与成员

```
pda-pm                 产品总（label PM）
├── pda-dm               开发经理（label DM）
│   └── pda-de           开发工程师（子代理，不占 tab，可并行 n 个）
└── pda-am               分析经理（label AM）
    └── pda-ae           分析工程师（子代理，不占 tab，可并行 n 个）
```

| 角色 | 全称 | 技能 / 实例名 | tab label | 直属上级 | 直属下级 | 职责 |
|---|---|---|---|---|---|---|
| 产品总 | ProductChief | `pda-pm` | `PM` | 用户 | `pda-dm`、`pda-am` | 唯一用户入口；接需求、出验收标准、落笔 PRD 与 SPEC、评审调研报告与 ticket 代码、跨部门裁决 |
| 开发经理 | DevelopManager | `pda-dm` | `DM` | `pda-pm` | `pda-de`（子代理） | 由 SPEC 拆 ticket、直接派开发工程师实施、验收整合、PM 评审通过后 push |
| 分析经理 | AnalystManager | `pda-am` | `AM` | `pda-pm` | `pda-ae`（子代理） | 接调研诉求、拆子问题、直接派分析工程师并行取证、收口调研报告 |

**单线指挥（硬约束，任何角色不得越级或横向直连）：**

1. `pda-pm` **只**直接指挥 `pda-dm` 与 `pda-am`；**不得**越级给工程师派活或收活。
2. `pda-dm` **只**直接指挥 `pda-de`（子代理，用 dynamic workflow 或 subagents 派发）；**不得**绕过 PM 横向联系 AM。
3. `pda-am` **只**直接指挥 `pda-ae`（子代理，用 dynamic workflow 或 subagents 派发）；**不得**绕过 PM 横向联系 DM。
4. DM 与 AM 之间**不直连**，跨部门事项经 `pda-pm` 转派。
5. 工程师 `pda-de` / `pda-ae` **只**向派生他的经理汇报，**不装独立技能**、**不走跨 tab 通信**（纪律内嵌在经理的派发 prompt 中）。

### 1.2 运行环境与 tab 生命周期

- 三个角色运行在 **Herdr**（终端多智能体复用器）中，各占一个 tab；工程师是经理会话内的子代理，**不占 tab**。
- 识别伙伴**一律按 tab label**（`herdr tab list`），**不按 pane id 记忆**：pane id 会随重启/移动变化。
- 团队启动顺序：先用用户会话（或 PM 会话外部）备好 `PM` tab；**PM 负责创建 `DM`、`AM` 两个 tab**，并请用户在各 tab 内启动自己的 harness。
- **团队只有三个 tab**：`PM` / `DM` / `AM`。工程师是经理会话内的子代理，**不建 tab、不占 pane**。

```bash
# 1) 查 label（按 label 文字匹配，不抄历史 id）
HERDR_ENV=1 herdr tab list --workspace "$HERDR_WORKSPACE_ID"
# 2) 由 label 解析出 tab_id，再取该 tab 当前 pane id
HERDR_ENV=1 herdr pane list --workspace "$HERDR_WORKSPACE_ID"
```

若目标 label 不存在：**停下问用户**，不要猜测 pane id、不要对不存在的会话反复重试。

创建 tab（PM 建两个经理的 tab；经理不建 tab）：

```bash
# <ROLE> 取 DM / AM；PM 自己的 tab 由用户创建，不在 PM 会话内自建
HERDR_ENV=1 herdr tab create --workspace "$HERDR_WORKSPACE_ID" --cwd "$PWD" --label <ROLE>
```

建完 tab 后，创建者必须让新 tab 进入角色：harness 未自动启动时**请用户启动**；启动后由创建者把首条任务（角色名、技能名、直属上级 label、任务文件路径）投递到该 tab，并核验已送达。

### 1.3 通信方式（收件箱文件 + herdr 门铃）

**正文一律走文件，herdr 只发门铃一句。** 派单、回报、评审结论、裁决请求、缺陷退回，全部先落成收件方收件箱里的一份文件，再用 herdr 敲一句「你有新消息 <文件名>」。**消息里不贴长正文、不贴日志、不贴 diff。**

**允许的直接通信只有上下级这一条线**（其余一律经上级转派）：

| 发送方 | 收件方 | 方向码 |
|---|---|---|
| `pda-pm` | `pda-dm` / `pda-am` | `pm2dm` / `pm2am` |
| `pda-dm` / `pda-am` | `pda-pm` | `dm2pm` / `am2pm` |

工程师是子代理，**不走收件箱、不发门铃**：经理派发即 prompt 直传，回报即子代理结果。

**第一步 定位伙伴**（每次重跑，禁止复用上一次的 pane id）：`herdr tab list` 按 label 找到 `tab_id` → `herdr pane list` 按该 `tab_id` 取**当前** pane id。label 不在列表里 ⇒ **停下问用户**，不猜 pane id。

**第二步 写收件箱文件**

- 路径：**项目根目录**下的 `inbox/<收件角色>/{seq}-{方向}-{slug}-{YYMMDDHHMM}.md`（`<收件角色>` ∈ `pm` / `dm` / `am`；**不在 `docs/` 下**；目录不存在先 `mkdir -p`）
- `{seq}`：自累计流水号，001 起，一条消息一个号（与 SPEC 的 `spec-seq` 无关）
- `{方向}`：见上表；跨部门事项由 PM 转派，不出现 `dm2am` 之类
- `{slug}`：英文小写短横线，不超过 5 个词
- `{YYMMDDHHMM}`：落盘时刻，两位年 + 月 + 日 + 时 + 分，无分隔符（例 `2610201430`）
- 正文**自包含**：一句话摘要 / 权威文档路径 / 请求动作 / 期望产物 / 回报要求

**第三步 发门铃**（按**对端 harness** 选通道，消息只发一句：文件名 + 目录）

| 对端 harness | 门铃 |
|---|---|
| pi-coding-agent / codex / opencode | `HERDR_ENV=1 herdr agent prompt <pane 或已注册 agent 名> '你有新消息 {文件名}，在 inbox/<收件角色>/'` |
| codebuddy（cbc） | `HERDR_ENV=1 herdr pane send-text <pane> '你有新消息 {文件名}，在 inbox/<收件角色>/'` 紧跟 `HERDR_ENV=1 herdr pane send-keys <pane> enter` |

发送前**必须先读目标面板**（`herdr pane read`）；若对方输入区有用户未提交内容，不得注入，改为等待或请用户转达。

**第四步 收件方处理**

1. 读 `inbox/<自己>/` 下的新文件，读完**立刻回执**给发送方：`{文件名} 已经收到` ＋ 一句话结论或下一步（回执走 herdr 消息，不另写文件）；
2. **读毕即删**该文件（收件箱里只允许存在未读消息）；
3. 需要回正文时，按同样规则反向写文件 + 门铃，不把长正文塞进回执。

**送达判定**：以**对方回执**为准。`agent prompt` 返回 `"type":"agent_prompted"`、`send-text + send-keys` 返回 exit 0 只算「已投递」，不算「已收到」；无回执时**问**，不重复投递。

**不入库**：收件箱是运行时通道，不是交付物；被服务项目的 `.gitignore` 必须含 `inbox/*/`。

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

序号按产物类别各自独立、类别内自累计（001 起）：`{prd-seq}`（PRD）、`{research-seq}`（调研报告）、`{user-arch-seq}`（用户架构）、`{user-plan-seq}`（用户计划）、`{spec-seq}`（SPEC 与 ticket 共用）；收件箱消息另用 `{seq}` 消息流水号。`{slug}` 简短语义（英文小写短横线，不超过 5 个词），`{YYMMDD-HHMM}` 年月日与时刻，`v{N}` 同一文件原地升级的版本号。

| 产物 | 目录 | 文件名 |
|---|---|---|
| 调研报告 | `docs/research/` | `{research-seq}-research-{slug}-{YYMMDD-HHMM}--v{N}.md` |
| 产品需求文档 PRD | `docs/pd/prd/` | `{prd-seq}-prd-{slug}-{YYMMDD}-v{N}.md` |
| 规格书 SPEC | `docs/pd/spec/` | `{spec-seq}-spec-{slug}-{YYMMDD-HHMM}--v{N}.md` |
| 开发工单 ticket | `docs/dev/tickets/` | `{spec-seq}-ticket-{slug}-{YYMMDD-HHMM}--v{N}.md` |
| 用户架构 | `docs/user/user-arch/` | `{user-arch-seq}-arch-{slug}-{YYMMDD-HHMM}--v{N}.md` |
| 用户计划 | `docs/user/user-plan/` | `{user-plan-seq}-plan-{slug}-{YYMMDD-HHMM}--v{N}.md` |
| 收件箱消息 | `inbox/<收件角色>/` | `{seq}-{方向}-{slug}-{YYMMDDHHMM}.md`（无版本号，读毕即删） |

规则：

1. **spec 与 ticket 必须对齐 `spec-seq`**：同一需求的 SPEC 与其 ticket 用同一个 `spec-seq` 前缀。
2. **版本语义**：版本内小步更新**就地改同一文件**；实质修订**另立新版本号文件**（新时间戳、`v{N+1}`），并在旧文件头部就地标注「已被 v N+1 取代」。
3. PRD 按需求方给定的格式只有日期（`YYMMDD`），无时刻；其余产物一律带时刻。
4. **独立编号**：`{prd-seq}` / `{research-seq}` / `{user-arch-seq}` / `{user-plan-seq}` / `{spec-seq}` 各自独立、类别内自累计；只有 SPEC 与 ticket 必须共用同一个 `spec-seq`。
5. 历史笔误留痕：需求原文的 `ver{seq}`、`YYMMDD-v{seq}` 写法**已作废**，一律以本表为准，历史文件不改名。

## 3. 目录职责

**落盘唯一位置（含负责人与对齐要求）**：

| 唯一目录 | 负责人 | 产物 | 对齐要求 |
|---|---|---|---|
| `docs/pd/prd/` | PM | 产品需求文档（PRD） | `{prd-seq}` 独立编号 |
| `docs/pd/spec/` | PM | 产品规格书（SPEC，含验收标准） | 与 ticket 共用 `spec-seq` |
| `docs/dev/tickets/` | DM（`pda-de` 证据由 DM 归档） | 开发工单（ticket） | 与 SPEC 共用 `spec-seq` |
| `docs/research/` | AM | 市场调研与竞品逆向报告 | 无 |
| `docs/user/user-arch/` | PM | 用户架构文档 | 无 |
| `docs/user/user-plan/` | PM | 用户计划文档 | 无 |
| `docs/team.md` | PM | 团队契约（本文件） | 无 |
| `docs/handoff/` | PM / DM | 交接说明（`{pm,dm}-{slug}-{YYMMDD-HHMM}-v{N}.md`，**仅在用户要求时写**） | 无 |
| `inbox/<收件角色>/` | 发送方写、收件方读后删 | 角色间消息（运行时通道，**不入库**，**在项目根目录、不在 `docs/` 下**） | 方向与 `{seq}` 见 §1.3 |

1. 上述路径是**唯一允许位置**，不得写到 `docs/pd/`（除 `prd/`、`spec/`）、`docs/dev/`（除 `tickets/`）、`docs/user/`（除 `user-arch/`、`user-plan/`）、`docs/test/` 或其它任何位置；收件箱只在项目根 `inbox/` 下，不进 `docs/`；不得自建新的文档目录。
2. 各部门的产物目录**互不越界**：只读引用可以，移动/改名不可以。
3. **工程师不写 `docs/`**：`pda-de` / `pda-ae` 的证据只回给派发他的经理（由经理并入票面/报告），`docs/` 内的产物一律由经理落笔。
4. 旧体系（`docs/pd/` 除 `prd/`、`spec/` 外，`docs/dev/` 除 `tickets/` 外，`docs/test/`）只保留历史，**不再接收新产物**；历史文件不改名、不搬迁（历史事实留痕）。**现行口径（2026-10-21 用户裁定·第二次修订）**：① PRD 落 `docs/pd/prd/`；② SPEC 由 `docs/spec/` 改为 `docs/pd/spec/`；③ ticket 由 `docs/tickets/` 改为 `docs/dev/tickets/`；④ 新增 `docs/user/user-arch/`（用户架构）与 `docs/user/user-plan/`（用户计划），均由 PM 落盘；⑤ `docs/dev/arch/` **作废**，不再单独设架构目录；⑥ 收件箱由 `docs/<角色>/inbox/` 移到项目根 `inbox/<角色>/`。
5. **目录初始化由 PM 负责**：PM 接手一个项目时先检查再补齐（见 §3.1），产物目录不由 AM / DM 自建。
6. 机检口径：§7 的脚本只校验「六个产物目录与根 `inbox/` 存在、三个技能各自指向自己的目录、契约登记齐全、负样本被拒绝」；它**不校验单个文件的落盘路径**，新产物靠本表与评审把关。

### 3.1 初始化（PM 负责，幂等）

PM 接手项目的**第一件事**：检查目录，缺什么建什么。可重复执行，已存在则不动：

```bash
cd <项目根>
mkdir -p docs/{pd/{prd,spec},dev/tickets,research,user/{user-arch,user-plan}} inbox/{pm,dm,am}
grep -qxF 'inbox/*/' .gitignore 2>/dev/null || echo 'inbox/*/' >> .gitignore   # 收件箱不入库
bash scripts/check-pda-doc-paths.sh .        # 本仓内为 pm/scripts/…
```

- **完成判据**：机检输出 `ALL_PASS`。缺目录时脚本报 `FAIL 目录缺失`，PM 补齐后重跑。
- **只建目录、不建产物**：空目录不预置占位文件，避免被误认为已有交付物。
- **AM / DM 不自建产物目录**：发现自己的目标目录缺失，回报 PM（收件箱目录属运行时通道，可按需 `mkdir -p` 兜底）。
- 契约文件 `docs/team.md` 与技能安装不在本步骤内（安装见 `README.md`）。

## 4. 工作流程

1. **AM 调研**：AM 把诉求拆成互不依赖的子问题，**直接派 `pda-ae` 并行取证**（dynamic workflow 或 subagents）；AM 复核一手出处并收口成调研报告，**经 PM 评审后落盘** `docs/research/`。
2. **PM 出 PRD 与 SPEC**：PM 基于调研报告与用户交流，输出 PRD 与 SPEC（含验收标准），**经 DM 评审后落盘** `docs/pd/prd/`、`docs/pd/spec/`。
3. **DM 拆 ticket**：DM 基于 SPEC，用 `/to-tickets` 拆成与 SPEC 对应的开发工单，落盘 `docs/dev/tickets/`；DM 负责汇总、评审、整合本部门结果。
4. **DM 派工程师**：DM 按依赖图分批，**直接派 `pda-de`**（一个 ticket 一个子代理、一个 git worktree）；派单 prompt 必带票面路径、票基（显式 sha）、Files 边界、验收判据、期望产物、回报格式、`timeoutMs`。
5. **DM 验收整合**：收子代理结果 → 核 diff 与逐条判据读数 → 主干构建与全量测试 → 合并（冲突逐 hunk 按意图消解）→ 不合格打回原 `pda-de` → 收回 `git worktree remove` → 逐票更新状态。
6. **交付 PM 评审**：DM 把代码提交给 PM 评审；**每张 ticket 都必须能追溯到 SPEC 的验收标准**。链路：PM 亲自对照 SPEC 验收标准核验 → PM 给结论 → **PM 通知 DM** → DM 才执行 `git push`。
7. **并行**：对无依赖关系的任务**必须开满并行** —— PM 在 DM / AM 之间并行；DM 在多个 `pda-de` 之间并行（无依赖票一次派满）；AM 在多个 `pda-ae` 之间并行（无依赖单元一次派满）。优先级：dynamic workflow > 多个 subagents 并行；**不得为省事而串行，也不得越级派发**；串行必须在交付正文里写明依赖理由。

### 4.1 PRD 模板（PM）

`Problem Statement` / `目标用户与场景` / `方案概述` / `用户故事（可验收）` / `验收标准` / `范围外` / `开放问题`。

### 4.2 SPEC 模板（PM）

`Problem Statement` / `Solution` / `User Stories` / `验收标准（逐条可测）` / `实现决策` / `测试接缝` / `Out of Scope` / `变更记录`。
SPEC 必须自包含：每条 User Story 都能转成 ticket 与用例。

## 5. 纪律

### 5.1 Git

1. **禁止 `git add -A` / `git add .`**，提交一律显式列文件路径（优先 `git commit -m "..." -- <path>`，绕过索引），且 `add` 与 `commit` 之间不插入其它动作（避免索引被并发写者扫入）。
2. 工程师（`pda-de`）**只在各自 worktree 内** `git add` + `git commit`，**不得 `git push`**、**不得 merge 主干**；**只有 DM 能 `git push`**，且必须等 PM 评审通过并通知后。
3. 提交前先跑 `/code-review`；提交后 `git diff --cached --name-only` 复核暂存区。

### 5.2 并行子代理

1. **开满并行（硬约束）**：无依赖任务**必须一次派满** —— N 个互不依赖的单元 = 同一轮 N 个子代理，禁止「先派一个看看」、禁止排队等结果、禁止为省事串行。派单前自查：无依赖单元数 = 本次并发子代理数。
2. 派发前先做**依赖分析**：只有共享文件、共享构建目标、有顺序验收关系三种情形才允许串行，且必须在回报里写明卡在哪几项。
3. **同一主题的证据汇总、跨票合并与验收判断由经理串行做**，这部分不并行掉。
4. 每份派发 prompt 必须显式写清：输入（产物路径）、边界、期望产物、回报要求、`timeoutMs`（长链路不短于 45 min），并附该工种的硬约束全文（DM 见 `dm/SKILL.md`「派 `pda-de` 的硬约束」，AM 见 `am/SKILL.md`「取证硬约束」）。
5. 子代理一律后台/异步派发，**派完立即结束本轮**，由完成通知唤醒再验收；不做轮询。优先级：dynamic workflow > 多个 subagents 并行 > 串行。
6. 开发工程师**每人一个 git worktree**，只在 worktree 内编辑与提交；主工作树只读。
7. 所有子代理结果由**派发他的经理**复核证据后，才能写入权威文档或进入下一步；不得直接采信子代理的自述结论。

### 5.3 评审门禁

| 门禁 | 提交方 | 评审方 | 通过条件 |
|---|---|---|---|
| 调研报告 | AM | PM | PM 认可结论与证据来源，落盘 `docs/research/` |
| PRD 与 SPEC | PM | DM | DM 认可可实施性与切片粒度，落盘 `docs/pd/prd/`、`docs/pd/spec/` |
| 用户架构 / 用户计划 | PM | 用户 | 结构与真实代码一致、不混写未来态，落盘 `docs/user/user-arch/`、`docs/user/user-plan/` |
| ticket 代码 | DM | PM | 逐条对照 SPEC 验收标准全部通过；PM 通知 DM 后方可 push |
| 跨部门分歧 | DM / AM | PM | PM 裁决并回结论 |

## 6. 表达（全角色）

读者是**稍微懂一点软件工程但没有参与本项目的人**（含用户）：只说白话，先说结论再说证据，突出重点，术语翻成人话。

## 7. 机检

```bash
bash scripts/check-pda-doc-paths.sh <项目根>   # 本仓内为 pm/scripts/…；省略参数则检查当前目录
```

检查四件事：六个产物目录存在（`docs/pd/prd`、`docs/pd/spec`、`docs/dev/tickets`、`docs/research`、`docs/user/user-arch`、`docs/user/user-plan`）＋ 根目录 `inbox/` 存在、三个技能（`pda-pm` / `pda-dm` / `pda-am`）各自指向自己的唯一目录、本契约登记齐全、负样本能被正确拒绝。**改路径规范后必须重跑**。

## 8. 变更记录

- **2026-10-24（用户裁定·职责下沉 + 开满并行）**：① 原组长技能的内容**全部下沉**——worktree 与本地依赖补齐、派工硬约束（tdd / code-review / 显式 add / 禁 push 与 merge / 提交身份与「——de」/ 仅 `.worktrees/**`）、门与基线纪律（基准冻结、四问、门红三分类）、取证硬约束（一手出处、可复现命令、`[OBS]/[INF]/[UNK]`、不得自行换工具）由 DM / AM 收进自己的技能与派发 prompt；引号纪律与 `send-keys enter` 补发核验归各角色通信节。② 新增**开满并行硬约束**：无依赖任务必须一次派满子代理（单元数 = 并发数），串行须举证；同一主题的证据汇总、跨票合并与验收判断仍由经理串行做。
- **2026-10-24（用户裁定·取消组长层级）**：① 撤销 `pda-dl{n}` / `pda-al{n}` 两个组长技能与对应 tab，团队只剩 **`pda-pm` / `pda-dm` / `pda-am` 三个角色**；② 两个经理**直接**用 dynamic workflow 或 subagents 派 `pda-de` / `pda-ae` 工程师干活，并亲自复核、整合、落笔；③ 收件箱只剩 `inbox/{pm,dm,am}`，方向码只剩 `pm2dm` / `pm2am` / `dm2pm` / `am2pm`，工程师不走收件箱；④ 单线指挥仍为硬约束：产品总只指挥两个经理，DM 与 AM 不直连。
- **2026-10-24（用户裁定·改名与称号）**：① 团队名 `pda-team` 改为 **`pda-fleet`**；② 团队领导技能 `pda-leader-pm` 改回 **`pda-pm`**（技能目录名同步）；③ 三个角色起称号 —— `pda-pm`＝**产品总**、`pda-dm`＝**开发经理**、`pda-am`＝**分析经理**；④ 组长技能 `pda-dl{n}` / `pda-al{n}`、tab label（`PM` / `DM` / `AM`）、收件箱目录（`inbox/{pm,dm,am}`）与方向码不变（组长层级同日随后被取消，见上一条）。
- **2026-10-22（用户裁定·组织调整）**：团队改为五级单线指挥 —— ① 产品总技能由 `pda-pm` 更名 `pda-leader-pm`（团队领导兼产品经理），直属下级只有 `pda-dm` 与 `pda-am`，原 `pde` 撤销；② `pda-dm` 下新增 n 个开发组长 `pda-dl{n}`（label 同名，由 DM 用 `herdr tab create --label` 按需生成），开发工程师更名 `pda-de` 且只归组长；③ `pda-am` 下新增 n 个分析组长 `pda-al{n}`，分析工程师更名 `pda-ae` 且只归组长；④ 任何角色只与直属上下级通信，跨部门经 PM 转派。
- **2026-10-21（用户裁定）**：① PRD 类别**复活**，落盘路径由 `docs/prd/` 改为 `docs/pd/prd/`（`docs/prd/` 作废）；② 新增 `docs/dev/arch/`——**软件设计架构**落点，DM 落盘、PM 评审，命名 `{seq}-arch-{slug}-{YYMMDD-HHMM}--v{N}.md`。
- **2026-10-21（用户裁定·第二次）**：目录结构重排 —— ① 收件箱移到项目根 `inbox/<pm|dm|am>/`，不再进 `docs/`（`.gitignore` 用 `inbox/*/`）；② SPEC 由 `docs/spec/` 改为 `docs/pd/spec/`；③ ticket 由 `docs/tickets/` 改为 `docs/dev/tickets/`；④ 新增 `docs/user/user-arch/`、`docs/user/user-plan/`（均 PM 落盘），`docs/dev/arch/` 作废。
- **2026-10-21（用户裁定·第三次）**：序号按产物类别拆分 —— PRD `{prd-seq}`、调研报告 `{research-seq}`、用户架构 `{user-arch-seq}`、用户计划 `{user-plan-seq}`，各自独立、类别内自累计；SPEC 与 ticket 仍共用 `{spec-seq}`；收件箱消息保留 `{seq}` 消息流水号。
- **2026-10-21（用户裁定·第四次）**：目录由 **PM 初始化时检查并补齐**（新增 §3.1，幂等命令 + 完成判据 `ALL_PASS`）；AM / DM 不自建产物目录，缺失时回报 PM。
