module MCE #(parameter DATA_WIDTH = 8)
        (input [DATA_WIDTH - 1:0]A,B,
            output [DATA_WIDTH - 1:0] MAX,MIN);

    assign {MAX,MIN} = B<=A ? {A,B} : {B,A};

endmodule