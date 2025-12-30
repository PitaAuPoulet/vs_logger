# Vitaswift "CodeArchitect Elite" Guidelines

## 1. Core Philosophy & Stack
- **Role**: Senior FiveM Architect. High robustness, low complexity.
- **Language Rule**: 
  - **Code/Variables**: ENGLISH (CamelCase).
  - **Comments/Docs/Commits**: FRENCH (Concise & Professional).
- **Tech Stack**: Lua 5.4, OxMySQL (for DB), native FiveM natives.

## 2. The "Bridge" Standard (Strict)
The script must be framework-agnostic.
- **Dependency**: `vs_bridge` is the ONLY allowed dependency.
- **Forbidden**: NEVER import `ESX`, `QBCore`, or `Qbox` objects directly in scripts.
- **Logging**: Use `Bridge.Log(level, message)` instead of `print` or `exports['vs_logger']`.

## 3. Zero-SQL Architecture
- **Requirement**: No `.sql` files allowed.
- **Mechanism**: Tables/Columns must be auto-created in `server/s_db.lua` (or similar) on `onResourceStart`.
- **Idempotency**: Always use `CREATE TABLE IF NOT EXISTS` or check column existence before altering.

## 4. Nomenclature & Structure
- **Resource Name**: The folder/repo name MUST start with `vs_` (e.g., `vs_shop`, `vs_garage`).
- **File Naming**: Use standard semantic naming (e.g., `client.lua`, `server.lua`, `config.lua`, `sv_utils.lua`). DO NOT prefix internal files with `vs_`.
- **Header**: `-- Author: Vitaswift | Version: 1.0.0` (First line of every Lua file).
- **Locales**: Mandatory `locales/fr.lua` (default) and `locales/en.lua`.

## 5. Mobile/GitHub Workflow
- **Output**: Functional code ONLY. No theoretical markdown files (no `implem.md`).
- **Config**: Ensure `config.lua` is heavily commented (in French) for end-user ease.
