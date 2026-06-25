# HPC LucaPCycle M2 Full Enzyme Input Audit Prompt

Date: 2026-06-25

Copy this prompt to the HPC-side AI before deciding whether to run LucaPCycle
M2 extraction for the complete enzyme pool.

---

你现在在 HPC 上帮我做 **LucaPCycle M2 完整酶集合输入审计**。

这一步只允许检查输入表、行数、UID 覆盖关系和已有 M2 结果覆盖；**不要训练、不要提取 M2、不要提交 SLURM、不要修改代码、不要删除或覆盖已有输出**。

## 背景

当前已经完成的 M2 vector-only 结果不是完整 19 万酶集合，而是训练表去重后的 UID 集合：

```text
已完成输出目录:
/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only

已完成输入:
/public/home/acfbwjsi7s/bio_vector_full_run_2026-06-04/data/reaction_enzyme_microbe_training_clean_2026-06-01_LOCAL/tables/reaction_enzyme_pairs.csv

已完成 UID 数:
107731
```

本地完整酶序列表是：

```text
/home/a/EnzymeCAGE/data/processed/rhea/2026-01-21/all_enzymes.csv
rows=195743
unique UniprotID=195743
columns=UniprotID,sequence
```

现在需要确认 HPC 上是否也有这个完整表；如果有，统计它与已完成 M2 的覆盖关系。如果没有，请报告需要上传，并建议上传目标路径。

## 固定路径

```text
ENV=/public/home/acfbwjsi7s/envs/lucapcycle_m2
CURRENT_M2_OUT=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only
TRAINING_TABLE=/public/home/acfbwjsi7s/bio_vector_full_run_2026-06-04/data/reaction_enzyme_microbe_training_clean_2026-06-01_LOCAL/tables/reaction_enzyme_pairs.csv
```

## 只允许检查的完整酶表候选路径

请只检查下面这些候选路径，不要全盘搜索：

```text
/public/home/acfbwjsi7s/data/processed/rhea/2026-01-21/all_enzymes.csv
/public/home/acfbwjsi7s/EnzymeCAGE/data/processed/rhea/2026-01-21/all_enzymes.csv
/public/home/acfbwjsi7s/LucaPCycle-3/all_enzymes.csv
/public/home/acfbwjsi7s/bio_vector_full_run_2026-06-04/data/processed/rhea/2026-01-21/all_enzymes.csv
```

如果都不存在，请建议上传本地文件：

```text
本地: /home/a/EnzymeCAGE/data/processed/rhea/2026-01-21/all_enzymes.csv
建议上传到 HPC:
/public/home/acfbwjsi7s/LucaPCycle-3/all_enzymes.csv
```

## 请运行的命令

```bash
set -u

ENV="/public/home/acfbwjsi7s/envs/lucapcycle_m2"
CURRENT_M2_OUT="/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only"
TRAINING_TABLE="/public/home/acfbwjsi7s/bio_vector_full_run_2026-06-04/data/reaction_enzyme_microbe_training_clean_2026-06-01_LOCAL/tables/reaction_enzyme_pairs.csv"
REPORT="/public/home/acfbwjsi7s/LucaPCycle-3/lucapcycle_m2_full_enzyme_input_audit_$(date +%Y%m%d_%H%M%S).md"

FULL_CANDIDATES=(
  "/public/home/acfbwjsi7s/data/processed/rhea/2026-01-21/all_enzymes.csv"
  "/public/home/acfbwjsi7s/EnzymeCAGE/data/processed/rhea/2026-01-21/all_enzymes.csv"
  "/public/home/acfbwjsi7s/LucaPCycle-3/all_enzymes.csv"
  "/public/home/acfbwjsi7s/bio_vector_full_run_2026-06-04/data/processed/rhea/2026-01-21/all_enzymes.csv"
)

{
  echo "# LucaPCycle M2 Full Enzyme Input Audit"
  echo
  echo "Date: $(date)"
  echo "Host: $(hostname)"
  echo

  echo "## 1. Boundary"
  echo
  echo "Input and coverage audit only."
  echo "No M2 extraction is run."
  echo "No SLURM job is submitted."
  echo "No training is run."
  echo "No ESM/ESM-C/ESM2 model is loaded."
  echo

  echo "## 2. Candidate Full Enzyme Tables"
  echo
  FULL_TABLE=""
  for p in "${FULL_CANDIDATES[@]}"; do
    if [ -f "$p" ]; then
      echo "FOUND: $p"
      ls -lh "$p"
      if [ -z "$FULL_TABLE" ]; then
        FULL_TABLE="$p"
      fi
    else
      echo "MISSING: $p"
    fi
  done
  echo
  echo "SELECTED_FULL_TABLE=$FULL_TABLE"
  echo

  echo "## 3. Existing M2 Output Checks"
  echo
  for p in \
    "$CURRENT_M2_OUT" \
    "$CURRENT_M2_OUT/audit_summary.json" \
    "$CURRENT_M2_OUT/input_uid_sequence_manifest.csv" \
    "$CURRENT_M2_OUT/uid_to_shard.csv" \
    "$CURRENT_M2_OUT/vector_features"
  do
    if [ -e "$p" ]; then
      echo "OK: $p"
      ls -ldh "$p"
    else
      echo "MISSING: $p"
    fi
  done
  echo

  echo "## 4. Python UID Coverage Audit"
  echo
  "$ENV/bin/python" - <<PY
import json
from pathlib import Path
import pandas as pd

full_table = Path("$FULL_TABLE") if "$FULL_TABLE" else None
training_table = Path("$TRAINING_TABLE")
current_out = Path("$CURRENT_M2_OUT")
uid_to_shard = current_out / "uid_to_shard.csv"
audit_summary = current_out / "audit_summary.json"

errors = []
def err(msg):
    errors.append(msg)
    print("ERROR:", msg)

print("selected_full_table:", str(full_table) if full_table else "")
print("training_table:", training_table)
print("current_m2_out:", current_out)

if audit_summary.is_file():
    summary = json.loads(audit_summary.read_text(encoding="utf-8"))
    print("current_FULL_VECTOR_STATUS:", summary.get("FULL_VECTOR_STATUS"))
    print("current_total_unique_input:", summary.get("total_unique_input"))
    print("current_completed_total:", summary.get("completed_total"))
    print("current_failed_total:", summary.get("failed_total"))
else:
    err("current audit_summary.json missing")

if training_table.is_file():
    train = pd.read_csv(training_table, usecols=["UniprotID", "sequence"])
    train["UniprotID"] = train["UniprotID"].astype(str)
    train_uids = set(train["UniprotID"])
    print("training_rows:", len(train))
    print("training_unique_uid:", len(train_uids))
else:
    train = pd.DataFrame()
    train_uids = set()
    err("training_table missing")

if uid_to_shard.is_file():
    done = pd.read_csv(uid_to_shard, usecols=["uid"])
    done["uid"] = done["uid"].astype(str)
    done_uids = set(done["uid"])
    print("current_m2_uid_to_shard_rows:", len(done))
    print("current_m2_unique_uid:", len(done_uids))
    print("current_m2_duplicate_uid_count:", int(done["uid"].duplicated().sum()))
else:
    done = pd.DataFrame()
    done_uids = set()
    err("uid_to_shard.csv missing")

if full_table and full_table.is_file():
    full = pd.read_csv(full_table)
    print("full_columns:", full.columns.tolist())
    required = {"UniprotID", "sequence"}
    if not required.issubset(full.columns):
        err(f"full table missing required columns: {required - set(full.columns)}")
    else:
        full = full[["UniprotID", "sequence"]].dropna()
        full["UniprotID"] = full["UniprotID"].astype(str)
        full["sequence"] = full["sequence"].astype(str)
        full = full[full["sequence"].str.len() > 0]
        full_uids = set(full["UniprotID"])
        print("full_rows_after_nonnull_sequence:", len(full))
        print("full_unique_uid:", len(full_uids))
        print("full_duplicate_uid_count:", int(full["UniprotID"].duplicated().sum()))
        print("full_min_sequence_length:", int(full["sequence"].str.len().min()))
        print("full_max_sequence_length:", int(full["sequence"].str.len().max()))
        print("full_head:")
        print(full.head(5).to_string(index=False))

        print("overlap_full_vs_current_m2:", len(full_uids & done_uids))
        print("missing_from_current_m2_if_full_needed:", len(full_uids - done_uids))
        print("extra_current_m2_not_in_full:", len(done_uids - full_uids))
        print("overlap_full_vs_training:", len(full_uids & train_uids))
        print("training_uids_missing_from_full:", len(train_uids - full_uids))
        print("full_uids_not_in_training:", len(full_uids - train_uids))
        print("first_20_missing_from_current_m2:", sorted(full_uids - done_uids)[:20])
else:
    print("FULL_TABLE_STATUS=MISSING_ON_HPC")
    print("UPLOAD_NEEDED=yes")
    print("local_source_to_upload=/home/a/EnzymeCAGE/data/processed/rhea/2026-01-21/all_enzymes.csv")
    print("recommended_hpc_target=/public/home/acfbwjsi7s/LucaPCycle-3/all_enzymes.csv")

print()
if errors:
    print("FULL_ENZYME_INPUT_AUDIT_STATUS=FAIL")
    print("error_count:", len(errors))
else:
    if full_table and full_table.is_file():
        print("FULL_ENZYME_INPUT_AUDIT_STATUS=PASS_FULL_TABLE_FOUND")
        print("error_count: 0")
    else:
        print("FULL_ENZYME_INPUT_AUDIT_STATUS=NEEDS_UPLOAD_FULL_TABLE")
        print("error_count: 0")
PY
  echo

  echo "## 5. Final Recommendation Boundary"
  echo
  echo "Do not run full enzyme M2 extraction until this audit is reviewed."
} | tee "$REPORT"

echo
echo "REPORT_WRITTEN=$REPORT"
```

## 需要你最后回复我的内容

请把下面内容贴回来：

1. markdown 报告路径；
2. `FULL_ENZYME_INPUT_AUDIT_STATUS`；
3. `SELECTED_FULL_TABLE`；
4. 如果完整表不存在，是否需要上传，以及建议上传路径；
5. `full_rows_after_nonnull_sequence`、`full_unique_uid`、`full_duplicate_uid_count`；
6. `current_m2_unique_uid`；
7. `overlap_full_vs_current_m2`；
8. `missing_from_current_m2_if_full_needed`；
9. `full_uids_not_in_training`；
10. `training_uids_missing_from_full`；
11. 前 20 个 missing UID。

不要开始 M2 提取，等我审核后再决定是补跑 missing-only，还是重新跑完整 `195,743` UID 输出目录。
