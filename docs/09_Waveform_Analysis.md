# Waveform Analysis

# 1. Introduction

Waveform analysis was performed using ModelSim to verify the timing and functional behavior of the AXI4 Full Slave RTL. The simulation waveforms confirm proper operation of the AXI4 protocol, including channel handshaking, burst transfers, address generation, transaction sequencing, and response generation.

Each waveform presented in this document corresponds to a specific verification scenario executed during simulation.

---

# 2. Single Write Transaction

## Objective

Verify a single write transaction from the AXI master to the slave.

## Signals Observed

- AWVALID
- AWREADY
- AWADDR
- WVALID
- WREADY
- WDATA
- WLAST
- BVALID
- BREADY
- BRESP

## Waveform Observation

1. The master places the write address on the AW channel.
2. AWVALID and AWREADY are asserted simultaneously, completing the address handshake.
3. The master sends one data beat through the W channel.
4. WVALID and WREADY complete the data transfer.
5. WLAST indicates the final data beat.
6. The slave stores the data into memory.
7. The slave generates a write response (BRESP = OKAY).
8. The transaction completes after the BVALID/BREADY handshake.

## Result

✓ Single write transaction completed successfully.

---

# 3. Single Read Transaction

## Objective

Verify a single read transaction.

## Signals Observed

- ARVALID
- ARREADY
- ARADDR
- RVALID
- RREADY
- RDATA
- RLAST
- RRESP

## Waveform Observation

1. The master sends the read address.
2. ARVALID and ARREADY complete the address handshake.
3. The slave accesses the internal memory.
4. The requested data is returned on the R channel.
5. RLAST is asserted because the transfer contains only one beat.
6. RRESP indicates a successful transfer.

## Result

✓ Read data matched the previously written value.

---

# 4. FIXED Burst Transfer

## Objective

Verify FIXED burst operation.

## Configuration

- Burst Type : FIXED
- Burst Length : 4 Beats
- Transfer Size : 4 Bytes

## Expected Address Sequence

```
0x300

↓

0x300

↓

0x300

↓

0x300
```

## Waveform Observation

- The address remains unchanged throughout the burst.
- Every data beat accesses the same memory location.
- The final beat is indicated by WLAST and RLAST.

## Result

✓ FIXED burst behavior matches the AXI4 protocol specification.

---

# 5. INCR Burst Transfer

## Objective

Verify incrementing burst operation.

## Configuration

- Burst Type : INCR
- Burst Length : 4 Beats
- Transfer Size : 4 Bytes

## Expected Address Sequence

```
0x200

↓

0x204

↓

0x208

↓

0x20C
```

## Waveform Observation

The waveform shows the address incrementing by four bytes after every successful transfer.

Observed address sequence:

```
0x200

↓

0x204

↓

0x208

↓

0x20C
```

The returned data matched the values written during the burst transaction.

## Result

✓ INCR burst verified successfully.

---

# 6. WRAP Burst Transfer

## Objective

Verify wrapping burst operation.

## Configuration

- Start Address : 0x30C
- Burst Length : 4 Beats
- Transfer Size : 4 Bytes

## Calculated Wrap Boundary

```
0x300
```

## Expected Address Sequence

```
0x30C

↓

0x300

↓

0x304

↓

0x308
```

## Waveform Observation

The waveform confirms that:

- The first transfer occurs at 0x30C.
- The address wraps to 0x300 after reaching the boundary.
- The remaining transfers continue sequentially.

Observed sequence:

```
0x30C

↓

0x300

↓

0x304

↓

0x308
```

The data returned from memory matches the expected values.

## Result

✓ WRAP burst verified successfully.

---

# 7. Multiple Address Transactions

## Objective

Verify access to different memory locations.

## Waveform Observation

Multiple write transactions are issued to different addresses, followed by corresponding read transactions.

The waveform confirms:

- Independent memory locations are accessed correctly.
- Data integrity is maintained across all addresses.
- No corruption occurs between transactions.

## Result

✓ Multiple address transactions verified successfully.

---

# 8. Concurrent Read and Write

## Objective

Verify simultaneous read and write channel operation.

## Waveform Observation

The read and write channels operate independently.

The waveform shows:

- Read transactions progressing while write transactions are active.
- Independent VALID/READY handshakes.
- No protocol conflicts between channels.

## Result

✓ Concurrent read and write operation verified.

---

# 9. Transaction ID Verification

## Objective

Verify correct handling of AXI transaction IDs.

## Waveform Observation

Transactions with different IDs are issued.

The waveform confirms:

- AWID is correctly propagated to BID.
- ARID is correctly propagated to RID.
- Responses correspond to the correct transaction.

## Result

✓ Transaction ID handling verified.

---

# 10. Multiple Outstanding Transactions

## Objective

Verify handling of multiple pending transactions.

## Waveform Observation

Multiple transactions are issued before previous responses complete.

The waveform confirms:

- Transactions are buffered correctly.
- FIFO maintains transaction order.
- Responses are returned correctly.

## Result

✓ Multiple outstanding transactions verified.

---

# 11. Backpressure Verification

## Objective

Verify protocol behavior during backpressure.

## Waveform Observation

READY signals are intentionally deasserted.

The waveform confirms:

- VALID remains asserted.
- Transfers pause without data loss.
- Transactions resume correctly when READY is asserted.

## Result

✓ Backpressure handling verified successfully.

---

# 12. Overall Verification Summary

| Verification Item | Status |
|-------------------|--------|
| Single Write | Passed |
| Single Read | Passed |
| FIXED Burst | Passed |
| INCR Burst | Passed |
| WRAP Burst | Passed |
| Multiple Address | Passed |
| Concurrent Read/Write | Passed |
| Transaction ID | Passed |
| Outstanding Transactions | Passed |
| Backpressure | Passed |

---

# 13. Conclusion

Waveform analysis confirms that the AXI4 Full Slave RTL operates according to the AXI4 protocol specification. All implemented features—including single transfers, burst transfers, address generation, transaction handling, and protocol handshaking—were successfully validated through simulation. The observed timing relationships and signal behavior demonstrate correct RTL functionality and provide confidence for future integration with an AXI4 Verification IP (VIP) environment.