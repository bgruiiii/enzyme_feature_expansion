## Database Progress

### Current Snapshot

- Rhea raw snapshot: `RHEA-140_2026-01-21`
- Raw data path: `data/raw/rhea/RHEA-140_2026-01-21/`
- Cleaned output path: `data/processed/rhea/2026-01-21/`

### Cleaning Status

- [x] Rhea raw package unpacked and verified
- [x] `uid2seq.pkl` rebuilt for this snapshot
- [x] Original `scripts/rhea_data_cleaning.py` run on the 2026-01-21 snapshot
- [x] Main cleaned positive-pair table generated
- [x] Reaction failure table generated
- [x] Missing-sequence table generated

### Current Outputs

- `data/processed/rhea/2026-01-21/rhea_rxn2uids.csv`
  - Main positive `reaction-enzyme` table
- `data/processed/rhea/2026-01-21/rhea_rxn_filtered.csv`
  - Reactions filtered out or failed during canonicalization
- `data/processed/rhea/2026-01-21/rhea_no-seq_filtered.csv`
  - Enzymes missing sequences after UID-to-sequence mapping
- `data/processed/rhea/2026-01-21/asset_reuse/`
  - 2026 asset reuse manifest and backfill input tables

### 2026 Protein Feature Asset Status

- ESM-C sequence-level node features are expected to be complete on cloud:
  - `G:\esm\ESM-C_600M\node_level\*.npz`
  - expected count: `195,743`
- Original EnzymeCAGE pooling for ESM-C sequence features:
  - source tensor per UID:
    - `node_feature`
    - shape `(sequence_length, 1152)`
  - pooling:
    - mean over the sequence/residue dimension
  - pooled tensor:
    - shape `(1152,)`
  - pooled dictionary:
    - `G:\esm\ESM-C_600M\protein_level\seq2feature.pkl`
    - expected entries: `164,514`, equal to unique sequence count
- Pocket-node status:
  - completed on cloud in custom sharded storage format:
    - `G:\esm\ESM-C_600M\pocket_node_feature_full_valid_sharded_20260422`
  - valid rows/features:
    - `191,062`
  - per-UID tensor remains original-style unpooled:
    - `(pocket_residue_count, 1152)`
- Current policy:
  - treat ESM sequence mean pooling and unpooled pocket-node matrices as the
    official original-model reproduction route.
  - any custom pooled/256-dimensional feature must be logged as a separate
    ablation and must not overwrite these original-style assets.
- Validation plan document:
  - `custom/docs/ESM_SEQUENCE_POOLING_EXPERIMENT_PLAN_2026-04-23.md`
- Execution location for the next validation:
  - cloud Windows machine first
  - do not rerun ESM-C
  - do not rerun pocket-node
  - do not overwrite current feature files

### Microorganism Step 1 Status

- Step 1 source main table:
  - `data/processed/rhea/2026-01-21/rhea_rxn2uids.csv`
- Step 1 output:
  - `data/processed/rhea/2026-01-21/microbe/uid_list.csv`
  - `data/processed/rhea/2026-01-21/microbe/uid_list_summary.json`
- Step 1 result:
  - source rows: `320,043`
  - unique `UniprotID`: `195,743`

### Microorganism Step 2 Design

This step will build:

- `uid_to_source.csv`

Purpose:

- map each unique `UniprotID` to its source microorganism metadata
- do **not** download genomes yet
- do **not** select final assemblies yet

Official sources selected after checking live APIs and official docs:

1. UniProtKB REST
   - endpoint family:
     - `https://rest.uniprot.org/uniprotkb/...`
   - recommended mode:
     - chunked `stream` queries over `UniprotID`
   - confirmed usable fields:
     - `accession`
     - `organism_name`
     - `organism_id`
     - `xref_proteomes`
     - `reviewed`
     - `gene_primary`
     - `lineage`

2. UniProt Proteomes REST
   - endpoint family:
     - `https://rest.uniprot.org/proteomes/...`
   - used after parsing unique `UPID` values from `xref_proteomes`
   - useful fields:
     - `upid`
     - `organism`
     - `organism_id`
     - `lineage`
     - `genome_assembly`
   - full JSON also exposes:
     - `strain`
     - `genomeAssembly`

3. NCBI Datasets / Assembly
   - used later, after `uid_to_source.csv`, for:
     - candidate genome search
     - final genome download

Current agreed design note:

- `TaxID`, `organism_name`, `lineage`, and proteome cross-references should
  come from UniProtKB.
- `strain` and final `assembly_accession` should not be assumed to come
  directly and reliably from the first UniProtKB pass.
- Candidate assembly search must therefore remain a later step.

Planned `uid_to_source.csv` columns:

- `UniprotID`
- `TaxID`
- `organism_name`
- `lineage`
- `reviewed`
- `gene_primary`
- `proteome_raw`
- `proteome_id`
- `proteome_count`
- `source_signature`
- `source_db`
- `mapping_confidence`

Exact source-level dedup standard for the next step:

- next output:
  - `source_signature_catalog.csv`
- dedup key field:
  - `source_signature`
- construction priority:
  1. exactly one `proteome_id`
     - `source_signature = proteome:<UPID>`
  2. otherwise, if both `TaxID` and `strain_name` exist
     - normalize `strain_name` by trim + whitespace collapse + lowercase
     - `source_signature = taxon:<TaxID>|strain:<normalized_strain_name>`
  3. otherwise, if both `TaxID` and `organism_name` exist
     - normalize `organism_name` by trim + whitespace collapse + lowercase
     - `source_signature = taxon:<TaxID>|organism:<normalized_organism_name>`
  4. otherwise
     - `source_signature = uid:<UniprotID>`

Explicit non-keys at this stage:

- enzyme sequence
- EC number
- gene name
- final genome assembly accession

Ambiguity rule:

- rows with `proteome_count > 1` are marked:
  - `source_resolution_level = taxon_organism`
  - `is_ambiguous = 1`
- rows without multi-proteome conflict keep:
  - `is_ambiguous = 0`
- this makes ambiguous fallback rows separable from ordinary taxon-level rows

Current rebuilt `uid_to_source.csv` summary under the revised rule:

- `uid_count`: `195,743`
- `uid_matched_in_uniprotkb`: `195,743`
- `unique_proteome_ids`: `2,176`
- `uids_with_single_proteome`: `150,042`
- `uids_with_multi_proteome`: `5,530`
- `uids_with_no_proteome`: `40,171`
- `uids_with_proteome_assembly`: `149,932`
- `source_resolution_level = proteome`: `150,042`
- `source_resolution_level = taxon_organism`: `45,701`
- `source_resolution_level = taxon_strain`: `0`
- `ambiguous_uid_count`: `5,530`

Current step-2 execution status:

- builder script created:
  - `custom/data_build/build_uid_to_source_from_uniprot.py`
- validated on a 20-UID live sample:
  - `20 / 20` matched in UniProtKB
  - `8` unique `UPID` values recovered
  - UniProt Proteomes enrichment returned `strain` and `genome_assembly` as expected
- full strict-2026 execution has now been started with:
  - `chunk_size=100`
  - `proteome_chunk_size=100`
- intermediate outputs will accumulate under:
  - `data/processed/rhea/2026-01-21/microbe/uniprotkb_chunks/`
  - `data/processed/rhea/2026-01-21/microbe/proteome_chunks/`

User execution preference reaffirmed:

- proceed strictly one step at a time
- do not skip ahead to later microorganism/genome tables before the current
  table is completed and checked

### Local AlphaFill Installation Progress

- External storage root for this branch:
  - `/mnt/f/酶智能体/enzymecage_external`
- Current build environment:
  - `/home/a/EnzymeCAGE/.envs/alphafill-build`
- Resolved blocker:
  - conda-forge `libmcfp 2.0.1` was incompatible with AlphaFill source
  - replaced for AlphaFill purposes by official `libmcfp v1.3.4` installed at:
    - `/home/a/EnzymeCAGE/.deps/mcfp-1.3.4`
- Additional compatibility resolution:
  - installed `libcifpp 9.0.5` from user-provided source into:
    - `/home/a/EnzymeCAGE/.deps/cifpp-9.0.5`
  - added compatibility header:
    - `/home/a/EnzymeCAGE/.envs/alphafill-build/include/mxml/serialize.hpp`
  - restored runtime `zeem` symlink compatibility for `libzeep 7.3.2`
- Local AlphaFill installation result:
  - executable path:
    - `/home/a/EnzymeCAGE/.deps/alphafill-2.3.0/bin/alphafill`
  - verified command:
    - `alphafill --version`
  - observed output:
    - `alphafill version 2.3.0`
- Current next blocker:
  - local `PDB-REDO` data is still missing
  - AlphaFold input structures for the unresolved UID set are not prepared yet
- Immediate next step:
  - confirm and stage official `PDB-REDO` download under:
    - `/mnt/f/酶智能体/enzymecage_external/pdb_redo`
- Official PDB-REDO route confirmed:
  - current databank sync:
    - `rsync -av --exclude=attic rsync://rsync.pdb-redo.eu/pdb-redo/ pdb-redo/`
  - full archive sync:
    - `rsync -av rsync://rsync.pdb-redo.eu/pdb-redo/ pdb-redo/`
- AlphaFill indexing implication confirmed:
  - `pdbredo_seqdb.txt` does not need to be downloaded separately first
  - it can be generated locally from the downloaded mmCIF tree using:
    - `alphafill create-index --pdb-dir ... --pdb-fasta ...`
- Current new blocker after executable installation:
  - the official `rsync://rsync.pdb-redo.eu/pdb-redo/` endpoint is currently unreachable from WSL/Linux
  - observed error:
    - `No route to host`
- New fallback route confirmed:
  - Windows-side connectivity to `rsync.pdb-redo.eu:873` is available
  - user-installed MSYS2 path:
    - `F:\enzymecage\tools\msys64`
  - `rsync` has been installed there and verified working
  - remote directory listing via that Windows-side MSYS2 succeeds
- Prepared reusable sync helper:
  - `custom/data_build/sync_pdb_redo_to_external.sh`
  - default target:
    - `/mnt/f/酶智能体/enzymecage_external/pdb_redo`
- Important path decision for the actual PDB-REDO mirror:
  - because MSYS2 does not handle non-ASCII paths robustly, the mirror target is now switched to an English external path:
    - Windows: `F:\enzymecage_external\pdb_redo`
    - WSL: `/mnt/f/enzymecage_external/pdb_redo`
  - a small probe file `LICENSE.txt` has already been synced successfully to that location
- Prepared Windows-side sync helper:
  - `custom/data_build/sync_pdb_redo_via_windows_msys2.sh`
- Current runtime state:
  - the full `PDB-REDO` sync is actively running through the Windows-side MSYS2 route
  - the older `pdb_redo_sync_progress.log` / `pdb_redo_sync_status.log` paths exist
    but are not authoritative for the current resumed transfer
  - current authoritative live minute monitor:
    - `/home/a/EnzymeCAGE/pdb_redo_sync_status_live.log`
  - monitor implementation:
    - `custom/data_build/monitor_pdb_redo_drive_delta_minutely.py`

### 2026-04-13 PDB-REDO Sync Control Update

- The resumed mirror on `F:\enzymecage_external\pdb_redo` was confirmed to be
  capable of real transfer again on `2026-04-13`.
- Representative foreground `rsync` file-transfer rates observed during the
  recovered window were in the approximate range of `10-24 MB/s` for some files.
- A lightweight minute monitor was attached at:
  - `/home/a/EnzymeCAGE/pdb_redo_sync_status_live.log`
- Diagnostic result from the later same-day stalled state:
  - TCP connectivity to `rsync.pdb-redo.eu:873` could remain established
  - worker processes could remain alive
  - yet effective byte growth could return to ~zero
  - consistent with very slow directory / metadata traversal rather than clean
    network loss
- Operational decision after this diagnosis:
  - stop treating WSL-side orchestration as the preferred operator path
  - prefer direct Windows-local manual control
  - reusable launcher:
    - `custom/data_build/run_pdb_redo_sync_windows_local.ps1`

### Cleaning Summary

- Raw `reaction-enzyme` rows from `rhea2uniprot_sprot.tsv`: `391,027`
- Raw unique `UniprotID`: `236,103`
- Polymer reactions without usable SMILES: `336`
- Rows missing SMILES after Rhea mapping: `18,626`
- Rows remaining after SMILES mapping: `372,401`
- Unique raw reaction SMILES before cleaning: `13,619`
- Unique reactions failed during canonicalization/filtering: `1,747`
- Pair rows removed by reaction cleaning: `41,888`
- Pair rows missing sequence: `0`
- Pair rows removed by sequence length > 1000: `12,188`
- Final cleaned positive pairs: `320,043`
- Final keep ratio from raw pairs: `81.8468%`

### Comparison With Original Project Tables

#### Main cleaned table

- Our current table:
  - `data/processed/rhea/2026-01-21/rhea_rxn2uids.csv`
  - rows: `320,043`
  - unique `RHEA_ID`: `18,533`
  - unique `CANO_RXN_SMILES`: `11,418`
  - unique `UniprotID`: `195,743`

- Original project 2025 snapshot:
  - `dataset/RHEA/2025-02-05/rhea_rxn2uids.csv`
  - rows: `300,476`
  - unique `RHEA_ID`: `17,064`
  - unique `CANO_RXN_SMILES`: `10,617`
  - unique `UniprotID`: `191,567`

- Original project 2023 snapshot:
  - `dataset/RHEA/2023-07-12/rhea_rxn2uids.csv`
  - rows: `307,027`
  - unique `RHEA_ID`: `16,756`
  - unique `CANO_RXN_SMILES`: `10,783`
  - unique `UniprotID`: `198,291`

#### Important note on schema

- Our 2026 cleaned table currently has:
  - `RHEA_ID, DIRECTION, MASTER_ID, UniprotID, SMILES, EC number, CANO_RXN_SMILES, sequence, reverse_template, n_seq`
- The original packaged 2025 table also has:
  - `rxnmapper_template, localmapper_template`
- This means:
  - We have reproduced the original **core cleaning step**
  - We have **not yet** reproduced the later template-enrichment step that added those two columns

### Table Mapping: Original Project vs Our Current Work

- Original project `rhea_rxn2uids.csv`
  - Status: done
  - Our equivalent: `data/processed/rhea/2026-01-21/rhea_rxn2uids.csv`

- Original project `rhea_rxn_filtered.csv`
  - Status: done
  - Our equivalent: `data/processed/rhea/2026-01-21/rhea_rxn_filtered.csv`

- Original project `rhea_no-seq_filtered.csv`
  - Status: done
  - Our equivalent: `data/processed/rhea/2026-01-21/rhea_no-seq_filtered.csv`

- Original project `all_enzymes.csv`
  - Status: done
  - Our equivalent: `data/processed/rhea/2026-01-21/all_enzymes.csv`

- Original project training tables such as `training/train.csv` and `training/valid.csv`
  - Status: not done yet
  - Not needed for the current database-construction milestone

- Original project feature assets under `feature/`, `pockets/`, and reaction fingerprints
  - Status: partially done
  - Current state:
    - cleaned main table: done
    - reaction features: done for 2026
    - pocket assets: not done yet for 2026
    - protein features: not done yet for 2026

- Our future `reaction_dim.csv`
  - Status: not done yet
  - Planned new table

- Our future `enzyme_dim.csv`
  - Status: not done yet
  - Planned new table

- Our future `microbe_dim.csv`
  - Status: not done yet
  - Planned new table

- Our future `reaction_enzyme_microbe.csv`
  - Status: not done yet
  - Planned new table

- Our future `microbe_substrate_pref.csv`
  - Status: not done yet
  - Planned new table

### Original Dataset Asset Gap Analysis

The original downloaded dataset is now available locally at `dataset/`.

The original downloaded dataset contains more than the cleaned pair table.

For `RHEA/2025-02-05`, the important pieces are:

- `rhea_rxn2uids.csv`
  - cleaned main pair table
- `all_enzymes.csv`
  - enzyme pool table for protein feature extraction
- `pockets/pocket_info.csv`
  - pocket residue metadata
- `pockets/pocket/*.pdb`
  - pre-extracted enzyme pocket structures
- `feature/reaction/drfp/rxn2fp.pkl`
  - reaction fingerprint asset
- `feature/reaction/reacting_center/rxn2aam.pkl`
  - atom-mapped reactions
- `feature/reaction/reacting_center/reacting_center.pkl`
  - reaction center index asset
- `feature/reaction/molecule_conformation/*.sdf`
  - molecule 3D conformations

Important observation:

- In the downloaded original dataset, `feature/reaction/*` is already present.
- But `feature/protein/*` is not present in the local packaged data we inspected.
- This matches the README: users are expected to calculate protein features themselves from `all_enzymes.csv` and the provided pockets.

So compared with the original dataset/feature stack, our current 2026 snapshot is still missing:

- `all_enzymes.csv`
- reaction feature assets under `feature/reaction/`
- pocket assets under `pockets/`
- protein feature assets under `feature/protein/`
- microorganism mapping and microorganism features

Among these, the biggest blocker is:

- 2026 pocket / structure source

because reaction features can be regenerated directly from the cleaned main table, but protein 3D features require pocket PDB files first.

Current reuse-first conclusion:

- We should not rebuild everything from zero first.
- We should first reuse compatible assets from the 2025 packaged dataset.
- Then we should supplement only:
  - newly added 2026 reactions
  - newly added 2026 enzymes
  - enzymes whose sequences changed between the old and new snapshots

### 2026 Asset Reuse Manifest

Generated under:

- `data/processed/rhea/2026-01-21/asset_reuse/reaction_asset_reuse.csv`
- `data/processed/rhea/2026-01-21/asset_reuse/reaction_asset_gap.csv`
- `data/processed/rhea/2026-01-21/asset_reuse/enzyme_asset_reuse.csv`
- `data/processed/rhea/2026-01-21/asset_reuse/enzyme_asset_gap.csv`
- `data/processed/rhea/2026-01-21/asset_reuse/asset_reuse_summary.json`

Backfill input tables prepared for the next step:

- `data/processed/rhea/2026-01-21/asset_reuse/all_enzymes_2026.csv`
- `data/processed/rhea/2026-01-21/asset_reuse/reaction_feature_backfill_input.csv`
- `data/processed/rhea/2026-01-21/asset_reuse/enzyme_feature_backfill_input.csv`
- `data/processed/rhea/2026-01-21/asset_reuse/enzyme_pocket_backfill_input.csv`

Reaction-side summary:

- total 2026 unique reactions: `11,418`
- can directly reuse all old reaction assets: `10,561`
- still need only reaction-level assets: `178`
- still need only molecule conformations: `0`
- still need both reaction-level assets and molecule conformations: `679`
- total reaction gaps to backfill: `857`

Enzyme-side summary:

- total 2026 unique enzymes: `195,743`
- can directly reuse old pocket + sequence inputs: `188,745`
- missing old pocket assets: `2,139`
- sequence changed and should recompute: `626`
- sequence changed and old pocket also missing: `9`
- pocket exists but sequence source needs recheck: `100`
- brand-new UIDs needing full backfill: `4,124`
- total enzyme gaps to backfill: `6,998`

Interpretation:

- Reaction assets are mostly reusable from the old dataset.
- Enzyme-side gaps are concentrated in a much smaller subset than the full 2026 enzyme pool.
- The immediate low-risk next step is reaction asset backfill, because it depends only on the cleaned main table.
- Enzyme pocket backfill still needs a 2026 structure / pocket source for the gap set.

### Materialized 2026 Assets So Far

Already materialized into the 2026 processed snapshot:

- `data/processed/rhea/2026-01-21/all_enzymes.csv`
- `data/processed/rhea/2026-01-21/feature/reaction/drfp/rxn2fp.pkl`
- `data/processed/rhea/2026-01-21/feature/reaction/reacting_center/rxn2aam.pkl`
- `data/processed/rhea/2026-01-21/feature/reaction/reacting_center/reacting_center.pkl`
- `data/processed/rhea/2026-01-21/feature/reaction/molecule_conformation/mol2id.csv`
- `data/processed/rhea/2026-01-21/feature/reaction/molecule_conformation/*.sdf`
- `data/processed/rhea/2026-01-21/feature/reaction/reuse_summary.json`

Current materialized reaction-asset coverage:

- reusable reactions already written into 2026 assets: `10,561`
- reusable molecules already written into 2026 assets: `9,448`
- reusable molecule conformations already linked/copied: `9,448`
- reaction assets still missing and need computation before backfill: `857`
- after repairing `localmapper` and running the incremental backfill:
  - `rxn2aam.pkl`: `11,418` reactions
  - `reacting_center.pkl`: `11,418` reactions
  - `rxn2fp.pkl`: `12,187` keys
  - `molecule_conformation/*.sdf`: `10,193` files out of `10,193` listed molecules
  - `failed_ids.csv`: header only, no failed molecule IDs
- reaction-side asset gap is now closed for the current 2026 snapshot

### Enzyme-Side Reuse Materialization

We have now started the enzyme-side baseline by materializing safe reusable pocket assets into the 2026 workspace.

Outputs:

- `data/processed/rhea/2026-01-21/pockets/reuse_pocket/*.pdb`
- `data/processed/rhea/2026-01-21/pockets/reuse_pocket_info.csv`
- `data/processed/rhea/2026-01-21/asset_reuse/enzyme_pocket_ready_now.csv`
- `data/processed/rhea/2026-01-21/asset_reuse/enzyme_pocket_ready_links.csv`
- `data/processed/rhea/2026-01-21/asset_reuse/enzyme_pocket_recheck.csv`
- `data/processed/rhea/2026-01-21/asset_reuse/enzyme_structure_external_needed.csv`
- `data/processed/rhea/2026-01-21/asset_reuse/enzyme_structure_external_needed.txt`
- `data/processed/rhea/2026-01-21/asset_reuse/enzyme_structure_download_manifest.csv`
- `data/processed/rhea/2026-01-21/asset_reuse/enzyme_pocket_reuse_summary.json`

Current enzyme-side split:

- safe reusable old pockets already materialized: `188,745`
- old pockets needing recheck before final use: `726`
- enzymes still needing external structure source: `6,272`

AlphaFill download preparation:

- added downloader script:
  - `custom/data_build/download_alphafill_gap_entries.py`
- validated the direct AlphaFill route with a 5-entry sample:
  - success: `2`
  - `404` not found: `3`
- sample status table:
  - `data/processed/rhea/2026-01-21/asset_reuse/alphafill_gap_sample_status.csv`
- sample downloaded files:
  - `data/raw/rhea/RHEA-140_2026-01-21/alphafill_gap_sample/`

Planned structure-acquisition strategy:

1. Do **targeted download by enzyme UID list**, not full AlphaFill mirroring.
2. For each UID in `enzyme_structure_download_manifest.csv`, first try direct AlphaFill entry download:
   - `.cif`
   - `.json`
3. If the AlphaFill entry exists:
   - store raw files under the 2026 raw workspace
   - then run the repository pocket-extraction code to derive the actual `8A` pocket
4. If AlphaFill returns `404`:
   - keep the UID in a fallback list
   - evaluate whether to locally run AlphaFill or choose another structure-source fallback later
5. Important distinction:
   - downloaded AlphaFill entry files are **not** pocket files yet
   - the actual `8A` pocket is produced later by `feature/extract_pocket.py`
   - the `8A` cutoff is defined by `POCKET_RADIUS = 8.0`
6. Current preference:
   - use targeted public AlphaFill download first because it is smaller and simpler than local AlphaFill deployment
   - only consider local AlphaFill deployment for the unresolved `404` subset if necessary
7. Current execution rule:
   - finish the AlphaFill download stage first
   - after download completes, automatically merge the statistics and continue to pocket extraction for successful entries

Current AlphaFill error interpretation:

- The large `error` counts seen during full download are currently dominated by a transport-level SSL failure, not by confirmed missing AlphaFill entries.
- The concrete observed error is:
  - `<urlopen error [SSL: UNEXPECTED_EOF_WHILE_READING] EOF occurred in violation of protocol (_ssl.c:1017)>`
- Meaning:
  - the AlphaFill HTTPS connection was interrupted mid-transfer
  - these rows should be treated as transient download failures, not the same thing as `404`
- In the current downloader:
  - `HTTPError` is recorded as `http_error`
  - SSL EOF and similar connection breaks fall into the generic `error` bucket
- Practical consequence:
  - a high `error` count does **not** currently prove that the corresponding UIDs are absent from AlphaFill
  - it mainly shows that the current request strategy is too fragile for this server behavior

Downloader hardening that has now been applied:

- `custom/data_build/download_alphafill_gap_entries.py` was removed and rewritten from scratch
- the current implementation now:
  - uses `curl` instead of Python `urllib`
  - forces `HTTP/1.1`
  - retries transient failures with backoff and jitter
  - writes downloads through `.part` files and renames only after success
  - treats previously recorded generic `error` rows as retryable instead of final
  - records `attempt_count` and `error_category` in the status CSV
- `custom/data_build/run_alphafill_download_chunks.sh` was added as a reusable launcher with gentler defaults

Latest rewritten-downloader probe:

- probe set:
  - `A0A1U8QHE3`
  - `A0A1D8PKB4`
  - `B7LW38`
- result:
  - `2 / 3` downloaded successfully
  - `1 / 3` returned `http_404`
  - `0 / 3` remained in the generic `error` bucket
- interpretation:
  - the new curl-based downloader is materially more reliable than the previous urllib-based implementation
  - AlphaFill access is currently viable again through this rewritten path

Remaining-only conservative rerun final result:

- total remaining rows processed: `4119`
- `ok`: `1970`
- `http_error`: `2148`
- generic `error`: `1`
- failure composition:
  - `2148` are clean `http_404`
  - `1` is `ssl_error`
- implication:
  - the rewritten downloader is stable enough that almost all non-success outcomes are now explicit `404`, not ambiguous transport failures

Pocket-stage result:

- Existing repository code was used for pocket extraction:
  - `feature/extract_pocket.py`
  - `custom/data_build/extract_alphafill_gap_pockets.py`
- AlphaFill-success manifest built:
  - `4123` successful AlphaFill UIDs
- AlphaFill pocket extraction result:
  - pocket rows kept: `2545`
  - AlphaFill-success but no pocket extracted: `1578`
- Final merged 2026 pocket assets:
  - `reuse_rows`: `188745`
  - `alphafill_rows`: `2545`
  - `final_unique_rows`: `191290`
  - missing PDB after merge: `0`
- Final 2026 pocket coverage summary:
  - all unique enzymes: `195743`
  - final pocket UID count: `191290`
  - final missing pocket UID count: `4453`
- Important interpretation:
  - the downstream protein-feature pipeline can now follow the original storage contract:
    - `pockets/pocket/*.pdb`
    - `pockets/pocket_info.csv`
  - local AlphaFill fallback should mainly target the unresolved download subset
  - a separate strategy may still be needed for the `1578` AlphaFill-success rows that did not yield pockets under the original extraction logic

Fallback plan if AlphaFill HTTPS download remains unreliable:

1. First try the same data source through a different transport:
   - official AlphaFill rsync mirror
   - reason: it preserves the original AlphaFill output format and avoids the fragile REST-over-HTTPS path
2. If rsync is impractical, move to local AlphaFill generation:
   - use `scripts/run_alphafill.py`
   - requires installing `alphafill` and downloading the `PDB-REDO` resources
3. If AlphaFill itself becomes infeasible, switch from strict reproduction to engineering fallback:
   - generate pocket files from other structure sources and alternative pocket-definition logic
   - minimum interface to preserve downstream compatibility:
     - `pockets/pocket/*.pdb`
     - `pocket_info.csv`
4. If some enzymes still remain unresolved:
   - either exclude them from the structure branch
   - or explicitly support a sequence-only fallback in the later model/data pipeline

Important note:

- the new 2026 pocket directory created so far is a reuse-only staging area, not yet the final complete `pockets/pocket/`
- this is intentional so we do not accidentally mix verified reusable pockets with pockets that still need recomputation or external download

### LocalMapper Repair Status

`localmapper` is now repaired and can be initialized in the local environment.

Working environment combination:

- `torch 2.2.1+cu121`
- `torchdata 0.7.1`
- `dgl 2.1.0`
- `pydantic 2.12.5`

Important runtime note:

- during command-line runs we used:
  - `HOME=/tmp MPLCONFIGDIR=/tmp/matplotlib DGLDEFAULTDIR=/tmp/dgl DGLBACKEND=pytorch`

Compatibility note:

- the installed `localmapper/localmapper.py` was patched so matplotlib import is optional
- this was needed because the visualization dependency is not required for atom mapping but was blocking module import in this environment

### Next Checklist

- [x] Reproduce the original `reaction-enzyme` positive database cleaning step
- [x] Generate `all_enzymes.csv` for the 2026 snapshot
- [x] Generate 2026 asset reuse and gap manifests
- [x] Prepare reaction and enzyme backfill input tables
- [x] Materialize reusable 2025 reaction assets into the 2026 snapshot
- [x] Compute the remaining `857` missing 2026 reaction feature assets
  - `drfp/rxn2fp.pkl`
  - `reacting_center/rxn2aam.pkl`
  - `reacting_center/reacting_center.pkl`
  - `molecule_conformation/*`
- [x] Materialize safe reusable old pocket assets into the 2026 staging area
- [ ] Download/collect external AlphaFill structures for the subset that exists in the public AlphaFill databank
- [ ] Design fallback handling for the remaining missing UIDs that return `404`
- [ ] Resolve the `726` old-pocket recheck set
- [ ] Backfill enzyme pocket assets into the final 2026 pocket directory
  - `pockets/pocket_info.csv`
  - `pockets/pocket/*.pdb`
- [ ] Generate 2026 protein feature assets
- [~] Generate 2026 protein feature assets
  - `feature/protein/gvp_feature/gvp_protein_feature.pt`
  - `feature/protein/ESM-C_600M/protein_level/seq2feature.pkl`
  - `feature/protein/ESM-C_600M/pocket_node_feature/esm_node_feature.pt`
- [ ] Build `UniprotID -> TaxID / organism` mapping
- [ ] Join microorganism information into the cleaned main table
- [ ] Save the enriched `reaction-enzyme-microorganism` main table
- [ ] Define substrate extraction rule from `CANO_RXN_SMILES`
- [ ] Aggregate microorganism-substrate statistics into `microbe_substrate_pref.csv`
- [ ] Design the new microorganism-preference branch for model input
- [ ] Decide how to fuse that branch with the existing enzyme and reaction branches
- [ ] Optionally generate `enzyme_dim.csv` and `reaction_dim.csv` as helper tables
- [ ] Decide whether `rxnmapper_template` and `localmapper_template` are required for downstream work

## 2026-04-01 Protein Feature Preparation

- Status:
  - reaction-side assets: ready
  - strict 2026 pocket assets: ready
  - protein-feature software environment: ready
  - protein-feature generation itself: in progress
- Rechecked strict current 2026 inputs:
  - strict `all_enzymes.csv`: `195,743`
  - strict `pockets/pocket_info.csv` UIDs: `191,290`
  - strict main-table enzymes already pocket-supported: `191,290`
  - strict main-table enzymes without pocket: `4,453`
  - strict main-table pairs already pocket-supported: `309,325 / 320,043`
- Important interpretation:
  - for the immediate original-style 2026 feature build, the default input should be the strict current 2026 dataset
  - the broad auxiliary protein asset pool is preserved for coverage and future expansion, but it is not the default immediate feature-build input
- Verified software stack in `/home/a/EnzymeCAGE/.envs/rhea-clean/bin/python`:
  - `torch 2.2.1+cu121`
  - `torchvision 0.17.1+cu121`
  - `torch_geometric 2.7.0`
  - `torch_scatter 2.1.2+pt22cu121`
  - `torch_sparse 0.6.18+pt22cu121`
  - `torch_cluster 1.6.3+pt22cu121`
  - `esm 3.1.1`
  - `mlcrate 0.2.0`
  - `Bio 1.83`
  - `PyYAML 6.0.2`
  - `tqdm 4.66.2`
  - `numpy 1.26.4`
- Verified hardware checkpoint:
  - GPU: `NVIDIA GeForce RTX 5060 Laptop GPU`
  - VRAM: `8151 MiB`
- Original-based planned run command:
  - `cd /home/a/EnzymeCAGE/feature`
  - `HOME=/tmp MPLCONFIGDIR=/tmp/matplotlib DGLDEFAULTDIR=/tmp/dgl DGLBACKEND=pytorch ../.envs/rhea-clean/bin/python main.py --data_path ../data/processed/rhea/2026-01-21/all_enzymes.csv --pocket_dir ../data/processed/rhea/2026-01-21/pockets/pocket --skip_rxn_feature`
- Expected outputs from that run:
  - `data/processed/rhea/2026-01-21/feature/protein/gvp_feature/gvp_protein_feature.pt`
  - `data/processed/rhea/2026-01-21/feature/protein/ESM-C_600M/protein_level/seq2feature.pkl`
  - `data/processed/rhea/2026-01-21/feature/protein/ESM-C_600M/pocket_node_feature/esm_node_feature.pt`
- Important workflow note:
  - a compute-saving `with-pocket-only` input table is possible, but that would be a `Custom` optimization and has not been approved as the official path
- Current execution note:
  - the original-based strict-2026 protein-feature run was launched on `2026-04-01 10:22 CST`
  - command:
    - `cd /home/a/EnzymeCAGE/feature`
    - `HOME=/tmp MPLCONFIGDIR=/tmp/matplotlib DGLDEFAULTDIR=/tmp/dgl DGLBACKEND=pytorch ../.envs/rhea-clean/bin/python main.py --data_path ../data/processed/rhea/2026-01-21/all_enzymes.csv --pocket_dir ../data/processed/rhea/2026-01-21/pockets/pocket --skip_rxn_feature`
  - the original monolithic `GVP` merge path did not finish on this machine
  - the per-UID `GVP` computation itself did finish

### 2026-04-01 GVP Checkpoint

- `Original-based` result:
  - strict `GVP` generation was launched from the released `feature/main.py` path
  - the first run exposed bad pockets that produce `num_valid_residues=0`
- `Custom`, user-approved stabilization:
  - `feature/gvp_torchdrug_feature.py` was patched so bad pockets are logged and skipped instead of crashing the whole run
- After retry:
  - strict pocket-supported enzymes processed: `191,290`
  - successful per-UID `GVP` tmp outputs: `191,062`
  - bad-pocket failures: `228`
- Monolithic merge outcome:
  - the repository’s original one-file merge strategy stopped during aggregation under local memory pressure
  - tmp `GVP` storage on disk reached about `29G`
- `Custom`, user-approved formalization:
  - `GVP` outputs were converted into sharded storage plus a lazy compatibility loader
  - new formalized outputs:
    - `feature/protein/gvp_feature/shards/gvp_part_*.pt`
    - `feature/protein/gvp_feature/gvp_manifest.json`
    - `feature/protein/gvp_feature/gvp_protein_feature.pt`
      - metadata pointer file, not a monolithic dict tensor
    - `feature/protein/gvp_feature/gvp_failed_uids.csv`
- Final formalized `GVP` counts:
  - usable `GVP` entries: `191,060`
  - failed entries total: `230`
  - breakdown:
    - bad pockets with zero valid residues: `228`
    - corrupt tmp `.pt` files after the interrupted merge stage: `2`
      - `P80185`
      - `Q46Z41`
- User decision:
  - the two corrupt tmp `.pt` cases will not be repaired
  - they are now treated as final `GVP` failures
- Compatibility validation:
  - the new sharded `gvp_protein_feature.pt` loads through `enzymecage.dataset.sharded_protein.load_protein_gvp_data`
  - sampled UID reads from `LazyShardMapping` returned valid tensor tuples
- Current next stage:
  - `ESM-C` protein-level features: not started yet
  - `ESM-C` pocket-node features: not started yet

### 2026-04-01 ESM-C Benchmark / Environment Check

- A real small-sample benchmark was attempted before starting full `ESM-C`.
- Important result:
  - in the current `.envs/rhea-clean` environment, `ESM-C` does **not** currently run on the local GPU
- Local hardware / software combination:
  - GPU: `NVIDIA GeForce RTX 5060 Laptop GPU`
  - PyTorch: `2.2.1+cu121`
- Actual failure:
  - PyTorch warns that the current install does not support the GPU CUDA capability `sm_120`
  - `ESM-C` model initialization fails with:
    - `RuntimeError: CUDA error: no kernel image is available for execution on the device`
- Interpretation:
  - this is not a normal throughput limitation
  - it is a GPU-compatibility blocker for the `ESM-C` stage
- CPU fallback probe:
  - forcing `CUDA_VISIBLE_DEVICES=''` successfully switches the run away from the GPU path
  - the first CPU-side probe starts downloading the `ESMC 600M` weights (`2.30G`)
  - so CPU fallback is feasible in principle, but it will be substantially slower and includes a one-time model download
- Current status:
  - this blocker applied only to `.envs/rhea-clean`
  - it is now resolved via a separate `ESM-C` GPU environment

### 2026-04-01 ESM-C GPU Environment Resolution

- A separate GPU-capable `ESM-C` environment was created:
  - `/home/a/EnzymeCAGE/.envs/esmc-gpu`
- Installed stack:
  - `torch 2.7.1+cu128`
  - `torchvision 0.22.1`
  - `torchaudio 2.7.1`
  - `esm 3.1.1`
  - `pandas 2.3.3`
  - `numpy 1.26.4`
  - `biopython 1.83`
  - `tqdm 4.66.2`
  - `pyyaml 6.0.2`
- Environment verification:
  - CUDA matmul sanity check succeeded on the local `RTX 5060 Laptop GPU`
  - `ESMC.from_pretrained('esmc_600m').to('cuda')` now succeeds in this environment
  - a real tiny forward pass also succeeds
- Observed probe metrics:
  - model load time: `3.905 sec`
  - probe embedding shape: `(39, 1152)`
  - peak CUDA memory during the tiny test: about `4518.7 MB`
- Model-weight state:
  - the `ESMC 600M` weights are fully cached under:
    - `/home/a/.cache/huggingface/hub/models--EvolutionaryScale--esmc-600m-2024-12`
  - primary model blob size:
    - `2,300,275,866` bytes
- Storage added for this resolution path:
  - `.envs/esmc-gpu`: about `7.0G`
  - `ESMC 600M` Hugging Face cache subtree: about `2.2G`
- Current status:
  - the local-GPU blocker for `ESM-C` is resolved
  - full `ESM-C` generation has not started yet

### 2026-04-01 ESM-C 100-Protein Benchmark

- `Custom benchmark` was run before the full strict-2026 `ESM-C` stage.
- Benchmark input:
  - `100` proteins from the strict 2026 `all_enzymes.csv`
  - CSV:
    - `/home/a/EnzymeCAGE/data/processed/rhea/2026-01-21/feature/protein/ESM-C_600M_benchmark/all_enzymes_100.csv`
- Runtime mode:
  - same per-protein serial `ESM-C` call pattern as the released `calc_seq_esm_C_feature`
  - environment:
    - `/home/a/EnzymeCAGE/.envs/esmc-gpu`
- Measured output:
  - total wall time: `13.845 sec`
  - throughput: about `7.223 proteins/sec`
  - average per-protein time: `0.138 sec`
  - median per-protein time: `0.111 sec`
  - p90 per-protein time: `0.173 sec`
  - benchmark average sequence length: `435.93 aa`
  - benchmark average token length: `437.93`
  - generated node-feature size for the 100 proteins: `177.941 MB`
  - average compressed node-feature size per protein: about `1822.116 KB`
  - observed peak CUDA memory during the benchmark: about `4518.702 MB`
- Full-run extrapolation for `195,743` strict-2026 proteins:
  - sequence-level `ESM-C` stage alone: about `7.53 hours`
  - sequence-level node-feature `npz` pool alone: about `340.144 GiB`
- Worst-case probe:
  - real longest-sequence UID tested: `Q00342`
  - sequence length: `1000`
  - token length: `1002`
  - forward time: `1.158 sec`
  - observed peak CUDA memory remained around `4518.702 MB`
- Main risk conclusion:
  - the dominant risk for full `ESM-C` is disk / artifact scale, not immediate 5060 GPU memory
  - the released resume behavior for `seq2feature.pkl` is not robust against interruptions because skipped existing `uid.npz` files are not backfilled into the pickle state automatically
## 2026-04-07 Missing-Pocket Analysis Refresh

- Rechecked the current strict-2026 missing-pocket set:
  - total missing-pocket enzymes: `4,453`
- This set is now explicitly separated as:
  - `726` old-pocket recheck rows
  - `1,578` AlphaFill-success rows with no extracted pocket
  - `2,148` public AlphaFill `404` rows
  - `1` public AlphaFill timeout row

### Recheck Set: Additional Sequence Validation

- Input:
  - `data/processed/rhea/2026-01-21/asset_reuse/enzyme_pocket_recheck.csv`
- Additional comparison against the packaged old `uid2seq.pkl` was run.
- Output:
  - `data/processed/rhea/2026-01-21/asset_reuse/enzyme_pocket_recheck_with_old_uid2seq_status.csv`
- Result:
  - total: `726`
  - exact match against old `uid2seq.pkl`: `95`
  - mismatch against old `uid2seq.pkl`: `631`
  - missing in old `uid2seq.pkl`: `0`
- Interpretation:
  - only `95` recheck rows look like potential direct-reuse candidates after this extra validation
  - the remaining `631` should stay unresolved for now

### AlphaFill-Success But No Pocket: Cause Breakdown

- Input:
  - `data/processed/rhea/2026-01-21/pockets/coverage/alphafill_success_no_pocket.csv`
- Cause summary written to:
  - `data/processed/rhea/2026-01-21/pockets/coverage/alphafill_success_no_pocket_reason_summary.json`
- Counts:
  - `single_chain_only`: `1170`
  - `no_valid_best_ligand_chain`: `381`
  - `exception:TypeError`: `26`
  - `exception:PDBConstructionException`: `1`
- Interpretation:
  - most of the `1,578` no-pocket rows are not caused by missing AlphaFill downloads
  - most fail before the actual `8A` pocket selection:
    - either the parsed structure already has only one chain
    - or `get_best_ligand_chain` returns `None`
  - therefore local AlphaFill re-generation should not be assumed to fix most of this subset

### Local AlphaFill Deployment Reality Check

- Local-run entry point in the repository:
  - `scripts/run_alphafill.py`
- Explicit prerequisites from that script:
  - `alphafill` executable on `PATH`
  - `pdbredo_seqdb.txt`
  - local `PDB-REDO` directory
  - input structure `.cif` files
- Current local availability:
  - `alphafill`: missing
  - `dataset/PDB-REDO`: missing
- Input-structure helper already exists:
  - `feature/download_af2_structures.py`
- Current storage reference points:
  - downloaded public AlphaFill raw set for `4,123` UIDs: about `1.9G`
  - extracted AlphaFill-gap pocket PDBs for `2,545` UIDs: about `60M`
- Interpretation:
  - the unresolved local-AlphaFill target set (`2,148 + 1`) is not large in terms of output artifacts
  - the main cost/unknown is obtaining and storing the required local `PDB-REDO` mirror

## 2026-04-07 Microorganism / Genome-Linking Planning

- Pocket-side follow-up is paused for the moment.
- Immediate planning focus is now the microorganism/genome branch.
- This branch is `Custom` relative to the original EnzymeCAGE pipeline.

### Recommended starting table

- Use the strict cleaned main table as the microorganism-source enzyme set:
  - `data/processed/rhea/2026-01-21/rhea_rxn2uids.csv`
- Rationale:
  - this is the actual supervised reaction-enzyme fact table
  - every microorganism discovered from this set is guaranteed to correspond to at least one positive training fact

### Recommended lookup key

- Start from:
  - `UniprotID`
- Do not use raw sequence as the primary microorganism lookup key.
- Target mapping fields to build:
  - `UniprotID -> TaxID`
  - `UniprotID -> organism_name`
  - preferably also:
    - `proteome_id`
    - strain / isolate name
    - `assembly_accession`

### Recommended deduplication principle

- One microorganism may map to many enzymes.
- Therefore:
  - enzyme list should be the **discovery list**
  - microorganism/genome table should be the **download/storage unit**
- Recommended normalized outputs:
  - `uid_to_microbe.csv`
  - `microbe_genome_catalog.csv`
  - `reaction_enzyme_microbe.csv`

### Recommended order

1. unique `UniprotID` from `rhea_rxn2uids.csv`
2. build `uid_to_microbe.csv`
3. deduplicate to unique microorganism/genome units
4. download/store genomes once per unique microorganism/genome
5. join microorganism keys back into the cleaned main table

### Finalized Execution Plan

- The final chosen microorganism/genome workflow is now:
  1. `uid_list.csv`
  2. `uid_to_source.csv`
  3. `source_signature_catalog.csv`
  4. `source_signature_to_genome_candidates.csv`
  5. `source_signature_to_selected_genome.csv`
  6. `genome_catalog.csv`
  7. `uid_to_selected_genome.csv`
  8. `reaction_enzyme_microbe.csv`
- Important refinement:
  - candidate genome queries should be deduplicated at the source-signature level rather than run per `UniprotID`
- Source split:
  - UniProt for `UniprotID -> source microorganism`
  - NCBI Datasets / Assembly for candidate genome metadata and final genome download
- Selection rule:
  - prefer exact strain/isolate match
  - then best organism/proteome context
  - then `reference` assemblies
  - then higher assembly level / better annotation / newer release
  - unresolved ties must remain explicitly marked as ambiguous

### Microorganism Step 1 Status

- Status: done
- Script:
  - `custom/data_build/build_uid_list_from_main_table.py`
- Outputs:
  - `data/processed/rhea/2026-01-21/microbe/uid_list.csv`
  - `data/processed/rhea/2026-01-21/microbe/uid_list_summary.json`
- Current counts:
  - source main-table rows: `320,043`
  - unique `UniprotID`: `195,743`
- Immediate next step:
  - build `uid_to_source.csv` from `uid_list.csv`
## 2026-03-31 Inventory Check: Original 2025 Dataset

- Re-verified `/home/a/EnzymeCAGE/dataset/RHEA/2025-02-05`.
- Present in the packaged main RHEA dataset:
  - `rhea_rxn2uids.csv`
  - `all_enzymes.csv`
  - `uid2seq.pkl`
  - `pockets/pocket/*.pdb`
  - `pockets/pocket_info.csv`
  - `feature/reaction/drfp/rxn2fp.pkl`
  - `feature/reaction/reacting_center/rxn2aam.pkl`
  - `feature/reaction/reacting_center/reacting_center.pkl`
  - `feature/reaction/molecule_conformation/*`
- Not present in the packaged main RHEA dataset:
  - `feature/protein/gvp_feature/gvp_protein_feature.pt`
  - `feature/protein/ESM-C_600M/protein_level/seq2feature.pkl`
  - `feature/protein/ESM-C_600M/pocket_node_feature/esm_node_feature.pt`
- Conclusion:
  - The original packaged RHEA dataset already includes reaction features and extracted pocket raw assets.
  - It does not include ready-made protein feature tensors for the main RHEA database.
  - Protein features still need to be generated locally from `all_enzymes.csv` + `pockets/pocket`, following the README workflow.

## 2026-03-31 Strict 2026 all_enzymes.csv: Why It Is Smaller

- Current 2026 `all_enzymes.csv` was generated from the cleaned 2026 main table by `UniprotID` de-duplication.
- It is therefore a strict cleaned-main-table enzyme pool, not a broad auxiliary enzyme pool.
- Raw-to-strict UID flow:
  - raw Rhea-linked UIDs in `rhea2uniprot_sprot.tsv`: `236,103`
  - after requiring non-null reaction SMILES: `222,104`
  - final cleaned main-table UIDs / current `all_enzymes.csv`: `195,743`
- Missing from the strict pool relative to raw Rhea-linked UIDs: `40,360`
- Removal reasons:
  - no usable reaction SMILES: `13,999`
  - fail canonical reaction cleaning only: `21,403`
  - fail sequence length >1000 only: `4,285`
  - fail both canonicalization and sequence-length filter: `673`
  - missing sequence after mapping: `0`
- Additional interpretation:
  - The original repo workflow was followed for `rhea_rxn2uids.csv`, but the exact generation rule for the packaged 2025 `all_enzymes.csv` is not公开 in the repo.
  - The packaged 2025 `all_enzymes.csv` is broader than its own cleaned main table by `8,825` enzymes.
  - `8,739` of those extra enzymes already have pocket PDB files in the packaged 2025 dataset.
  - They also do not overlap packaged `train.csv`, `valid.csv`, `Enzyme-405.csv`, or `Orphan-335.csv`.
  - Therefore the old 2025 `all_enzymes.csv` should be treated as a broader auxiliary enzyme/pocket feature pool, not as a strict by-product of the cleaned main table.
- The packaged old pocket pool is broader still:
  - packaged old pocket PDB count: `236,439`
  - overlap with old `all_enzymes.csv`: `198,157`
  - pocket IDs not in old `all_enzymes.csv`: `38,282`
  - overlap with old cleaned main table: `189,418`
  - pocket IDs not in old cleaned main table: `47,021`
  - all packaged old pocket IDs are present in the old valid `uid2seq.pkl`
- Interpretation:
  - The old packaged pockets were almost certainly generated from a broad AlphaFill/sequence asset pool.
  - They cannot be treated as “all directly reusable for current 2026 modeling” because many are outside the current 2026 enzyme universe, and some overlapping IDs have sequence/version mismatch that still requires recheck.
- Reconciliation against the old public main table:
  - old pocket IDs absent from current 2026 main table: `46,968`
  - but only `67` of those are present in the old 2025 public main table
  - the other `46,901` were not in the old 2025 public main table either
  - this confirms that the apparent gap is mainly due to the old pocket directory being a very broad auxiliary structure pool
  - it is **not** evidence that the newer 2026 main table became smaller than the old public main table
- Main-table comparison remains:
  - old public main-table unique enzymes: `191,567`
  - current 2026 main-table unique enzymes: `195,743`
  - overlap: `191,499`
  - 2026-only enzymes vs old public main table: `4,244`
  - old-main-only enzymes vs current 2026 main table: `68`

## 2026-03-31 Broad Protein Asset Pool

- User approved adding a broader auxiliary protein/pocket asset pool in addition to the strict current-model subset.
- Built:
  - [`broad_protein_asset_pool`](/home/a/EnzymeCAGE/data/processed/rhea/2026-01-21/broad_protein_asset_pool)
  - pocket directory: [`broad_protein_asset_pool/pockets/pocket`](/home/a/EnzymeCAGE/data/processed/rhea/2026-01-21/broad_protein_asset_pool/pockets/pocket)
  - pocket info: [`broad_protein_asset_pool/pockets/pocket_info.csv`](/home/a/EnzymeCAGE/data/processed/rhea/2026-01-21/broad_protein_asset_pool/pockets/pocket_info.csv)
  - broad enzyme pool: [`broad_protein_asset_pool/all_enzymes.csv`](/home/a/EnzymeCAGE/data/processed/rhea/2026-01-21/broad_protein_asset_pool/all_enzymes.csv)
  - sequence-source manifest: [`broad_protein_asset_pool/all_enzymes_sequence_source.csv`](/home/a/EnzymeCAGE/data/processed/rhea/2026-01-21/broad_protein_asset_pool/all_enzymes_sequence_source.csv)
  - summary: [`broad_protein_asset_pool/summary.json`](/home/a/EnzymeCAGE/data/processed/rhea/2026-01-21/broad_protein_asset_pool/summary.json)
- Counts:
  - old pocket rows: `236,439`
  - new 2026 AlphaFill-derived pocket rows: `2,545`
  - overlap: `0`
  - broad unique pocket rows: `238,984`
  - broad all_enzymes rows: `238,984`
  - missing PDB after merge: `0`
  - missing sequence after merged old/new uid2seq lookup: `0`
## Session Resume Rule

- Before any new work session starts, first read:
  - `/home/a/EnzymeCAGE/custom/docs/PROJECT_MEMORY.md`
  - `/home/a/EnzymeCAGE/custom/docs/DATABASE_PROGRESS.md`
  - the latest relevant daily log in `/home/a/EnzymeCAGE/custom/docs/`
- Mandatory continuation update on `2026-04-22`:
  - future sessions must also preserve the logging workflow itself
  - after any meaningful data/package/script/cloud-command/project-decision
    change, update:
    - the current dated daily log
    - `/home/a/EnzymeCAGE/custom/docs/PROJECT_MEMORY.md`
    - `/home/a/EnzymeCAGE/custom/docs/DATABASE_PROGRESS.md`
  - do this before closing the work turn, so a new chat can resume without
    losing the current operational state
- Mandatory pre-run / pre-transfer audit:
  - record row counts, file counts, regular-file versus symlink/reparse-point
    counts, sizes or raw byte totals, checksums for archives when practical,
    and traceability manifests for mixed-source assets
  - run a small mixed-source smoke test before long cloud jobs
  - do not treat a file or directory as valid only because its name or expected
    path looks correct
- Current external-storage convention:
  - large-data local AlphaFill / PDB-REDO / future genome downloads use:
    - `/mnt/f/酶智能体/enzymecage_external`
  - repository code and Python environments stay on the local Linux disk
- PDB-REDO sync troubleshooting checkpoint on `2026-04-10`:
  - previous overnight sync had reached `196.003 GB` (`397,932` files) but the visible WSL-side `/mnt/f` mount disappeared again
  - multiple duplicate Windows-side `bash.exe` / `rsync.exe` workers were detected for the same mirror target and killed
  - sync was relaunched as a single controlled Windows-side `rsync --partial` worker
  - later resume work showed the old progress-log attachment could become stale even while the real Windows/MSYS2 rsync chain was alive
- The current live monitor is no longer derived from the stale rsync stdout log.
- It now estimates:
  - current total mirrored size
  - previous-1-minute byte growth
  - previous-1-minute average speed
  from:
  - last exact verified mirror size (`196.022 GB`)
  - plus minute-by-minute `F:` free-space deltas
- Current live monitor path:
  - `/home/a/EnzymeCAGE/pdb_redo_sync_status_live.log`
- The previous heavy full-tree monitor history was archived to:
  - `/home/a/EnzymeCAGE/pdb_redo_sync_status_heavy_archive.log`
- PDB-REDO download status clarification on `2026-04-10`:
  - old mirror target: `F:\enzymecage_external\pdb_redo`
  - overnight progress reached about `196 GB`
  - healthy phase on `2026-04-09` evening: approximately `6-8 MB/s`
  - degraded phase on `2026-04-10`: many minute windows at `0.000 MB/s`, with current completed-file based transfer only around `0.25-0.35 MB/s`
  - this confirms the current serial continuation path is significantly degraded compared with the original healthy phase
- Parallel-probe checkpoint:
  - a small proof-of-concept per-prefix parallel rsync probe succeeded under `/mnt/f/enzymecage_external/pdb_redo_parallel_probe`
  - however, reliable orchestration of multiple Windows/MSYS2 rsync lanes should be done directly on Windows, not through the current WSL wrapper
- New preferred operational route for the main mirror:
  - direct Windows PowerShell control
  - reusable launcher:
    - `custom/data_build/run_pdb_redo_sync_windows_local.ps1`
  - keep using the same resumed target:
    - `F:\enzymecage_external\pdb_redo`
- Latest relevant daily log is now:
  - `/home/a/EnzymeCAGE/custom/docs/DAILY_LOG_2026-04-10.md`

## 2026-04-17 Cloud Sequence-Level ESM-C Resume Status

- The cloud-side full strict-2026 sequence-level `ESM-C` run was interrupted
  after a large partial output had already been produced.
- Confirmed checkpoint at interruption:
  - completed `node_level` `.npz`: `179,298 / 195,743`
  - remaining proteins at restart time: about `16,445`
- Resume is confirmed healthy:
  - resumed cloud PID: `8736`
  - `.npz` count grew from `179,298` to `179,585` in a `60` second window
  - GPU remained allocated to the cloud Python worker
- Important completion caveat:
  - `protein_level/seq2feature.pkl` had **not** been produced before interruption
  - therefore a successful resumed `node_level` finish is still **not**
    sufficient to declare sequence-level `ESM-C` fully complete
  - after `node_level` ends, we still need a dedicated protein-level
    aggregation/rebuild step for a trustworthy final `seq2feature.pkl`
- Latest relevant daily log is now also:
  - `/home/a/EnzymeCAGE/custom/docs/DAILY_LOG_2026-04-17.md`

## 2026-04-17 Cloud Sequence-Level ESM-C Finalized

- Cloud-side strict-2026 sequence-level `ESM-C` is now complete.
- Final verified outputs:
  - `node_level` `.npz`: `195,743 / 195,743`
  - `failed_proteins.csv`: `0`
  - final `protein_level/seq2feature.pkl`: `164,514`
- Important interpretation:
  - `164,514` is the correct final `seq2feature.pkl` target because the pickle
    is keyed by unique amino-acid sequence rather than by UID
  - therefore the successful final count is the unique sequence count, not the
    total UID count
- Repair method:
  - after the interrupted/resumed run, the intermediate pickle (`16,433`) was
    found incomplete
  - the final pickle was rebuilt offline from:
    - full `node_level/*.npz`
    - `all_enzymes.csv`
  - no model re-run was required
- Current stage summary:
  - `ESM-C` protein-level features: complete
  - next original-model protein-side step: pocket-node `esm_node_feature.pt`

## 2026-04-21 Cloud Pocket-Node Next Step

- Cloud-side strict-2026 pocket inputs are now available according to the user:
  - `G:\esm\pocket_info.csv`
  - `G:\esm\pocket`
- Added standalone cloud script:
  - `custom/data_build/run_esmc_pocket_node_only.py`
- Target output:
  - `G:\esm\ESM-C_600M\pocket_node_feature\esm_node_feature.pt`
- Execution plan:
  1. run a 100-row pocket-node smoke test
  2. verify output count and failures
  3. run full extraction against the strict `191,290` pocket rows

## 2026-04-21 Pocket-Node Cloud Run Needs PDB Re-transfer

- Cloud full pocket-node extraction result:
  - input pocket rows: `191,290`
  - saved features: `8,179`
  - failures: `183,111`
  - failure reason: `no_valid_residue_indices`
- Current status:
  - this output is **not** acceptable as the final `esm_node_feature.pt`
  - sequence-level `ESM-C` remains complete and does not need rerunning
- Diagnosis:
  - local final `pockets/pocket` consists entirely of symbolic links
  - symlink-based transfer to Windows/cloud likely produced PDB content or
    path semantics inconsistent with `pocket_info.csv`
  - local spot checks show the residue-number mapping should work when the
    actual target PDB content is present
- Required next step:
  - materialize/dereference the pocket PDB directory or reconstruct it from the
    source `reuse_pocket` plus `alphafill_gap/pocket` directories
  - rerun pocket-node after validating PDB content

## Final Database Packaging Rule

- The final database must not be handed off as an undocumented symlink-based
  directory.
- Working/staging directories may use symlinks for space efficiency, but any
  final transfer package must either:
  - contain regular materialized files, or
  - explicitly document symlink requirements and pass target-environment
    resolution tests before downstream use
- Mandatory packaging checks before future cloud runs or final release:
  - count total entries
  - count regular files
  - count symbolic links
  - record total size
  - sample records across all source groups and verify table-to-file alignment
- This rule was added after the `2026-04-21` pocket-node failure, where a
  symlink-based final `pocket/` directory was transferred as if it were a
  normal PDB directory and produced an invalid `8,179 / 191,290` pocket-node
  result.

## 2026-04-22 Pocket-Node Re-transfer Package Prepared

- Immediate goal:
  - repair the cloud pocket-node stage by transferring a materialized strict
    pocket package
  - sequence-level `ESM-C` remains complete and should not be rerun
  - the old cloud pocket-node output with only `8,179` saved features remains
    invalid
- User instruction for this phase:
  - first prepare and identify exactly what must be transferred
  - user will transfer the package
  - cloud execution commands should be provided only after transfer is complete
  - logs must be written in the dated daily log and in both long-term memory
    files
- Latest relevant daily log is now:
  - `/home/a/EnzymeCAGE/custom/docs/DAILY_LOG_2026-04-22.md`

### Local Audit Before Repackaging

- Strict final pocket directory:
  - `/home/a/EnzymeCAGE/data/processed/rhea/2026-01-21/pockets/pocket`
- Audit result:
  - total symlinks: `191,290`
  - regular `.pdb` files directly in that directory: `0`
- Strict `pocket_info.csv`:
  - rows: `191,290`
  - unique `UniprotID`: `191,290`
  - `pocket_source` counts:
    - `reuse_pocket`: `188,745`
    - `alphafill_gap`: `2,545`
- Local mapping checks:
  - sampled `reuse_pocket` records map `pocket_residues` to real PDB residue
    numbers when the dereferenced target PDB is used
  - sampled `alphafill_gap` records also map correctly
- Interpretation:
  - the residue-number mapping logic is still the right approach
  - the problem to fix is the transfer package shape and PDB content, not the
    completed sequence-level feature pool

### Standalone Script Hardening

- Updated:
  - `custom/data_build/run_esmc_pocket_node_only.py`
- Added strict validation options:
  - `--expected_rows`
  - `--min_saved_features`
  - `--fail_on_failures`
- Purpose:
  - avoid silently accepting another partial pocket-node output
  - make the cloud command fail if the row count or saved-feature count is not
    acceptable
- Validation:
  - `py_compile` passed in the local `esmc-gpu` environment

### Transfer Package

- Prepared package:
  - `/home/a/EnzymeCAGE/data/processed/rhea/2026-01-21/cloud_transfer/pocket_node_rerun_2026-04-22`
- Package contents:
  - `pocket/`
    - materialized, dereferenced real PDB files
  - `pocket_info.csv`
  - `pocket_info_smoke_mixed100.csv`
    - `50` `reuse_pocket` rows
    - `50` `alphafill_gap` rows
  - `run_esmc_pocket_node_only.py`
    - strict-mode standalone script
  - `pocket_source_manifest.csv.gz`
    - per-UID traceability manifest
    - records the original strict symlink path, resolved source PDB path, and
      transfer-package PDB path
- Package audit:
  - package `pocket/` regular `.pdb` files: `191,290`
  - package `pocket/` symlinks: `0`
  - package size: about `4.4G`
  - package `pocket_info.csv` rows: `191,290`
  - package `pocket_info.csv` unique `UniprotID`: `191,290`
- Traceability audit:
  - manifest rows: `191,290`
  - missing resolved source PDBs: `0`
  - strict entries that were not symlinks: `0`
  - missing or symlinked PDBs in transfer package: `0`
  - source group counts:
    - `old_2025_packaged_pocket`: `188,745`
    - `new_2026_alphafill_gap_pocket`: `2,545`

### Current User Transfer Step

- Transfer only the contents of:
  - `/home/a/EnzymeCAGE/data/processed/rhea/2026-01-21/cloud_transfer/pocket_node_rerun_2026-04-22`
- Target on cloud:
  - `G:\esm`
- Expected cloud layout after transfer:
  - `G:\esm\pocket\*.pdb`
  - `G:\esm\pocket_info.csv`
  - `G:\esm\pocket_info_smoke_mixed100.csv`
  - `G:\esm\run_esmc_pocket_node_only.py`
  - `G:\esm\TRANSFER_MANIFEST_2026-04-22.txt`
  - `G:\esm\pocket_source_manifest.csv.gz`
- Existing cloud sequence-level outputs should stay in place:
  - `G:\esm\ESM-C_600M\node_level\*.npz`
  - `G:\esm\ESM-C_600M\protein_level\seq2feature.pkl`
- Next after transfer:
  1. audit cloud PDB file counts and ensure they are regular files
  2. run mixed-source smoke test
  3. run full pocket-node extraction only if smoke test passes

## 2026-04-22 Pocket-Node Archive Transfer Fallback

- Direct transfer of the many-file `pocket/` directory was reported by the
  user to produce only about `174 MB` on the cloud side.
- This is not consistent with the validated local materialized package:
  - local package `pocket/` `.pdb` files: `191,290`
  - local package `pocket/` symlinks: `0`
  - local package raw PDB bytes: about `4.23 GB`
  - local package disk usage: about `4.4G`
- To avoid transfer instability with `191,290` small files, a single archive
  was created.
- Archive:
  - `/home/a/EnzymeCAGE/data/processed/rhea/2026-01-21/cloud_transfer/pocket_node_rerun_2026-04-22.tar.gz`
- SHA256 file:
  - `/home/a/EnzymeCAGE/data/processed/rhea/2026-01-21/cloud_transfer/pocket_node_rerun_2026-04-22.tar.gz.sha256`
- Transfer note:
  - `/home/a/EnzymeCAGE/data/processed/rhea/2026-01-21/cloud_transfer/ARCHIVE_TRANSFER_NOTE_2026-04-22.txt`
- Archive audit:
  - archive size: about `908 MB`
  - SHA256:
    - `3f75a1efcebe44aa1b5ffb476515dfbd65436ff730a1a4c3bffa04c6cbd2ca6f`
  - local checksum verification:
    - `pocket_node_rerun_2026-04-22.tar.gz: OK`
  - `.pdb` files inside archive:
    - `191,290`
- Revised user transfer step:
  - transfer the archive and checksum file instead of copying the many-file
    directory directly
  - place both files under `G:\esm`
  - extract the archive inside `G:\esm`
  - only after extraction and count validation should the cloud pocket-node
    smoke test be run
- Current status update:
  - the user has reported that the archive-transfer files were copied to the
    cloud machine
  - the next cloud step is checksum validation and extraction only
  - expected extracted `pocket/*.pdb` count: `191,290`
  - expected archive SHA256:
    - `3f75a1efcebe44aa1b5ffb476515dfbd65436ff730a1a4c3bffa04c6cbd2ca6f`
- Cloud archive validation result:
  - archive present: `yes`
  - SHA256 matched:
    - `3f75a1efcebe44aa1b5ffb476515dfbd65436ff730a1a4c3bffa04c6cbd2ca6f`
  - extracted: `yes`
  - old `G:\esm\pocket` backup: none needed because the directory did not
    exist at check time
  - extracted `.pdb` count: `191,290`
  - raw PDB bytes: `4,228,503,030`
  - raw GB: `3.938100`
  - reparse/symlink count: `0`
  - required extracted files are present
- Next permitted cloud step:
  - run only the mixed-source smoke test
  - wait for review before full pocket-node extraction

## 2026-04-22 Pocket-Node Smoke Failure Analysis

- Cloud mixed-source smoke test was run only on:
  - `G:\esm\pocket_info_smoke_mixed100.csv`
- It did not continue to full extraction.
- Cloud prechecks:
  - `G:\esm\ESM-C_600M\node_level/*.npz`: `195,743`
  - `G:\micromamba-root\envs\esm-gpu\python.exe` can import:
    - `pandas`
    - `numpy`
    - `torch`
    - `tqdm`
  - `C:\Anaconda\python.exe` is not suitable because `torch` is missing
- Smoke result:
  - command exit code: `1`
  - rows: `100`
  - saved features: `97`
  - failures: `3`
  - saved output file exists:
    - `G:\esm\ESM-C_600M\pocket_node_feature_smoke_20260422\esm_node_feature.pt`
  - `torch.load` key count: `97`
- Failed UIDs:
  - `A0A1D8PJ01`
  - `A0KQ95`
  - `A1AIF3`
- Local diagnosis:
  - all three are `alphafill_gap`
  - `pocket_residues` is empty / `NaN`
  - corresponding PDB files contain only `END`
  - each file is `7` bytes
- Full local mapping audit:
  - total strict pocket rows: `191,290`
  - rows with valid residue mapping: `191,062`
  - invalid rows: `228`
  - invalid source:
    - `alphafill_gap`: `228`
  - invalid reason:
    - `empty_pocket_residues`: `228`
- Interpretation:
  - archive transfer and extraction remain valid
  - smoke failure is not a new cloud transfer problem
  - the test exposed the already-known bad-pocket subset documented earlier
    during the GVP stage
  - the expected full pocket-node target should be filtered to valid pocket
    rows:
    - `191,062`
  - the unfiltered strict `191,290` table includes `228` placeholder/empty
    pockets that cannot produce pocket-node features
- Next step:
  - create a cloud-side filtered table:
    - `G:\esm\pocket_info_valid_for_pocket_node.csv`
  - filter rule:
    - keep rows with non-empty `pocket_residues`
  - expected row count:
    - `191,062`
  - create a new mixed-source smoke file from the filtered table
  - rerun smoke test against that filtered smoke file before any full run

## 2026-04-22 Filtered Pocket-Node Smoke Passed

- Cloud-side filtered input table was generated:
  - `G:\esm\pocket_info_valid_for_pocket_node.csv`
- Filter rule:
  - remove rows with empty / null / whitespace-only `pocket_residues`
- Counts:
  - original rows: `191,290`
  - empty/null `pocket_residues`: `228`
  - filtered rows: `191,062`
- Filtered source split:
  - `reuse_pocket`: `188,745`
  - `alphafill_gap`: `2,317`
- Filtered smoke input:
  - `G:\esm\pocket_info_valid_smoke_mixed100.csv`
  - `reuse_pocket`: `50`
  - `alphafill_gap`: `50`
- Filtered smoke result:
  - command exit code: `0`
  - `pocket_info_rows`: `100`
  - `saved_features`: `100`
  - `failures`: `0`
  - failed rows in `failed_pocket_nodes.csv`: `0`
  - output:
    - `G:\esm\ESM-C_600M\pocket_node_feature_smoke_valid_20260422\esm_node_feature.pt`
  - output size:
    - `29,010,052` bytes
  - `torch.load` UID key count:
    - `100`
- Interpretation:
  - the filtered valid pocket table aligns with both transferred PDB files and
    sequence-level ESM node features
  - full pocket-node extraction can proceed with expected output count:
    - `191,062`
  - full extraction must use the filtered table:
    - `G:\esm\pocket_info_valid_for_pocket_node.csv`
  - do not use unfiltered `G:\esm\pocket_info.csv` for full pocket-node
    extraction

## 2026-04-22 Pocket-Node Full Run Save Failure And Sharded Output Plan

- Filtered full pocket-node extraction was attempted on the cloud after the
  valid mixed-source smoke test passed.
- Input table:
  - `G:\esm\pocket_info_valid_for_pocket_node.csv`
- Expected valid rows:
  - `191,062`
- Reported run status:
  - progress completed:
    - `191062 / 191062`
  - elapsed:
    - `4:18:26`
  - exit code:
    - `1`
  - failed stage:
    - final `torch.save(uid_to_feature, esm_node_feature.pt)`
  - exception:
    - `MemoryError`
- Output validity:
  - `esm_node_feature.pt` exists but is invalid:
    - size: `701` bytes
    - `torch.load` failed:
      - `PytorchStreamReader failed locating file data.pkl`
  - `pocket_node_summary.json` was not written
  - `failed_pocket_nodes.csv` was not written
- Database/build interpretation:
  - the row filtering decision remains correct:
    - `191,290` original rows
    - `228` empty/null pocket rows excluded
    - `191,062` valid pocket-node targets
  - the failed full run does not indicate a new data-alignment problem
  - the failure is an output serialization/memory problem from saving one huge
    UID dictionary at the end
  - the corrupt `esm_node_feature.pt` must not be registered as a usable
    database artifact
- Fix:
  - the cloud standalone extraction script now supports sharded output:
    - `--save_format sharded`
    - `--shard_size`
  - the intended database artifact will consist of:
    - a small pointer:
      - `esm_node_feature.pt`
    - a manifest:
      - `esm_node_feature_manifest.json`
    - feature shards:
      - `esm_node_feature_shards/esm_node_feature_part_*.pt`
  - format tag:
    - `sharded_esm_pocket_v1`
- Local repository reader support was added for this artifact type:
  - `enzymecage/dataset/sharded_protein.py`
  - `enzymecage/dataset/geometric.py`
  - `infer.py`
- Local validation:
  - syntax check passed
  - synthetic two-row sharded extraction and load test passed
- Updated transfer script:
  - `/home/a/EnzymeCAGE/data/processed/rhea/2026-01-21/cloud_transfer/pocket_node_rerun_2026-04-22/run_esmc_pocket_node_only.py`
  - SHA256:
    - `a56a0b89b718f689cf937b2fca9d10c25ef7f51c0f7036460569a1807134233a`
- Next valid database build step:
  - transfer the updated script to `G:\esm`
  - rerun full extraction in sharded mode against:
    - `G:\esm\pocket_info_valid_for_pocket_node.csv`
  - expected saved features:
    - `191,062`
  - use a fresh output directory and do not reuse the corrupt failed output

## 2026-04-22 Artifact Compatibility Note For Final Database Aggregation

- The sharded ESM pocket-node output is a custom 2026 storage format, not the
  original EnzymeCAGE monolithic `esm_node_feature.pt` format.
- Original EnzymeCAGE artifact:
  - one file:
    - `esm_node_feature.pt`
  - direct content:
    - `uid -> pocket_node_feature`
  - generated by:
    - `feature/main.py::get_esm_pocket_feature`
  - validated by:
    - `feature/main.py::check_pocket_feature`
- Planned full 2026 artifact after the cloud memory failure:
  - pointer file:
    - `esm_node_feature.pt`
  - manifest:
    - `esm_node_feature_manifest.json`
  - shard directory:
    - `esm_node_feature_shards/`
  - format tag:
    - `sharded_esm_pocket_v1`
- Data semantics remain aligned with the original model:
  - UID key space
  - pocket residue mapping
  - ESM node-level feature slicing
  - per-UID matrix meaning
- Storage/container differs:
  - old code that calls only `torch.load(esm_node_feature.pt)` will not see
    UID keys directly
  - downstream use must go through the sharded-aware loader:
    - `load_pocket_node_feature_data`
- Final database aggregation rule:
  - do not move or register `esm_node_feature.pt` alone
  - always keep pointer, manifest, and shard directory together
  - record final counts from the manifest:
    - expected `saved_features = 191,062`
    - expected `failures = 0`
  - if a future machine has enough memory and a monolithic original-compatible
    file is required, create it as a separate conversion artifact and document
    it explicitly; do not pretend the sharded pointer is the original format

## 2026-04-22 Sharded Format Documentation File

- Dedicated storage-format documentation was created:
  - `/home/a/EnzymeCAGE/custom/docs/POCKET_NODE_SHARDED_FORMAT_2026-04-22.md`
- It was also copied to the current transfer package:
  - `/home/a/EnzymeCAGE/data/processed/rhea/2026-01-21/cloud_transfer/pocket_node_rerun_2026-04-22/POCKET_NODE_SHARDED_FORMAT_2026-04-22.md`
- During final database aggregation, this note is part of the required context
  for interpreting the ESM-C pocket-node artifact.
- The database should record the sharded artifact as a grouped artifact, not as
  a single standalone file:
  - `esm_node_feature.pt`
  - `esm_node_feature_manifest.json`
  - `esm_node_feature_shards/`

## 2026-04-22 Updated Script Is On Cloud

- The user reported that the updated sharded extraction script and checksum are
  now on the cloud machine:
  - `G:\esm\run_esmc_pocket_node_only.py`
  - `G:\esm\run_esmc_pocket_node_only.py.sha256`
- The next database build action is to generate the full ESM-C pocket-node
  sharded artifact.
- Required run:
  - input:
    - `G:\esm\pocket_info_valid_for_pocket_node.csv`
  - output directory:
    - `G:\esm\ESM-C_600M\pocket_node_feature_full_valid_sharded_20260422`
  - save format:
    - `sharded_esm_pocket_v1`
  - expected rows:
    - `191,062`
  - expected saved features:
    - `191,062`
  - expected failures:
    - `0`
- This output must later be registered as a grouped artifact:
  - pointer file
  - manifest file
  - shard directory

## 2026-04-22 Failed Monolithic Full Run Is Not Recoverable

- The completed progress counter from the failed full run does not represent a
  recoverable database artifact.
- Reason:
  - the old run saved no per-UID feature shards or checkpoints
  - all extracted feature arrays existed only in RAM until the final
    monolithic `torch.save`
  - the final save failed with `MemoryError`
  - process memory was lost after exit
- Remaining files are not sufficient for database use:
  - `run.log` has progress text only
  - corrupt `esm_node_feature.pt` is `701` bytes and cannot be loaded
  - summary and failed CSV were not written
- Database build decision:
  - rerun the pocket-node extraction step in sharded mode
  - reuse existing ESM-C node-level `.npz`, pocket PDBs, and filtered
    `pocket_info_valid_for_pocket_node.csv`
  - do not rerun sequence-level ESM-C

## 2026-04-23 ESM-C Pocket-Node Sharded Artifact Complete

- The full ESM-C pocket-node extraction has now completed successfully in
  sharded format on the cloud machine.
- Output directory:
  - `G:\esm\ESM-C_600M\pocket_node_feature_full_valid_sharded_20260422`
- Run status:
  - command exit code: `0`
  - script SHA256 matched before run
  - new script arguments confirmed:
    - `--save_format`
    - `--shard_size`
- Summary:
  - `pocket_info_rows`: `191062`
  - `saved_features`: `191062`
  - `failures`: `0`
  - `save_format`: `sharded`
  - `num_shards`: `192`
- Artifact files:
  - `esm_node_feature.pt`
    - pointer file
    - size: `964` bytes
    - `__format__ = sharded_esm_pocket_v1`
  - `esm_node_feature_manifest.json`
    - `saved_features = 191062`
    - `failures = 0`
    - `uid_to_shard` count: `191062`
  - `esm_node_feature_shards/`
    - `.pt` shard count: `192`
  - `failed_pocket_nodes.csv`
    - failed data rows: `0`
- Random shard validation:
  - sample shard:
    - `esm_node_feature_part_00133.pt`
  - sample UID:
    - `Q4FN07`
  - feature shape:
    - `(61, 1152)`
  - feature dtype:
    - `torch.float32`
- Database status:
  - ESM-C pocket-node feature generation is complete for the `191,062` valid
    pocket-node targets
  - this completes the previously active pocket-node build step
  - the artifact must be handled as a grouped sharded artifact:
    - pointer
    - manifest
    - shard directory
- Next database operation:
  - transfer/archive the complete grouped artifact back to local storage with
    checksums
  - then register it under the 2026 protein feature directory
  - do not treat the pointer file alone as the feature asset

## 2026-04-23 Cloud Artifact Packaging Plan

- A dedicated packaging plan was created:
  - `/home/a/EnzymeCAGE/custom/docs/CLOUD_ARTIFACT_PACKAGING_PLAN_2026-04-23.md`
- Cloud archive output directory:
  - `G:\esm\cloud_archives_20260423`
- Archive group 1: ESM-C sequence/node-level features
  - archive:
    - `G:\esm\cloud_archives_20260423\ESM-C_600M_sequence_features_20260423.tar.gz`
  - checksum:
    - `G:\esm\cloud_archives_20260423\ESM-C_600M_sequence_features_20260423.tar.gz.sha256`
  - includes:
    - `G:\esm\ESM-C_600M\node_level\`
    - `G:\esm\ESM-C_600M\protein_level\`
  - role:
    - reusable upstream ESM-C features for all `195,743` enzymes
- Archive group 2: ESM-C pocket-node sharded features
  - archive:
    - `G:\esm\cloud_archives_20260423\ESM-C_600M_pocket_node_sharded_20260423.tar.gz`
  - checksum:
    - `G:\esm\cloud_archives_20260423\ESM-C_600M_pocket_node_sharded_20260423.tar.gz.sha256`
  - includes:
    - `G:\esm\ESM-C_600M\pocket_node_feature_full_valid_sharded_20260422\`
  - role:
    - validated pocket-node feature artifact for `191,062` valid pocket targets
    - contains pointer, manifest, shard directory, summary, and failed CSV
- Future aggregation rule:
  - register these as distinct feature artifact groups
  - do not merge archive roles
  - verify SHA256 before extraction

## 2026-04-22 Next-Chat Handoff Document

- A dedicated new-chat handoff document was created:
  - `/home/a/EnzymeCAGE/custom/docs/NEXT_CHAT_HANDOFF.md`
- Purpose:
  - let the next conversation resume without guessing from partial context
  - preserve the user's working preferences:
    - Chinese communication
    - one step at a time
    - verify files before asking the user to transfer or run long jobs
    - write logs after meaningful changes
  - preserve path conventions and active next-step boundaries
- The handoff records the current active state:
  - sequence-level `ESM-C 600M` is complete and should not be rerun
  - unfiltered `pocket_info.csv` has `191,290` rows
  - valid pocket-node input has `191,062` rows after excluding `228`
    empty/null `pocket_residues`
  - the old `8,179`-feature cloud pocket-node output is invalid
  - the corrupt `701` byte monolithic `esm_node_feature.pt` is invalid
  - the sharded full pocket-node output has now completed successfully on
    cloud
  - the next valid step is to package and transfer the complete grouped
    sharded artifact back to local storage
- The handoff must be read before continuing pocket-node, final aggregation,
  cloud transfer, or any new long-running data build.

## 2026-04-22 Advisor Progress Report

- A Markdown progress report for advisor discussion was created:
  - `/home/a/EnzymeCAGE/custom/docs/PROJECT_PROGRESS_REPORT_2026-04-22.md`
- It was updated after the cloud pocket-node sharded run completed.
- Main counts recorded there:
  - cleaned main table rows: `320,043`
  - unique canonical reactions: `11,418`
  - unique enzymes: `195,743`
  - unique sequences: `164,514`
  - strict pocket rows: `191,290`
  - valid pocket-node target rows: `191,062`
  - GVP successful entries: `191,060`
  - ESM-C node-level features: `195,743 / 195,743`
  - microbe source signatures: `5,917`
- The report now records that pocket-node completed with:
  - `saved_features = 191,062`
  - `failures = 0`
  - shard count: `192`

## 2026-04-24 ESM Sequence Pooling Reproduction Plan

- A detailed sequence-level ESM pooling reproduction plan was created:
  - `/home/a/EnzymeCAGE/custom/docs/ESM_SEQUENCE_POOLING_REPRO_PLAN_2026-04-24.md`
- Original-model code confirmed:
  - `/home/a/EnzymeCAGE/feature/main.py::calc_seq_esm_C_feature`
  - pooling rule:
    - `seq_to_feature[seq] = node_feature.mean(axis=0)`
- Original-model downstream lookup also confirmed:
  - `/home/a/EnzymeCAGE/enzymecage/dataset/geometric.py::get_esm_feat`
  - pooled ESM feature is loaded by sequence string
- Official reproduction rule:
  - `node_feature` shape:
    - `(sequence_length, 1152)`
  - pooled sequence feature shape:
    - `(1152,)`
  - pooled file:
    - `protein_level/seq2feature.pkl`
  - key:
    - sequence string
  - pocket-node remains unpooled
- Next recommended execution:
  - validate or rebuild `seq2feature.pkl` from existing `node_level/*.npz`
  - do not rerun ESM-C inference
  - do not mix custom pooling into the official reproduction asset

## 2026-04-24 Validation of Existing Cloud Sequence-Level ESM Asset

- A read-only validation was run on the current cloud artifact:
  - `G:\esm\ESM-C_600M\protein_level\seq2feature.pkl`
- Validation outcome:
  - `VALIDATION PASS`
- Counts confirmed:
  - total UIDs: `195,743`
  - unique sequences: `164,514`
  - `node_level/*.npz`: `195,743`
  - `seq2feature.pkl` entries: `164,514`
- Numeric consistency checks:
  - 100 random UID sample comparisons against recomputed mean pooling:
    - max abs diff: `0.0`
    - missing keys: `False`
    - shape mismatches: `False`
  - 20 duplicate-sequence groups checked:
    - max within-group diff: `0.0`
- Important database decision:
  - the current cloud `seq2feature.pkl` is already the correct official
    sequence-level pooled ESM artifact
  - do **not** rerun sequence pooling
  - do **not** rebuild this file unless a future checksum or integrity audit
    finds corruption
- Storage detail recorded:
  - values are stored as `numpy.ndarray(float32)` with shape `(1152,)`
  - this remains compatible with current EnzymeCAGE downstream loading

## 2026-04-24 Sequence-Pooling Timeline Correction

- Database-history clarification recorded:
  - although the original `ESM-C` code performs pooling during generation,
    the current official cloud `seq2feature.pkl` should be regarded as the
    result of the `2026-04-17` offline rebuild from completed
    `node_level/*.npz`, not as an automatically trustworthy untouched output of
    the first interrupted long run
- Key facts:
  - incomplete intermediate pooled file after resume: `16,433`
  - final rebuilt cloud pooled file: `164,514`
  - `2026-04-24` read-only validation confirmed the rebuilt file remains
    correct
- Reporting rule:
  - describe the current sequence-level pooled asset as “complete and
    validated”
  - if timeline matters, say it was finalized by offline rebuild on
    `2026-04-17`

## 2026-04-24 Cloud Local-AlphaFill Route Clarification

- The cloud local-AlphaFill branch is now explicitly planned as a
  **Windows-native** route for that machine.
- Immediate target scope:
  - unresolved public-download subset only: `2,149` UIDs
  - not the full `4,453` missing-pocket set
- Reason:
  - the additional `1,578` AlphaFill-success-but-no-pocket rows are a separate
    extraction-logic problem and are not automatically solved by obtaining
    `PDB-REDO`
- Required components before execution:
  - Windows-side `PDB-REDO` mirror
  - AlphaFold input `.cif` structures for target UIDs
  - callable Windows-side `alphafill`
  - repo-like script layout for:
    - `feature/download_af2_structures.py`
    - `feature/extract_pocket.py`
    - `scripts/run_alphafill.py`
    - `custom/data_build/extract_alphafill_gap_pockets.py`
- Important code caveat:
  - when using `scripts/run_alphafill.py`, explicitly pass:
    - `--postfix transplant.cif`
  - to avoid accidental double-underscore naming
- Next action remains:
  - Windows-native preflight first
  - do not start `PDB-REDO` or AlphaFill before that preflight passes

## 2026-04-27 Substrate Extraction And Annotation

### Substrate Rule Now Materialized

- Source table:
  - `data/processed/rhea/2026-01-21/rhea_rxn2uids.csv`
- Rule used:
  - deduplicate by unique `CANO_RXN_SMILES`
  - take the left side of each canonical reaction as the substrate side
  - split left-side participants by `.`
  - deduplicate substrate molecules within each reaction before counting

### New Substrate Outputs

- Output directory:
  - `data/processed/rhea/2026-01-21/substrates/`
- Files:
  - `substrate_base_table.csv`
  - `substrate_review_table.csv`
  - `substrate_base_summary.txt`
  - `pubchem_lookup_cache.csv`
  - `substrate_final_table.csv`
  - `substrate_final_table_3cols.csv`
  - `substrate_provenance_table.csv`
  - `substrate_annotation_summary.txt`
  - `substrate_provenance_table_augmented_zh.csv`
  - `substrate_final_table_3cols_augmented_zh.csv`
  - `substrate_augmented_zh_summary.txt`

### Current Substrate Counts

- unique canonical reactions processed: `11,418`
- unique substrate structures: `6,152`
- structures with `*` dummy atoms / generic fragments: `996`
- final table rows: `6,152`

### Current Annotation Coverage

- English names filled: `5,822`
- Chinese names filled from direct traceable mappings: `539`
- rows tagged as emerging pollutants under current rule set: `91`

### Source Hierarchy Used

1. exact local Rhea/ChEBI mapping:
   - `data/raw/rhea/RHEA-140_2026-01-21/tsv/rhea-chebi-smiles.tsv`
   - `data/raw/rhea/RHEA-140_2026-01-21/tsv/chebiId_name.tsv`
2. PubChem PUG REST SMILES lookup for unresolved non-dummy structures
3. direct `ChEBI ID -> Wikidata` and `PubChem CID -> Wikidata` Chinese-label mapping

### Important Boundary

- The current final substrate table is traceable and ready for downstream
  review, but Chinese-name coverage is intentionally conservative because
  fuzzy name search and free translation were not used as primary final
  sources.
- Material class and emerging-pollutant flags are rule-based and should be
  treated as first-pass annotations, not as a fully manual chemistry curation.

### Second-Round Chinese Supplement Layer

- An additional augmented Chinese-candidate layer now exists on top of the
  strict traceable table.
- Current augmented summary:
  - original direct Chinese names: `539`
  - additional generated candidate Chinese names: `123`
  - augmented Chinese total: `662`
- Generated candidates are explicitly labeled by source type and should be
  treated as review candidates rather than as the same confidence level as the
  direct `Wikidata` / fixed-source Chinese names.

### Chinese-Name Website Provenance Layer

- To make Chinese-name sources directly auditable, a website-level provenance
  layer was added after the strict and augmented tables were built.
- New script:
  - `custom/data_build/annotate_zh_source_sites.py`
- New files:
  - `data/processed/rhea/2026-01-21/substrates/substrate_provenance_table_with_zh_websites.csv`
  - `data/processed/rhea/2026-01-21/substrates/substrate_provenance_table_augmented_zh_with_websites.csv`
  - `data/processed/rhea/2026-01-21/substrates/zh_name_source_websites_legend.csv`
  - `data/processed/rhea/2026-01-21/substrates/zh_name_source_websites.md`
- Added audit columns:
  - strict:
    - `name_zh_source_site`
    - `name_zh_source_site_url`
    - `name_zh_source_level`
    - `name_zh_supporting_id_site`
    - `name_zh_supporting_id_url`
  - augmented:
    - `name_zh_source_site_augmented`
    - `name_zh_source_site_url_augmented`
    - `name_zh_source_level_augmented`
    - `name_zh_supporting_id_site_augmented`
    - `name_zh_supporting_id_url_augmented`
- Actual row-level website reality in the current dataset:
  - direct strict Chinese names currently come mainly from `Wikidata` labels
    with `PubChem` identity anchors
  - simple common names like water / oxygen come from local fixed rules
  - augmented extra Chinese names remain explicitly labeled local generated
    candidates
- Important methodological boundary:
  - `CNTERM` / `NMPA` have been documented as preferred future high-standard
    Chinese-name sources, but they have **not** yet been applied row-by-row in
    the current substrate tables

### Final Completed 3-Column Table

- A final completed 3-column substrate table has now been materialized for the
  user-facing deliverable.
- New script:
  - `custom/data_build/complete_substrate_table.py`
- New outputs:
  - `data/processed/rhea/2026-01-21/substrates/substrate_provenance_table_completed.csv`
  - `data/processed/rhea/2026-01-21/substrates/substrate_final_table_3cols_completed.csv`
  - `data/processed/rhea/2026-01-21/substrates/substrate_completion_summary.txt`
  - caches:
    - `data/processed/rhea/2026-01-21/substrates/pubchem_retry_cache.csv`
    - `data/processed/rhea/2026-01-21/substrates/cactus_iupac_cache.csv`
- Main completion rules added:
  1. retry failed `PubChem` structure lookups for blank English names
  2. fallback to `CACTUS` structure-to-IUPAC only when `PubChem` still fails
  3. preserve direct traceable Chinese rows
  4. add broader exact/common-name Chinese maps
  5. add systematic component translation rules
  6. add lipid-abbreviation and eicosanoid-abbreviation translation rules
  7. add explicit identifier labels for `GlyTouCan` / `CID`-style names
- Final completion stats:
  - total rows: `6,152`
  - blank English cells after completion: `0`
  - blank Chinese cells after completion: `0`
  - English names newly recovered from retry lookup: `298`
  - rows still using explicit review-style Chinese placeholders:
    `1,003`
- User-facing path handling:
  - strict earlier table preserved at:
    - `data/processed/rhea/2026-01-21/substrates/substrate_final_table_3cols_strict_backup.csv`
  - `data/processed/rhea/2026-01-21/substrates/substrate_final_table_3cols.csv`
    has been replaced with the completed 3-column table

### Emerging Pollutant Audit On Completed Table

- The completed deliverable was audited specifically for stale
  `is_emerging_pollutant` / `emerging_pollutant_class` values after final
  English-name recovery.
- New durable script:
  - `custom/data_build/recheck_emerging_pollutants.py`
- Audit inputs:
  - `data/processed/rhea/2026-01-21/substrates/substrate_provenance_table_completed.csv`
  - `data/processed/rhea/2026-01-21/substrates/substrate_base_table.csv`
- Confirmed deterministic repair result:
  - `4` rows fixed from `否` to `是：广义新污染物-抗生素`
  - names:
    - `2'-Dehydrokanamycin A`
    - `Rhodomycin D`
    - `Nocamycin E`
    - `Chlortetracycline`
- Post-audit subclass counts:
  - `广义新污染物-抗生素`: `54`
  - `广义新污染物-内分泌干扰物`: `26`
  - `广义新污染物-药物/PPCPs`: `8`
  - `广义新污染物-农药/除草剂`: `5`
  - `中国重点管控新污染物-二氯甲烷`: `1`
  - `中国重点管控新污染物-五氯苯酚类`: `1`
  - total marked new pollutants after audit: `95`
- Additional audit artifacts:
  - `data/processed/rhea/2026-01-21/substrates/emerging_pollutant_confirmed_fixes.csv`
  - `data/processed/rhea/2026-01-21/substrates/emerging_pollutant_broader_review_candidates.csv`
  - `data/processed/rhea/2026-01-21/substrates/emerging_pollutant_audit_summary.txt`
- Important boundary:
  - `81` broader steroid-hormone-family candidates were exported for review
    only and were not auto-merged into the main deliverable

### 2026-04-27 Substrate Chinese-Name Gap Translation

- Investigated the `994` rows in `substrate_final_table_3cols_fixed.csv` that
  carry `待核中文名(...)` placeholder Chinese names.
- Bottleneck root cause:
  - the previous completion pipeline (`complete_substrate_table.py`) filled
    English names from PubChem/CACTUS retries but jumped to placeholder for
    Chinese when rule-based translation failed
  - `620 / 994` rows have ChEBI IDs but ChEBI does not provide Chinese names
  - `361 / 994` rows have PubChem CIDs but PubChem does not provide Chinese
    synonyms
- External data source audit:
  - ChEBI REST / GraphQL APIs: all 404 (decommissioned)
  - PubChem PUG REST / HTML: no Chinese synonyms for any tested compound
  - ChemicalBook: blocked by JS rendering
  - Conclusion: no authoritative biochemical database provides Chinese names
    for these compounds; external API crawling is not a viable path
- Chosen approach: LLM batch translation (方案 B) for `~944` translatable
  entries (skipping Unresolved structure rows)
- Test sample of `50` entries translated and saved for review:
  - `data/processed/rhea/2026-01-21/substrates/translation_test_50_result.csv`
- Next step: full batch translation of remaining entries, then overwrite
  placeholders in the 3-column table

## 2026-04-28 Recovered Substrate Deliverable State

- A recovery audit found that the substrate branch progressed after the
  `2026-04-27` log.
- Current user-facing substrate deliverable:
  - `data/processed/rhea/2026-01-21/substrates/substrate_final_table_3cols.csv`
- Current directory policy:
  - root `substrates/` keeps only the user-facing table plus `archive/`
  - provenance tables, summaries, caches, backups, translation tests, and
    translation inputs/results are under:
    - `data/processed/rhea/2026-01-21/substrates/archive/`
- Current table audit:
  - encoding: GB18030 / Excel-friendly Chinese encoding
  - bytes: `518,195`
  - SHA256:
    - `8a16581e59539dc69ae6ac9bd335f943560b61c49ab64f176ad2f4d5a5688b46`
  - lines including header: `6,153`
  - data rows: `6,152`
  - columns:
    - `底物英文`
    - `底物中文`
    - `底物分类`
    - `是否新污染物`
  - blank cells in all four columns: `0`
  - rows containing `待核中文名`: `0`
- Current new-pollutant counts:
  - total marked new pollutants: `95`
  - `广义新污染物-抗生素`: `54`
  - `广义新污染物-内分泌干扰物`: `26`
  - `广义新污染物-药物/PPCPs`: `8`
  - `广义新污染物-农药/除草剂`: `5`
  - `中国重点管控新污染物-五氯苯酚类`: `1`
  - `中国重点管控新污染物-二氯甲烷`: `1`
- Translation artifact:
  - `data/processed/rhea/2026-01-21/substrates/archive/待核中文名_待翻译清单.translated.csv`
  - data rows: `994`
  - unique English names: `994`
  - blank translated Chinese rows: `0`
- Scripts observed for the 2026-04-28 step:
  - `custom/data_build/fill_translated_zh_names.py`
  - `custom/data_build/cleanup_substrates.py`
- Important boundary:
  - this table is complete in the no-empty-cell/no-placeholder sense.
  - generated Chinese names remain lower-confidence review candidates and
    should not be described as fully database-native or manually curated
    chemical nomenclature.

## 2026-04-28 Microorganism Taxonomy Filter Audit

- User switched back to the microorganism branch and requested a check of the
  deduplicated microorganism table because animal whole-genome sources were
  observed.
- Existing unfiltered source tables:
  - `data/processed/rhea/2026-01-21/microbe/uid_to_source.csv`
    - UID rows: `195,743`
  - `data/processed/rhea/2026-01-21/microbe/source_signature_catalog.csv`
    - source signatures: `5,917`
- Audit/filter script:
  - `custom/data_build/audit_microbe_taxonomy_filter.py`
- Output directory:
  - `data/processed/rhea/2026-01-21/microbe/taxonomy_filter_2026-04-28/`
- Keep rule:
  - keep only bacteria, fungi, and archaea based on UniProt lineage:
    - `Bacteria (domain)`
    - `Fungi (kingdom)`
    - `Archaea (domain)`
- Audit result:
  - kept UID rows: `168,335`
  - excluded UID rows: `27,408`
  - kept source signatures: `3,234`
  - excluded source signatures: `2,683`
- UID taxonomy group counts:
  - `target_bacteria`: `152,044`
  - `target_archaea`: `8,637`
  - `target_fungi`: `7,654`
  - `animal_metazoa`: `15,853`
  - `plant_viridiplantae`: `8,858`
  - `other_eukaryota`: `1,784`
  - `virus`: `913`
- Source-signature taxonomy group counts:
  - `target_bacteria`: `2,481`
  - `target_archaea`: `178`
  - `target_fungi`: `575`
  - `animal_metazoa`: `926`
  - `plant_viridiplantae`: `1,077`
  - `other_eukaryota`: `195`
  - `virus`: `485`
- Animal genome/proteome contamination confirmed:
  - animal source signatures with genome assembly: `167`
  - animal UID rows represented by those assembly-linked animal signatures:
    `13,304`
  - largest examples:
    - human `UP000005640`, `GCA_000001405.29`, `2,680` UID rows
    - mouse `UP000000589`, `GCA_000001635.9`, `2,632` UID rows
    - rat `UP000002494`, `GCA_036323735.1`, `1,487` UID rows
    - bovine `UP000009136`, `GCA_002263795.4`, `1,101` UID rows
- Mixed-taxonomy source signatures:
  - `0`
  - filtering at `source_signature` level is safe for this current table.
- Generated proposed filter outputs:
  - `source_signature_taxonomy_audit.csv`
  - `source_signature_catalog_keep_bacteria_fungi_archaea.csv`
  - `source_signature_catalog_excluded_non_target.csv`
  - `uid_to_source_keep_bacteria_fungi_archaea.csv`
  - `uid_to_source_excluded_non_target.csv`
  - `microbe_taxonomy_filter_summary.json`
- Original unfiltered files were not overwritten.
- Next step:
  - after user confirmation, use the keep catalog for the next genome-candidate
    step or promote the filtered files into the main microbe branch.

## 2026-04-28 Local Python Environment Convention

- Environment check confirmed that plain shell commands are not automatically
  inside a virtual environment:
  - `python3`: `/usr/bin/python3`, version `3.10.12`
  - `VIRTUAL_ENV`: empty
  - `CONDA_PREFIX`: empty
- Preferred local data-build environment:
  - `.envs/rhea-clean`
  - interpreter:
    - `/home/a/EnzymeCAGE/.envs/rhea-clean/bin/python`
  - confirmed available packages include:
    - `pandas 2.3.3`
    - `numpy 1.26.4`
    - `requests 2.33.1`
    - `rdkit 2022.09.5`
    - `torch 2.2.1+cu121`
    - `dgl 2.1.0`
    - `localmapper 0.1.1`
- Future local custom data scripts should use the explicit interpreter path
  rather than relying on a persistent activation state.
- `.envs/esmc-gpu` is reserved for ESM/GPU work.
- `.envs/alphafill-build` is reserved for AlphaFill/PDB-REDO work.

## 2026-04-28 Microbe Genome Download Pilot

- Automated genome download was validated for the filtered
  bacteria/fungi/archaea source table.
- Official route checked:
  - NCBI Datasets genome package by assembly accession
  - genomic FASTA path inside package:
    - `ncbi_dataset/data/<assembly_accession>/*_genomic.fna`
- Local implementation:
  - `datasets` CLI absent
  - `unzip` absent
  - used NCBI Datasets v2 REST download endpoint plus Python `zipfile`
- Script:
  - `custom/data_build/download_ncbi_genome_fasta_probe.py`
- Input:
  - `data/processed/rhea/2026-01-21/microbe/taxonomy_filter_2026-04-28/source_signature_catalog_keep_bacteria_fungi_archaea.csv`
- Direct assembly accession coverage in filtered catalog:
  - source signatures with direct assembly: `1,355`
  - source signatures without direct assembly: `1,879`
  - UID rows covered by direct assemblies: `130,303`
  - UID rows needing candidate assembly search: `38,032`
- Pilot output:
  - `data/processed/rhea/2026-01-21/microbe/genome_download_probe_2026-04-28/pilot_100/`
- Pilot result:
  - attempted: `100`
  - downloaded and validated: `100`
  - failed: `0`
  - zip packages: `100`
  - genomic FASTA files: `100`
  - symlinks: `0`
  - total directory size: `457M`
  - total zip bytes: `107,520,036`
  - total FASTA bytes: `370,388,699`
  - total FASTA bases: `365,767,359`
  - taxonomy composition:
    - `target_bacteria`: `85`
    - `target_archaea`: `12`
    - `target_fungi`: `3`
- Key pilot files:
  - `genome_download_probe_manifest.csv`
  - `genome_download_probe_summary.json`
  - `genome_download_probe_selected_candidates.csv`
  - `zip_packages/`
  - `genomic_fna/`
- Current decision boundary:
  - automatic downloading is proven for direct assembly accessions.
  - before full production, decide whether to first materialize
    `source_signature_to_selected_genome.csv`.
  - no-assembly sources still need NCBI candidate assembly search and
    selection.

## 2026-04-28 Microbe Genome Selection Table Materialized

- Status:
  - completed the first production-side genome selection table for filtered
    microorganism sources with direct UniProt Proteomes assembly accessions
- Script:
  - `custom/data_build/build_source_signature_to_selected_genome.py`
- Interpreter:
  - `/home/a/EnzymeCAGE/.envs/rhea-clean/bin/python`
- Input:
  - `data/processed/rhea/2026-01-21/microbe/taxonomy_filter_2026-04-28/source_signature_catalog_keep_bacteria_fungi_archaea.csv`
- Outputs:
  - `data/processed/rhea/2026-01-21/microbe/genome_selection_2026-04-28/source_signature_to_selected_genome.csv`
  - `data/processed/rhea/2026-01-21/microbe/genome_selection_2026-04-28/source_signature_to_selected_genome_summary.json`
- Current output semantics:
  - one row per filtered `source_signature`
  - direct assembly rows are fully populated as selected
  - no-assembly rows are carried forward as pending placeholders
- Counts:
  - filtered source signatures total: `3,234`
  - direct assembly selected: `1,355`
  - pending NCBI candidate search: `1,879`
  - UID rows covered by selected direct assemblies: `130,303`
  - UID rows still pending search: `38,032`
- Validation:
  - selected rows missing accession: `0`
  - pending rows with non-empty accession: `0`
  - unique selected assembly accessions among direct rows: `1,355`
  - duplicate selected assembly accessions among direct rows: `0`
  - selected assembly level:
    - `full`: `1,355`
  - selected assembly source:
    - `ENA/EMBL`: `1,354`
    - `EnsemblFungi`: `1`
- Taxonomy composition:
  - selected direct rows:
    - `target_bacteria`: `1,030`
    - `target_archaea`: `121`
    - `target_fungi`: `204`
  - pending rows:
    - `target_bacteria`: `1,451`
    - `target_archaea`: `57`
    - `target_fungi`: `371`
- Current next step:
  - use the selected direct rows to drive production genome download
  - separately implement NCBI candidate assembly search and selection for the
    `1,879` pending rows

## 2026-04-28 Taxonomy-Filtered Main/Substrate Copy

- Status:
  - completed a separate downstream filtered dataset copy for the current
    bacteria / fungi / archaea keep set
  - the original main table and original substrate table were intentionally not
    overwritten
- Script:
  - `custom/data_build/build_taxonomy_filtered_main_and_substrates.py`
- Interpreter:
  - `/home/a/EnzymeCAGE/.envs/rhea-clean/bin/python`
- Inputs:
  - main table:
    - `data/processed/rhea/2026-01-21/rhea_rxn2uids.csv`
  - keep UID table:
    - `data/processed/rhea/2026-01-21/microbe/taxonomy_filter_2026-04-28/uid_to_source_keep_bacteria_fungi_archaea.csv`
  - completed substrate provenance:
    - `data/processed/rhea/2026-01-21/substrates/archive/substrate_provenance_table_completed.csv`
  - translated Chinese fill table:
    - `data/processed/rhea/2026-01-21/substrates/archive/待核中文名_待翻译清单.translated.csv`
- Output root:
  - `data/processed/rhea/2026-01-21/taxonomy_filtered_bacteria_fungi_archaea_2026-04-28/`
- Outputs:
  - filtered main table:
    - `rhea_rxn2uids_filtered_bacteria_fungi_archaea.csv`
  - filtered substrate provenance:
    - `substrates/substrate_provenance_table_filtered_bacteria_fungi_archaea.csv`
  - filtered user-facing substrate table:
    - `substrates/substrate_final_table_3cols_filtered_bacteria_fungi_archaea.csv`
  - summary:
    - `taxonomy_filtered_dataset_summary.json`
- Output counts:
  - filtered enzyme-reaction pairs: `227,056`
  - filtered unique `UniprotID`: `168,335`
  - filtered unique `RHEA_ID`: `8,870`
  - filtered unique `CANO_RXN_SMILES`: `6,122`
  - filtered unique substrates: `3,770`
- Removed relative to original:
  - removed enzyme-reaction pairs: `92,987`
  - removed reactions: `5,296`
  - removed substrates: `2,382`
- Reaction-coverage structure after UID filtering:
  - fully kept reactions: `4,438`
  - mixed reactions: `1,684`
  - fully removed reactions: `5,296`
- Substrate-table carryover policy:
  - substrate universe was rebuilt from the filtered reaction set, not by
    directly deleting rows from the old final table
  - filtered substrate provenance inherits annotation fields from the completed
    substrate provenance table
  - reaction-dependent provenance fields were recomputed:
    - `reaction_count`
    - `example_rhea_id`
    - `example_cano_rxn_smiles`
  - translated Chinese carryover applied from the existing fill table:
    - replacements applied: `586`
    - remaining `待核中文名` placeholders: `0`
- Filtered final user table audit:
  - blank `底物英文`: `0`
  - blank `底物中文`: `0`
  - blank `底物分类`: `0`
  - blank `是否新污染物`: `0`

## 2026-04-28 Genome Catalog And Production Downloader

- Status:
  - progressed the microorganism/genome branch from probe-only download
    validation into a production-ready downloader chain
- Important distinction:
  - `source_signature_to_selected_genome.csv` indicates selected assemblies,
    not already downloaded genomes
  - as of this session, `1,355` direct assemblies are selected, while `20`
    have been production-downloaded and validated
- New scripts:
  - `custom/data_build/build_genome_catalog_from_selected.py`
  - `custom/data_build/download_ncbi_genome_fasta_catalog.py`
- Interpreter:
  - `/home/a/EnzymeCAGE/.envs/rhea-clean/bin/python`
- New genome catalog outputs:
  - `data/processed/rhea/2026-01-21/microbe/genome_selection_2026-04-28/genome_catalog.csv`
  - `data/processed/rhea/2026-01-21/microbe/genome_selection_2026-04-28/genome_catalog_summary.json`
- Genome catalog counts:
  - unique selected assembly accessions: `1,355`
  - selected source-signature rows represented: `1,355`
  - selected UID rows represented: `130,303`
  - taxonomy composition:
    - `target_bacteria`: `1,030`
    - `target_archaea`: `121`
    - `target_fungi`: `204`
- Production downloader capabilities now implemented:
  - resume from existing manifest
  - `--skip` and `--limit` chunked execution
  - disk-space precheck
  - retry with exponential backoff for `429`/`5xx` and network failures
  - slower request pacing than the original probe script
  - per-row manifest checkpoint writes
- Current production output root:
  - `data/processed/rhea/2026-01-21/microbe/genome_download_direct_assembly_2026-04-28/`
- Production smoke result:
  - first `20` direct genomes downloaded and validated successfully
  - failed: `0`
  - immediate rerun confirmed manifest-based resume
- Current production smoke sizes:
  - `zip_packages/`: `139M`
  - `genomic_fna/`: `454M`
  - total zip bytes: `144,901,888`
  - total FASTA bytes: `475,159,027`
  - total FASTA bases: `469,105,555`
- Full-batch estimate:
  - pilot-based average per genome: about `4,779,087` total bytes
  - rough direct-assembly total for `1,355` genomes: about `6.03 GiB`
  - local free disk during run: about `843.7 GB`
- Current next step:
  - continue production download from the current manifest until the direct
    `1,355` selected assemblies are all materialized
  - then build the UID-to-selected-genome join
  - keep the `1,879` pending no-assembly sources for the later NCBI candidate
    assembly stage

## 2026-04-28 Cloud Handoff Package Audit And Python 3 Readiness

- The current genome-download continuation target on cloud is the handoff
  package:
  - `G:\EnzymeCAGE_cloud_handoff_2026-04-28`
- Intended package layout:
  - `docs/`
  - `scripts/`
  - `microbe/`
  - `taxonomy_filtered_dataset/`
- Cloud audit timeline, according to the user-relayed Windows-side Codex
  reports:
  - first audit failed because:
    - `taxonomy_filtered_dataset/` was missing
    - usable `python3` was absent; default `python` was `2.7.3`
  - second audit passed after the user re-transferred the missing subtree and
    installed a new Python 3 environment
- Passed cloud-side resume/audit facts:
  - package symlink count: `0`
  - `microbe/genome_download_direct_assembly_2026-04-28/` symlink count: `0`
  - `23` key files matched expected SHA256 / line counts
  - `zip_packages/` file count: `20`
  - `genomic_fna/` file count: `20`
  - `genome_download_manifest.csv` status counts:
    - `downloaded_and_validated`: `20`
    - `failed`: `0`
- Cloud execution interpreter now prepared:
  - `C:\Users\hp\.venvs\enzymecage-py312\Scripts\python.exe`
  - `Python 3.12.0`
  - `requests 2.33.1`
- Important boundary:
  - the cloud default `python` still points to `Python 2.7.3`
  - the downloader must therefore always be launched with the explicit `py312`
    interpreter above
- Current next step on cloud:
  - the first real resume smoke with `--limit 25` has now run on cloud and
    exposed a manifest-portability bug
  - cloud command exit code was `0`
  - cloud summary reported:
    - `target_row_count`: `25`
    - `downloaded_and_validated`: `5`
    - `failed`: `20`
  - cloud filesystem still contained:
    - `zip_packages`: `25`
    - `genomic_fna`: `25`
  - newly successful accessions:
    - `GCA_000006625.1`
    - `GCA_000006665.1`
    - `GCA_000006685.1`
    - `GCA_000006725.1`
    - `GCA_000006745.1`
- Diagnosis:
  - the first `20` rows were misclassified as failed because the transferred
    manifest contained local relative paths from the source machine
  - the old downloader let those stale paths override the current cloud
    `--output-dir`
  - this is not evidence that the direct-assembly download route is broken
- Fix prepared locally:
  - patched script:
    - `custom/data_build/download_ncbi_genome_fasta_catalog.py`
  - new SHA256:
    - `263b446a4c881d47b529905a20db85efd95c11316f261f49ef0fcd38288f5a9c`
  - behavior:
    - rediscover existing zip/fna under the current `--output-dir`
    - revalidate FASTA/zip metadata
    - recover stale-path or failed manifest rows as
      `downloaded_and_validated`
  - validation:
    - `py_compile` passed
    - local `/tmp` relocation smoke recovered one stale-path row without
      network access
- Cloud manifest repair result with patched downloader:
  - `--limit 25` rerun exited with code `0`
  - `genome_download_summary.json` status counts:
    - `downloaded_and_validated`: `25`
  - manifest status counts:
    - `downloaded_and_validated`: `25`
  - `zip_packages` file count: `25`
  - `genomic_fna` file count: `25`
  - stale-path failure state recovered from `5` successes / `20` failures to
    `25` successes / `0` failures
- Cloud `--limit 30` continuation smoke passed:
  - exit code: `0`
  - `genome_download_summary.json` status counts:
    - `downloaded_and_validated`: `30`
  - manifest status counts:
    - `downloaded_and_validated`: `30`
  - `zip_packages` file count: `30`
  - `genomic_fna` file count: `30`
  - newly successful accessions:
    - `GCA_000006765.1`
    - `GCA_000006785.2`
    - `GCA_000006805.1`
    - `GCA_000006825.1`
    - `GCA_000006845.1`
- Updated next step:
  - full direct-assembly continuation has now completed on cloud
  - user-reported result:
    - exit code: `0`
    - target row count: `1,355`
    - `downloaded_and_validated_count`: `1,355`
    - `failed_count`: `0`
    - manifest status counts:
      - `downloaded_and_validated`: `1,355`
    - `zip_packages`: `1,355`
    - `genomic_fna`: `1,355`
- Direct-assembly download status:
  - complete for all `1,355` selected direct assemblies
- New mapping script:
  - `custom/data_build/build_uid_to_selected_genome_from_manifest.py`
  - SHA256:
    - `b85578f75ec84d41f49e60d10a65412eacd66daf605f38480e327f92b44a0285`
  - outputs:
    - `source_signature_to_downloaded_genome_direct_assembly.csv`
    - `uid_to_selected_genome_direct_assembly.csv`
    - `uid_to_selected_genome_direct_assembly_summary.json`
  - local validation:
    - `py_compile` passed
    - local partial-manifest smoke with `--allow-incomplete` passed
- Updated next step:
  - run the mapping script on cloud without `--allow-incomplete`
  - expected cloud output:
    - downloaded direct source signatures: `1,355`
    - UID rows with downloaded direct genome: `130,303`
    - pending source signatures: `1,879`
  - do not start the `1,879` pending-source candidate search until direct
    mapping outputs are generated and audited
- Cloud mapping output status:
  - complete
  - exit code: `0`
  - selected direct source signatures: `1,355`
  - downloaded direct source signatures: `1,355`
  - UID rows with downloaded direct genome: `130,303`
  - pending source signatures: `1,879`
  - missing manifest accessions: `0`
  - failed manifest accessions: `0`
  - missing file accessions: `0`
- Cloud mapping taxonomy counts:
  - source signatures:
    - `target_archaea`: `121`
    - `target_bacteria`: `1,030`
    - `target_fungi`: `204`
  - UID rows:
    - `target_archaea`: `7,777`
    - `target_bacteria`: `116,253`
    - `target_fungi`: `6,273`
- Cloud mapping output SHA256:
  - `source_signature_to_downloaded_genome_direct_assembly.csv`:
    - `132fc64f43bdcdfda11e4d2e5ae5413b459ed8d11e754df179f9ecbf583da5e2`
  - `uid_to_selected_genome_direct_assembly.csv`:
    - `baaebb4007ae15785dce669e85e2e6794e294f88530fe4313bd0353d55edb9c8`
  - `uid_to_selected_genome_direct_assembly_summary.json`:
    - `cb19a87a1cf1beba311434a1ecf39dda01dd42a87059a15f47e8292cb6cd0efc`
- Current boundary:
  - direct-assembly download and mapping are complete
  - next branch decision is pending:
    - candidate assembly search for `1,879` pending source signatures
    - or metabolic-model environment/input preflight for `1,355` direct genomes

## 2026-04-29 Pending Genome Candidate Search Pilot

- Branch chosen:
  - solve the `1,879` no-direct-assembly source signatures before metabolic
    model construction
- New script:
  - `custom/data_build/build_pending_genome_candidates.py`
  - SHA256:
    - `af84fd197d77649576c2c8381e6704dd37aa63ea55743062e0d82a753ab9e7db`
- Data source:
  - NCBI Datasets REST API
  - endpoint:
    - `https://api.ncbi.nlm.nih.gov/datasets/v2/genome/taxon/{tax_id}/dataset_report`
  - no NCBI datasets CLI dependency
- Input table:
  - `data/processed/rhea/2026-01-21/microbe/genome_selection_2026-04-28/source_signature_to_selected_genome.csv`
  - filtered to `selection_status = pending`
- Pilot output directory:
  - `data/processed/rhea/2026-01-21/microbe/pending_genome_candidate_search_2026-04-29/pilot_50/`
- Pilot command status:
  - `py_compile` passed
  - `--limit 50` completed with exit code `0`
- Pilot summary:
  - target pending source signatures: `50`
  - candidate rows: `591`
  - automatically selected source signatures: `39`
  - still pending/manual-review source signatures: `11`
  - selected UID total: `476`
  - status counts:
    - `selected`: `39`
    - `pending`: `11`
  - confidence counts:
    - `high`: `16`
    - `medium`: `23`
    - `low`: `0`
    - `manual_review`: `11`
  - selected assembly source counts:
    - `SOURCE_DATABASE_REFSEQ`: `32`
    - `SOURCE_DATABASE_GENBANK`: `7`
  - selected assembly level counts:
    - `Complete Genome`: `21`
    - `Scaffold`: `11`
    - `Contig`: `7`
- API audit:
  - HTTP `200`: `50 / 50`
  - API errors: `0`
  - zero-candidate/manual-review rows: `11`
- Current output checksums:
  - `genome_catalog_pending_candidate.csv`:
    - `59457158040d2b6ba64f9edefdc09e826712c498a41606632dcc8268a4fc7b9d`
  - `source_signature_to_selected_genome_pending_candidate.csv`:
    - `36053b15d8c031fab485999435c28502b7c4285f5d9eefa46b8e796a10702fd6`
  - `pending_genome_candidate_summary.json`:
    - `6481e74000a01be0263d72385360008239c783979e6c86552f9cbe206fa44092`
- Current boundary:
  - full `1,879` candidate selection is not run yet
  - cloud download for pending candidates is not prepared yet
  - next step is to review the selection/confidence standard and decide
    whether to add a fallback route for zero-candidate TaxIDs

### 2026-04-29 Zero-Candidate Fallback Diagnosis

- `exclude_atypical=false` was clarified:
  - it relaxes the NCBI Datasets atypical-assembly filter
  - it may increase recall but can lower genome quality
  - it was not used to produce the original `39 / 50` pilot selections
- Local same-TaxID fallback output:
  - `data/processed/rhea/2026-01-21/microbe/pending_genome_candidate_search_2026-04-29/fallback_pilot_11_clean/`
  - target rows: `11`
  - recovered rows: `0`
  - still pending rows: `11`
  - `genome_catalog_fallback.csv`: header only
- User-reported external parent/higher-taxon test:
  - the exact `11` TaxIDs have no NCBI Genomes entry
  - parent or higher taxa have many genomes
  - exact-strain recovery is not available
  - parent/higher-taxon fallback is possible only as low-confidence or manual
    review candidate
- Updated boundary:
  - full `1,879` candidate selection is not yet run
  - next full-run strategy should separate strict exact-TaxID hits,
    exact-TaxID `exclude_atypical=false` hits, low-confidence parent/higher-
    taxon fallback, and `no_genome_available`

### 2026-04-29 NCBI Website Cross-Verification

- User verified 4 TaxIDs on ncbi.nlm.nih.gov/datasets/genome/?taxon=XXXX
  - 101028 and 1063 showed genomes (success confirmed)
  - 1004011 and 106355 showed 0 genomes (data gap confirmed)
- API and website results are consistent
- The 11 zero-candidate TaxIDs are real NCBI data gaps

## 2026-04-30 Full Pending Genome Candidate Query

- Full exact-TaxID strict query completed for the `1,879` pending source
  signatures.
- Output directory:
  - `data/processed/rhea/2026-01-21/microbe/pending_genome_candidate_search_2026-04-30/full_strict_1879/`
- Query policy:
  - NCBI Datasets REST
  - exact source `TaxID`
  - `assembly_version=latest`
  - `exclude_atypical=true`
  - `page_size=100`
  - `max_pages_per_taxid=5`
  - no parent/higher-taxon fallback
  - no external database fallback
- API audit:
  - HTTP `200`: `1,879 / 1,879`
  - API errors: `0`
  - cache JSON files: `1,879`
- Full strict result:
  - target pending source signatures: `1,879`
  - candidate rows: `77,509`
  - selected rows: `1,525`
  - manual-review / zero-candidate rows: `354`
  - selected UID total: `30,579`
  - confidence counts:
    - `high`: `365`
    - `medium`: `1,153`
    - `low`: `7`
    - `manual_review`: `354`
  - selected assembly source counts:
    - `SOURCE_DATABASE_REFSEQ`: `1,260`
    - `SOURCE_DATABASE_GENBANK`: `265`
  - selected assembly level counts:
    - `Complete Genome`: `850`
    - `Chromosome`: `77`
    - `Scaffold`: `330`
    - `Contig`: `268`
- Download-ready strict high/medium subset:
  - source signatures: `1,518`
  - UID rows: `30,561`
  - catalog:
    - `data/processed/rhea/2026-01-21/microbe/pending_genome_candidate_search_2026-04-30/full_strict_1879/genome_catalog_pending_candidate_high_medium.csv`
  - SHA256:
    - `985f64ae236de3cadcf7c7d52f6e87eaf08394f2e038810695fae251ef0882ed`
- Holdout tables:
  - low-confidence selected candidates:
    - `low_confidence_selected_candidates.csv`
    - `7` source signatures, `18` UID rows
  - exact-TaxID zero-candidate worklist:
    - `manual_review_exact_taxid_zero_candidate.csv`
    - `354` source signatures, `7,453` UID rows
- Combined high/medium-or-better genome coverage after this step:
  - direct Proteomes assembly branch:
    - `1,355` source signatures, `130,303` UID rows
  - strict exact-TaxID high/medium branch:
    - `1,518` source signatures, `30,561` UID rows
  - total:
    - `2,873 / 3,234` source signatures
    - `160,864 / 168,335` UID rows
- Current boundary:
  - high/medium exact-TaxID catalog can be considered for cloud download
    after user accepts the policy
  - `7` low-confidence rows should not be included yet
  - `354` zero-candidate rows should go to second-stage rescue:
    exact TaxID with `exclude_atypical=false`, then NCBI text/BioSample/
    Assembly synonym rescue, then external databases if still unresolved

### 2026-04-30 Pending High/Medium Cloud Download Package

- Prepared transfer package:
  - `data/processed/rhea/2026-01-21/cloud_transfer/pending_genome_download_high_medium_2026-04-30/`
- Package audit:
  - size: `101M`
  - regular files: `17`
  - symlinks: `0`
- Correct cloud download catalog:
  - `catalogs/genome_catalog_pending_candidate_high_medium_unique_assembly.csv`
  - rows including header: `1,517`
  - unique assembly accessions: `1,516`
  - source signatures represented: `1,518`
  - UID rows represented: `30,561`
  - SHA256:
    - `099b72fe17e2a6ee3d7b5ea0d551eeefb8b5748f370af110c0d2829045ce5d43`
- Important count rule:
  - expected cloud download count is `1,516`, not `1,518`
  - `1,516` unique assemblies cover `1,518` source signatures
- Expected cloud download result:
  - `downloaded_and_validated = 1,516`
  - failed count: `0`
  - `zip_packages = 1,516`
  - `genomic_fna = 1,516`
- Holdouts remain:
  - low confidence: `7` source signatures
  - exact-TaxID zero-candidate: `354` source signatures

### 2026-05-05 Cloud Package Audit Status

- User reported cloud-side audit failed before download.
- Download was not run.
- Failure reason:
  - the expected top-level directories were still present as zip files:
    - `audit.zip`
    - `catalogs.zip`
    - `docs.zip`
    - `microbe.zip`
    - `scripts.zip`
  - therefore `catalogs\...csv` and `scripts\...py` did not exist as real
    filesystem paths
- Passing facts:
  - symlink / reparse-point count: `0`
  - `HANDOFF_AUDIT_SUMMARY.json` values matched
  - Python interpreter exists:
    - `C:\Users\hp\.venvs\enzymecage-py312\Scripts\python.exe`
  - required catalog and downloader hashes matched inside the zip files
- Required next step:
  - expand the five zip files into real top-level directories in a clean
    expanded package directory
  - re-run the audit
  - only run the download after expanded audit passes

### 2026-05-06 Pending High/Medium Cloud Download Status

- Cloud package audit later passed.
- Pending high/medium exact-TaxID genome download completed on cloud.
- Resume behavior:
  - one command-window timeout occurred at the tool layer
  - Python downloader continued in background
  - first pass reached `1,505` successes and `11` failed
  - manifest resume retried and recovered all `11` failed rows
- Final user-reported result:
  - exit code: `0`
  - `target_row_count`: `1,516`
  - summary status counts:
    - `downloaded_and_validated`: `1,516`
  - `downloaded_and_validated_count`: `1,516`
  - `failed_count`: `0`
  - manifest status counts:
    - `downloaded_and_validated`: `1,516`
  - `zip_packages`: `1,516`
  - `genomic_fna`: `1,516`
  - failed details: none
- Count interpretation:
  - `1,516` unique assemblies downloaded
  - these represent `1,518` source signatures and `30,561` UID rows
- Required next validation:
  - final read-only post-download audit comparing catalog, manifest, summary,
    local zip/fna files, and stored SHA256 values before downstream mapping

### 2026-05-06 Pending High/Medium Post-Download Audit Passed

- User reported the final cloud read-only integrity audit passed.
- Audit result:
  - `POST_DOWNLOAD_AUDIT_PASSED`: yes
  - command exit code: `0`
  - `bad_manifest_rows_count`: `0`
  - `zip_file_count`: `1,516`
  - `fna_file_count`: `1,516`
  - `accession_diff_count`: `0`
  - `summary_failed_count`: `0`
  - `reparse_point_count`: `0`
- Interpretation:
  - pending high/medium genome download content is complete
  - manifest, summary, catalog accessions, zip files, and fna files are
    internally consistent
  - expected assembly count remains `1,516` unique assemblies
  - these map back to `1,518` high/medium pending source signatures and
    `30,561` UID rows
- Next cloud step:
  - run source-signature and UID materialization from the download manifest
  - expected output rows:
    - source-signature CSV: `1,519` lines including header
    - UID CSV: `30,562` lines including header
  - do not include the `7` low-confidence rows or the `354` exact-TaxID
    zero-candidate/manual-review rows

### 2026-05-06 Pending High/Medium UID Mapping Completed

- User reported cloud mapping/materialization completed.
- No download command was re-run.
- Mapping command result:
  - `MAPPING_EXIT_CODE`: `0`
  - `expected_pass`: `true`
- Summary counts:
  - `selected_source_signatures`: `1,518`
  - `downloaded_source_signatures`: `1,518`
  - `uid_rows_with_downloaded_genome`: `30,561`
  - `pending_source_signatures`: `0`
  - `missing_manifest_accessions_count`: `0`
  - `failed_manifest_accessions_count`: `0`
  - `missing_file_accessions_count`: `0`
- Output line counts:
  - source mapping CSV: `1,519` lines including header
  - UID mapping CSV: `30,562` lines including header
- Output SHA256:
  - source CSV:
    `03fda392bb6a7891fb7efde136511ea386c80d74f2772ec884b7630461d5c598`
  - UID CSV:
    `f39ed9d41b92b44f9743d4ea747605c728b2a861fbcd038179950cc4c4e1f69e`
  - summary JSON:
    `f0e404be1ca689cc749cfd0bd4916d5feb21093ea76775a36dbed33de5423f54`
- Combined genome-backed coverage so far:
  - direct branch: `1,355` source signatures, `130,303` UID rows
  - pending high/medium branch: `1,518` source signatures, `30,561`
    UID rows
  - total: `2,873 / 3,234` source signatures
  - total: `160,864 / 168,335` UID rows
- Remaining unresolved genome assignment:
  - `361` source signatures
  - `7,471` UID rows
  - includes `7` low-confidence rows and `354` exact-TaxID
    zero-candidate/manual-review rows
- Next required build step:
  - combine direct and pending high/medium mapping outputs into a single
    genome-backed UID mapping table
  - keep unresolved rows separate for manual/fallback policy review

### 2026-05-06 Genome-Backed Model Input Merge Completed

- User reported cloud merge completed with `expected_pass = true`.
- Output directory:
  - `G:\EnzymeCAGE_genome_backed_model_input_2026-05-06`
- Merged clean model-input coverage:
  - `combined_source_rows`: `2,873`
  - `combined_uid_rows`: `160,864`
  - `unique_model_genomes`: `2,869`
  - `unresolved_source_signatures`: `361`
  - `unresolved_uid_rows`: `7,471`
- Merge audits:
  - source overlap count: `0`
  - UID overlap count: `0`
  - UID missing source count: `0`
  - bad artifact count: `0`
  - assembly content conflict count: `0`
- Output line counts:
  - source CSV: `2,874` lines including header
  - UID CSV: `160,865` lines including header
  - unique genome manifest: `2,870` lines including header
- Output SHA256:
  - source CSV:
    `25e005902a577bc905eff7d6e744434829bc13c695ef0cf5ec5627a4dd35b12c`
  - UID CSV:
    `83a6923eba7d04f2cd85cc5dd6e764dd7f96fcd23910b9310d5b94d185bc6cf9`
  - unique genome manifest:
    `8bde0227564e3b9e42ff0086b923c886084a80cdb9a8706ccfcee723a00d09d4`
  - summary JSON:
    `3afedb5e0ea4190a4df9757889b80a15a4f8c808037323fa886be2982cd84718`
- Modeling input boundary:
  - use `unique_genome_fasta_for_modeling.csv` for one-model-per-unique-genome
    execution
  - use `uid_to_selected_genome_clean_high_medium.csv` only for downstream
    back-mapping to UID / enzyme / reaction rows
  - current FASTA files are genomic contig/scaffold FASTA files downloaded via
    NCBI `GENOME_FASTA`
  - do not feed raw genomic contigs directly into a CarveMe-like reconstruction
    without gene calling or an equivalent protein/gene FASTA route
- Required next step:
  - metabolic-model environment and input preflight on cloud
  - only after preflight passes, run a small smoke test before any full model
    reconstruction

### 2026-05-06 NGDC/GWH Rescue Index For Remaining Genome Gaps

- Created and ran NGDC/GWH TaxID rescue indexing script:
  - `custom/data_build/build_ngdc_gwh_taxid_rescue_index.py`
  - script SHA256:
    `b88a01336b718f877b5f366975a8638a668a15f1cd6a86025ff67bc2b44fe5b1`
- Query endpoint:
  - `https://ngdc.cncb.ac.cn/gwh/gwhSearch/api`
- Query term:
  - `attrs.taxonomy_id:(TaxID) OR attrs.tax_lineage:(TaxID)`
- Important distinction:
  - NGDC/GWH public detail API uses internal genome IDs or assembly
    accessions
  - TaxID rescue must first use the search endpoint to obtain assembly-level
    records and download links
- Input gap rows:
  - `7` low-confidence selected candidates
  - `354` manual-review exact-TaxID zero-candidate rows
  - total: `361` source signatures
- Output directory:
  - `data/processed/rhea/2026-01-21/microbe/ngdc_gwh_rescue_2026-05-06/full_exact_taxid_361`
- Run result:
  - processed source signatures: `361`
  - processed unique TaxIDs: `361`
  - cache JSON files: `361`
  - candidate rows: `365`
  - source with hits: `10`
  - source with zero hits: `351`
  - exact-TaxID candidate rows: `3`
  - descendant-of-source-TaxID candidate rows: `11`
  - no-hit rows: `351`
- Manual-review exact-TaxID rescue hits:
  - TaxID `295838`, `Streptomyces rugosporus`,
    `GWHFGFS00000000.1`, direct NGDC/GWH submission
  - TaxID `60481`, `Shewanella sp. (strain MR-7)`,
    `GWHAAYS00000000`, direct NGDC/GWH submission
  - TaxID `84635`, `Bacillus sp. (strain GL1)`,
    `GCA_039680825.1`, NGDC mirror of NCBI assembly
- Output SHA256:
  - `ngdc_gwh_taxid_index_candidates.csv`:
    `9bf8221cfdff36e4e1bdb930fd3b8242f209a538521443b8401ff5cc70315823`
  - `ngdc_gwh_taxid_query_audit.csv`:
    `20c5f69681ce9a279077edcf949c530e7adc7eef78fafa40e833b47a4d2eaef1`
  - `ngdc_gwh_taxid_index_summary.json`:
    `e1eec877131744a2c9026ab709fd53a7582389bb1ab4dfb65779e33638d999d5`
- Interpretation:
  - NGDC/GWH exact TaxID/lineage search rescues `3 / 354`
    manual-review rows
  - `351 / 354` manual-review rows still have no exact TaxID/lineage hit in
    NGDC/GWH
  - low-confidence descendant hits remain separate and should not enter the
    clean model-input set without an explicit fallback policy
- Next step:
  - detail/downloadability audit for the `3` exact-TaxID candidates
  - then optionally create a tiny rescue download manifest
  - do not merge these into the clean model input until download and mapping
    audits pass

### 2026-05-06 Unresolved Genome Source List Materialized

- Created a standalone CSV listing all `361` source signatures that are not
  currently represented in the clean downloaded-genome set.
- Output:
  - `data/processed/rhea/2026-01-21/microbe/unresolved_genome_source_list_2026-05-06/unresolved_361_microbe_sources_missing_genome.csv`
- Summary:
  - `data/processed/rhea/2026-01-21/microbe/unresolved_genome_source_list_2026-05-06/unresolved_361_microbe_sources_missing_genome_summary.json`
- Counts:
  - rows: `361`
  - lines including header: `362`
  - UID rows represented: `7,471`
  - low-confidence selected-not-downloaded rows: `7`
  - manual-review zero-candidate rows: `354`
  - target archaea: `14`
  - target bacteria: `284`
  - target fungi: `63`
  - NGDC/GWH exact-TaxID best hits: `3`
  - NGDC/GWH descendant best hits: `7`
  - NGDC/GWH no-hit rows: `351`
- Output hashes:
  - CSV:
    `72e68f8ee56b733bed57684b96b7373d3e5f5af2c10c601b94c23c9ddb5dc890`
  - summary JSON:
    `e7b2e26cc6b54f149f055fcfe5fe24ba2764a1f681dcbaa3edb6970f55d615ef`

### 2026-05-06 Online Taxonomy Stats For Unresolved Genomes

- Queried NCBI Taxonomy online for the `361` unresolved source signatures.
- Script:
  - `custom/data_build/build_unresolved_genome_taxonomy_online_stats.py`
  - SHA256:
    `c7007ff2ddf32e667f435bf815a11b9bd4dc98333793a2df0fc9ba631db2070e`
- Online source:
  - NCBI E-utilities `efetch.fcgi`
  - `db=taxonomy`
  - `retmode=xml`
- Output directory:
  - `data/processed/rhea/2026-01-21/microbe/unresolved_genome_taxonomy_online_2026-05-06`
- Query audit:
  - source rows: `361`
  - unique TaxIDs: `361`
  - taxonomy records returned: `361`
  - missing TaxIDs: `0`
  - represented UID rows: `7,471`
- Domain composition:
  - Bacteria: `284` source signatures, `6,870` UID rows
  - Eukaryota / fungi: `63` source signatures, `132` UID rows
  - Archaea: `14` source signatures, `469` UID rows
- Largest phyla:
  - Pseudomonadota: `140`
  - Actinomycetota: `64`
  - Ascomycota: `44`
  - Bacillota: `33`
  - Basidiomycota: `16`
  - Cyanobacteriota: `15`
  - Methanobacteriota: `11`
  - Bacteroidota: `8`
- Largest genera:
  - Streptomyces: `24`
  - Bacillus: `18`
  - Pseudomonas: `16`
  - Buchnera: `10`
  - Arthrobacter: `7`
  - Agrobacterium: `6`
  - Aspergillus: `6`
  - Corynebacterium: `6`
  - Penicillium: `6`
- Main files:
  - `unresolved_361_microbe_sources_ncbi_taxonomy_lineage.csv`
  - `unresolved_361_ncbi_domain_counts.csv`
  - `unresolved_361_ncbi_kingdom_counts.csv`
  - `unresolved_361_ncbi_phylum_counts.csv`
  - `unresolved_361_ncbi_class_counts.csv`
  - `unresolved_361_ncbi_genus_counts.csv`
  - `unresolved_361_ncbi_taxonomy_summary.json`
- Summary JSON SHA256:
  - `4ea5882183ab47b174685422f8bd4de2d0f8d751c6d802c4af4d21123afa7236`

### 2026-04-30 Multi-Database Cross-Query Pilot Completed

- 11 zero-candidate TaxIDs from pilot_50 cross-queried against NCBI
  E-utilities, ENA, JGI GOLD, and PATRIC
- Script: `custom/data_build/build_multi_db_genome_cross_query.py`
- Result: all 11 confirmed zero across all reachable databases
  - NCBI E-utilities (esearch assembly): all zero
  - ENA assembly search: all zero
  - PATRIC by taxid: all zero
  - PATRIC by genus: found genus-level genomes, zero exact-taxid matches
  - JGI GOLD: unreachable (TLS handshake failure, server-side issue)
- Conclusion: These are genuine orphan strains — UniProt has their proteins
  but no database has their genome assemblies. No external database can
  recover exact-strain genomes for them.

### 2026-05-07 CarveMe Environment Package Audit

- Teacher-provided CarveMe environment package inspected locally:
  - extracted directory:
    `/mnt/c/Users/Melo/Downloads/envname`
  - archive:
    `/mnt/c/Users/Melo/Downloads/envname.tar.gz`
- The extracted directory is a flattened/broken Linux environment:
  - symlinks observed: `0`
  - `scip` fails because `libtbb.so.12` symlink is missing
  - direct `carve` fails because `bin/python` symlink is missing
- The tar archive preserves symlinks:
  - symlink count inside archive: `1,394`
  - cloud/Linux extraction must use the `.tar.gz`, not the Windows-extracted
    directory
- Useful included components:
  - CarveMe `1.6.2`
  - DIAMOND `2.1.10`
  - SCIP `9.1.1`
  - PySCIPOpt `5.1.1`
  - COBRApy `0.29.1`
  - reframed `1.5.3`
- `prodigal` is not included.
- CarveMe `--dna` mode is available and uses DIAMOND `blastx`, so the first
  smoke test can be:
  - genomic `.fna` input
  - `carve --dna`
  - `--solver scip`
- CPLEX is not portable from this package:
  - `site-packages/cplex` is an absolute symlink to the teacher's machine
    path under `/work/home/aclhl3hbth/Cplex/...`
  - use CPLEX only if the cloud machine separately has a valid CPLEX install
    and license
- Next cloud step remains environment unpack/verification and `smoke10`, not a
  full `2,869` genome run.

### 2026-05-07 Cloud `enzymecage-gem` Environment Installed

- User reported that cloud installation finished successfully in:
  - `/home/jinying/miniconda3/envs/enzymecage-gem`
- Validated components:
  - Python `3.10.20`
  - Prodigal `2.6.3`
  - CarveMe command available
  - DIAMOND `2.1.13`
  - pandas `2.3.3`
  - PySCIPOpt import OK
- Teacher tar package remains at:
  - `/home/jinying/gem/envname.tar.gz`
- Current operational choice:
  - do not extract/use the tar package now
  - use the fresh environment for smoke testing
  - keep tar package as backup/provenance
- Next step:
  - run `smoke10`
  - first route:
    `genomic.fna -> prodigal .faa -> carve --solver scip -> SBML .xml`
  - no full reconstruction until smoke test passes and outputs are audited

### 2026-05-07 Full Genome FASTA Teacher Package

- Full genome FASTA source is cloud-side:
  - direct assembly:
    `G:\EnzymeCAGE_cloud_handoff_2026-04-28\microbe\genome_download_direct_assembly_2026-04-28\genomic_fna`
    - `.fna`: `1,355`
  - pending high/medium:
    `G:\EnzymeCAGE_pending_genome_download_high_medium_2026-04-30\microbe\genome_download_pending_exact_taxid_high_medium_2026-04-30\genomic_fna`
    - `.fna`: `1,516`
- Local repo is not complete for this asset:
  - observed local direct `.fna`: `20`
  - observed local pending `.fna`: `0`
- Clean unique-genome package created on cloud from the preflighted manifest:
  - `/home/jinying/gem/EnzymeCAGE_unique_genomic_fna_2869_2026-05-07`
- Package audit reported by user:
  - rows in source manifest: `2,869`
  - packaged `.fna`: `2,869`
  - total `.fna` bytes: `28,799,737,964`
  - directory size: `27G`
- This package is the correct teacher handoff source for genome FASTA files,
  because it uses the deduplicated `unique_genome_fasta_for_modeling` manifest.
- User reported the package was transferred.
- Destination-side audit still needed if this transfer is used as a formal
  reproducible handoff:
  - destination path
  - `.fna` count or archive checksum
  - archive size if packed as `.tar`, `.tar.gz`, or `.tar.zst`

### 2026-05-07 Prodigal-Only Branch Decision

- User paused the prior slow modeling smoke test.
- Current cloud branch should run Prodigal only:
  - input:
    `/home/jinying/gem/EnzymeCAGE_genome_backed_model_input_2026-05-06/unique_genome_fasta_for_modeling.linux_paths_preflight.csv`
  - environment:
    `/home/jinying/miniconda3/envs/enzymecage-gem`
  - expected tool:
    `prodigal 2.6.3`
- CarveMe/GEM reconstruction is postponed.
- Next verification:
  - Prodigal-only smoke test
  - if passed, batch Prodigal on bacteria/archaea only
  - keep fungi separate from this formal Prodigal route

### 2026-05-07 Prodigal Smoke10 Passed

- Cloud smoke output:
  - `/home/jinying/gem/EnzymeCAGE_prodigal_smoke10_2026-05-07`
  - `prodigal_smoke10_summary.csv`
- Smoke count:
  - attempted: `10`
  - successful Prodigal exit code: `10`
  - `.faa` exists: `10`
  - protein count > 0: `10`
- Protein count range:
  - `903` to `5,681`
- This validates the Prodigal-only path for bacteria/archaea examples.
- Proceed to full bacteria/archaea Prodigal batch only.
- CarveMe/GEM modeling remains explicitly postponed.

### 2026-05-07 Unresolved 361 Provenance Status

- Added a provenance audit for the unresolved missing-genome set:
  - `/home/a/EnzymeCAGE/data/processed/rhea/2026-01-21/microbe/unresolved_provenance_audit_2026-05-07`
- Coverage:
  - `361` source signatures
  - `7,471` UID rows
  - `9,941` filtered Rhea enzyme-reaction rows
  - `1,416` directional `RHEA_ID`
  - `1,170` unique `MASTER_ID`
  - `862` EC numbers
- Provenance conclusion:
  - local/filtered Rhea tables do not contain source-genome provenance beyond
    the `UniprotID` bridge
  - raw `rhea2uniprot_sprot.tsv` also only stores:
    - `RHEA_ID`
    - `DIRECTION`
    - `MASTER_ID`
    - `ID`
  - `rhea2xrefs.tsv` adds external database name at the reaction level, not
    organism/genome provenance
- UID-source conclusion:
  - all unresolved rows remain only `taxon_organism` level
  - no unresolved row retains a usable local:
    - `proteome_id`
    - `proteome_raw`
    - `genome_assembly_from_proteome`
    - `proteome_organism_id`
    - `proteome_strain_name`
- Next recommended rescue direction:
  - query reviewed UniProt entries for the unresolved `7,471` UIDs to extract
    assembly-adjacent cross-references and literature provenance

### 2026-05-07 GT-S `1111707` Taxonomy Mismatch

- Added case audit:
  - `/home/a/EnzymeCAGE/custom/docs/CASE_AUDIT_1111707_SYNECHOCYSTIS_GT-S_2026-05-07.md`
- Database-level conclusion:
  - local unresolved source
    `taxon:1111707|organism:synechocystis sp. (strain pcc 6803 / gt-s)` is not
    based on a bogus local TaxID
  - reviewed UniProtKB entries use active `organism_id = 1111707`
  - but the recoverable GT-S proteome/genome is indexed under species-level
    `taxonomy_id = 1148`
- Confirmed external linkage:
  - UniProt Proteomes:
    - `UP000008187`
  - assembly:
    - `GCA_000270265.1`
  - UniProtKB genomic xref:
    - `EMBL: AP012205`
- Pipeline implication:
  - exact-TaxID zero-report is not sufficient evidence that no recoverable
    genome exists

### 2026-05-07 Full Unresolved UniProt/Taxonomy Rescue Status

- Added full official online audit:
  - script:
    `/home/a/EnzymeCAGE/custom/data_build/audit_unresolved_uniprot_taxonomy_rescue.py`
  - output:
    `/home/a/EnzymeCAGE/data/processed/rhea/2026-01-21/microbe/unresolved_uniprot_taxonomy_rescue_2026-05-07`
- Coverage:
  - `361` unresolved source signatures
  - `7,471` unresolved UID rows
- Current online signal summary:
  - direct reviewed-entry Proteomes xref now: `0`
  - genomic EMBL evidence now: `326` sources
  - exact same-TaxID Proteomes hits now: `0`
  - strong species-level strain match plus EMBL: `5`
  - moderate-or-better species-level strain match plus EMBL: `10`
  - no current UniProt rescue signal: `35`
- Operational interpretation:
  - most unresolved rows still do not become direct Proteomes rows under the
    current exact source TaxID
  - however, most unresolved rows still retain reviewed-entry genomic evidence
    through EMBL
  - the next rescue work should be split:
    1. high-priority species-level strain-match candidates
    2. broader EMBL/GenBank accession-to-assembly resolution for the `326`
       genomic-EMBL cases

### 2026-05-07 Species-Level Strain Match Rescue Catalog Materialized

- Script:
  - `/home/a/EnzymeCAGE/custom/data_build/build_rescue_genome_catalog_species_strain_match.py`
  - SHA256: `227a3ef2914d11fb2f6cbe0f4af7ee826e97aa1d99d09934da55dab68681b2e8`
- Output:
  - `/home/a/EnzymeCAGE/data/processed/rhea/2026-01-21/microbe/unresolved_species_strain_rescue_2026-05-07`
- Catalog shape:
  - `10` source signatures, `9` unique assemblies, `636` UID rows
  - `5` high-confidence, `5` medium-confidence
  - all `full` assembly level, all `ENA/EMBL` source
  - catalog format: same 13-column schema as `genome_catalog_pending_candidate_high_medium_unique_assembly.csv`
- For download: use existing `download_ncbi_genome_fasta_catalog.py` with
  `--catalog rescue_genome_catalog_species_strain_match.csv`
- After download: map UIDs via `build_uid_to_selected_genome_from_manifest.py`
- One assembly (`GCA_000016125.1`) serves two Methanococcus maripaludis strains (C7, C6);
  strain_overlap is only `0.500` for both — review this pair if the assembly content
  does not match either strain-specific annotation
- Still unresolved: `351` source signatures
  - `316` genomic_embl_only → needs EMBL accession audit
  - `35` no signal → literature-level gap

### 2026-05-08 NCBI Assembly Full-Text Search Audit

- Added evidence-only audit script:
  - `/home/a/EnzymeCAGE/custom/data_build/audit_unresolved_ncbi_assembly_fulltext_search.py`
  - SHA256:
    `8f6bf7a5c750454357412441eae5a7950918a42c5c258307d26d73fbf9ce99f0`
- Final output:
  - `/home/a/EnzymeCAGE/data/processed/rhea/2026-01-21/microbe/ncbi_assembly_fulltext_search_2026-05-08/full_361_v3`
- Scope:
  - fixed unresolved source list: `361`
  - NCBI Assembly E-utilities full-text phrase search
  - no catalog mutation and no genome download
- Result:
  - full-text hit sources: `33`
  - zero-hit sources: `328`
  - candidate rows: `221`
  - best Complete Genome hits: `20`
  - best Chromosome hits: `3`
  - best hits with original source TaxID match: `0`
  - best hits confirming known UniProt species/strain rescue assemblies: `3`
  - best hits confirming prior low-confidence assemblies: `5`
- Confirmed GT-S mechanism:
  - `1111707` full-text query `Synechocystis sp. PCC 6803 GT-S`
    returns `GCF_000270265.1` / `GCA_000270265.1`
  - assembly is indexed under NCBI/KEGG species-level `1148`
- Database interpretation:
  - exact source TaxID zero-report is not sufficient evidence of no genome
  - full-text search can recover metadata-linked assemblies
  - however, it is not safe for automatic selection because hits are not
    original-source-TaxID matches

### 2026-05-08 Current Genome-Gap Rescue State

- Added:
  - `/home/a/EnzymeCAGE/custom/data_build/build_unresolved_genome_rescue_state.py`
  - SHA256:
    `4146d3b7c64ea953d7a76c930616c76ff10401bf42353f7b2dc67c257e8cce5a`
- New current-state output:
  - `/home/a/EnzymeCAGE/data/processed/rhea/2026-01-21/microbe/unresolved_genome_rescue_state_2026-05-08`
- This state converts the historical `361` gap list into:
  - accepted rescue ledger:
    `accepted_rescue_sources_from_unresolved_361.csv`
  - accepted unique genome catalog:
    `accepted_rescue_unique_genome_catalog.csv`
  - current remaining unresolved list:
    `unresolved_345_microbe_sources_remaining_after_rescue.csv`
  - remaining NCBI full-text manual-review queue:
    `ncbi_fulltext_hits_still_manual_review_after_rescue.csv`
- Accepted rescue totals:
  - source signatures: `16`
  - unique assemblies: `15`
  - UID rows: `893`
- Remaining unresolved totals:
  - source signatures: `345`
  - UID rows: `6,578`
- Accepted rescue group counts:
  - `uniprot_species_strain_rescue`: `10`
  - `ngdc_exact_taxid_non_contig`: `2`
  - `descendant_complete_or_chromosome`: `3`
  - `ncbi_fulltext_user_confirmed`: `1`
- Integrity checks:
  - source partition passed: `361 = 16 + 345`
  - UID partition passed: `7,471 = 893 + 6,578`
- From this point, database progress should cite the live unresolved count as
  `345`, not the old historical `361`, unless explicitly referring to the
  original audit snapshot.

### 2026-05-08 Candidate-Only Rescue Pool Before CNCB Review

- Candidate file retained for manual review:
  - `/home/a/EnzymeCAGE/data/processed/rhea/2026-01-21/microbe/unresolved_genome_rescue_state_2026-05-08/ncbi_fulltext_manual_confirmation_queue_25.csv`
  - SHA256:
    `e3b532678245a4e7e375ecb1917616fb278e10865b368822a76e6c3da0bd5b25`
- Status:
  - these `25` rows are not yet accepted
  - no database totals changed in this note
  - live unresolved remains `345` source signatures / `6,578` UID rows
- Relationship/quality review summary:
  - parent/higher-taxon candidate hits: `12`
  - child/lower-taxon candidate hits: `3`, all currently `Contig`
  - same-species different-TaxID candidate hits: `1`
  - different or unresolved relationship hits: `9`
- Working rule:
  - do not merge parent/higher-taxon hits unless they are explicitly accepted as
    species-level proxy genomes
  - do not merge child/lower-taxon hits while they are only contig-level
  - do not merge different/unresolved hits without external synonym,
    reclassification, or strain evidence
  - future accepted rows should be added through a new rescue-state build, not by
    editing the historical `361` table in place
- Next investigation path:
  - user will first query CNCB / National Center for Bioinformation resources
    outside this run
  - any CNCB/NGDC hits should be audited for assembly level, source TaxID,
    candidate TaxID, organism/strain relationship, and download path before they
    are added to the accepted rescue ledger

### 2026-05-08 Qwen NGDC/GWH Name-Search Evaluation

- Evaluated Qwen's GWH name-search output:
  - report:
    `/home/a/EnzymeCAGE/custom/docs/NGDC_GWH_NAME_RESCUE_FULL_REPORT.md`
  - result CSV:
    `/home/a/EnzymeCAGE/data/processed/rhea/2026-01-21/microbe/ngdc_gwh_name_rescue_2026-05-07/full_361/ngdc_gwh_name_rescue_results.csv`
- File audit:
  - report lines: `719`
  - result CSV lines including header: `362`
  - result CSV SHA256:
    `1316aa09461f2362fae6320301790bb57c7e73c1ab2f5e532b8eb7f6168c7588`
  - script SHA256:
    `155e7d12608b88ab766a701d9f23ff0f4fc41483c893f092b324aee5b7837375`
- Coverage finding:
  - the run queried only the GWH search endpoint
    `https://ngdc.cncb.ac.cn/gwh/gwhSearch/api`
  - it should not be described as complete coverage of CNCB nodes, NCBI,
    EBI/ENA, DDBJ, CNGB, NMDC, or all CNCB databases
  - it is an evidence pool from GWH search plus mirrored/integrated NCBI
    assembly records
- Recomputed result counts:
  - processed rows: `361`
  - `success`: `356`
  - `network_error`: `5`
  - returned-hit rows: `210`
  - zero-return rows: `151`
  - best `GCA_` rows: `203`
  - best `GWH` rows: `7`
  - best Complete Genome rows: `6`
  - duplicate query-name groups: `26`
  - rows in duplicate query-name groups: `129`
  - cache rows where `totalHits > returned data`: `76`
- Current live-state projection:
  - Qwen output overlaps all `361` historical rows:
    - `16` already accepted
    - `345` current live unresolved
  - among live `345` rows:
    - returned-hit rows: `196`
    - Complete/Chromosome best assembly strings: `4`
    - GWH-prefixed best IDs: `5`
- Decision:
  - Qwen's proposed `2 exact_high + 7 GWH` set is not accepted automatically
  - `3 / 9` proposed rows are already accepted in the current rescue state
  - the remaining live GWH-prefixed rows are generic low-quality
    scaffold/contig matches
  - the live `Prochlorococcus marinus subsp. pastoris` hit remains
    candidate-only because strain equivalence was not established
- Database totals remain unchanged:
  - accepted rescue:
    `16` source signatures / `15` unique assemblies / `893` UID rows
  - live unresolved:
    `345` source signatures / `6,578` UID rows
- Next safe action:
  - use Qwen's output only as a candidate/evidence pool
  - require paginated search, detail/downloadability checks,
    source-vs-candidate TaxID lineage checks, strain-token checks, assembly
    quality normalization, and manual evidence notes before adding any rows to a
    new rescue-state version

### 2026-05-09 CNCB/GWH Live-345 Rescue Audit

- New read-only audit script:
  - `/home/a/EnzymeCAGE/custom/data_build/audit_cncb_gwh_live345_rescue.py`
  - SHA256:
    `0d91dbe218929032ae9e3f60575587e9c0c3918773a82c6848684a825b609db6`
- Output directory:
  - `/home/a/EnzymeCAGE/data/processed/rhea/2026-01-21/microbe/cncb_gwh_live345_rescue_2026-05-09/full345_taxid_strain`
- Scope:
  - input is the current live `345` unresolved source list
  - not the historical `361` snapshot
  - target is GWH / Genome Warehouse, because CNCB nodes is a resource index
    rather than one complete cross-database genome rescue API
- Query policy:
  - `taxid_lineage`
  - `strain_phrase`
  - `strain_phrase_with_word`
  - no broad primary-name rescue acceptance
- Result:
  - processed source signatures: `345`
  - query rows: `807`
  - HTTP `200`: `805`
  - API errors: `2`
  - candidate assembly rows: `9`
  - candidate source signatures represented: `6`
  - rescueable/review rows under current rules: `0`
  - `cncb_gwh_live345_rescueable_or_review_candidates.csv` is header-only
- Candidate-only rows:
  - `taxon:111519|organism:caldanaerobacter subterraneus subsp. yonseiensis (thermoanaerobacter yonseiensis)`
    - descendant, contig
  - `taxon:1208|organism:trichodesmium thiebautii`
    - descendant, contig
  - `taxon:45916|organism:nostoc ellipsosporum`
    - descendant, contig
  - `taxon:83541|organism:mastigocladus laminosus (fischerella sp.)`
    - descendant, scaffold candidates
  - `taxon:66693|organism:pseudomonas sp. (strain yl)`
    - strain token appears, but different/unclear TaxID and contig
  - `taxon:84635|organism:bacillus sp. (strain gl1)`
    - exact source TaxID and strain token, but contig
- Decision:
  - no new GWH/CNCB rescue is accepted from the live `345` list in this run
  - accepted rescue remains:
    `16` source signatures / `15` unique assemblies / `893` UID rows
  - live unresolved remains:
    `345` source signatures / `6,578` UID rows
- Output hashes:
  - `cncb_gwh_live345_candidate_hits.csv`:
    `2b991ce0eab4a605582e46349b9dfb3f0084be151fc531f1b61f7fa5ddf09241`
  - `cncb_gwh_live345_source_audit.csv`:
    `661fd99271e23e1bbdcfed90d63e92ddaed6831812efbf4af76bda0fa5759fca`
  - `cncb_gwh_live345_query_audit.csv`:
    `d791f39959dc06c968d9a9e22a6dd3eac44fb01a5e69dc59b88697b9381b85ff`
  - `cncb_gwh_live345_summary.json`:
    `9ece87790a44228ccbdb1229b875d562994f462f5d3520b5bb90dd2e2b882170`

### 2026-05-09 Genome Expansion Phase 0

- New expansion policy:
  - species-to-strain expansion is allowed
  - strain-to-species expansion is allowed as a marked species-level proxy
  - genus-level proxy is rejected
  - Complete Genome and Chromosome are accepted quality levels
  - Scaffold and Contig are rejected
  - manually reviewed / curated RefSeq `GCF_*` is preferred over paired or
    same-quality GenBank `GCA_*`
- Plan file updated:
  - `/home/a/EnzymeCAGE/custom/docs/GENOME_EXPANSION_PLAN_2026-05-09.md`
  - SHA256:
    `a4a69455d76903cfdc0d592d8c2d3f9116949e57544322ddc0e6171a064a133b`
- Added script:
  - `/home/a/EnzymeCAGE/custom/data_build/build_genome_expansion_phase0.py`
  - SHA256:
    `ebf5e46ed97f5d44665504b5cf139234a66665e30ec1f76b0e7181903a3fccf2`
- Output directory:
  - `/home/a/EnzymeCAGE/data/processed/rhea/2026-01-21/microbe/genome_expansion_2026-05-09/phase0_prep`
- Phase 0 outputs:
  - `phase0_taxonomy_relation.csv`
  - `phase0_existing_genome_blacklist.csv`
  - `phase0_summary.json`
- Phase 0 counts:
  - processed live unresolved sources: `345`
  - represented UID rows: `6,578`
  - taxonomy groups:
    - `target_archaea`: `12`
    - `target_bacteria`: `271`
    - `target_fungi`: `62`
  - expansion buckets:
    - `species_to_strain_search`: `286`
    - `strain_to_species_search`: `59`
  - all live unresolved sources are expansion-ready under the species/strain
    policy
- Existing genome blacklist:
  - clean direct catalog rows: `1,355`
  - clean pending high/medium unique catalog rows: `1,516`
  - clean direct + pending unique exact assemblies: `2,869`
  - accepted rescue unique catalog rows: `15`
  - unique exact blacklist assemblies: `2,877`
  - overlap explains why this is not `2,869 + 15`
- Output hashes:
  - `phase0_taxonomy_relation.csv`:
    `c7fec579a5ae18f7ee2aafae7d6bc3ff0a0d552d047239eec83b358bd74cd271`
  - `phase0_existing_genome_blacklist.csv`:
    `7b519875ee0a817a2e189876db7a3ee4bffd96e067f71b8582ef495f32b46e14`
  - `phase0_summary.json`:
    `d2bad647bc387e9bdbf100bee34b29b822100d3a80945f74bfe7d2c3bc3fcbb2`
- Current boundary:
  - Phase 0 is complete
  - no Phase 1 NCBI expansion query has been run yet
  - no download catalog has been created yet

## 23. 2026-05-09 Genome Expansion Phase 1 NCBI

- Added and ran:
  - `/home/a/EnzymeCAGE/custom/data_build/build_genome_expansion_phase1_ncbi.py`
- Script SHA256:
  - `0c6f85920fa87e01d6a783f2f7078eb53e547f8e8948cbc2bafa6b2c1a3f43a8`
- Validation:
  - `python3 -m py_compile custom/data_build/build_genome_expansion_phase1_ncbi.py`
  - exit code: `0`
- Full output directory:
  - `/home/a/EnzymeCAGE/data/processed/rhea/2026-01-21/microbe/genome_expansion_2026-05-09/phase1_ncbi`
- Report:
  - `/home/a/EnzymeCAGE/custom/docs/GENOME_EXPANSION_PHASE1_NCBI_REPORT_2026-05-09.md`
- Inputs:
  - Phase 0 relation table:
    `/home/a/EnzymeCAGE/data/processed/rhea/2026-01-21/microbe/genome_expansion_2026-05-09/phase0_prep/phase0_taxonomy_relation.csv`
  - Phase 0 blacklist:
    `/home/a/EnzymeCAGE/data/processed/rhea/2026-01-21/microbe/genome_expansion_2026-05-09/phase0_prep/phase0_existing_genome_blacklist.csv`
- Query:
  - NCBI Datasets REST genome/taxon dataset_report
  - requested assembly levels:
    `complete_genome,chromosome`
  - local quality filter still enforced:
    Complete Genome / Chromosome accepted, Scaffold / Contig rejected
  - curated/manual RefSeq `GCF_*` preferred over paired or same-quality
    GenBank `GCA_*`
- Full-run counts:
  - processed source signatures: `345`
  - represented UID rows: `6,578`
  - NCBI search jobs: `404`
  - query audit rows: `404`
  - HTTP `200`: `404`
  - API errors: `0`
  - candidate rows inspected: `7,738`
  - accepted source signatures: `48`
  - accepted UID rows covered: `3,796`
  - unique accepted assemblies: `34`
  - rejected candidate rows: `7,690`
- Accepted candidates:
  - all `48` final accepted candidates are `Complete Genome`
  - no final accepted candidate is Chromosome-level in this NCBI phase
  - selected accession prefixes:
    - `GCF_`: `47`
    - `GCA_`: `1`
  - source databases:
    - `SOURCE_DATABASE_REFSEQ`: `47`
    - `SOURCE_DATABASE_GENBANK`: `1`
- Accepted by relation/expansion class:
  - strict `strain_to_species_complete`:
    `38` source signatures / `2,665` UID rows / `26` unique assemblies
  - same-parent-species `strain_to_species_descendant_proxy_complete`:
    `10` source signatures / `1,131` UID rows / `8` unique assemblies
  - `species_to_strain_complete`:
    `0`
- Species-to-strain finding:
  - `286` source signatures were searched
  - no acceptable Complete/Chromosome descendant strain was found in NCBI
  - the only species candidates returned were:
    - `Trichodesmium thiebautii`: contig
    - `Nostoc ellipsosporum`: contig
    - `Mastigocladus laminosus`: scaffold
- Candidate rejection counts:
  - `reject_quality`: `4,041`
  - `reject_lower_ranked_accepted_candidate`: `3,417`
  - `reject_duplicate_existing_genome`: `232`
- Output SHA256:
  - `phase1_ncbi_accepted_candidates.csv`:
    `8c9cf566ab114dc21145153f62b156c9d41216d2a12b35f826c9d224743b74cb`
  - `phase1_ncbi_candidate_hits.csv`:
    `e9040e39f77c6e6bf629d7db00f72edbc8755c41cccae9e3dd0cfcb1bd103ab7`
  - `phase1_ncbi_rejected_candidates.csv`:
    `32eac4c9e4008903ecab9bd05a7351e233072a9e574ffa20a895fd25ea8396ec`
  - `phase1_ncbi_query_audit.csv`:
    `f20751a19e60f08a27436719ab4df474d2b448d22c4ee0ee883168eb7b55326a`
  - `phase1_ncbi_source_audit.csv`:
    `bb56651c5f27ff621c02b7091c253f7482c7004840ed0151c10c044c20ef7443`
  - `phase1_ncbi_summary.json`:
    `53752d20aae1ed859654816056f5f358ac3c5e0ca0758a53280e706261aba72b`
- Current boundary:
  - Phase 1 NCBI expansion audit is complete
  - no genome download has been performed
  - next step is Phase 2 GWH/CNCB expansion audit under the same rules

## 24. 2026-05-09 Genome Expansion Phase 2 GWH/CNCB

- Added and ran:
  - `/home/a/EnzymeCAGE/custom/data_build/build_genome_expansion_phase2_gwh.py`
- Script SHA256:
  - `52be6049dd7cf55dd096db88d33d4d0700e14cab5c10943581f374e3d81118e1`
- Validation:
  - `python3 -m py_compile custom/data_build/build_genome_expansion_phase2_gwh.py`
  - exit code: `0`
  - 10-source smoke test passed
  - full 345-source run passed
  - invariant check passed
- Full output directory:
  - `/home/a/EnzymeCAGE/data/processed/rhea/2026-01-21/microbe/genome_expansion_2026-05-09/phase2_gwh`
- Report:
  - `/home/a/EnzymeCAGE/custom/docs/GENOME_EXPANSION_PHASE2_GWH_REPORT_2026-05-09.md`
- Inputs:
  - Phase 0 relation table:
    `/home/a/EnzymeCAGE/data/processed/rhea/2026-01-21/microbe/genome_expansion_2026-05-09/phase0_prep/phase0_taxonomy_relation.csv`
  - Phase 0 blacklist:
    `/home/a/EnzymeCAGE/data/processed/rhea/2026-01-21/microbe/genome_expansion_2026-05-09/phase0_prep/phase0_existing_genome_blacklist.csv`
  - Phase 1 accepted candidates:
    `/home/a/EnzymeCAGE/data/processed/rhea/2026-01-21/microbe/genome_expansion_2026-05-09/phase1_ncbi/phase1_ncbi_accepted_candidates.csv`
- Query:
  - CNCB/NGDC GWH Search API:
    `https://ngdc.cncb.ac.cn/gwh/gwhSearch/api`
  - TaxID term:
    `attrs.taxonomy_id:(TAXID) OR attrs.tax_lineage:(TAXID)`
  - assembly-level filters:
    - `Complete Genome`
    - `Chromosome`
  - local quality filter still enforced:
    Complete Genome / Chromosome accepted, Scaffold / Contig rejected
  - GWH `refseq_accession` used to prefer `GCF_*` over reported `GCA_*`
- Full-run counts:
  - processed source signatures: `345`
  - represented UID rows: `6,578`
  - GWH search jobs: `404`
  - query audit rows: `848`
  - HTTP `200`: `802`
  - cached query rows: `46`
  - API errors: `0`
  - query rows truncated after page limit: `2`
  - candidate rows inspected: `3,483`
  - accepted source signatures: `48`
  - accepted UID rows covered: `3,796`
  - unique accepted assemblies: `34`
  - rejected candidate rows: `3,435`
- Accepted candidates:
  - all `48` final accepted candidates are `Complete Genome`
  - no Chromosome-level candidate was selected
  - no GWH-native/direct submission was accepted
  - all accepted candidates are NCBI mirror entries in GWH
  - selected accession prefixes:
    - `GCF_`: `47`
    - `GCA_`: `1`
- Accepted by relation/expansion class:
  - strict `strain_to_species_complete`: `40`
  - same-parent-species `strain_to_species_descendant_proxy_complete`: `8`
  - `species_to_strain_complete`: `0`
- Relation to Phase 1:
  - Phase 2 accepted source set is identical to Phase 1 accepted source set
  - new source signatures beyond Phase 1: `0`
  - same-assembly confirmations: `43`
  - different assemblies for the same source signatures: `5`
  - the 5 different-assembly rows:
    - `Agrobacterium tumefaciens (strain T37)` -> `GCF_003667925.1`
    - `Agrobacterium tumefaciens (strain RS5)` -> `GCF_003667925.1`
    - `Xanthomonas campestris pv. cyanopsidis` -> `GCF_028749585.1`
    - `Staphylococcus aureus (strain JH1)` -> `GCF_022221525.1`
    - `Xanthomonas campestris pv. amaranthicola` -> `GCF_028749585.1`
  - CSV `cross_database_status = gwh_only_candidate` should be interpreted as
    different from Phase 1 selected assembly, not GWH-native/direct-only
- Species-to-strain finding:
  - `286` source signatures were searched
  - no acceptable Complete/Chromosome descendant strain was found in GWH
  - this matches Phase 1 NCBI
- Candidate rejection counts:
  - `reject_lower_ranked_accepted_candidate`: `3,196`
  - `reject_duplicate_existing_genome`: `239`
- Query truncation:
  - only `Staphylococcus aureus`, TaxID `1280`, was truncated:
    Complete Genome total `3,551`; Chromosome total `467`; first `5` pages
    fetched for each
  - existence-level rescue still valid because a Complete Genome species-level
    proxy was found
- Output SHA256:
  - `phase2_gwh_accepted_candidates.csv`:
    `8b46ee5bdf751336207490ee4cc292b4998fa0e36ef7d36428e8c2a907eb4e67`
  - `phase2_gwh_candidate_hits.csv`:
    `a63eda8c4221d475b7c08f8b7fb45d2e7ea9df42c7ff3072ad4eda8994943a57`
  - `phase2_gwh_rejected_candidates.csv`:
    `320728bf7ce1906b8b0420ea6c9c8ecf7f38eec0d96714b261024d4ba506c74d`
  - `phase2_gwh_query_audit.csv`:
    `f752981d9093fb28f75f574ca609038d896f63c9ee0894a6829c53c2207d6a4a`
  - `phase2_gwh_source_audit.csv`:
    `5e5e08ac83ac8f00fbf97983823050274d5bca4705077f8e14299aca263c0104`
  - `phase2_gwh_summary.json`:
    `d6f8e5e5c4a9398c33898c9379765882bb25acd8e478ec49b7cc0c1357035ac8`
- Current boundary:
  - Phase 2 GWH/CNCB expansion audit is complete
  - no genome download has been performed
  - next step is Phase 3 merge before creating any download catalog

### 2026-05-12 Genome Expansion Phase 3 Merge

- Phase 3 merge completed locally.
- Script:
  - `/home/a/EnzymeCAGE/custom/data_build/build_genome_expansion_phase3_merge.py`
  - SHA256:
    `d54c743aba594f025aaa93d6523791adedfdc99bcde6c2838c0b92851320e376`
- Output directory:
  - `/home/a/EnzymeCAGE/data/processed/rhea/2026-01-21/microbe/genome_expansion_2026-05-09/phase3_merge`
- Merged inputs:
  - Phase 1 NCBI accepted candidates: `48`
  - Phase 2 GWH accepted candidates: `48`
  - accepted rescue source signatures from 2026-05-08 state: `16`
  - accepted rescue unique assemblies: `15`
- Accepted rescue source ledger:
  - `/home/a/EnzymeCAGE/data/processed/rhea/2026-01-21/microbe/unresolved_genome_rescue_state_2026-05-08/accepted_rescue_sources_from_unresolved_361.csv`
- Accepted rescue unique genome catalog:
  - `/home/a/EnzymeCAGE/data/processed/rhea/2026-01-21/microbe/unresolved_genome_rescue_state_2026-05-08/accepted_rescue_unique_genome_catalog.csv`
- Phase 1/2 merge outcome:
  - same-assembly confirmations: `43`
  - different-assembly alternatives: `5`
  - Phase 1 only: `0`
  - Phase 2 only: `0`
- Final source-level merge:
  - source-level CSV:
    `/home/a/EnzymeCAGE/data/processed/rhea/2026-01-21/microbe/genome_expansion_2026-05-09/phase3_merge/phase3_final_source_signature_to_genome.csv`
  - lines including header: `65`
  - data rows: `64`
  - `phase3_expansion`: `48`
  - `accepted_rescue_2026-05-08`: `16`
  - final UID rows represented: `4,689`
- Final unique genome catalogs:
  - all unique genomes:
    `/home/a/EnzymeCAGE/data/processed/rhea/2026-01-21/microbe/genome_expansion_2026-05-09/phase3_merge/phase3_final_unique_genome_catalog.csv`
    - data rows: `49`
  - NCBI accession download catalog:
    `/home/a/EnzymeCAGE/data/processed/rhea/2026-01-21/microbe/genome_expansion_2026-05-09/phase3_merge/phase3_ncbi_accession_download_catalog.csv`
    - data rows: `47`
  - non-NCBI direct download catalog:
    `/home/a/EnzymeCAGE/data/processed/rhea/2026-01-21/microbe/genome_expansion_2026-05-09/phase3_merge/phase3_non_ncbi_direct_download_catalog.csv`
    - data rows: `2`
    - accessions:
      - `GWHAAYS00000000`
      - `GWHFGFS00000000.1`
- Blacklist audit:
  - overlap with Phase 0 blacklist: `15`
  - all overlaps are accepted rescue genomes
  - non-rescue blacklist overlaps: `0`
- Output SHA256:
  - `phase3_final_source_signature_to_genome.csv`:
    `5b66a34228afa124d75a2d4a743d013d4cf6f2013953c9abd48c137fc5c45380`
  - `phase3_final_unique_genome_catalog.csv`:
    `3542957506d8e18038f64286d127e82192854542edb847832dad7107b2c29e9a`
  - `phase3_ncbi_accession_download_catalog.csv`:
    `d431090b418fca6ede6923c7721e145d9a10a502165d0eb88638e8a1556ed312`
  - `phase3_non_ncbi_direct_download_catalog.csv`:
    `f21274570be6c81b33ec42e00709eddd74f266fd62b059d66fa77aab53c7142a`
  - `phase3_merge_summary.json`:
    `8b0a6103c1ace7dd3b261382acd69142437c9ac10fbb88f1fc9450af3da080ad`
- Current boundary:
  - Phase 3 merge is complete
  - no Phase 3 genome download has been run yet
  - next step is a transfer-package audit/prep for downloading the `47`
    NCBI-accession genomes and `2` GWH-direct genomes

### 2026-05-14 Phase 3 Genome Download Completion

- Cloud reuse audit completed before download:
  - NCBI accession catalog rows: `47`
  - GWH direct catalog rows: `2`
  - reusable NCBI rows from existing direct/pending manifests: `7`
  - NCBI rows still needing download: `40`
  - direct manifest checked:
    - `G:\EnzymeCAGE_cloud_handoff_2026-04-28\microbe\genome_download_direct_assembly_2026-04-28\genome_download_manifest.csv`
    - rows: `1,355`
    - downloaded_and_validated: `1,355`
  - pending high/medium manifest checked:
    - `G:\EnzymeCAGE_pending_genome_download_high_medium_2026-04-30\microbe\genome_download_pending_exact_taxid_high_medium_2026-04-30\genome_download_manifest.csv`
    - rows: `1,516`
    - downloaded_and_validated: `1,516`
- Cloud NCBI download output:
  - `G:\EnzymeCAGE_genome_expansion_phase3_download_2026-05-12\microbe\genome_download_phase3_ncbi_2026-05-12`
  - target row count: `40`
  - downloaded_and_validated: `40`
  - failed count: `0`
  - total zip bytes: `52,310,466`
  - total fna bytes: `181,959,466`
  - total FASTA bases: `179,705,619`
- Cloud GWH direct download output:
  - `G:\EnzymeCAGE_genome_expansion_phase3_download_2026-05-12\microbe\genome_download_phase3_gwh_direct_2026-05-12`
  - target row count: `2`
  - downloaded_and_validated: `2`
  - failed count: `0`
  - total compressed package bytes: `4,553,439`
  - total fna bytes: `15,643,794`
  - total FASTA bases: `15,483,281`
- Script note:
  - GWH direct downloader was fixed after a checkpoint-writing `KeyError`
  - fixed script SHA256:
    `cf2f8924ecf675f836743d2bf343b4506c90d97c9683426d7e3d1c9384f2b9bb`
- Current status:
  - Phase 3 genomes accounted for: `49 / 49`
  - composition:
    - existing reusable NCBI rows: `7`
    - new NCBI downloads: `40`
    - new GWH direct downloads: `2`
  - failed downloads: `0`
- Current boundary:
  - Phase 3 download is complete
  - next step is post-download audit and mapping/materialization

### 2026-05-19 Microbe Substrate Preference v1 Planning

- New active branch:
  - build microorganism substrate-metabolic-preference features from existing
    full CarveMe metabolic models and map them back to the RHEA main table.
- v1 scope:
  - use the `2,867` successful CarveMe models from the earlier `2,869` genome
    modeling batch
  - do not include Phase 3's extra `49` genomes
  - do not use NIS Core outputs for this v1
  - use full CarveMe models rather than NIS core-reaction subsets
- Reaction input policy:
  - use `rhea_rxn2uids.csv` column `SMILES` as the complete reaction input for
    the substrate-preference code
  - do not use `CANO_RXN_SMILES` as the complete reaction input
  - keep `CANO_RXN_SMILES` for traceability and later joining to existing
    reaction-feature assets
- Main-table facts reconfirmed:
  - rows: `320,043`
  - unique `UniprotID`: `195,743`
  - unique `RHEA_ID`: `18,533`
  - unique complete `SMILES`: `11,564`
  - unique cleaned `CANO_RXN_SMILES`: `11,418`
  - null `SMILES`: `0`
  - null `CANO_RXN_SMILES`: `0`
- Target taxonomy filtered facts:
  - rows: `227,056`
  - unique `UniprotID`: `168,335`
  - unique `RHEA_ID`: `8,870`
  - unique complete `SMILES`: `6,210`
  - unique cleaned `CANO_RXN_SMILES`: `6,122`
- Accepted genome-backed mapping audit:
  - direct selected sources: `1,355`
  - pending high/medium selected sources: `1,518`
  - Phase 3 accepted/rescue sources: `64`
  - total source signatures: `2,937`
  - unique assemblies: `2,911`
  - sources with more than one assembly: `0`
- Mapping the accepted genome-backed source set back to the RHEA main table:
  - rows covered: `223,267`
  - unique genome-backed `UniprotID`: `165,553`
  - unique source signatures: `2,937`
  - unique assemblies: `2,911`
  - unique complete `SMILES`: `6,076`
  - source-signature by complete-`SMILES` pairs: `183,763`
  - assembly by complete-`SMILES` pairs: `182,921`
- Planned v1 outputs:
  - `model_inventory_2867.csv`
  - `source_to_model_2867.csv`
  - `model_full_reaction_queries_2867.csv`
  - `model_substrate_preference_2867.csv`
  - `reaction_enzyme_microbe_substrate_preference_long.csv`
  - `reaction_enzyme_microbe_preference_features.csv`
- Current next step:
  - on HPC, locate/audit the `2,867` CarveMe XML models and generate
    `model_inventory_2867.csv`
  - required audit fields:
    - model XML path
    - parsed `assembly_accession`
    - regular file count
    - duplicate accession count
    - empty or malformed XML count
  - do not run full substrate-preference calculation before this inventory is
    checked

### 2026-05-19 HPC Model File Audit Result

- User reported the first HPC audit for existing full CarveMe models:
  - directory:
    `/public/home/acfbwjsi7s/EnzymeCAGE_unique_genomic_fna_2869_2026-05-07/genomic_fna/faa/`
  - XML file count: `2,867`
  - empty XML file count: `0`
  - duplicate XML filename count: `0`
  - example filename:
    `GCA_000001985.1_JCVI-PMFA1-2.0_genomic.xml`
- Step status:
  - initial model-file audit passed
  - v1 should continue with these `2,867` full CarveMe XML models
- Next action:
  - generate `model_inventory_2867.csv` on HPC
  - parse `assembly_accession` from filenames
  - include model path, filename, file size, and lightweight SBML/XML marker
    status
  - then return inventory summary for local mapping preparation

### 2026-05-19 Model Inventory Generated

- HPC outputs generated and reported by user:
  - `/public/home/acfbwjsi7s/model_inventory_2867.csv`
  - `/public/home/acfbwjsi7s/model_inventory_2867_summary.txt`
- Inventory audit:
  - CSV size: `586K`
  - lines including header: `2,868`
  - model rows: `2,867`
  - `xml_count`: `2,867`
  - `unique_assembly_accession`: `2,867`
  - `missing_assembly_accession`: `0`
  - `duplicate_assembly_accession`: `0`
  - `empty_files`: `0`
  - `sbml_marker_missing_or_error`: `0`
- Step status:
  - `model_inventory_2867.csv` passed audit
- Current next action:
  - transfer the model inventory files from HPC to local
  - build `source_to_model_2867.csv`
  - after that, build `model_full_reaction_queries_2867.csv`
  - substrate-preference code should still not be run before these mapping
    tables are audited

### 2026-05-19 Model Inventory Local Transfer Verified

- Local files:
  - `/home/a/EnzymeCAGE/data/processed/rhea/2026-01-21/microbe/model_inventory_2867.csv`
  - `/home/a/EnzymeCAGE/data/processed/rhea/2026-01-21/microbe/model_inventory_2867_summary.txt`
- User-reported local transfer audit:
  - CSV size: `586K`
  - summary size: `307`
  - CSV line count: `2,868`
  - model rows: `2,867`
  - `xml_count`: `2,867`
  - `unique_assembly_accession`: `2,867`
  - `missing_assembly_accession`: `0`
  - `duplicate_assembly_accession`: `0`
  - `empty_files`: `0`
  - `sbml_marker_missing_or_error`: `0`
- Current next action:
  - build and audit `source_to_model_2867.csv`

### 2026-05-19 source_to_model_2867 Built

- New script:
  - `/home/a/EnzymeCAGE/custom/data_build/build_source_to_model_2867.py`
- Outputs:
  - `/home/a/EnzymeCAGE/data/processed/rhea/2026-01-21/microbe/source_to_model_2867.csv`
  - `/home/a/EnzymeCAGE/data/processed/rhea/2026-01-21/microbe/source_to_model_2867_summary.json`
  - `/home/a/EnzymeCAGE/data/processed/rhea/2026-01-21/microbe/source_to_model_2867_missing_model.csv`
  - `/home/a/EnzymeCAGE/data/processed/rhea/2026-01-21/microbe/model_inventory_2867_without_source_mapping.csv`
- v1 source policy:
  - include direct selected genome sources
  - include pending high/medium selected genome sources
  - exclude Phase 3 genomes
- Audit:
  - model inventory rows: `2,867`
  - selected sources before dedup: `2,873`
  - duplicate source-signature rows: `0`
  - source-to-model rows: `2,871`
  - unique source signatures with model: `2,871`
  - unique assemblies with model: `2,867`
  - selected sources without model: `2`
  - inventory models without source mapping: `0`
- Missing source rows:
  - `proteome:UP000000781` / `GCA_000017525.1`
  - `proteome:UP000002216` / `GCA_000023225.1`
- Interpretation:
  - Step 2 passed
  - the missing rows explain the known `2` CarveMe failures from the original
    `2,869` genome batch
- Next action:
  - build `model_full_reaction_queries_2867.csv`
  - use full original `SMILES` as the reaction input
  - keep `CANO_RXN_SMILES` only for traceability

### 2026-05-19 model_full_reaction_queries_2867 Built

- Script:
  - `/home/a/EnzymeCAGE/custom/data_build/build_model_full_reaction_queries_2867.py`
- Outputs:
  - `/home/a/EnzymeCAGE/data/processed/rhea/2026-01-21/microbe/model_full_reaction_queries_2867.csv`
  - `/home/a/EnzymeCAGE/data/processed/rhea/2026-01-21/microbe/model_full_reaction_queries_2867_detail.csv`
  - `/home/a/EnzymeCAGE/data/processed/rhea/2026-01-21/microbe/model_full_reaction_queries_2867_per_model_summary.csv`
  - `/home/a/EnzymeCAGE/data/processed/rhea/2026-01-21/microbe/model_full_reaction_queries_2867_summary.json`
- Audit:
  - query rows (`assembly_accession x SMILES`): `178,493`
  - detail rows: `217,101`
  - unique assemblies: `2,867`
  - unique source signatures: `2,871`
  - unique UniProt IDs: `160,851`
  - unique RHEA IDs: `8,624`
  - unique full `SMILES`: `6,055`
  - unique cleaned `CANO_RXN_SMILES`: `5,968`
  - duplicate query keys: `0`
  - assemblies without reactions: `0`
  - query rows with zero left-side substrate count: `0`
- File sizes:
  - query CSV: `144M`
  - detail CSV: `202M`
  - per-model summary: `553K`
  - summary JSON: `1.8K`
- SHA256:
  - script:
    `5816eaea5998471af1e7fac6de568358d3c50ef41ea752b4ba8839fd414106bf`
  - query CSV:
    `84cdec144d9a590fe0a67a6790ba3602190d09731fd98ee18f93ab98223dc193`
  - summary JSON:
    `1bca7ae4fe0638491cfe268b7595c9c625eb60739cb03d2c38bdad7008c59d76`
- Step status:
  - Step 3 passed
- Next action:
  - transfer query/mapping files to HPC
  - adapt existing substrate-preference code to use full `SMILES`
  - smoke test before full run

### 2026-05-19 BiGG Coverage Audit For 2867 Query Universe

- Audit used:
  - `/home/a/EnzymeCAGE/data/processed/rhea/2026-01-21/microbe/model_full_reaction_queries_2867.csv`
- Output directory:
  - `/home/a/EnzymeCAGE/data/processed/rhea/2026-01-21/microbe/bigg_coverage_audit_2867/`
- Files:
  - `substrate_to_bigg_mapping_audit_2867.csv`
  - `query_row_bigg_coverage_audit_2867.csv`
  - `assembly_bigg_coverage_audit_2867.csv`
  - `bigg_coverage_summary_2867.json`
  - `chebi_to_bigg_cache.json`
- Reported cache/audit:
  - BiGG metabolites queried: `9,088`
  - API errors: `0`
- Substrate-level:
  - unique substrates: `3,706`
  - with ChEBI: `1,831`
  - with BiGG: `531`
  - BiGG coverage: `14.33%`
- Query-row-level:
  - total query rows: `178,493`
  - all substrates have BiGG: `17,980` (`10.07%`)
  - partial substrates have BiGG: `86,050` (`48.21%`)
  - no substrate has BiGG: `74,463` (`41.72%`)
- Assembly-level:
  - assemblies: `2,867`
  - assemblies with at least one BiGG-mapped substrate: `2,360` (`82.32%`)
  - assemblies with zero BiGG-mapped substrate: `507` (`17.68%`)
- Interpretation:
  - BiGG-only mapping has low substrate-level coverage
  - this result is an external database coverage audit, not final model
    usability
  - next step is to inspect CarveMe XML metabolites and annotations to find
    actual model IDs and possible ModelSEED/ChEBI/BiGG mapping routes

### 2026-05-19 Canonicalized BiGG Coverage Re-Audit

- Reason:
  - prior raw-exact audit reported low ChEBI/BiGG coverage
  - user suspected raw substrate SMILES did not string-match RHEA ChEBI-SMILES
- Cleaning-code finding:
  - original RHEA cleaning has standardization/canonicalization functions
  - `CANO_RXN_SMILES` also removes/modifies molecules and is not appropriate as
    the full reaction input for preference calculation
  - for mapping audit, single-substrate RDKit canonical matching is appropriate
- Script:
  - `/home/a/EnzymeCAGE/custom/data_build/build_bigg_coverage_audit_2867_canonical.py`
- Outputs:
  - `/home/a/EnzymeCAGE/data/processed/rhea/2026-01-21/microbe/bigg_coverage_audit_2867_canonical/substrate_to_bigg_mapping_audit_2867_canonical.csv`
  - `/home/a/EnzymeCAGE/data/processed/rhea/2026-01-21/microbe/bigg_coverage_audit_2867_canonical/query_row_bigg_coverage_audit_2867_canonical.csv`
  - `/home/a/EnzymeCAGE/data/processed/rhea/2026-01-21/microbe/bigg_coverage_audit_2867_canonical/assembly_bigg_coverage_audit_2867_canonical.csv`
  - `/home/a/EnzymeCAGE/data/processed/rhea/2026-01-21/microbe/bigg_coverage_audit_2867_canonical/bigg_coverage_summary_2867_canonical.json`
- Audit:
  - unique substrates: `3,706`
  - raw-exact substrates with ChEBI: `1,831`
  - raw-exact substrates with BiGG: `531`
  - canonical substrates with ChEBI: `3,705`
  - canonical substrates with BiGG: `1,020`
  - canonical substrate BiGG coverage: `27.52%`
  - rescued by canonical ChEBI matching: `1,874`
  - rescued by canonical BiGG matching: `489`
  - query rows all substrates have ChEBI: `178,488`
  - query rows partial ChEBI: `5`
  - query rows no ChEBI: `0`
  - query rows all substrates have BiGG: `103,955`
  - query rows partial BiGG: `62,748`
  - query rows no BiGG: `11,790`
  - assemblies with at least one BiGG substrate: `2,811`
  - assemblies with zero BiGG substrate: `56`
  - RHEA equation parsed IDs: `8,624 / 8,624`
  - RHEA left-side unique ChEBI: `3,732`
  - RHEA left-side ChEBI with BiGG: `1,020`
- File sizes:
  - substrate audit CSV: `2.0M`
  - query-row audit CSV: `52M`
  - assembly audit CSV: `123K`
  - summary JSON: `2.2K`
- SHA256:
  - script:
    `2ee5ee58077b825534346ff08a7ca4b5ccb3986093b8a430086e8e9cda1deb4d`
  - summary JSON:
    `f25085d85e0b1fc3978d07f75c8aad1d8a7e48e9a1aa10a001c569d8ee943470`
  - substrate audit CSV:
    `54094594d3eec249e28d34ae9a2596d265f6696002eeab90633ed632e8b2e06e`
- Interpretation:
  - raw-exact matching substantially underestimated mapping coverage
  - canonical substrate-to-ChEBI matching should be used for future mapping
    audits
  - BiGG coverage is much higher than first reported, but still incomplete
  - next step remains actual CarveMe XML metabolite/annotation audit

### 2026-05-20 Full-Reaction All-Molecule BiGG Coverage Audit

- Output directory:
  - `/home/a/EnzymeCAGE/data/processed/rhea/2026-01-21/microbe/bigg_coverage_audit_2867_all_molecules/`
- Files:
  - `molecule_to_bigg_mapping_audit_2867_all_molecules.csv`
  - `reaction_row_bigg_coverage_audit_2867_all_molecules.csv`
  - `assembly_reaction_bigg_coverage_audit_2867_all_molecules.csv`
  - `bigg_coverage_summary_2867_all_molecules.json`
- Input:
  - `/home/a/EnzymeCAGE/data/processed/rhea/2026-01-21/microbe/model_full_reaction_queries_2867.csv`
  - column: `SMILES`
  - canonicalization:
    `rdkit_canonical (MolFromSmiles + MolToSmiles, isomeric=True)`
- Metrics:
  - query rows total: `178,493`
  - assemblies total: `2,867`
  - unique reactions total: `6,055`
  - unique molecules total: `5,608`
  - unique reactant molecules: `3,702`
  - unique product molecules: `4,145`
  - unique molecules with ChEBI: `5,607`
  - unique molecules with BiGG: `1,213`
  - molecule BiGG coverage: `21.63%`
  - reaction rows full BiGG: `93,171` (`52.20%`)
  - reaction rows partial BiGG: `82,104` (`46.00%`)
  - reaction rows no BiGG: `3,218` (`1.80%`)
  - reaction rows all reactants have BiGG: `103,955` (`58.24%`)
  - reaction rows all products have BiGG: `103,088` (`57.76%`)
  - assemblies with at least one full-BiGG reaction: `2,076` (`72.41%`)
  - assemblies with zero full-BiGG reaction: `791` (`27.59%`)
  - raw-exact ChEBI molecules: `2,731`
  - canonical ChEBI molecules: `2,876`
  - unmatched ChEBI molecules: `1`
  - rescued by canonical ChEBI matching: `2,876`
  - rescued by canonical BiGG matching: `584`
- File audit:
  - molecule audit CSV: `2.6M`, `5,609` lines including header
  - reaction-row audit CSV: `93M`, `178,494` lines including header
  - assembly audit CSV: `130K`, `2,868` lines including header
  - summary JSON: `1.3K`
- SHA256:
  - summary JSON:
    `728ae6528d9eead76049967cd7982646bc2dee89ca4d734bb19b66f774ceaf7f`
  - molecule audit CSV:
    `f7900f176abaf380a194607a3987cfff24d95da4d19ba9da75d0fa26e430e37f`
- Interpretation:
  - this all-molecule audit is the correct BiGG-only coverage estimate for
    inserting complete RHEA reactions into CarveMe models
  - BiGG-only can fully encode about half of query rows
  - incomplete rows require additional mapping routes before full reaction
    insertion can be generalized
- Next action:
  - inspect actual CarveMe XML model metabolite IDs and annotations on HPC
  - determine whether BiGG, ModelSEED, ChEBI, KEGG, or MetaNetX can serve as
    the model-compatible mapping layer

### 2026-05-20 Integrated Final Plan For Substrate Preference

- New final plan:
  - `/home/a/EnzymeCAGE/custom/docs/SUBSTRATE_PREFERENCE_FINAL_PLAN_2026-05-20.md`
- Reason for update:
  - the original `PLAN5.19.md` assumed direct full-reaction conversion
  - the later all-molecule audit showed BiGG-only full reaction coverage is
    partial
  - the senior-student strategy is to use short names / placeholders for
    molecules without BiGG IDs and focus preference analysis on molecules with
    BiGG IDs
- Additional derived coverage:
  - candidate rows with at least one BiGG molecule:
    `175,275 / 178,493` = `98.20%`
  - candidate assemblies:
    `2,843 / 2,867` = `99.16%`
  - zero-candidate assemblies:
    `24 / 2,867` = `0.84%`
- Planned new data products:
  - `rhea_molecule_bigg_placeholder_mapping_2867.csv`
  - `model_reaction_stoich_queries_2867.csv`
- Planned code path:
  - use `/home/a/EnzymeCAGE/5.19/analyze_pae_nis_v2.py` as a template
  - create a new RHEA-specific script
  - replace hard-coded PAE reactions with dynamic reaction stoichiometry
  - output per-model, per-reaction, per-BiGG-molecule preference results
- Current boundary:
  - do not run preference calculation yet
  - generate and audit the two new mapping/stoichiometry tables first

### 2026-05-20 RHEA Stoichiometry Smoke Test Reviewed

- User provided a smoke-test result from a local AI script that generated
  `4` example RHEA stoichiometry dictionaries.
- Reported nitrile example:
  - RHEA equation:
    `CHEBI:18379 + 2 CHEBI:15377 = CHEBI:29067 + CHEBI:28938`
  - generated stoich:
    `{"rhea_mol_b219689f21_c": -1.0, "h2o_c": -2.0, "Rtotal_c": 1.0, "nh3_c": 1.0}`
- Local validation:
  - `CHEBI:28938` / `[NH4+]` has ambiguous BiGG candidates `nh3|nh4`
  - `CHEBI:29067` / `[1*]C(=O)[O-]` has generic BiGG candidates
    `Rtotal|Rtotal2|Rtotal3`
  - sample CarveMe XML contains both `M_nh3_c` and `M_nh4_c`, but RHEA
    ammonium should map to `nh4_c`
- Verdict:
  - equation parsing and coefficient parsing are promising
  - BiGG candidate selection is not accepted yet
  - full generation must not run until selection rules are fixed
- Required fixes:
  - no simple lexical first-choice for ambiguous BiGG IDs
  - force `CHEBI:28938` / `[NH4+]` to `nh4_c`
  - treat wildcard/generic molecules with only `Rtotal*` BiGG candidates as
    placeholders
  - preserve ambiguous candidates in output audit fields
  - add a reason field for chosen model metabolite ID
- Expected corrected nitrile output:
  - nitrile placeholder: `-1.0`
  - `h2o_c`: `-2.0`
  - carboxylate placeholder: `+1.0`
  - `nh4_c`: `+1.0`

### 2026-05-20 Active Plan Execution Order

- Active plan document:
  - `/home/a/EnzymeCAGE/custom/docs/SUBSTRATE_PREFERENCE_FINAL_PLAN_2026-05-20.md`
- Next execution sequence:
  1. Fix RHEA stoichiometry smoke script rules for ambiguous BiGG candidates.
  2. Re-run smoke only; no full output tables yet.
  3. Once smoke passes, generate:
     - `rhea_molecule_bigg_placeholder_mapping_2867.csv`
     - `model_reaction_stoich_queries_2867.csv`
  4. Audit generated tables for:
     - candidate rows
     - candidate assemblies/models
     - no-BiGG skipped rows
     - placeholder ID uniqueness
     - ambiguous BiGG IDs
     - selection-reason fields
  5. Generate on HPC and transfer:
     - `core_npz_inventory_2867.csv`
     - `core_npz_inventory_2867_summary.json`
  6. After both table audit and core inventory pass, create the RHEA-specific
     analysis script from `/home/a/EnzymeCAGE/5.19/analyze_pae_nis_v2.py`.
  7. Run analysis smoke tests only; full substrate-preference run remains
     blocked until smoke passes.
- Current hard stops:
  - do not run full stoichiometry table generation yet
  - do not run substrate-preference calculation yet
  - do not accept `Rtotal`, `Rtotal2`, or `Rtotal3` as concrete metabolites
  - do not map ammonium `CHEBI:28938` to `nh3_c`

### 2026-05-20 RHEA Stoichiometry Tables Finalized

- Final local outputs:
  - `/home/a/EnzymeCAGE/data/processed/rhea/2026-01-21/microbe/model_reaction_stoich_queries_2867.csv`
  - `/home/a/EnzymeCAGE/data/processed/rhea/2026-01-21/microbe/rhea_molecule_bigg_placeholder_mapping_2867.csv`
  - `/home/a/EnzymeCAGE/data/processed/rhea/2026-01-21/microbe/model_reaction_stoich_queries_2867_summary.json`
- File audit:
  - stoich CSV: `178,494` lines including header, `178,493` data rows
  - molecule mapping CSV: `5,627` lines including header, `5,626` data rows
  - summary JSON: `996` bytes
- Summary after fixes:
  - total query rows: `178,493`
  - candidate rows: `175,242`
  - no-BiGG skip rows: `3,251`
  - parse failures: `0`
  - total assemblies: `2,867`
  - candidate assemblies: `2,843`
  - true zero-candidate assemblies: `24`
  - assemblies with any no-BiGG skip: `957`
  - unique BiGG metabolites: `1,154`
  - unique placeholder metabolites in reactions: `4,445`
  - unique placeholder IDs in mapping: `4,450`
  - placeholder IDs missing from mapping: `0`
  - placeholder IDs unused in reactions: `5`
- Independent validation:
  - all `stoich_json` values parsed successfully
  - all reaction placeholder IDs are present in the mapping table
  - no duplicate placeholder IDs in mapping
- Interpretation:
  - RHEA equation parsing and BiGG/placeholder stoichiometry generation are
    now accepted for downstream smoke testing
  - the next analysis-code step still depends on the corrected core NPZ
    inventory, not the older inventory with `UNKNOWN` assemblies

### 2026-05-20 Corrected Core NPZ Inventory Accepted

- Corrected inventory:
  - `/home/a/EnzymeCAGE/data/processed/rhea/2026-01-21/microbe/core_npz_inventory_2867_corrected.csv`
- Parse audit:
  - `/home/a/EnzymeCAGE/data/processed/rhea/2026-01-21/microbe/core_npz_inventory_2867_parse_audit.json`
- Bad/old inventory:
  - `/home/a/EnzymeCAGE/data/processed/rhea/2026-01-21/microbe/core_npz_inventory_2867.csv`
  - reason not usable: `1,251` rows have `assembly_accession=UNKNOWN`
- Corrected inventory validation:
  - rows: `2,867`
  - unique assemblies: `2,867`
  - UNKNOWN/blank assemblies: `0`
  - duplicate assemblies: `0`
  - `load_status=ok`: `2,867`
  - missing `OriginalGEM_*` fields: `0`
  - missing core fields: `0`
- Cross joins:
  - model inventory assemblies: `2,867`
  - stoich query assemblies: `2,867`
  - corrected core assemblies: `2,867`
  - missing core for model inventory: `0`
  - missing core for stoich query assemblies: `0`
- SHA256:
  - corrected CSV:
    `2306642d66da0356c89caf63b9218c350d3f5c5173e99ab9e7d05f93dbb9802d`
  - parse audit:
    `01bf8cf21b127f1476e25c0af97fcddfb354599114adb6dc8fd3509d584c6fc6`

### 2026-05-20 Analysis Script Review Finalized

- New RHEA-specific script:
  - `/home/a/EnzymeCAGE/custom/data_build/analyze_rhea_core_preference_2867.py`
- Old PAE script remains unchanged:
  - `/home/a/EnzymeCAGE/5.19/analyze_pae_nis_v2.py`
  - SHA256:
    `cf6e21326447fc7d7f885602b382c9cf9e0663d651275af9b2421341dbaf055a`
- New script behavior:
  - reads `model_reaction_stoich_queries_2867.csv`
  - reads `core_npz_inventory_2867_corrected.csv`
  - loads `*_nisCore.npz`
  - reconstructs `OriginalGEM_S_*`
  - uses `core_rxns` to select core reaction columns
  - retains all metabolite rows
  - inserts RHEA candidate reactions temporarily
  - computes BFS connectivity to `core_met_ids`
  - outputs per-model, per-reaction, per-BiGG-metabolite long rows
  - placeholders participate in connectivity but are not target outputs
- Compile:
  - passed
- Script SHA256 after audit fixes:
  - `c4139b7c30b8e5a2d6bea5c4b1c33310a31bfc3f17254148e42facc30aca7670`
- Audit fixes accepted:
  - `selected_no_bigg_skip_rows` is counted by selected assembly from the
    full stoichiometry table, even when `--include_no_bigg_skip` is disabled
  - `model_name` is read from `core_npz_inventory_2867_corrected.csv` and
    written to long-output rows
- Next database-dependent step:
  - transfer finalized script and accepted input CSVs to HPC
  - run smoke only before any full-scale preference calculation

### 2026-05-21 Placeholder Interpretation Boundary Added

- This is a downstream interpretation/database annotation issue, not a
  stoichiometry-generation failure.
- Current RHEA stoichiometry tables intentionally use placeholder metabolite
  IDs for molecules without reliable BiGG IDs:
  - example format: `rhea_mol_<hash>_c`
  - reverse lookup is kept in
    `rhea_molecule_bigg_placeholder_mapping_2867.csv`
- Consequence:
  - placeholder molecules can make the full reaction insertable into the
    temporary matrix
  - but they cannot by themselves prove that an unknown pollutant connects to
    the model core network
- Results must therefore distinguish:
  - direct support from a concrete pollutant/substrate BiGG ID
  - indirect support from a non-currency product BiGG ID
  - weak support from currency/common metabolites only
  - uninformative placeholder-only reactions
- Currency/common metabolites that should be flagged as low-information
  include:
  - `h2o_c`, `h_c`, `o2_c`, `co2_c`, `nh4_c`
  - `pi_c`, `ppi_c`
  - `atp_c`, `adp_c`, `amp_c`
  - `nad_c`, `nadh_c`, `nadp_c`, `nadph_c`
  - `coa_c`
- Required future derived labels:
  - `direct_pollutant_supported`
  - `product_assimilation_supported`
  - `currency_only_supported`
  - `placeholder_only_uninformative`

### 2026-05-21 Main Metabolite Coverage Full Run

- Script:
  - `/home/a/EnzymeCAGE/custom/data_build/build_main_reactant_product_coverage_2867.py`
- Output directory:
  - `/home/a/EnzymeCAGE/data/processed/rhea/2026-01-21/microbe/main_reactant_product_coverage_2867`
- Full-run input:
  - `model_reaction_stoich_queries_2867.csv`
  - `rhea_molecule_bigg_placeholder_mapping_2867.csv`
- Full-run output files:
  - `model_reaction_main_metabolite_coverage_2867.csv`
  - `main_metabolite_coverage_summary_2867.json`
  - `main_metabolite_examples_2867.csv`
- Final counts:
  - total rows: `178,493`
  - candidate rows: `175,242`
  - no-BiGG skip rows: `3,251`
  - parse failures: `0`
- Main interpretation classes:
  - direct main reactant BiGG available: `123,639`
  - main placeholder only: `29,162`
  - main product BiGG available: `15,022`
  - currency only: `7,419`
  - no BiGG skip: `3,251`
- Interpretation:
  - the coverage table now provides a usable prefilter for pollutant / main-product reasoning
  - placeholder-only rows are not evidence of core connectivity by themselves
  - currency-only rows should be treated as low-information, not as utilization evidence
- Operational note:
  - this coverage layer is now the preferred interpretation table before running
    or interpreting downstream core-preference outputs

### 2026-05-25 Restore Recheck

- Reconfirmed active database-dependent inputs for RHEA core-preference smoke:
  - `model_reaction_stoich_queries_2867.csv`: `178,494` lines including header
  - `rhea_molecule_bigg_placeholder_mapping_2867.csv`: `5,627` lines including header
  - `core_npz_inventory_2867_corrected.csv`: `2,868` lines including header
  - `model_reaction_main_metabolite_coverage_2867.csv`: `178,494` lines including header
- Reconfirmed script SHA256:
  - `custom/data_build/analyze_rhea_core_preference_2867.py`
  - `c4139b7c30b8e5a2d6bea5c4b1c33310a31bfc3f17254148e42facc30aca7670`
- Compile check with `.envs/rhea-clean` passed.
- Current boundary:
  - use corrected core NPZ inventory only
  - run HPC smoke only before any full-scale core-preference run

### 2026-05-25 RHEA Core-Preference Full HPC Outputs

- HPC working directory:
  - `/public/home/acfbwjsi7s/5.21`
- HPC output root:
  - `/public/home/acfbwjsi7s/5.21/rhea_core_preference_sharded_full_2026-05-25`
- Execution environment:
  - conda env: `sbml`
  - Python: `3.11.15`
  - NumPy: `2.4.3`
- Input files validated on HPC:
  - `analyze_rhea_core_preference_2867.py`
    - SHA256:
      `c4139b7c30b8e5a2d6bea5c4b1c33310a31bfc3f17254148e42facc30aca7670`
  - `model_reaction_stoich_queries_2867.csv`
    - lines: `178,494` including header
  - `core_npz_inventory_2867_corrected.csv`
    - lines: `2,868` including header
    - NPZ path audit on HPC: missing all `0`
  - `rhea_molecule_bigg_placeholder_mapping_2867.csv`
    - lines: `5,627` including header
  - `model_reaction_main_metabolite_coverage_2867.csv`
    - lines: `178,494` including header
    - size: `133M`
- Run mechanics:
  - smoke with default limits passed
  - full run split `2,843` candidate assemblies into 20 manifest shards
  - SLURM partition: `kshctest02`
  - all 20 shard failure CSVs are header-only
- Full-run aggregate:
  - summary files: `20`
  - selected assemblies: `2,843`
  - assemblies with NPZ: `2,843`
  - assemblies missing NPZ: `0`
  - selected candidate reaction rows: `175,242`
  - reactions processed: `175,242`
  - target rows written: `692,151`
  - failures: `0`
- Target-level status:
  - `in_core`: `485,894`
  - `reachable`: `185,815`
  - `not_reachable`: `20,442`
  - connectable target count: `671,709`
  - connectable target ratio: `0.9704659821339563`
  - not-connectable target ratio: `0.02953401786604368`
- Output files produced on HPC:
  - `rhea_core_preference_full_sharded_summary_2026-05-25.json`
  - `rhea_core_preference_model_level_summary_2026-05-25.csv`
  - `rhea_core_preference_reaction_level_summary_2026-05-25.csv`
  - `rhea_core_preference_reaction_level_with_main_coverage_2026-05-25.csv`
  - `rhea_core_preference_main_coverage_interpretation_summary_2026-05-25.json`
  - plus 20 shard directories with long CSV / summary JSON / failures CSV
- Model-level summary:
  - models: `2,843`
  - models with any connectable target: `2,787`
  - models with zero connectable target: `56`
  - models with any not-connectable target: `1,231`
  - models with zero not-connectable target: `1,612`
- Reaction-level summary:
  - model-reaction rows: `175,242`
  - rows with any connectable target: `166,675`
  - rows with zero connectable target: `8,567`
  - all targets connectable: `165,164`
  - partial connectable: `1,511`
  - no targets connectable: `8,567`
- Main metabolite interpretation join:
  - join key:
    - `assembly_accession`
    - `SMILES`
  - joined rows: `175,242`
  - missing coverage join: `0`
- Main interpretation summary:
  - `direct_main_reactant_bigg_available`
    - total: `123,639`
    - rows with any connectable target: `115,696`
    - rows with zero connectable target: `7,943`
    - any-connectable ratio: `0.9357565169566238`
  - `main_product_bigg_available`
    - total: `15,022`
    - rows with any connectable target: `14,501`
    - rows with zero connectable target: `521`
    - any-connectable ratio: `0.9653175342830516`
  - `main_placeholder_only`
    - total: `29,162`
    - rows with any connectable target: `29,059`
    - rows with zero connectable target: `103`
    - any-connectable ratio: `0.996468006309581`
  - `currency_only`
    - total: `7,419`
    - rows with any connectable target: `7,419`
    - rows with zero connectable target: `0`
    - any-connectable ratio: `1.0`
- Database interpretation rule:
  - use direct main-reactant BiGG support as the strongest v1 evidence
  - treat main-product BiGG support as indirect
  - do not claim placeholder-only rows prove pollutant/core connection
  - do not over-interpret currency-only rows
- Current transfer plan:
  - transfer lightweight derived outputs first
  - defer all 20 long shard CSVs unless needed for detailed debugging or
    downstream training-table construction

### 2026-05-26 Local RHEA Core-Preference Package Verification

- Local receive directory:
  - `/home/a/EnzymeCAGE/data/processed/rhea/2026-01-21/microbe/rhea_core_preference_2026-05-25`
- Received archive:
  - `5.21.zip`
  - size: `17,481,329` bytes
  - SHA256:
    `927233b5195e9668606372faa0868449391f2f8a35ebfa3a7ed86e83e0822078`
- Zip contents:
  - `rhea_core_preference_light_outputs_2026-05-26.tar.gz`
  - `rhea_core_preference_light_outputs_2026-05-26.tar.gz.sha256`
- Original tarball verification:
  - `sha256sum -c`: `OK`
  - expected SHA256:
    `16c8b6ddfcc2979b4ae874d926236ded9da8019eeba32caba86effe711132a08`
  - `gzip -t`: `OK`
- Extracted output directory:
  - `/home/a/EnzymeCAGE/data/processed/rhea/2026-01-21/microbe/rhea_core_preference_2026-05-25/rhea_core_preference_light_outputs_2026-05-26`
- Local extracted files:
  - `rhea_core_preference_full_sharded_summary_2026-05-25.json`
  - `rhea_core_preference_main_coverage_interpretation_summary_2026-05-25.json`
  - `rhea_core_preference_model_level_summary_2026-05-25.csv`
  - `rhea_core_preference_reaction_level_summary_2026-05-25.csv`
  - `rhea_core_preference_reaction_level_with_main_coverage_2026-05-25.csv`
- File sizes:
  - full summary JSON: `848` bytes
  - interpretation summary JSON: `1,383` bytes
  - model-level CSV: `140,743` bytes
  - reaction-level CSV: `107,680,046` bytes
  - reaction-level with main coverage CSV: `116,916,876` bytes
- Line counts:
  - model-level CSV: `2,844` lines including header
  - reaction-level CSV: `175,243` lines including header
  - reaction-level with main coverage CSV: `175,243` lines including header
- Local JSON spot-check:
  - selected assemblies: `2,843`
  - reactions processed: `175,242`
  - target rows written: `692,151`
  - failures: `0`
  - target-level connectable ratio:
    `0.9704659821339563`
- Status:
  - local lightweight results are verified and can be used for downstream
    reporting and interpretation.

### 2026-06-01 Single Example Package

- Created one GitHub-friendly single example package:
  - `/home/a/EnzymeCAGE/custom/github_upload/single_reaction_example_2026-06-01`
- Archive:
  - `/home/a/EnzymeCAGE/custom/github_upload/single_reaction_example_2026-06-01.tar.gz`
  - size: `340K`
  - SHA256:
    `5684fb7024d9a2656ed3a93a7c33570f6ebc452664e2ccd7645fcad79f07fe7f`
- Selected example:
  - `RHEA_ID=10164`
  - `UniprotID=Q7M0V7`
  - `assembly_accession=GCF_018885085.1`
  - `CANO_RXN_SMILES=O=C(O)[C@@H](CO)OP(=O)(O)O>>C=C(OP(=O)(O)O)C(=O)O.O`
- Local included data:
  - `tables/*.csv`
  - `features/reaction/reaction_features.npz`
  - `features/reaction/molecule_conformation/*.sdf`
  - `features/enzyme/gvp_pocket_feature.npz`
  - `features/enzyme/Q7M0V7_pocket.pdb`
  - `features/enzyme/Q7M0V7_esm_c_sequence_node.npz`
  - `features/enzyme/Q7M0V7_esm_c_sequence_mean.npy`
  - `features/enzyme/Q7M0V7_esm_c_pocket_node.npy`
  - `features/microbe/*.json`
- ESM-C verification:
  - sequence node: `node_feature (59, 1152)`
  - sequence mean: `(1152,)`
  - pocket-node: `(15, 1152)`
- Cloud export provenance is documented under:
  - `/home/a/EnzymeCAGE/custom/github_upload/single_reaction_example_2026-06-01/cloud_needed`

### 2026-06-01 300 Example Package

- Created package:
  - `/home/a/EnzymeCAGE/custom/github_upload/reaction_enzyme_microbe_300_examples_2026-06-01`
- Archive:
  - `/home/a/EnzymeCAGE/custom/github_upload/reaction_enzyme_microbe_300_examples_2026-06-01_FULL_WITH_ESMC.zip`
  - size: `436M`
  - SHA256:
    `52404c9bb4cc46d8881e2438b5aad53af1dbdca20b8febf7c613f1a4606b1f32`
- Verification:
  - examples: `300`
  - unique RHEA: `300`
  - unique UID: `260`
  - unique assembly: `159`
  - main CSV tables: all `300` rows
  - reaction DRFP matrix: `(300, 2048)`
  - reaction-center rows: `263 / 300` non-empty after fixing export key
  - GVP pocket feature files: `300`
  - pocket PDB files: `260`
  - molecule SDF files: `378`
  - local ESM-C rows included after merge: `300`
  - unique UID with ESM-C: `260`
  - cloud export failures: `0`
- ESM-C merge report:
  - `/home/a/EnzymeCAGE/custom/github_upload/reaction_enzyme_microbe_300_examples_2026-06-01/features/enzyme/esm_c_merge_report.json`
- Recommended cloud-side script:
  - `/home/a/EnzymeCAGE/custom/github_upload/reaction_enzyme_microbe_300_examples_2026-06-01/cloud_needed/export_and_pack_esmc_features_for_300_examples.py`

### 2026-06-01 Clean Full Training Package, Local Side Complete

The user clarified that the real deliverable is a full training feature asset,
not another GitHub/example dataset.

Superseded artifact:

- Deleted:
  `/home/a/EnzymeCAGE/custom/github_upload/reaction_enzyme_microbe_FULL_examples_2026-06-01`
- Deleted:
  `/home/a/EnzymeCAGE/custom/data_build/build_github_full_package.py`
- Reason:
  - broad taxonomy-filtered export, not strict training-complete data
  - included rows without non-empty reaction centers
  - used GVP symlinks
  - left pocket PDB as manifest-only
  - inflated ESM-C request count to `166,004` UID

Correct training package scripts:

- `/home/a/EnzymeCAGE/custom/data_build/build_training_clean_package.py`
- `/home/a/EnzymeCAGE/custom/data_build/assemble_training_local_package.py`

Correct training package artifacts:

- clean intermediate:
  `/home/a/EnzymeCAGE/custom/github_upload/reaction_enzyme_microbe_training_clean_2026-06-01`
  - size: `1.3G`
- final local package:
  `/home/a/EnzymeCAGE/custom/github_upload/reaction_enzyme_microbe_training_clean_2026-06-01_LOCAL`
  - size: `32G`
- final local tar without ESM-C:
  `/home/a/EnzymeCAGE/custom/github_upload/reaction_enzyme_microbe_training_clean_2026-06-01_LOCAL_WITH_GVP_NO_ESMC.tar`
  - size: `32G`
  - SHA256:
    `dfc0aa6cc6fe4a9d8a342c5c4bebcf477760b40a7a10e48f74fae1735bd9b45a`

Cleaning requirements:

- DRFP exists
- rxn2aam exists
- substrate and product reaction-center indices are both non-empty
- GVP UID exists in official sharded GVP manifest
- pocket record/PDB exists
- UID maps to microbe source
- source maps to selected model/assembly
- assembly + reaction exists in stoich query
- assembly + reaction exists in main metabolite coverage
- assembly + reaction exists in core-preference
- current `RHEA_ID` is present in core-preference `rhea_ids`

Cleaning audit:

- input taxonomy-filtered rows: `227,056`
- after GVP + pocket: `222,744`
- after complete reaction features and non-empty reaction centers: `153,297`
- after UID/source/model mapping: `146,469`
- after stoich + coverage + core-preference exists: `145,607`
- after RHEA/core-preference ID alignment: `145,607`

Final training data scale:

- training rows: `145,607`
- unique UID: `107,731`
- unique RHEA: `6,278`
- unique canonical reaction SMILES: `4,541`
- unique assembly: `2,475`
- strict direct-main/all-connectable subset:
  `103,310` rows

Retained core-preference classes:

- `main_reaction_interpretation_class`
  - `direct_main_reactant_bigg_available`: `108,717`
  - `main_placeholder_only`: `12,596`
  - `main_product_bigg_available`: `12,322`
  - `currency_only`: `11,972`
- `connectability_class`
  - `all_targets_connectable`: `137,565`
  - `no_targets_connectable`: `6,021`
  - `partial_connectable`: `2,021`

Local feature packaging:

- Reaction:
  - `features/reaction/reaction_features.npz`
  - DRFP matrix: `(145607, 2048)`, `float32`
  - all substrate/product reaction-center arrays non-empty
  - `reaction_feature_metadata.jsonl`
  - molecule SDF conformation files included
- Enzyme / GVP:
  - complete official sharded GVP pool copied into:
    `features/enzyme/gvp_pocket_features/`
  - copied files: `195`
  - shards: `192`
  - copied GVP bytes: `29,634,611,534`
  - `tmp/` not included
  - `enzyme_gvp_mapping.csv`: `107,731` rows, one row per training UID
  - `enzyme_feature_metadata.csv`: `145,607` rows, one row per training example
- Pocket:
  - materialized regular PDB files:
    `107,731 / 107,731`
  - failures: `0`
- Microbe:
  - all row-level tables have `145,607` rows and unique `example_id`
  - `features/microbe/microbe_features.jsonl`: `145,607` records
- ESM-C:
  - not included in the local package
  - request file:
    `/home/a/EnzymeCAGE/custom/github_upload/reaction_enzyme_microbe_training_clean_2026-06-01_LOCAL/cloud_needed/esmc_cloud_feature_requests.json`
  - requests: `107,731` unique UID

Verification:

- final local package contains no symlinks
- manifest covers `112,225` files and excludes self-reference
- tar archive includes:
  - `features/enzyme/gvp_pocket_features/enzyme_gvp_mapping.csv`
  - `features/enzyme/enzyme_feature_metadata.csv`
- `107,731 / 107,731` training UID are present in GVP manifest
- sampled GVP entries load through
  `enzymecage.dataset.sharded_protein.load_protein_gvp_data`
- a full cross-modal verification command was prepared for another AI to run;
  it checks reaction/enzyme/microbe one-to-one alignment, GVP readability,
  pocket PDB existence, ESM-C request hashes, manifest coverage, no symlinks,
  and tar SHA256.

Next:

- upload the local tar to cloud drive
- export ESM-C features on the cloud machine from `G:\esm\ESM-C_600M`
- upload/merge ESM-C package separately

### 2026-06-02 Microbe Target-Level Long Preference Add-on

- Created a separate add-on for the full target-level RHEA core-preference /
  substrate-preference results from the 2026-05-25 HPC run.
- This add-on does not replace the 32G main package. The main package remains
  valid and should be used together with this add-on.
- Add-on archive:
  `/home/a/EnzymeCAGE/custom/github_upload/reaction_enzyme_microbe_training_clean_2026-06-01_MICROBE_LONG_PREF_ADDON.tar.gz`
- SHA256:
  `8b534e1b9df0394e4b63b47d4d32921971c5c82b2e5ee4c8d6b97146edc6c5db`
- Extracted add-on directory:
  `/home/a/EnzymeCAGE/custom/github_upload/reaction_enzyme_microbe_training_clean_2026-06-01_MICROBE_LONG_PREF_ADDON`
- Verification:
  - long CSV shards: `20`
  - total target-level rows: `692,151`
  - failure CSV data rows: `0`
  - status counts:
    - `in_core`: `485,894`
    - `reachable`: `185,815`
    - `not_reachable`: `20,442`
  - min-path-length counts:
    - `0`: `485,894`
    - `1`: `185,815`
    - `-1`: `20,442`
  - clean main-package examples checked: `145,607`
  - missing long rows: `0`
  - target-count mismatches: `0`
- Main-package to add-on join key:
  `assembly_accession + CANO_RXN_SMILES + rhea_ids`.

### 2026-06-02 Cloud ESM-C Clean Training Export

- Cloud-side ESM-C export was reported complete for the clean training package.
- Cloud script/index source on local side:
  `/home/a/EnzymeCAGE/custom/github_upload/reaction_enzyme_microbe_training_clean_2026-06-01_LOCAL/cloud_needed/esmc_training_clean_cloud_scripts_and_indices.zip`
- Request/index facts:
  - unique UID: `107,731`
  - batches: `108`
  - last batch size: `731`
- Cloud output facts reported by user/cloud AI:
  - ZIP directory:
    `G:\esmc_training_clean_cloud_export\batch_esmc_export_training_clean_zips\`
  - ZIP files: `108`
  - total ZIP size: `164.13 GB`
  - bytes: `176,229,847,243`
  - successful UID: `107,731`
  - failed UID: `0`
- Verification:
  - expected UID: `107,731`
  - exported UID: `107,731`
  - missing UID: `0`
  - extra UID: `0`
  - status: passed on cloud
- Payload per UID:
  - sequence node: `<UID>_esm_c_sequence_node.npz`
  - sequence mean: `<UID>_esm_c_sequence_mean.npy`
  - pocket node: `<UID>_esm_c_pocket_node.npy`
- Cloud-side issue and fix:
  - batch `0` initially appeared as `0` exported UID in verification
  - reran batch `0`
  - verification then passed for all `107,731` UID
- Upload set:
  - `G:\esmc_training_clean_cloud_export\batch_esmc_export_training_clean_zips\`
  - `G:\esmc_training_clean_cloud_export\esmc_training_clean_zip_sha256.csv`
  - `G:\esmc_training_clean_cloud_export\esmc_training_clean_zip_dir.txt`
  - `G:\esmc_training_clean_cloud_export\batch_esmc_export_training_clean\esmc_training_clean_export_report.json`
  - `G:\esmc_training_clean_cloud_export\batch_esmc_export_training_clean\selected_batch_export_report.json`
- Do not upload expanded batch folders when uploading the ZIP directory.
- Local verification still required after transfer:
  - verify each ZIP against `esmc_training_clean_zip_sha256.csv`
  - confirm ZIP count `108`
  - confirm ESM-C UID coverage `107,731`

### 2026-06-02 Final Training Upload Grouping

The clean training upload is intentionally split:

1. Main local package, no ESM-C:
   `/home/a/EnzymeCAGE/custom/github_upload/reaction_enzyme_microbe_training_clean_2026-06-01_LOCAL_WITH_GVP_NO_ESMC.tar`
2. Microbe long-preference add-on:
   `/home/a/EnzymeCAGE/custom/github_upload/reaction_enzyme_microbe_training_clean_2026-06-01_MICROBE_LONG_PREF_ADDON.tar.gz`
3. Cloud ESM-C ZIP set:
   `G:\esmc_training_clean_cloud_export\batch_esmc_export_training_clean_zips\`

The 32G main package remains valid. Do not rebuild or re-upload it solely
because the microbe target-level long CSVs and ESM-C payloads are separate.

### 2026-06-03 Bio Vector Demo Training Status

Teacher demo reproduction has started using the uploaded/packaged 300-example
data format as the first validation step for unified vector-space training.

Demo code:

- `/home/a/EnzymeCAGE/demo/bio_vector-main/bio_vector-main/demo/train.py`
- `/home/a/EnzymeCAGE/demo/bio_vector-main/bio_vector-main/demo/diagnose_effective_rank.py`
- README:
  `/home/a/EnzymeCAGE/demo/bio_vector-main/bio_vector-main/demo/README.md`

Active data source for demo runs:

`/home/a/EnzymeCAGE/custom/github_upload/reaction_enzyme_microbe_300_examples_2026-06-01`

Verified data status:

- example rows: `300`
- all main CSV tables: `301` lines including header
- GVP files: `300`, missing from metadata `0`
- ESM-C UID files:
  - sequence node: `260`
  - sequence mean: `260`
  - pocket node: `260`
- ESM-C missing files across `300` example rows: `0`
- pocket PDB files: `260`
- use this local complete directory instead of the incomplete expanded teacher
  demo data directory.

Environment:

- Python:
  `/home/a/EnzymeCAGE/.envs/rhea-clean/bin/python`
- Verified dependencies:
  `numpy 1.26.4`, `torch 2.2.1+cu121`, `sklearn 1.7.2`,
  `matplotlib 3.10.8`, `faiss 1.14.2`, `rdkit 2022.09.5`
- `train.py --help` and `diagnose_effective_rank.py --help` both pass.

Runtime issue:

- The first CUDA GVP training attempt failed because RTX 5060 Laptop GPU is
  `sm_120`, but current PyTorch `2.2.1+cu121` supports CUDA architectures only
  up to `sm_90`.
- Do not upgrade `.envs/rhea-clean` PyTorch in place.

Next run boundary:

- Run README-defined GVP and ESM-C first-round demo on CPU with
  `CUDA_VISIBLE_DEVICES=""`.
- Output directories:
  - `output_v3_300_cpu_round1`
  - `output_v3_esmc_cpu_round1`
- Then inspect:
  - `metrics_v3.json`
  - `effective_rank_summary.json`
  - `training_history.json`
  - `unified_space_v3_results.png`
  - `effective_rank_diagnosis.png`
- Do not start full `145,607` training yet.

### 2026-06-03 Bio Vector Round 1 Completed

First-round CPU demo outputs are available:

- GVP:
  `/home/a/EnzymeCAGE/demo/bio_vector-main/bio_vector-main/demo/output_v3_300_cpu_round1`
- ESM-C:
  `/home/a/EnzymeCAGE/demo/bio_vector-main/bio_vector-main/demo/output_v3_esmc_cpu_round1`

Both runs completed `100` epochs and produced model, embeddings, FAISS indices,
metrics, training history, visualization, and effective-rank diagnostics.

Retrieval metrics:

| Mode | R->E MRR | R->E top-5 | E->M MRR | S->M MRR |
|---|---:|---:|---:|---:|
| GVP | `0.7493` | `0.8967` | `0.6004` | `0.6293` |
| ESM-C | `0.7419` | `0.8767` | `0.5756` | `0.6464` |

Diagnostic summary:

- GVP effective ranks:
  - Reaction `81.08`
  - Enzyme `85.00`
  - Substrate `123.46`
  - Microbe `66.27`
- ESM-C effective ranks:
  - Reaction `81.40`
  - Enzyme `83.45`
  - Substrate `121.86`
  - Microbe `62.89`
- Microbe dimension inflation warning appears in both modes.
- DRFP collision warning appears in both modes.

Important interpretation:

- Retrieval is evaluated on all `300` examples after training, not only the
  held-out split.
- Treat results as successful demo pipeline/alignment validation, not final
  generalization proof.

Next action:

- Design second-round parameter changes conservatively, probably focused on
  lowering VICReg pressure for low-dimensional modalities or globally lowering
  `vicreg_var_weight`.
- Preserve round-1 output directories as baseline.
- Do not run full clean training package yet.

### 2026-06-08 Local Storage Cleanup

Purpose: free local disk while preserving the verified full clean training
artifacts needed for future HPC transfer.

Verified before deletion:

- Main no-ESM-C training tar:
  `/home/a/EnzymeCAGE/custom/github_upload/reaction_enzyme_microbe_training_clean_2026-06-01_LOCAL_WITH_GVP_NO_ESMC.tar`
  - regular file
  - size: `33,488,558,080` bytes, about `32G`
  - SHA256:
    `1cd69d38955f5b76e0b645d91d14d8a14473fa3c153c55a3cff7713da4c0f206`
  - checksum command result: `OK`

Deleted:

- `/home/a/EnzymeCAGE/custom/github_upload/reaction_enzyme_microbe_training_clean_2026-06-01_LOCAL`
  - about `32G`
  - extracted duplicate of the verified main package
  - included duplicate GVP shards under
    `features/enzyme/gvp_pocket_features/shards`
- Local caches/build residue:
  - `/home/a/.cache/pip`, about `9.7G`
  - `/home/a/EnzymeCAGE/.mamba-root/pkgs`, about `1.9G`
  - `/home/a/EnzymeCAGE/.deps`, about `500M`
  - `/home/a/EnzymeCAGE/.envs/rhea-clean/lib/python3.10/site-packages/~orch`,
    about `1.5G`
- Git temporary pack garbage:
  `/home/a/EnzymeCAGE/.git/objects/pack/tmp_pack_*`

Kept:

- Verified main tar and `.sha256` file.
- Microbe long-preference add-on tar and checksum.
- Canonical GVP shards:
  `/home/a/EnzymeCAGE/data/processed/rhea/2026-01-21/feature/protein/gvp_feature/shards`
  - `192` regular files
  - about `28G`

Validation after cleanup:

- `/home/a/EnzymeCAGE/.envs/rhea-clean/bin/python` imports Torch successfully:
  `torch 2.2.1+cu121`, CUDA available.
- `.git` temporary pack garbage count is `0`.
- Filesystem availability after cleanup: `701G` available on `/dev/sdd`.

Important boundary:

- The deleted extracted full package can be recreated from the verified tar.
- Do not delete the verified tar or canonical GVP shards until an external
  backup is confirmed.

Update later on 2026-06-08:

- User confirmed the main no-ESM-C training tar is backed up in the Nanjing
  University cloud drive and can be downloaded again if needed.
- Deleted local main tar:
  `/home/a/EnzymeCAGE/custom/github_upload/reaction_enzyme_microbe_training_clean_2026-06-01_LOCAL_WITH_GVP_NO_ESMC.tar`
  - size before deletion: about `32G`
  - last verified SHA256:
    `1cd69d38955f5b76e0b645d91d14d8a14473fa3c153c55a3cff7713da4c0f206`
- Kept checksum file locally:
  `/home/a/EnzymeCAGE/custom/github_upload/reaction_enzyme_microbe_training_clean_2026-06-01_LOCAL_WITH_GVP_NO_ESMC.tar.sha256`
- If the tar is needed again for HPC transfer, download it from the Nanjing
  University cloud drive and verify against the kept `.sha256` file before use.
- Disk state after deletion: `732G` available on `/dev/sdd`.
