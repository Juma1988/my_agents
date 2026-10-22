# Flutter Fail Recovery (MuMu / ADB)

Loaded when the preferred FF target is missing or FF fails. EVE v1.4 · commands and recovery steps only.

```powershell
& "C:\Users\juma\Android\sdk\platform-tools\adb.exe" connect 127.0.0.1:5555
& "C:\Users\juma\Android\sdk\platform-tools\adb.exe" devices
```

Restart ADB if needed:

```powershell
& "C:\Users\juma\Android\sdk\platform-tools\adb.exe" kill-server
& "C:\Users\juma\Android\sdk\platform-tools\adb.exe" start-server
& "C:\Users\juma\Android\sdk\platform-tools\adb.exe" devices
```

Then (per EVE Flutter Automation rules):

1. Retry device detection; cache the successful ADB connection string so recovery only runs when truly needed.
2. Cache the exact successful `flutter run` command + target for reuse without re-probing.
3. After a failed FF, offer the next most likely device (physical device → other emulator → web) as a one-tap choice.
