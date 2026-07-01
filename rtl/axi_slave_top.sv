module axi_slave_top
#(
    parameter ID_WIDTH       = 4,
    parameter ADDR_WIDTH     = 32,
    parameter DATA_WIDTH     = 32,
    parameter MEM_ADDR_WIDTH = 10,
    parameter MEM_DEPTH      = 1024
)
(
    input logic ACLK,
    input logic ARESETn,

    //-------------------------------------------------
    // WRITE ADDRESS CHANNEL
    //-------------------------------------------------

    input  logic [ID_WIDTH-1:0]    S_AXI_AWID,
    input  logic [ADDR_WIDTH-1:0]  S_AXI_AWADDR,
    input  logic [7:0]             S_AXI_AWLEN,
    input  logic [2:0]             S_AXI_AWSIZE,
    input  logic [1:0]             S_AXI_AWBURST,
    input  logic                   S_AXI_AWVALID,
    output logic                   S_AXI_AWREADY,

    //-------------------------------------------------
    // WRITE DATA CHANNEL
    //-------------------------------------------------

    input  logic [DATA_WIDTH-1:0]      S_AXI_WDATA,
    input  logic [(DATA_WIDTH/8)-1:0]  S_AXI_WSTRB,
    input  logic                       S_AXI_WLAST,
    input  logic                       S_AXI_WVALID,
    output logic                       S_AXI_WREADY,

    //-------------------------------------------------
    // WRITE RESPONSE CHANNEL
    //-------------------------------------------------

    output logic [ID_WIDTH-1:0]    S_AXI_BID,
    output logic [1:0]             S_AXI_BRESP,
    output logic                   S_AXI_BVALID,
    input  logic                   S_AXI_BREADY,

    //-------------------------------------------------
    // READ ADDRESS CHANNEL
    //-------------------------------------------------

    input  logic [ID_WIDTH-1:0]    S_AXI_ARID,
    input  logic [ADDR_WIDTH-1:0]  S_AXI_ARADDR,
    input  logic [7:0]             S_AXI_ARLEN,
    input  logic [2:0]             S_AXI_ARSIZE,
    input  logic [1:0]             S_AXI_ARBURST,
    input  logic                   S_AXI_ARVALID,
    output logic                   S_AXI_ARREADY,

    //-------------------------------------------------
    // READ DATA CHANNEL
    //-------------------------------------------------

    output logic [ID_WIDTH-1:0]    S_AXI_RID,
    output logic [DATA_WIDTH-1:0]  S_AXI_RDATA,
    output logic [1:0]             S_AXI_RRESP,
    output logic                   S_AXI_RLAST,
    output logic                   S_AXI_RVALID,
    input  logic                   S_AXI_RREADY
);

/////////////////////////////////////////////////////////
// MEMORY INTERFACE SIGNALS
/////////////////////////////////////////////////////////

logic                        mem_write_en;
logic [ADDR_WIDTH-1:0]       mem_write_addr;
logic [DATA_WIDTH-1:0]       mem_write_data;
logic [(DATA_WIDTH/8)-1:0]   mem_write_strb;

logic                        mem_read_en;
logic [ADDR_WIDTH-1:0]       mem_read_addr;
logic [DATA_WIDTH-1:0]       mem_read_data;

/////////////////////////////////////////////////////////
// WRITE CONTROLLER
/////////////////////////////////////////////////////////

axi_write_controller
#(
    .ADDR_WIDTH (ADDR_WIDTH),
    .DATA_WIDTH (DATA_WIDTH),
    .ID_WIDTH   (ID_WIDTH)
)
WRITE_CTRL
(
    .clk                (ACLK),
    .rst_n              (ARESETn),

    .awid               (S_AXI_AWID),
    .awaddr             (S_AXI_AWADDR),
    .awlen              (S_AXI_AWLEN),
    .awsize             (S_AXI_AWSIZE),
    .awburst            (S_AXI_AWBURST),
    .awvalid            (S_AXI_AWVALID),
    .awready            (S_AXI_AWREADY),

    .wdata              (S_AXI_WDATA),
    .wstrb              (S_AXI_WSTRB),
    .wvalid             (S_AXI_WVALID),
    .wlast              (S_AXI_WLAST),
    .wready             (S_AXI_WREADY),

    .bid                (S_AXI_BID),
    .bresp              (S_AXI_BRESP),
    .bvalid             (S_AXI_BVALID),
    .bready             (S_AXI_BREADY),

    .mem_write_en       (mem_write_en),
    .mem_write_addr     (mem_write_addr),
    .mem_write_data     (mem_write_data),
    .mem_write_strb     (mem_write_strb)
);

/////////////////////////////////////////////////////////
// READ CONTROLLER
/////////////////////////////////////////////////////////

axi_read_controller
#(
    .ADDR_WIDTH (ADDR_WIDTH),
    .DATA_WIDTH (DATA_WIDTH),
    .ID_WIDTH   (ID_WIDTH)
)
READ_CTRL
(
    .clk                (ACLK),
    .rst_n              (ARESETn),

    .arid               (S_AXI_ARID),
    .araddr             (S_AXI_ARADDR),
    .arlen              (S_AXI_ARLEN),
    .arsize             (S_AXI_ARSIZE),
    .arburst            (S_AXI_ARBURST),

    .arvalid            (S_AXI_ARVALID),
    .arready            (S_AXI_ARREADY),

    .rid                (S_AXI_RID),
    .rdata              (S_AXI_RDATA),
    .rresp              (S_AXI_RRESP),
    .rlast              (S_AXI_RLAST),
    .rvalid             (S_AXI_RVALID),
    .rready             (S_AXI_RREADY),

    .mem_read_en        (mem_read_en),
    .mem_read_addr      (mem_read_addr),
    .mem_read_data      (mem_read_data)
);

/////////////////////////////////////////////////////////
// MEMORY
/////////////////////////////////////////////////////////

axi_mem
#(
    .ADDR_WIDTH (MEM_ADDR_WIDTH),
    .DATA_WIDTH (DATA_WIDTH),
    .DEPTH      (MEM_DEPTH)
)
MEM
(
    .clk            (ACLK),
    .rst_n          (ARESETn),

    .write_en       (mem_write_en),

    .write_addr     (
        mem_write_addr[MEM_ADDR_WIDTH-1:0]
    ),

    .write_data     (mem_write_data),

    .write_strb     (mem_write_strb),

    .read_en        (mem_read_en),

    .read_addr      (
        mem_read_addr[MEM_ADDR_WIDTH-1:0]
    ),

    .read_data      (mem_read_data)
);

endmodule