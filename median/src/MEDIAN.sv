module MEDIAN #(parameter DATA_WIDTH = 8)
    (input DSI, nRST, CLK,
    input [DATA_WIDTH-1:0] DI,
    output [DATA_WIDTH-1:0] DO,
    output logic DSO);

    logic BYP;
    logic [3:0] counter, state;  

    typedef enum logic [2:0] {
        INIT = 0,
        state1 = 1,
        state2 = 2,
        state3 = 3,
        state4 = 4,
        state5 = 5,
        state6 = 6
      } State;

    MED #(.DATA_WIDTH(DATA_WIDTH)) MED0 (.DI(DI), .DSI(DSI), .CLK(CLK), .BYP(BYP), .DO(DO));
    
    always_ff @(posedge CLK)
    begin
        if (nRST) begin
            counter <= (counter == 8) ? 0 : counter + 1;
            if (state == INIT) 
            begin
                state <= (DSI) ? state1 : INIT;
                counter <= 0;
            end 
            else if (state == state6 && counter == 4) state <= (DSI) ? state1 : INIT;
            else if (counter == 8) state <= state + 1;
            
        end else begin 
            counter <= 0;
            state   <= 0;
        end
    end

    always_comb
    begin
        BYP = 0;
        DSO = 0;
        
        case (state)
            state1: if (counter < 8) begin BYP = DSI; DSO = 0; end
            state2: if (counter > 7)  begin BYP = 1; DSO = 0; end
            state3: if (counter > 6)  begin BYP = 1; DSO = 0; end
            state4: if (counter > 5)  begin BYP = 1; DSO = 0; end
            state5: if (counter > 4)  begin BYP = 1; DSO = 0; end
            state6: if (counter == 4) begin BYP = 0; DSO = 1; end
        endcase
    end
endmodule
