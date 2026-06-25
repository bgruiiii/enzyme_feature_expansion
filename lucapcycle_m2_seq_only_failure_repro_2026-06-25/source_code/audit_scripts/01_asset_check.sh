set -u

REPORT="/public/home/acfbwjsi7s/LucaPCycle-3/lucapcycle_m2_asset_check_$(date +%Y%m%d_%H%M%S).md"
CODE_ROOT="/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3"
CKPT_ROOT="/public/home/acfbwjsi7s/LucaPCycle-3/TrainedCheckPoint"
ENV="/public/home/acfbwjsi7s/envs/lucapcycle_m2"
BIN_CKPT="$CKPT_ROOT/models/extra_p_2_class_v3/protein/binary_class/lucaprot/seq_matrix/20240924203640/checkpoint-264284"
MC_CKPT="$CKPT_ROOT/models/extra_p_31_class_v3/protein/multi_class/lucaprot/seq_matrix/20240923094428/checkpoint-8569250"

{
  echo "# LucaPCycle M2 Asset Check"
  echo
  echo "Date: $(date)"
  echo "Host: $(hostname)"
  echo

  echo "## 1. Path Summary"
  echo
  echo '```text'
  echo "CODE_ROOT=$CODE_ROOT"
  echo "CKPT_ROOT=$CKPT_ROOT"
  echo "ENV=$ENV"
  echo "BIN_CKPT=$BIN_CKPT"
  echo "MC_CKPT=$MC_CKPT"
  echo '```'
  echo

  echo "## 2. Directory Checks"
  echo
  for p in \
    "$CODE_ROOT" \
    "$CODE_ROOT/src" \
    "$CODE_ROOT/subword" \
    "$CODE_ROOT/vocab" \
    "$CKPT_ROOT" \
    "$BIN_CKPT" \
    "$ENV"
  do
    if [ -e "$p" ]; then
      echo "OK: $p"
      ls -ld "$p"
    else
      echo "MISSING: $p"
    fi
  done
  echo

  echo "## 3. Required File Checks"
  echo
  required_files=(
    "$CODE_ROOT/README.md"
    "$CODE_ROOT/requirements.txt"
    "$CODE_ROOT/src/prediction_v2.py"
    "$CODE_ROOT/src/inference.py"
    "$CODE_ROOT/src/lucaprot/models/lucaprot.py"
    "$CODE_ROOT/src/common/modeling_bert.py"
    "$CODE_ROOT/src/batch_converter.py"
    "$CODE_ROOT/src/encoder.py"
    "$CODE_ROOT/subword/extra_p/extra_p_50_codes_20000.txt"
    "$CODE_ROOT/vocab/extra_p/extra_p_50_subword_vocab_20000.txt"
    "$BIN_CKPT/config.json"
    "$BIN_CKPT/pytorch_model.bin"
    "$BIN_CKPT/training_args.bin"
    "$BIN_CKPT/tokenizer/special_tokens_map.json"
    "$BIN_CKPT/tokenizer/tokenizer_config.json"
    "$BIN_CKPT/tokenizer/vocab.txt"
  )
  missing=0
  for f in "${required_files[@]}"; do
    if [ -f "$f" ]; then
      echo "OK: $f"
      ls -lh "$f"
    else
      echo "MISSING: $f"
      missing=$((missing + 1))
    fi
  done
  echo
  echo "Missing required file count: $missing"
  echo

  echo "## 4. Optional 31-class Checkpoint Check"
  echo
  if [ -d "$MC_CKPT" ]; then
    echo "OK: $MC_CKPT"
    find "$MC_CKPT" -maxdepth 2 -type f | sort | sed -n '1,40p'
  else
    echo "OPTIONAL_MISSING: $MC_CKPT"
  fi
  echo

  echo "## 5. Checkpoint Config Summary"
  echo
  if [ -f "$BIN_CKPT/config.json" ]; then
    "$ENV/bin/python" - <<PY
import json
p = "$BIN_CKPT/config.json"
with open(p, "r", encoding="utf-8") as f:
    cfg = json.load(f)
for k in ["hidden_size", "num_hidden_layers", "num_attention_heads", "vocab_size", "seq_fc_size", "seq_pooling_type", "seq_max_length", "input_type", "embedding_input_size"]:
    print(f"{k}: {cfg.get(k)}")
PY
  else
    echo "SKIP: config.json missing"
  fi
  echo

  echo "## 6. BPE/Vocab Line Counts"
  echo
  for f in \
    "$CODE_ROOT/subword/extra_p/extra_p_50_codes_20000.txt" \
    "$CODE_ROOT/vocab/extra_p/extra_p_50_subword_vocab_20000.txt" \
    "$BIN_CKPT/tokenizer/vocab.txt"
  do
    if [ -f "$f" ]; then
      echo "$f"
      wc -l "$f"
      head -3 "$f"
      echo "---"
    else
      echo "SKIP missing: $f"
    fi
  done
  echo

  echo "## 7. Environment Non-Torch Import Check"
  echo
  if [ -x "$ENV/bin/python" ]; then
    "$ENV/bin/python" - <<'PY'
import sys
print("python", sys.version)
mods = ["numpy", "pandas", "transformers", "tokenizers", "subword_nmt", "sklearn", "scipy", "tqdm", "Bio", "h5py"]
for m in mods:
    try:
        mod = __import__(m)
        print("OK", m, getattr(mod, "__version__", "version_not_reported"))
    except Exception as e:
        print("FAIL", m, repr(e))
PY
  else
    echo "SKIP: ENV python missing or not executable"
  fi
  echo

  echo "## 8. Torch Login-Node Check"
  echo
  echo "Torch may fail on login node; this is informational only."
  "$ENV/bin/python" - <<'PY' || true
try:
    import torch
    print("torch import OK", torch.__version__)
    print("cuda_available", torch.cuda.is_available())
except Exception as e:
    print("torch import failed on this node:", repr(e))
PY
  echo

  echo "## 9. py_compile Checks"
  echo
  if [ -x "$ENV/bin/python" ]; then
    cd "$CODE_ROOT" 2>/dev/null || echo "Cannot cd to CODE_ROOT"
    for f in \
      src/prediction_v2.py \
      src/inference.py \
      src/lucaprot/models/lucaprot.py \
      src/common/modeling_bert.py \
      src/batch_converter.py \
      src/encoder.py
    do
      if [ -f "$f" ]; then
        echo "py_compile: $f"
        "$ENV/bin/python" -m py_compile "$f" && echo "OK_COMPILE: $f" || echo "FAIL_COMPILE: $f"
      else
        echo "SKIP_MISSING: $f"
      fi
    done
  fi
  echo

  echo "## 10. Final Status"
  echo
  if [ "$missing" -eq 0 ]; then
    echo "ASSET_CHECK_STATUS=PASS_REQUIRED_FILES_PRESENT"
  else
    echo "ASSET_CHECK_STATUS=FAIL_MISSING_REQUIRED_FILES"
  fi
  echo
  echo "Do not proceed to extraction until this report is reviewed."
} | tee "$REPORT"

echo
echo "REPORT_WRITTEN=$REPORT"
