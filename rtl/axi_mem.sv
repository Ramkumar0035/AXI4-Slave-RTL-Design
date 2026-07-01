module axi_mem
#(
    parameter ADDR_WIDTH = 10,
    parameter DATA_WIDTH = 32,
    parameter DEPTH      = 1024
)
(
    input  logic clk,
    input  logic rst_n,

    //--------------------------------------------------
    // WRITE PORT
    //--------------------------------------------------
    input  logic write_en,
    input  logic [ADDR_WIDTH-1:0] write_addr,
    input  logic [DATA_WIDTH-1:0] write_data,
    input  logic [(DATA_WIDTH/8)-1:0] write_strb,

    //--------------------------------------------------
    // READ PORT
    //--------------------------------------------------
    input  logic read_en,
    input  logic [ADDR_WIDTH-1:0] read_addr,

    output logic [DATA_WIDTH-1:0] read_data
);

/////////////////////////////////////////////////////////
// MEMORY ARRAY
/////////////////////////////////////////////////////////

logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];

logic [ADDR_WIDTH-1:0] rd_addr_reg;
logic                  read_en_d;

integer i;

/////////////////////////////////////////////////////////
// WRITE LOGIC
/////////////////////////////////////////////////////////

always_ff @(posedge clk)
begin
    if(write_en && (write_addr < DEPTH))
    begin
        for(i = 0; i < DATA_WIDTH/8; i = i + 1)
        begin
            if(write_strb[i])
            begin
                mem[write_addr][i*8 +: 8]
                    <= write_data[i*8 +: 8];
            end
        end
    end
end

/////////////////////////////////////////////////////////
// READ ADDRESS PIPELINE
/////////////////////////////////////////////////////////

always_ff @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        rd_addr_reg <= {ADDR_WIDTH{1'b0}};
        read_en_d   <= 1'b0;
    end
    else
    begin
        if(read_en)
            rd_addr_reg <= read_addr;

        read_en_d <= read_en;
    end
end

/////////////////////////////////////////////////////////
// READ DATA PIPELINE
/////////////////////////////////////////////////////////

always_ff @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        read_data <= {DATA_WIDTH{1'b0}};
    end
    else if(read_en_d)
    begin
        if(rd_addr_reg < DEPTH)
            read_data <= mem[rd_addr_reg];
        else
            read_data <= {DATA_WIDTH{1'b0}};
    end
end

endmodule
