# Changelog

All notable changes to this project are documented in this file.

The format follows the principles of Keep a Changelog.

---

# [v1.0] - Initial Stable Release

## Added

### RTL Modules

- AXI4 Full Slave Top Module
- AXI Write Controller
- AXI Read Controller
- AXI Transaction FIFO
- AXI Internal Memory
- AXI Address Generator
- AXI Response Generator
- AXI Alignment Checker
- AXI Boundary Checker
- AXI Transaction ID Tracker
- AXI Write FSM
- AXI Read FSM

---

### AXI4 Features

- Complete AXI4 five-channel interface
- Single write transactions
- Single read transactions
- FIXED burst support
- INCR burst support
- WRAP burst support
- Burst address generation
- Internal memory interface
- Transaction buffering using FIFO
- Transaction ID propagation
- Multiple outstanding transaction support
- Concurrent read and write operation
- Backpressure handling

---

### Verification

- SystemVerilog self-checking testbench
- Reset verification
- Single write verification
- Single read verification
- FIXED burst verification
- INCR burst verification
- WRAP burst verification
- Multiple address transaction verification
- Concurrent read/write verification
- Transaction ID verification
- Multiple outstanding transaction verification
- Backpressure verification

---

### Documentation

Added comprehensive project documentation including:

- Project Overview
- AXI4 Protocol
- System Architecture
- RTL Architecture
- Module Description
- Address Generation
- Verification Methodology
- Test Cases
- Waveform Analysis
- Supported Features
- Current Limitations
- Future Work

---

### Simulation

- ModelSim simulation support
- Functional waveform verification
- Self-checking simulation environment

---

# Future Releases

## Planned for v2.0

- Enhanced protocol robustness
- Additional corner-case verification
- Improved documentation
- Extended verification scenarios

---

## Planned for v3.0

- UVM verification environment
- AXI4 Master Agent
- AXI4 Slave Agent
- Driver
- Monitor
- Sequencer
- Scoreboard
- Functional coverage

---

## Planned for v4.0

- Complete AXI4 Verification IP (VIP)
- Assertion-based verification
- Regression framework
- Performance analysis
- Coverage reports