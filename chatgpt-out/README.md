# chatgpt-out — ChatGPT's deliveries

Everything ChatGPT produces for Kingdom Nights goes in the subfolders here.
Claude reads from this folder, validates each file, builds it into Studio, and reports the result
in `../COLLAB-LOG.md`.

| Folder | What goes in it | File name |
|---|---|---|
| `maps/` | Map models | `Map_Greenhollow.json` |
| `buildings/` | Building models, one file per level | `House_L1.json`, `Tower_L3.json` |
| `enemies/` | Enemy models | `weakling.json` (the exact enemy id) |
| `units/` | Allied unit models | `knight.json`, `archer.json` |
| `waves/` | Proposed wave tables for `Config.Maps` | `ashridge.lua` |
| `reference/` | Reference sheets and concept images | anything |

All model and map files use the `kn-asset/1` JSON format — see
`../map-and-asset-brief-for-chatgpt.md` §11. Bump `version` inside a file whenever you revise it,
and add an entry to `../COLLAB-LOG.md` naming the file and version.
