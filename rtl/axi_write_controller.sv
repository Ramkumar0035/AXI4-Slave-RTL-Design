module axi_write_controller
#(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter ID_WIDTH   = 4,
    parameter FIFO_DEPTH = 16,
    parameter ENABLE_MULTI_OUTSTANDING = 0
)
(
    input  logic clk,
    input  logic rst_n,

    //--------------------------------------------------
    // AW CHANNEL
    //--------------------------------------------------
    input  logic [ID_WIDTH-1:0]   awid,
    input  logic [ADDR_WIDTH-1:0] awaddr,
    input  logic [7:0]            awlen,
    input  logic [2:0]            awsize,
    input  logic [1:0]            awburst,
    input  logic                  awvalid,
    output logic                  awready,

    //--------------------------------------------------
    // W CHANNEL
    //--------------------------------------------------
    input  logic [DATA_WIDTH-1:0]      wdata,
    input  logic [(DATA_WIDTH/8)-1:0]  wstrb,
    input  logic                       wvalid,
    input  logic                       wlast,
    output logic                       wready,

    //--------------------------------------------------
    // B CHANNEL
    //--------------------------------------------------
    output logic [ID_WIDTH-1:0] bid,
    output logic [1:0]          bresp,
    output logic                bvalid,
    input  logic                bready,

    //--------------------------------------------------
    // MEMORY INTERFACE
    //--------------------------------------------------
    output logic                      mem_write_en,
    output logic [ADDR_WIDTH-1:0]     mem_write_addr,
    output logic [DATA_WIDTH-1:0]     mem_write_data,
    output logic [(DATA_WIDTH/8)-1:0] mem_write_strb
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
logic [$clog2(FIFO_DEPTH+1)-1:0] fifo_occupancy;

axi_transaction_fifo
#(
    .DEPTH(FIFO_DEPTH),
    .ID_WIDTH(ID_WIDTH),
    .ADDR_WIDTH(ADDR_WIDTH)
)
AW_FIFO
(
    .clk(clk),
    .rst_n(rst_n),

    .push(fifo_push),

    .push_id(awid),
    .push_addr(awaddr),
    .push_len(awlen),
    .push_size(awsize),
    .push_burst(awburst),

    .pop(fifo_pop),

    .pop_id(fifo_id),
    .pop_addr(fifo_addr),
    .pop_len(fifo_len),
    .pop_size(fifo_size),
    .pop_burst(fifo_burst),

    .full(fifo_full),
    .empty(fifo_empty),
    .occupancy(fifo_occupancy)
);

assign fifo_push = awvalid && awready;
assign awready   = !fifo_full;

/////////////////////////////////////////////////////////
// ACTIVE TRANSACTION
/////////////////////////////////////////////////////////

logic [ID_WIDTH-1:0]   active_id;

logic [ADDR_WIDTH-1:0] curr_addr;
logic [ADDR_WIDTH-1:0] next_addr;

logic [7:0] active_len;
logic [2:0] active_size;
logic [1:0] active_burst;

logic [7:0] beat_count;
logic transaction_active;

/////////////////////////////////////////////////////////
// REGISTERED B CHANNEL
/////////////////////////////////////////////////////////

logic                bvalid_reg;
logic [1:0]          bresp_reg;
logic [ID_WIDTH-1:0] bid_reg;

/////////////////////////////////////////////////////////
// FSM
/////////////////////////////////////////////////////////

typedef enum logic [1:0]
{
    WR_IDLE,
    WR_LOAD,
    WR_DATA,
    WR_RESP
} wr_state_t;

wr_state_t state,next_state;

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
// CHECKERS
/////////////////////////////////////////////////////////

logic alignment_error;
logic boundary_error;
logic burst_length_error;

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

assign burst_length_error =
       (state == WR_DATA) &&
       wvalid &&
       wready &&
       wlast &&
       (beat_count != active_len);

axi_resp_gen RESP_GEN
(
    .alignment_error(alignment_error),
    .boundary_error(boundary_error),
    .decode_error(1'b0),
    .outstanding_error(burst_length_error),
    .resp(resp)
);

/////////////////////////////////////////////////////////
// FSM SEQUENTIAL
/////////////////////////////////////////////////////////

always_ff @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        state <= WR_IDLE;
    else
        state <= next_state;
end

/////////////////////////////////////////////////////////
// FSM COMBINATIONAL
/////////////////////////////////////////////////////////

always_comb
begin

    next_state = state;

    fifo_pop = 1'b0;
    wready   = 1'b0;

    case(state)

        WR_IDLE:
        begin
            if(!fifo_empty)
            begin
                if(ENABLE_MULTI_OUTSTANDING)
                begin
                    if(!transaction_active)
                        next_state = WR_LOAD;
                end
                else
                    next_state = WR_LOAD;
            end
        end

        WR_LOAD:
        begin
            if(ENABLE_MULTI_OUTSTANDING)
            begin
                if(!transaction_active)
                    fifo_pop = 1'b1;
            end
            else
                fifo_pop = 1'b1;
            next_state = WR_DATA;
        end

        WR_DATA:
        begin

            wready = 1'b1;

            if(wvalid && wready && wlast)
                next_state = WR_RESP;

        end

        WR_RESP:
        begin

            if(bvalid_reg && bready)
                next_state = WR_IDLE;

        end

        default:
        begin
            next_state = WR_IDLE;
        end

    endcase

end

/////////////////////////////////////////////////////////
// TRANSACTION REGISTERS
/////////////////////////////////////////////////////////

always_ff @(posedge clk or negedge rst_n)
begin

    if(!rst_n)
    begin

        active_id    <= 0;
        curr_addr    <= 0;

        active_len   <= 0;
        active_size  <= 0;
        active_burst <= 0;

        beat_count   <= 0;

    end
    else
    begin

        if(state == WR_LOAD)
        begin

            active_id    <= fifo_id;

            curr_addr    <= fifo_addr;

            active_len   <= fifo_len;
            active_size  <= fifo_size;
            active_burst <= fifo_burst;

            beat_count   <= 0;

        end
        else if(state == WR_DATA &&
                wvalid &&
                wready)
        begin

            if(!wlast)
                curr_addr <= next_addr;

            beat_count <= beat_count + 1'b1;

        end

    end

end


always_ff @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        transaction_active <= 1'b0;
    else begin
        if(state == WR_LOAD)
            transaction_active <= 1'b1;
        else if(state == WR_RESP && bvalid_reg && bready)
            transaction_active <= 1'b0;
    end
end

/////////////////////////////////////////////////////////
// MEMORY INTERFACE
/////////////////////////////////////////////////////////

assign mem_write_en =
        (state == WR_DATA) &&
        wvalid &&
        wready;

assign mem_write_addr =
        curr_addr;

assign mem_write_data =
        wdata;

assign mem_write_strb =
        wstrb;

/////////////////////////////////////////////////////////
// B CHANNEL REGISTERS
/////////////////////////////////////////////////////////

always_ff @(posedge clk or negedge rst_n)
begin

    if(!rst_n)
    begin

        bvalid_reg <= 1'b0;
        bresp_reg  <= 2'b00;
        bid_reg    <= 0;

    end
    else
    begin

        if(state == WR_DATA &&
           wvalid &&
           wready &&
           wlast)
        begin

            bvalid_reg <= 1'b1;
            bresp_reg  <= resp;
            bid_reg    <= active_id;

        end
        else if(bvalid_reg && bready)
        begin

            bvalid_reg <= 1'b0;

        end

    end

end

/////////////////////////////////////////////////////////
// OUTPUTS
/////////////////////////////////////////////////////////

assign bvalid = bvalid_reg;
assign bresp  = bresp_reg;
assign bid    = bid_reg;

endmodule



