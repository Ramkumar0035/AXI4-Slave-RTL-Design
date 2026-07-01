# RTL Module Description

## 1. Introduction

The AXI4 Full Slave RTL is divided into multiple independent modules. Each module performs a dedicated protocol function, improving readability, maintainability, verification, and scalability.

This document describes the purpose and functionality of every RTL module used in the design.

---

# 2. axi_slave_top

## Purpose

The `axi_slave_top` module is the top-level integration module of the AXI4 Full Slave. It connects all internal RTL modules and interfaces directly with the external AXI4 master.

## Responsibilities

- Connect all AXI channels
- Instantiate read controller
- Instantiate write controller
- Connect internal memory
- Coordinate read and write paths
- Connect protocol checker modules

## Major Interfaces

### Inputs

- Clock
- Reset
- AW Channel
- W Channel
- AR Channel

### Outputs

- B Channel
- R Channel

---

# 3. axi_write_controller

## Purpose

Controls the complete AXI write transaction.

## Responsibilities

- Accept write address
- Store write transaction
- Receive write data
- Generate burst addresses
- Write memory
- Generate write response

## Connected Modules

- Transaction FIFO
- Address Generator
- Memory
- Response Generator

---

# 4. axi_read_controller

## Purpose

Controls the complete AXI read transaction.

## Responsibilities

- Accept read address
- Store read request
- Generate burst addresses
- Read memory
- Return read data
- Generate read response

## Connected Modules

- Transaction FIFO
- Address Generator
- Memory
- Response Generator

---

# 5. axi_transaction_fifo

## Purpose

Stores pending AXI transactions before they are processed.

## Responsibilities

- Buffer incoming transactions
- Store transaction information
- Maintain FIFO ordering
- Support multiple outstanding transactions

## Stored Information

- Transaction ID
- Address
- Burst Length
- Burst Size
- Burst Type

---

# 6. axi_mem

## Purpose

Acts as the internal memory of the AXI4 Slave.

## Responsibilities

- Store write data
- Return read data
- Support byte enables
- Support synchronous write
- Support registered read

## Features

- Parameterized depth
- Parameterized data width
- WSTRB support

---

# 7. axi_addr_gen

## Purpose

Generates the next memory address during burst transfers.

## Supported Burst Types

### FIXED

Address remains constant.

Example

```
0x100
0x100
0x100
0x100
```

---

### INCR

Address increments after every transfer.

Example

```
0x100
0x104
0x108
0x10C
```

---

### WRAP

Address wraps around the calculated boundary.

Example

```
0x30C
0x300
0x304
0x308
```

---

# 8. axi_alignment_checker

## Purpose

Checks whether the transfer address is correctly aligned according to the transfer size.

## Responsibilities

- Verify address alignment
- Detect alignment violations
- Report alignment error

---

# 9. axi_boundary_checker

## Purpose

Verifies that burst transfers do not violate AXI burst boundary rules.

## Responsibilities

- Calculate burst boundary
- Detect boundary violations
- Generate boundary error

---

# 10. axi_resp_gen

## Purpose

Generates AXI response codes.

## Supported Responses

| Response | Description |
|-----------|-------------|
| OKAY | Successful transaction |
| SLVERR | Slave error |
| DECERR | Decode error |

The response generator combines the outputs of protocol checker modules to produce the final AXI response.

---

# 11. axi_id_tracker

## Purpose

Tracks transaction identifiers throughout the protocol.

## Responsibilities

- Store AWID
- Store ARID
- Return BID
- Return RID
- Maintain transaction association

---

# 12. axi_write_fsm

## Purpose

Implements the write channel state machine.

## Major States

- IDLE
- LOAD
- DATA
- RESP

## Responsibilities

- Control write sequencing
- Coordinate memory write
- Generate write response

---

# 13. axi_read_fsm

## Purpose

Implements the read channel state machine.

## Major States

- IDLE
- LOAD
- REQUEST
- WAIT
- SEND

## Responsibilities

- Control read sequencing
- Generate read addresses
- Control burst progression
- Return read data

---

# 14. Module Interaction

The overall interaction between modules is shown below.

```
                AXI Master
                     │
                     ▼
              axi_slave_top
               │         │
               │         │
               ▼         ▼
      axi_write_controller
      axi_read_controller
               │
               ▼
      axi_transaction_fifo
               │
               ▼
         axi_addr_gen
               │
               ▼
            axi_mem
               │
               ▼
         axi_resp_gen
               │
               ▼
          AXI Responses
```

---

# 15. Summary

| Module | Function |
|----------|----------|
| axi_slave_top | Top-level integration |
| axi_write_controller | Write transaction processing |
| axi_read_controller | Read transaction processing |
| axi_transaction_fifo | Transaction buffering |
| axi_mem | Internal memory |
| axi_addr_gen | Burst address generation |
| axi_alignment_checker | Alignment verification |
| axi_boundary_checker | Boundary verification |
| axi_resp_gen | Response generation |
| axi_id_tracker | Transaction ID handling |
| axi_write_fsm | Write state machine |
| axi_read_fsm | Read state machine |

---

# 16. Conclusion

The modular organization of the AXI4 Full Slave separates protocol processing into dedicated RTL blocks. This improves readability, simplifies verification, supports future feature expansion, and enables easier integration with an AXI4 Verification IP (VIP) environment.