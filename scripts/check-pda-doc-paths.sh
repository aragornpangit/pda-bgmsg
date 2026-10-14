#!/usr/bin/env bash
# pda-team 产物落盘路径机检（检查「使用本团队的项目」）
# 判据来源：本仓 team.md §3「落盘唯一位置（硬约束）」
# 用法：bash scripts/check-pda-doc-paths.sh [项目根目录]    默认当前目录
#     环境变量 PDA_SKILLS_DIR 可覆盖技能安装位置（默认 <项目根>/.agents/skills）
set -u

ROOT="$(cd "${1:-$PWD}" && pwd)" || exit 2
SKILLS_DIR="${PDA_SKILLS_DIR:-$ROOT/.agents/skills}"
# 解析脚本真实位置，兼容“脚本被软链到项目里”的安装方式
CONTRACT="$(cd "$(dirname "$(readlink -f "$0")")/.." && pwd)/team.md"

fail=0
echo "项目根：  $ROOT"
echo "技能目录：$SKILLS_DIR"
echo
echo "== 1) 四个产物目录必须存在 =="
for d in docs/prd docs/spec docs/research docs/tickets; do
  if [ -d "$ROOT/$d" ]; then
    echo "OK   目录存在            $d"
  else
    echo "FAIL 目录缺失            $d"
    fail=1
  fi
done

echo
echo "== 2) 三个角色技能必须指向各自唯一目录 =="
check() {
  local file="$1" want="$2" who
  who="$(basename "$(dirname "$file")")"
  if [ ! -f "$file" ]; then
    echo "FAIL 技能未安装          $who（$file）"
    fail=1
    return
  fi
  if grep -q -- "$want" "$file"; then
    echo "OK   $who 含 $want"
  else
    echo "FAIL $who 缺 $want"
    fail=1
  fi
}
check "$SKILLS_DIR/pda-pm/SKILL.md" 'docs/prd/'
check "$SKILLS_DIR/pda-pm/SKILL.md" 'docs/spec/'
check "$SKILLS_DIR/pda-dm/SKILL.md" 'docs/tickets/'
check "$SKILLS_DIR/pda-am/SKILL.md" 'docs/research/'

echo
echo "== 3) 团队契约必须登记四个唯一目录 =="
if [ -f "$CONTRACT" ]; then
  for d in 'docs/prd/' 'docs/spec/' 'docs/tickets/' 'docs/research/'; do
    if grep -q -- "$d" "$CONTRACT"; then
      echo "OK   契约含              $d"
    else
      echo "FAIL 契约缺              $d"
      fail=1
    fi
  done
else
  echo "FAIL 未找到团队契约      $CONTRACT"
  fail=1
fi

echo
echo "== 4) 负样本：判据必须能拒绝坏路径（期望 rc=1） =="
if grep -q -- 'docs/not-a-pda-output-dir/' "$CONTRACT"; then
  echo "FAIL 坏路径被误判为存在"
  fail=1
else
  echo "OK   坏路径被正确拒绝（grep rc=1）"
fi

echo "---"
if [ "$fail" -eq 0 ]; then
  echo "ALL_PASS"
else
  echo "HAS_FAIL"
fi
exit "$fail"
