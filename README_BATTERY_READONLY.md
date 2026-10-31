# PSP Everest Rev9 — Battery Read-only Diagnostics

Based on released PSP Everest 2 Rev9 (commit d30e675dd0a252adbb9b640d5d7a3821e2ba4ed6).

Goal: diagnose original battery serial readings on PSP-3000 with 6.20 PRO without modifying battery EEPROM.

The Rev9 code only attempts serial reading on PSP-1000 and select early PSP-2000 boards, and tests EEPROM writeability before showing the serial. PSP-3000 is excluded from that logic.

Planned change: read serial words at EEPROM addresses 0x07 and 0x09 independently using the existing Syscon read operation, display each read status, and remove write operations from the diagnostic path. Keep Pandora-mode handling restricted to supported hardware.

Safety: never change battery EEPROM contents. Source code is not a hardware validation; errors do not prove battery is counterfeit.

Build target: app/EBOOT.PBP using PSPDEV. Runtime verification on PSP-3000 remains pending.

License: GPLv3. Original authors: frostegater and Joel16.
