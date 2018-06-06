package btdeposit;

  interface Ifc_btdeposit;
    method Action ma_start(Bit #(64) rs1, Bit#(64) rs2);
    method Bit#(64) mn_done;
  endinterface

  module mkbtdeposit(Ifc_btdeposit);

    Reg#(Bit#(64)) rg_x <- mkRegU();
    Reg#(Bit#(64)) rg_y <- mkRegU();
    Reg#(Bit#(64)) rg_work <- mkReg(0);
    Reg#(Bit#(64)) rg_count <- mkReg(0);
    Reg#(Bit#(64)) rg_m <- mkReg(1);
    
    rule rl_putbtdeposit(rg_work == 1);
      if((rg_x & (rg_m)) > 0) rg_count <= rg_count | (rg_y & -rg_y);
      rg_y <= rg_y - (rg_y & -rg_y);
      rg_m <= rg_m << 1;
      if (rg_y == 0) rg_work <= 2;
    endrule
    
    method Action ma_start(Bit#(64) rs1, Bit#(64) rs2) if(rg_work == 0); 
      rg_work <= 1;
      rg_x <= rs1;
      rg_y <= rs2;
    endmethod

    method Bit#(64) mn_done if(rg_work==2);
      return rg_count;
    endmethod

  endmodule

endpackage
