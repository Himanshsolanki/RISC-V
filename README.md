# RV32I Single-Cycle CPU

A small RISC-V processor written in Verilog as an educational ASIC design project. The CPU uses a single-cycle datapath: instructions are fetched from an internal instruction memory, decoded, and executed before the next clock edge. It is not a pipelined processor.

## What it supports

The implemented subset includes:

- Arithmetic and logic: `ADD`, `SUB`, `AND`, `OR`, `XOR`, `SLT`, `ADDI`, `ANDI`, `ORI`, `XORI`, `SLTI`
- Memory: `LW`, `SW` for 32-bit words
- Control flow: `BEQ`, `BNE`, `JAL`
- Upper immediates: `LUI`, `AUIPC`
- `FENCE`, treated as a no-op

Unsupported instructions, including `ECALL` and `JALR`, stop execution and set `halted`. The halt remains asserted until reset. This project does not implement the full RV32I specification, exceptions, CSRs, interrupts, byte or halfword memory accesses, or a pipeline. The instruction and data memories are internal Verilog arrays; alignment faults and memory-mapped peripherals are not implemented.

## Design

The top-level `rv32i_cpu` connects the instruction memory, control unit, immediate generator, register file, ALU, and data memory. The register file has two read ports and one write port, and reads from `x0` always return zero. The CPU interface is `clk`, active-high asynchronous `reset`, and `halted`.

## Run the simulation

From the project root in PowerShell, with Icarus Verilog installed:

```powershell
.\scripts\simulate.ps1
```

The self-checking testbench runs every supported instruction behavior and checks register updates, `x0`, word loads and stores, branch and jump behavior, and the illegal-instruction halt. The testbench passed in the available environment: **PASS, 22 cycles**. The simulator (`vvp`) exited successfully. The installed Windows `iverilog` executable reports an access-violation exit status after producing its output file; the script runs the generated simulation image and reports its result.

## Project files

- `rtl/` contains the processor modules.
- `tb/tb_rv32i_cpu.v` contains the self-checking testbench.
- `programs/smoke.hex` is a short example program. `programs/selfcheck.hex` is the testbench's initialized memory image.
- `scripts/simulate.ps1` compiles and runs the testbench.
- `scripts/synth.ys` and `scripts/synthesize.ps1` are provided for generic Yosys synthesis.
- `openlane/config.json` and `constraints/asic.sdc` are starter physical-design configuration files.

## Synthesis and physical design

Yosys, OpenLane, OpenROAD, Docker, and the SKY130 PDK were not available in the environment used for this project, so synthesis and physical design have not been run. To try generic synthesis where Yosys is installed, run:

```powershell
.\scripts\synthesize.ps1
```

The OpenLane configuration is a starting point and may need adjustment for the installed OpenLane version. This repository does not include a generated GDSII file or measured area, timing, power, DRC, or LVS results.
