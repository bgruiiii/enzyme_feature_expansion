import argparse
import os
import pickle as pkl

import numpy as np
import pandas as pd
import torch
from tqdm import tqdm

try:
    from enzymecage.base import SEQ_COL, UID_COL
except Exception:
    UID_COL = "UniprotID"
    SEQ_COL = "sequence"


def run_sequence_esmc(data_path: str, output_root: str, model_name: str = "esmc_600m"):
    from esm.models.esmc import ESMC
    from esm.sdk.api import ESMProtein, LogitsConfig

    if not torch.cuda.is_available():
        raise RuntimeError("CUDA is not available. Please fix the GPU runtime first.")

    device = "cuda"
    node_dir = os.path.join(output_root, "node_level")
    protein_dir = os.path.join(output_root, "protein_level")
    os.makedirs(node_dir, exist_ok=True)
    os.makedirs(protein_dir, exist_ok=True)

    mean_feat_path = os.path.join(protein_dir, "seq2feature.pkl")
    failed_path = os.path.join(node_dir, "failed_proteins.csv")

    print(f"Loading {model_name} on {device} ...")
    model = ESMC.from_pretrained(model_name).to(device)
    model.eval()

    print(f"Reading input table: {data_path}")
    df = pd.read_csv(data_path)
    if UID_COL not in df.columns or SEQ_COL not in df.columns:
        raise ValueError(
            f"Input CSV must contain columns `{UID_COL}` and `{SEQ_COL}`. "
            f"Found: {df.columns.tolist()}"
        )

    df = df[[UID_COL, SEQ_COL]].drop_duplicates(UID_COL)
    uid_to_seq = dict(zip(df[UID_COL], df[SEQ_COL]))

    pending_uids = []
    for uid in df[UID_COL].tolist():
        save_path = os.path.join(node_dir, f"{uid}.npz")
        if not os.path.exists(save_path):
            pending_uids.append(uid)

    if os.path.exists(mean_feat_path):
        seq_to_feature = pkl.load(open(mean_feat_path, "rb"))
    else:
        seq_to_feature = {}

    failed_uids = []
    failed_seqs = []

    print(f"{len(pending_uids)} proteins pending for sequence-level ESM-C.")
    for uid in tqdm(pending_uids):
        seq = uid_to_seq[uid]
        save_path = os.path.join(node_dir, f"{uid}.npz")
        protein = ESMProtein(sequence=seq)

        try:
            with torch.no_grad():
                protein_tensor = model.encode(protein)
                logits_output = model.logits(
                    protein_tensor,
                    LogitsConfig(sequence=True, return_embeddings=True),
                )
        except Exception as exc:
            print(f"[failed] uid={uid} length={len(seq)} err={exc}")
            failed_uids.append(uid)
            failed_seqs.append(seq)
            continue

        node_feature = logits_output.embeddings[0].cpu().numpy()
        np.savez_compressed(save_path, node_feature=node_feature)
        seq_to_feature[seq] = node_feature.mean(axis=0)

    with open(mean_feat_path, "wb") as f:
        pkl.dump(seq_to_feature, f)

    pd.DataFrame({UID_COL: failed_uids, SEQ_COL: failed_seqs}).to_csv(
        failed_path, index=False
    )

    print(f"Saved node-level features to: {node_dir}")
    print(f"Saved sequence mean features to: {mean_feat_path}")
    print(f"Saved failed-protein table to: {failed_path}")


def main():
    parser = argparse.ArgumentParser(
        description="Run sequence-level ESM-C 600M for EnzymeCAGE all_enzymes.csv."
    )
    parser.add_argument("--data_path", required=True, help="Path to all_enzymes.csv")
    parser.add_argument(
        "--output_root",
        required=True,
        help="Output root directory, e.g. G:\\EnzymeCAGE_data\\ESM-C_600M",
    )
    parser.add_argument(
        "--model_name",
        default="esmc_600m",
        help="ESM-C model name accepted by esm.from_pretrained",
    )
    args = parser.parse_args()

    run_sequence_esmc(
        data_path=args.data_path,
        output_root=args.output_root,
        model_name=args.model_name,
    )


if __name__ == "__main__":
    main()
