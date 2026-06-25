# HPC LucaPCycle M2 Sample10 Output Audit Prompt

Date: 2026-06-25

Copy this prompt to the HPC-side AI after the 10-UID sample extraction report
returns `SAMPLE10_STATUS=PASS`.

---

你现在在 HPC 上帮我做 **LucaPCycle M2 10 条样例输出文件审计**。

这一步只读取已经生成的样例输出，检查 `.npz` 内部 key、shape、dtype、NaN/Inf、attention mask、UID 覆盖和 token matrix 文件数量。**不要重新提取、不要训练、不要加载 ESM、不要跑全量。**

## 已知样例输出目录

```text
OUT_ROOT=/public/home/acfbwjsi7s/LucaPCycle-3/m2_sample10
```

应该存在：

```text
$OUT_ROOT/sample_uid_sequences_10.csv
$OUT_ROOT/m2_sample_vectors.npz
$OUT_ROOT/m2_sample_summary.json
$OUT_ROOT/m2_sample_token_matrices/*.npz
```

## 审计重点

1. `sample_uid_sequences_10.csv` 是否正好 10 行、10 个唯一 `UniprotID`。
2. `m2_sample_vectors.npz` 是否包含：

```text
uid
sequence_sha256
sequence_length
bpe_token_count_without_special
token_count_with_special
m2_mean
m2_max
m2_value_attention
m2_projected_256
```

3. vector shapes 是否为：

```text
m2_mean: (10, 1024)
m2_max: (10, 1024)
m2_value_attention: (10, 1024)
m2_projected_256: (10, 256)
```

4. vector dtype 是否为 float32。
5. 所有 vector 是否无 NaN/Inf。
6. token matrix 文件是否正好 10 个，且 UID 与 sample CSV 一一对应。
7. 每个 token matrix `.npz` 是否包含：

```text
m2_token_matrix_fp16
input_ids
attention_mask
```

8. 每个 token matrix 是否满足：

```text
m2_token_matrix_fp16.shape == (len(input_ids), 1024)
len(input_ids) == len(attention_mask)
attention_mask 全部为 1
m2_token_matrix_fp16 dtype == float16
无 NaN/Inf
```

9. `token_count_with_special` 是否等于对应 token matrix 的 token 数。
10. 报告之前脚本中出现过 `Filtering out non-M2 loss keys: ['loss_fct.pos_weight']`。请在报告里说明：这是 checkpoint 里的 loss 权重，不是 M2 encoder/pooler/linear 权重；全量脚本后续只能白名单过滤这个 key，不能过滤其他模型权重。

## 请运行的命令

```bash
set -u

OUT_ROOT="/public/home/acfbwjsi7s/LucaPCycle-3/m2_sample10"
REPORT="$OUT_ROOT/lucapcycle_m2_sample10_output_audit_$(date +%Y%m%d_%H%M%S).md"
ENV="/public/home/acfbwjsi7s/envs/lucapcycle_m2"

{
  echo "# LucaPCycle M2 Sample10 Output Audit"
  echo
  echo "Date: $(date)"
  echo "Host: $(hostname)"
  echo "OUT_ROOT=$OUT_ROOT"
  echo

  echo "## 1. File Listing"
  echo
  find "$OUT_ROOT" -maxdepth 2 -type f | sort
  echo

  echo "## 2. Output Audit"
  echo
  "$ENV/bin/python" - <<'PY'
import json
from pathlib import Path

import numpy as np
import pandas as pd

out = Path("/public/home/acfbwjsi7s/LucaPCycle-3/m2_sample10")
sample_csv = out / "sample_uid_sequences_10.csv"
vectors_npz = out / "m2_sample_vectors.npz"
summary_json = out / "m2_sample_summary.json"
token_dir = out / "m2_sample_token_matrices"

errors = []

def fail(msg):
    errors.append(msg)
    print("ERROR:", msg)

print("sample_csv:", sample_csv)
print("vectors_npz:", vectors_npz)
print("summary_json:", summary_json)
print("token_dir:", token_dir)

df = pd.read_csv(sample_csv)
print("sample_rows:", len(df))
print("sample_unique_uids:", df["UniprotID"].nunique() if "UniprotID" in df.columns else "missing_column")
if len(df) != 10:
    fail(f"sample_csv row count is {len(df)}, expected 10")
if "UniprotID" not in df.columns:
    fail("sample_csv missing UniprotID")
if "sequence" not in df.columns:
    fail("sample_csv missing sequence")

uids = df["UniprotID"].astype(str).tolist()

vec = np.load(vectors_npz, allow_pickle=True)
required_keys = [
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
print("vector_keys:", sorted(vec.files))
for k in required_keys:
    if k not in vec.files:
        fail(f"m2_sample_vectors.npz missing key {k}")

expected_shapes = {
    "m2_mean": (10, 1024),
    "m2_max": (10, 1024),
    "m2_value_attention": (10, 1024),
    "m2_projected_256": (10, 256),
}
for k, shape in expected_shapes.items():
    if k in vec.files:
        arr = vec[k]
        print(f"{k}: shape={arr.shape}, dtype={arr.dtype}, nan={np.isnan(arr).sum()}, inf={np.isinf(arr).sum()}")
        if tuple(arr.shape) != shape:
            fail(f"{k} shape {arr.shape}, expected {shape}")
        if arr.dtype != np.float32:
            fail(f"{k} dtype {arr.dtype}, expected float32")
        if np.isnan(arr).any():
            fail(f"{k} contains NaN")
        if np.isinf(arr).any():
            fail(f"{k} contains Inf")

vec_uids = [str(x) for x in vec["uid"].tolist()] if "uid" in vec.files else []
print("vector_uid_count:", len(vec_uids))
print("vector_uids:", vec_uids)
if vec_uids != uids:
    fail("vector UID order does not match sample CSV")

token_counts = vec["token_count_with_special"].astype(int) if "token_count_with_special" in vec.files else None

token_files = sorted(token_dir.glob("*.npz"))
print("token_file_count:", len(token_files))
print("token_files:", [p.name for p in token_files])
if len(token_files) != 10:
    fail(f"token matrix file count {len(token_files)}, expected 10")

token_uid_set = {p.stem for p in token_files}
if token_uid_set != set(uids):
    fail("token matrix UID set does not match sample CSV UIDs")

for i, uid in enumerate(uids):
    p = token_dir / f"{uid}.npz"
    if not p.exists():
        fail(f"missing token matrix file for {uid}")
        continue
    d = np.load(p)
    print(f"token_matrix[{uid}] keys={sorted(d.files)}")
    for k in ["m2_token_matrix_fp16", "input_ids", "attention_mask"]:
        if k not in d.files:
            fail(f"{uid} token file missing key {k}")
    if "m2_token_matrix_fp16" not in d.files:
        continue
    mat = d["m2_token_matrix_fp16"]
    ids = d["input_ids"]
    mask = d["attention_mask"]
    print(f"  shape={mat.shape}, dtype={mat.dtype}, ids={ids.shape}, mask_sum={int(mask.sum())}, nan={np.isnan(mat).sum()}, inf={np.isinf(mat).sum()}")
    if mat.ndim != 2 or mat.shape[1] != 1024:
        fail(f"{uid} token matrix shape {mat.shape}, expected (*,1024)")
    if mat.dtype != np.float16:
        fail(f"{uid} token matrix dtype {mat.dtype}, expected float16")
    if len(ids) != mat.shape[0]:
        fail(f"{uid} len(input_ids) != matrix rows")
    if len(mask) != mat.shape[0]:
        fail(f"{uid} len(attention_mask) != matrix rows")
    if not np.all(mask == 1):
        fail(f"{uid} attention_mask contains non-1 values after padding removal")
    if token_counts is not None and int(token_counts[i]) != mat.shape[0]:
        fail(f"{uid} token_count_with_special {int(token_counts[i])} != matrix rows {mat.shape[0]}")
    if np.isnan(mat).any():
        fail(f"{uid} token matrix contains NaN")
    if np.isinf(mat).any():
        fail(f"{uid} token matrix contains Inf")

print()
print("loss_fct.pos_weight note:")
print("The sample extraction reported filtering ['loss_fct.pos_weight']; this is a loss-function weight, not an M2 encoder/pooler/linear model weight. Future full extraction may whitelist-filter only this exact key and must fail on any other unexpected key.")
print()
if errors:
    print("OUTPUT_AUDIT_STATUS=FAIL")
    print("error_count:", len(errors))
else:
    print("OUTPUT_AUDIT_STATUS=PASS")
    print("error_count: 0")
PY
} | tee "$REPORT"

echo "REPORT_WRITTEN=$REPORT"
```

## 需要你最后回复我的内容

请把以下内容贴回来：

1. markdown 报告路径；
2. `OUTPUT_AUDIT_STATUS`；
3. `error_count`；
4. vector keys 和 shapes；
5. token matrix file count；
6. 是否确认 `loss_fct.pos_weight` 仅作为白名单过滤项。

不要继续做全量提取，等我审核这份输出审计报告。
