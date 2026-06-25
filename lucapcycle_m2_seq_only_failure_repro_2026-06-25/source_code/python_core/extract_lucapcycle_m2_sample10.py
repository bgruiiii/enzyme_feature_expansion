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
