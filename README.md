# Codex Now（Windows）

`Codex Now` 是一个面向 Windows 的 `Codex CLI` 启动器，目标是让你在指定目录里更安全、更省事地启动 Codex，并可选集成资源管理器右键菜单。

默认启动命令：

- `codex -C "<target_dir>" -a on-request -s workspace-write`

极速模式：

- `codex-now.cmd [target_dir] --fast`
- 实际执行：`codex -C "<target_dir>" --full-auto`

它默认不会启用：

- `--dangerously-bypass-approvals-and-sandbox`

## 功能概览

- 一键在指定目录启动 Codex
- 记住上一次打开的目录，下一次可直接继续
- 可选安装资源管理器右键菜单
- 右键菜单仅写入 `HKCU`，无需管理员权限
- 启动前输出 `[AUDIT]` 命令信息，便于确认实际执行内容
- 对目标路径做基础安全校验，拦截高风险 shell 字符

## 目录结构

- `windows/codex-now.cmd`：主启动脚本
- `windows/codex-now-explorer.cmd`：供资源管理器右键菜单调用的辅助脚本
- `windows/codex-now.ps1`：右键菜单隐藏窗口启动脚本
- `windows/install.bat`：安装脚本，复制启动器到 `%USERPROFILE%\bin`
- `windows/install-context-menu.bat`：安装右键菜单
- `windows/uninstall-context-menu.bat`：卸载右键菜单
- `windows/diagnose.bat`：诊断当前安装状态
- `windows/set-menu-icon.bat`：切换右键菜单图标
- `scripts/release.ps1`：生成发布包（zip + sha256）

## 安装前准备

安装本项目之前，请先确认：

1. 你使用的是 Windows。
2. 你已经安装好 Codex CLI。
3. 在终端里运行 `codex --version` 能看到版本号。

如果 `codex --version` 报错，那么 `install.bat` 也会失败。

## 安装方式

### 方式一：从发布包安装

这是推荐给其他使用者的方式。

1. 下载发布包 zip。
2. 把 zip **完整解压**到一个普通目录。
3. 不要只单独拿出 `install.bat` 运行，必须保留整个 `windows` 目录里的配套文件。
4. 进入解压后的目录，运行：

```bat
windows\install.bat
```

也可以直接双击 `windows\install.bat`。

安装脚本会做这些事：

- 检查 `codex` 命令是否可用
- 检查安装所需文件是否完整
- 将启动器复制到 `%USERPROFILE%\bin`
- 生成默认右键菜单图标文件
- 检查 `%USERPROFILE%\bin` 是否已加入 `PATH`

安装成功后，通常会得到这些文件：

- `%USERPROFILE%\bin\codex-now.cmd`
- `%USERPROFILE%\bin\codex-now-explorer.cmd`
- `%USERPROFILE%\bin\codex-now.ps1`
- `%USERPROFILE%\bin\codex-now-hourglass.ico`

### 方式二：从源码仓库安装

如果别人拿到的是这个仓库源码，也可以直接安装：

1. 克隆或下载整个仓库。
2. 在仓库根目录打开终端。
3. 运行：

```bat
windows\install.bat
```

## 为什么别人点 `install.bat` 会闪退

常见原因有两个：

1. 双击运行 `.bat` 时，如果脚本报错后直接退出，窗口会瞬间关闭，看起来就像“闪退”。
2. 如果别人拿到的是一个不完整的安装包，例如只拷走了 `install.bat`，或者发布包里缺少 `codex-now.ps1`、`codex-now-explorer.cmd` 之类的配套文件，安装脚本会立即失败。

当前仓库已经针对这个体验做了改进：

- 安装失败时会保留窗口，方便查看错误原因
- 缺文件时会明确提示“当前包不完整或已过期，请重新下载并完整解压”

如果别人仍然说“闪退”，优先让他按下面顺序检查：

1. 是否完整解压了整个 zip。
2. 是否先安装了 Codex CLI，并且 `codex --version` 正常。
3. 是否有权限创建 `%USERPROFILE%\bin`。
4. 是否直接在终端中运行 `windows\install.bat` 查看输出。

如果你想在脚本执行完成后不等待按键，也可以运行：

```bat
windows\install.bat --no-pause
```

## 首次使用

安装完成后，可以直接在终端中使用：

```bat
codex-now.cmd
```

这会：

- 优先打开上一次使用的目录
- 如果没有历史目录，则默认打开 `%USERPROFILE%`

指定目录启动：

```bat
codex-now.cmd "F:\github\my-repo"
```

开启极速模式：

```bat
codex-now.cmd "F:\github\my-repo" --fast
```

也可以不传目录，只开启极速模式：

```bat
codex-now.cmd --fast
```

## 资源管理器右键菜单

如果希望在资源管理器里右键打开 Codex：

```bat
windows\install-context-menu.bat
```

安装后，你可以在这些位置看到菜单项：

- 文件夹
- 文件夹空白处
- 磁盘根目录

右键菜单默认文案是：

- `codex now`

## 右键菜单图标切换

脚本：

```bat
windows\set-menu-icon.bat
```

可选参数：

- `windows\set-menu-icon.bat codex`
- `windows\set-menu-icon.bat system`
- `windows\set-menu-icon.bat legacy`
- `windows\set-menu-icon.bat hourglass`
- `windows\set-menu-icon.bat custom "C:\path\icon.ico"`
- `windows\set-menu-icon.bat custom "C:\path\app.exe,0"`

## 诊断

如果安装后不能正常使用，先运行：

```bat
windows\diagnose.bat
```

它会检查：

- `%USERPROFILE%\bin` 下的启动器文件是否存在
- `codex` 是否在 `PATH` 中
- `%USERPROFILE%\bin` 是否在 `PATH` 中
- 右键菜单注册表项是否存在
- 当前右键菜单图标和命令内容

## 卸载

只卸载右键菜单：

```bat
windows\uninstall-context-menu.bat
```

如果要彻底删除本工具，可以额外手动删除这些文件：

- `%USERPROFILE%\bin\codex-now.cmd`
- `%USERPROFILE%\bin\codex-now-explorer.cmd`
- `%USERPROFILE%\bin\codex-now.ps1`
- `%USERPROFILE%\bin\codex-now-hourglass.ico`
- `%USERPROFILE%\.codex-now-last-dir`
- `%USERPROFILE%\.codex-now-menu-icon`

## 常见问题

### 1. 安装成功了，但终端里提示 `codex-now.cmd` 不是内部或外部命令

说明 `%USERPROFILE%\bin` 还没加入 `PATH`，或者当前终端没有重新打开。

处理方式：

1. 先关闭并重新打开终端。
2. 如果仍然无效，把 `%USERPROFILE%\bin` 手动加入用户环境变量 `PATH`。
3. 临时也可以直接运行：

```bat
"%USERPROFILE%\bin\codex-now.cmd"
```

### 2. 提示 `codex command was not found`

说明 Codex CLI 还没装好，或者没有加入 `PATH`。

先确认：

```bat
codex --version
```

### 3. 双击安装时报“缺少 source file”

通常说明以下情况之一：

- 没有完整解压发布包
- 只单独复制了 `install.bat`
- 你手里的发布包是旧包，内容与当前源码不一致

正确做法是重新下载最新发布包，并完整解压后再执行。

## 打包发布

生成发布包：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\release.ps1 -Version 1.0.0
```

自定义输出目录：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\release.ps1 -Version 1.0.0 -OutputDir .\release
```

输出文件：

- `codex-now-windows-<version>.zip`
- `codex-now-windows-<version>.zip.sha256`
