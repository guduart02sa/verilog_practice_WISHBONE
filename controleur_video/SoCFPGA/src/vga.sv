module vga #(parameter HDISP = 800, parameter VDISP = 480)
(
    input pixel_clk,
    input pixel_rst,
    video_if.master video_ifm,
    wshb_if.master wshb_ifm
);

localparam HFP = 40;
localparam HPULSE = 48;
localparam HBP = 40;
localparam VFP = 13;
localparam VPULSE = 3;
localparam VBP = 29;

localparam DATA_WIDTH = 32;

//To work in a parametable way, we need to use only the parameters to create signals that are not binary. As stated in the TP page:

localparam V_size = VFP + VPULSE + VBP + VDISP;
localparam H_size = HFP + HPULSE + HBP + HDISP;

logic [$clog2(V_size) - 1 : 0] counterlines;
logic [$clog2(H_size) - 1 : 0] counterpixels;

assign video_ifm.CLK = pixel_clk;

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
end


// Wishbone interface
assign wshb_ifm.sel = 4'b1111;
assign wshb_ifm.we = 1'b0;
assign wshb_ifm.cti = '0;
assign wshb_ifm.bte = '0;

// FIFO

logic aux_read, aux_rempty,aux_wfull,aux_almost_full;
logic [DATA_WIDTH - 1 : 0] aux_rdata;

// Almost full threshold as 255 because it's the default value
async_fifo #(.DATA_WIDTH(DATA_WIDTH), .DEPTH_WIDTH(8), .ALMOST_FULL_THRESHOLD(255)) async_fifo0
(
    .rst(wshb_ifm.rst),
    .rclk(pixel_clk),
    .read(aux_read),
    .rdata(aux_rdata),
    .rempty(aux_rempty),
    .wclk(wshb_ifm.clk),
    .wdata(wshb_ifm.dat_sm),
    .write(wshb_ifm.ack),
    .wfull(aux_wfull),
    .walmost_full(aux_almost_full)
);

assign wshb_ifm.stb = !aux_wfull;         // While the fifo is not full, ask data 

//SDRAM READING
always_ff @(posedge wshb_ifm.clk)
begin
    if(wshb_ifm.rst)
    begin
        wshb_ifm.adr <= 0;
    end
    else
    begin
        if(wshb_ifm.ack)
        begin
            if (wshb_ifm.adr == 4*(HDISP*VDISP)-4)   // 4* Because byte oriented(and each byte is 32 bits represented), sees if the scan is already
            begin                                    // in the end
                wshb_ifm.adr <= 0;
            end
            else
            begin
                wshb_ifm.adr <= wshb_ifm.adr + 4;  //Word increment "Les pixels sont stockés par mots de 32bits"
            end
        end
    end
end

logic fifo_full_1st_time;
always_ff @(posedge pixel_clk or posedge pixel_rst)
begin
    if (pixel_rst)
    begin
        fifo_full_1st_time <= 0;
    end
    else
    begin
        if (aux_wfull && !video_ifm.VS && !video_ifm.HS) begin fifo_full_1st_time <= 1; end
    end
end

assign aux_read = video_ifm.BLANK && fifo_full_1st_time && !aux_rempty;
assign video_ifm.RGB = aux_rdata[23:0];

////////////////////////// NEW CODE part 4 //////////////////////////

assign wshb_ifm.cyc = wshb_ifm.stb;

endmodule