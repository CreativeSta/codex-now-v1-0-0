# Codex Now（Windows）

`Codex Now` 是一个面向 Windows 的 `Codex CLI` 一键启动器，默认采用安全优先策略。

它可以：
- 在指定目录一键启动 Codex
- 可选集成资源管理器右键菜单
- 使用更稳妥的默认运行参数

## 安全默认配置

默认启动命令：
- `codex -C "<target_dir>" -a on-request -s workspace-write`

极速模式（仅在你显式传参时启用）：
- `codex-now.cmd [target_dir] --fast`
- 实际执行：`codex -C "<target_dir>" --full-auto`

默认不会使用：
- `--dangerously-bypass-approvals-and-sandbox`

额外安全保护：
- 校验目标路径是否存在且必须是目录
- 拦截高风险 shell 字符（`& | < > ^ %`）
- 执行前输出 `[AUDIT]` 命令审计信息
- 右键菜单仅写入 `HKCU`（用户级，无需管理员权限）
- 右键菜单图标优先使用 `codex.exe` 图标，找不到时回退系统图标

## 项目结构

- `windows/codex-now.cmd`：启动器主脚本
- `windows/install.bat`：安装脚本（复制到 `%USERPROFILE%\bin`）
- `windows/install-context-menu.bat`：安装右键菜单
- `windows/uninstall-context-menu.bat`：卸载右键菜单
- `windows/diagnose.bat`：诊断脚本
- `scripts/release.ps1`：发布打包脚本（zip + sha256）
- `docs/RELEASE_NOTES_TEMPLATE.zh-CN.md`：中文 Release Notes 模板

## 安装

1. 先确认 Codex CLI 可用：
   - `codex --version`
2. 执行安装：
   - `windows\install.bat`
3. （可选）安装右键菜单：
   - `windows\install-context-menu.bat`

## 使用方式

命令行：
- `codex-now.cmd`
- `codex-now.cmd "F:\github\my-repo"`
- `codex-now.cmd "F:\github\my-repo" --fast`

资源管理器右键：
- 在文件夹 / 文件夹空白处 / 磁盘根目录右键
- 选择 `Open with Codex Now`

## 卸载右键菜单

- 运行：`windows\uninstall-context-menu.bat`

## 诊断

- 运行：`windows\diagnose.bat`

## 右键菜单图标切换

脚本：
- `windows\set-menu-icon.bat`

可选项：
- `windows\set-menu-icon.bat codex`（使用 Codex 程序图标）
- `windows\set-menu-icon.bat system`（系统默认样式）
- `windows\set-menu-icon.bat legacy`（旧版样式）
- `windows\set-menu-icon.bat custom "C:\path\icon.ico"`（自定义 ico）
- `windows\set-menu-icon.bat custom "C:\path\app.exe,0"`（使用 exe/dll 内图标）

## 发布打包（zip + sha256）

脚本：
- `scripts\release.ps1`

基础用法：
- `powershell -ExecutionPolicy Bypass -File .\scripts\release.ps1 -Version 1.0.0`

自定义输出目录：
- `powershell -ExecutionPolicy Bypass -File .\scripts\release.ps1 -Version 1.0.0 -OutputDir .\release`

输出文件：
- `codex-now-windows-<version>.zip`
- `codex-now-windows-<version>.zip.sha256`

## Release Notes（中文模板）

可直接复制使用：
- `docs/RELEASE_NOTES_TEMPLATE.zh-CN.md`
