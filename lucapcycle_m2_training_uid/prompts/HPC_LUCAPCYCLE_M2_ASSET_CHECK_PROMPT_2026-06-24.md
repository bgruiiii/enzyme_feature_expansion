# HPC LucaPCycle M2 Asset Check Prompt

Date: 2026-06-24

Copy the following prompt to the HPC-side AI.

---

你现在在 HPC 上帮我做 **LucaPCycle M2 特征提取前的资产完整性检查**。这一步只允许检查文件、路径、配置、轻量编译和环境状态；**不要训练、不要全量提取、不要修改 EnzymeCAGE 训练代码、不要启动长任务**。

## 背景

我们要提取的是 LucaPCycle 论文中的 M2：

```text
amino-acid sequence
-> BPE / subword word-level tokenization
-> LucaPCycle trained Transformer seq_encoder
-> M2 representation
```

原论文的 M1 是 ESM2-3B，但我们项目中用已经在 HPC 上存在的 ESM600M / ESM-C 600M 酶序列特征替代 M1。本次只检查 M2 所需资产是否齐全。

重要边界：

- **M2 提取不需要 ESM/ESM-C/ESM2 模型参与。**
- 本次检查不要安装 `esm`、`fair-esm`，也不要加载 `ESMC.from_pretrained(...)`。
- ESM600M / ESM-C 600M 只是在后续融合训练时作为已经存在的 M1 替代特征使用。
- 之前项目中使用的 ESM 序列模型版本是 `ESMC.from_pretrained("esmc_600m")`，输出目录风格是 `ESM-C_600M/node_level` 和 `ESM-C_600M/protein_level/seq2feature.pkl`。这次 M2 检查不验证这些 ESM 文件，后续会单独做 ESM 资产一致性审计。

## 已上传路径

```text
CODE_ROOT=/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3
CKPT_ROOT=/public/home/acfbwjsi7s/LucaPCycle-3/TrainedCheckPoint
ENV=/public/home/acfbwjsi7s/envs/lucapcycle_m2
```

## 必须检查的内容

1. 代码目录是否存在：

```text
$CODE_ROOT
$CODE_ROOT/src
$CODE_ROOT/subword
$CODE_ROOT/vocab
$CODE_ROOT/README.md
$CODE_ROOT/requirements.txt
```

2. BPE / vocab 文件是否存在：

```text
$CODE_ROOT/subword/extra_p/extra_p_50_codes_20000.txt
$CODE_ROOT/vocab/extra_p/extra_p_50_subword_vocab_20000.txt
```

3. V3 二分类 checkpoint 是否存在：

```text
$CKPT_ROOT/models/extra_p_2_class_v3/protein/binary_class/lucaprot/seq_matrix/20240924203640/checkpoint-264284/
```

并检查以下文件：

```text
config.json
pytorch_model.bin
training_args.bin
tokenizer/special_tokens_map.json
tokenizer/tokenizer_config.json
tokenizer/vocab.txt
```

4. 可选检查 V3 31-class checkpoint 是否也存在：

```text
$CKPT_ROOT/models/extra_p_31_class_v3/protein/multi_class/lucaprot/seq_matrix/20240923094428/checkpoint-8569250/
```

5. 检查 checkpoint 配置中的关键字段。二分类 checkpoint 的 `config.json` 应至少报告：

```text
hidden_size
num_hidden_layers
num_attention_heads
vocab_size
seq_fc_size
seq_pooling_type
seq_max_length
```

预期大致为：

```text
hidden_size = 1024
num_hidden_layers = 4
num_attention_heads = 8
seq_fc_size = [256]
seq_pooling_type = value_attention
```

6. 激活环境后做非 torch import 检查。登录节点 torch import 可能失败，这是预期的，不要因此判断失败。

7. 对 LucaPCycle 核心源码做 `py_compile` 语法检查：

```text
src/prediction_v2.py
src/inference.py
src/lucaprot/models/lucaprot.py
src/common/modeling_bert.py
src/batch_converter.py
src/encoder.py
```

如果有文件不存在，请记录，不要自己乱改。

8. 不要运行 M2 提取；不要跑 `prediction_v2.py` 做预测；不要提交全量任务。

9. 不要检查、重算或覆盖 ESM600M / ESM-C 600M 特征。本轮只检查 LucaPCycle M2 所需代码、BPE/vocab、checkpoint 和环境。

## 请运行的检查脚本

请在 HPC 上执行下面这段命令，并把完整输出保存为 markdown 报告：

```bash
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
```

## 需要你最后回复我的内容

请把以下内容贴回来：

1. markdown 报告路径；
2. `ASSET_CHECK_STATUS`；
3. `Missing required file count`；
4. checkpoint config 摘要；
5. `py_compile` 是否全部通过；
6. torch 在登录节点是否失败，如果失败，把错误贴出来即可；
7. 是否发现 checkpoint 被多套了一层目录，比如 `TrainedCheckPoint/TrainedCheckPoint/models/...`。

不要继续做 M2 提取，等我审核检查报告后再进入下一小步。
