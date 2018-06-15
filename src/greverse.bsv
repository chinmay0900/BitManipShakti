package greverse;

  interface Ifc_greverse#(type size_t);
    method Action ma_start(Bit #(size_t) rs1, Bit#(size_t) rs2);
    method Bit#(size_t) mn_done;
  endinterface
  
  module mkgreverse(Ifc_greverse#(size_t));

    Reg#(Bit#(size_t)) rg_rd <- mkReg(0);
    Reg#(Bit#(1)) rg_work <- mkReg(0);
   
    Integer n = valueOf (size_t);
   
    method Action ma_start(Bit#(size_t) rs1, Bit#(size_t) rs2) if(rg_work == 0);  
      Bit#(size_t) a = 0, b = 0, c = 0, d = 0, e = 0, f = 0;
      rg_work <= 1;
   
      if(n == 64) begin
        if(rs2[0] == 1) a = ((rs1 & 'h5555555555555555)<<1)|((rs1 & 'hAAAAAAAAAAAAAAAA)>>1);
        else a = rs1;
        if(rs2[1] == 1) b = ((a & 'h3333333333333333)<<2)|((a & 'hCCCCCCCCCCCCCCCC)>>2);
        else b = a;
        if(rs2[2] == 1) c = ((b & 'h0F0F0F0F0F0F0F0F)<<4)|((b & 'hF0F0F0F0F0F0F0F0)>>4);
        else c = b;
        if(rs2[3] == 1) d = ((c & 'h00FF00FF00FF00FF)<<8)|((c & 'hFF00FF00FF00FF00)>>8);
        else d = c;
        if(rs2[4] == 1) e = ((d & 'h0000FFFF0000FFFF)<<16)|((d & 'hFFFF0000FFFF0000)>>16);
        else e = d;
        if(rs2[5] == 1) f = ((e & 'h00000000FFFFFFFF)<<32)|((e & 'hFFFFFFFF00000000)>>32);
        else f = e;
        rg_rd <= f;
      end

      else begin
        if(rs2[0] == 1) a = ((rs1 & 'h55555555)<<1)|((rs1 & 'hAAAAAAAA)>>1);
        else a = rs1;
        if(rs2[1] == 1) b = ((a & 'h33333333)<<2)|((a & 'hCCCCCCCC)>>2);
        else b = a;
        if(rs2[2] == 1) c = ((b & 'h0F0F0F0F)<<4)|((b & 'hF0F0F0F0)>>4);
        else c = b;
        if(rs2[3] == 1) d = ((c & 'h00FF00FF)<<8)|((c & 'hFF00FF00)>>8);
        else d = c;
        if(rs2[4] == 1) e = ((d & 'h0000FFFF)<<16)|((d & 'hFFFF0000)>>16);
        else e = d;
        rg_rd <= e;
      end

    endmethod

    method Bit#(size_t) mn_done if(rg_work==1);
      return rg_rd;
    endmethod

  endmodule

endpackage
