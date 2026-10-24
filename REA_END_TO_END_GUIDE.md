# REA (`morluto/rea`) — Workspace Reference & Operational Playbook

## 1. Installation Summary (`rea-agents@6.7.0`)

- **Workspace Skills (`.agents/skills/`)**:
  - [`.agents/skills/reverse-engineer-anything/SKILL.md`](./.agents/skills/reverse-engineer-anything/SKILL.md) (Primary RE workflow + 6 domain reference guides in `references/`)
  - [`.agents/skills/rea-tool-design/SKILL.md`](./.agents/skills/rea-tool-design/SKILL.md)
  - [`.agents/skills/rea-analysis-optimization/SKILL.md`](./.agents/skills/rea-analysis-optimization/SKILL.md)
  - [`.agents/skills/rea-ci-tests-audit/SKILL.md`](./.agents/skills/rea-ci-tests-audit/SKILL.md)
  - [`.agents/skills/rea-changelog-update/SKILL.md`](./.agents/skills/rea-changelog-update/SKILL.md)
- **Global Antigravity Registration**:
  - MCP Server Config: `C:\Users\mutee\.gemini\config\mcp_config.json` (`state: "aligned"`, `207` MCP tools, `6` guided prompts)
  - Personal Skill Copy: `C:\Users\mutee\.gemini\config\skills\reverse-engineer-anything` (`state: "aligned"`)
  - Global CLI: `rea` / `rea-agents` v6.7.0 (`153` CLI commands)
- **Full Source & Documentation Checkout**:
  - [`./tools/rea`](./tools/rea) (`morluto/rea` source tree, bridges, and 80+ documentation guides)

---

## 2. Quick CLI & Readiness Commands

```powershell
# Verify Antigravity MCP registration and skill alignment
rea doctor --client antigravity --skill --json

# Check readiness for a specific external engine (ghidra, jadx, ida, kuna)
rea doctor --provider ghidra --json
rea doctor --provider jadx --json

# Triage an unknown desktop installation directory
rea inspect-desktop-application "C:\path\to\app" --detail summary --evidence_output desktop-evidence.json --json

# Inspect an extracted Electron / JS application or app.asar
rea analyze-javascript-application "C:\path\to\app.asar" --detail summary --evidence_output js-evidence.json --json

# Inspect an Android APK's signing block (v1/v2/v3/v3.1) and certificates (0 external tools required)
rea inspect-apk-signature "C:\path\to\moviebox.apk" --json

# Inspect an archive/APK/IPA/PyInstaller inventory (0 external tools required)
rea inspect-artifact "C:\path\to\moviebox.apk" --detail summary --evidence_output apk-inventory.json --json

# Inspect a saved HAR or Fiddler .saz web network capture
rea inspect-web-network-capture "C:\path\to\traffic.har" --detail summary --evidence_output har-evidence.json --json
```

---

## 3. Target Routing Cheat Sheet for Movie-Box Investigations

| Target Artifact | First Tool to Call (MCP / CLI) | Follow-Up Views & Traces | External Engine Needed? |
| :--- | :--- | :--- | :--- |
| **Android `.apk` (Container & Signatures)** | `inspect_apk_signature`, `open_binary` + `inspect_artifact` (`detail: "summary"`) | `inspect_analysis_view` (`kind: "inventory"`, `collection: "occurrences"`) | **None (Built-in)** |
| **Android `.apk` (Flutter `libapp.so`)** | `identify_flutter_build`, `inspect_dart_aot` | Inspects Dart snapshot hash, engine commit, and per-ABI library digests | **None (Built-in)** |
| **Android `.apk` (Unity `global-metadata.dat`)** | `inspect_il2cpp_metadata` (with optional `binary_path` to `libil2cpp.so`) | `inspect_analysis_view` (`images`, `types`, `methods`, `string_literals`, `method_addresses`) | **None (Built-in)** |
| **Android `.apk` (DEX Classes & Methods)** | `inspect_android_package` -> `search_android_classes` | `inspect_android_class` -> `inspect_android_method` -> `trace_android_references` | `REA_JADX_MCP_JAR` + `JAVA_HOME` (JDK 17+) |
| **Android `.apk` (Resources & Manifest XML)** | `decode_android_resources` | Inspects decoded `AndroidManifest.xml`, `resources.arsc`, string tables, locales | `REA_APKTOOL_COMMAND` |
| **Android Live Device / Emulator** | `list_adb_devices` -> `list_adb_packages` / `read_adb_logcat` | `pull_adb_package`, `capture_adb_screen`, `inspect_adb_window`, `start_adb_activity` | `adb` on `PATH` or `REA_ADB_COMMAND` |
| **Native `.so` / `.dll` / `.exe` (Quick Triage)** | `inspect_native_exports`, `inspect_elf_notes`, `inspect_pe_imports`, `inspect_pe_certificates`, `inspect_pe_resources`, `inspect_byte_entropy` | `inspect_analysis_view` (`kind: "native-exports"`) | **None (Built-in)** |
| **Native `.so` / `.dll` / `.exe` (Deep Decompile)** | `open_binary` -> `binary_overview` / `search_strings` / `search_procedures` | `analyze_function` (summary-first) -> `inspect_analysis_view` (`kind: "native"`, `facet: "pseudocode"` / `"assembly"` / `"value_flow_operations"`) -> `trace_native_values` | `GHIDRA_INSTALL_DIR` or `REA_IDA_MCP_CONFIG` |
| **Electron / JS App (`app.asar` or folder)** | `inspect_electron_fuses`, `analyze_javascript_application` (`detail: "summary"`) | `inspect_analysis_view` (`javascript-routes`, `modules` page/item, `javascript-facts`) -> `trace_application_feature` | **None (Built-in)** |
| **Captured Network Traffic (`.har` / `.saz` / `.qlog`)** | `inspect_web_network_capture` (`detail: "summary"`) | `inspect_analysis_view` (`api-surface`, `environment-manifest`, `environment-state`, `protobuf`, `capture`) | **None (Built-in)** |
| **Live Website / Web Player** | `list_browser_targets` or `capture_browser_scenario` | `inspect_web_page`, `analyze_web_bundle`, `observe_web_execution`, `trace_web_source_location` | Chrome/Edge CDP or `REA_BROWSER_EXECUTABLE` |
| **SQLite Local Cache / DB (`.db` / `.sqlite`)** | `inspect_sqlite_database` | Compact schema inventory first, then select table + `columns` + `row_limit` | **None** (Node 24.15+ / 26+ native SQLite) |
