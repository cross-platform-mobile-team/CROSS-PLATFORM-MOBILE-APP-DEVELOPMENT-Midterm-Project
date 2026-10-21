# Evidence outputs

The alias manifest records `sha256` and `bytes` for repository blob bytes so
verification is independent of checkout CRLF/LF conversion. It also retains
`working_tree_sha256` and `working_tree_bytes` from the Windows consolidation.
The 210,385-byte reduction refers to that working copy. Raw log content is not
trimmed to satisfy whitespace checks.

## Exact duplicate file aliases

On 21 October 2026, byte-identical copies were consolidated. Original event
identities and outcomes remain in the records above and the [alias manifest](aliases.json). Shared bytes do not establish a new run, independent
repetitions or a changed outcome. Use the retained file for the raw payload.

| Original local filename | Retained raw output |
| --- | --- |
| `backend-syntax-20260907.txt` | [docs/evidence/accessibility-api-check-20260909.txt](accessibility-api-check-20260909.txt) |
| `edge-sample-no-tab-20260908.txt` | [docs/evidence/edge-sample-confirm-20260908.txt](edge-sample-confirm-20260908.txt) |
| `edge-sample-rerun-20260907.txt` | [docs/evidence/edge-sample-keyboard-20260908.txt](edge-sample-keyboard-20260908.txt) |
| `edge-sample-result-rerun-20260908.txt` | [docs/evidence/edge-sample-keyboard-20260908.txt](edge-sample-keyboard-20260908.txt) |
