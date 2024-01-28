`timescale 1ns/1ps

`default_nettype none

module tb_Top;

// Entrées sorties extérieures
bit   FPGA_CLK1_50;
logic [1:0]	KEY;
wire  [7:0]	LED;
logic [3:0]	SW;

// Interface vers le support matériel
hws_if      hws_ifm();

// Instance du module Top
//Top Top0(.*) ;

///////////////////////////////
//  Code élèves
//////////////////////////////

`define SIMULATION

// Clock generator
always #10ns FPGA_CLK1_50 = ~FPGA_CLK1_50;

// KEY[0] manipulation
initial begin
    KEY[0] = 1'b1;
    #128ns KEY[0] = 1'b0;
    #128ns KEY[0] = 1'b1;
end

// Process to stop the simulation after a arbitrary time
initial begin
    #15ms $stop();
end

video_if video_if0() ;
Top #(.HDISP(160),.VDISP(90))
simuTOP (
    .FPGA_CLK1_50(FPGA_CLK1_50),
    .KEY(KEY),
    .LED(LED),
    .SW(SW),
    .hws_ifm(hws_ifm),
    .video_ifm(video_if0)
);

screen #(.mode(13),.X(160),.Y(90)) screen0(.video_ifs(video_if0))  ;


endmodule
