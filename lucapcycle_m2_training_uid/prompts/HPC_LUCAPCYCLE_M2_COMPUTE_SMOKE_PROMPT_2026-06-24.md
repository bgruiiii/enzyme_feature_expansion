# HPC LucaPCycle M2 Compute-Node Smoke Test Prompt

Date: 2026-06-24

Copy the following prompt to the HPC-side AI **after** the asset check has
passed.

---

你现在在 HPC 上帮我做 **LucaPCycle M2 计算节点 smoke test**。

这一步的目的只有一个：确认 DCU/ROCm 计算节点上 `torch` 可以 import，并且 LucaPCycle V3 二分类 checkpoint 可以被 `torch.load(..., map_location="cpu")` 正常读取，state_dict 中能看到 M2 所需的 `seq_encoder` 权重。

## 禁止事项

- 不要训练。
- 不要全量提取。
- 不要运行 `prediction_v2.py` 做预测。
- 不要加载 ESM/ESM-C/ESM2。
- 不要安装 `esm`、`fair-esm`、`deepspeed`、`tensorflow`。
- 不要修改 EnzymeCAGE 训练代码。
- 不要生成任何 M2 特征文件。

## 背景边界

M2 不需要 ESM。M2 路线是：

```text
sequence -> BPE/subword tokens -> LucaPCycle seq_encoder -> M2
```

原论文 M1 是 ESM2-3B，但我们项目中用已经在 HPC 上存在的 `ESMC.from_pretrained("esmc_600m")` / `ESM-C_600M` 序列特征替代 M1。这个 smoke test 不检查、不重算、不覆盖 ESM600M 特征。

## 已知路径

```text
CODE_ROOT=/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3
CKPT_ROOT=/public/home/acfbwjsi7s/LucaPCycle-3/TrainedCheckPoint
ENV=/public/home/acfbwjsi7s/envs/lucapcycle_m2
BIN_CKPT=/public/home/acfbwjsi7s/LucaPCycle-3/TrainedCheckPoint/models/extra_p_2_class_v3/protein/binary_class/lucaprot/seq_matrix/20240924203640/checkpoint-264284
```

前一步资产检查已经通过：

```text
ASSET_CHECK_STATUS=PASS_REQUIRED_FILES_PRESENT
Missing required file count: 0
```

## 请执行的任务

1. 在 HPC 上创建一个短 SLURM 作业脚本。
2. 提交到 DCU 计算节点。
3. 在作业里执行：
   - `module load compiler/rocm/dtk-23.10`
   - `source /public/home/acfbwjsi7s/envs/lucapcycle_m2/bin/activate`
   - import torch 并打印版本、`torch.cuda.is_available()`、设备数量。
   - `torch.load("$BIN_CKPT/pytorch_model.bin", map_location="cpu")`
   - 判断 checkpoint 对象类型。
   - 如果是 dict，抽取 state_dict。
   - 打印 key 总数、前 30 个 key。
   - 统计包含以下关键词的 key 数：
     - `seq_encoder`
     - `seq_pooler`
     - `seq_linear`
     - `embedding`
     - `classifier`
   - 打印几个 `seq_encoder` 相关 key 及 shape。
   - 读取 `config.json` 并再次打印关键字段。
4. 把完整结果写入 markdown 报告。
5. 不要继续做 M2 提取，等我审核报告。

## 推荐 SLURM 脚本

请先执行下面这段命令。若分区名或 DCU 资源参数不适合当前集群，可以只调整 `#SBATCH --partition` 和 `#SBATCH --gres`，其他逻辑不要改。

```bash
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
```

## 需要你最后回复我的内容

请等 SLURM 作业结束后，把下面内容贴回来：

1. markdown 报告路径；
2. SLURM job id；
3. `.out` 和 `.err` 文件路径；
4. `torch_import` 是否 OK；
5. `torch_version`；
6. `torch_cuda_is_available` 和设备数；
7. `SMOKE_STATUS`；
8. `match_count[seq_encoder]`、`match_count[seq_pooler]`、`match_count[seq_linear]`；
9. 如果 `.err` 非空，贴出前 80 行。

不要继续做 M2 提取，等我审核这份 smoke test 报告。
