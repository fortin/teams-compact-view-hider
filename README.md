# Teams Compact View Hider

A [Hammerspoon](https://www.hammerspoon.org/) script that minimises the Microsoft Teams compact meeting view as soon as it appears.

Teams has no setting to turn this off. Switch away from a meeting and a small "compact view" window pops up over whatever you were doing. This script watches for that window with UI automation and minimises it immediately, including windows that already exist when Hammerspoon starts or when Teams launches.

## Requirements

- macOS
- [Hammerspoon](https://www.hammerspoon.org/). With Homebrew:

  ```bash
  brew install --cask hammerspoon
  ```

- Microsoft Teams (`com.microsoft.teams2`, the current Teams app)
- Accessibility permission for Hammerspoon, so it can see and minimise the window

Grant access in **System Settings → Privacy & Security → Device Control and Data Access**, then enable Hammerspoon.

## Install

Clone this repo, then load `init.lua` from your Hammerspoon config. If your config lives in the usual place:

```lua
-- ~/.hammerspoon/init.lua
dofile(os.getenv("HOME") .. "/path/to/teams-compact-view-hider/init.lua")
```

Reload Hammerspoon (**Hammerspoon menu → Reload config**, or `hs.reload()`). The Hammerspoon console should print:

```
[Teams] Compact view observer started
```

That line appears when Teams is already running at reload, and again each time Teams launches. When a compact view is minimised:

```
[Teams] Compact view minimised
```

## How it works

1. An `hs.application.watcher` starts and stops a per-app observer when Teams launches and quits.
2. The observer listens for `AXWindowCreated` on the Teams accessibility element.
3. A new window is minimised only when both of these are true:
   - its title starts with `Meeting compact view |`
   - its accessibility subrole is `AXSystemDialog`

Existing Teams windows are checked once when the observer attaches, so a compact view that is already on screen gets minimised too. Other Teams windows are left alone.

The title prefix and subrole are how Teams labels this dialog. If a Teams update changes either one, the script will stop matching until those constants in `init.lua` are updated.

## License

MIT. See [LICENSE](LICENSE).
