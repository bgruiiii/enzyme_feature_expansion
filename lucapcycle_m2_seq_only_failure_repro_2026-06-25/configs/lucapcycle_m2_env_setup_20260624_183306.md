# LucaPCycle M2 特征提取环境 — HPC 安装报告

## 1. 系统信息

| 项目 | 值 |
|------|-----|
| hostname | login03 |
| date | 2026-06-24 18:33 CST |
| 集群类型 | 国家超算互联网华东一区（昆山）— DCU/ROCm 集群 |
| nvidia-smi | 不可用（无 NVIDIA GPU） |
| rocm-smi | 登录节点不可用 |
| Loaded Modules | compiler/devtoolset/7.3.1, mpi/hpcx/2.11.0/gcc-7.3.1, compiler/rocm/dtk-23.10 |
| GPU 类型 | DCU（海光），需 `module load compiler/rocm/dtk-23.10` |

## 2. 环境路径与类型

| 项目 | 值 |
|------|-----|
| **环境路径** | `/public/home/acfbwjsi7s/envs/lucapcycle_m2` |
| **环境类型** | Python venv（基于 `nis` conda 环境，`--system-site-packages`） |
| **Python 可执行文件** | `/public/home/acfbwjsi7s/envs/lucapcycle_m2/bin/python` |
| **Python 版本** | 3.9.23 |

> **说明**: 因登录节点内存限制，conda solver 频繁 OOM，故改用 `python -m venv --system-site-packages` 方式创建。  
> 该 venv 继承 `nis` conda 环境的全部包（包括 DCU 编译版 PyTorch），并额外安装了 M2 所需 Python 包。  
> **激活方式**: `source /public/home/acfbwjsi7s/envs/lucapcycle_m2/bin/activate`

## 3. PyTorch 版本

| 项目 | 值 |
|------|-----|
| torch | 1.13.1+git7d2dd01.abi0.dtk2310 |
| 编译工具链 | DCU DTK 23.10（非 CUDA，非标准 ROCm） |
| CUDA 可用 | **否**（无 NVIDIA GPU） |
| DCU 可用 | 仅计算节点可用（登录节点缺少 DCU 硬件驱动，`import torch` 报 `libgalaxyhip.so.5` 符号缺失） |
| torchaudio | 2.0.2+rocm5.4.2 |
| torchvision | 0.14.1+gitf78f29f.abi0.dtk2310.torch1.13 |
| pytorch-triton-rocm | 2.0.1 |

> **重要**: torch 在登录节点 **无法 import**（`ImportError: symbol roctracer_next_record`），这是正常的——只有提交 SLURM 作业到 DCU 计算节点后才能正常加载。  
> **SLURM 作业中需要**: `module load compiler/rocm/dtk-23.10`

## 4. Import 检查完整输出

### 4.1 非 torch 包（登录节点检查 — 全部通过）

```
python 3.9.23 (main, Jun  5 2025, 13:40:20) [GCC 11.2.0]
torch SKIPPED - DCU runtime not available on login node, expected
numpy 1.26.4
pandas 2.0.3
transformers 4.29.0
tokenizers 0.13.2
subword_nmt import OK
sklearn 1.6.1
scipy 1.12.0
tqdm 4.68.3
biopython 1.80
h5py 3.14.0
statsmodels 0.14.0
sentencepiece import OK
sacremoses import OK
pynvml import OK
packaging 26.2
matplotlib 3.9.4
requests 2.28.1
ALL NON-TORCH IMPORTS PASSED
```

### 4.2 torch（登录节点 — 预期失败）

```
ImportError: /public/home/acfbwjsi7s/miniconda3/envs/nis/lib/python3.9/site-packages/torch/lib/libtorch_cpu.so:
  symbol roctracer_next_record, version HIP not defined in file libgalaxyhip.so.5 with link time reference
```

> 在 DCU 计算节点上 `module load compiler/rocm/dtk-23.10` 后可正常 import。

## 5. 已安装 M2 相关包清单

| 包名 | 版本 | 来源 |
|------|------|------|
| numpy | 1.26.4 | nis 环境继承 |
| pandas | 2.0.3 | nis 环境继承 |
| scipy | 1.12.0 | nis 环境继承 |
| scikit-learn | 1.6.1 | nis 环境继承 |
| tqdm | 4.68.3 | nis 环境继承 |
| h5py | 3.14.0 | nis 环境继承 |
| matplotlib | 3.9.4 | nis 环境继承 |
| requests | 2.28.1 | nis 环境继承 |
| **transformers** | **4.29.0** | pip 新装 |
| **tokenizers** | **0.13.2** | pip 新装 |
| **subword-nmt** | **0.3.8** | pip 新装 |
| **sentencepiece** | **0.1.97** | pip 新装 |
| **sacremoses** | **0.0.53** | pip 新装 |
| **biopython** | **1.80** | pip 新装 |
| **statsmodels** | **0.14.0** | pip 新装 |
| **pynvml** | **11.5.0** | pip 新装 |
| packaging | 26.2 | pip 新装 |
| torch | 1.13.1+git7d2dd01.abi0.dtk2310 | nis 环境继承（DCU 编译版） |

## 6. LucaPCycle 实际路径

**尚未上传到 HPC。**

已搜索路径：
- `/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3` → 不存在
- `/public/home/acfbwjsi7s/Luca*` → 无匹配
- `find -name "prediction_v2.py" -path "*/src/*"` → 无结果

## 7. BPE / Vocab 文件检查

| 文件 | 状态 |
|------|------|
| `subword/extra_p/extra_p_50_codes_20000.txt` | **待上传** |
| `vocab/extra_p/extra_p_50_subword_vocab_20000.txt` | **待上传** |

## 8. Checkpoint 检查

**二分类 checkpoint 目录**（预期路径）：
```
models/extra_p_2_class_v3/protein/binary_class/lucaprot/seq_matrix/20240924203640/checkpoint-264284/
```

| 必需文件 | 状态 |
|----------|------|
| config.json | **待上传** |
| pytorch_model.bin | **待上传** |
| training_args.bin | **待上传** |
| tokenizer/special_tokens_map.json | **待上传** |
| tokenizer/tokenizer_config.json | **待上传** |
| tokenizer/vocab.txt | **待上传** |

## 9. py_compile 编译检查

**跳过** — LucaPCycle 代码尚未上传。

待上传后需检查的文件：
- `src/prediction_v2.py`
- `src/lucaprot/models/lucaprot.py`
- `src/common/modeling_bert.py`
- `src/batch_converter.py`
- `src/encoder.py`

## 10. 禁止项确认

| 检查项 | 结果 |
|--------|------|
| 是否安装了 tensorflow | **否** |
| 是否安装了 fair-esm | **否** |
| 是否安装了 deepspeed | **否** |
| 是否执行了训练 | **否** |
| 是否执行了全量 M2 提取 | **否** |
| 是否修改了 EnzymeCAGE train.py | **否** |

## 11. 下一步建议

1. **等待本地上传 LucaPCycle V3 代码和 checkpoint 到 HPC**  
   建议上传到：`/public/home/acfbwjsi7s/LucaPCycle-3/LucaPCycle-3/`
2. 上传完成后执行：
   - 关键文件存在性检查（BPE codes、vocab、checkpoint 6 文件）
   - `py_compile` 编译检查（5 个核心 .py 文件）
3. **等待本地提供 10 条 UID 小样本提取测试脚本**
4. 提交 SLURM 作业到 DCU 计算节点验证：
   - `module load compiler/rocm/dtk-23.10`
   - `source /public/home/acfbwjsi7s/envs/lucapcycle_m2/bin/activate`
   - `python -c "import torch; print(torch.__version__, torch.cuda.is_available())"`
   - 运行小样本 M2 提取测试

## 12. SLURM 作业模板

```bash
#!/bin/bash
#SBATCH --job-name=lucap_m2_test
#SBATCH --partition=dcu          # 按实际分区名调整
#SBATCH --nodes=1
#SBATCH --gres=dcu:1             # 按实际需求调整
#SBATCH --time=01:00:00

module load compiler/rocm/dtk-23.10
source /public/home/acfbwjsi7s/envs/lucapcycle_m2/bin/activate

python -c "import torch; print('torch', torch.__version__, 'cuda_available', torch.cuda.is_available())"
```
