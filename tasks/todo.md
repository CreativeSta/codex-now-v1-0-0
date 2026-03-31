# Task Todo

## Goal

排查他人双击 `install.bat` 闪退的原因，修复真实安装问题，并在 `README.md` 中补充详细安装与使用说明。

## Plan

- [x] 检查项目结构、安装入口、发布包内容与现有文档
  - 高层说明：确认源码安装链路、发布包安装链路、以及 `install.bat` 的依赖文件。
- [x] 修复安装链路中的真实问题
  - 检查项：发布包必须包含安装所需全部文件。
  - 检查项：`install.bat` 在失败时应给出可见提示，避免双击时“闪退无信息”。
- [x] 完善 `README.md`
  - 检查项：说明前置依赖。
  - 检查项：分别说明“从源码安装”和“从发布包安装”。
  - 检查项：说明右键菜单、诊断、卸载、常见问题。
- [x] 验证修复结果
  - 检查项：确认发布脚本的打包清单已包含缺失文件。
  - 检查项：确认安装脚本在缺依赖场景下不会无提示退出。
  - 检查项：确认 README 与实际脚本行为一致。

## Progress

- [x] 已定位两个根因：
  - 发布包漏打核心文件，导致 `install.bat` 在发布包场景下必然失败。
  - `install.bat` 报错后直接退出，双击时用户看不到错误。
- [x] 已更新 `windows/install.bat`
  - 高层说明：增加失败提示、坏包提示、以及默认暂停，避免双击时窗口瞬间关闭。
- [x] 已重写 `README.md`
  - 高层说明：补充从发布包安装、从源码安装、首次使用、右键菜单、诊断、卸载与 FAQ。
- [x] 已重新生成 `release/codex-now-windows-1.0.0.zip`
  - 高层说明：新 zip 已包含 `codex-now.ps1`、`codex-now-explorer.cmd`、`generate-hourglass-icon.ps1`、`set-menu-icon.bat` 等缺失文件。

## Result Review

- 结论：
  - “别人点 `install.bat` 闪退”的直接体验原因是脚本此前报错后直接退出。
  - 更深层根因是仓库内旧的 `release/codex-now-windows-1.0.0.zip` 缺少安装必需文件，导致发布包安装路径本身就会失败。
- 验证：
  - 在工作区临时用户目录下运行 `windows\install.bat --no-pause`，安装成功并生成目标文件。
  - 在故意缺文件的临时坏包里运行 `install.bat --no-pause`，脚本会明确提示包不完整，而不是无提示退出。
  - 重新执行 `scripts\release.ps1 -Version 1.0.0` 后检查 zip，确认安装所需文件已完整打包。
