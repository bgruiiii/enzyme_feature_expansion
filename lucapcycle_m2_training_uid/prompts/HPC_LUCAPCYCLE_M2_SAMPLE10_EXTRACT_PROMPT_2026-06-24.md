# HPC LucaPCycle M2 10-UID Sample Extraction Prompt

Date: 2026-06-24

Copy this prompt to the HPC-side AI only after:

1. asset check passed;
2. compute-node smoke test passed.

---

你现在在 HPC 上帮我做 **LucaPCycle M2 的 10 条 UID 最小样例提取**。

这一步是第一次真正生成 M2，但只允许生成 10 条样例输出，用于验证 tokenization、checkpoint 加载、M2 tensor shape、pooling 和保存格式。**不要全量提取。**

## 已通过的前置检查

资产检查：

```text
ASSET_CHECK_STATUS=PASS_REQUIRED_FILES_PRESENT
Missing required file count: 0
```

计算节点 smoke test：

```text
torch_import: OK
torch_cuda_is_available: True
torch_cuda_device_count: 1
SMOKE_STATUS=PASS_SEQ_ENCODER_KEYS_PRESENT
match_count[seq_encoder]: 71
match_count[seq_pooler]: 3
match_count[seq_linear]: 2
```

## 重要边界

- 不要全量提取。
- 不要训练。
- 不要运行 `prediction_v2.py` 做分类预测。
- 不要加载 ESM/ESM-C/ESM2。
- 不要安装 `esm`、`fair-esm`、`deepspeed`、`tensorflow`。
- 不要修改 EnzymeCAGE 训练代码。
- 本次只允许生成 10 条 M2 样例输出和 markdown 报告。

M2 不需要 ESM。路线是：

```text
sequence -> BPE/subword tokens -> LucaPCycle seq_encoder -> M2
```

原论文 M1 是 ESM2-3B，但我们项目中用已有 HPC 侧 `ESMC.from_pretrained("esmc_600m")` / `ESM-C_600M` 序列特征替代 M1。本次不碰这些 ESM600M 文件。

## 已知路径

```text
WORK_ROOT=/public/home/acfbwjsi7s/LucaPCycle-3
CODE_ROOT=/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3
CKPT_ROOT=/public/home/acfbwjsi7s/LucaPCycle-3/TrainedCheckPoint
ENV=/public/home/acfbwjsi7s/envs/lucapcycle_m2
BIN_CKPT=/public/home/acfbwjsi7s/LucaPCycle-3/TrainedCheckPoint/models/extra_p_2_class_v3/protein/binary_class/lucaprot/seq_matrix/20240924203640/checkpoint-264284
BPE_CODES=/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/subword/extra_p/extra_p_50_codes_20000.txt
```

优先训练表路径：

```text
/public/home/acfbwjsi7s/bio_vector_full_run_2026-06-04/data/reaction_enzyme_microbe_training_clean_2026-06-01_LOCAL/tables/reaction_enzyme_pairs.csv
```

如果这个路径不存在，请只在以下目录中找 `reaction_enzyme_pairs.csv`：

```text
/public/home/acfbwjsi7s/bio_vector_full_run_2026-06-04
/public/home/acfbwjsi7s/LucaPCycle-3
/public/home/acfbwjsi7s
```

不要做全盘搜索。

## 样例选择规则

从 `reaction_enzyme_pairs.csv` 中读取 `UniprotID,sequence`：

1. 按 `UniprotID` 去重；
2. 过滤空序列；
3. 取前 8 条；
4. 再取序列长度最长的 2 条；
5. 合并去重，如果不足 10 条，再从剩余 UID 中补足到 10 条；
6. 保存为：

```text
$WORK_ROOT/m2_sample10/sample_uid_sequences_10.csv
```

## 输出要求

输出目录：

```text
$WORK_ROOT/m2_sample10/
```

至少生成：

```text
sample_uid_sequences_10.csv
m2_sample_vectors.npz
m2_sample_summary.json
m2_sample_token_matrices/<UID>.npz
lucapcycle_m2_sample10_report_<JOBID>.md
```

`m2_sample_vectors.npz` 必须包含：

```text
uid
sequence_sha256
sequence_length
bpe_token_count_without_special
token_count_with_special
m2_mean                  shape: (10, 1024)
m2_max                   shape: (10, 1024)
m2_value_attention       shape: (10, 1024)
m2_projected_256         shape: (10, 256)
```

每个 token matrix 文件必须包含：

```text
m2_token_matrix_fp16     shape: (token_count_with_special, 1024)
input_ids
attention_mask
```

注意：token matrix 可包含 `[CLS]` 和 `[SEP]`，但不能包含 padding。

## 技术实现要求

请创建一个临时 Python 脚本：

```text
$WORK_ROOT/m2_sample10/extract_lucapcycle_m2_sample10.py
```

脚本逻辑：

1. 加入 LucaPCycle 源码路径：

```python
sys.path.insert(0, CODE_ROOT)
sys.path.insert(0, os.path.join(CODE_ROOT, "src"))
```

2. 使用 LucaPCycle 的类：

```python
from common.model_config import LucaConfig
from lucaprot.models.lucaprot import LucaProt
```

3. 使用 LucaPCycle 训练 checkpoint 的 tokenizer：

```python
from transformers.models.bert.tokenization_bert import BertTokenizer
tokenizer = BertTokenizer.from_pretrained(os.path.join(BIN_CKPT, "tokenizer"), do_lower_case=False)
```

4. 使用 BPE：

```python
from subword_nmt.apply_bpe import BPE
bpe = BPE(open(BPE_CODES), merges=-1, separator="")
```

5. 初始化完整 `LucaProt`，因为我们还要提取 `seq_pooler` 和 `seq_linear`：

```python
from types import SimpleNamespace

config = LucaConfig.from_json_file(os.path.join(BIN_CKPT, "config.json"))
args = SimpleNamespace(
    input_type="seq_matrix",
    seq_pooling_type=config.seq_pooling_type,
    matrix_pooling_type=config.matrix_pooling_type,
)
model = LucaProt(config, args=args)
state_dict = torch.load(os.path.join(BIN_CKPT, "pytorch_model.bin"), map_location="cpu")
missing, unexpected = model.load_state_dict(state_dict, strict=True)
```

如果 `strict=True` 报错，停止并把错误写报告，不要自己改成不严格加载后继续。

6. 把模型放到 GPU/DCU：

```python
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
model.to(device)
model.eval()
```

7. 只调用 M2 相关模块，不调用完整分类预测：

```python
seq_outputs = model.seq_encoder(
    input_ids,
    attention_mask=attention_mask,
    token_type_ids=None,
    position_ids=None,
    output_attentions=False,
    output_hidden_states=False,
    return_dict=False,
)
m2 = seq_outputs[0]
pooled = model.seq_pooler(m2, mask=attention_mask)
projected = model.dropout(pooled)
for layer in model.seq_linear:
    projected = layer(projected)
```

8. mean/max 必须使用 `attention_mask`，不能让 padding 污染结果。

9. 保存前检查：

```text
no NaN
no Inf
m2 hidden dim == 1024
m2_mean shape == (10,1024)
m2_projected_256 shape == (10,256)
```

## 请运行的命令

请在 HPC 上执行下面这段命令。若分区名或 DCU 资源参数不适合当前集群，只允许调整 `#SBATCH --partition` 和 `#SBATCH --gres`。

```bash
set -u

WORK_ROOT="/public/home/acfbwjsi7s/LucaPCycle-3"
CODE_ROOT="/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3"
CKPT_ROOT="/public/home/acfbwjsi7s/LucaPCycle-3/TrainedCheckPoint"
ENV="/public/home/acfbwjsi7s/envs/lucapcycle_m2"
BIN_CKPT="$CKPT_ROOT/models/extra_p_2_class_v3/protein/binary_class/lucaprot/seq_matrix/20240924203640/checkpoint-264284"
BPE_CODES="$CODE_ROOT/subword/extra_p/extra_p_50_codes_20000.txt"
OUT_ROOT="$WORK_ROOT/m2_sample10"
JOB="$OUT_ROOT/lucapcycle_m2_sample10.sbatch"

mkdir -p "$OUT_ROOT"

cat > "$OUT_ROOT/extract_lucapcycle_m2_sample10.py" <<'PY'
import argparse
import hashlib
import json
import os
import sys
from pathlib import Path
from types import SimpleNamespace

import numpy as np
import pandas as pd
import torch
from subword_nmt.apply_bpe import BPE
from transformers.models.bert.tokenization_bert import BertTokenizer


def sha256_text(s):
    return hashlib.sha256(str(s).encode("utf-8")).hexdigest()


def find_training_table(candidates):
    for p in candidates:
        if p and Path(p).is_file():
            return str(Path(p))
    raise FileNotFoundError("No reaction_enzyme_pairs.csv found in candidate paths: " + repr(candidates))


def build_sample(input_csv, out_csv):
    df = pd.read_csv(input_csv)
    required = {"UniprotID", "sequence"}
    if not required.issubset(df.columns):
        raise ValueError(f"Input table missing {required}; columns={df.columns.tolist()}")
    df = df[["UniprotID", "sequence"]].dropna()
    df["UniprotID"] = df["UniprotID"].astype(str)
    df["sequence"] = df["sequence"].astype(str)
    df = df[df["sequence"].str.len() > 0].drop_duplicates("UniprotID")
    df["sequence_length"] = df["sequence"].str.len()

    first8 = df.head(8)
    longest2 = df.sort_values("sequence_length", ascending=False).head(2)
    sample = pd.concat([first8, longest2], ignore_index=True).drop_duplicates("UniprotID")
    if len(sample) < 10:
        extra = df[~df["UniprotID"].isin(sample["UniprotID"])].head(10 - len(sample))
        sample = pd.concat([sample, extra], ignore_index=True)
    sample = sample.head(10)
    if len(sample) != 10:
        raise RuntimeError(f"Expected 10 sample UIDs, got {len(sample)}")
    sample.to_csv(out_csv, index=False)
    return sample


def encode_sequence(seq, bpe, tokenizer, seq_max_length, cls_id=2, sep_id=3):
    pieces = bpe.process_line(seq.upper()).split(" ")
    token_text = " ".join(pieces)
    enc = tokenizer.encode_plus(
        token_text,
        None,
        add_special_tokens=False,
        max_length=seq_max_length,
        truncation=True,
    )
    core_ids = enc["input_ids"]
    input_ids = [cls_id] + core_ids + [sep_id]
    attention_mask = [1] * len(input_ids)
    return input_ids, attention_mask, len(core_ids)


def pad_batch(encoded, pad_id=0):
    max_len = max(len(x[0]) for x in encoded)
    ids = np.full((len(encoded), max_len), pad_id, dtype=np.int64)
    mask = np.zeros((len(encoded), max_len), dtype=np.int64)
    for i, (input_ids, attention_mask, _) in enumerate(encoded):
        ids[i, :len(input_ids)] = np.asarray(input_ids, dtype=np.int64)
        mask[i, :len(attention_mask)] = np.asarray(attention_mask, dtype=np.int64)
    return torch.from_numpy(ids), torch.from_numpy(mask)


def masked_mean_max(m2, mask):
    mask_f = mask.unsqueeze(-1).to(dtype=m2.dtype)
    summed = (m2 * mask_f).sum(dim=1)
    denom = mask_f.sum(dim=1).clamp(min=1.0)
    mean = summed / denom
    very_negative = torch.finfo(m2.dtype).min / 4
    maxed = m2.masked_fill(mask.unsqueeze(-1) == 0, very_negative).max(dim=1).values
    return mean, maxed


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--code_root", required=True)
    parser.add_argument("--bin_ckpt", required=True)
    parser.add_argument("--bpe_codes", required=True)
    parser.add_argument("--out_root", required=True)
    parser.add_argument("--input_csv", default="")
    parser.add_argument("--candidate_csv", action="append", default=[])
    parser.add_argument("--batch_size", type=int, default=2)
    args = parser.parse_args()

    code_root = Path(args.code_root)
    bin_ckpt = Path(args.bin_ckpt)
    out_root = Path(args.out_root)
    out_root.mkdir(parents=True, exist_ok=True)
    token_dir = out_root / "m2_sample_token_matrices"
    token_dir.mkdir(parents=True, exist_ok=True)

    sys.path.insert(0, str(code_root))
    sys.path.insert(0, str(code_root / "src"))

    from common.model_config import LucaConfig
    from lucaprot.models.lucaprot import LucaProt

    input_csv = find_training_table([args.input_csv] + args.candidate_csv)
    sample_csv = out_root / "sample_uid_sequences_10.csv"
    sample = build_sample(input_csv, sample_csv)

    config = LucaConfig.from_json_file(str(bin_ckpt / "config.json"))
    model_args = SimpleNamespace(
        input_type="seq_matrix",
        seq_pooling_type=config.seq_pooling_type,
        matrix_pooling_type=config.matrix_pooling_type,
    )
    model = LucaProt(config, args=model_args)
    state_dict = torch.load(str(bin_ckpt / "pytorch_model.bin"), map_location="cpu")
    model.load_state_dict(state_dict, strict=True)

    tokenizer = BertTokenizer.from_pretrained(str(bin_ckpt / "tokenizer"), do_lower_case=False)
    with open(args.bpe_codes, "r", encoding="utf-8") as f:
        bpe = BPE(f, merges=-1, separator="")

    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    model.to(device)
    model.eval()

    uids = sample["UniprotID"].astype(str).tolist()
    seqs = sample["sequence"].astype(str).tolist()
    seq_lengths = np.asarray([len(s) for s in seqs], dtype=np.int64)
    seq_hashes = np.asarray([sha256_text(s) for s in seqs], dtype=object)

    encoded = [encode_sequence(s, bpe, tokenizer, config.seq_max_length) for s in seqs]
    bpe_counts = np.asarray([x[2] for x in encoded], dtype=np.int64)
    token_counts = np.asarray([len(x[0]) for x in encoded], dtype=np.int64)

    all_mean = []
    all_max = []
    all_pooled = []
    all_projected = []

    with torch.no_grad():
        for start in range(0, len(encoded), args.batch_size):
            batch_encoded = encoded[start:start + args.batch_size]
            input_ids, attention_mask = pad_batch(batch_encoded, pad_id=0)
            input_ids = input_ids.to(device)
            attention_mask = attention_mask.to(device)

            seq_outputs = model.seq_encoder(
                input_ids,
                attention_mask=attention_mask,
                token_type_ids=None,
                position_ids=None,
                output_attentions=False,
                output_hidden_states=False,
                return_dict=False,
            )
            m2 = seq_outputs[0]
            mean, maxed = masked_mean_max(m2, attention_mask)
            pooled = model.seq_pooler(m2, mask=attention_mask)
            projected = model.dropout(pooled)
            for layer in model.seq_linear:
                projected = layer(projected)

            all_mean.append(mean.detach().cpu().numpy())
            all_max.append(maxed.detach().cpu().numpy())
            all_pooled.append(pooled.detach().cpu().numpy())
            all_projected.append(projected.detach().cpu().numpy())

            m2_cpu = m2.detach().cpu().numpy()
            ids_cpu = input_ids.detach().cpu().numpy()
            mask_cpu = attention_mask.detach().cpu().numpy()
            for j in range(m2_cpu.shape[0]):
                global_idx = start + j
                keep = mask_cpu[j].astype(bool)
                uid = uids[global_idx]
                np.savez_compressed(
                    token_dir / f"{uid}.npz",
                    m2_token_matrix_fp16=m2_cpu[j, keep, :].astype(np.float16),
                    input_ids=ids_cpu[j, keep].astype(np.int64),
                    attention_mask=mask_cpu[j, keep].astype(np.int64),
                )

    m2_mean = np.concatenate(all_mean, axis=0)
    m2_max = np.concatenate(all_max, axis=0)
    m2_value_attention = np.concatenate(all_pooled, axis=0)
    m2_projected_256 = np.concatenate(all_projected, axis=0)

    checks = {
        "sample_count": len(uids),
        "m2_mean_shape": list(m2_mean.shape),
        "m2_max_shape": list(m2_max.shape),
        "m2_value_attention_shape": list(m2_value_attention.shape),
        "m2_projected_256_shape": list(m2_projected_256.shape),
        "token_count_min": int(token_counts.min()),
        "token_count_max": int(token_counts.max()),
        "bpe_token_count_min_without_special": int(bpe_counts.min()),
        "bpe_token_count_max_without_special": int(bpe_counts.max()),
        "nan_count": int(
            np.isnan(m2_mean).sum()
            + np.isnan(m2_max).sum()
            + np.isnan(m2_value_attention).sum()
            + np.isnan(m2_projected_256).sum()
        ),
        "inf_count": int(
            np.isinf(m2_mean).sum()
            + np.isinf(m2_max).sum()
            + np.isinf(m2_value_attention).sum()
            + np.isinf(m2_projected_256).sum()
        ),
        "input_csv": input_csv,
        "sample_csv": str(sample_csv),
        "device": str(device),
        "torch_cuda_is_available": bool(torch.cuda.is_available()),
        "torch_cuda_device_count": int(torch.cuda.device_count()) if torch.cuda.is_available() else 0,
    }

    ok = (
        checks["sample_count"] == 10
        and checks["m2_mean_shape"] == [10, 1024]
        and checks["m2_max_shape"] == [10, 1024]
        and checks["m2_value_attention_shape"] == [10, 1024]
        and checks["m2_projected_256_shape"] == [10, 256]
        and checks["nan_count"] == 0
        and checks["inf_count"] == 0
    )
    checks["SAMPLE10_STATUS"] = "PASS" if ok else "FAIL"

    np.savez_compressed(
        out_root / "m2_sample_vectors.npz",
        uid=np.asarray(uids, dtype=object),
        sequence_sha256=seq_hashes,
        sequence_length=seq_lengths,
        bpe_token_count_without_special=bpe_counts,
        token_count_with_special=token_counts,
        m2_mean=m2_mean.astype(np.float32),
        m2_max=m2_max.astype(np.float32),
        m2_value_attention=m2_value_attention.astype(np.float32),
        m2_projected_256=m2_projected_256.astype(np.float32),
    )
    with open(out_root / "m2_sample_summary.json", "w", encoding="utf-8") as f:
        json.dump(checks, f, indent=2, ensure_ascii=False)

    print(json.dumps(checks, indent=2, ensure_ascii=False))
    if not ok:
        raise SystemExit(3)


if __name__ == "__main__":
    main()
PY

cat > "$JOB" <<EOF
#!/bin/bash
#SBATCH --job-name=lucap_m2_s10
#SBATCH --partition=dcu
#SBATCH --nodes=1
#SBATCH --gres=dcu:1
#SBATCH --time=00:30:00
#SBATCH --output=$OUT_ROOT/lucapcycle_m2_sample10_%j.out
#SBATCH --error=$OUT_ROOT/lucapcycle_m2_sample10_%j.err

set -u

REPORT="$OUT_ROOT/lucapcycle_m2_sample10_report_\${SLURM_JOB_ID}.md"
SCRIPT="$OUT_ROOT/extract_lucapcycle_m2_sample10.py"
CODE_ROOT="$CODE_ROOT"
BIN_CKPT="$BIN_CKPT"
BPE_CODES="$BPE_CODES"
OUT_ROOT="$OUT_ROOT"

{
  echo "# LucaPCycle M2 Sample10 Extraction Report"
  echo
  echo "Date: \$(date)"
  echo "Host: \$(hostname)"
  echo "SLURM_JOB_ID: \${SLURM_JOB_ID:-NA}"
  echo

  echo "## 1. Boundary"
  echo
  echo "Only 10 UID sample extraction is allowed in this job."
  echo "No ESM/ESM-C/ESM2 model is loaded."
  echo "No full extraction or training is run."
  echo

  echo "## 2. Environment"
  echo
  module load compiler/rocm/dtk-23.10
  module list 2>&1 || true
  source "$ENV/bin/activate"
  echo "python: \$(which python)"
  python --version
  python - <<'PY'
import torch
print("torch_version:", torch.__version__)
print("torch_cuda_is_available:", torch.cuda.is_available())
print("torch_cuda_device_count:", torch.cuda.device_count() if torch.cuda.is_available() else 0)
PY
  echo

  echo "## 3. Input Table Search"
  echo
  CANDIDATE_1="/public/home/acfbwjsi7s/bio_vector_full_run_2026-06-04/data/reaction_enzyme_microbe_training_clean_2026-06-01_LOCAL/tables/reaction_enzyme_pairs.csv"
  CANDIDATE_2=\$(find /public/home/acfbwjsi7s/bio_vector_full_run_2026-06-04 -path "*/tables/reaction_enzyme_pairs.csv" -type f 2>/dev/null | head -1 || true)
  CANDIDATE_3=\$(find /public/home/acfbwjsi7s/LucaPCycle-3 -name "reaction_enzyme_pairs.csv" -type f 2>/dev/null | head -1 || true)
  echo "CANDIDATE_1=\$CANDIDATE_1"
  echo "CANDIDATE_2=\$CANDIDATE_2"
  echo "CANDIDATE_3=\$CANDIDATE_3"
  echo

  echo "## 4. Run Sample Extraction"
  echo
  python "\$SCRIPT" \\
    --code_root "\$CODE_ROOT" \\
    --bin_ckpt "\$BIN_CKPT" \\
    --bpe_codes "\$BPE_CODES" \\
    --out_root "\$OUT_ROOT" \\
    --input_csv "\$CANDIDATE_1" \\
    --candidate_csv "\$CANDIDATE_2" \\
    --candidate_csv "\$CANDIDATE_3" \\
    --batch_size 2
  echo

  echo "## 5. Output Files"
  echo
  find "\$OUT_ROOT" -maxdepth 2 -type f | sort
  echo

  echo "## 6. Summary JSON"
  echo
  cat "\$OUT_ROOT/m2_sample_summary.json"
  echo

  echo "## 7. Final Boundary"
  echo
  echo "No full M2 extraction was run."
  echo "No ESM/ESM-C/ESM2 model was loaded."
  echo "Wait for local review before the next step."
} | tee "\$REPORT"

echo "REPORT_WRITTEN=\$REPORT"
EOF

echo "SBATCH_SCRIPT=$JOB"
sbatch "$JOB"
```

## 需要你最后回复我的内容

请等 SLURM 作业结束后，把下面内容贴回来：

1. markdown 报告路径；
2. SLURM job id；
3. `.out` 和 `.err` 文件路径；
4. `SAMPLE10_STATUS`；
5. `m2_mean_shape`、`m2_max_shape`、`m2_value_attention_shape`、`m2_projected_256_shape`；
6. token count min/max；
7. `nan_count`、`inf_count`；
8. 输出目录文件列表；
9. 如果 `.err` 非空，贴出前 120 行。

不要继续做全量 M2 提取，等我审核样例报告。
