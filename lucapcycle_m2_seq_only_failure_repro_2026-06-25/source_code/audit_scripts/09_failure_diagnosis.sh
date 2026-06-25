set -u

CODE_ROOT="/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3"
CKPT_ROOT="/public/home/acfbwjsi7s/LucaPCycle-3/TrainedCheckPoint"
ENV="/public/home/acfbwjsi7s/envs/lucapcycle_m2"
BIN_CKPT="$CKPT_ROOT/models/extra_p_2_class_v3/protein/binary_class/lucaprot/seq_matrix/20240924203640/checkpoint-264284"
BPE_CODES="$CODE_ROOT/subword/extra_p/extra_p_50_codes_20000.txt"
TRAINING_TABLE="/public/home/acfbwjsi7s/bio_vector_full_run_2026-06-04/data/reaction_enzyme_microbe_training_clean_2026-06-01_LOCAL/tables/reaction_enzyme_pairs.csv"
CURRENT_OUT="/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only"
REPORT="$CURRENT_OUT/logs/lucapcycle_m2_failure_diagnosis_$(date +%Y%m%d_%H%M%S).md"

{
  echo "# LucaPCycle M2 Failure Diagnosis"
  echo
  echo "Date: $(date)"
  echo "Host: $(hostname)"
  echo

  echo "## 1. Boundary"
  echo
  echo "Small-sample diagnosis only."
  echo "No full extraction is run."
  echo "No 195,743-UID job is submitted."
  echo "No training is run."
  echo "No ESM/ESM-C/ESM2 model is loaded."
  echo

  echo "## 2. Known Failure"
  echo
  echo "Current 107,731-UID vector result failed diversity audit and must not be used for training unless root cause is fixed."
  echo

  echo "## 3. Python Diagnosis"
  "$ENV/bin/python" - <<'PY'
import json
import math
import os
import sys
from pathlib import Path
from types import SimpleNamespace

import numpy as np
import pandas as pd
import torch
from subword_nmt.apply_bpe import BPE
from transformers.models.bert.tokenization_bert import BertTokenizer

CODE_ROOT = Path("/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3")
BIN_CKPT = Path("/public/home/acfbwjsi7s/LucaPCycle-3/TrainedCheckPoint/models/extra_p_2_class_v3/protein/binary_class/lucaprot/seq_matrix/20240924203640/checkpoint-264284")
BPE_CODES = Path("/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/subword/extra_p/extra_p_50_codes_20000.txt")
TRAINING_TABLE = Path("/public/home/acfbwjsi7s/bio_vector_full_run_2026-06-04/data/reaction_enzyme_microbe_training_clean_2026-06-01_LOCAL/tables/reaction_enzyme_pairs.csv")
CURRENT_OUT = Path("/public/home/acfbwjsi7s/lucapcycle_m2_features_2026-06-25_vector_only")

sys.path.insert(0, str(CODE_ROOT))
sys.path.insert(0, str(CODE_ROOT / "src"))

from common.model_config import LucaConfig
from lucaprot.models.lucaprot import LucaProt
from batch_converter import BatchConverter

def tensor_stats(name, arr):
    arr = np.asarray(arr)
    flat = arr.reshape(arr.shape[0], -1) if arr.ndim >= 2 else arr.reshape(1, -1)
    per_dim_std = flat.std(axis=0)
    row_norms = np.linalg.norm(flat, axis=1)
    print(f"{name}: shape={arr.shape}, dtype={arr.dtype}")
    print(f"  global_min={float(np.min(arr)):.8f}, global_max={float(np.max(arr)):.8f}")
    print(f"  mean_dim_std={float(np.mean(per_dim_std)):.12g}, median_dim_std={float(np.median(per_dim_std)):.12g}, max_dim_std={float(np.max(per_dim_std)):.12g}")
    print(f"  row_norm_min={float(np.min(row_norms)):.8f}, row_norm_max={float(np.max(row_norms)):.8f}")
    if flat.shape[0] >= 2:
        x = flat.astype(np.float32)
        x = x / np.clip(np.linalg.norm(x, axis=1, keepdims=True), 1e-12, None)
        sim = x @ x.T
        vals = sim[np.triu_indices(sim.shape[0], k=1)]
        print(f"  cosine_min={float(vals.min()):.8f}, cosine_median={float(np.median(vals)):.8f}, cosine_max={float(vals.max()):.8f}")

def load_sample():
    df = pd.read_csv(TRAINING_TABLE, usecols=["UniprotID", "sequence"]).dropna()
    df["UniprotID"] = df["UniprotID"].astype(str)
    df["sequence"] = df["sequence"].astype(str)
    df = df[df["sequence"].str.len() > 0].drop_duplicates("UniprotID")
    df["sequence_length"] = df["sequence"].str.len()
    sample = pd.concat([
        df.head(4),
        df.sort_values("sequence_length").head(4),
        df.sort_values("sequence_length", ascending=False).head(4),
    ], ignore_index=True).drop_duplicates("UniprotID").head(12)
    return sample

def manual_encode(seq, bpe, tokenizer, seq_max_length, cls_id=2, sep_id=3):
    pieces = bpe.process_line(seq.upper()).split(" ")
    token_text = " ".join(pieces)
    enc = tokenizer.encode_plus(token_text, None, add_special_tokens=False, max_length=seq_max_length, truncation=True)
    ids = [cls_id] + enc["input_ids"] + [sep_id]
    mask = [1] * len(ids)
    return pieces, token_text, ids, mask

def pad(ids_list, pad_id=0):
    max_len = max(len(x) for x in ids_list)
    ids = np.full((len(ids_list), max_len), pad_id, dtype=np.int64)
    mask = np.zeros((len(ids_list), max_len), dtype=np.int64)
    for i, ids_i in enumerate(ids_list):
        ids[i, :len(ids_i)] = ids_i
        mask[i, :len(ids_i)] = 1
    return torch.from_numpy(ids), torch.from_numpy(mask)

print("### 3.1 Load Config / Tokenizer")
cfg = LucaConfig.from_json_file(str(BIN_CKPT / "config.json"))
for k in [
    "hidden_size", "num_hidden_layers", "num_attention_heads", "vocab_size",
    "seq_fc_size", "embedding_input_size", "embedding_fc_size",
    "seq_pooling_type", "matrix_pooling_type", "seq_max_length",
    "input_type", "no_position_embeddings", "no_token_type_embeddings",
]:
    print(f"{k}: {getattr(cfg, k, None)}")

tokenizer = BertTokenizer.from_pretrained(str(BIN_CKPT / "tokenizer"), do_lower_case=False)
with open(BPE_CODES, "r", encoding="utf-8") as f:
    bpe = BPE(f, merges=-1, separator="")
print("tokenizer_vocab_size:", tokenizer.vocab_size)
print("special ids:", {
    "pad": tokenizer.pad_token_id,
    "unk": tokenizer.unk_token_id,
    "cls": tokenizer.cls_token_id,
    "sep": tokenizer.sep_token_id,
    "mask": tokenizer.mask_token_id,
})

sample = load_sample()
print()
print("### 3.2 Sample UID Set")
print(sample[["UniprotID", "sequence_length"]].to_string(index=False))

print()
print("### 3.3 Manual Tokenization / UNK Audit")
manual_ids = []
manual_masks = []
for _, row in sample.iterrows():
    uid = row["UniprotID"]
    seq = row["sequence"]
    pieces, token_text, ids, mask = manual_encode(seq, bpe, tokenizer, cfg.seq_max_length)
    manual_ids.append(ids)
    manual_masks.append(mask)
    core_ids = ids[1:-1]
    unk_count = sum(1 for x in core_ids if x == tokenizer.unk_token_id)
    unique_core = len(set(core_ids))
    print(f"UID={uid} seq_len={len(seq)} bpe_pieces={len(pieces)} token_ids={len(ids)} unique_core_ids={unique_core} unk_count={unk_count} unk_ratio={unk_count/max(len(core_ids),1):.4f}")
    print("  first20_pieces:", pieces[:20])
    print("  first30_ids:", ids[:30])
    print("  first20_tokens:", tokenizer.convert_ids_to_tokens(ids[:20]))

manual_input_ids, manual_attention_mask = pad(manual_ids, pad_id=tokenizer.pad_token_id or 0)
print("manual_input_ids_shape:", tuple(manual_input_ids.shape))
print("manual_global_unique_input_ids:", len(set(manual_input_ids.numpy().reshape().tolist())))
print("manual_global_unk_ratio_nonpad:", float(((manual_input_ids == tokenizer.unk_token_id) & (manual_attention_mask == 1)).sum().item() / max(int(manual_attention_mask.sum().item()), 1)))

print()
print("### 3.4 Official BatchConverter Tokenization Comparison")
batch_converter = BatchConverter(
    task_level_type="seq_level",
    label_size=1,
    output_mode="binary_class",
    seq_subword=bpe,
    seq_tokenizer=tokenizer,
    no_position_embeddings=getattr(cfg, "no_position_embeddings", False),
    no_token_type_embeddings=getattr(cfg, "no_token_type_embeddings", False),
    truncation_seq_length=cfg.seq_max_length,
    truncation_matrix_length=cfg.seq_max_length,
    padding_idx=tokenizer.pad_token_id,
    unk_idx=tokenizer.unk_token_id,
    cls_idx=tokenizer.cls_token_id,
    eos_idx=tokenizer.sep_token_id,
    mask_idx=tokenizer.mask_token_id,
)
records = [
    {"seq_id": str(r.UniprotID), "seq_type": "prot", "seq": str(r.sequence), "vector": None, "matrix": None, "label": None}
    for r in sample.itertuples(index=False)
]
batch = batch_converter(records)
official_ids = batch["input_ids"]
official_seq_mask = batch["seq_attention_masks"]
official_token_type = batch["token_type_ids"]
official_position_ids = batch["position_ids"]
print("official_input_ids_shape:", tuple(official_ids.shape))
print("official_seq_mask_sum:", official_seq_mask.sum(dim=1).tolist())
print("manual_mask_sum:", manual_attention_mask.sum(dim=1).tolist())
print("manual_vs_official_ids_equal:", bool(torch.equal(manual_input_ids, official_ids)))
print("official_global_unique_input_ids:", len(set(official_ids.numpy().reshape().tolist())))
print("official_global_unk_ratio_nonpad:", float(((official_ids == tokenizer.unk_token_id) & (official_seq_mask == 1)).sum().item() / max(int(official_seq_mask.sum().item()), 1)))
print("official_token_type_unique:", sorted(set(official_token_type.numpy().reshape().tolist())) if official_token_type is not None else None)
print("official_position_first_row:", official_position_ids[0, :min(20, official_position_ids.shape[1])].tolist() if official_position_ids is not None else None)

print()
print("### 3.5 Load Model")
model_args = SimpleNamespace(
    input_type="seq_matrix",
    seq_pooling_type=cfg.seq_pooling_type,
    matrix_pooling_type=cfg.matrix_pooling_type,
    output_mode="binary_class",
    sigmoid=True,
    loss_type="bce",
    device=torch.device("cuda" if torch.cuda.is_available() else "cpu"),
)
model = LucaProt(cfg, args=model_args)
state = torch.load(str(BIN_CKPT / "pytorch_model.bin"), map_location="cpu")
filtered = []
if "loss_fct.pos_weight" in state:
    filtered.append("loss_fct.pos_weight")
    state.pop("loss_fct.pos_weight")
missing, unexpected = model.load_state_dict(state, strict=True)
print("filtered_keys:", filtered)
print("missing:", missing)
print("unexpected:", unexpected)
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
model.to(device)
model.eval()
print("device:", device)

print()
print("### 3.6 Seq Encoder Diversity: Manual vs Official Inputs")
with torch.no_grad():
    # Manual path used by current failed extraction.
    mi = manual_input_ids.to(device)
    mm = manual_attention_mask.to(device)
    out_manual = model.seq_encoder(mi, attention_mask=mm, token_type_ids=None, position_ids=None, return_dict=False)[0]
    token_mean_manual = (out_manual * mm.unsqueeze(-1)).sum(dim=1) / mm.sum(dim=1, keepdim=True).clamp(min=1)
    pooled_manual_nomask = model.seq_pooler(out_manual)
    pooled_manual_mask = model.seq_pooler(out_manual, mask=mm)

    oi = official_ids.to(device)
    om = official_seq_mask.to(device)
    ott = official_token_type.to(device) if official_token_type is not None else None
    op = official_position_ids.to(device) if official_position_ids is not None else None
    out_official = model.seq_encoder(oi, attention_mask=om, token_type_ids=ott, position_ids=op, return_dict=False)[0]
    token_mean_official = (out_official * om.unsqueeze(-1)).sum(dim=1) / om.sum(dim=1, keepdim=True).clamp(min=1)
    pooled_official_nomask = model.seq_pooler(out_official)
    pooled_official_mask = model.seq_pooler(out_official, mask=om)

    # Embedding-output diversity before Transformer encoder.
    emb_manual = model.seq_encoder.embeddings(input_ids=mi, token_type_ids=None, position_ids=None)
    emb_official = model.seq_encoder.embeddings(input_ids=oi, token_type_ids=ott, position_ids=op)
    emb_mean_manual = (emb_manual * mm.unsqueeze(-1)).sum(dim=1) / mm.sum(dim=1, keepdim=True).clamp(min=1)
    emb_mean_official = (emb_official * om.unsqueeze(-1)).sum(dim=1) / om.sum(dim=1, keepdim=True).clamp(min=1)

arrays = {
    "emb_mean_manual_before_transformer": emb_mean_manual.detach().cpu().numpy(),
    "m2_token_mean_manual_after_transformer": token_mean_manual.detach().cpu().numpy(),
    "m2_pooler_manual_nomask": pooled_manual_nomask.detach().cpu().numpy(),
    "m2_pooler_manual_mask": pooled_manual_mask.detach().cpu().numpy(),
    "emb_mean_official_before_transformer": emb_mean_official.detach().cpu().numpy(),
    "m2_token_mean_official_after_transformer": token_mean_official.detach().cpu().numpy(),
    "m2_pooler_official_nomask": pooled_official_nomask.detach().cpu().numpy(),
    "m2_pooler_official_mask": pooled_official_mask.detach().cpu().numpy(),
}
for name, arr in arrays.items():
    tensor_stats(name, arr)

print()
print("### 3.7 Current Saved Shard Cross-Check")
shard0 = CURRENT_OUT / "vector_features" / "m2_vectors_part_000000.npz"
if shard0.is_file():
    with np.load(shard0, allow_pickle=False) as z:
        print("shard0 keys:", sorted(z.files))
        take = min(12, len(z["uid"]))
        print("shard0 first_uids:", [str(x) for x in z["uid"][:take]])
        for f in ["m2_mean", "m2_max", "m2_value_attention", "m2_projected_256"]:
            tensor_stats("saved_shard0_" + f + "_first12", z[f][:take])
else:
    print("shard0 missing:", shard0)

print()
print("### 3.8 Diagnosis Interpretation")
print("DIAGNOSIS_STATUS=COMPLETED_SMALL_SAMPLE")
print("If UNK ratio is high, tokenization/vocab mismatch is likely.")
print("If embedding before Transformer is diverse but M2 after Transformer collapses, seq branch/checkpoint is not usable as standalone M2.")
print("If official BatchConverter differs from manual input and official M2 is diverse, rerun using BatchConverter.")
print("If seq branch remains collapsed even with official BatchConverter, do not run 195,743 seq-only extraction; investigate matrix/ESM branch or a different checkpoint.")
PY
  echo

  echo "## 4. Final Boundary"
  echo "Diagnosis finished. Do not start complete enzyme-pool extraction until this report is reviewed."
} | tee "$REPORT"

echo
echo "REPORT_WRITTEN=$REPORT"
