# PSP Everest 2 Rev9 — Battery Serial (read-only)

Based on the original [PSP Everest 2 Rev9](https://github.com/joel16/PSP-Everest/releases/tag/v2.9)
(commit `d30e675dd0a252adbb9b640d5d7a3821e2ba4ed6`).
License: GPLv3. Authors of the original project: frostegater and Joel16.

## The problem

The stock Rev9 deliberately skips battery EEPROM serial reading on PSP-3000 and
requires a successful *EEPROM write test* before showing the serial on eligible
PSP models. An original battery can therefore show `Serial: -`.

## Hardware findings — PSP-3000, 6.20 PRO

A first diagnostic build was tested on real PSP-3000 hardware:

| Command | Result |
| --- | --- |
| Battery EEPROM read `0x74`, register `0x07` | `0x80250084` (invalid command) |
| Battery EEPROM read `0x74`, register `0x09` | `0x80250084` (invalid command) |
| Standard battery serial `0x6C` | **PASS**, valid 32-bit serial displayed |

All ordinary battery telemetry (voltage, temperature, capacity, charge level)
continued to work. The successful `0x6C` test is preserved on branch
[`tested/psp3000-6c-ro2`](../../tree/tested/psp3000-6c-ro2)
(commit `24759b7620d0a4b83c8166bfccaf342cd71f7786`).

**This does not authenticate the battery as genuine.** It only proves that the
serial can be read using the standard Syscon command, without modifying EEPROM.

## Final code path

- Reads the battery serial using only **Syscon command `0x6C`**, corresponding
  to `sceSysconBatteryGetSerial()`.
- No direct battery EEPROM read (`0x74`) or EEPROM write (`0x73`).
- The serial is displayed when the `0x6C` call succeeds.
- On PSP-3000, the inapplicable Pandora-mode row reports
  `Serial 6C: OK` or the exact query error.
- On compatible PSP-1000 / early PSP-2000 hardware, the same serial value is
  used to interpret Pandora mode (service, autoboot, normal).
- The Battery Information screen uses its original 14 rows without
  duplicated EEPROM diagnostics.

The final streamlined build is based on a hardware-tested **read routine**,
but still requires one device test of the cleaned-up screen layout.

## Build

A GitHub Actions workflow builds the app with PSPDEV and publishes
`PSP-Everest-Rev9-Battery-RO-EBOOT` containing `EBOOT.PBP`.

1. Open the [Actions page](../../actions).
2. Select the latest successful run for `feature/battery-readonly-rev9`.
3. Download the EBOOT artifact and extract it.
4. Put it in a separate folder:
   `ms0:/PSP/GAME/EVEREST_RO/EBOOT.PBP`.
5. Open Battery Information, check `Serial` and `Serial 6C`, and verify that
   remaining battery data and screen layout are unaffected.

No firmware upgrade, EEPROM writes, or Pandora conversion is involved.

## References

- [uOFW PSP Syscon implementation](https://github.com/uofw/uofw/blob/master/src/syscon/syscon.c)
- [PSPDEV Syscon import definitions](https://github.com/pspdev/pspsdk/blob/master/src/kernel/sceSyscon_driver.S)
