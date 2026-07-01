`timescale 1ns/1ps

module tb_axi_slave_smoke;

/////////////////////////////////////////////////////////
// PARAMETERS
/////////////////////////////////////////////////////////

localparam ID_WIDTH   = 4;
localparam ADDR_WIDTH = 32;
localparam DATA_WIDTH = 32;

/////////////////////////////////////////////////////////
// CLOCK / RESET
/////////////////////////////////////////////////////////

logic ACLK;
logic ARESETn;

initial
begin
    ACLK = 0;
    forever #5 ACLK = ~ACLK;
end

/////////////////////////////////////////////////////////
// WRITE ADDRESS CHANNEL
/////////////////////////////////////////////////////////

logic [ID_WIDTH-1:0]   S_AXI_AWID;
logic [ADDR_WIDTH-1:0] S_AXI_AWADDR;
logic [7:0]            S_AXI_AWLEN;
logic [2:0]            S_AXI_AWSIZE;
logic [1:0]            S_AXI_AWBURST;
logic                  S_AXI_AWVALID;
logic                  S_AXI_AWREADY;

/////////////////////////////////////////////////////////
// WRITE DATA CHANNEL
/////////////////////////////////////////////////////////

logic [DATA_WIDTH-1:0]     S_AXI_WDATA;
logic [(DATA_WIDTH/8)-1:0] S_AXI_WSTRB;
logic                      S_AXI_WLAST;
logic                      S_AXI_WVALID;
logic                      S_AXI_WREADY;

/////////////////////////////////////////////////////////
// WRITE RESPONSE CHANNEL
/////////////////////////////////////////////////////////

logic [ID_WIDTH-1:0] S_AXI_BID;
logic [1:0]          S_AXI_BRESP;
logic                S_AXI_BVALID;
logic                S_AXI_BREADY;

/////////////////////////////////////////////////////////
// READ ADDRESS CHANNEL
/////////////////////////////////////////////////////////

logic [ID_WIDTH-1:0]   S_AXI_ARID;
logic [ADDR_WIDTH-1:0] S_AXI_ARADDR;
logic [7:0]            S_AXI_ARLEN;
logic [2:0]            S_AXI_ARSIZE;
logic [1:0]            S_AXI_ARBURST;
logic                  S_AXI_ARVALID;
logic                  S_AXI_ARREADY;

/////////////////////////////////////////////////////////
// READ DATA CHANNEL
/////////////////////////////////////////////////////////

logic [ID_WIDTH-1:0]   S_AXI_RID;
logic [DATA_WIDTH-1:0] S_AXI_RDATA;
logic [1:0]            S_AXI_RRESP;
logic                  S_AXI_RLAST;
logic                  S_AXI_RVALID;
logic                  S_AXI_RREADY;

/////////////////////////////////////////////////////////
// DUT
/////////////////////////////////////////////////////////

axi_slave_top DUT
(
    .ACLK           (ACLK),
    .ARESETn        (ARESETn),

    .S_AXI_AWID     (S_AXI_AWID),
    .S_AXI_AWADDR   (S_AXI_AWADDR),
    .S_AXI_AWLEN    (S_AXI_AWLEN),
    .S_AXI_AWSIZE   (S_AXI_AWSIZE),
    .S_AXI_AWBURST  (S_AXI_AWBURST),
    .S_AXI_AWVALID  (S_AXI_AWVALID),
    .S_AXI_AWREADY  (S_AXI_AWREADY),

    .S_AXI_WDATA    (S_AXI_WDATA),
    .S_AXI_WSTRB    (S_AXI_WSTRB),
    .S_AXI_WLAST    (S_AXI_WLAST),
    .S_AXI_WVALID   (S_AXI_WVALID),
    .S_AXI_WREADY   (S_AXI_WREADY),

    .S_AXI_BID      (S_AXI_BID),
    .S_AXI_BRESP    (S_AXI_BRESP),
    .S_AXI_BVALID   (S_AXI_BVALID),
    .S_AXI_BREADY   (S_AXI_BREADY),

    .S_AXI_ARID     (S_AXI_ARID),
    .S_AXI_ARADDR   (S_AXI_ARADDR),
    .S_AXI_ARLEN    (S_AXI_ARLEN),
    .S_AXI_ARSIZE   (S_AXI_ARSIZE),
    .S_AXI_ARBURST  (S_AXI_ARBURST),
    .S_AXI_ARVALID  (S_AXI_ARVALID),
    .S_AXI_ARREADY  (S_AXI_ARREADY),

    .S_AXI_RID      (S_AXI_RID),
    .S_AXI_RDATA    (S_AXI_RDATA),
    .S_AXI_RRESP    (S_AXI_RRESP),
    .S_AXI_RLAST    (S_AXI_RLAST),
    .S_AXI_RVALID   (S_AXI_RVALID),
    .S_AXI_RREADY   (S_AXI_RREADY)
);

/////////////////////////////////////////////////////////
// RESET
/////////////////////////////////////////////////////////

task reset_dut;
begin

    ARESETn = 0;

    S_AXI_AWVALID = 0;
    S_AXI_WVALID  = 0;
    S_AXI_BREADY  = 0;

    S_AXI_ARVALID = 0;
    S_AXI_RREADY  = 0;

    repeat(10) @(posedge ACLK);

    ARESETn = 1;

    repeat(5) @(posedge ACLK);

end
endtask

/////////////////////////////////////////////////////////
// SINGLE WRITE
/////////////////////////////////////////////////////////

task axi_single_write
(
    input [31:0] addr,
    input [31:0] data
);
begin

    @(posedge ACLK);

    S_AXI_AWID     <= 0;
    S_AXI_AWADDR   <= addr;
    S_AXI_AWLEN    <= 0;
    S_AXI_AWSIZE   <= 3'd2;
    S_AXI_AWBURST  <= 2'b01;
    S_AXI_AWVALID  <= 1;

    wait(S_AXI_AWREADY);

    @(posedge ACLK);
    S_AXI_AWVALID <= 0;

    S_AXI_WDATA   <= data;
    S_AXI_WSTRB   <= 4'hF;
    S_AXI_WLAST   <= 1;
    S_AXI_WVALID  <= 1;

    wait(S_AXI_WREADY);

    @(posedge ACLK);

    S_AXI_WVALID <= 0;

    S_AXI_BREADY <= 1;

    wait(S_AXI_BVALID);

    @(posedge ACLK);

    S_AXI_BREADY <= 0;

    $display("WRITE DONE ADDR=%h DATA=%h",addr,data);

end
endtask

task axi_single_write_id
(
    input [ID_WIDTH-1:0]  id,
    input [31:0] addr,
    input [31:0] data
);

begin

    @(posedge ACLK);

    //-----------------------------
    // AW CHANNEL
    //-----------------------------
    S_AXI_AWID    <= id;
    S_AXI_AWADDR  <= addr;
    S_AXI_AWLEN   <= 0;
    S_AXI_AWSIZE  <= 3'd2;
    S_AXI_AWBURST <= 2'b01;
    S_AXI_AWVALID <= 1;

    wait(S_AXI_AWREADY);

    @(posedge ACLK);

    S_AXI_AWVALID <= 0;

    //-----------------------------
    // W CHANNEL
    //-----------------------------
    S_AXI_WDATA   <= data;
    S_AXI_WSTRB   <= 4'hF;
    S_AXI_WLAST   <= 1'b1;
    S_AXI_WVALID  <= 1'b1;

    wait(S_AXI_WREADY);

    @(posedge ACLK);

    S_AXI_WVALID <= 0;

    //-----------------------------
    // B CHANNEL
    //-----------------------------
    S_AXI_BREADY <= 1'b1;

    wait(S_AXI_BVALID);

    $display("");
    $display("=================================");
    $display("WRITE ID TEST");
    $display("=================================");
    $display("AWID SENT : %0d", id);
    $display("BID  RECV : %0d", S_AXI_BID);

    if(S_AXI_BID == id)
        $display("WRITE ID PASS");
    else
        $display("WRITE ID FAIL");

    @(posedge ACLK);

    S_AXI_BREADY <= 1'b0;

end
endtask

task axi_send_aw_only
(
    input [ID_WIDTH-1:0] id,
    input [31:0] addr
);

begin

    @(posedge ACLK);

    S_AXI_AWID    <= id;
    S_AXI_AWADDR  <= addr;
    S_AXI_AWLEN   <= 0;
    S_AXI_AWSIZE  <= 3'd2;
    S_AXI_AWBURST <= 2'b01;
    S_AXI_AWVALID <= 1'b1;

    wait(S_AXI_AWREADY);

    @(posedge ACLK);

    S_AXI_AWVALID <= 1'b0;

    $display("AW ACCEPTED : ID=%0d ADDR=%h",id,addr);

end

endtask

task axi_send_w_only
(
    input [31:0] data
);

begin

    @(posedge ACLK);

    S_AXI_WDATA  <= data;
    S_AXI_WSTRB  <= 4'hF;
    S_AXI_WLAST  <= 1'b1;
    S_AXI_WVALID <= 1'b1;

    wait(S_AXI_WREADY);

    @(posedge ACLK);

    S_AXI_WVALID <= 1'b0;

    S_AXI_BREADY <= 1'b1;

    wait(S_AXI_BVALID);

    $display("WRITE COMPLETE : BID=%0d DATA=%h",
             S_AXI_BID,
             data);

    @(posedge ACLK);

    S_AXI_BREADY <= 1'b0;

end

endtask


task axi_send_w_only_B
(
    input [31:0] data
);

begin

    @(posedge ACLK);

    S_AXI_WDATA  <= data;
    S_AXI_WSTRB  <= 4'hF;
    S_AXI_WLAST  <= 1'b1;
    S_AXI_WVALID <= 1'b1;

    wait(S_AXI_WREADY);

    @(posedge ACLK);

    S_AXI_WVALID <= 1'b0;

    //--------------------------------------------------
    // WRITE BACKPRESSURE
    //--------------------------------------------------

    S_AXI_BREADY <= 1'b0;

    wait(S_AXI_BVALID);

    $display("WRITE BACKPRESSURE : BVALID asserted, holding BREADY LOW");

    repeat(5)
        @(posedge ACLK);

    S_AXI_BREADY <= 1'b1;

    @(posedge ACLK);

    $display("WRITE COMPLETE : BID=%0d DATA=%h",
             S_AXI_BID,
             data);

    S_AXI_BREADY <= 1'b0;

end

endtask
/////////////////////////////////////////////////////////
// SINGLE READ
/////////////////////////////////////////////////////////

task axi_single_read
(
    input  [31:0] addr,
    output [31:0] data
);
begin

    @(posedge ACLK);

    S_AXI_ARID     <= 0;
    S_AXI_ARADDR   <= addr;
    S_AXI_ARLEN    <= 0;
    S_AXI_ARSIZE   <= 3'd2;
    S_AXI_ARBURST  <= 2'b01;
    S_AXI_ARVALID  <= 1;

    wait(S_AXI_ARREADY);

    @(posedge ACLK);

    S_AXI_ARVALID <= 0;

    S_AXI_RREADY  <= 1;

    wait(S_AXI_RVALID);

    data = S_AXI_RDATA;

    @(posedge ACLK);

    S_AXI_RREADY <= 0;

    $display("READ DONE ADDR=%h DATA=%h",addr,data);

end
endtask

task axi_single_read_id
(
    input  [ID_WIDTH-1:0]  id,
    input  [31:0] addr,
    output [31:0] data
);

begin

    @(posedge ACLK);

    //-----------------------------
    // AR CHANNEL
    //-----------------------------
    S_AXI_ARID    <= id;
    S_AXI_ARADDR  <= addr;
    S_AXI_ARLEN   <= 0;
    S_AXI_ARSIZE  <= 3'd2;
    S_AXI_ARBURST <= 2'b01;
    S_AXI_ARVALID <= 1'b1;

    wait(S_AXI_ARREADY);

    @(posedge ACLK);

    S_AXI_ARVALID <= 0;

    //-----------------------------
    // R CHANNEL
    //-----------------------------
    S_AXI_RREADY <= 1'b1;

    wait(S_AXI_RVALID);

    data = S_AXI_RDATA;

    $display("");
    $display("=================================");
    $display("READ ID TEST");
    $display("=================================");
    $display("ARID SENT : %0d", id);
    $display("RID  RECV : %0d", S_AXI_RID);
    $display("RDATA     : %h", S_AXI_RDATA);

    if(S_AXI_RID == id)
        $display("READ ID PASS");
    else
        $display("READ ID FAIL");

    @(posedge ACLK);

    S_AXI_RREADY <= 1'b0;

end

endtask

task axi_single_read_id_B
(
    input  [ID_WIDTH-1:0] id,
    input  [31:0]         addr,
    output [31:0]         data
);

begin

    @(posedge ACLK);

    S_AXI_ARID    <= id;
    S_AXI_ARADDR  <= addr;
    S_AXI_ARLEN   <= 0;
    S_AXI_ARSIZE  <= 3'd2;
    S_AXI_ARBURST <= 2'b01;
    S_AXI_ARVALID <= 1'b1;

    wait(S_AXI_ARREADY);

    @(posedge ACLK);

    S_AXI_ARVALID <= 1'b0;

    //--------------------------------------------------
    // READ BACKPRESSURE
    //--------------------------------------------------

    S_AXI_RREADY <= 1'b0;

    wait(S_AXI_RVALID);

    $display("READ BACKPRESSURE : RVALID asserted, holding RREADY LOW");

    repeat(5)
        @(posedge ACLK);

    S_AXI_RREADY <= 1'b1;

    @(posedge ACLK);

    data = S_AXI_RDATA;

    $display("READ COMPLETE : RID=%0d DATA=%h",
             S_AXI_RID,
             data);

    S_AXI_RREADY <= 1'b0;

end

endtask

task axi_fixed_write;

input [31:0] addr;
input [7:0]  len;

input [31:0] data0;
input [31:0] data1;
input [31:0] data2;
input [31:0] data3;

begin

    @(posedge ACLK);

    S_AXI_AWID    <= 0;
    S_AXI_AWADDR  <= addr;
    S_AXI_AWLEN   <= len;
    S_AXI_AWSIZE  <= 3'd2;
    S_AXI_AWBURST <= 2'b00;
    S_AXI_AWVALID <= 1;

    wait(S_AXI_AWREADY);

    @(posedge ACLK);

    S_AXI_AWVALID <= 0;

    S_AXI_WSTRB  <= 4'hF;
    S_AXI_WVALID <= 1;

    S_AXI_WDATA <= data0;
    S_AXI_WLAST <= 0;

    wait(S_AXI_WREADY);
    @(posedge ACLK);

    S_AXI_WDATA <= data1;

    wait(S_AXI_WREADY);
    @(posedge ACLK);

    S_AXI_WDATA <= data2;

    wait(S_AXI_WREADY);
    @(posedge ACLK);

    S_AXI_WDATA <= data3;
    S_AXI_WLAST <= 1;

    wait(S_AXI_WREADY);
    @(posedge ACLK);

    S_AXI_WVALID <= 0;
    S_AXI_WLAST  <= 0;

    S_AXI_BREADY <= 1;

    wait(S_AXI_BVALID);

    @(posedge ACLK);

    S_AXI_BREADY <= 0;

end

endtask
task axi_burst_write;

input [31:0] addr;
input [7:0]  len;

input [31:0] data0;
input [31:0] data1;
input [31:0] data2;
input [31:0] data3;

begin

    @(posedge ACLK);

    S_AXI_AWID    <= 0;
    S_AXI_AWADDR  <= addr;
    S_AXI_AWLEN   <= len;
    S_AXI_AWSIZE  <= 3'd2;
    S_AXI_AWBURST <= 2'b01;
    S_AXI_AWVALID <= 1;

    wait(S_AXI_AWREADY);

    @(posedge ACLK);

    S_AXI_AWVALID <= 0;

    S_AXI_WSTRB  <= 4'hF;
    S_AXI_WVALID <= 1;

    S_AXI_WDATA <= data0;
    S_AXI_WLAST <= 0;

    wait(S_AXI_WREADY);
    @(posedge ACLK);

    S_AXI_WDATA <= data1;

    wait(S_AXI_WREADY);
    @(posedge ACLK);

    S_AXI_WDATA <= data2;

    wait(S_AXI_WREADY);
    @(posedge ACLK);

    S_AXI_WDATA <= data3;
    S_AXI_WLAST <= 1;

    wait(S_AXI_WREADY);
    @(posedge ACLK);

    S_AXI_WVALID <= 0;
    S_AXI_WLAST  <= 0;

    S_AXI_BREADY <= 1;

    wait(S_AXI_BVALID);

    @(posedge ACLK);

    S_AXI_BREADY <= 0;

end

endtask
task axi_wrap_write;

input [31:0] addr;
input [7:0]  len;

input [31:0] data0;
input [31:0] data1;
input [31:0] data2;
input [31:0] data3;

begin

    @(posedge ACLK);

    S_AXI_AWID    <= 0;
    S_AXI_AWADDR  <= addr;
    S_AXI_AWLEN   <= len;
    S_AXI_AWSIZE  <= 3'd2;
    S_AXI_AWBURST <= 2'b10;
    S_AXI_AWVALID <= 1;

    wait(S_AXI_AWREADY);

    @(posedge ACLK);

    S_AXI_AWVALID <= 0;

    S_AXI_WSTRB  <= 4'hF;
    S_AXI_WVALID <= 1;

    S_AXI_WDATA <= data0;
    S_AXI_WLAST <= 0;

    wait(S_AXI_WREADY);
    @(posedge ACLK);

    S_AXI_WDATA <= data1;

    wait(S_AXI_WREADY);
    @(posedge ACLK);

    S_AXI_WDATA <= data2;

    wait(S_AXI_WREADY);
    @(posedge ACLK);

    S_AXI_WDATA <= data3;
    S_AXI_WLAST <= 1;

    wait(S_AXI_WREADY);
    @(posedge ACLK);

    S_AXI_WVALID <= 0;
    S_AXI_WLAST  <= 0;

    S_AXI_BREADY <= 1;

    wait(S_AXI_BVALID);

    @(posedge ACLK);

    S_AXI_BREADY <= 0;

end

endtask
task axi_fixed_read;

input [31:0] addr;
input [7:0]  len;

integer i;

begin

    @(posedge ACLK);

    S_AXI_ARID    <= 0;
    S_AXI_ARADDR  <= addr;
    S_AXI_ARLEN   <= len;
    S_AXI_ARSIZE  <= 3'd2;
    S_AXI_ARBURST <= 2'b00;
    S_AXI_ARVALID <= 1;

    wait(S_AXI_ARREADY);

    @(posedge ACLK);

    S_AXI_ARVALID <= 0;

    S_AXI_RREADY <= 1;

    for(i=0;i<=len;i=i+1)
    begin

        wait(S_AXI_RVALID);

        case(i)

    0:
        if(S_AXI_RDATA !== 32'h44444444)
            $error("Beat0 mismatch");

    1:
        if(S_AXI_RDATA !== 32'h44444444)
            $error("Beat1 mismatch");

    2:
        if(S_AXI_RDATA !== 32'h44444444)
            $error("Beat2 mismatch");

    3:
        if(S_AXI_RDATA !== 32'h44444444)
            $error("Beat3 mismatch");

endcase

        $display("READ DATA = %h", S_AXI_RDATA);

        wait(!S_AXI_RVALID);

    end

    S_AXI_RREADY <= 0;

end

endtask
task axi_burst_read;

input [31:0] addr;
input [7:0]  len;

integer i;

begin

    @(posedge ACLK);

    S_AXI_ARID    <= 0;
    S_AXI_ARADDR  <= addr;
    S_AXI_ARLEN   <= len;
    S_AXI_ARSIZE  <= 3'd2;
    S_AXI_ARBURST <= 2'b01;
    S_AXI_ARVALID <= 1;

    wait(S_AXI_ARREADY);

    @(posedge ACLK);

    S_AXI_ARVALID <= 0;

    S_AXI_RREADY <= 1;

    for(i=0;i<=len;i=i+1)
    begin

        wait(S_AXI_RVALID);

        case(i)

            0:
            begin
                if(S_AXI_RDATA !== 32'hAAAA1111)
                    $error("Beat0 mismatch");
            end

            1:
            begin
                if(S_AXI_RDATA !== 32'hBBBB2222)
                    $error("Beat1 mismatch");
            end

            2:
            begin
                if(S_AXI_RDATA !== 32'hCCCC3333)
                    $error("Beat2 mismatch");
            end

            3:
            begin
                if(S_AXI_RDATA !== 32'hDDDD4444)
                    $error("Beat3 mismatch");
            end

        endcase

        $display("READ DATA = %h", S_AXI_RDATA);

        wait(!S_AXI_RVALID);

    end

    S_AXI_RREADY <= 0;

end

endtask

task axi_wrap_read;

input [31:0] addr;
input [7:0]  len;

integer i;

begin

    @(posedge ACLK);

    S_AXI_ARID    <= 0;
    S_AXI_ARADDR  <= addr;
    S_AXI_ARLEN   <= len;
    S_AXI_ARSIZE  <= 3'd2;
    S_AXI_ARBURST <= 2'b10;
    S_AXI_ARVALID <= 1;

    wait(S_AXI_ARREADY);

    @(posedge ACLK);

    S_AXI_ARVALID <= 0;

    S_AXI_RREADY <= 1;

    for(i=0;i<=len;i=i+1)
    begin

        wait(S_AXI_RVALID);

        case(i)

0:
begin
    if(S_AXI_RDATA !== 32'h11111111)
        $error("Beat0 mismatch");
end

1:
begin
    if(S_AXI_RDATA !== 32'h22222222)
        $error("Beat1 mismatch");
end

2:
begin
    if(S_AXI_RDATA !== 32'h33333333)
        $error("Beat2 mismatch");
end

3:
begin
    if(S_AXI_RDATA !== 32'h44444444)
        $error("Beat3 mismatch");
end

endcase

        $display("READ DATA = %h", S_AXI_RDATA);

        wait(!S_AXI_RVALID);

    end

    S_AXI_RREADY <= 0;

end

endtask


/////////////////////////////////////////////////////////
// OUTSTANDING AW ONLY TEST
/////////////////////////////////////////////////////////

task axi_push_aw_only
(
    input [3:0] id,
    input [31:0] addr
);
begin
    @(posedge ACLK);
    S_AXI_AWID    <= id;
    S_AXI_AWADDR  <= addr;
    S_AXI_AWLEN   <= 0;
    S_AXI_AWSIZE  <= 3'd2;
    S_AXI_AWBURST <= 2'b01;
    S_AXI_AWVALID <= 1;

    wait(S_AXI_AWREADY);

    @(posedge ACLK);
    S_AXI_AWVALID <= 0;

    $display("AW PUSHED ID=%0d ADDR=%h", id, addr);
end
endtask

/////////////////////////////////////////////////////////
// TEST
/////////////////////////////////////////////////////////

logic [31:0] rd_data;

initial
begin

    reset_dut();

    //--------------------------------------------------
    // SINGLE WRITE/READ
    //--------------------------------------------------

    axi_single_write
    (
        32'h00000100,
        32'h12345678
    );

    axi_single_read
    (
        32'h00000100,
        rd_data
    );

    if(rd_data == 32'h12345678)
    begin
        $display("--------------------------------");
        $display("SINGLE TEST PASSED");
        $display("--------------------------------");
    end
    else
    begin
        $display("--------------------------------");
        $display("SINGLE TEST FAILED");
        $display("--------------------------------");
    end
axi_fixed_write
(
    32'h00000300,
    8'd3,

    32'h11111111,
    32'h22222222,
    32'h33333333,
    32'h44444444
);

axi_fixed_read
(
    32'h00000300,
    8'd3
);
    //--------------------------------------------------
    // BURST WRITE
    //--------------------------------------------------

    axi_burst_write
    (
        32'h00000200,
        8'd3,

        32'hAAAA1111,
        32'hBBBB2222,
        32'hCCCC3333,
        32'hDDDD4444
    );

    //--------------------------------------------------
    // BURST READ
    //--------------------------------------------------

    axi_burst_read
    (
        32'h00000200,
        8'd3
    );

axi_wrap_write
(
    32'h0000030C,
    8'd3,
    32'h11111111,
    32'h22222222,
    32'h33333333,
    32'h44444444
);
axi_wrap_read
(
    32'h0000030C,
    8'd3
);



//---------------------------
// Verification
//---------------------------

$display("");
$display("================================");
$display(" MULTIPLE ADDRESS WRITE TEST");
$display("================================");

axi_single_write(32'h10, 32'h11111111);
axi_single_write(32'h20, 32'h22222222);
axi_single_write(32'h30, 32'h33333333);

axi_single_read(32'h10, rd_data);
if(rd_data == 32'h11111111)
    $display("ADDR1 PASS");
else
    $display("ADDR1 FAIL");

axi_single_read(32'h20, rd_data);
if(rd_data == 32'h22222222)
    $display("ADDR2 PASS");
else
    $display("ADDR2 FAIL");

axi_single_read(32'h30, rd_data);
if(rd_data == 32'h33333333)
    $display("ADDR3 PASS");
else
    $display("ADDR3 FAIL");

$display("");
$display("================================");
$display(" CONCURRENT READ WRITE TEST");
$display("================================");

fork

begin
    axi_single_write_id
    (
        4'd7,
        32'h4000,
        32'hAAAAAAAA
    );
end

begin
    axi_single_read
    (
        32'h10,
        rd_data
    );
end

join

$display("CONCURRENT TEST COMPLETED");

$display("");
$display("================================");
$display(" TRANSACTION ID TEST");
$display("================================");

axi_single_write_id(4'd1, 32'h100, 32'h11111111);
axi_single_write_id(4'd5, 32'h200, 32'h22222222);
axi_single_write_id(4'd9, 32'h300, 32'h33333333);

axi_single_read_id(4'd1, 32'h100, rd_data);
axi_single_read_id(4'd5, 32'h200, rd_data);
axi_single_read_id(4'd9, 32'h300, rd_data);

$display("TRANSACTION ID TEST COMPLETED");



$display("");
$display("======================================");
$display(" MULTIPLE OUTSTANDING WRITE+READ TEST ");
$display("======================================");

//--------------------------------------------------
// STEP 1 : Send 3 AW requests
//--------------------------------------------------

axi_send_aw_only(4'd1, 32'h00000010);
axi_send_aw_only(4'd2, 32'h00000020);
axi_send_aw_only(4'd3, 32'h00000030);

repeat(5) @(posedge ACLK);

//--------------------------------------------------
// STEP 2 : Send corresponding write data
//--------------------------------------------------

axi_send_w_only(32'h11111111);

axi_send_w_only(32'h22222222);

axi_send_w_only(32'h33333333);

repeat(5) @(posedge ACLK);

//--------------------------------------------------
// STEP 3 : Read back and verify
//--------------------------------------------------

axi_single_read_id(4'd1, 32'h00000010, rd_data);

if (rd_data == 32'h11111111)
    $display("READ1 PASS");
else
    $display("READ1 FAIL");

axi_single_read_id(4'd2, 32'h00000020, rd_data);

if (rd_data == 32'h22222222)
    $display("READ2 PASS");
else
    $display("READ2 FAIL");

axi_single_read_id(4'd3, 32'h00000030, rd_data);

if (rd_data == 32'h33333333)
    $display("READ3 PASS");
else
    $display("READ3 FAIL");

//--------------------------------------------------
// BACKPRESSURE TEST
//--------------------------------------------------

$display("");
$display("==============================================");
$display("      AXI WRITE/READ BACKPRESSURE TEST");
$display("==============================================");


//---------------------------
// Write
//---------------------------

axi_send_aw_only(
    4'd1,
    32'h00000040
);

axi_send_w_only_B(
    32'hDEADBEEF
);

//---------------------------
// Read
//---------------------------

axi_single_read_id_B(
    4'd1,
    32'h00000040,
    rd_data
);

if(rd_data == 32'hDEADBEEF)
begin
    $display("----------------------------------------------");
    $display("BACKPRESSURE TEST PASSED");
    $display("----------------------------------------------");
end
else
begin
    $display("----------------------------------------------");
    $display("BACKPRESSURE TEST FAILED");
    $display("Expected : DEADBEEF");
    $display("Received : %h", rd_data);
    $display("----------------------------------------------");
end

    #100;

    $finish;

end

endmodule
