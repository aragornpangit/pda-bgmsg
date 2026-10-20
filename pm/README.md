# pda-team

pda 团队的角色技能仓（Product / Development / Analysis）：**团队定义与三个角色技能的唯一维护地**。

| 角色 | tab label | 下属子代理 | 职责摘要 |
|---|---|---|---|
| PM 产品部经理（**兼任团队领导**，`pda-pm`） | `PM` | `pde` | 接需求、输出验收标准、评审调研报告、自己落笔 PRD 与 SPEC、评审 ticket 代码、跨部门裁决 |
| DM 开发部经理（`pda-dm`） | `DM` | `sde` | 由 SPEC 拆 ticket、每个 sde 一个 git worktree、派单与验收整合、PM 评审通过后才 push |
| AM 分析部经理（`pda-am`） | `AM` | `analyst` | 网络信息调研与竞品逆向（REA）、产出调研报告、交 PM 评审后落盘 |

成员运行在 Herdr（终端多智能体复用器）中，**按 tab label 识别伙伴**，pane id 每次发送前重查。
**角色间通信 = 收件箱文件 + herdr 门铃**：正文写进收件方 `docs/<收件角色>/inbox/{seq}-{方向}-{slug}-{YYMMDDHHMM}.md`，herdr 只发一句「你有新消息 …」；收件方读后回执「… 已经收到」并删掉文件（详见 `team.md` §1.3）。
工作流一句话：AM 调研（PM 评审）→ PM 出 PRD 与 SPEC（DM 评审）→ DM 拆 ticket 并派 sde 实施 → DM 交 PM 部门评审通过 → DM `git push`。

**团队契约（工作流程、通信、文件命名、目录职责与纪律的唯一权威）＝ [`team.md`](team.md)。**

```
pda-bgmsg/                              # 根目录只有 pm / dm / am 三个文件夹
├── pm/                                 # 产品部经理兼团队领导（pda-pm）
│   ├── SKILL.md
│   ├── team.md                         # 团队契约（唯一权威）
│   ├── README.md                       # 本文件
│   └── scripts/check-pda-doc-paths.sh  # 产物落盘路径机检
├── dm/SKILL.md                         # 开发部经理（pda-dm）
└── am/SKILL.md                         # 分析部经理（pda-am）
```

## 安装到一个项目

技能与契约都装到**被服务项目**里：技能目录名用 `pm` / `dm` / `am`，技能 `name` 用 `pda-pm` / `pda-dm` / `pda-am`。

```bash
mkdir -p <项目>/.agents/skills/{pm,dm,am} <项目>/docs/{prd,spec,research,tickets} <项目>/scripts
for r in pm dm am; do cp $r/SKILL.md <项目>/.agents/skills/$r/; done
cp pm/team.md <项目>/docs/team.md
cp pm/scripts/check-pda-doc-paths.sh <项目>/scripts/
printf 'docs/*/inbox/\n' >> <项目>/.gitignore   # 收件箱是运行时通道，不入库
```

想跟随本仓更新就改用**相对软链**（推荐；以与本仓同级的项目为例）：

```bash
ln -s ../../../pda-bgmsg/pm <项目>/.agents/skills/pm   # dm / am 同理
ln -s ../../pda-bgmsg/pm/team.md <项目>/docs/team.md
ln -s ../../pda-bgmsg/pm/scripts/check-pda-doc-paths.sh <项目>/scripts/check-pda-doc-paths.sh
```

软链整个角色目录时，`pm/` 里的契约、说明与机检脚本一并可见，不影响技能加载。
装到其他 harness（codebuddy / codex / opencode 等）的用户级技能目录时，规则同样是**目录名即角色名**。

## 机检

```bash
bash pm/scripts/check-pda-doc-paths.sh <项目根目录>   # 省略参数则检查当前目录
# 技能未装在 <项目根>/.agents/skills 时，用 PDA_SKILLS_DIR 覆盖（默认值见脚本第 9 行）
```

判据四项：四个产物目录存在、`pm` / `dm` / `am` 各自指向自己的唯一目录、本契约登记齐全、负样本能被正确拒绝。**改路径规范后必须重跑。**

## 维护

- 本仓是 pda-team 的**唯一维护地**，使用方不保留副本；软链后技能与契约随本仓更新，改完即生效（无需重装）。
- 技能内的契约引用不依赖相对路径（写作「`pm/team.md`（本仓；装到项目后为 `docs/team.md`）」），因此软链安装不会断链。
- 依赖 harness 侧技能：`herdr`（通信）、`pi-subagents`（subagents 与 dynamic workflow），以及 mattpocock 的 `/to-spec`、`/to-tickets`、`/code-review`、`/tdd`、`/research` 等（安装与回退见 `team.md` §1.4）。
