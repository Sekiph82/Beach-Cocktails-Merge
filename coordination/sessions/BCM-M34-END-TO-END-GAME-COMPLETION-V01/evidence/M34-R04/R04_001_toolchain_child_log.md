# R04-001 — Android toolchain inventory

Result: **BLOCKED on missing Android toolchain; inventory complete.**

Inspected Godot 4.7.2, standard JDK/Android SDK locations, PATH commands, and the Godot 4.7.2 export-template folder. Godot is present; only Web export templates are installed. `java`, `adb`, `sdkmanager`, and `gradle` are absent, as are the Android SDK, Android Studio, NDK, CMake, Android export template, and `export_presets.cfg`.

No installation was attempted. Installing the command-line SDK bootstrap plus Android platform, NDK, CMake, and export template would require large downloads and introduce license-acceptance/toolchain changes. R04 prohibited unapproved large downloads; no global PATH or other project was modified. See `android_toolchain_inventory.json` for exact paths and the official Godot requirements.
