# AXI4 Full Slave System Architecture

# 1. Introduction

The AXI4 Full Slave is designed using a modular architecture in which each major protocol function is implemented as an independent RTL module. This approach improves readability, simplifies debugging, enables module-level verification, and allows future feature extensions with minimal impact on the existing design.

The slave interfaces with an AXI4 master through the five AXI channels while internally coordinating address processing, data movement, response generation, and memory access.

---

# 2. Top-Level Architecture

```
                     +----------------------+
                     |      AXI MASTER      |
                     +----------------------+
                              |
        --------------------------------------------------
        |        |        |        |                    |
       AW       W        B       AR                    R
        |        |        |        |                    |
        +--------+--------+--------+--------------------+
                              |
                    +----------------------+
                    |    AXI SLAVE TOP     |
                    +----------------------+
                              |
      ------------------------------------------------------------
      |            |             |             |                  |
      |            |             |             |                  |
 Write Ctrl   Read Ctrl   Transaction FIFO  Address Gen   Response Gen
      |            |             |             |                  |
      ------------------------------------------------------------
                              |
                  Alignment / Boundary Checkers
                              |
                       Transaction ID Tracker
                              |
                         Internal Memory
```

---

# 3. Top-Level Module

The `axi_slave_top` module acts as the integration point for all RTL modules.

Its responsibilities include:

- Receiving AXI interface signals
- Connecting read and write controllers
- Interfacing with internal memory
- Coordinating transaction flow
- Returning protocol responses

---

# 4. Write Path

The write channel processes incoming write transactions through three AXI channels.

### Step 1

The master sends the write address on the AW channel.

Information received includes:

- AWID
- AWADDR
- AWLEN
- AWSIZE
- AWBURST

---

### Step 2

The write controller stores the transaction information inside the transaction FIFO until it is ready to process the request.

---

### Step 3

The write data is received through the W channel.

Each beat contains:

- WDATA
- WSTRB
- WLAST

---

### Step 4

The write controller generates the target memory address using the Address Generator.

---

### Step 5

The memory module stores the received data.

---

### Step 6

The Response Generator creates the BRESP signal.

---

### Step 7

The slave returns:

- BID
- BRESP
- BVALID

to complete the write transaction.

---

# 5. Read Path

The read channel operates independently of the write channel.

### Step 1

The master issues:

- ARID
- ARADDR
- ARLEN
- ARSIZE
- ARBURST

---

### Step 2

The read transaction is stored in the transaction FIFO.

---

### Step 3

The Read Controller calculates the memory address using the Address Generator.

---

### Step 4

The memory module reads the requested data.

---

### Step 5

The Response Generator determines the response status.

---

### Step 6

The slave returns:

- RID
- RDATA
- RRESP
- RLAST
- RVALID

for every burst beat.

---

# 6. Internal Data Flow

The internal transaction flow is illustrated below.

```
Master

   |

Write Address
   |

Transaction FIFO

   |

Write Controller

   |

Address Generator

   |

Memory

   |

Response Generator

   |

B Channel
```

Read flow

```
Master

   |

Read Address

   |

Transaction FIFO

   |

Read Controller

   |

Address Generator

   |

Memory

   |

Response Generator

   |

R Channel
```

---

# 7. Major RTL Modules

| Module | Function |
|----------|----------|
| axi_slave_top | Top-level integration module |
| axi_write_controller | Controls write transactions |
| axi_read_controller | Controls read transactions |
| axi_transaction_fifo | Buffers pending transactions |
| axi_addr_gen | Generates burst addresses |
| axi_mem | Internal storage memory |
| axi_alignment_checker | Detects address alignment errors |
| axi_boundary_checker | Detects burst boundary violations |
| axi_resp_gen | Generates AXI response signals |
| axi_id_tracker *(if implemented)* | Tracks transaction IDs |

---

# 8. Design Characteristics

The RTL architecture provides:

- Modular implementation
- Parameterizable data width
- Parameterizable address width
- Independent read and write paths
- Burst address generation
- Internal transaction buffering
- Protocol compliance through dedicated checker modules
- Easy scalability for future AXI features

---

# 9. Future Architectural Enhancements

The current architecture forms the foundation for future verification and protocol extensions.

Planned additions include:

- AXI4 Master RTL
- UVM-based Master Agent
- UVM-based Slave Agent
- Protocol assertions
- Functional coverage
- Random traffic generation
- Error injection
- Automated regression environment

---

# 10. Conclusion

The modular organization of the AXI4 Full Slave separates protocol handling, memory access, address generation, response generation, and transaction management into dedicated RTL modules. This improves maintainability, simplifies verification, and provides a stable foundation for future AXI4 VIP development.