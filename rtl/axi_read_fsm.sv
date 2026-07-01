module axi_read_fsm
(
    input  logic clk,
    input  logic rst_n,

    input  logic arvalid,
    output logic arready,

    output logic rvalid,
    input  logic rready,

    input  logic rlast_in,

    output logic rd_start,
    output logic rd_done
);

typedef enum logic [1:0]
{
    RD_IDLE,
    RD_DATA
} rd_state_t;

rd_state_t state,next_state;

always_ff @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        state <= RD_IDLE;
    else
        state <= next_state;
end

always_comb
begin

    arready  = 1'b0;
    rvalid   = 1'b0;

    rd_start = 1'b0;
    rd_done  = 1'b0;

    next_state = state;

    case(state)

    //----------------------------------
    // IDLE
    //----------------------------------

    RD_IDLE:
    begin

        arready = 1'b1;

        if(arvalid && arready)
        begin
            rd_start = 1'b1;
            next_state = RD_DATA;
        end

    end

    //----------------------------------
    // DATA
    //----------------------------------

    RD_DATA:
    begin

        rvalid = 1'b1;

        if(rvalid &&
           rready &&
           rlast_in)
        begin

            rd_done = 1'b1;
            next_state = RD_IDLE;

        end

    end

    endcase

end

endmodule
