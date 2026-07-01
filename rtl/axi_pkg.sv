
package axi_pkg;

parameter int AXI_ADDR_WIDTH = 32;
parameter int AXI_DATA_WIDTH = 32;
parameter int AXI_ID_WIDTH   = 4;

typedef enum logic [1:0]
{
    AXI_FIXED = 2'b00,
    AXI_INCR  = 2'b01,
    AXI_WRAP  = 2'b10
} axi_burst_t;

typedef enum logic [1:0]
{
    AXI_OKAY   = 2'b00,
    AXI_EXOKAY = 2'b01,
    AXI_SLVERR = 2'b10,
    AXI_DECERR = 2'b11
} axi_resp_t;

typedef struct packed
{
    logic [AXI_ID_WIDTH-1:0]   id;
    logic [AXI_ADDR_WIDTH-1:0] addr;
    logic [7:0]                len;
    logic [2:0]                size;
    logic [1:0]                burst;
} axi_write_txn_t;

typedef struct packed
{
    logic [AXI_ID_WIDTH-1:0]   id;
    logic [AXI_ADDR_WIDTH-1:0] addr;
    logic [7:0]                len;
    logic [2:0]                size;
    logic [1:0]                burst;
} axi_read_txn_t;

endpackage