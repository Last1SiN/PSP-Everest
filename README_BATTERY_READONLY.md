# PSP Everest Rev9 — Battery Serial Diagnostics (RO2)

Base: [original PSP Everest 2 Rev9](https://github.com/joel16/PSP-Everest/releases/tag/v2.9), commit `d30e675dd0a252adbb9b640d5d7a3821e2ba4ed6`.
License: GPLv3, original authors frostegater and Joel16.

## Verified on PSP-3000 / firmware 6.20 PRO

The first read-only test build ran on the user's real PSP-3000. Battery voltage,
temperature, charge and capacity were readable, but both direct battery EEPROM
queries failed with `0x80250084`:

- `0x07 -> 0x80250084`
- `0x09 -> 0x80250084`

This error has been identified in PSP Syscon research as **invalid command**.
It means the selected Syscon command is rejected, not that the battery is
inauthentic or faulty.

## Second diagnostic attempt: regular battery serial command

The regular Sony Syscon function `sceSysconBatteryGetSerial()` uses battery
command **0x6C**, whereas the original direct EEPROM read uses **0x74**.
These are different commands. The firmware-level 0x6C approach is described
in the uOFW PSP Syscon implementation and PSPDEV import tables.

The current branch issues the **read-only** 0x6C command directly through
`sceSysconCmdExec` and parses its four-byte response if the expected packet
length (7) is present. This avoids adding firmware-dependent imports.

- The main `Serial` field prefers successful command 0x6C.
- If command 0x6C fails but both 0x74 EEPROM reads work, `Serial` falls
  back to the EEPROM word pair.
- On PSP-3000, the former `Mode: -` field now shows `Serial 6C: OK` or
  `Serial 6C ERR: XXXXXXXX`, so the raw result is visible.
- Bottom lines have shorter labels (`EE07` / `EE09`) to avoid overlapping
  text on the PSP's 480-pixel screen.
- On PSP-1000 and capable early PSP-2000, mode logic is unchanged.

## Read-only safety

No code is permitted to write to battery EEPROM. The original write helper,
writeability test, and kernel export were removed. The battery commands used
are only `0x6C` and `0x74`, not the EEPROM write command `0x73`.
The test build is not a battery programmer and makes no battery modifications.

## Build and test

The GitHub Actions workflow compiles `app/EBOOT.PBP` with PSPDEV and publishes
an artifact named `PSP-Everest-Rev9-Battery-RO-EBOOT`. The build is not itself
a hardware test.

Install the artifact in a separate folder
`ms0:/PSP/GAME/EVEREST_RO/EBOOT.PBP`, leaving the original Rev9 intact.

Open Battery Information and capture a screenshot/photo of:
- `Serial`
- `Serial 6C` (on PSP-3000)
- `EE07` and `EE09`

If the 0x6C command fails, report its exact error code. The read-only test
does not prove that the serial cannot be retrieved by other means.

## References

- [uOFW Syscon implementation](https://github.com/uofw/uofw/blob/master/src/syscon/syscon.c)
- [PSPDEV Syscon import table](https://github.com/pspdev/pspsdk/blob/master/src/kernel/sceSyscon_driver.S)
- [Syscon 0x80250084 analysis](https://lukasz.dk/mirror/forums.ps2dev.org/viewtopic92c2.html?t=10959)
