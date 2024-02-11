`default_nettype none

module Top #(parameter HDISP = 800, parameter VDISP = 480)
(
    // Les signaux externes de la partie FPGA
	input  wire         FPGA_CLK1_50,
	input  wire  [1:0]	KEY,
	output logic [7:0]	LED,
	input  wire	 [3:0]	SW,
    // Les signaux du support matériel son regroupés dans une interface
    hws_if.master       hws_ifm,
    video_if.master     video_ifm
);

//====================================
//  Déclarations des signaux internes
//====================================
  wire        sys_rst;   // Le signal de reset du système
  wire        sys_clk;   // L'horloge système a 100Mhz
  wire        pixel_clk; // L'horloge de la video 32 Mhz

//=======================================================
//  La PLL pour la génération des horloges
//=======================================================

sys_pll  sys_pll_inst(
		   .refclk(FPGA_CLK1_50),   // refclk.clk
		   .rst(1'b0),              // pas de reset
		   .outclk_0(pixel_clk),    // horloge pixels a 32 Mhz
		   .outclk_1(sys_clk)       // horloge systeme a 100MHz
);

//=============================
//  Les bus Wishbone internes
//=============================
wshb_if #( .DATA_BYTES(4)) wshb_if_sdram  (sys_clk, sys_rst);
wshb_if #( .DATA_BYTES(4)) wshb_if_stream (sys_clk, sys_rst);

//=============================
//  Le support matériel
//=============================
hw_support hw_support_inst (
    .wshb_ifs (wshb_if_sdram),
    .wshb_ifm (wshb_if_stream),
    .hws_ifm  (hws_ifm),
	.sys_rst  (sys_rst), // output
    .SW_0     ( SW[0] ),
    .KEY      ( KEY )
 );

logic [31:0] counter, counter1;
logic pixel_rst, D0,D1,Q0;

`ifdef SIMULATION
  localparam hcmpt = 50;
  localparam hcmpt_pixel_clk = 16;
`else
  localparam hcmpt = 50000000;
  localparam hcmpt_pixel_clk = 16000000;
`endif

assign LED[0] = KEY[0];

always_ff @(posedge sys_clk or posedge sys_rst)
begin
    if (sys_rst) 
    begin
        counter <= 0;
        LED[1] <= 0;
    end
    else 
    begin
        if (counter == hcmpt) 
        begin
            counter <= 0;
            LED[1] <= ~LED[1];
        end 
        else 
        begin
            counter <= counter + 1;
        end
    end
end

assign D1 = Q0;
assign D0 = 0;
always_ff @(posedge sys_rst or posedge pixel_clk) 
begin
    Q0 <= (sys_rst) ? 1 : D0;
    pixel_rst <= (sys_rst) ? 1 : D1;
end

always_ff @(posedge pixel_clk or posedge pixel_rst)
begin
    if (pixel_rst) 
    begin
        counter1 <= 0;
        LED[2] <= 0;
    end
    else 
    begin
        if (counter1 == hcmpt_pixel_clk) 
        begin
            counter1 <= 0;
            LED[2] <= ~LED[2];
        end 
        else 
        begin
            counter1 <= counter1 + 1;
        end
    end
end

wshb_if #(.DATA_BYTES(4)) wshb_if_vga (sys_clk, sys_rst);

vga #(.HDISP(HDISP), .VDISP(VDISP)) 
vga_module (
    .pixel_clk(pixel_clk),
    .pixel_rst(pixel_rst),
    .video_ifm(video_ifm),
    .wshb_ifm(wshb_if_vga)
);

wshb_intercon wshb_intercon_module (
    .wshb_ifs_mire(wshb_if_stream),
    .wshb_ifm(wshb_if_sdram.master),
    .wshb_ifs_vga(wshb_if_vga)
);

endmodule