module MED #(parameter DATA_WIDTH = 8, parameter NUM_PIXELS = 9)
  (input clk,DSI,BYP,
   input [DATA_WIDTH - 1 : 0] DI,
   output [DATA_WIDTH - 1 : 0] DO);

  //              Mouting the MCE MODULE                          //

  wire [DATA_WIDTH - 1:0] A_w,B_w;
  wire [DATA_WIDTH - 1:0] MAX_w,MIN_w;

  MCE #(.WIDTH(DATA_WIDTH)) MCE0 (.A(A_w),.B(B_w),.MAX(MAX_w),.MIN(MIN_w));

  //              Mounting the registers                          //

  logic [DATA_WIDTH - 1 : 0] registers [0 : NUM_PIXELS - 1];

  always_ff @(posedge clk)
  begin

        registers[NUM_PIXELS-1] <= BYP ? registers[NUM_PIXELS-2] : MAX_w;

        registers[0] <= DSI ? DI: MIN_w;

        for (int i = 0; i <= NUM_PIXELS/2; i = i++)
        begin
                for (int pix_idx = 0; pix_idx < NUM_PIXELS - i; pix_idx++)
                begin
                        if (registers[0] < registers[pix_idx]) 
                        begin                                
                                static logic [DATA_WIDTH-1:0] aux = registers[0];
                                registers[0] <= registers[pix_idx];
                                registers[pix_idx] <= aux;
                        end
                end
        end
        registers[0:NUM_PIXELS-1] = {registers[1:NUM_PIXELS-1], 0};
  end

  assign DO = registers[0];

endmodule
