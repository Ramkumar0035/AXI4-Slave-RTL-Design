module axi_transaction_fifo
#(
    parameter DEPTH      = 16,
    parameter ID_WIDTH   = 4,
    parameter ADDR_WIDTH = 32
)
(
    input  logic clk,
    input  logic rst_n,

    //--------------------------------------------------
    // PUSH INTERFACE
    //--------------------------------------------------
    input  logic                  push,
    input  logic [ID_WIDTH-1:0]   push_id,
    input  logic [ADDR_WIDTH-1:0] push_addr,
    input  logic [7:0]            push_len,
    input  logic [2:0]            push_size,
    input  logic [1:0]            push_burst,

    //--------------------------------------------------
    // POP INTERFACE
    //--------------------------------------------------
    input  logic                  pop,

    output logic [ID_WIDTH-1:0]   pop_id,
    output logic [ADDR_WIDTH-1:0] pop_addr,
    output logic [7:0]            pop_len,
    output logic [2:0]            pop_size,
    output logic [1:0]            pop_burst,

    //--------------------------------------------------
    // STATUS
    //--------------------------------------------------
    output logic full,
    output logic empty,
    output logic [$clog2(DEPTH+1)-1:0] occupancy
);

typedef struct packed
{
    logic [ID_WIDTH-1:0]   id;
    logic [ADDR_WIDTH-1:0] addr;
    logic [7:0]            len;
    logic [2:0]            size;
    logic [1:0]            burst;
} txn_t;

txn_t fifo [0:DEPTH-1];

logic [$clog2(DEPTH)-1:0] wr_ptr;
logic [$clog2(DEPTH)-1:0] rd_ptr;

logic [$clog2(DEPTH+1)-1:0] count;

always_ff @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        wr_ptr <= '0;
    end
    else if(push && !full)
    begin

        fifo[wr_ptr].id    <= push_id;
        fifo[wr_ptr].addr  <= push_addr;
        fifo[wr_ptr].len   <= push_len;
        fifo[wr_ptr].size  <= push_size;
        fifo[wr_ptr].burst <= push_burst;

        if(wr_ptr == DEPTH-1)
            wr_ptr <= '0;
        else
            wr_ptr <= wr_ptr + 1'b1;

    end
end

always_ff @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        rd_ptr <= '0;
    end
    else if(pop && !empty)
    begin

        if(rd_ptr == DEPTH-1)
            rd_ptr <= '0;
        else
            rd_ptr <= rd_ptr + 1'b1;

    end
end

always_ff @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        count <= '0;
    end
    else
    begin

        case({push && !full,
              pop  && !empty})

            2'b10:
                count <= count + 1'b1;

            2'b01:
                count <= count - 1'b1;

            default:
                count <= count;

        endcase

    end
end

assign full =
       (count == DEPTH);

assign empty =
       (count == 0);

assign occupancy =
       count;

assign pop_id =
       empty ? '0 : fifo[rd_ptr].id;

assign pop_addr =
       empty ? '0 : fifo[rd_ptr].addr;

assign pop_len =
       empty ? '0 : fifo[rd_ptr].len;

assign pop_size =
       empty ? '0 : fifo[rd_ptr].size;

assign pop_burst =
       empty ? '0 : fifo[rd_ptr].burst;

`ifndef SYNTHESIS
always_ff @(posedge clk)
begin
    assert(!(push && full))
    else $error("FIFO Overflow");

    assert(!(pop && empty))
    else $error("FIFO Underflow");
end
`endif

endmodule
