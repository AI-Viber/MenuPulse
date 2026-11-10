# MenuPulse

A MenuMeters-style system monitor for the macOS menu bar.

- **Up to 4 menu bar icons**, each a glyph plus a small live history graph.
  Choose any of CPU, GPU, Neural Engine, Memory, Disk and Network.
- **Click any icon** to drop down a panel with one row per metric. The row you
  clicked opens expanded; click any other row to expand or collapse it.
- **Pin button** on each row adds or removes that metric from the menu bar.
  With nothing pinned, a single plain icon remains so the panel stays reachable.
- **⌘-drag** an icon to move it; macOS remembers where you put each one.
- **Icon style**: graphs are coloured per metric, and the glyph can be turned
  off for a narrower graph-only icon. Both are checkboxes at the bottom of the
  panel. With colour off, icons use the menu bar's own single tint.

| Metric | Menu bar graph | Expanded row |
| --- | --- | --- |
| CPU | Total usage | User / system / idle, load average, CPU power, per-core bars (E and P cores labelled) |
| GPU | Utilisation | Overall, renderer and tiler utilisation, memory in use, GPU power |
| Neural Engine | Estimated load | Power draw in watts and estimated load |
| Memory | Used fraction | App / wired / compressed / cached breakdown, free, swap, pressure |
| Disk | Read (up) and write (down) | Read and write rates, startup disk space, per-disk rates |
| Network | Download (up) and upload (down) | Download and upload rates, per-interface rates and IP addresses |

## Requirements

- macOS 13 (Ventura) or later
- Xcode 15 or later, or the matching Command Line Tools (`xcode-select --install`)

## Build and run

```sh
./build-app.sh
open build/MenuPulse.app
```

To work on it in Xcode, open `Package.swift` and run the `MenuPulse` scheme.
Run that way it works as normal, but "Launch at login" needs the bundled app
from `build-app.sh`. Copy `build/MenuPulse.app` to `/Applications` before
turning that on.

## Project layout

```
Package.swift
build-app.sh                 Builds and wraps the binary in MenuPulse.app
Support/Info.plist           Bundle settings (LSUIElement hides the Dock icon)
Sources/MenuPulse/
  App/AppDelegate.swift      Entry point of the standalone app
  Monitor/                   Everything else; self-contained and embeddable
    MonitorStatusController.swift  The menu bar icons and the dropdown they share
    MenuBarIcon.swift              Draws each icon
    MonitorViews.swift             SwiftUI dropdown: rows, detail panels, footer
    SystemMonitor.swift            Background timer that polls the samplers
    MonitorSettings.swift          Pinned metrics, refresh interval, on/off
    Models.swift                   Data types and number formatting
    Samplers/                      One file per data source
```

## Embedding in another app

The `Monitor` folder has no dependency on the app shell. Copy it into another
AppKit app and create one controller on the main thread:

```swift
let monitor = MonitorStatusController(mode: .embedded)
monitor.showPanel(hostAnchor: myStatusItem.button)   // from the host's own menu
```

In embedded mode zero icons may be pinned, the footer drops Quit and Launch at
login, and `MonitorSettings.shared.enabled` is a master switch. Sampling runs
on a background queue and stops whenever no icon or panel is showing.

## Where the numbers come from

- **CPU**: `host_processor_info` tick counters, per core.
- **GPU**: the `PerformanceStatistics` dictionary on `IOAccelerator`.
- **Neural Engine and power**: the SoC "Energy Model" counters, read through
  the private `IOReport` library. Apple Silicon only.
- **Memory**: `host_statistics64`, plus `vm.swapusage` and the memory pressure
  level from `sysctl`.
- **Disk**: `IOBlockStorageDriver` byte counters.
- **Network**: interface byte counters from `getifaddrs`.

Nothing needs root or a helper tool.

## Known limits

- **Neural Engine**: macOS exposes no utilisation figure, only energy use. The
  "load" shown is power draw against a nominal 8 W
  (`PowerStats.aneFullLoadWatts` in `Models.swift`). Treat it as an activity
  indicator rather than a percentage of capacity.
- **Private API**: `IOReport` is undocumented, so this cannot ship on the Mac
  App Store and the app must not be sandboxed. If the library is missing, the
  power and Neural Engine readings show "n/a" and everything else still works.
- **Core labels** assume efficiency cores are listed before performance cores.
  If the labels look swapped on your chip, the fix is in `CPUSampler.swift`.
- **Network total** counts `en*` and `pdp_ip*` interfaces only, so VPN traffic
  is not counted twice. Other interfaces still appear in the per-interface list.
- **Icon order**: icons pinned at first launch run CPU to Network, left to
  right. One pinned later appears at the left; ⌘-drag it where you want it.

## Licence

MIT. See [LICENSE](LICENSE).
