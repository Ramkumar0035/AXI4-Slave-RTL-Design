# Address Generation in AXI4 Full Slave

# 1. Introduction

Address generation is one of the most important functions in an AXI4 Full Slave. During burst transactions, the slave must calculate the memory address for every transfer beat according to the burst type specified by the master.

The AXI4 Full Slave implements a dedicated Address Generator module (`axi_addr_gen`) to calculate the next address for FIXED, INCR, and WRAP burst transfers.

---

# 2. Inputs to the Address Generator

The Address Generator receives the following inputs:

| Signal | Description |
|----------|-------------|
| curr_addr | Current transfer address |
| burst_len | Number of transfers in the burst |
| burst_size | Number of bytes transferred per beat |
| burst_type | Burst mode (FIXED, INCR, WRAP) |

Output:

| Signal | Description |
|----------|-------------|
| next_addr | Address for the next transfer |

---

# 3. Address Increment Calculation

The address increment depends on the transfer size.

```
increment = 1 << burst_size
```

Examples:

| AWSIZE | Bytes per Beat | Increment |
|---------|----------------|-----------|
| 0 | 1 | 1 |
| 1 | 2 | 2 |
| 2 | 4 | 4 |
| 3 | 8 | 8 |
| 4 | 16 | 16 |

For this project,

```
AWSIZE = 2
```

Therefore,

```
increment = 4 bytes
```

---

# 4. FIXED Burst

Burst Type

```
AWBURST = 2'b00
```

In a FIXED burst, the address never changes.

Example

| Beat | Address |
|------|---------|
| 0 | 0x100 |
| 1 | 0x100 |
| 2 | 0x100 |
| 3 | 0x100 |

RTL Operation

```
next_addr = curr_addr;
```

Applications

- Peripheral registers
- FIFOs
- Control registers

---

# 5. INCR Burst

Burst Type

```
AWBURST = 2'b01
```

The address increments after every beat.

RTL Equation

```
next_addr = curr_addr + increment;
```

Example

Start Address

```
0x200
```

Increment

```
4 bytes
```

Address Sequence

| Beat | Address |
|------|---------|
| 0 | 0x200 |
| 1 | 0x204 |
| 2 | 0x208 |
| 3 | 0x20C |

Simulation confirmed the expected address progression during INCR burst verification.

---

# 6. WRAP Burst

Burst Type

```
AWBURST = 2'b10
```

A WRAP burst increments the address until the wrap boundary is reached. Once the boundary is exceeded, the address wraps back to the lower boundary.

---

# 7. Wrap Size Calculation

The total wrap region is

```
wrap_size = increment × (burst_len + 1)
```

Example

```
AWSIZE = 2

increment = 4 bytes

AWLEN = 3

Number of beats = 4
```

Therefore

```
wrap_size = 4 × 4

wrap_size = 16 bytes
```

---

# 8. Wrap Boundary Calculation

The lower boundary is calculated as

```
wrap_boundary = curr_addr & ~(wrap_size - 1)
```

Example

```
Current Address = 0x30C

Wrap Size = 16
```

```
wrap_boundary

= 0x30C & ~(0x0F)

= 0x30C & 0xFFFFFFF0

= 0x300
```

Therefore,

```
Wrap Region

0x300

to

0x30F
```

---

# 9. WRAP Address Sequence

Starting Address

```
0x30C
```

Address progression

| Beat | Address |
|------|---------|
| 0 | 0x30C |
| 1 | 0x300 |
| 2 | 0x304 |
| 3 | 0x308 |

The waveform obtained during simulation matches the expected AXI4 WRAP burst behavior.

---

# 10. RTL Implementation

The Address Generator uses the following algorithm:

```
Calculate increment

↓

Calculate wrap size

↓

Calculate wrap boundary

↓

Check burst type

↓

Generate next address
```

---

# 11. Burst Comparison

| Feature | FIXED | INCR | WRAP |
|----------|-------|-------|------|
| Address Changes | No | Yes | Yes |
| Increment | 0 | Constant | Constant |
| Wrap Boundary | No | No | Yes |
| Primary Use | Registers | Memory | Cache |

---

# 12. Verification Results

The following burst modes were verified during simulation:

✓ FIXED Burst

✓ INCR Burst

✓ WRAP Burst

Observed address sequences matched the expected AXI4 protocol behavior for each burst type.

---

# 13. Conclusion

The Address Generator correctly computes the next transfer address for FIXED, INCR, and WRAP burst modes based on the current address, burst size, burst length, and burst type. Simulation results confirmed that the generated address sequences conform to the AXI4 protocol specification, demonstrating correct implementation of burst address generation.