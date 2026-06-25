set -u

OUT_ROOT="/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only"
ENV="/public/home/acfbwjsi7s/envs/lucapcycle_m2"
JOB_ID="115940591"
RUN_REPORT="$OUT_ROOT/logs/lucapcycle_m2_full_vector_report_${JOB_ID}.md"
RUN_OUT="$OUT_ROOT/logs/lucapcycle_m2_full_vector_${JOB_ID}.out"
RUN_ERR="$OUT_ROOT/logs/lucapcycle_m2_full_vector_${JOB_ID}.err"
AUDIT_REPORT="$OUT_ROOT/logs/lucapcycle_m2_full_vector_output_audit_$(date +%Y%m%d_%H%M%S).md"

{
  echo "# LucaPCycle M2 Full Vector Output Audit"
  echo
  echo "Date: $(date)"
  echo "Host: $(hostname)"
  echo "OUT_ROOT=$OUT_ROOT"
  echo "JOB_ID=$JOB_ID"
  echo

  echo "## 1. Boundary"
  echo
  echo "Read-only output audit."
  echo "No model extraction is run."
  echo "No training is run."
  echo "No ESM/ESM-C/ESM2 model is loaded."
  echo "No token-level matrix extraction is run."
  echo

  echo "## 2. Required File Checks"
  echo
  required_files=(
    "$OUT_ROOT/README.md"
    "$OUT_ROOT/extraction_config.json"
    "$OUT_ROOT/input_uid_sequence_manifest.csv"
    "$OUT_ROOT/uid_to_shard.csv"
    "$OUT_ROOT/audit_summary.json"
    "$RUN_REPORT"
    "$RUN_OUT"
    "$RUN_ERR"
  )
  missing=0
  for f in "${required_files[@]}"; do
    if [ -f "$f" ]; then
      echo "OK: $f"
      ls -lh "$f"
    else
      echo "MISSING: $f"
      missing=$((missing + 1))
    fi
  done
  echo "missing_required_file_count=$missing"
  echo

  echo "## 3. Log Error Check"
  echo
  if [ -f "$RUN_ERR" ]; then
    err_bytes=$(wc -c < "$RUN_ERR")
    echo "RUN_ERR_BYTES=$err_bytes"
    if [ "$err_bytes" -gt 0 ]; then
      echo
      echo "First 120 lines of RUN_ERR:"
      sed -n '1,120p' "$RUN_ERR"
    else
      echo "RUN_ERR is empty."
    fi
  else
    echo "RUN_ERR missing."
  fi
  echo

  echo "## 4. Output Directory Size"
  echo
  du -sh "$OUT_ROOT" "$OUT_ROOT/vector_features" 2>/dev/null || true
  echo
  echo "Top-level files:"
  find "$OUT_ROOT" -maxdepth 1 -type f -printf '%p\t%k KB\n' | sort
  echo

  echo "## 5. Token Matrix Absence Check"
  echo
  echo "These matches are informational. token_count fields are expected metadata; token-level matrix files/directories should not exist."
  find "$OUT_ROOT" -maxdepth 3 \( -iname '*token*' -o -iname '*matrix*' \) -print | sort || true
  echo

  echo "## 6. Python Structure Audit"
  echo
  "$ENV/bin/python" - <<'PY'
import json
import math
import os
from pathlib import Path

import numpy as np
import pandas as pd

OUT_ROOT = Path("/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only")
vector_dir = OUT_ROOT / "vector_features"
summary_path = OUT_ROOT / "audit_summary.json"
config_path = OUT_ROOT / "extraction_config.json"
input_manifest_path = OUT_ROOT / "input_uid_sequence_manifest.csv"
uid_to_shard_path = OUT_ROOT / "uid_to_shard.csv"
failed_path = OUT_ROOT / "failed_uids.csv"

errors = []

def report_error(msg):
    errors.append(msg)
    print("ERROR:", msg)

def as_list(x):
    if isinstance(x, np.ndarray):
        return x.tolist()
    return x

print("### 6.1 Summary JSON")
if summary_path.is_file():
    summary = json.loads(summary_path.read_text(encoding="utf-8"))
    for k in [
        "FULL_VECTOR_STATUS",
        "input_csv",
        "out_root",
        "total_unique_input",
        "completed_total",
        "failed_total",
        "shard_file_count",
        "batch_size",
        "shard_size",
        "elapsed_seconds",
        "device",
        "torch_version",
        "torch_cuda_is_available",
        "filtered_allowed_keys",
        "token_matrix_saved",
    ]:
        print(f"{k}: {summary.get(k)}")
    if summary.get("FULL_VECTOR_STATUS") != "PASS":
        report_error("FULL_VECTOR_STATUS is not PASS")
    if summary.get("token_matrix_saved") is not False:
        report_error("token_matrix_saved is not false")
else:
    summary = {}
    report_error("audit_summary.json missing")

print()
print("### 6.2 Extraction Config")
if config_path.is_file():
    cfg = json.loads(config_path.read_text(encoding="utf-8"))
    for k in ["model", "outputs", "token_matrix_saved", "code_root", "bin_ckpt", "bpe_codes"]:
        print(f"{k}: {cfg.get(k)}")
else:
    report_error("extraction_config.json missing")

print()
print("### 6.3 Manifest Checks")
if input_manifest_path.is_file() and uid_to_shard_path.is_file():
    input_df = pd.read_csv(input_manifest_path)
    map_df = pd.read_csv(uid_to_shard_path)
    print(f"input_manifest_rows: {len(input_df)}")
    print(f"input_manifest_unique_uid: {input_df['UniprotID'].nunique() if 'UniprotID' in input_df.columns else 'NA'}")
    print(f"uid_to_shard_rows: {len(map_df)}")
    print(f"uid_to_shard_unique_uid: {map_df['uid'].nunique() if 'uid' in map_df.columns else 'NA'}")
    print(f"uid_to_shard_duplicate_uid_count: {int(map_df['uid'].duplicated().sum()) if 'uid' in map_df.columns else 'NA'}")

    if "UniprotID" in input_df.columns and "uid" in map_df.columns:
      input_uids = set(input_df["UniprotID"].astype(str))
      mapped_uids = set(map_df["uid"].astype(str))
      missing_from_map = sorted(input_uids - mapped_uids)
      extra_in_map = sorted(mapped_uids - input_uids)
      print(f"uids_missing_from_uid_to_shard: {len(missing_from_map)}")
      print(f"uids_extra_in_uid_to_shard: {len(extra_in_map)}")
      if missing_from_map:
          print("first_missing_uids:", missing_from_map[:10])
          report_error("some input UIDs are missing from uid_to_shard")
      if extra_in_map:
          print("first_extra_uids:", extra_in_map[:10])
          report_error("uid_to_shard contains UIDs absent from input manifest")
    else:
      report_error("manifest columns missing UniprotID or uid")

    required_map_cols = [
        "uid",
        "shard_file",
        "row_in_shard",
        "sequence_sha256",
        "sequence_length",
        "bpe_token_count_without_special",
        "token_count_with_special",
    ]
    print("uid_to_shard_columns:", map_df.columns.tolist())
    missing_cols = [c for c in required_map_cols if c not in map_df.columns]
    print("uid_to_shard_missing_columns:", missing_cols)
    if missing_cols:
        report_error("uid_to_shard missing required columns")
else:
    input_df = pd.DataFrame()
    map_df = pd.DataFrame()
    report_error("input manifest or uid_to_shard missing")

print()
print("### 6.4 Failed UID Check")
if failed_path.exists():
    try:
        failed_df = pd.read_csv(failed_path)
        print(f"failed_uids_file_exists: true")
        print(f"failed_uids_rows: {len(failed_df)}")
        if len(failed_df):
            print(failed_df.head(10).to_string(index=False))
            report_error("failed_uids.csv has rows")
    except Exception as exc:
        print(f"failed_uids_read_error: {repr(exc)}")
        report_error("failed_uids.csv exists but cannot be read")
else:
    print("failed_uids_file_exists: false")
    print("failed_uids_rows: 0")

print()
print("### 6.5 Shard File Checks")
shards = sorted(vector_dir.glob("m2_vectors_part_*.npz"))
print(f"shard_count: {len(shards)}")
indices = []
for p in shards:
    try:
        indices.append(int(p.stem.split("_")[-1]))
    except Exception:
        report_error(f"cannot parse shard index: {p.name}")
expected_indices = list(range(len(shards)))
print(f"shard_index_min: {min(indices) if indices else 'NA'}")
print(f"shard_index_max: {max(indices) if indices else 'NA'}")
print(f"shard_indices_contiguous_0_based: {indices == expected_indices}")
if indices != expected_indices:
    report_error("shard indices are not contiguous 0-based")

expected_keys = [
    "uid",
    "sequence_sha256",
    "sequence_length",
    "bpe_token_count_without_special",
    "token_count_with_special",
    "m2_mean",
    "m2_max",
    "m2_value_attention",
    "m2_projected_256",
]
feature_specs = {
    "m2_mean": (1024, np.float32),
    "m2_max": (1024, np.float32),
    "m2_value_attention": (1024, np.float32),
    "m2_projected_256": (256, np.float32),
}

row_counts = []
total_rows = 0
sample_details = {}
global_stats = {k: {"min": math.inf, "max": -math.inf, "mean_sum": 0.0, "mean_count": 0} for k in feature_specs}

for shard_i, p in enumerate(shards):
    with np.load(p, allow_pickle=False) as z:
        keys = sorted(z.files)
        if keys != sorted(expected_keys):
            report_error(f"{p.name} keys mismatch: {keys}")
        n = len(z["uid"])
        row_counts.append(n)
        total_rows += n

        if n == 0:
            report_error(f"{p.name} has zero rows")
            continue

        for meta_key in ["sequence_length", "bpe_token_count_without_special", "token_count_with_special"]:
            arr = z[meta_key]
            if arr.shape != (n,):
                report_error(f"{p.name}:{meta_key} shape {arr.shape}, expected {(n,)}")

        for feat, (dim, dtype) in feature_specs.items():
            arr = z[feat]
            if arr.shape != (n, dim):
                report_error(f"{p.name}:{feat} shape {arr.shape}, expected {(n, dim)}")
            if arr.dtype != dtype:
                report_error(f"{p.name}:{feat} dtype {arr.dtype}, expected {dtype}")
            nan_count = int(np.isnan(arr).sum())
            inf_count = int(np.isinf(arr).sum())
            if nan_count or inf_count:
                report_error(f"{p.name}:{feat} nan={nan_count}, inf={inf_count}")
            global_stats[feat]["min"] = min(global_stats[feat]["min"], float(np.min(arr)))
            global_stats[feat]["max"] = max(global_stats[feat]["max"], float(np.max(arr)))
            global_stats[feat]["mean_sum"] += float(np.mean(arr))
            global_stats[feat]["mean_count"] += 1

        if shard_i in {0, len(shards)//2, len(shards)-1}:
            sample_details[p.name] = {
                "keys": keys,
                "rows": int(n),
                "uid_dtype": str(z["uid"].dtype),
                "sequence_length_dtype": str(z["sequence_length"].dtype),
                "feature_shapes": {feat: list(z[feat].shape) for feat in feature_specs},
                "feature_dtypes": {feat: str(z[feat].dtype) for feat in feature_specs},
                "first_three_records": [],
            }
            take = min(3, n)
            for j in range(take):
                rec = {
                    "row": int(j),
                    "uid": str(z["uid"][j]),
                    "sequence_length": int(z["sequence_length"][j]),
                    "bpe_token_count_without_special": int(z["bpe_token_count_without_special"][j]),
                    "token_count_with_special": int(z["token_count_with_special"][j]),
                    "sequence_sha256_prefix": str(z["sequence_sha256"][j])[:16],
                    "m2_mean_first5": [round(float(x), 6) for x in z["m2_mean"][j, :5]],
                    "m2_value_attention_first5": [round(float(x), 6) for x in z["m2_value_attention"][j, :5]],
                    "m2_projected_256_first5": [round(float(x), 6) for x in z["m2_projected_256"][j, :5]],
                    "m2_mean_l2_norm": round(float(np.linalg.norm(z["m2_mean"][j])), 6),
                    "m2_value_attention_l2_norm": round(float(np.linalg.norm(z["m2_value_attention"][j])), 6),
                    "m2_projected_256_l2_norm": round(float(np.linalg.norm(z["m2_projected_256"][j])), 6),
                }
                sample_details[p.name]["first_three_records"].append(rec)

print(f"total_rows_across_shards: {total_rows}")
print(f"row_count_min: {min(row_counts) if row_counts else 'NA'}")
print(f"row_count_max: {max(row_counts) if row_counts else 'NA'}")
print(f"row_count_last: {row_counts[-1] if row_counts else 'NA'}")
print(f"row_count_distribution: {dict(sorted(pd.Series(row_counts).value_counts().to_dict().items())) if row_counts else {}}")
expected_total = int(summary.get("total_unique_input", 107731)) if isinstance(summary, dict) else 107731
expected_shard_count = int(summary.get("shard_file_count", 108)) if isinstance(summary, dict) else 108
if total_rows != expected_total:
    report_error(f"total rows across shards {total_rows} != expected {expected_total}")
if len(shards) != expected_shard_count:
    report_error(f"shard count {len(shards)} differs from expected {expected_shard_count}")

print()
print("### 6.6 Feature Global Sample Stats Across All Shards")
for feat, stat in global_stats.items():
    mean_of_shard_means = stat["mean_sum"] / max(stat["mean_count"], 1)
    print(f"{feat}: global_min={stat['min']:.6f}, global_max={stat['max']:.6f}, mean_of_shard_means={mean_of_shard_means:.6f}")

print()
print("### 6.7 Selected Shard Data Structure Examples")
print(json.dumps(sample_details, indent=2, ensure_ascii=False))

print()
print("### 6.8 Teacher-Facing Feature Schema")
schema = {
    "file_format": "compressed NumPy .npz shard",
    "shard_count": len(shards),
    "rows_total": total_rows,
    "rows_per_full_shard": 1000,
    "last_shard_rows": row_counts[-1] if row_counts else None,
    "keys": expected_keys,
    "features": {
        "m2_mean": "float32, shape (N, 1024), masked mean pooling over LucaPCycle seq_encoder token representations",
        "m2_max": "float32, shape (N, 1024), masked max pooling over LucaPCycle seq_encoder token representations",
        "m2_value_attention": "float32, shape (N, 1024), LucaPCycle configured value_attention seq_pooler output",
        "m2_projected_256": "float32, shape (N, 256), value_attention pooled vector after LucaPCycle seq_linear projection",
    },
    "metadata": {
        "uid": "UniProt ID string array, shape (N,)",
        "sequence_sha256": "sequence hash for consistency checking, shape (N,)",
        "sequence_length": "original amino-acid sequence length, int64, shape (N,)",
        "bpe_token_count_without_special": "BPE token count before CLS/SEP, int64, shape (N,)",
        "token_count_with_special": "BPE token count plus CLS/SEP, int64, shape (N,)",
    },
}
print(json.dumps(schema, indent=2, ensure_ascii=False))

print()
print("### 6.9 Final Audit Status")
if errors:
    print("FULL_VECTOR_OUTPUT_AUDIT_STATUS=FAIL")
    print("error_count:", len(errors))
    for e in errors[:50]:
        print(" -", e)
else:
    print("FULL_VECTOR_OUTPUT_AUDIT_STATUS=PASS")
    print("error_count: 0")
PY
  echo

  echo "## 7. Final Boundary"
  echo
  echo "Read-only audit finished."
  echo "No extraction was run."
  echo "No training was run."
  echo "No ESM/ESM-C/ESM2 model was loaded."
} | tee "$AUDIT_REPORT"

echo
echo "AUDIT_REPORT_WRITTEN=$AUDIT_REPORT"
