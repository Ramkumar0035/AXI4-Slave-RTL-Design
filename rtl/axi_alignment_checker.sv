module axi_alignment_checker
#(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)
(
    input  logic [ADDR_WIDTH-1:0] addr,
    input  logic [2:0]            size,

    output logic alignment_error
);

logic [ADDR_WIDTH-1:0] mask;

logic illegal_size;

always_comb
begin

    //--------------------------------------------------
    // Illegal Transfer Size Check
    //--------------------------------------------------

    illegal_size =
        ( (1 << size) > (DATA_WIDTH/8) );

    //--------------------------------------------------
    // Alignment Mask
    //--------------------------------------------------

    mask =
        ADDR_WIDTH'((1 << size) - 1);

    //--------------------------------------------------
    // Alignment Error
    //--------------------------------------------------

    alignment_error =
        illegal_size ||
        ((addr & mask) != 0);

end

endmodule
