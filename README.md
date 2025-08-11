# RSI Indicator in SystemVerilog
This repository contains a SystemVerilog implementation of the Relative Strength Index indicator, using fixed-point arithmetic Q8.8.


## Purpose
The final purpose of this repo is to impliment the whole chain to calculate the RSI of real incoming data and compare it against a Python reference model.

## Repo structure
```bash
├── rtl/
│   
├── tb/
│   ├── uvm_env/            # UVM environment (agents, sequencer, driver, monitor, scoreboard)
│   ├── tests/              # UVM test cases (sanity, corner cases, parameter sweeps, reset/enable tests)
│   └── sim/                # Simulation scripts for Questa/VCS/Verilator
├── ref/
│   ├── rsi_ref.py          # Python reference implementation
│   └── vectors/            # Test vectors and real-market traces
├── README.md           
└── .github/workflows/      # Continuous Integration (lint + sim + reference comparison)
s
```
## Technical Overview 
Fixed-Point Format
- uq8_8_t: Unsigned 16-bit fixed point with 8 fractional bits (Q8.8).

- uq16_16_t: Unsigned 32-bit fixed point (Q16.16) for accumulation and division.

All fixed-point parameters and conversion helpers are in fixed_pkg.sv:

- FIXED_WIDTH = 16, FIXED_FRAC_BITS = 8

- Conversion functions: real_to_uq8_8, uq8_8_to_real, uq16_16_to_uq8_8, etc.

### Main module (for the moment)
```bash
module top_rsi 
#(
    parameter N=14,
    parameter G_POLARITY=0
)
(
    input  logic    i_clk,
    input  logic    i_rst,
    input  logic    i_en,
    input  uq8_8_t  i_prices[N],
    output uq8_8_t  o_rsi_scaled,
    output logic    o_rsi_valid,
    input  uq8_8_t i_curr_price,  
    input  logic   i_valid_price
);
```
#### Functionality

1. Takes an array of N price samples (i_prices in Q8.8).

2. Computes gain/loss per time step, averages them, and calculates RS = avg_gain / avg_loss.

3. Outputs o_rs_scaled in Q8.8, saturating if it exceeds the representable range.


#### Parameters

- N: RSI window size (default 14).

- G_POLARITY: Reset polarity (0 active-low, 1 active-high).

#### Implementation Notes

If sum_loss == 0, division by zero is avoided by forcing avg_loss = 1.

The RS ratio is scaled to match the Q8.8 output format.

Designed to be synthesizable for FPGA.

## Targets Tested
### Hardware ressources.

## How to simulate
With Questa:  
1. Compile all RTL + UVM packages:
```bash
vlog -sv \
  +incdir+. \
  +incdir+$UVM_HOME/src \
  $UVM_HOME/src/uvm_pkg.sv \
  -f filelist.f
```
**Notes:**
- `$QUESTA_HOME` → path to your Questa installation (e.g., `/opt/questa-2024.3/`).
- `$UVM_HOME` → usually `$QUESTA_HOME/verilog_src/uvm-1.2`.
- `+incdir+.` → includes the current directory.
- `filelist.f` → should list all RTL + TB source files in the correct order.

2. Run the simulation in console mode

```bashs
vsim -c -voptargs="+acc" -uvmcontrol=all work.tb \
  -sv_lib $UVM_HOME/win64/uvm_dpi \
  -do "run -all"
  ```

## Future work 
- [ ] **Ethernet streaming interface** to send RSI values in real-time (with parser + FIFO).
- [ ] **Real market data capture** and live RSI computation.
- [ ] **Comparison pipelined and combinational version**
- [ ] **Automatic plotting** of hardware vs. Python RSI traces in CI.
- [ ] **Continious Integration**

## Credits
Claudia Menéndez Cárdenes
