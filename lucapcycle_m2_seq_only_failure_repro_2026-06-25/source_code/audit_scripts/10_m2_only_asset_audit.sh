set -u

WORK_ROOT="/public/home/acfbwjsi7s/LucaPCycle-3"
CODE_ROOT="/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3"
CKPT_ROOT="/public/home/acfbwjsi7s/LucaPCycle-3/TrainedCheckPoint"
ENV="/public/home/acfbwjsi7s/envs/lucapcycle_m2"
REPORT="$WORK_ROOT/lucapcycle_m2_only_asset_audit_$(date +%Y%m%d_%H%M%S).md"

{
  echo "# LucaPCycle M2-Only Asset Audit"
  echo
  echo "Date: $(date)"
  echo "Host: $(hostname)"
  echo

  echo "## 1. Boundary"
  echo
  echo "Read-only asset audit."
  echo "No prediction."
  echo "No feature extraction."
  echo "No model weight loading."
  echo "No ESM/ESM-C/ESM2 loading."
  echo "No source modification."
  echo

  echo "## 2. Directory Overview"
  echo
  for p in "$WORK_ROOT" "$CODE_ROOT" "$CKPT_ROOT" "$CKPT_ROOT/models"; do
    if [ -e "$p" ]; then
      echo "OK: $p"
      ls -lh "$p" | sed -n '1,80p'
    else
      echo "MISSING: $p"
    fi
    echo
  done

  echo "## 3. Checkpoint Directory Search"
  echo
  echo "Limited to CKPT_ROOT/models only."
  echo
  find "$CKPT_ROOT/models" -maxdepth 8 -type d \
    \( -name 'checkpoint-*' -o -name 'best' \) -print | sort
  echo

  echo "## 4. Input-Type Directory Search"
  echo
  echo "Directories named seq / matrix / seq_matrix / seq_vector / vector:"
  find "$CKPT_ROOT/models" -maxdepth 8 -type d \
    \( -name 'seq' -o -name 'matrix' -o -name 'seq_matrix' -o -name 'seq_vector' -o -name 'vector' \) \
    -print | sort
  echo

  echo "## 5. Config JSON Scan"
  echo
  "$ENV/bin/python" - <<'PY'
import json
from pathlib import Path

ckpt_root = Path("/public/home/acfbwjsi7s/LucaPCycle-3/TrainedCheckPoint/models")
rows = []
for cfg_path in sorted(ckpt_root.glob("**/config.json")):
    try:
        cfg = json.loads(cfg_path.read_text(encoding="utf-8"))
    except Exception as exc:
        rows.append((str(cfg_path), "READ_ERROR", repr(exc)))
        continue
    parts = cfg_path.parts
    inferred_input_type = None
    for name in ["seq", "matrix", "seq_matrix", "seq_vector", "vector"]:
        if name in parts:
            inferred_input_type = name
            break
    rows.append((
        str(cfg_path),
        "inferred_dir_input_type=" + str(inferred_input_type),
        "config_input_type=" + str(cfg.get("input_type")),
        "hidden_size=" + str(cfg.get("hidden_size")),
        "seq_fc_size=" + str(cfg.get("seq_fc_size")),
        "embedding_input_size=" + str(cfg.get("embedding_input_size")),
        "embedding_fc_size=" + str(cfg.get("embedding_fc_size")),
        "seq_pooling_type=" + str(cfg.get("seq_pooling_type")),
        "matrix_pooling_type=" + str(cfg.get("matrix_pooling_type")),
    ))

for row in rows:
    print(" | ".join(row))

seq_like = [r for r in rows if "inferred_dir_input_type=seq" in r[1]]
seq_matrix_like = [r for r in rows if "inferred_dir_input_type=seq_matrix" in r[1]]
print()
print("config_file_count:", len(rows))
print("seq_like_config_count:", len(seq_like))
print("seq_matrix_like_config_count:", len(seq_matrix_like))
PY
  echo

  echo "## 6. Training Args Scan"
  echo
  "$ENV/bin/python" - <<'PY'
from pathlib import Path
import torch

ckpt_root = Path("/public/home/acfbwjsi7s/LucaPCycle-3/TrainedCheckPoint/models")
paths = sorted(ckpt_root.glob("**/training_args.bin"))
print("training_args_count:", len(paths))
for p in paths:
    print()
    print("TRAINING_ARGS:", p)
    try:
        obj = torch.load(str(p), map_location="cpu")
    except Exception as exc:
        print("READ_ERROR:", repr(exc))
        continue
    d = getattr(obj, "__dict__", {})
    keys = [
        "dataset_name", "dataset_type", "task_type", "model_type",
        "input_type", "input_mode", "seq_subword", "seq_pooling_type",
        "matrix_pooling_type", "matrix_encoder", "matrix_dirpath",
        "vector_dirpath", "llm_type", "llm_version", "embedding_input_size",
        "seq_max_length", "matrix_max_length", "output_mode",
    ]
    for k in keys:
        print(f"{k}: {d.get(k, None)}")
PY
  echo

  echo "## 7. Official Code Route Search"
  echo
  echo "Search only CODE_ROOT README/docs/src for M2/export/input_type references."
  grep -RIn \
    "M2\\|M1\\|input_type\\|seq_matrix\\|seq-only\\|seq only\\|matrix_dirpath\\|vector_dirpath\\|predict_embedding\\|Encoder\\|BatchConverter\\|feature\\|embedding" \
    "$CODE_ROOT/README.md" "$CODE_ROOT/src" "$CODE_ROOT/docs" 2>/dev/null | head -300 || true
  echo

  echo "## 8. Final Assessment Template"
  echo
  echo "M2_ONLY_ASSET_AUDIT_STATUS=<PASS_M2_ONLY_FOUND or NO_M2_ONLY_FOUND or INCONCLUSIVE>"
  echo "m2_only_checkpoint_paths=<list or none>"
  echo "seq_matrix_checkpoint_paths=<list>"
  echo "official_m2_only_export_entrypoint=<path or none>"
  echo "requires_esm_or_matrix_for_official_prediction=<yes/no/unknown>"
  echo "recommendation=<do not run / run only after approval / candidate found>"
} | tee "$REPORT"

echo
echo "REPORT_WRITTEN=$REPORT"
