# Test Cases and Verification Results

# 1. Introduction

This document summarizes the functional test cases executed to verify the AXI4 Full Slave RTL implementation. Each test validates a specific protocol feature and confirms correct operation of the design under different transaction scenarios.

---

# 2. Test Environment

Simulation Tool

- ModelSim

Language

- SystemVerilog

Device Under Test

- AXI4 Full Slave RTL

Verification Method

- Self-checking testbench
- Waveform analysis

---

# 3. Test Case Summary

| Test ID | Test Name | Status |
|-----------|-----------------------------|--------|
| TC-01 | Reset Verification | Passed |
| TC-02 | Single Write Transaction | Passed |
| TC-03 | Single Read Transaction | Passed |
| TC-04 | FIXED Burst Write | Passed |
| TC-05 | FIXED Burst Read | Passed |
| TC-06 | INCR Burst Write | Passed |
| TC-07 | INCR Burst Read | Passed |
| TC-08 | WRAP Burst Write | Passed |
| TC-09 | WRAP Burst Read | Passed |
| TC-10 | Multiple Address Transactions | Passed |
| TC-11 | Concurrent Read and Write | Passed |
| TC-12 | Transaction ID Handling | Passed |
| TC-13 | Multiple Outstanding Transactions | Passed |
| TC-14 | Backpressure Handling | Passed |

---

# 4. Detailed Test Cases

## TC-01 Reset Verification

### Objective

Verify correct initialization after reset.

### Procedure

- Assert reset.
- Release reset.
- Observe internal signals.

### Expected Result

- FSM returns to IDLE.
- VALID signals deasserted.
- Counters reset.
- Internal registers initialized.

### Result

Passed

---

## TC-02 Single Write Transaction

### Objective

Verify a single write transfer.

### Procedure

- Send AW transaction.
- Send one WDATA beat.
- Receive BRESP.

### Expected Result

- Data stored correctly.
- BRESP = OKAY.

### Result

Passed

---

## TC-03 Single Read Transaction

### Objective

Verify a single read transfer.

### Procedure

- Send AR transaction.
- Receive one RDATA beat.

### Expected Result

- Returned data matches memory.
- RRESP = OKAY.

### Result

Passed

---

## TC-04 FIXED Burst Write

### Objective

Verify FIXED burst write operation.

### Procedure

- Configure AWBURST = FIXED.
- Perform four write beats.

### Expected Result

- Same memory address accessed for every beat.

### Result

Passed

---

## TC-05 FIXED Burst Read

### Objective

Verify FIXED burst read operation.

### Procedure

- Configure ARBURST = FIXED.
- Perform four read beats.

### Expected Result

- Same address accessed repeatedly.

### Result

Passed

---

## TC-06 INCR Burst Write

### Objective

Verify incrementing burst write.

### Procedure

Start Address

```
0x200
```

Four transfer beats.

### Expected Address Sequence

```
0x200

↓

0x204

↓

0x208

↓

0x20C
```

### Result

Passed

---

## TC-07 INCR Burst Read

### Objective

Verify incrementing burst read.

### Procedure

Read the previously written burst.

### Expected Result

Addresses increment correctly and returned data matches the written values.

### Result

Passed

---

## TC-08 WRAP Burst Write

### Objective

Verify wrapping burst write.

### Procedure

Start Address

```
0x30C
```

Burst Length

```
4 beats
```

### Expected Address Sequence

```
0x30C

↓

0x300

↓

0x304

↓

0x308
```

### Result

Passed

---

## TC-09 WRAP Burst Read

### Objective

Verify wrapping burst read.

### Procedure

Read the previously written wrap burst.

### Expected Result

Returned addresses follow the WRAP sequence and data matches the written values.

### Result

Passed

---

## TC-10 Multiple Address Transactions

### Objective

Verify transactions targeting different memory locations.

### Procedure

Perform independent read/write operations to multiple addresses.

### Expected Result

Each address stores and returns the correct data independently.

### Result

Passed

---

## TC-11 Concurrent Read and Write

### Objective

Verify simultaneous operation of read and write channels.

### Procedure

Issue overlapping read and write transactions.

### Expected Result

Independent read and write channels operate correctly without interference.

### Result

Passed

---

## TC-12 Transaction ID Handling

### Objective

Verify transaction ID propagation.

### Procedure

Issue transactions with different IDs.

### Expected Result

Returned BID and RID match the original transaction IDs.

### Result

Passed

---

## TC-13 Multiple Outstanding Transactions

### Objective

Verify buffering of multiple pending transactions.

### Procedure

Issue multiple transactions before previous responses complete.

### Expected Result

FIFO stores transactions correctly and responses are returned in order.

### Result

Passed

---

## TC-14 Backpressure Handling

### Objective

Verify protocol behavior when READY is deasserted.

### Procedure

Hold:

- AWREADY
- WREADY
- BREADY
- ARREADY
- RREADY

low for multiple cycles.

### Expected Result

- VALID remains asserted.
- Transfer resumes after READY is asserted.
- No data loss occurs.

### Result

Passed

---

# 5. Verification Coverage Summary

The completed verification covers:

- Reset behavior
- VALID/READY handshake
- Single transfers
- FIXED burst
- INCR burst
- WRAP burst
- Address generation
- Memory access
- Read/write data integrity
- Transaction ID handling
- Outstanding transactions
- Backpressure scenarios

---

# 6. Overall Verification Status

| Category | Status |
|-----------|--------|
| Functional Verification | Passed |
| Burst Verification | Passed |
| Address Generation | Passed |
| Memory Verification | Passed |
| Transaction Management | Passed |
| Protocol Handshake | Passed |

---

# 7. Conclusion

All implemented verification scenarios completed successfully. The AXI4 Full Slave RTL correctly handled single transfers, burst transfers, address generation, transaction buffering, and protocol handshaking. These results establish a stable and verified RTL foundation for future AXI4 Verification IP (VIP) development and UVM-based verification.