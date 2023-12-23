module MED #(parameter DATA_WIDTH = 8, parameter NUM_PIXELS = 9)
  (input CLK,DSI,BYP,
   input [DATA_WIDTH - 1 : 0] DI,
   output [DATA_WIDTH - 1 : 0] DO);

  //              Mounting the registers                          //

  logic [DATA_WIDTH - 1 : 0] registers [0 : NUM_PIXELS - 1];


    //              Mouting the MCE MODULE                          //
  wire [DATA_WIDTH - 1:0] MAX_w,MIN_w;
  MCE #(.DATA_WIDTH(DATA_WIDTH)) MCE0 (.A(DO),.B(registers[NUM_PIXELS - 2]),.MAX(MAX_w),.MIN(MIN_w));


  always_ff @(posedge CLK)
  begin

      //MUX 2
      registers[NUM_PIXELS-1] <= BYP ? registers[NUM_PIXELS-2] : MAX_w;
      //MUX 1
      registers[0] <= DSI ? DI: MIN_w;

      for (int i = 0; i < NUM_PIXELS-2; i++)
      begin
          registers[i+1] <= registers[i];
      end
    end
  assign DO = registers[NUM_PIXELS-1];

endmodule
