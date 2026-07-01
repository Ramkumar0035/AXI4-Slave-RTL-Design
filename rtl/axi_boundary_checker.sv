module axi_boundary_checker
#(
    parameter ADDR_WIDTH = 32
)
(
    input  logic [ADDR_WIDTH-1:0] start_addr,
    input  logic [7:0]            burst_len,
    input  logic [2:0]            burst_size,

    output logic boundary_error
);

logic [ADDR_WIDTH:0] burst_bytes;
logic [ADDR_WIDTH:0] end_addr;
logic [ADDR_WIDTH:0] start_addr_ext;

always_comb
begin

    start_addr_ext = start_addr;

    //----------------------------------
    // Total bytes in burst
    //----------------------------------

    burst_bytes =
        ((burst_len + 1) << burst_size);

    //----------------------------------
    // Last byte address
    //----------------------------------

    end_addr =
        start_addr_ext +
        burst_bytes - 1;

    //----------------------------------
    // 4KB Boundary Check
    //----------------------------------

    boundary_error =
        (start_addr[ADDR_WIDTH-1:12] !=
         end_addr[ADDR_WIDTH-1:12]);

end

endmodule