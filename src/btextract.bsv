package btextract;

  import Vector::*;

  interface Ifc_btextract;
    method Action ma_start(Bit #(64) rs1, Bit#(64) rs2);
    method Bit#(64) mn_done;
  endinterface

  module mkbtextract(Ifc_btextract);

    Reg#(Bit#(64)) rg_x <- mkRegU();
    Reg#(Bit#(64)) rg_y <- mkRegU();
    Reg#(Bit#(64)) rg_work <- mkReg(0);
    Reg#(Bit#(64)) rg_count <- mkReg(0);
    Reg#(Bit#(64)) rg_m <- mkReg(1);
    Reg#(Bit#(64)) rg_lsetbt <- mkRegU();

    rule rl_getbtextract(rg_work == 1);
      if(rg_y != 0) begin
        rg_lsetbt <= rg_y & (-rg_y);
        rg_work <= 2;
      end else rg_work <= 3;
    endrule

    rule rl_putbtextract(rg_work == 2);
      if((rg_x & rg_lsetbt) > 0) rg_count <= rg_count | rg_m;
      rg_y <= rg_y - rg_lsetbt;
      rg_m <= rg_m << 1;
      rg_work <= 1;
    endrule
    
    method Action ma_start(Bit#(64) rs1, Bit#(64) rs2) if(rg_work == 0); 
      rg_work <= 1;
      rg_x <= rs1;
      rg_y <= rs2;
    endmethod

    method Bit#(64) mn_done if(rg_work==3);
      return rg_count;
    endmethod

  endmodule

endpackage
