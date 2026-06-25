# HPC LucaPCycle M2 Vector Diversity Audit Prompt

Date: 2026-06-25

Copy this prompt to the HPC-side AI before running the complete 195,743-enzyme
M2 extraction.

---

你现在在 HPC 上帮我做 **LucaPCycle M2 训练 UID 向量区分度只读审计**。

这一步只读取已经生成的 `107,731` 训练 UID vector-only 结果，检查向量是否存在大规模重复、近乎常量或 pairwise cosine 过高的问题；**不要训练、不要重新提取、不要提交 SLURM、不要修改代码、不要加载 ESM/ESM-C/ESM2、不要删除或覆盖已有输出**。

## 为什么要做这一步

全量输出结构审计已经通过：

```text
FULL_VECTOR_OUTPUT_AUDIT_STATUS=PASS
total_rows_across_shards=107731
failed_uids_rows=0
```

但审计报告中的少量示例显示多个 UID 的前 5 维和 L2 norm 非常接近。示例的前 5 维不能代表完整 1024/256 维向量，因此需要做一次数值区分度审计，确认向量整体不是退化为大量相同或近似相同的表示。这个审计通过后，再补跑完整 `195,743` 酶池更稳。

## 固定路径

```text
ENV=/public/home/acfbwjsi7s/envs/lucapcycle_m2
OUT_ROOT=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only
VECTOR_DIR=/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features
```

## 请运行的命令

请在 HPC 登录节点执行下面命令。它是只读审计，不需要 GPU/DCU。

```bash
set -u

ENV="/public/home/acfbwjsi7s/envs/lucapcycle_m2"
OUT_ROOT="/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only"
VECTOR_DIR="$OUT_ROOT/vector_features"
REPORT="$OUT_ROOT/logs/lucapcycle_m2_vector_diversity_audit_$(date +%Y%m%d_%H%M%S).md"

{
  echo "# LucaPCycle M2 Vector Diversity Audit"
  echo
  echo "Date: $(date)"
  echo "Host: $(hostname)"
  echo "OUT_ROOT=$OUT_ROOT"
  echo

  echo "## 1. Boundary"
  echo
  echo "Read-only vector diversity audit."
  echo "No extraction is run."
  echo "No training is run."
  echo "No ESM/ESM-C/ESM2 model is loaded."
  echo "No SLURM job is submitted."
  echo

  echo "## 2. File Checks"
  echo
  if [ -d "$VECTOR_DIR" ]; then
    echo "OK: $VECTOR_DIR"
    echo "shard_count: $(find "$VECTOR_DIR" -name 'm2_vectors_part_*.npz' -type f | wc -l)"
  else
    echo "MISSING: $VECTOR_DIR"
  fi
  echo

  echo "## 3. Python Diversity Audit"
  "$ENV/bin/python" - <<'PY'
import hashlib
import json
import math
from pathlib import Path

import numpy as np

VECTOR_DIR = Path("/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only/vector_features")
features = ["m2_mean", "m2_max", "m2_value_attention", "m2_projected_256"]
sample_limit = 5000
rng = np.random.default_rng(20260625)

errors = []
warnings = []

def add_error(msg):
    errors.append(msg)
    print("ERROR:", msg)

def add_warning(msg):
    warnings.append(msg)
    print("WARNING:", msg)

def row_hashes(arr):
    arr = np.ascontiguousarray(arr)
    return [hashlib.sha1(row.tobytes()).hexdigest() for row in arr]

def cosine_summary(x):
    x = x.astype(np.float32, copy=False)
    norms = np.linalg.norm(x, axis=1, keepdims=True)
    valid = norms[:, 0] > 0
    x = x[valid] / np.clip(norms[valid], 1e-12, None)
    if len(x) < 2:
        return {"sample_n": int(len(x)), "error": "too_few_valid_vectors"}
    sim = x @ x.T
    iu = np.triu_indices(sim.shape[0], k=1)
    vals = sim[iu]
    return {
        "sample_n": int(len(x)),
        "pair_count": int(vals.size),
        "cos_min": float(np.min(vals)),
        "cos_p01": float(np.quantile(vals, 0.01)),
        "cos_p05": float(np.quantile(vals, 0.05)),
        "cos_p50": float(np.quantile(vals, 0.50)),
        "cos_p95": float(np.quantile(vals, 0.95)),
        "cos_p99": float(np.quantile(vals, 0.99)),
        "cos_max": float(np.max(vals)),
        "frac_cos_gt_0_999": float(np.mean(vals > 0.999)),
        "frac_cos_gt_0_9999": float(np.mean(vals > 0.9999)),
    }

shards = sorted(VECTOR_DIR.glob("m2_vectors_part_*.npz"))
print("shard_count:", len(shards))
if not shards:
    add_error("no shard files found")

total_rows = 0
uid_seen = set()
feature_hash_sets = {f: set() for f in features}
feature_sum = {}
feature_sumsq = {}
feature_min = {}
feature_max = {}
feature_sample = {f: [] for f in features}
uid_sample = []

for si, p in enumerate(shards):
    with np.load(p, allow_pickle=False) as z:
        uids = [str(x) for x in z["uid"]]
        n = len(uids)
        total_rows += n
        uid_seen.update(uids)

        for f in features:
            arr = z[f].astype(np.float64)
            if f not in feature_sum:
                dim = arr.shape[1]
                feature_sum[f] = np.zeros(dim, dtype=np.float64)
                feature_sumsq[f] = np.zeros(dim, dtype=np.float64)
                feature_min[f] = np.full(dim, np.inf, dtype=np.float64)
                feature_max[f] = np.full(dim, -np.inf, dtype=np.float64)
            feature_sum[f] += arr.sum(axis=0)
            feature_sumsq[f] += (arr * arr).sum(axis=0)
            feature_min[f] = np.minimum(feature_min[f], arr.min(axis=0))
            feature_max[f] = np.maximum(feature_max[f], arr.max(axis=0))

            # Hash exact float32 rows, not float64 rows.
            arr32 = z[f].astype(np.float32, copy=False)
            feature_hash_sets[f].update(row_hashes(arr32))

            if len(feature_sample[f]) < sample_limit:
                remaining = sample_limit - len(feature_sample[f])
                take = min(remaining, n)
                idx = np.arange(n)
                if n > take:
                    idx = rng.choice(idx, size=take, replace=False)
                feature_sample[f].append(arr32[idx].copy())
        if len(uid_sample) < 20:
            uid_sample.extend(uids[: max(0, 20 - len(uid_sample))])

        if (si + 1) % 30 == 0:
            print(f"checked {si + 1}/{len(shards)} shards")

print()
print("## Basic Counts")
print("total_rows:", total_rows)
print("unique_uid_count:", len(uid_seen))
print("uid_duplicate_count:", total_rows - len(uid_seen))
print("uid_sample_first20:", uid_sample[:20])

if total_rows != 107731:
    add_warning(f"expected 107731 rows, observed {total_rows}")
if total_rows != len(uid_seen):
    add_error("UID duplicates detected")

print()
print("## Feature Diversity Summary")
summary = {}
for f in features:
    mean = feature_sum[f] / max(total_rows, 1)
    var = feature_sumsq[f] / max(total_rows, 1) - mean * mean
    var = np.maximum(var, 0)
    std = np.sqrt(var)
    value_range = feature_max[f] - feature_min[f]
    exact_unique = len(feature_hash_sets[f])
    sample_arr = np.concatenate(feature_sample[f], axis=0) if feature_sample[f] else np.zeros((0, 1), dtype=np.float32)
    cos = cosine_summary(sample_arr)
    zero_std_dims = int(np.sum(std < 1e-8))
    low_std_dims = int(np.sum(std < 1e-5))
    zero_range_dims = int(np.sum(value_range < 1e-8))

    summary[f] = {
        "shape_dim": int(mean.shape[0]),
        "exact_unique_vector_count": int(exact_unique),
        "exact_duplicate_vector_count": int(total_rows - exact_unique),
        "mean_of_dim_means": float(np.mean(mean)),
        "mean_dim_std": float(np.mean(std)),
        "median_dim_std": float(np.median(std)),
        "min_dim_std": float(np.min(std)),
        "max_dim_std": float(np.max(std)),
        "zero_std_dims_lt_1e_8": zero_std_dims,
        "low_std_dims_lt_1e_5": low_std_dims,
        "zero_range_dims_lt_1e_8": zero_range_dims,
        "global_min": float(np.min(feature_min[f])),
        "global_max": float(np.max(feature_max[f])),
        "cosine_sample": cos,
    }
    print(json.dumps({f: summary[f]}, indent=2, ensure_ascii=False))

    if exact_unique < max(1000, int(total_rows * 0.01)):
        add_error(f"{f} has very low exact unique vector count: {exact_unique}/{total_rows}")
    if float(np.mean(std)) < 1e-6:
        add_error(f"{f} mean_dim_std is near zero: {float(np.mean(std))}")
    if cos.get("frac_cos_gt_0_9999", 0.0) > 0.95:
        add_warning(f"{f} sample vectors are extremely similar: frac_cos_gt_0_9999={cos.get('frac_cos_gt_0_9999')}")

print()
print("## Final Status")
if errors:
    status = "FAIL"
elif warnings:
    status = "REVIEW_WARNINGS"
else:
    status = "PASS"
print("VECTOR_DIVERSITY_AUDIT_STATUS=" + status)
print("error_count:", len(errors))
print("warning_count:", len(warnings))
if errors:
    print("errors:")
    for e in errors:
        print(" -", e)
if warnings:
    print("warnings:")
    for w in warnings:
        print(" -", w)
PY
  echo

  echo "## 4. Final Boundary"
  echo "Read-only audit finished. Do not start 195,743-UID extraction until this report is reviewed."
} | tee "$REPORT"

echo
echo "REPORT_WRITTEN=$REPORT"
```

## 需要你最后回复我的内容

请把下面内容贴回来：

1. markdown 报告路径；
2. `VECTOR_DIVERSITY_AUDIT_STATUS`；
3. `error_count` 和 `warning_count`；
4. 对每个 feature 的：
   - `exact_unique_vector_count`
   - `exact_duplicate_vector_count`
   - `mean_dim_std`
   - `median_dim_std`
   - `zero_std_dims_lt_1e_8`
   - cosine sample 的 `cos_p50`、`cos_p95`、`cos_p99`、`frac_cos_gt_0_9999`
5. 如果有 warnings/errors，完整贴出。

如果审计是 `PASS`，下一步再提交完整 `195,743` 酶池 vector-only 提取；如果是 `REVIEW_WARNINGS` 或 `FAIL`，先不要补跑完整酶池。
