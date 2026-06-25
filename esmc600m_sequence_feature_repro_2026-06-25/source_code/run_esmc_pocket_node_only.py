#!/usr/bin/env python3
"""Build ESM-C pocket-node features from existing node-level embeddings.

This is a standalone cloud-friendly version of the original
``feature.main.get_esm_pocket_feature`` step. It intentionally avoids importing
the full EnzymeCAGE repository so it can run on a machine that only has:

- pocket_info.csv
- pocket/*.pdb
- ESM-C_600M/node_level/{UniprotID}.npz

Output:
- Original-compatible monolithic mode: pocket_node_feature/esm_node_feature.pt
  is a torch-saved UID -> pocket-node-feature mapping.
- Custom cloud-safe sharded mode: esm_node_feature.pt is only a small pointer;
  the real UID features are stored in esm_node_feature_shards/*.pt with a
  manifest. This mode was added for the 2026-04-22 full RHEA run after the
  original monolithic torch.save exhausted memory on the cloud machine.
"""

from __future__ import annotations

import argparse
import csv
import json
from pathlib import Path

import numpy as np
import pandas as pd
import torch
from tqdm import tqdm


UID_COL = "UniprotID"
POCKET_COL = "pocket_residues"

STANDARD_AA3 = {
    "ALA",
    "ARG",
    "ASN",
    "ASP",
    "CYS",
    "GLN",
    "GLU",
    "GLY",
    "HIS",
    "ILE",
    "LEU",
    "LYS",
    "MET",
    "PHE",
    "PRO",
    "SER",
    "THR",
    "TRP",
    "TYR",
    "VAL",
}


def build_residue_mapping_from_pdb(pdb_path: Path) -> dict[int, int]:
    """Map PDB residue numbers to zero-based sequence indices.

    This mirrors the original EnzymeCAGE behavior closely: standard amino-acid
    residues are counted in PDB order, and lookup is by integer residue number.
    """

    residue_mapping: dict[int, int] = {}
    seen_residues: set[tuple[str, int, str]] = set()
    seq_index = 0

    with pdb_path.open("rt", errors="ignore") as handle:
        for line in handle:
            if not line.startswith("ATOM"):
                continue
            if len(line) < 27:
                continue

            resname = line[17:20].strip()
            if resname not in STANDARD_AA3:
                continue

            chain_id = line[21].strip()
            insertion_code = line[26].strip()
            try:
                residue_number = int(line[22:26])
            except ValueError:
                continue

            residue_key = (chain_id, residue_number, insertion_code)
            if residue_key in seen_residues:
                continue

            seen_residues.add(residue_key)
            residue_mapping[residue_number] = seq_index
            seq_index += 1

    return residue_mapping


def parse_pocket_residue_numbers(raw_value: object) -> list[int]:
    if not isinstance(raw_value, str):
        return []
    residue_numbers: list[int] = []
    for part in raw_value.split(","):
        part = part.strip()
        if not part:
            continue
        try:
            residue_numbers.append(int(part))
        except ValueError:
            continue
    return residue_numbers


def load_node_feature(npz_path: Path) -> np.ndarray:
    with np.load(npz_path) as data:
        if "node_feature" not in data:
            raise KeyError("missing node_feature key")
        return data["node_feature"]


def build_pocket_node_features(
    pocket_info_path: Path,
    esm_node_dir: Path,
    pocket_pdb_dir: Path,
    limit: int | None = None,
) -> tuple[dict[str, np.ndarray], list[dict[str, str]], dict[str, int]]:
    df = pd.read_csv(pocket_info_path)
    required = {UID_COL, POCKET_COL}
    missing_cols = required.difference(df.columns)
    if missing_cols:
        raise ValueError(f"Missing required columns in pocket_info: {sorted(missing_cols)}")

    if limit is not None:
        df = df.head(limit).copy()

    uid_to_feature: dict[str, np.ndarray] = {}
    failures: list[dict[str, str]] = []

    for row in tqdm(df.itertuples(index=False), total=len(df), desc="pocket-node"):
        row_dict = row._asdict()
        uid = str(row_dict[UID_COL])
        pocket_raw = row_dict[POCKET_COL]

        npz_path = esm_node_dir / f"{uid}.npz"
        pdb_path = pocket_pdb_dir / f"{uid}.pdb"

        if not npz_path.exists():
            failures.append({"UniprotID": uid, "reason": "missing_npz"})
            continue
        if not pdb_path.exists():
            failures.append({"UniprotID": uid, "reason": "missing_pdb"})
            continue

        try:
            node_feature = load_node_feature(npz_path)
            residue_mapping = build_residue_mapping_from_pdb(pdb_path)
            pocket_residue_numbers = parse_pocket_residue_numbers(pocket_raw)

            seq_indices: list[int] = []
            for pdb_residue_number in pocket_residue_numbers:
                seq_index = residue_mapping.get(pdb_residue_number)
                if seq_index is None:
                    continue
                if seq_index < node_feature.shape[0]:
                    seq_indices.append(seq_index)

            if not seq_indices:
                failures.append({"UniprotID": uid, "reason": "no_valid_residue_indices"})
                continue

            uid_to_feature[uid] = node_feature[seq_indices].astype(np.float32, copy=False)
        except Exception as exc:  # Keep the batch moving and report per-UID issues.
            failures.append({"UniprotID": uid, "reason": f"exception:{type(exc).__name__}:{exc}"})

    summary = {
        "pocket_info_rows": int(len(df)),
        "saved_features": int(len(uid_to_feature)),
        "failures": int(len(failures)),
    }
    return uid_to_feature, failures, summary


def load_pocket_info(pocket_info_path: Path, limit: int | None = None) -> pd.DataFrame:
    df = pd.read_csv(pocket_info_path)
    required = {UID_COL, POCKET_COL}
    missing_cols = required.difference(df.columns)
    if missing_cols:
        raise ValueError(f"Missing required columns in pocket_info: {sorted(missing_cols)}")

    if limit is not None:
        df = df.head(limit).copy()
    return df


def extract_one_pocket_feature(
    uid: str,
    pocket_raw: object,
    esm_node_dir: Path,
    pocket_pdb_dir: Path,
) -> tuple[np.ndarray | None, str | None]:
    npz_path = esm_node_dir / f"{uid}.npz"
    pdb_path = pocket_pdb_dir / f"{uid}.pdb"

    if not npz_path.exists():
        return None, "missing_npz"
    if not pdb_path.exists():
        return None, "missing_pdb"

    try:
        node_feature = load_node_feature(npz_path)
        residue_mapping = build_residue_mapping_from_pdb(pdb_path)
        pocket_residue_numbers = parse_pocket_residue_numbers(pocket_raw)

        seq_indices: list[int] = []
        for pdb_residue_number in pocket_residue_numbers:
            seq_index = residue_mapping.get(pdb_residue_number)
            if seq_index is None:
                continue
            if seq_index < node_feature.shape[0]:
                seq_indices.append(seq_index)

        if not seq_indices:
            return None, "no_valid_residue_indices"

        return node_feature[seq_indices].astype(np.float32, copy=False), None
    except Exception as exc:  # Keep the batch moving and report per-UID issues.
        return None, f"exception:{type(exc).__name__}:{exc}"


def write_shard(shard_data: dict[str, np.ndarray], shard_dir: Path, shard_index: int) -> str:
    shard_name = f"esm_node_feature_part_{shard_index:05d}.pt"
    shard_path = shard_dir / shard_name
    tensor_shard = {
        uid: torch.from_numpy(feature) if isinstance(feature, np.ndarray) else feature
        for uid, feature in shard_data.items()
    }
    torch.save(tensor_shard, shard_path)
    return shard_name


def build_pocket_node_features_sharded(
    pocket_info_path: Path,
    esm_node_dir: Path,
    pocket_pdb_dir: Path,
    output_path: Path,
    limit: int | None = None,
    shard_size: int = 1000,
) -> tuple[list[dict[str, str]], dict[str, int]]:
    if shard_size <= 0:
        raise ValueError("shard_size must be positive")

    df = load_pocket_info(pocket_info_path, limit=limit)
    shard_dir = output_path.with_name(output_path.stem + "_shards")
    manifest_path = output_path.with_name(output_path.stem + "_manifest.json")
    shard_dir.mkdir(parents=True, exist_ok=True)
    for old_shard in shard_dir.glob("esm_node_feature_part_*.pt"):
        old_shard.unlink()
    if manifest_path.exists():
        manifest_path.unlink()
    if output_path.exists():
        output_path.unlink()

    failures: list[dict[str, str]] = []
    uid_to_shard: dict[str, str] = {}
    shard_counts: dict[str, int] = {}
    shard_data: dict[str, np.ndarray] = {}
    shard_index = 0
    saved_features = 0

    for row in tqdm(df.itertuples(index=False), total=len(df), desc="pocket-node"):
        row_dict = row._asdict()
        uid = str(row_dict[UID_COL])
        pocket_raw = row_dict[POCKET_COL]

        feature, failure_reason = extract_one_pocket_feature(
            uid=uid,
            pocket_raw=pocket_raw,
            esm_node_dir=esm_node_dir,
            pocket_pdb_dir=pocket_pdb_dir,
        )
        if failure_reason is not None:
            failures.append({"UniprotID": uid, "reason": failure_reason})
            continue

        assert feature is not None
        shard_data[uid] = feature
        saved_features += 1

        if len(shard_data) >= shard_size:
            shard_name = write_shard(shard_data, shard_dir, shard_index)
            for shard_uid in shard_data:
                uid_to_shard[shard_uid] = shard_name
            shard_counts[shard_name] = len(shard_data)
            shard_data = {}
            shard_index += 1

    if shard_data:
        shard_name = write_shard(shard_data, shard_dir, shard_index)
        for shard_uid in shard_data:
            uid_to_shard[shard_uid] = shard_name
        shard_counts[shard_name] = len(shard_data)

    manifest = {
        "format": "sharded_esm_pocket_v1",
        "shard_dir": shard_dir.name,
        "uid_to_shard": uid_to_shard,
        "shard_counts": shard_counts,
        "pocket_info_rows": int(len(df)),
        "saved_features": int(saved_features),
        "failures": int(len(failures)),
        "pocket_info": str(pocket_info_path),
        "esm_node_dir": str(esm_node_dir),
        "pocket_pdb_dir": str(pocket_pdb_dir),
    }
    with manifest_path.open("w", encoding="utf-8") as handle:
        json.dump(manifest, handle)

    pointer = {
        "__format__": "sharded_esm_pocket_v1",
        "manifest_path": manifest_path.name,
    }
    torch.save(pointer, output_path)

    summary = {
        "pocket_info_rows": int(len(df)),
        "saved_features": int(saved_features),
        "failures": int(len(failures)),
        "save_format": "sharded",
        "shard_dir": str(shard_dir),
        "manifest_path": str(manifest_path),
        "num_shards": int(len(shard_counts)),
    }
    return failures, summary


def write_failures(failures: list[dict[str, str]], failed_csv: Path) -> None:
    failed_csv.parent.mkdir(parents=True, exist_ok=True)
    with failed_csv.open("w", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=["UniprotID", "reason"])
        writer.writeheader()
        writer.writerows(failures)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--pocket_info", required=True, type=Path)
    parser.add_argument("--esm_node_dir", required=True, type=Path)
    parser.add_argument("--pocket_pdb_dir", required=True, type=Path)
    parser.add_argument("--output_path", required=True, type=Path)
    parser.add_argument("--failed_csv", type=Path, default=None)
    parser.add_argument("--summary_json", type=Path, default=None)
    parser.add_argument("--limit", type=int, default=None)
    parser.add_argument(
        "--save_format",
        choices=["monolithic", "sharded"],
        default="monolithic",
        help=(
            "monolithic matches the original single-file UID mapping; sharded "
            "is a custom cloud-safe extension for full runs."
        ),
    )
    parser.add_argument(
        "--shard_size",
        type=int,
        default=1000,
        help="Number of UID features per shard when --save_format sharded is used.",
    )
    parser.add_argument(
        "--expected_rows",
        type=int,
        default=None,
        help="Fail after writing the summary if pocket_info row count does not match this value.",
    )
    parser.add_argument(
        "--min_saved_features",
        type=int,
        default=None,
        help="Fail after writing the summary if saved feature count is below this value.",
    )
    parser.add_argument(
        "--fail_on_failures",
        action="store_true",
        help="Fail after writing outputs if any per-UID failures were recorded.",
    )
    args = parser.parse_args()

    args.output_path.parent.mkdir(parents=True, exist_ok=True)
    failed_csv = args.failed_csv or args.output_path.with_name("failed_pocket_nodes.csv")
    summary_json = args.summary_json or args.output_path.with_name("pocket_node_summary.json")

    if args.save_format == "sharded":
        failures, summary = build_pocket_node_features_sharded(
            pocket_info_path=args.pocket_info,
            esm_node_dir=args.esm_node_dir,
            pocket_pdb_dir=args.pocket_pdb_dir,
            output_path=args.output_path,
            limit=args.limit,
            shard_size=args.shard_size,
        )
    else:
        uid_to_feature, failures, summary = build_pocket_node_features(
            pocket_info_path=args.pocket_info,
            esm_node_dir=args.esm_node_dir,
            pocket_pdb_dir=args.pocket_pdb_dir,
            limit=args.limit,
        )
        torch.save(uid_to_feature, args.output_path)

    write_failures(failures, failed_csv)

    summary.update(
        {
            "pocket_info": str(args.pocket_info),
            "esm_node_dir": str(args.esm_node_dir),
            "pocket_pdb_dir": str(args.pocket_pdb_dir),
            "output_path": str(args.output_path),
            "failed_csv": str(failed_csv),
        }
    )
    with summary_json.open("w") as handle:
        json.dump(summary, handle, indent=2)

    print(json.dumps(summary, indent=2))

    strict_errors: list[str] = []
    if args.expected_rows is not None and summary["pocket_info_rows"] != args.expected_rows:
        strict_errors.append(
            f"expected_rows={args.expected_rows}, observed={summary['pocket_info_rows']}"
        )
    if (
        args.min_saved_features is not None
        and summary["saved_features"] < args.min_saved_features
    ):
        strict_errors.append(
            "min_saved_features="
            f"{args.min_saved_features}, observed={summary['saved_features']}"
        )
    if args.fail_on_failures and summary["failures"] > 0:
        strict_errors.append(f"failures={summary['failures']}")

    if strict_errors:
        raise SystemExit("Strict pocket-node validation failed: " + "; ".join(strict_errors))


if __name__ == "__main__":
    main()
