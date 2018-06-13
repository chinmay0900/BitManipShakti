package andwithc;

  interface Ifc_andwithc;
    method Action ma_start(Bit#(64) rs1, Bit#(64) rs2);
    method Bit#(64) mn_done;
  endinterface

  module mkandwithc(Ifc_andwithc);

    Reg#(Bit#(64)) rg_rd <- mkReg(0);
    Reg#(Bit#(1)) rg_work <- mkReg(0);
   
    method Action ma_start(Bit#(64) rs1, Bit#(64) rs2) if(rg_work == 0); 
      rg_work <= 1;
      rg_rd <= (rs1 & ~rs2);
    endmethod

    method Bit#(64) mn_done if(rg_work==1);
      return rg_rd;
    endmethod

  endmodule

endpackage
