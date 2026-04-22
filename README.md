# EE499 FYP — Buck/Boost DC-DC Converter for Robotics and Autonomous Systems

Design, simulate, build and test a buck/boost DC-DC converter intended for use in robotics and autonomous systems such as factory automation, surveillance platforms, delivery robots, drones and e-mobility applications.

## Overview

DC-DC converters supply the various voltage rails required by different sub-systems in robotic platforms. This project investigates the key design principles of a switched-mode buck/boost converter, with emphasis on:

- **Efficiency** — targeting >97 % through low-power MOSFET switching and high-Q energy-storage components (inductors and capacitors).
- **Power quality** — minimising output voltage ripple introduced by the switching action to protect downstream sub-systems.
- **PWM control** — using pulse-width modulation to regulate the output voltage and current under varying load conditions.

## Repository Structure

| Folder | Contents |
|--------|----------|
| `LTSpice Boost Converter/` | LTSpice simulation schematics and waveform data for the LTC1871-based boost converter |
| `KiCAD PCB Design/` | KiCad schematic, PCB layout and project files |
| `EE499 Deliverables/` | Submitted project deliverables |
| `EE499 Checklist and Report Iterations/` | Report drafts and progress checklists |
| `Figures/` | Diagrams and images used in documentation |
| `Feedback Documents from Dr. Bob Lawlor/` | Supervisor feedback |
| `FYP_Template/` | Report and document templates |
| `auto_sync.sh`, `start_sync.bat` | Foreground Git Bash auto-sync (interval-based) |
| `sync_fyp.ps1`, `sync_fyp.vbs` | Background PowerShell sync (scheduled, silent) |

## Tools

- **LTSpice** — circuit simulation and AC/transient analysis
- **KiCad** — schematic capture and PCB layout
- **MATLAB / Simulink** — system-level modelling

## Repository Sync

Two mechanisms keep local clones in sync with this remote. Both commit, pull, and push automatically; `sync_fyp.log` captures activity.

- **Foreground watcher** — `start_sync.bat` launches `auto_sync.sh` in a Git Bash window (default 60 s interval). Handles divergence by preserving local work on a `backup/<host>/<timestamp>` branch before resetting to remote.
- **Background watcher** — `sync_fyp.vbs` runs `sync_fyp.ps1` silently (scheduled task, 15 min interval).

### Setting up on a new machine

`start_sync.bat` hardcodes the Git Bash executable path. On first setup, edit line 4 to point at the local Git install — e.g. `C:\Program Files\Git\bin\bash.exe` for a system-wide install, or `C:\Users\<user>\AppData\Local\Programs\Git\bin\bash.exe` for a per-user install. Run `where git` to check which one is present.

## Supervisor

Dr. Bob Lawlor

## References

1. EPC — DC-DC Converters for Industrial Applications
2. M. H. Rashid (Ed.), *Power Electronics Handbook*, 3rd Edition
3. A. S. Sedra, K. C. Smith et al., *Microelectronic Circuits*, 8th International Edition, Oxford University Press, 2021
4. R. Shaffer, *Fundamentals of Power Electronics with MATLAB*, Firewall Media, 2013
