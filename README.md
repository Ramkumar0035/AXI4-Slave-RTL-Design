# AXI4 Full Slave RTL Design and Verification

## Overview

This project implements a configurable **AXI4 Full Slave** compliant with the ARM AMBA AXI4 protocol. The RTL is developed in Verilog/SystemVerilog using a modular architecture and verified through a self-checking SystemVerilog testbench.

The project was developed as part of the **Samsung PRISM** worklet and serves as a foundation for future AXI4 Verification IP (VIP) development.

---

## Features

### Implemented

- AXI4 Full Slave RTL
- Five AXI4 Channels
  - Write Address (AW)
  - Write Data (W)
  - Write Response (B)
  - Read Address (AR)
  - Read Data (R)
- Single Read/Write Transactions
- FIXED Burst
- INCR Burst
- WRAP Burst
- Burst Address Generation
- Transaction FIFO
- Transaction ID Handling
- Internal Memory
- Address Alignment Checking
- Burst Boundary Checking
- Response Generation
- Multiple Outstanding Transactions
- Concurrent Read and Write Support
- Backpressure Handling
- Parameterized RTL Modules

---

## Verification

The RTL has been verified using a directed SystemVerilog testbench.

Verified scenarios include:

- Reset Verification
- Single Write
- Single Read
- FIXED Burst
- INCR Burst
- WRAP Burst
- Multiple Address Transactions
- Concurrent Read/Write
- Transaction ID Handling
- Multiple Outstanding Transactions
- Backpressure Handling

Simulation was performed using **ModelSim**, and protocol behavior was validated through waveform analysis.

---

## Project Structure

```
AXI4-Full-Slave/
│
├── rtl/
│   ├── axi_slave_top.sv
│   ├── axi_write_controller.sv
│   ├── axi_read_controller.sv
│   ├── axi_transaction_fifo.sv
│   ├── axi_addr_gen.sv
│   ├── axi_mem.sv
│   ├── axi_alignment_checker.sv
│   ├── axi_boundary_checker.sv
│   ├── axi_resp_gen.sv
│   ├── axi_id_tracker.sv
│   ├── axi_write_fsm.sv
│   └── axi_read_fsm.sv
│
├── tb/
│   └── tb_axi_slave_smoke.sv
│
├── docs/
│
├── waveforms/
│
└── README.md
```

---

## Supported Burst Types

| Burst Type | Status |
|------------|--------|
| FIXED | ✓ |
| INCR | ✓ |
| WRAP | ✓ |

---

## Supported Features

| Feature | Status |
|----------|--------|
| Single Read | ✓ |
| Single Write | ✓ |
| Burst Read | ✓ |
| Burst Write | ✓ |
| Transaction FIFO | ✓ |
| Transaction ID | ✓ |
| Multiple Outstanding Transactions | ✓ |
| Backpressure | ✓ |

---

## Documentation

Project documentation includes:

- Project Overview
- AXI4 Protocol Overview
- System Architecture
- RTL Architecture
- RTL Module Description
- Address Generation
- Verification Methodology
- Test Cases
- Waveform Analysis
- Supported Features
- Current Limitations
- Future Work

---

## Future Enhancements

Planned developments include:

- AXI4 Master RTL
- UVM-Based Verification Environment
- AXI4 Verification IP (VIP)
- Protocol Assertions (SVA)
- Functional Coverage
- Constrained-Random Verification
- Regression Automation
- Performance Analysis

---

## Development Status

**Current Version:** v1.0

Status:

- RTL Design: Complete
- Functional Verification: Complete
- Documentation: Complete
- UVM Verification: Planned
- AXI4 VIP Development: Planned

---

## Tools Used

- Verilog
- SystemVerilog
- ModelSim
- Git
- GitHub

---

## License

This project is intended for educational, research, and learning purposes.