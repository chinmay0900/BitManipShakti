package greverse;

  interface Ifc_greverse;
    method Action ma_start(Bit #(64) rs1, Bit#(64) rs2);
    method Bit#(64) mn_done;
  endinterface
  
  module mkgreverse(Ifc_greverse);

    Reg#(Bit#(64)) rg_rd <- mkReg(0);
    Reg#(Bit#(1)) rg_work <- mkReg(0);
    method Action ma_start(Bit#(64) rs1, Bit#(64) rs2) if(rg_work == 0);  
      Bit#(64) a = 0, b = 0, c = 0, d = 0, e = 0, f = 0;
      rg_work <= 1;
      if(rs2[0] == 1) a = ((rs1&64'h5555555555555555)<<1)|((rs1&64'hAAAAAAAAAAAAAAAA)>>1);
        else a = rs1;
        if(rs2[1] == 1) b = ((a&64'h3333333333333333)<<2)|((a&64'hCCCCCCCCCCCCCCCC)>>2);
        else b = a;
        if(rs2[2] == 1) c = ((b&64'h0F0F0F0F0F0F0F0F)<<4)|((b&64'hF0F0F0F0F0F0F0F0)>>4);
        else c = b;
        if(rs2[3] == 1) d = ((c&64'h00FF00FF00FF00FF)<<8)|((c&64'hFF00FF00FF00FF00)>>8);
        else d = c;
        if(rs2[4] == 1) e = ((d&64'h0000FFFF0000FFFF)<<16)|((d&64'hFFFF0000FFFF0000)>>16);
        else e = d;
        if(rs2[5] == 1) f = ((e&64'h00000000FFFFFFFF)<<32)|((e&64'hFFFFFFFF00000000)>>32);
        else f = e;
        rg_rd <= f;
    endmethod

    method Bit#(64) mn_done if(rg_work==1);
      return rg_rd;
    endmethod

  endmodule

endpackage
