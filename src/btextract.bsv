package btextract;

  interface Ifc_btextract#(type size_t);
    method Action ma_start(Bit #(size_t) rs1, Bit#(size_t) rs2);
    method Bit#(size_t) mn_done;
  endinterface

  module mkbtextract(Ifc_btextract#(size_t));

    Reg#(Bit#(size_t)) rg_x <- mkRegU();
    Reg#(Bit#(size_t)) rg_y <- mkRegU();
    Reg#(Bit#(size_t)) rg_work <- mkReg(0);
    Reg#(Bit#(size_t)) rg_count <- mkReg(0);
    Reg#(Bit#(size_t)) rg_m <- mkReg(1);
    
    rule rl_putbtextract(rg_work == 1);
      if((rg_x & (rg_y & -rg_y)) > 0) rg_count <= rg_count | rg_m;
      rg_y <= rg_y - (rg_y & -rg_y);
      rg_m <= rg_m << 1;
      if (rg_y == 0) rg_work <= 2;
    endrule
    
    method Action ma_start(Bit#(size_t) rs1, Bit#(size_t) rs2) if(rg_work == 0); 
      rg_work <= 1;
      rg_x <= rs1;
      rg_y <= rs2;
    endmethod

    method Bit#(size_t) mn_done if(rg_work==2);
      return rg_count;
    endmethod

  endmodule

endpackage
