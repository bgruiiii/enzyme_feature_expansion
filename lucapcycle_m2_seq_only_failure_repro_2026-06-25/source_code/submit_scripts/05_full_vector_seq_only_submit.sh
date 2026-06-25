set -u

WORK_ROOT="/public/home/acfbwjsi7s/LucaPCycle-3"
CODE_ROOT="/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3"
CKPT_ROOT="/public/home/acfbwjsi7s/LucaPCycle-3/TrainedCheckPoint"
ENV="/public/home/acfbwjsi7s/envs/lucapcycle_m2"
BIN_CKPT="$CKPT_ROOT/models/extra_p_2_class_v3/protein/binary_class/lucaprot/seq_matrix/20240924203640/checkpoint-264284"
BPE_CODES="$CODE_ROOT/subword/extra_p/extra_p_50_codes_20000.txt"
OUT_ROOT="/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only"
SCRIPT="$OUT_ROOT/extract_lucapcycle_m2_full_vector_only.py"
JOB="$OUT_ROOT/lucapcycle_m2_full_vector_only.sbatch"

mkdir -p "$OUT_ROOT/vector_features" "$OUT_ROOT/logs"

cat > "$SCRIPT" <<'PY'
import argparse
import csv
import hashlib
import json
import os
import sys
import time
from pathlib import Path
from types import SimpleNamespace

import numpy as np
import pandas as pd
import torch
from subword_nmt.apply_bpe import BPE
from transformers.models.bert.tokenization_bert import BertTokenizer


def now():
    return time.strftime("%Y-%m-%d %H:%M:%S")


def sha256_text(s):
    return hashlib.sha256(str(s).encode("utf-8")).hexdigest()


def find_training_table(candidates):
    for p in candidates:
        if p and Path(p).is_file():
            return str(Path(p))
    raise FileNotFoundError("No reaction_enzyme_pairs.csv found in candidate paths: " + repr(candidates))


def load_input_table(input_csv, out_manifest):
    df = pd.read_csv(input_csv)
    required = {"UniprotID", "sequence"}
    if not required.issubset(df.columns):
        raise ValueError(f"Input table missing {required}; columns={df.columns.tolist()}")
    df = df[["UniprotID", "sequence"]].dropna()
    df["UniprotID"] = df["UniprotID"].astype(str)
    df["sequence"] = df["sequence"].astype(str)
    df = df[df["sequence"].str.len() > 0].drop_duplicates("UniprotID")
    df["sequence_length"] = df["sequence"].str.len()
    df["sequence_sha256"] = df["sequence"].map(sha256_text)
    df.to_csv(out_manifest, index=False)
    return df


def load_completed_uids(uid_to_shard_path):
    if not uid_to_shard_path.exists():
        return set()
    done = set()
    with uid_to_shard_path.open("r", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            uid = row.get("uid")
            if uid:
                done.add(uid)
    return done


def next_shard_index(vector_dir):
    max_idx = -1
    for p in vector_dir.glob("m2_vectors_part_*.npz"):
        stem = p.stem
        try:
            idx = int(stem.split("_")[-1])
            max_idx = max(max_idx, idx)
        except Exception:
            continue
    return max_idx + 1


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


def append_failed(path, rows):
    exists = path.exists()
    with path.open("a", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=["uid", "sequence_length", "error"])
        if not exists:
            writer.writeheader()
        for row in rows:
            writer.writerow(row)


def append_uid_manifest(path, rows):
    exists = path.exists()
    with path.open("a", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(
            f,
            fieldnames=[
                "uid",
                "shard_file",
                "row_in_shard",
                "sequence_sha256",
                "sequence_length",
                "bpe_token_count_without_special",
                "token_count_with_special",
            ],
        )
        if not exists:
            writer.writeheader()
        for row in rows:
            writer.writerow(row)


def write_shard(vector_dir, shard_idx, buffer, uid_manifest_path):
    shard_name = f"m2_vectors_part_{shard_idx:06d}.npz"
    shard_path = vector_dir / shard_name
    if shard_path.exists():
        raise FileExistsError(f"Refusing to overwrite existing shard: {shard_path}")

    uids = [x["uid"] for x in buffer]
    sequence_sha256 = [x["sequence_sha256"] for x in buffer]
    sequence_length = np.asarray([x["sequence_length"] for x in buffer], dtype=np.int64)
    bpe_counts = np.asarray([x["bpe_token_count_without_special"] for x in buffer], dtype=np.int64)
    token_counts = np.asarray([x["token_count_with_special"] for x in buffer], dtype=np.int64)
    m2_mean = np.stack([x["m2_mean"] for x in buffer]).astype(np.float32)
    m2_max = np.stack([x["m2_max"] for x in buffer]).astype(np.float32)
    m2_value_attention = np.stack([x["m2_value_attention"] for x in buffer]).astype(np.float32)
    m2_projected_256 = np.stack([x["m2_projected_256"] for x in buffer]).astype(np.float32)

    checks = [
        ("m2_mean", m2_mean, (len(buffer), 1024)),
        ("m2_max", m2_max, (len(buffer), 1024)),
        ("m2_value_attention", m2_value_attention, (len(buffer), 1024)),
        ("m2_projected_256", m2_projected_256, (len(buffer), 256)),
    ]
    for name, arr, shape in checks:
        if arr.shape != shape:
            raise RuntimeError(f"{name} shape {arr.shape}, expected {shape}")
        if np.isnan(arr).any():
            raise RuntimeError(f"{name} contains NaN")
        if np.isinf(arr).any():
            raise RuntimeError(f"{name} contains Inf")

    tmp_path = shard_path.with_suffix(".npz.tmp")
    np.savez_compressed(
        tmp_path,
        uid=np.asarray(uids, dtype=str),
        sequence_sha256=np.asarray(sequence_sha256, dtype=str),
        sequence_length=sequence_length,
        bpe_token_count_without_special=bpe_counts,
        token_count_with_special=token_counts,
        m2_mean=m2_mean,
        m2_max=m2_max,
        m2_value_attention=m2_value_attention,
        m2_projected_256=m2_projected_256,
    )
    # np.savez_compressed appends .npz if the provided path does not end with .npz.
    auto_npz = Path(str(tmp_path) + ".npz")
    if auto_npz.exists():
        auto_npz.rename(shard_path)
    else:
        tmp_path.rename(shard_path)

    manifest_rows = []
    for i, x in enumerate(buffer):
        manifest_rows.append({
            "uid": x["uid"],
            "shard_file": shard_name,
            "row_in_shard": i,
            "sequence_sha256": x["sequence_sha256"],
            "sequence_length": x["sequence_length"],
            "bpe_token_count_without_special": x["bpe_token_count_without_special"],
            "token_count_with_special": x["token_count_with_special"],
        })
    append_uid_manifest(uid_manifest_path, manifest_rows)
    return shard_path


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--code_root", required=True)
    parser.add_argument("--bin_ckpt", required=True)
    parser.add_argument("--bpe_codes", required=True)
    parser.add_argument("--out_root", required=True)
    parser.add_argument("--input_csv", default="")
    parser.add_argument("--candidate_csv", action="append", default=[])
    parser.add_argument("--batch_size", type=int, default=4)
    parser.add_argument("--shard_size", type=int, default=1000)
    parser.add_argument("--max_uids", type=int, default=0, help="0 means all")
    args = parser.parse_args()

    code_root = Path(args.code_root)
    bin_ckpt = Path(args.bin_ckpt)
    out_root = Path(args.out_root)
    vector_dir = out_root / "vector_features"
    out_root.mkdir(parents=True, exist_ok=True)
    vector_dir.mkdir(parents=True, exist_ok=True)

    uid_manifest_path = out_root / "uid_to_shard.csv"
    failed_path = out_root / "failed_uids.csv"
    input_manifest_path = out_root / "input_uid_sequence_manifest.csv"
    audit_summary_path = out_root / "audit_summary.json"

    sys.path.insert(0, str(code_root))
    sys.path.insert(0, str(code_root / "src"))

    from common.model_config import LucaConfig
    from lucaprot.models.lucaprot import LucaProt

    input_csv = find_training_table([args.input_csv] + args.candidate_csv)
    df = load_input_table(input_csv, input_manifest_path)
    if args.max_uids and args.max_uids > 0:
        df = df.head(args.max_uids).copy()

    completed = load_completed_uids(uid_manifest_path)
    todo = df[~df["UniprotID"].isin(completed)].copy()

    print(f"[{now()}] input_csv={input_csv}")
    print(f"[{now()}] total_unique_input={len(df)}")
    print(f"[{now()}] already_completed={len(completed)}")
    print(f"[{now()}] todo={len(todo)}")

    config = LucaConfig.from_json_file(str(bin_ckpt / "config.json"))
    model_args = SimpleNamespace(
        input_type="seq_matrix",
        seq_pooling_type=config.seq_pooling_type,
        matrix_pooling_type=config.matrix_pooling_type,
    )
    model = LucaProt(config, args=model_args)
    state_dict = torch.load(str(bin_ckpt / "pytorch_model.bin"), map_location="cpu")
    allowed_filter = {"loss_fct.pos_weight"}
    filtered = []
    for k in list(state_dict.keys()):
        if k in allowed_filter:
            filtered.append(k)
            state_dict.pop(k)
    unexpected_filtered = [k for k in filtered if k not in allowed_filter]
    if unexpected_filtered:
        raise RuntimeError(f"Unexpected filtered keys: {unexpected_filtered}")
    print(f"[{now()}] filtered_allowed_keys={filtered}")
    missing, unexpected = model.load_state_dict(state_dict, strict=True)
    if missing or unexpected:
        raise RuntimeError(f"load_state_dict not clean: missing={missing}, unexpected={unexpected}")

    tokenizer = BertTokenizer.from_pretrained(str(bin_ckpt / "tokenizer"), do_lower_case=False)
    with open(args.bpe_codes, "r", encoding="utf-8") as f:
        bpe = BPE(f, merges=-1, separator="")

    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    if device.type != "cuda":
        raise RuntimeError("CUDA/DCU device is not available on this compute node")
    model.to(device)
    model.eval()

    buffer = []
    failed_rows = []
    shard_idx = next_shard_index(vector_dir)
    processed_new = 0
    start_time = time.time()

    records = todo.to_dict("records")
    with torch.no_grad():
        for start in range(0, len(records), args.batch_size):
            batch_records = records[start:start + args.batch_size]
            encoded = []
            valid_records = []
            for r in batch_records:
                uid = str(r["UniprotID"])
                seq = str(r["sequence"])
                try:
                    encoded.append(encode_sequence(seq, bpe, tokenizer, config.seq_max_length))
                    valid_records.append(r)
                except Exception as exc:
                    failed_rows.append({"uid": uid, "sequence_length": len(seq), "error": f"encode_error: {repr(exc)}"})
            if not valid_records:
                continue

            try:
                input_ids, attention_mask = pad_batch(encoded, pad_id=0)
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

                mean_np = mean.detach().cpu().numpy()
                max_np = maxed.detach().cpu().numpy()
                pooled_np = pooled.detach().cpu().numpy()
                projected_np = projected.detach().cpu().numpy()

                for j, r in enumerate(valid_records):
                    uid = str(r["UniprotID"])
                    seq = str(r["sequence"])
                    buffer.append({
                        "uid": uid,
                        "sequence_sha256": sha256_text(seq),
                        "sequence_length": len(seq),
                        "bpe_token_count_without_special": int(encoded[j][2]),
                        "token_count_with_special": int(len(encoded[j][0])),
                        "m2_mean": mean_np[j].astype(np.float32),
                        "m2_max": max_np[j].astype(np.float32),
                        "m2_value_attention": pooled_np[j].astype(np.float32),
                        "m2_projected_256": projected_np[j].astype(np.float32),
                    })
                    processed_new += 1

                if len(buffer) >= args.shard_size:
                    shard_path = write_shard(vector_dir, shard_idx, buffer, uid_manifest_path)
                    print(f"[{now()}] wrote_shard={shard_path} rows={len(buffer)} processed_new={processed_new}")
                    shard_idx += 1
                    buffer = []
                    if failed_rows:
                        append_failed(failed_path, failed_rows)
                        failed_rows = []

            except Exception as exc:
                for r in valid_records:
                    failed_rows.append({
                        "uid": str(r["UniprotID"]),
                        "sequence_length": len(str(r["sequence"])),
                        "error": f"batch_error: {repr(exc)}",
                    })
                print(f"[{now()}] batch_error start={start}: {repr(exc)}")

    if buffer:
        shard_path = write_shard(vector_dir, shard_idx, buffer, uid_manifest_path)
        print(f"[{now()}] wrote_final_shard={shard_path} rows={len(buffer)} processed_new={processed_new}")
    if failed_rows:
        append_failed(failed_path, failed_rows)

    completed_after = load_completed_uids(uid_manifest_path)
    failed_count = 0
    if failed_path.exists():
        try:
            failed_count = len(pd.read_csv(failed_path))
        except Exception:
            failed_count = -1
    shard_files = sorted(vector_dir.glob("m2_vectors_part_*.npz"))
    summary = {
        "FULL_VECTOR_STATUS": "PASS" if len(completed_after) + max(failed_count, 0) >= len(df) else "INCOMPLETE",
        "input_csv": input_csv,
        "out_root": str(out_root),
        "total_unique_input": int(len(df)),
        "already_completed_at_start": int(len(completed)),
        "todo_at_start": int(len(todo)),
        "processed_new_this_run": int(processed_new),
        "completed_total": int(len(completed_after)),
        "failed_total": int(failed_count),
        "shard_file_count": int(len(shard_files)),
        "batch_size": int(args.batch_size),
        "shard_size": int(args.shard_size),
        "elapsed_seconds": round(time.time() - start_time, 2),
        "device": str(device),
        "torch_version": torch.__version__,
        "torch_cuda_is_available": bool(torch.cuda.is_available()),
        "filtered_allowed_keys": filtered,
        "token_matrix_saved": False,
    }
    with open(audit_summary_path, "w", encoding="utf-8") as f:
        json.dump(summary, f, indent=2, ensure_ascii=False)
    with open(out_root / "extraction_config.json", "w", encoding="utf-8") as f:
        json.dump({
            "code_root": str(code_root),
            "bin_ckpt": str(bin_ckpt),
            "bpe_codes": args.bpe_codes,
            "model": "LucaPCycle V3 binary-class lucaprot seq_matrix checkpoint-264284",
            "outputs": ["m2_mean", "m2_max", "m2_value_attention", "m2_projected_256"],
            "token_matrix_saved": False,
            "note": "Vector-only full extraction. Token-level M2 matrices are not saved.",
        }, f, indent=2, ensure_ascii=False)
    with open(out_root / "README.md", "w", encoding="utf-8") as f:
        f.write("# LucaPCycle M2 Vector-Only Features\n\n")
        f.write("This directory contains vector-only M2 features extracted from LucaPCycle.\n")
        f.write("Full token-level M2 matrices were not saved in this run.\n")
    print(json.dumps(summary, indent=2, ensure_ascii=False))


if __name__ == "__main__":
    main()
PY

cat > "$JOB" <<EOF
#!/bin/bash
#SBATCH --job-name=lucap_m2_fullvec
#SBATCH --partition=dcu
#SBATCH --nodes=1
#SBATCH --gres=dcu:1
#SBATCH --time=24:00:00
#SBATCH --output=$OUT_ROOT/logs/lucapcycle_m2_full_vector_%j.out
#SBATCH --error=$OUT_ROOT/logs/lucapcycle_m2_full_vector_%j.err

set -u

REPORT="$OUT_ROOT/logs/lucapcycle_m2_full_vector_report_\${SLURM_JOB_ID}.md"
SCRIPT="$SCRIPT"
CODE_ROOT="$CODE_ROOT"
BIN_CKPT="$BIN_CKPT"
BPE_CODES="$BPE_CODES"
OUT_ROOT="$OUT_ROOT"

{
  echo "# LucaPCycle M2 Full Vector-Only Extraction Report"
  echo
  echo "Date: \$(date)"
  echo "Host: \$(hostname)"
  echo "SLURM_JOB_ID: \${SLURM_JOB_ID:-NA}"
  echo

  echo "## 1. Boundary"
  echo
  echo "Vector-only full extraction."
  echo "No token-level M2 matrix is saved."
  echo "No ESM/ESM-C/ESM2 model is loaded."
  echo "No training is run."
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

  echo "## 4. Run Full Vector Extraction"
  echo
  python "\$SCRIPT" \\
    --code_root "\$CODE_ROOT" \\
    --bin_ckpt "\$BIN_CKPT" \\
    --bpe_codes "\$BPE_CODES" \\
    --out_root "\$OUT_ROOT" \\
    --input_csv "\$CANDIDATE_1" \\
    --candidate_csv "\$CANDIDATE_2" \\
    --candidate_csv "\$CANDIDATE_3" \\
    --batch_size 4 \\
    --shard_size 1000
  echo

  echo "## 5. Output Summary"
  echo
  echo "Top-level files:"
  find "\$OUT_ROOT" -maxdepth 1 -type f | sort
  echo
  echo "Shard count:"
  find "\$OUT_ROOT/vector_features" -name "m2_vectors_part_*.npz" -type f | wc -l
  echo
  echo "Audit summary:"
  cat "\$OUT_ROOT/audit_summary.json"
  echo

  echo "## 6. Final Boundary"
  echo
  echo "No token-level M2 matrix was saved."
  echo "No ESM/ESM-C/ESM2 model was loaded."
  echo "No training was performed."
} | tee "\$REPORT"

echo "REPORT_WRITTEN=\$REPORT"
EOF

echo "SBATCH_SCRIPT=$JOB"
sbatch "$JOB"
