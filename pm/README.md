# pda-fleet

pda-fleet 团队的角色技能仓：**团队定义与五个角色技能的唯一维护地**。

| 角色 | 技能 | tab label | 直属上级 | 直属下级 | 职责摘要 |
|---|---|---|---|---|---|
| 产品总 | `pda-pm` | `PM` | 用户 | `pda-dm`、`pda-am` | 接需求、输出验收标准、落笔 PRD 与 SPEC、评审调研报告与 ticket 代码、跨部门裁决 |
| 开发经理 | `pda-dm` | `DM` | `pda-pm` | `pda-dl{n}` | 由 SPEC 拆 ticket、按需生成开发组长、验收整合、PM 通过后才 push |
| 分析经理 | `pda-am` | `AM` | `pda-pm` | `pda-al{n}` | 接调研诉求、按需生成分析组长、收口调研报告 |
| 开发组长 | `pda-dl`（实例 `pda-dl{n}`） | `pda-dl1`、`pda-dl2` … | `pda-dm` | `pda-de`（子代理） | 建 worktree、派开发工程师、收 diff 做初检、回报 DM |
| 分析组长 | `pda-al`（实例 `pda-al{n}`） | `pda-al1`、`pda-al2` … | `pda-am` | `pda-ae`（子代理） | 拆子问题、派分析工程师并行取证、复核出处、回报 AM |

**单线指挥**：每个角色只与直属上下级通信；PM 不越级指挥组长与工程师，经理不直接给工程师派活，组长之间、经理之间不横向直连，跨部门一律经 PM 转派。
组长**按需生成、不预建**：DM 用 `herdr tab create --workspace "$HERDR_WORKSPACE_ID" --cwd "$PWD" --label pda-dl{n}` 建开发组长，AM 用同样的命令建 `pda-al{n}`。

成员运行在 Herdr（终端多智能体复用器）中，**按 tab label 识别伙伴**，pane id 每次发送前重查。
**角色间通信 = 收件箱文件 + herdr 门铃**：正文写进收件方 `inbox/<收件角色>/{seq}-{方向}-{slug}-{YYMMDDHHMM}.md`（项目根，不在 `docs/` 下），herdr 只发一句「你有新消息 …」；收件方读后回执「… 已经收到」并删掉文件（详见 `team.md` §1.3）。
工作流一句话：AM 派分析组长调研（PM 评审）→ PM 出 PRD 与 SPEC（DM 评审）→ DM 拆 ticket 并生成开发组长 → 组长派 pda-de 实施并初检 → DM 验收整合 → PM 评审通过 → DM `git push`。

**团队契约（组织、通信、文件命名、目录职责与纪律的唯一权威）＝ [`team.md`](team.md)。**

```
pda-fleet/                              # 一个角色一个文件夹
├── pm/                                 # 产品总（技能 pda-pm）
│   ├── SKILL.md
│   ├── team.md                         # 团队契约（唯一权威）
│   ├── README.md                       # 本文件
│   └── scripts/check-pda-doc-paths.sh  # 产物落盘路径机检
├── dm/SKILL.md                         # 开发经理（pda-dm）
├── am/SKILL.md                         # 分析经理（pda-am）
├── dl/SKILL.md                         # 开发组长（pda-dl{n}）
└── al/SKILL.md                         # 分析组长（pda-al{n}）
```

## 安装到一个项目

仓内目录名是简称（`pm` / `dm` / `am` / `dl` / `al`），**装到技能目录时用技能名**（`pda-pm` / `pda-dm` / `pda-am` / `pda-dl` / `pda-al`），目录名即技能名。

```bash
mkdir -p <项目>/.agents/skills/{pda-pm,pda-dm,pda-am,pda-dl,pda-al} <项目>/scripts \
         <项目>/docs/{pd/{prd,spec},dev/tickets,research,user/{user-arch,user-plan}} \
         <项目>/inbox/{pm,dm,am}
cp pm/SKILL.md  <项目>/.agents/skills/pda-pm/
cp dm/SKILL.md  <项目>/.agents/skills/pda-dm/
cp am/SKILL.md  <项目>/.agents/skills/pda-am/
cp dl/SKILL.md  <项目>/.agents/skills/pda-dl/
cp al/SKILL.md  <项目>/.agents/skills/pda-al/
cp pm/team.md <项目>/docs/team.md
cp pm/scripts/check-pda-doc-paths.sh <项目>/scripts/
printf 'inbox/*/\n' >> <项目>/.gitignore        # 收件箱是运行时通道，不入库
```

想跟随本仓更新就改用**相对软链**（推荐；以与本仓同级的项目为例）：

```bash
ln -s ../../../pda-fleet/pm <项目>/.agents/skills/pda-pm
ln -s ../../../pda-fleet/dm <项目>/.agents/skills/pda-dm     # am / dl / al 同理
ln -s ../../pda-fleet/pm/team.md <项目>/docs/team.md
ln -s ../../pda-fleet/pm/scripts/check-pda-doc-paths.sh <项目>/scripts/check-pda-doc-paths.sh
```

软链整个角色目录时，`pm/` 里的契约、说明与机检脚本一并可见，不影响技能加载。
装到其他 harness（codebuddy / codex / opencode 等）的用户级技能目录时，规则同样是**目录名即技能名**。

## 机检

```bash
bash pm/scripts/check-pda-doc-paths.sh <项目根目录>   # 省略参数则检查当前目录
# 技能未装在 <项目根>/.agents/skills 时，用 PDA_SKILLS_DIR 覆盖（默认值见脚本第 9 行）
```

判据四项：六个产物目录 + 根目录 `inbox/` 存在（**缺则由 PM 初始化时补齐**，见 `team.md` §3.1）、五个角色技能各自指向自己的唯一目录、本契约登记齐全、负样本能被正确拒绝。**改路径规范后必须重跑。**

## 维护

- 本仓是 pda-fleet 的**唯一维护地**，使用方不保留副本；软链后技能与契约随本仓更新，改完即生效（无需重装）。
- 技能内的契约引用不依赖相对路径（写作「`pm/team.md`（本仓；装到项目后为 `docs/team.md`）」），因此软链安装不会断链。
- 依赖 harness 侧技能：`herdr`（通信与 tab 生成）、`pi-subagents`（subagents 与 dynamic workflow），以及 mattpocock 的 `/to-spec`、`/to-tickets`、`/code-review`、`/tdd`、`/research` 等（安装与回退见 `team.md` §1.4）。
