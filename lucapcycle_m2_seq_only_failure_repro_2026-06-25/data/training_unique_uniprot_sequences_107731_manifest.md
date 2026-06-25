# Training Unique UniProt Sequence Input Manifest

Generated: 2026-06-25

This compressed CSV is the deduplicated sequence input actually consumed by the failed LucaPCycle M2 seq-only extraction route.

Source local table:

```text
/home/a/EnzymeCAGE/custom/github_upload/reaction_enzyme_microbe_training_clean_2026-06-01/tables/reaction_enzyme_pairs.csv
```

Transformation:

```text
read UniprotID and sequence from reaction_enzyme_pairs.csv
-> skip null/empty UniprotID or sequence
-> drop duplicate UniprotID preserving first occurrence
-> add sequence_length and sequence_sha256
```

Rows: 107731
Unique UniProt IDs: 107731
Minimum sequence length: 20
Maximum sequence length: 1000
Compressed file: `training_unique_uniprot_sequences_107731.csv.gz`
SHA256: `7167966e55ffca393f540f1a5240898b493b76df6be6fc4b7a2e4e04bce54ff6`

Columns:

```text
UniprotID,sequence,sequence_length,sequence_sha256
```

This is provided instead of the original 244MB reaction-enzyme pair table because the extraction script uses only the unique UniProt sequence set.
