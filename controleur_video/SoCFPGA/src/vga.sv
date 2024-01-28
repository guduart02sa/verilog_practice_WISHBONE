module vga #(parameter HDISP = 800, parameter VDISP = 480)
(
    input pixel_clk,
    input pixel_rst,
    video_if.master video_ifm
);

localparam HFP = 40;
localparam HPULSE = 48;
localparam HBP = 40;
localparam VFP = 13;
localparam VPULSE = 3;
localparam VBP = 29;


//To work in a parametable way, we need to use only the parameters to create signals that are not binary. As stated in the TP page:

localparam V_size = VFP + VPULSE + VBP + VDISP;
localparam H_size = HFP + HPULSE + HBP + HDISP;

logic [$clog2(V_size) - 1 : 0] counterlines;
logic [$clog2(H_size) - 1 : 0] counterpixels;

assign video_ifm.CLK = pixel_clk;

// REMOVED RST FROM THE SENSITIVITY LIST BECAUSE OF ERROR: 
// vga.sv(28): cannot match operand(s) in the condition to the corresponding edges in the enclosing event control of the always construct 
always_ff @(posedge pixel_clk)
begin
    if(pixel_rst || counterpixels == H_size - 1)
    begin
        counterpixels <= 0;
    end
    else
    begin
        counterpixels <= counterpixels + 1;
    end
end

// REMOVED RST FROM THE SENSITIVITY LIST BECAUSE OF ERROR: 
// vga.sv(40): cannot match operand(s) in the condition to the corresponding edges in the enclosing event control of the always construct 
always_ff @(posedge pixel_clk)
begin
    if(pixel_rst || counterlines == V_size)
    begin
        counterlines <= 0;
    end
    else if (counterpixels == H_size - 1)
    begin
        counterlines <= counterlines + 1;
    end
end

always_ff @(posedge pixel_clk)
begin
    video_ifm.HS <= !(counterpixels >= HFP && counterpixels < HFP + HPULSE);
    video_ifm.VS <= !(counterlines >= VFP && counterlines < VFP + VPULSE);
    video_ifm.BLANK <= ((counterlines >= VBP + VPULSE + VFP) && (counterpixels >= HBP + HPULSE + HFP));
    video_ifm.RGB <= ((counterpixels - (H_size - HDISP)) % 16 == 0) || ((counterlines - (V_size - VDISP)) % 16 == 0) ? '1 : '0;
end

// Deleted "rst" for video_ifm.RGB. It's unecessary.


endmodule