package rotate;

  interface Ifc_rotate;
    method Action ma_start(Bit #(64) rs1, Bit#(64) rs2, Bit#(1) dir);
    method Bit#(64) mn_done;
  endinterface

  module mkrotate(Ifc_rotate);

    Reg#(Bit#(64)) rg_rd <- mkReg(64);
    Reg#(Bit#(1)) rg_work <- mkReg(0);

    method Action ma_start(Bit#(64) rs1, Bit#(64) rs2, Bit#(1) dir) if(rg_work == 0); 
      if(dir==0) rg_rd <= ~(~rs1 >> (rs2 & 63));
      else rg_rd <= ~(~rs1 << (rs2 & 63));
      rg_work <= 1;
    endmethod

    method Bit#(64) mn_done if(rg_work==1);
      return rg_rd;
    endmethod


  endmodule

endpackage
