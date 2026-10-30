# Clinkr architecture

How the iPhone app and the Apple Watch app fit together. Solid lines are what exists today. Dashed boxes and lines are the usual next pieces, which aren't built yet.

## 1. From project to devices

One Xcode project builds two apps. The Watch app is packed inside the iPhone app, and the Watch installs it automatically when the iPhone app is installed.

```mermaid
flowchart LR
    subgraph xcode["Clinkr.xcodeproj"]
        t1["Target: Clinkr<br/>(iOS 26+)"]
        t2["Target: Clinkr Watch App<br/>(watchOS 26+)"]
    end

    subgraph bundle["Clinkr.app"]
        phoneBin["iPhone app code"]
        subgraph watchFolder["Watch/"]
            watchBin["Clinkr Watch App.app"]
        end
    end

    t1 -- builds --> phoneBin
    t2 -- builds --> watchBin

    bundle -- "installed via Xcode,<br/>TestFlight or App Store" --> iphone["iPhone"]
    iphone -- "auto-installs<br/>Watch app" --> watch["Apple Watch"]
```

## 2. Inside each app

Both apps are SwiftUI apps with the same shape. Each one starts at an `@main` App struct, which shows a `ContentView`. Both compile `Shared/`: the data model (`DrinkType`, `DrinkEntry`, `Night`) and the design system (colors, text styles, spacing, radii and drink glyphs). The Watch keeps tonight in `NightStore`, which the Add screen's drink buttons write to. The iPhone's own state and phone/watch messaging come later.

```mermaid
flowchart TB
    subgraph phone["iPhone app (Clinkr/)"]
        pApp["ClinkrApp<br/>@main entry point"] --> pView["ContentView<br/>SwiftUI screen"]
        pModel["Model / app state"]:::planned
        pSync["Connectivity service<br/>(WCSession)"]:::planned
        pView -.-> pModel
        pModel -.-> pSync
    end

    subgraph watch["Watch app (Clinkr Watch App/)"]
        wApp["ClinkrWatchApp<br/>@main entry point"] --> wView["ContentView"]
        wView --> wAdd["AddView<br/>DrinkButton grid"]
        wModel["NightStore<br/>tonight, saved to nights.json"]
        wSync["Connectivity service<br/>(WCSession)"]:::planned
        wApp --> wModel
        wAdd -- "add(drink)" --> wModel
        wModel -.-> wSync
    end

    shared["Shared/<br/>DrinkType, DrinkEntry, Night<br/>design tokens, glyphs"]
    shared -.-> pModel
    shared -.-> wModel

    pSync <-. "WatchConnectivity<br/>(Bluetooth / Wi-Fi)" .-> wSync

    classDef planned stroke-dasharray: 5 5
```

## 3. How a message would travel between Watch and iPhone

This is the usual pattern with Apple's WatchConnectivity framework. If the other app is running, messages arrive right away. If not, the system queues the data and delivers it later.

```mermaid
sequenceDiagram
    actor User
    participant W as Watch app
    participant WC as WatchConnectivity (system)
    participant P as iPhone app

    User->>W: Taps a button
    W->>W: Update local state and UI

    alt iPhone app is reachable (running)
        W->>WC: sendMessage(...)
        WC->>P: Delivered immediately
        P-->>W: Optional reply
    else iPhone app not running
        W->>WC: transferUserInfo(...) or updateApplicationContext(...)
        WC-->>P: Delivered in the background, when the system decides
    end

    P->>P: Update its own state and UI
```
