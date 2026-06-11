# Parameterized CPU Datapath in Verilog

## Overview
A structural, parameterized CPU datapath designed in Verilog. This project demonstrates the physical integration of an Arithmetic Logic Unit (ALU) with a multi-port Register File, creating a closed-loop hardware execution cycle. It abandons error-prone positional port mapping in favor of explicit named port mapping, ensuring a clean, production-ready feedback highway for memory writes.

## Architectural Features
* **Parameterized Widths:** Data and address bus widths are fully scalable via top-level parameter propagation.
* **Execution Core (ALU):** A purely combinational 4-bit Arithmetic Logic Unit supporting arithmetic (ADD, SUB) and bitwise operations, explicitly coded to prevent accidental latch synthesis.
* **Short-Term Vault (Register File):** A parameterized memory array featuring dual synchronous combinational read ports and a single clock-guarded sequential write port.
* **Datapath Loopback:** The top-level structural wrapper routes the ALU output bus directly back into the Register File's write-data port, verified free of bus contention or width mismatches.
* **Timing-Safe Verification:** The testbench stimulus is driven on the falling edge of the clock, providing optimal setup-time margins and eliminating simulation race conditions.

## Simulation Waveform
*(The instantaneous combinational ALU read/compute followed by the clock-synchronous memory latching)*

![GTKWave Simulation](waveform.png) 

## File Structure
* `datapath.v` - The top-level structural wrapper utilizing explicit named port connections.
* `alu.v` - The combinational Arithmetic Logic Unit.
* `reg_file.v` - The memory array and access logic.
* `tb_datapath.v` - The verification testbench featuring hierarchical backdoor memory loading and sequential testing.

## Toolchain & Prerequisites
To compile and simulate this RTL, you need an EDA toolchain capable of Verilog-2001 compilation and VCD waveform viewing.
* [Icarus Verilog (iverilog)](http://iverilog.icarus.com/)
* [GTKWave](https://gtkwave.sourceforge.net/)

## How to Run the Simulation
Clone the repository and execute the compilation toolchain from your terminal:

```bash
# 1. Compile the architectural modules and testbench
iverilog -o sim_datapath datapath.v alu.v reg_file.v tb_datapath.v

# 2. Execute the simulation binary
vvp sim_datapath

# 3. Open the waveform viewer
gtkwave datapath.vcd
