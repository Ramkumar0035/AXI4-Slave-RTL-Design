     module axi_read_controller
#(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter ID_WIDTH   = 4,
    parameter FIFO_DEPTH = 16
)
(
    input  logic clk,
    input  logic rst_n,

    input  logic [ID_WIDTH-1:0]   arid,
    input  logic [ADDR_WIDTH-1:0] araddr,
    input  logic [7:0]            arlen,
    input  logic [2:0]            arsize,
    input  logic [1:0]            arburst,
    input  logic                  arvalid,
    output logic                  arready,

    output logic [ID_WIDTH-1:0]   rid,
    output logic [DATA_WIDTH-1:0] rdata,
    output logic [1:0]            rresp,
    output logic                  rlast,
    output logic                  rvalid,

    input  logic                  rready,

    output logic                  mem_read_en,
    output logic [ADDR_WIDTH-1:0] mem_read_addr,

    input  logic [DATA_WIDTH-1:0] mem_read_data
);

/////////////////////////////////////////////////////////
// FIFO
/////////////////////////////////////////////////////////

logic fifo_push;
logic fifo_pop;

logic fifo_full;
logic fifo_empty;

logic [ID_WIDTH-1:0]   fifo_id;
logic [ADDR_WIDTH-1:0] fifo_addr;
logic [7:0]            fifo_len;
logic [2:0]            fifo_size;
logic [1:0]            fifo_burst;

axi_transaction_fifo
#(
    .DEPTH(FIFO_DEPTH),
    .ID_WIDTH(ID_WIDTH),
    .ADDR_WIDTH(ADDR_WIDTH)
)
AR_FIFO
(
    .clk(clk),
    .rst_n(rst_n),

    .push(fifo_push),

    .push_id(arid),
    .push_addr(araddr),
    .push_len(arlen),
    .push_size(arsize),
    .push_burst(arburst),

    .pop(fifo_pop),

    .pop_id(fifo_id),
    .pop_addr(fifo_addr),
    .pop_len(fifo_len),
    .pop_size(fifo_size),
    .pop_burst(fifo_burst),

    .full(fifo_full),
    .empty(fifo_empty),

    .occupancy()
);

assign arready   = !fifo_full;
assign fifo_push = arvalid && arready;

/////////////////////////////////////////////////////////
// ACTIVE TRANSACTION
/////////////////////////////////////////////////////////

logic [ID_WIDTH-1:0] active_id;

logic [ADDR_WIDTH-1:0] curr_addr;
logic [ADDR_WIDTH-1:0] next_addr;

logic [7:0] active_len;
logic [2:0] active_size;
logic [1:0] active_burst;

logic [7:0] beat_count;

/////////////////////////////////////////////////////////
// R CHANNEL REGISTERS
/////////////////////////////////////////////////////////

logic                  rvalid_reg;
logic                  rlast_reg;

logic [ID_WIDTH-1:0]   rid_reg;
logic [DATA_WIDTH-1:0] rdata_reg;
logic [1:0]            rresp_reg;

/////////////////////////////////////////////////////////
// CHECKERS
/////////////////////////////////////////////////////////

logic alignment_error;
logic boundary_error;

logic [1:0] resp;

axi_alignment_checker
#(
    .ADDR_WIDTH(ADDR_WIDTH)
)
ALIGN_CHECK
(
    .addr(curr_addr),
    .size(active_size),
    .alignment_error(alignment_error)
);

axi_boundary_checker
#(
    .ADDR_WIDTH(ADDR_WIDTH)
)
BOUNDARY_CHECK
(
    .start_addr(curr_addr),
    .burst_len(active_len),
    .burst_size(active_size),
    .boundary_error(boundary_error)
);

axi_resp_gen RESP_GEN
(
    .alignment_error(alignment_error),
    .boundary_error(boundary_error),
    .decode_error(1'b0),
    .outstanding_error(1'b0),
    .resp(resp)
);

/////////////////////////////////////////////////////////
// ADDRESS GENERATOR
/////////////////////////////////////////////////////////

axi_addr_gen
#(
    .ADDR_WIDTH(ADDR_WIDTH)
)
ADDR_GEN
(
    .curr_addr(curr_addr),
    .burst_len(active_len),
    .burst_size(active_size),
    .burst_type(active_burst),
    .next_addr(next_addr)
);

/////////////////////////////////////////////////////////
// FSM
/////////////////////////////////////////////////////////

typedef enum logic [2:0]
{
    RD_IDLE,
    RD_LOAD,
    RD_REQ,
    RD_WAIT1,
    RD_WAIT2,
    RD_SEND
} rd_state_t;

rd_state_t state;
rd_state_t next_state;

always_ff @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        state <= RD_IDLE;
    else
        state <= next_state;
end

always_comb
begin

    next_state = state;

    fifo_pop = 1'b0;

    mem_read_en   = 1'b0;
    mem_read_addr = curr_addr;

    case(state)

        RD_IDLE:
        begin
            if(!fifo_empty)
                next_state = RD_LOAD;
        end

        RD_LOAD:
        begin
            fifo_pop   = 1'b1;
            next_state = RD_REQ;
        end

        RD_REQ :
begin

    mem_read_en   = 1'b1;
    mem_read_addr = curr_addr;

    next_state = RD_WAIT1;

end

        RD_WAIT1:
begin
    next_state = RD_WAIT2;
end

RD_WAIT2:
begin
    next_state = RD_SEND;
end

        RD_SEND:
        begin
            if(rvalid_reg && rready)
            begin
                if(rlast_reg)
                    next_state = RD_IDLE;
                else
                    next_state = RD_REQ;
            end
        end

        default:
            next_state = RD_IDLE;

    endcase

end

/////////////////////////////////////////////////////////
// TRANSACTION REGISTERS
/////////////////////////////////////////////////////////

always_ff @(posedge clk or negedge rst_n)
begin

    if(!rst_n)
    begin

        active_id    <= '0;
        curr_addr    <= '0;

        active_len   <= '0;
        active_size  <= '0;
        active_burst <= '0;

        beat_count   <= '0;

    end
    else
    begin

        if(state == RD_LOAD)
        begin

            active_id    <= fifo_id;
            curr_addr    <= fifo_addr;

            active_len   <= fifo_len;
            active_size  <= fifo_size;
            active_burst <= fifo_burst;

            beat_count   <= '0;

        end
        
else if(state == RD_SEND &&
        rvalid_reg &&
        rready)
begin

    $display(
    "TIME=%0t ADDR=%h NEXT=%h COUNT=%0d DATA=%h",
    $time,
    curr_addr,
    next_addr,
    beat_count,
    mem_read_data
    );

    beat_count <= beat_count + 1'b1;

    if(!rlast_reg)
        curr_addr <= next_addr;

end

    end

end

/////////////////////////////////////////////////////////
// R CHANNEL REGISTERS
/////////////////////////////////////////////////////////

always_ff @(posedge clk or negedge rst_n)
begin

    if(!rst_n)
    begin

        rvalid_reg <= 1'b0;

        rid_reg   <= '0;
        rdata_reg <= '0;
        rresp_reg <= '0;
        rlast_reg <= 1'b0;

    end
    else
    begin

        if(state == RD_WAIT2)
begin

    rvalid_reg <= 1'b1;

    rid_reg   <= active_id;
    rdata_reg <= mem_read_data;
    rresp_reg <= resp;

    rlast_reg <= (beat_count == active_len);

end
        else if(rvalid_reg && rready)
        begin

            rvalid_reg <= 1'b0;

        end

    end

end

/////////////////////////////////////////////////////////
// OUTPUTS
/////////////////////////////////////////////////////////

assign rid    = rid_reg;
assign rdata  = rdata_reg;
assign rresp  = rresp_reg;
assign rlast  = rlast_reg;
assign rvalid = rvalid_reg;

endmodule
