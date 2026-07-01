module axi_resp_gen
(
    input  logic alignment_error,
    input  logic boundary_error,
    input  logic decode_error,
    input  logic outstanding_error,

    output logic [1:0] resp
);

localparam logic [1:0] OKAY   = 2'b00;
localparam logic [1:0] EXOKAY = 2'b01;
localparam logic [1:0] SLVERR = 2'b10;
localparam logic [1:0] DECERR = 2'b11;

always_comb
begin

    //--------------------------------------------------
    // Priority Encoder
    //--------------------------------------------------

    if(decode_error)
        resp = DECERR;

    else if(outstanding_error)
        resp = SLVERR;

    else if(boundary_error)
        resp = SLVERR;

    else if(alignment_error)
        resp = SLVERR;

    else
        resp = OKAY;

end

endmodule