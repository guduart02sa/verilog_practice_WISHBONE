module Mire #(parameter HDISP = 800, parameter VDISP = 480)
(
    wshb_if.master wshb_ifm
);

// Wishbone steady signals
assign wshb_ifm.sel = 4'b1111;
assign wshb_ifm.we = 1'b1;
assign wshb_ifm.cti = '0;
assign wshb_ifm.bte = '0;

//Basically copiyng the image did in the second part
logic [$clog2(VDISP) - 1 : 0] counterlines;
logic [$clog2(HDISP) - 1 : 0] counterpixels;

always_ff @(posedge wshb_ifm.clk)
begin
    if(wshb_ifm.rst || counterpixels == HDISP - 1)
    begin
        counterpixels <= 0;
    end
    else
    begin
        counterpixels <= counterpixels + wshb_ifm.ack;
    end
end

always_ff @(posedge wshb_ifm.clk)
begin
    if(wshb_ifm.rst || counterlines == VDISP)
    begin
        counterlines <= 0;
    end
    else if (counterpixels == HDISP - 1)
    begin
        counterlines <= counterlines + wshb_ifm.ack;
    end
end

logic [5:0] counter_fair_play;

always_ff @(posedge wshb_ifm.clk or posedge wshb_ifm.rst)
begin
    if (wshb_ifm.rst)
    begin
        counter_fair_play <= 0;
    end
    else
    begin
        if(counter_fair_play == 63)
        begin 
            counter_fair_play <= 0;
            wshb_ifm.stb <= 0; 
        end
        else
        begin
            wshb_ifm.stb <= 1;
            counter_fair_play <= counter_fair_play + wshb_ifm.ack; 
        end
    end
end

// Address (also same as before)
always_ff @(posedge wshb_ifm.clk or posedge wshb_ifm.rst)
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
                wshb_ifm.adr <= wshb_ifm.adr + 4;  
            end
        end
    end
end


assign wshb_ifm.cyc = wshb_ifm.stb;

// RGB equivalent
assign wshb_ifm.dat_ms = (counterpixels % 16 == 0) || (counterlines % 16 == 0) ? '1: '0;

endmodule