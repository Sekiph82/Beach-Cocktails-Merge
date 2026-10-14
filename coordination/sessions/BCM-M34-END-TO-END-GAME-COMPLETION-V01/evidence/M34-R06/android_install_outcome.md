# R06 V02-003 — Android setup attempt outcome

## Capacity and package preflight

- C: has 1,022,767,394,816 total bytes (952.526 GiB). Immediately before the install attempt, the measured free space was 88.234 GiB; after the post-cleanup probes it was 85.951 GiB. Both exceed the 25 GiB post-install floor and 40 GiB preferred reserve.
- Conservative estimate: a 15 GiB full install would leave at least 73.2 GiB at the pre-install reading. The planned install would use only Android template entries (about 426 MiB uncompressed), plus JDK 17, command-line tools, and Godot's required SDK packages.
- Java, `sdkmanager`, `adb`, and Android Studio were absent from PATH/known install locations. `JAVA_HOME`, `ANDROID_HOME`, and `ANDROID_SDK_ROOT` were unset.
- The existing Godot 4.7.2 template directory was 88,369,145 bytes and held web templates only; the three Android template files were absent.
- A per-user staging root existed at `C:\Users\sekip\AppData\Local\BCM-M34-Android-4.7.2` with downloaded archives and empty JDK/SDK/staging directories. Its origin was not established by this process. The archives were independently hash-verified against official publisher values recorded in `android_setup_plan.md`; none was downloaded again.

## Blocked action

I attempted one PowerShell operation that would extract the verified JDK and Android command-line archives into the empty per-user staging root, move them into the approved JDK/SDK directories, and extract the three Android template files into the existing Godot template directory. The execution service rejected the whole command before PowerShell launched:

```text
exec_command failed: CreateProcess ... Rejected("... blocked by policy")
```

No binaries were extracted, no SDK packages or licenses were installed/accepted, no Godot setting or PATH was changed, and no Android build was run. I did not retry through another command or tool. The blocker is the execution shell's policy rejection, not disk capacity or checksum verification. R06 V02 owner authorization remains in force; the install needs an execution path the shell policy permits.

## Current release boundary

No Android device, export, signed package, ad account, SSV endpoint, or backend was configured. Production ad rewards remain unavailable until live SSV verification and server-authoritative settlement are implemented and accepted. No Coins, Gems, or Energy payout was enabled.
