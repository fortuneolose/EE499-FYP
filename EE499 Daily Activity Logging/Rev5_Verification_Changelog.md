# LTC1871_BOM_Caps_Rev5_Derated — Change Log & PCB Pre-Flight Checklist

**Author:** Fortune Olose | **Date:** 7 April 2026 | **Base file:** LTC1871_BOM_Caps_Rev4.asc

---

## Summary of Changes (Rev4 → Rev5)

This file corrects six modelling gaps in the Rev4 simulation that would cause hardware results to diverge significantly from simulation predictions. Every change makes the simulation *more pessimistic* — if metrics still pass under these conditions, the PCB design has real margin.

---

## Change 1 — DC-Bias Derated Output Capacitors

| Component | Rev4 (nominal) | Rev5 (derated at 12 V) | Source |
|-----------|---------------|----------------------|--------|
| C1a (6×22 µF GRM31CR61E226M) | 132 µF | **102 µF** (6 × 17 µF) | Murata SimSurfing: GRM31CR61E226M at 12 V DC bias → ~77% of nominal |
| C1b (2×10 µF GRM21BR61E106K) | 20 µF | **14 µF** (2 × 7 µF) | Murata SimSurfing: GRM21BR61E106K at 12 V DC bias → ~70% of nominal |
| **Total effective** | 152 µF | **116 µF** | |

**Why this matters:** Rev4 used nominal capacitance values. Class II MLCCs (X5R/X7R) lose 20–40% of their capacitance at rated DC bias. The real board sees ~116 µF, not 152 µF. Ripple voltage is inversely proportional to capacitance, so the actual ripple will be ~30% higher than Rev4 predicted. Load transient droop will also be proportionally worse.

**Action for you:** Verify these derated values against Murata's SimSurfing tool for your exact part numbers at 12 V DC bias. The 77% and 70% figures used here are conservative estimates — your actual parts may derate slightly more or less depending on the specific lot.

---

## Change 2 — Inductor DC Resistance (DCR)

| Parameter | Rev4 | Rev5 |
|-----------|------|------|
| L1 Rser | 0 Ω (ideal) | **28.4 mΩ** |

**Source:** Coilcraft XAL6060-103MEC datasheet, DCR (typ) = 28.4 mΩ.

**Why this matters:** At 3 A average current (VIN = 8 V, 2 A load), the inductor drops I²×DCR = 0.26 W and introduces 85 mV of DC voltage drop at the inductor input. This reduces efficiency by ~1% and slightly shifts the operating point. More importantly, the DCR adds a real zero in the power stage transfer function that the ideal inductor model misses.

---

## Change 3 — Battery Source Impedance

| Parameter | Rev4 | Rev5 |
|-----------|------|------|
| V1 Rser | 0 Ω (ideal) | **50 mΩ** (parameterised as `{Rbat}`) |

**Source:** Typical 3S LiPo internal resistance (30–80 mΩ) plus connector/wire resistance (~10–20 mΩ).

**Why this matters:** An ideal voltage source has zero impedance — it can supply infinite current instantaneously. A real LiPo cannot. At 3 A input current draw, the battery drops 150 mV across its internal resistance. During load transients, the input voltage sags, which increases duty cycle and worsens the output droop. The Rev4 simulation was artificially optimistic about transient performance because it assumed a perfect supply.

**Tuning:** `Rbat` is parameterised in the directive block. Measure your actual battery + wiring resistance with a milliohm meter and update the value. If you're using a bench supply for initial testing, set `Rbat=0.01` (typical bench supply output impedance).

**PCB action required:** You must add bulk + ceramic input capacitors close to the LTC1871 VIN pin. This is not optional — the LTC1871 datasheet specifies a minimum input capacitor. Recommended: 1× 100 µF electrolytic (bulk) + 2× 10 µF 0805 MLCC (high-frequency decoupling), all within 10 mm of the VIN pin. These are **not yet in the .asc schematic** (adding them requires GUI placement) — add them manually in LTspice and on your KiCad schematic before PCB order.

---

## Change 4 — Parametric VIN Sweep (Worst-Case Coverage)

| Parameter | Rev4 | Rev5 |
|-----------|------|------|
| `.step` directive | Single VIN = 9.6 V | **`.step param VIN list 8 9.6 11`** |

Rev4 ran at nominal VIN only. Rev5 sweeps all three operating points in a single run, so you get worst-case metrics automatically. The error log will report all measurements for each step.

---

## Change 5 — Fixed Recovery Time Measurement

| Parameter | Rev4 | Rev5 |
|-----------|------|------|
| Recovery threshold | `V(OUT)=12.15 CROSS=2` | **`V(OUT)=12.08 RISE=1`** |

**Why the Rev4 measurement was wrong:** The 12.15 V threshold sits within the normal switching ripple band (12.2 V ± 93 mV). With 184 mV peak-to-peak ripple, V(OUT) crosses 12.15 V every switching cycle regardless of whether a load transient is occurring. The `CROSS=2` directive simply caught the second ripple crossing after the time delay, producing the physically implausible 2.18 µs "recovery" — less than one switching cycle.

**Rev5 fix:** The threshold is set to 12.08 V, which is below the ripple envelope floor (12.2 − 0.093 = 12.107 V). The `RISE=1` keyword explicitly finds the first upward crossing, eliminating the ambiguity of `CROSS=2`. This will report the true time at which V(OUT) recovers from the load-step droop back into the regulation band.

**Expected result:** Recovery time will be in the range of 20–80 µs, not 2.18 µs. This is still well within the 1 ms target, but is the real number.

---

## Change 6 — Additional Measurement Directives

New measurements added:

| Directive | Purpose |
|-----------|---------|
| `Vout_droop1_mV` / `Vout_droop2_mV` | Droop in millivolts (computed from steady-state average minus minimum) |
| `Vout_ripple_pre` | Pre-step ripple (confirms steady-state before load events) |
| `IL_peak_full` | Peak inductor current **during full 2 A load** (the actual worst case, not the pre-step idle window) |
| `Eff` | Efficiency computed directly as `Pout/Pin×100` in the .meas block |
| `Vmin_abs` | Absolute minimum V(OUT) across entire simulation — the true worst-case voltage the load bus sees |

---

## What Rev5 Does NOT Fix (Manual Actions Required)

### A. Input Decoupling Capacitors
Add these to your KiCad schematic and LTspice model manually:

| Ref | Value | Package | Placement |
|-----|-------|---------|-----------|
| Cin1 | 100 µF 25 V electrolytic | 8×10 mm radial or 6.3×7.7 SMD | Within 15 mm of LTC1871 VIN pin |
| Cin2 | 10 µF 25 V X5R MLCC | 0805 | Within 5 mm of LTC1871 VIN pin |
| Cin3 | 10 µF 25 V X5R MLCC | 0805 | Within 5 mm of LTC1871 VIN pin |

In LTspice, add a single capacitor (120 µF, Rser=0.015) from IN to GND.

### B. MOSFET Gate Resistor
Consider adding a 2.2 Ω gate resistor between the LTC1871 GATE pin and the IRF7811 gate to damp ringing from gate loop inductance. Not critical for simulation but important for EMI on the PCB. Can be a 0402 0 Ω placeholder on the BOM (populated only if ringing is observed during hardware bring-up).

### C. Inductor Inductance Derating
The XAL6060-103MEC drops from 10 µH to approximately 8.5 µH at 3.5 A DC bias. To test the impact, change L1 from `10µ` to `8.5µ` in LTspice and re-run. This will increase ripple current by ~18% and shift the RHPZ frequency. If metrics still pass at 8.5 µH, the design is robust.

### D. Motor Inrush Model
The PWL current source models a controlled 2 A step. A real DC motor at stall may draw 5–10 A briefly. To stress-test: change the PWL peak from 2.0 A to 5.0 A for a 500 µs pulse, then check Vmin_abs. If V(OUT) drops below 11.4 V, you need either a larger output capacitor bank or an inrush current limiter on the motor driver.

---

## PCB Layout Checklist (Pre-Order)

Before sending the board to fabrication, verify:

- [ ] Input capacitors (Cin1/Cin2/Cin3) placed within 15 mm of VIN pin
- [ ] Output capacitor bank (C1a × 6, C1b × 2) placed within 10 mm of OUT node, with short return path to GND
- [ ] SENSE trace routed as a Kelvin connection directly to MOSFET source pad — not through the power ground pour
- [ ] GND pour under L1, Q1, D1 for thermal relief (MBR735 dissipates ~1 W at 2 A)
- [ ] FB divider (R2/R3) placed close to LTC1871 FB pin, away from switching node
- [ ] Switching node (MOSFET drain / inductor / diode anode junction) kept physically small to minimize radiated EMI
- [ ] No signal traces routed under L1 or across the switching node
- [ ] INTVCC bypass cap (C4 = 4.7 µF) within 3 mm of INTVCC pin
- [ ] Compensation network (R4/C2/C3) within 5 mm of ITH pin
- [ ] FREQ resistor (R1) within 5 mm of FREQ pin
- [ ] Board thickness and copper weight specified (1.6 mm, 1 oz minimum; 2 oz preferred for power traces)

---

## Expected Impact on Key Metrics

| Metric | Rev4 Result | Rev5 Expected (Estimate) | Target | Still Pass? |
|--------|------------|------------------------|--------|-------------|
| Output ripple | 184 mV | ~220–240 mV | < 240 mV | Marginal — watch this |
| Load droop (2 A) | 127 mV | ~180–250 mV | < 600 mV | Yes |
| Recovery time | 2.18 µs (artefact) | ~30–60 µs (real) | < 1 ms | Yes |
| Efficiency | 94.83% | ~92–93% | > 85% | Yes |
| IL_peak (2 A load) | 3.548 A | ~3.6–3.7 A | < 3.59 A (analytical) | **Marginal** — verify |
| Vmin_abs | Not measured | ~11.8–12.0 V | > 11.4 V | Yes |

The ripple and IL_peak are the two metrics most at risk. If ripple exceeds 240 mV in the Rev5 simulation, you should add a 9th output capacitor (another 22 µF 1206) to the BOM. If IL_peak exceeds 3.59 A at VIN = 8 V with the derated inductor (8.5 µH), the analytical limit needs to be recalculated for the actual inductance.
