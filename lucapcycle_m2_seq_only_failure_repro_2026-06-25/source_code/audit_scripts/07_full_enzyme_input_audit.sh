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
