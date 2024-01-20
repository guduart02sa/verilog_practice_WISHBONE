//-----------------------------------------------------------------
// Wishbone BlockRAM
//-----------------------------------------------------------------
//
// Le paramètre mem_adr_width doit permettre de déterminer le nombre 
// de mots de la mémoire : (2048 pour mem_adr_width=11)

module wb_bram #(parameter mem_adr_width = 11) 
(
// Wishbone interface
wshb_if.slave wb_s
);

//Address                                                                   
wire [mem_adr_width-1:0] address = wb_s.adr[mem_adr_width+1:2];              

// 4 independent memories as suggested   
logic [7:0] mem0 [0:2**mem_adr_width-1];
logic [7:0] mem1 [0:2**mem_adr_width-1];
logic [7:0] mem2 [0:2**mem_adr_width-1];
logic [7:0] mem3 [0:2**mem_adr_width-1];

// ACK
logic ack_w, ack_r;
logic read_enable_ack;

//ACK_w (doesn't exactly need to analyze cyc)
assign ack_w = wb_s.stb & wb_s.we;

//ACK master
assign wb_s.ack = ack_w | ack_r;

//Convention slides  
assign wb_s.err = 0;
assign wb_s.rty = 0;

//Read acknowledge(need to be sequential)
always_ff @(posedge wb_s.clk)
begin
      if(wb_s.rst || ack_r)
            ack_r <= 0;
      else if(!wb_s.we && wb_s.stb)
            ack_r <= 1;
end              

always_ff @(posedge wb_s.clk)
begin
      if(ack_w)  //Could be done analying bits of sel, but the sel = 4b'1001 isn't valid, for instance 
      begin
            if      (wb_s.sel == 4'b0001) begin mem0[address] <= wb_s.dat_ms[7:0];     end
            else if (wb_s.sel == 4'b0010) begin mem1[address] <= wb_s.dat_ms[15:8];    end 
            else if (wb_s.sel == 4'b0100) begin mem2[address] <= wb_s.dat_ms[23:16];   end 
            else if (wb_s.sel == 4'b1000) begin mem3[address] <= wb_s.dat_ms[31:24];   end 
            else if (wb_s.sel == 4'b0011) 
            begin
                  mem0[address] <= wb_s.dat_ms[7:0];
                  mem1[address] <= wb_s.dat_ms[15:8];
            end 
            else if (wb_s.sel == 4'b1100) 
            begin
                  mem2[address] <= wb_s.dat_ms[23:16];
                  mem3[address] <= wb_s.dat_ms[31:24];
            end 
            else if (wb_s.sel == 4'b1111) 
            begin
                  mem0[address] <= wb_s.dat_ms[7:0];
                  mem1[address] <= wb_s.dat_ms[15:8];
                  mem2[address] <= wb_s.dat_ms[23:16];
                  mem3[address] <= wb_s.dat_ms[31:24];
            end
      end
      wb_s.dat_sm[7:0] <= mem0[address];
      wb_s.dat_sm[15:8] <= mem1[address];
      wb_s.dat_sm[23:16] <= mem2[address];
      wb_s.dat_sm[31:24] <= mem3[address];
end
endmodule