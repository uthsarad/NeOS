# graphify-out

Generated knowledge graph of this repository: files as nodes, their relationships as
edges, grouped into communities. Produced by the external `graphify` tool, committed
deliberately (the 2026.09.18 CHANGELOG explains why), and never hand-edited apart from
the staleness banner in `GRAPH_REPORT.md`.

- `GRAPH_REPORT.md` — human-readable report: corpus size, community hubs, god nodes, cohesion, integrity diagnostic.
- `graph.json`, `graph.html` — machine-readable graph and a self-contained viewer.
- `manifest.json` — the per-file inventory the extraction ran over.
- `cost.json`, `.graphify_labels.json` — run metadata and community labels.

## Status: stale

The committed output is a **2026-09-18 snapshot**. It predates the 2026-09-22 work
recorded in `CHANGELOG.md`, the relocation of the agent reports into
`reports/v2026.09.11/`, and the removal of the ISO size gate — so its file count (192),
community names ("ISO Size And Audit History") and edges no longer describe this tree.

Regenerate with the `graphify` tool over the current checkout before treating any of it
as current, and commit the refreshed output in the same change that makes the tree move.
`tests/verify_docs_links.sh` skips this directory, because its contents are generated.
