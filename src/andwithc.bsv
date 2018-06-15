package andwithc;

  interface Ifc_andwithc#(type size_t);
    method Action ma_start(Bit#(size_t) rs1, Bit#(size_t) rs2);
    method Bit#(size_t) mn_done;
  endinterface

  module mkandwithc(Ifc_andwithc#(size_t));

    Reg#(Bit#(size_t)) rg_rd <- mkReg(0);
    Reg#(Bit#(1)) rg_work <- mkReg(0);
   
    method Action ma_start(Bit#(size_t) rs1, Bit#(size_t) rs2) if(rg_work == 0); 
      rg_work <= 1;
      rg_rd <= (rs1 & ~rs2);
    endmethod

    method Bit#(size_t) mn_done if(rg_work==1);
      return rg_rd;
    endmethod

  endmodule

endpackage
