# all_enzymes.csv Input Manifest

Generated: 2026-06-25

This gzip contains the enzyme sequence table used for the ESM-C 600M sequence-level feature generation/reproduction route.

Source local file:

```text
/home/a/EnzymeCAGE/data/processed/rhea/2026-01-21/all_enzymes.csv
```

Compressed file:

```text
all_enzymes_195743.csv.gz
```

SHA256:

```text
b7494b2ab7b8f01350841a44f9572746e34978bec5341fe5d7a4feca41837f97
```

Counts:

```text
rows=195743
unique_UniprotID=195743
unique_sequence=164514
min_sequence_length=4
max_sequence_length=1000
```

Important columns for ESM-C extraction:

```text
UniprotID
sequence
```

The ESM-C extraction source reads `UniprotID` and `sequence`, saves per-UID residue matrices, and saves a sequence-keyed mean-pooled dictionary.
