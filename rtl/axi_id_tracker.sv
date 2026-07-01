module axi_id_tracker
#(
    parameter ID_WIDTH   = 4,
    parameter MAX_IDS    = 16,
    parameter COUNT_WIDTH = 8
)
(
    input  logic clk,
    input  logic rst_n,

    input  logic push,
    input  logic pop,

    input  logic [ID_WIDTH-1:0] push_id,
    input  logic [ID_WIDTH-1:0] pop_id,

    output logic outstanding_error,
    output logic overflow_error
);

/////////////////////////////////////////////////////////
// Outstanding Counters
/////////////////////////////////////////////////////////

logic [COUNT_WIDTH-1:0]
      outstanding_count [0:MAX_IDS-1];

integer i;

/////////////////////////////////////////////////////////
// Counter Logic
/////////////////////////////////////////////////////////

always_ff @(posedge clk or negedge rst_n)
begin

    if(!rst_n)
    begin

        for(i=0;i<MAX_IDS;i=i+1)
            outstanding_count[i] <= '0;

    end
    else
    begin

        //--------------------------------------------------
        // Same ID Push + Pop
        //--------------------------------------------------

        if(push && pop && (push_id == pop_id))
        begin

            outstanding_count[push_id]
                <= outstanding_count[push_id];

        end

        //--------------------------------------------------
        // Push Only
        //--------------------------------------------------

        else if(push)
        begin

            if(outstanding_count[push_id]
                != {COUNT_WIDTH{1'b1}})
            begin

                outstanding_count[push_id]
                    <= outstanding_count[push_id] + 1'b1;

            end

        end

        //--------------------------------------------------
        // Pop Only
        //--------------------------------------------------

        else if(pop)
        begin

            if(outstanding_count[pop_id] > 0)
            begin

                outstanding_count[pop_id]
                    <= outstanding_count[pop_id] - 1'b1;

            end

        end

    end

end

/////////////////////////////////////////////////////////
// Error Detection
/////////////////////////////////////////////////////////

assign outstanding_error =
       pop &&
      (outstanding_count[pop_id] == 0);

assign overflow_error =
       push &&
      (outstanding_count[push_id]
       == {COUNT_WIDTH{1'b1}});

endmodule
