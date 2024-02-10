module wshb_intercon (
    wshb_if.slave wshb_ifs_vga,
    wshb_if.slave wshb_ifs_mire,
    wshb_if.master wshb_ifm
);

logic jeton;       //Token  

always_ff @(posedge wshb_ifm.clk or posedge wshb_ifm.rst)
begin
    if (wshb_ifm.rst)
    begin
        jeton <= 1;
    end
    else
    begin
        if (jeton && !wshb_ifs_mire.cyc) begin jeton <= 0; end
        else if (!jeton && !wshb_ifs_vga.cyc) begin jeton <= 1; end
    end
end

always_comb
begin
    if (jeton == 1)     //Mire 
    begin
        wshb_ifm.cyc = wshb_ifs_mire.cyc;
        wshb_ifm.stb = wshb_ifs_mire.stb;
        wshb_ifm.adr = wshb_ifs_mire.adr;
        wshb_ifm.we  = wshb_ifs_mire.we;
        wshb_ifm.dat_ms = wshb_ifs_mire.dat_ms;
        wshb_ifm.sel = wshb_ifs_mire.sel;
        wshb_ifm.cti = wshb_ifs_mire.cti;
        wshb_ifm.bte = wshb_ifs_mire.bte;
    end
    else                //VGA   
    begin
        wshb_ifm.cyc = wshb_ifs_vga.cyc;
        wshb_ifm.stb = wshb_ifs_vga.stb;
        wshb_ifm.adr = wshb_ifs_vga.adr;
        wshb_ifm.we  = wshb_ifs_vga.we;
        wshb_ifm.dat_ms = wshb_ifs_vga.dat_ms;
        wshb_ifm.sel = wshb_ifs_vga.sel;
        wshb_ifm.cti = wshb_ifs_vga.cti;
        wshb_ifm.bte = wshb_ifs_vga.bte;
    end
end

assign wshb_ifs_mire.err = 0;
assign wshb_ifs_mire.rty = 0;
assign wshb_ifs_mire.dat_sm = wshb_ifm.dat_sm;
assign wshb_ifs_mire.ack = wshb_ifm.ack && jeton;           //This inside always comb generates a latch

assign wshb_ifs_vga.err = 0;
assign wshb_ifs_vga.rty = 0;
assign wshb_ifs_vga.dat_sm = wshb_ifm.dat_sm;
assign wshb_ifs_vga.ack = wshb_ifm.ack && !jeton;

endmodule