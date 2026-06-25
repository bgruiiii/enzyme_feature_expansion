#!/usr/bin/env python3
"""Write cloud-side ESM-C export scripts for the clean training package."""

from __future__ import annotations

import csv
import json
import textwrap
import zipfile
from pathlib import Path


BASE = Path("/home/a/EnzymeCAGE")
CLOUD_DIR = (
    BASE
    / "custom/github_upload/reaction_enzyme_microbe_training_clean_2026-06-01_LOCAL/cloud_needed"
)
REQUEST_JSON = CLOUD_DIR / "esmc_cloud_feature_requests.json"
BATCH_SIZE = 1000


EXPORT_SCRIPT = r'''#!/usr/bin/env python
"""Export and package ESM-C features for the clean EnzymeCAGE training package.

Run on the Windows/cloud machine where G:\esm\ESM-C_600M is available.

Expected files in this script directory:
  - esmc_cloud_feature_requests.json
  - esmc_training_uid_index.csv
  - esmc_training_batch_index.csv

Default output:
  - batch_esmc_export_training_clean/
  - one zip per batch:
    batch_esmc_export_training_clean_zips/esmc_training_clean_batch_00000.zip

Each UID exports the same three ESM-C payloads used by the 300-example package:
  - <UID>_esm_c_sequence_node.npz
  - <UID>_esm_c_sequence_mean.npy
  - <UID>_esm_c_pocket_node.npy
"""

from __future__ import annotations

import argparse
import csv
import hashlib
import json
import pickle
import shutil
import zipfile
from pathlib import Path

import numpy as np
import torch


SCRIPT_DIR = Path(__file__).resolve().parent
DEFAULT_REQUEST_JSON = SCRIPT_DIR / "esmc_cloud_feature_requests.json"
DEFAULT_ESM_ROOT = Path(r"G:\esm\ESM-C_600M")
DEFAULT_OUT_ROOT = SCRIPT_DIR / "batch_esmc_export_training_clean"
DEFAULT_ZIP_ROOT = SCRIPT_DIR / "batch_esmc_export_training_clean_zips"


def torch_load(path: Path):
    try:
        return torch.load(path, map_location="cpu", weights_only=False)
    except TypeError:
        return torch.load(path, map_location="cpu")


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def load_requests(path: Path) -> list[dict]:
    requests = json.loads(path.read_text(encoding="utf-8"))
    unique = {}
    for request in requests:
        unique[str(request["UniprotID"])] = request
    return [unique[uid] for uid in sorted(unique)]


def batch_requests(requests: list[dict], batch_size: int) -> list[list[dict]]:
    return [requests[i : i + batch_size] for i in range(0, len(requests), batch_size)]


def load_pocket_mapping(pocket_pointer: Path):
    pointer = torch_load(pocket_pointer)
    if not (isinstance(pointer, dict) and "__format__" in pointer):
        return pointer, None

    manifest_path = Path(pointer["manifest_path"])
    if not manifest_path.is_absolute():
        manifest_path = pocket_pointer.parent / manifest_path
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    return manifest, manifest_path


def load_pocket_feature(uid: str, pocket_mapping, manifest_path: Path | None):
    if manifest_path is None:
        return pocket_mapping[uid]
    shard_name = pocket_mapping["uid_to_shard"][uid]
    shard_path = manifest_path.parent / pocket_mapping["shard_dir"] / shard_name
    shard = torch_load(shard_path)
    return shard[uid]


def zip_directory(source_dir: Path, zip_path: Path) -> str:
    if zip_path.exists():
        zip_path.unlink()
    with zipfile.ZipFile(zip_path, "w", compression=zipfile.ZIP_DEFLATED, allowZip64=True) as zf:
        for path in sorted(source_dir.rglob("*")):
            if path.is_file():
                zf.write(path, path.relative_to(source_dir.parent))
    return sha256_file(zip_path)


def write_json(path: Path, obj) -> None:
    path.write_text(json.dumps(obj, ensure_ascii=False, indent=2), encoding="utf-8")


def write_summary_csv(path: Path, rows: list[dict]) -> None:
    fieldnames = [
        "batch_id",
        "UniprotID",
        "sequence_length",
        "sequence_sha256",
        "sequence_node_shape_json",
        "sequence_mean_shape_json",
        "pocket_node_shape_json",
        "sequence_node_file",
        "sequence_mean_file",
        "pocket_node_file",
        "sequence_node_sha256",
        "sequence_mean_sha256",
        "pocket_node_sha256",
    ]
    with path.open("w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        for row in rows:
            writer.writerow(row)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--request-json", type=Path, default=DEFAULT_REQUEST_JSON)
    parser.add_argument("--esm-root", type=Path, default=DEFAULT_ESM_ROOT)
    parser.add_argument("--out-root", type=Path, default=DEFAULT_OUT_ROOT)
    parser.add_argument("--zip-root", type=Path, default=DEFAULT_ZIP_ROOT)
    parser.add_argument("--batch-size", type=int, default=1000)
    parser.add_argument("--batch-id", type=int, default=None, help="Export one 0-based batch only.")
    parser.add_argument("--start-batch", type=int, default=0)
    parser.add_argument("--end-batch", type=int, default=None, help="Exclusive end batch.")
    parser.add_argument("--only-missing", action="store_true")
    parser.add_argument("--no-zip", action="store_true")
    parser.add_argument(
        "--skip-sequence-node",
        action="store_true",
        help="Emergency mode: export only sequence_mean and pocket_node. Default exports all three files.",
    )
    args = parser.parse_args()

    node_dir = args.esm_root / "node_level"
    seq2feature_path = args.esm_root / "protein_level" / "seq2feature.pkl"
    pocket_dir = args.esm_root / "pocket_node_feature_full_valid_sharded_20260422"
    pocket_pointer = pocket_dir / "esm_node_feature.pt"

    requests = load_requests(args.request_json)
    batches = batch_requests(requests, args.batch_size)
    if args.batch_id is not None:
        selected_batch_ids = [args.batch_id]
    else:
        end = len(batches) if args.end_batch is None else min(args.end_batch, len(batches))
        selected_batch_ids = list(range(args.start_batch, end))

    args.out_root.mkdir(parents=True, exist_ok=True)
    args.zip_root.mkdir(parents=True, exist_ok=True)

    print(json.dumps({
        "requests": len(requests),
        "batch_size": args.batch_size,
        "total_batches": len(batches),
        "selected_batches": selected_batch_ids[:10] + (["..."] if len(selected_batch_ids) > 10 else []),
        "esm_root": str(args.esm_root),
        "skip_sequence_node": args.skip_sequence_node,
    }, indent=2))

    print(f"Loading sequence mean pickle: {seq2feature_path}")
    with seq2feature_path.open("rb") as f:
        seq2feature = pickle.load(f)

    print(f"Loading pocket mapping: {pocket_pointer}")
    pocket_mapping, manifest_path = load_pocket_mapping(pocket_pointer)

    final_batches = []
    for batch_id in selected_batch_ids:
        if batch_id < 0 or batch_id >= len(batches):
            raise ValueError(f"Invalid batch_id {batch_id}; total batches={len(batches)}")

        batch = batches[batch_id]
        batch_dir = args.out_root / f"batch_{batch_id:05d}"
        batch_dir.mkdir(parents=True, exist_ok=True)
        summary_rows = []
        failures = []

        print(f"Batch {batch_id:05d}: {len(batch)} UID")
        for i, request in enumerate(batch, 1):
            uid = str(request["UniprotID"])
            seq = str(request["sequence"])
            sequence_node_out = batch_dir / f"{uid}_esm_c_sequence_node.npz"
            sequence_mean_out = batch_dir / f"{uid}_esm_c_sequence_mean.npy"
            pocket_node_out = batch_dir / f"{uid}_esm_c_pocket_node.npy"

            required_outputs = [sequence_mean_out, pocket_node_out]
            if not args.skip_sequence_node:
                required_outputs.append(sequence_node_out)
            if args.only_missing and all(path.exists() for path in required_outputs):
                continue

            try:
                sequence_node_shape = {}
                sequence_node_sha256 = ""
                sequence_node_file = ""
                if not args.skip_sequence_node:
                    sequence_node_src = node_dir / f"{uid}.npz"
                    shutil.copyfile(sequence_node_src, sequence_node_out)
                    sequence_node_npz = np.load(sequence_node_out)
                    sequence_node_shape = {
                        key: list(sequence_node_npz[key].shape) for key in sequence_node_npz.files
                    }
                    sequence_node_sha256 = sha256_file(sequence_node_out)
                    sequence_node_file = sequence_node_out.name

                sequence_mean = np.asarray(seq2feature[seq], dtype=np.float32)
                np.save(sequence_mean_out, sequence_mean)

                pocket_node = np.asarray(
                    load_pocket_feature(uid, pocket_mapping, manifest_path),
                    dtype=np.float32,
                )
                np.save(pocket_node_out, pocket_node)

                summary_rows.append({
                    "batch_id": batch_id,
                    "UniprotID": uid,
                    "sequence_length": len(seq),
                    "sequence_sha256": request.get("sequence_sha256", ""),
                    "sequence_node_shape_json": json.dumps(sequence_node_shape),
                    "sequence_mean_shape_json": json.dumps(list(sequence_mean.shape)),
                    "pocket_node_shape_json": json.dumps(list(pocket_node.shape)),
                    "sequence_node_file": sequence_node_file,
                    "sequence_mean_file": sequence_mean_out.name,
                    "pocket_node_file": pocket_node_out.name,
                    "sequence_node_sha256": sequence_node_sha256,
                    "sequence_mean_sha256": sha256_file(sequence_mean_out),
                    "pocket_node_sha256": sha256_file(pocket_node_out),
                })
            except Exception as exc:
                failures.append({"batch_id": batch_id, "UniprotID": uid, "error": repr(exc)})

            if i % 100 == 0 or i == len(batch):
                print(f"  batch {batch_id:05d}: {i}/{len(batch)}")
                write_summary_csv(batch_dir / "batch_esmc_export_summary.csv", summary_rows)
                write_json(batch_dir / "batch_esmc_export_failures.json", failures)

        write_summary_csv(batch_dir / "batch_esmc_export_summary.csv", summary_rows)
        write_json(batch_dir / "batch_esmc_export_failures.json", failures)

        zip_info = None
        if not args.no_zip:
            zip_path = args.zip_root / f"esmc_training_clean_batch_{batch_id:05d}.zip"
            print(f"  zipping {zip_path}")
            zip_sha256 = zip_directory(batch_dir, zip_path)
            zip_info = {
                "zip_path": str(zip_path),
                "zip_name": zip_path.name,
                "zip_bytes": zip_path.stat().st_size,
                "zip_sha256": zip_sha256,
            }

        final_batches.append({
            "batch_id": batch_id,
            "requested_uid": len(batch),
            "exported_uid": len(summary_rows),
            "failed_uid": len(failures),
            "batch_dir": str(batch_dir),
            "zip": zip_info,
        })
        write_json(args.out_root / "selected_batch_export_report.json", final_batches)

    report = {
        "request_json": str(args.request_json),
        "esm_root": str(args.esm_root),
        "total_requested_uid": len(requests),
        "batch_size": args.batch_size,
        "total_batches": len(batches),
        "selected_batches": final_batches,
    }
    write_json(args.out_root / "esmc_training_clean_export_report.json", report)
    print(json.dumps(report, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
'''


VERIFY_SCRIPT = r'''#!/usr/bin/env python
"""Verify ESM-C cloud export batches for the clean training package."""

from __future__ import annotations

import argparse
import csv
import json
import zipfile
from pathlib import Path


SCRIPT_DIR = Path(__file__).resolve().parent
DEFAULT_REQUEST_JSON = SCRIPT_DIR / "esmc_cloud_feature_requests.json"
DEFAULT_ZIP_ROOT = SCRIPT_DIR / "batch_esmc_export_training_clean_zips"


def load_requests(path: Path) -> set[str]:
    requests = json.loads(path.read_text(encoding="utf-8"))
    return {str(r["UniprotID"]) for r in requests}


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--request-json", type=Path, default=DEFAULT_REQUEST_JSON)
    parser.add_argument("--zip-root", type=Path, default=DEFAULT_ZIP_ROOT)
    args = parser.parse_args()

    expected_uids = load_requests(args.request_json)
    exported_uids = set()
    zip_reports = []
    for zip_path in sorted(args.zip_root.glob("esmc_training_clean_batch_*.zip")):
        with zipfile.ZipFile(zip_path) as zf:
            names = zf.namelist()
            summary_name = [n for n in names if n.endswith("batch_esmc_export_summary.csv")]
            failure_name = [n for n in names if n.endswith("batch_esmc_export_failures.json")]
            if len(summary_name) != 1:
                raise RuntimeError(f"{zip_path}: expected one summary CSV, found {summary_name}")
            with zf.open(summary_name[0]) as f:
                rows = list(csv.DictReader((line.decode("utf-8") for line in f)))
            with zf.open(failure_name[0]) as f:
                failures = json.loads(f.read().decode("utf-8"))
            for row in rows:
                uid = row["UniprotID"]
                exported_uids.add(uid)
                needed_suffixes = [
                    f"{uid}_esm_c_sequence_mean.npy",
                    f"{uid}_esm_c_pocket_node.npy",
                ]
                if row.get("sequence_node_file"):
                    needed_suffixes.append(f"{uid}_esm_c_sequence_node.npz")
                for suffix in needed_suffixes:
                    if not any(n.endswith(suffix) for n in names):
                        raise RuntimeError(f"{zip_path}: missing {suffix}")
            zip_reports.append({
                "zip": zip_path.name,
                "exported_uid": len(rows),
                "failures": len(failures),
            })

    missing = sorted(expected_uids - exported_uids)
    extra = sorted(exported_uids - expected_uids)
    report = {
        "expected_uid": len(expected_uids),
        "exported_uid": len(exported_uids),
        "missing_uid": len(missing),
        "extra_uid": len(extra),
        "zips": zip_reports,
    }
    print(json.dumps(report, ensure_ascii=False, indent=2))
    if missing or extra:
        raise SystemExit("ESM-C export verification failed.")


if __name__ == "__main__":
    main()
'''


def main() -> None:
    CLOUD_DIR.mkdir(parents=True, exist_ok=True)
    requests = json.loads(REQUEST_JSON.read_text(encoding="utf-8"))
    unique = {str(req["UniprotID"]): req for req in requests}
    ordered = [unique[uid] for uid in sorted(unique)]

    uid_index = CLOUD_DIR / "esmc_training_uid_index.csv"
    with uid_index.open("w", newline="", encoding="utf-8") as f:
        fieldnames = [
            "batch_id",
            "batch_index",
            "global_index",
            "UniprotID",
            "sequence_length",
            "sequence_sha256",
        ]
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        for i, req in enumerate(ordered):
            writer.writerow(
                {
                    "batch_id": i // BATCH_SIZE,
                    "batch_index": i % BATCH_SIZE,
                    "global_index": i,
                    "UniprotID": req["UniprotID"],
                    "sequence_length": req["sequence_length"],
                    "sequence_sha256": req["sequence_sha256"],
                }
            )

    batch_index = CLOUD_DIR / "esmc_training_batch_index.csv"
    with batch_index.open("w", newline="", encoding="utf-8") as f:
        fieldnames = ["batch_id", "start_global_index", "end_global_index_exclusive", "uid_count"]
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        for batch_id, start in enumerate(range(0, len(ordered), BATCH_SIZE)):
            end = min(start + BATCH_SIZE, len(ordered))
            writer.writerow(
                {
                    "batch_id": batch_id,
                    "start_global_index": start,
                    "end_global_index_exclusive": end,
                    "uid_count": end - start,
                }
            )

    (CLOUD_DIR / "export_and_pack_esmc_features_for_training_clean.py").write_text(
        EXPORT_SCRIPT, encoding="utf-8"
    )
    (CLOUD_DIR / "verify_esmc_training_clean_export.py").write_text(
        VERIFY_SCRIPT, encoding="utf-8"
    )

    readme = f"""# ESM-C cloud export for clean training package

This directory tells the cloud machine exactly which enzyme ESM-C features to export.

## Input index

- `esmc_cloud_feature_requests.json`: `{len(ordered)}` unique `UniprotID` with sequence.
- `esmc_cloud_feature_requests.csv`: same UID list without raw sequence.
- `esmc_training_uid_index.csv`: UID-to-batch index, batch size `{BATCH_SIZE}`.
- `esmc_training_batch_index.csv`: batch summary.

## Cloud source paths

- sequence node: `G:\\esm\\ESM-C_600M\\node_level\\<UID>.npz`
- sequence mean: `G:\\esm\\ESM-C_600M\\protein_level\\seq2feature.pkl`
- pocket node: `G:\\esm\\ESM-C_600M\\pocket_node_feature_full_valid_sharded_20260422`

## Export all batches

```powershell
python export_and_pack_esmc_features_for_training_clean.py
```

Default output:

- `batch_esmc_export_training_clean\\batch_00000\\...`
- `batch_esmc_export_training_clean_zips\\esmc_training_clean_batch_00000.zip`

## Export one batch / resume

```powershell
python export_and_pack_esmc_features_for_training_clean.py --batch-id 0 --only-missing
python export_and_pack_esmc_features_for_training_clean.py --start-batch 10 --end-batch 20 --only-missing
```

Default export includes the three ESM-C payloads used by the 300-example package:

- sequence node `.npz`
- sequence mean `.npy`
- pocket node `.npy`

Emergency disk-saving mode:

```powershell
python export_and_pack_esmc_features_for_training_clean.py --skip-sequence-node
```

Use that only if full sequence-node export is too large; the default is to export all three.

## Verify exported zip batches

```powershell
python verify_esmc_training_clean_export.py
```
"""
    (CLOUD_DIR / "README.md").write_text(textwrap.dedent(readme), encoding="utf-8")

    script_zip = CLOUD_DIR / "esmc_training_clean_cloud_scripts_and_indices.zip"
    if script_zip.exists():
        script_zip.unlink()
    include = [
        "README.md",
        "esmc_cloud_feature_requests.csv",
        "esmc_cloud_feature_requests.json",
        "esmc_training_uid_index.csv",
        "esmc_training_batch_index.csv",
        "export_and_pack_esmc_features_for_training_clean.py",
        "verify_esmc_training_clean_export.py",
    ]
    with zipfile.ZipFile(script_zip, "w", compression=zipfile.ZIP_DEFLATED, allowZip64=True) as zf:
        for name in include:
            zf.write(CLOUD_DIR / name, name)

    print(
        json.dumps(
            {
                "cloud_dir": str(CLOUD_DIR),
                "unique_uid": len(ordered),
                "batch_size": BATCH_SIZE,
                "batches": (len(ordered) + BATCH_SIZE - 1) // BATCH_SIZE,
                "script_zip": str(script_zip),
                "script_zip_bytes": script_zip.stat().st_size,
            },
            ensure_ascii=False,
            indent=2,
        )
    )


if __name__ == "__main__":
    main()
