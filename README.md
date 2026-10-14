# pda-team

pda 团队的角色技能仓（Product / Development / Analysis）：**团队定义与三个角色技能的唯一维护地**。

## 团队

| 角色 | tab label | 下属子代理 | 职责摘要 |
|---|---|---|---|
| PM 产品经理（**兼任团队领导**） | `PM` | `pde` | 接需求、输出验收标准、评审调研报告、自己落笔 PRD 与 SPEC、评审 ticket 代码、跨部门裁决 |
| DM 开发经理 | `DM` | `sde` | 由 SPEC 拆 ticket、每个 sde 一个 git worktree、派单与验收整合、PM 评审通过后才 push |
| AM 调研与分析部经理 | `AM` | `analyst` | 网络信息调研与竞品逆向（REA）、产出调研报告、交 PM 评审后落盘 |

成员运行在 Herdr（终端多智能体复用器）中，**按 tab label 识别伙伴**，pane id 每次发送前重查。
团队工作流程、通信方式、文件命名、目录职责与纪律的唯一权威是 [`team.md`](team.md)。

工作流一句话：AM 调研（PM 评审）→ PM 出 PRD 与 SPEC（DM 评审）→ DM 拆 ticket 并派 sde 实施 → DM 交 PM 部门评审通过 → DM `git push`。

## 目录结构

```
pda-team/
├── README.md
├── team.md                        # 团队契约（唯一权威）
├── skills/
│   ├── pda-pm/SKILL.md            # 产品经理兼团队领导
│   ├── pda-am/SKILL.md            # 调研与分析部经理
│   └── pda-dm/SKILL.md            # 开发经理
└── scripts/check-pda-doc-paths.sh # 产物落盘路径机检
```

## 安装到一个项目

技能与契约都装到**被服务项目**里：

```bash
# 1) 技能（拍平到项目的 .agents/skills/，pi 等 harness 会自动发现）
mkdir -p <项目>/.agents/skills
cp -r skills/pda-pm skills/pda-am skills/pda-dm <项目>/.agents/skills/

# 2) 团队契约
cp team.md <项目>/docs/team.md

# 3) 产物目录骨架
mkdir -p <项目>/docs/{prd,spec,research,tickets}
```

想跟随本仓更新就改用软链：

```bash
ln -s "$PWD/skills/pda-pm" <项目>/.agents/skills/pda-pm   # 其余两个同理
```

装到其他 harness（codebuddy / codex / opencode 等）的用户级技能目录时，规则同样是**拍平**（去掉 `skills/` 这层）。

## 机检

```bash
bash scripts/check-pda-doc-paths.sh <项目根目录>   # 省略参数则检查当前目录
```

判据四项：项目内四个产物目录存在、三个角色技能各自指向自己的唯一目录、团队契约登记齐全、负样本能被正确拒绝。

| 角色 | 产物 | 唯一目录 |
|---|---|---|
| PM | PRD | `docs/prd/` |
| PM | SPEC | `docs/spec/` |
| DM | ticket | `docs/tickets/` |
| AM | 调研报告 | `docs/research/` |

## 维护

- 本仓是 pda-team 的**唯一维护地**；`cloneDynm/docs/team.md` 与 `cloneDynm/.agents/skills/pda-*` 是 2026-10-14 的历史副本，此后不再更新。
- 改路径规范或角色职责后，必须重跑 `scripts/check-pda-doc-paths.sh`。
- 依赖 harness 侧技能：`herdr`（通信）、`pi-subagents`（subagents 与 dynamic workflow），以及 mattpocock 的 `/to-spec`、`/to-tickets`、`/code-review`、`/tdd`、`/research` 等（安装与回退见 [`team.md`](team.md) §1.4）。
