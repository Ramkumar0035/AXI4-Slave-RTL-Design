module axi_write_fsm
(
    input  logic clk,
    input  logic rst_n,

    input  logic awvalid,
    output logic awready,

    input  logic wvalid,
    input  logic wlast,
    output logic wready,

    output logic bvalid,
    input  logic bready,

    output logic wr_start,
    output logic wr_done
);

typedef enum logic [1:0]
{
    WR_IDLE,
    WR_DATA,
    WR_RESP
} wr_state_t;

wr_state_t state,next_state;

always_ff @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        state <= WR_IDLE;
    else
        state <= next_state;
end

always_comb
begin

    awready  = 1'b0;
    wready   = 1'b0;
    bvalid   = 1'b0;

    wr_start = 1'b0;
    wr_done  = 1'b0;

    next_state = state;

    case(state)

    WR_IDLE:
    begin

        awready = 1'b1;

        if(awvalid && awready)
        begin
            wr_start = 1'b1;
            next_state = WR_DATA;
        end

    end

    WR_DATA:
    begin

        wready = 1'b1;

        if(wvalid && wready && wlast)
        begin
            next_state = WR_RESP;
        end

    end

    WR_RESP:
    begin

        bvalid = 1'b1;

        if(bvalid && bready)
        begin
            wr_done = 1'b1;
            next_state = WR_IDLE;
        end

    end

    endcase

end

endmodule
