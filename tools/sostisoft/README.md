# Terminal Vertical (Sostisoft build)

A build of Windows Terminal with **vertical tabs**: tabs are stacked top-to-bottom in a sidebar on the left.

Branch `sostisoft/vertical` = upstream `release-1.25` + the vertical tabs feature + this branding
(own package identity, so it installs side by side with the Store version).

## Install

Elevated Windows PowerShell:

```powershell
irm https://raw.githubusercontent.com/sostisoft/terminal/sostisoft/vertical/tools/sostisoft/install.ps1 | iex
```

Launch "Terminal Vertical" from the Start menu, or `wtd`.

## Usage

- Click a tab to switch, middle-click or the × to close, right-click for the tab menu.
- Drag tabs in the sidebar to reorder them.
- The sidebar is on by default in this build. Turn it off with `"experimental.verticalTabs": false` in `settings.json`.

## Build

Requirements: Visual Studio 2022 with the components in `.vsconfig`, PowerShell 7.

```powershell
pwsh -File tools\sostisoft\build.ps1 -PfxPath C:\path\sostisoft.pfx
```

The signed package is written to `out\sostisoft\TerminalVertical_x64.msix`.
The signing certificate is not stored in the repository.
