# AXI4 Full Slave RTL Design and Verification

> A configurable and modular AXI4 Full Slave RTL implementation developed in SystemVerilog with functional verification using a self-checking testbench.

---

## Project Overview

This project implements an **AXI4 Full Slave** compliant with the ARM AMBA AXI4 protocol specification.

The design follows a modular RTL architecture and supports all five AXI4 channels, burst transfers, transaction buffering, address generation, and protocol response handling. Functional verification is performed using a directed SystemVerilog testbench with ModelSim waveform analysis.

The project was developed as part of the **Samsung PRISM** worklet and serves as a foundation for future **AXI4 Verification IP (VIP)** development.

---

# Architecture

```
                    AXI MASTER
                         │
         ┌───────────────┴───────────────┐
         │                               │
     Write Channel                  Read Channel
         │                               │
         ▼                               ▼
  axi_write_controller          axi_read_controller
         │                               │
         ├──────────────┬────────────────┤
         ▼              ▼
  axi_transaction_fifo  axi_addr_gen
               │
               ▼
            axi_mem
               │
               ▼
        axi_resp_gen
```

---

# Repository Structure

```
AXI4_SLAVE_RTL
│
├── rtl/
├── tb/
├── docs/
├── sim/
├── waveforms/
│
├── README.md
├── CHANGELOG.md
├── LICENSE
├── CONTRIBUTING.md
└── .gitignore
```

---

# RTL Modules

| Module | Description |
|---------|-------------|
| axi_slave_top | Top-level AXI4 Slave |
| axi_write_controller | Write transaction controller |
| axi_read_controller | Read transaction controller |
| axi_transaction_fifo | Transaction buffering |
| axi_mem | Internal memory |
| axi_addr_gen | Burst address generator |
| axi_alignment_checker | Alignment verification |
| axi_boundary_checker | Boundary verification |
| axi_resp_gen | Response generation |
| axi_id_tracker | Transaction ID handling |
| axi_write_fsm | Write channel state machine |
| axi_read_fsm | Read channel state machine |

---

# Supported Features

### AXI Channels

- Write Address (AW)
- Write Data (W)
- Write Response (B)
- Read Address (AR)
- Read Data (R)

### Transactions

- Single Write
- Single Read
- Burst Write
- Burst Read

### Burst Types

- FIXED Burst
- INCR Burst
- WRAP Burst

### Protocol Features

- VALID / READY Handshake
- Transaction FIFO
- Burst Address Generation
- Transaction ID Handling
- Multiple Outstanding Transactions
- Concurrent Read and Write
- Backpressure Handling
- Address Alignment Checking
- Burst Boundary Checking
- Response Generation

---

# Verification

The RTL has been functionally verified using a SystemVerilog self-checking testbench.

Verified functionality includes:

- Reset
- Single Write
- Single Read
- FIXED Burst
- INCR Burst
- WRAP Burst
- Multiple Address Transactions
- Concurrent Read / Write
- Transaction ID Handling
- Multiple Outstanding Transactions
- Backpressure Handling

Simulation Tool:

- ModelSim

---

# Documentation

Complete project documentation is available in the `docs/` directory.

| Document |
|----------|
| Project Overview |
| AXI4 Protocol |
| System Architecture |
| RTL Architecture |
| RTL Module Description |
| Address Generation |
| Verification Methodology |
| Test Cases |
| Waveform Analysis |
| Supported Features |
| Current Limitations |
| Future Work |

---

# Development Status

| Component | Status |
|-----------|--------|
| RTL Design | ✅ Complete |
| Functional Verification | ✅ Complete |
| Documentation | ✅ Complete |
| Directed Testbench | ✅ Complete |
| Waveform Verification | ✅ Complete |
| UVM Verification | 🔄 Planned |
| AXI4 VIP | 🔄 Planned |

---

# Future Roadmap

## Version 2.0

- Enhanced protocol verification
- Additional corner-case testing
- Improved verification automation

## Version 3.0

- UVM Environment
- Master Agent
- Slave Agent
- Driver
- Monitor
- Sequencer
- Scoreboard

## Version 4.0

- Complete AXI4 Verification IP
- Functional Coverage
- SystemVerilog Assertions
- Regression Framework
- Performance Analysis

---

# Tools

- SystemVerilog
- Verilog
- ModelSim
- Git
- GitHub

---

# License

This project is intended for educational, research, and learning purposes.

See the LICENSE file for details.
