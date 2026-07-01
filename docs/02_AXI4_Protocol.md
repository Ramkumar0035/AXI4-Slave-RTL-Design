# AXI4 Full Protocol Overview

## 1. Introduction

The Advanced eXtensible Interface 4 (AXI4) is a high-performance, high-bandwidth bus protocol defined by ARM as part of the AMBA (Advanced Microcontroller Bus Architecture) specification. It is widely used for communication between processors, memories, peripherals, and custom IP blocks in modern SoCs.

AXI4 supports independent read and write channels, burst-based data transfers, multiple outstanding transactions, and high-throughput pipelined communication.

---

# 2. AXI4 Architecture

AXI4 consists of five independent communication channels.

| Channel | Direction | Purpose |
|----------|-----------|---------|
| Write Address (AW) | Master → Slave | Sends write address and control information |
| Write Data (W) | Master → Slave | Transfers write data |
| Write Response (B) | Slave → Master | Indicates write completion status |
| Read Address (AR) | Master → Slave | Sends read address and control information |
| Read Data (R) | Slave → Master | Returns requested read data |

Since the read and write channels are independent, AXI4 supports simultaneous read and write operations.

---

# 3. AXI4 Handshake Mechanism

Every AXI4 channel follows the VALID/READY handshake protocol.

A transfer occurs only when both VALID and READY are asserted during the same clock cycle.

| Signal | Driven By | Description |
|----------|-----------|-------------|
| VALID | Source | Indicates valid information is available |
| READY | Destination | Indicates the receiver is ready |

Transfer Condition:

```
Transfer = VALID && READY
```

The source must keep VALID asserted until READY is received.

The destination may assert READY at any time.

---

# 4. Write Transaction

A write transaction consists of three phases.

## Step 1

Write Address

Master sends

- AWADDR
- AWLEN
- AWSIZE
- AWBURST
- AWID

Handshake

```
AWVALID && AWREADY
```

---

## Step 2

Write Data

Master sends

- WDATA
- WSTRB
- WLAST

Handshake

```
WVALID && WREADY
```

For burst transfers multiple data beats are transferred.

---

## Step 3

Write Response

Slave returns

- BID
- BRESP

Handshake

```
BVALID && BREADY
```

---

# 5. Read Transaction

Read consists of two phases.

## Step 1

Read Address

Master sends

- ARADDR
- ARLEN
- ARSIZE
- ARBURST
- ARID

Handshake

```
ARVALID && ARREADY
```

---

## Step 2

Read Data

Slave returns

- RID
- RDATA
- RRESP
- RLAST

Handshake

```
RVALID && RREADY
```

The last beat of a burst is identified using RLAST.

---

# 6. Burst Transfers

AXI4 supports three burst types.

## FIXED Burst

- Address remains constant.
- Every transfer accesses the same location.

Example

```
0x100
0x100
0x100
0x100
```

Applications

- FIFO
- Peripheral registers

---

## INCR Burst

Address increases after every beat.

Example

```
0x100
0x104
0x108
0x10C
```

Applications

- Memory transfers
- DMA
- Cache line fills

---

## WRAP Burst

The address increments until the wrap boundary is reached, then wraps back to the starting boundary.

Example

```
Start = 0x30C

0x30C
0x300
0x304
0x308
```

Applications

- Cache memory
- Circular buffers

---

# 7. Transaction ID

AXI4 uses transaction IDs to distinguish multiple outstanding transactions.

Signals

- AWID
- BID
- ARID
- RID

The slave must return the same transaction ID that was received from the master.

---

# 8. Response Signals

The slave reports the status of every transaction using BRESP and RRESP.

| Response | Value | Description |
|-----------|-------|-------------|
| OKAY | 2'b00 | Successful transfer |
| EXOKAY | 2'b01 | Exclusive access successful |
| SLVERR | 2'b10 | Slave error |
| DECERR | 2'b11 | Decode error |

The current implementation primarily uses the OKAY response for successful transactions.

---

# 9. Backpressure

AXI4 allows either the master or slave to temporarily pause data transfer.

Examples

- Master keeps BREADY low.
- Master keeps RREADY low.
- Slave keeps AWREADY low.
- Slave keeps WREADY low.

During backpressure, VALID signals remain asserted until the corresponding READY signal is received.

This mechanism prevents data loss while maintaining protocol compliance.

---

# 10. Multiple Outstanding Transactions

AXI4 allows multiple transactions to be issued before previous transactions complete.

Outstanding transactions improve throughput by overlapping address, data, and response phases.

In the implemented slave, pending transactions are stored in internal FIFOs and serviced in order.

---

# 11. Summary

The implemented AXI4 Full Slave supports the major protocol features required for functional verification, including:

- Independent read and write channels
- VALID/READY handshaking
- Single transfers
- FIXED burst
- INCR burst
- WRAP burst
- Transaction ID handling
- Multiple outstanding transactions
- Backpressure support

These protocol features form the foundation for the RTL implementation described in the following chapters.