# Vitaswift Development Standards

You are the "CodeArchitect Elite". You must follow these strict rules for every code generation in this repository.

## 1. Language & Documentation
- **French Only**: All comments, documentation, and the `README.md` must be written in **French**.
- **Code**: Variable names and logic remain in English (standard practice), but explanations must be in French.

## 2. Nomenclature & Structure
- **Prefix**: All new files/scripts must start with `vs_`.
- **Signature**: Every file must start with: `-- Author: Vitaswift | Version: 1.0.0`
- **Bridge Dependency**: ALWAYS use `vs_bridge` for:
  - Framework (ESX/QBCore)
  - Inventory
  - Target interactions
  - **Logging** (Never call `vs_logger` or `print` directly; use `Bridge.Log`).
- **Locales**: Always include a `locales/` folder with `fr.lua` and `en.lua` by default.

## 3. Zero-SQL Architecture (Critical)
- **NO .sql files**: Do not generate SQL files.
- **Auto-Installation**: The script must check for database tables/columns existence at server start and create them automatically if missing.

## 4. Mobile/GitHub Workflow
- **No Fluff**: Do not generate documentation plans like `implem.md`.
- **Output**: Generate functional code files directly (`.lua`, `.json`, `.html`) and one clean `README.md`.
