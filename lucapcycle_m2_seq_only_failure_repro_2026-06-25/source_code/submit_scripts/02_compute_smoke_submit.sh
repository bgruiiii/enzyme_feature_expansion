set -u

WORK_ROOT="/public/home/acfbwjsi7s/LucaPCycle-3"
REPORT="$WORK_ROOT/lucapcycle_m2_compute_smoke_$(date +%Y%m%d_%H%M%S).md"
JOB="$WORK_ROOT/lucapcycle_m2_compute_smoke.sbatch"
CODE_ROOT="/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3"
CKPT_ROOT="/public/home/acfbwjsi7s/LucaPCycle-3/TrainedCheckPoint"
ENV="/public/home/acfbwjsi7s/envs/lucapcycle_m2"
BIN_CKPT="$CKPT_ROOT/models/extra_p_2_class_v3/protein/binary_class/lucaprot/seq_matrix/20240924203640/checkpoint-264284"

cat > "$JOB" <<EOF
#!/bin/bash
#SBATCH --job-name=lucap_m2_smoke
#SBATCH --partition=dcu
#SBATCH --nodes=1
#SBATCH --gres=dcu:1
#SBATCH --time=00:20:00
#SBATCH --output=$WORK_ROOT/lucapcycle_m2_compute_smoke_%j.out
#SBATCH --error=$WORK_ROOT/lucapcycle_m2_compute_smoke_%j.err

set -u

REPORT="$REPORT"
CODE_ROOT="$CODE_ROOT"
BIN_CKPT="$BIN_CKPT"
ENV="$ENV"

{
  echo "# LucaPCycle M2 Compute-Node Smoke Test"
  echo
  echo "Date: \$(date)"
  echo "Host: \$(hostname)"
  echo "SLURM_JOB_ID: \${SLURM_JOB_ID:-NA}"
  echo

  echo "## 1. Module And Environment"
  echo
  module load compiler/rocm/dtk-23.10
  echo "Loaded modules:"
  module list 2>&1 || true
  echo
  source "\$ENV/bin/activate"
  echo "python: \$(which python)"
  python --version
  echo

  echo "## 2. Torch Runtime Check"
  echo
  python - <<'PY'
import os
import sys
print("python_executable:", sys.executable)
try:
    import torch
    print("torch_import: OK")
    print("torch_version:", torch.__version__)
    print("torch_cuda_is_available:", torch.cuda.is_available())
    try:
        print("torch_cuda_device_count:", torch.cuda.device_count())
    except Exception as e:
        print("torch_cuda_device_count_error:", repr(e))
    try:
        if torch.cuda.is_available() and torch.cuda.device_count() > 0:
            print("torch_device_0_name:", torch.cuda.get_device_name(0))
    except Exception as e:
        print("torch_device_name_error:", repr(e))
except Exception as e:
    print("torch_import: FAIL")
    print("torch_error:", repr(e))
    raise
PY
  echo

  echo "## 3. Checkpoint Load And State Dict Inspection"
  echo
  python - <<PY
import json
from pathlib import Path
import torch

ckpt_dir = Path("$BIN_CKPT")
model_path = ckpt_dir / "pytorch_model.bin"
config_path = ckpt_dir / "config.json"

print("checkpoint_dir:", ckpt_dir)
print("model_path:", model_path)
print("model_size_bytes:", model_path.stat().st_size)

obj = torch.load(str(model_path), map_location="cpu")
print("loaded_object_type:", type(obj).__name__)

if isinstance(obj, dict):
    if "state_dict" in obj and isinstance(obj["state_dict"], dict):
        sd = obj["state_dict"]
        print("state_dict_source: obj['state_dict']")
    elif "model_state_dict" in obj and isinstance(obj["model_state_dict"], dict):
        sd = obj["model_state_dict"]
        print("state_dict_source: obj['model_state_dict']")
    else:
        sd = obj
        print("state_dict_source: raw_dict")
else:
    print("ERROR: checkpoint object is not a dict")
    raise SystemExit(2)

keys = list(sd.keys())
print("state_dict_key_count:", len(keys))
print("first_30_keys:")
for k in keys[:30]:
    print("  ", k)

for token in ["seq_encoder", "seq_pooler", "seq_linear", "embedding", "classifier"]:
    matches = [k for k in keys if token in k]
    print(f"match_count[{token}]:", len(matches))
    for k in matches[:10]:
        v = sd[k]
        shape = tuple(v.shape) if hasattr(v, "shape") else "no_shape"
        print(f"  {k}: {shape}")

seq_encoder_matches = [k for k in keys if "seq_encoder" in k]
if not seq_encoder_matches:
    print("SMOKE_STATUS=FAIL_NO_SEQ_ENCODER_KEYS")
else:
    print("SMOKE_STATUS=PASS_SEQ_ENCODER_KEYS_PRESENT")

print()
print("config_summary:")
with open(config_path, "r", encoding="utf-8") as f:
    cfg = json.load(f)
for k in ["hidden_size", "num_hidden_layers", "num_attention_heads", "vocab_size", "seq_fc_size", "seq_pooling_type", "seq_max_length", "input_type", "embedding_input_size"]:
    print(f"{k}: {cfg.get(k)}")
PY
  echo

  echo "## 4. Final Boundary"
  echo
  echo "No M2 extraction was run."
  echo "No ESM/ESM-C/ESM2 model was loaded."
  echo "Wait for local review before the next step."
} | tee "\$REPORT"

echo "REPORT_WRITTEN=\$REPORT"
EOF

echo "SBATCH_SCRIPT=$JOB"
echo "REPORT_TARGET=$REPORT"
sbatch "$JOB"
