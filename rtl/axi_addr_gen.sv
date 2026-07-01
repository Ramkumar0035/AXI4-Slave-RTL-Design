module axi_addr_gen
#(
    parameter ADDR_WIDTH = 32
)
(
    input  logic [ADDR_WIDTH-1:0] curr_addr,
    input  logic [7:0]            burst_len,
    input  logic [2:0]            burst_size,
    input  logic [1:0]            burst_type,

    output logic [ADDR_WIDTH-1:0] next_addr
);

logic [ADDR_WIDTH-1:0] increment;
logic [ADDR_WIDTH:0]   wrap_size;
logic [ADDR_WIDTH-1:0] wrap_boundary;

always_comb
begin

    increment =
        ADDR_WIDTH'(1) << burst_size;

    wrap_size =
        increment * (burst_len + 1);

    wrap_boundary =
        curr_addr & ~(wrap_size - 1);

    case(burst_type)

        //----------------------------------
        // FIXED
        //----------------------------------

        2'b00:
            next_addr = curr_addr;

        //----------------------------------
        // INCR
        //----------------------------------

        2'b01:
            next_addr = curr_addr + increment;

        //----------------------------------
        // WRAP
        //----------------------------------

        2'b10:
        begin

            if((curr_addr + increment) >=
               (wrap_boundary + wrap_size))
                next_addr = wrap_boundary;
            else
                next_addr = curr_addr + increment;

        end

        //----------------------------------
        // DEFAULT
        //----------------------------------

        default:
            next_addr = curr_addr;

    endcase

end

endmodule
